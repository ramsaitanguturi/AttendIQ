# Architecture Audit: AttendIQ

**Audit Date:** 2026-11-10
**Scope:** Phases 0–4 Read-Only Baseline & Architectural Recovery Audit
**Repository:** `c:\Users\ramsa\Desktop\AttendIQ` (`main` branch, HEAD `fe176ba`, with 22 modified tracked files and 13 untracked entries in the working tree)

---

## 1. Executive Architectural Assessment

AttendIQ is built as a local-first Flutter application targeting Android (with leftover multi-platform scaffolding for iOS/web/desktop and historical documentation from an earlier Firebase-backed design). While its core UI shell, 12 Isar collections, GoRouter routes, and domain math primitives are present, the codebase suffers from **three structural fractures** introduced across incomplete refactors:

1. **Dual Split-Brain Timetable & Event Architecture *(Unified in `BUG-004`)*:**
   - **Canonical subsystem**: `WeeklyScheduleRuleLocal` (with `@Index() int? legacyTemplateId`), `DailyScheduleOccurrenceLocal` (with `@Index() int? ruleId`, `legacyEventId`, and type-scoped `slotKey`), and `AttendanceRecordLocal` (with `@Index() int? occurrenceId` + `legacyEventId`) now serve as the single source of truth across timetable scheduling, attendance marking, subject history, analytics, reports, AI context, widgets, notifications, and backup export/import.
   - **Legacy subsystem** (`TimetableTemplateLocal`, `EventLocal`, `EventGeneratorService`) is retained strictly as read-only migration and backup compatibility structures while idempotent `migrateLegacyTimetableAndEvents(Isar)` consolidates legacy rows into canonical tables without silent collision overwrites.
2. **Unsafe Initialization & Lifecycle State Management**:
   - [`isarProvider`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/database/isar_provider.dart#L22-L23) and [`notificationInitializerProvider`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/notifications/providers/notification_providers.dart#L30-L31) both use `@riverpod` without `keepAlive: true`, generating `AutoDispose*` providers.
   - [`main()`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/main.dart#L15-L46) catches database and notification initialization timeouts/exceptions and boots the UI anyway, causing downstream `.requireValue` consumers to throw `StateError` if Isar fails to open.
   - `notificationInitializerProvider` is only read once via `container.read(...)` during startup and immediately auto-disposes, cancelling its five Isar `.watchLazy()` subscriptions before the app even renders.
3. **Architecture-to-Documentation Drift**:
   - Repository markdown files conflict sharply on whether Firebase Auth/Cloud Firestore sync exists, which flavor names and entry points exist, how `Late` attendance weighting works, and what tests/mocks are used.

---

## 2. Technology Stack & Code Organization

### 2.1 Framework & Core Stack
- **SDKs**: Flutter `3.22.0` (`channel [user-branch]`), Dart `3.4.0` (`sdk: '>=3.4.0 <4.0.0'`).
- **State Management**: `flutter_riverpod` (`2.6.1`), `riverpod_annotation` (`2.6.1`), `riverpod_generator` (`2.4.0`).
- **Local Persistence**: `isar` (`4.0.0-dev.14`), `isar_flutter_libs` (`4.0.0-dev.14`).
- **Navigation**: `go_router` (`14.8.1`).
- **Android Native Integrations**: Kotlin `1.8.22`, AGP `7.3.0`, Gradle `7.6.3`, Java `1.8` target (`JDK 17.0.19+10` used for build toolchain), `home_widget` (`0.6.0`), `flutter_local_notifications` (`17.2.4`), `workmanager` (`0.5.2`), native `MethodChannel('com.ramsa.attendiq/storage')`.

### 2.2 Folder Structure (`lib/` — 174 Dart files)
- **App Entry & Routing (`lib/main.dart`, `lib/app/`)**:
  - [`lib/main.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/main.dart): Bootstraps `ProviderContainer`, pre-warms `isarProvider` & `notificationInitializerProvider` with 5s timeouts, launches `UncontrolledProviderScope(child: AttendIQApp())`.
  - [`lib/app/app.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/app/app.dart): `AttendIQApp` wires `HomeWidget` click listeners/deep links, triggers launch widget refresh, and renders `MaterialApp.router`.
  - [`lib/app/app_router.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/app/app_router.dart): `GoRouter` (`@Riverpod(keepAlive: true)`) with 13 routes (`/splash`, `/onboarding`, `/dashboard`, `/analytics`, `/timetable`, `/subject/:id`, `/settings`, `/backup`, `/about`, `/reports`, `/ai-assistant`, `/planner`, `/widget-settings`) and `RouterNotifier` listening to `hasActiveSemesterProvider`.
- **Shared Core Engines (`lib/core/`)**:
  - `ai/` — `AIProvider` interface, `GeminiAIProvider` (direct `dart:io` `HttpClient`), `LocalAdvisorService`, `AIContextBuilder`, `AIResponseParser`, `AdvisorPrompts`.
  - `analytics/` — `AnalyticsCalculator` (pure math), `AnalyticsService` (Isar/repo aggregation).
  - `attendance_engine/` — `AttendanceCalculator`, `AttendancePredictor`, `BunkAnalyzer`.
  - `backup/` — `BackupExporter`, `BackupImporter`, `BackupModels`, `BackupPathHelper`, `BackupScheduler`, `BackupService`.
  - `constants/` — `AppConstants`.
  - `database/` — `isar_provider.dart` and consolidated legacy timetable/event migration ([`timetable_migration.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/database/timetable_migration.dart)).
  - `errors/` — `AppException` & `Failure` hierarchies (largely unused by repositories/controllers).
  - `event_generator/` — Legacy `EventLocal`, `EventGenerator`, `EventGeneratorService`.
  - `notifications/` — `NotificationItem`, `LocalNotificationServiceImpl`, `NotificationScheduler`, `IsarNotificationDatabaseImpl`, providers.
  - `reports/` — `ReportService`, `PdfReportGenerator`, `CsvReportExporter`, models.
  - `theme/` — `AppTheme`, `AppColors`, `AppTextStyles`.
  - `utils/` — `generateUuid()`.
  - `widgets/` — `ExportSuccessDialog`.
- **Feature Modules (`lib/features/`)**:
  11 feature folders following mixed Clean Architecture (`data/` / `domain/` / `presentation/`) and simplified service layouts:
  `academic_planner`, `ai_assistant`, `analytics`, `attendance`, `backup`, `onboarding`, `semester`, `settings`, `subject`, `timetable`, `widgets`.

---

## 3. Application Startup & Navigation Flow

```
main()
  ├─ container.read(isarProvider.future).timeout(5s)         [catch-all ignores failure!]
  ├─ container.read(notificationInitializerProvider.future)  [AutoDispose cancels listeners after boot]
  └─ runApp(UncontrolledProviderScope -> AttendIQApp)
       ├─ initState: HomeWidget deep links (attendiq://today|timetable|calendar|planner) + refreshAllWidgets()
       └─ GoRouter (initialLocation: '/splash', refreshListenable: RouterNotifier)
            ├─ hasActiveSemesterProvider.isLoading  ──> '/splash'
            ├─ hasSemester == true  && (/splash || /onboarding) ──> '/dashboard'
            └─ hasSemester == false && (/splash || /dashboard)  ──> '/onboarding'
```

**Observed Routing & Boot Gaps**:
- `debugLogDiagnostics: true` is permanently enabled in release builds (`lib/app/app_router.dart:45`).
- If `hasActiveSemesterProvider` errors (e.g. Isar failed to open), `hasSemesterAsync.valueOrNull ?? false` evaluates to `false`, redirecting `/dashboard` -> `/onboarding` instead of surfacing a recovery error screen (`lib/app/app_router.dart:48-68`).
- When `hasSemester == false`, routes other than `/splash` and `/dashboard` (such as `/timetable` or `/planner` via deep links) are not redirected to `/onboarding`.
- [`DashboardPage`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/analytics/presentation/pages/dashboard_page.dart) instructs users with zero subjects to `"Tap Onboarding or Timetable to add"`, yet `app_router.dart:61` blocks `/onboarding` once a semester exists.

---

## 4. Database Schema & Persistence Architecture

[`isarProvider`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/database/isar_provider.dart#L33-L50) opens Isar `attendiq_isar` with 12 schemas:

| # | Collection (`*Local` / Item) | Indexed Fields | Active vs Legacy | Key Structural / Consistency Findings |
|---|---|---|---|---|
| 1 | `SemesterLocal` | `serverId` (unique), `isActive`, `status` | Active | Updated in `BUG-017`: carries explicit `isActive` + `status` (`draft`/`active`/`archived`), single-active invariant, strict `startDate < endDate` & non-overlap validation, idempotent startup migration (`migrateLegacySemesters`), and unified lookup (`resolveActiveSemesterLocal` / `SemesterRepository.getActiveSemester()`). |
| 2 | `SubjectLocal` | `serverId` (unique), `semesterId` | Active | Soft-delete sets `isDeleted=true` only; orphans rules, occurrences, and tasks. |
| 3 | `TimetableTemplateLocal` | `serverId` (unique), `subjectId`, `weekday` | Legacy (Read-Only) | Retained read-only for legacy DB migration & backup compatibility; migrated idempotently to `WeeklyScheduleRuleLocal` by `migrateLegacyTimetableAndEvents`. |
| 4 | `WeeklyScheduleRuleLocal` | `serverId` (unique), `subjectId`, `dayOfWeek`, `legacyTemplateId` | Canonical | Canonical recurring schedule rule preserving `type` (`THEORY`/`LAB`) and exported/imported with `type` & `legacyTemplateId`. |
| 5 | `ScheduleExceptionLocal` | `serverId` (unique), `date`, `subjectId`, `type` | Active | Honored by schedule providers & `NotificationScheduler`; controller 30d/90d range truncation tracked in `BUG-022`. |
| 6 | `DailyScheduleOccurrenceLocal` | `serverId` (unique), `date`, `subjectId`, `status`, `ruleId`, `legacyEventId`, `slotKey` | Canonical | Canonical dated occurrence keyed by type-scoped `slotKey` (`REGULAR`, `EXTRA`, `EXAM`, `EVENT`, `LEGACY_EV`) via `upsertCanonicalOccurrenceInWriteTx`. Ignored by `monthlyCalendarDataProvider` (`BUG-022`). |
| 7 | `AcademicEventLocal` | `serverId` (unique), `date`, `type` | Active | `AcademicEventRepositoryImpl` omits UUID generation for `serverId`. |
| 8 | `AcademicTaskLocal` | `serverId` (unique), `taskType`, `subjectId`, `startDate`, `dueDate`, `priority`, `status` | Active | `TaskRepositoryImpl` omits UUID generation for `serverId`. `TaskListController` crashes if `subjects` is empty. |
| 9 | `EventLocal` | `serverId` (unique), `subjectId`, `date`, `status` | Legacy (Read-Only) | Retained read-only for migration/backup compatibility; consumers migrated off `EventLocal` in `BUG-004` (`createExtraClassEvent` now writes `DailyScheduleOccurrenceLocal`). |
| 10 | `AttendanceRecordLocal` | `serverId` (unique), `occurrenceId`, `legacyEventId`, `eventId`, `subjectId`, `markedAt` | Canonical | Links via `occurrenceId` (fallback compatibility on `eventId`); `LATE` status tracked in `BUG-018`. |
| 11 | `NotificationItem` | `type`, `androidNotificationId` | Active | `BUG-009` added `autoIncrement()` & 32-bit `androidNotificationId`; `BUG-004` namespaced `relatedId` (`slot:<slotKey>`, `ae_1d:<id>`, `ae_30m:<id>`, `sub:<id>`) & switched watchers to canonical tables. |
| 12 | `UserPreferencesLocal` | `serverId` (unique) | Active | Auto-backup fields excluded from `BackupExporter`/`BackupImporter`; `lateWeight` missing. |

**Migration & Transaction Findings**:
- Consolidated single startup migration in [`isar_provider.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/database/isar_provider.dart) -> [`migrateLegacyTimetableAndEvents`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/database/timetable_migration.dart) (templates->rules, occurrence normalization/dedup, `EventLocal` disambiguation, conservative attendance reconciliation & audit reporting). Constructor side-effects in [`WeeklyScheduleRuleLocalDataSourceImpl`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/data/datasources/weekly_schedule_rule_local_data_source.dart) were replaced with a lazy guard delegating to `migrateLegacyTimetableAndEvents`.
- Repository mutations run in isolate-safe `_isar.writeAsync(...)` transactions (lookups inside `writeAsync`).
- In [`BackupImporter`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/backup/backup_importer.dart), parent->child topological import builds ID/FK/`serverId`/notification `relatedId` translation maps across Replace & Merge strategies (conflicting source/destination IDs and duplicate `serverId`s remapped safely), followed by `normalizeSemestersInWriteTx`, `runTimetableUnificationInWriteTx`, and `migrateLegacyNotificationItems`. (`BUG-007` empty `{}` JSON pre-validation remains tracked separately.)

---

## 5. Layering, Clean Architecture & State Management Violations

1. **Presentation/Services Bypassing Domain Repositories**:
   - `ReportService` (`report_service.dart`), `AnalyticsService` (`analytics_service.dart`), `AiContextBuilder` (`ai_context_builder.dart`), and `subjectEventsProvider`/`subjectEventCountsProvider` (`subject_attendance_stats_provider.dart`) inject `Isar` directly via `ref.watch(isarProvider).requireValue` and query `*Local` Isar schemas, violating `docs/CODING_RULES.md`.
   - `NotificationItem` (`@collection`) is used as both persistence DTO and domain/service model (`NotificationService`, `NotificationScheduler`, `TaskNotificationScheduler`).
2. **Code Generation Stale Timestamps & `AutoDispose` Misconfiguration**:
   - Four source files (`notification_providers.dart`, `attendance_controller.dart`, `timetable_controller.dart`, `today_schedule_provider.dart`) have mtimes (`07/21/2026`) newer than their `.g.dart` outputs (`07/20/2026`).
   - Virtually all infrastructure providers (`isarProvider`, `notificationInitializerProvider`, `notificationSchedulerProvider`, repositories, datasources) default to `AutoDispose` (`@riverpod` instead of `@Riverpod(keepAlive: true)`).
3. **UI Lifecycle & Unstable Family Providers**:
   - `BUG-004` routed [`dayScheduleProvider`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart#L87-L95) through canonical date-keyed `dayScheduleByKeyProvider` (`formatUtcDateKey`) and normalized [`aiContextProvider`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/ai/context/ai_context_builder.dart) calls; [`SemesterWeeklyCalendarView`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/widgets/semester_weekly_calendar_view.dart#L53-L54) still re-instantiates `_weekPageController` inside `build()` and shares a single `_dayPageController` across week pages (`BUG-021`).

---

## 6. Documentation vs. Implementation Contradictions

| Topic | Documented Claim | Actual Codebase Evidence |
|---|---|---|
| **Backend / Firebase Sync** | Untracked root `ARCHITECTURE.md`, `DATABASE.md`, `PROJECT.md`, `TECH_STACK.md`, `DEVELOPMENT.md` and `docs/MVP_SCOPE.md`, `docs/TESTING.md`, `docs/NOTIFICATION_SERVICE.md`, `docs/RELEASE_CHECKLIST.md` describe Firebase Auth, Cloud Firestore, FCM, outbox queue sync. | Zero Firebase packages in [`pubspec.yaml`](file:///c:/Users/ramsa/Desktop/AttendIQ/pubspec.yaml); README/CHANGELOG/active code are 100% offline-first using Isar and Gemini HTTP calls. (`isDirty` flags are dead metadata, often hardcoded `false`). |
| **Build Flavors & Entry Points** | `docs/DEVELOPMENT.md:49-59`, `docs/CI_CD.md:144`, `docs/TESTING.md:157` specify flavors `dev` (`lib/main_development.dart`) and `stg` (`lib/main_staging.dart`). | Only [`lib/main.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/main.dart) exists. [`android/app/build.gradle:69-88`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/app/build.gradle#L69-L88) defines flavors **`prod`** and **`beta`**. |
| **App Version** | Git HEAD `fe176ba` says `v2.0.0`; `RELEASE_NOTES.md:3` & `pubspec.yaml:19` say `1.1.0`. | [`AppConstants.appVersion`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/constants/app_constants.dart#L5) is hardcoded `'1.0.0'`. |
| **`Late` Status & Weight ($W_l$)** | `docs/DOMAIN_RULES.md` §1.1–1.2, `docs/PROJECT.md`, `docs/FEATURES.md`, `docs/TESTING.md`, `RELEASE_NOTES.md` require `late` status with configurable weight $W_l$ (`AppConstants.defaultLateWeight = 1.0`). | No `LATE` enum value in [`AttendanceStatus`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/attendance/domain/entities/attendance_record.dart#L1-L7) or `OccurrenceStatus`, `AttendanceCalculator` uses `int attended`, no `lateWeight` in settings/calculators. |
| **Soft-Deleted Subject History** | `docs/DOMAIN_RULES.md` §3 requires preserving attendance logs of soft-deleted subjects in overall semester averages and historical charts. | [`AnalyticsService`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/analytics/services/analytics_service.dart#L43-L69), [`ReportService`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/reports/services/report_service.dart#L49), and `allSubjectAttendanceStats` query only non-deleted subjects, dropping historical logs. |
| **Semester Lifecycle & Validation** | `docs/DOMAIN_RULES.md` §2 specifies Draft/Active/Archived states, single active semester, `startDate < endDate`, and non-overlapping semester dates. | Implemented in `BUG-017`: [`SemesterLocal`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/semester/data/models/semester_local.dart) & [`Semester`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/semester/domain/entities/semester.dart) track `draft`/`active`/`archived`, [`SemesterValidator`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/semester/domain/validators/semester_validator.dart) & [`SemesterRepositoryImpl`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/semester/data/repositories/semester_repository_impl.dart) enforce `startDate < endDate`, non-overlap, read-only archived edits, and single active semester; Settings provides create/edit/switch/archive UI. |
| **Event Generation Architecture** | `docs/ATTENDANCE_ENGINE.md` describes physical `EventLocal` rolling generation into DB rows with `unlogged` status; `docs/ARCHITECTURE.md` lists backup v1 collections (`7` tables). | Unified in `BUG-004` onto canonical `WeeklyScheduleRuleLocal` + `DailyScheduleOccurrenceLocal` + `AttendanceRecordLocal.occurrenceId` (`EventLocal`/`TimetableTemplateLocal` retained read-only for compatibility); `BackupExporter` exports `12` collections (`backupVersion: 2`). |
| **Testing & Mocking** | `docs/TESTING.md:34-39`, `docs/MVP_SCOPE.md:71-78`, `docs/CODING_RULES.md:9` mandate `mocktail`, `AttendanceMath`, integration tests, >=80% coverage, and zero lint errors. | No `mocktail`, no `AttendanceMath`, no `integration_test/` folder; tests use manual fakes/no-ops; `flutter analyze` fails with 268 issues (2 compile errors). |
| **CI/CD Workflow** | `docs/CI_CD.md:116-163` describes `flutter test --coverage`, APK flavor `dev` release build, and iOS IPA builds. | [`.github/workflows/flutter.yml`](file:///c:/Users/ramsa/Desktop/AttendIQ/.github/workflows/flutter.yml) runs `dart format` -> `build_runner` -> `flutter analyze` -> `flutter test` only (and currently fails on format & analyze). |

