# Execution, Build & Test Results: AttendIQ

**Audit Date:** 2026-11-10
**SDK Executed:** `.\flutter_sdk\bin\flutter.bat` (`Flutter 3.22.0`, `Dart 3.4.0`), `JDK 17.0.19+10`

---

## 1. Command Execution Summary (Phase 2)

| Check / Command | Outcome | Exit Code | Key Metrics & Exact Output Observations |
|---|---|:---:|---|
| `.\flutter_sdk\bin\flutter.bat --version` & `dart.bat --version` | **PASS** | `0` | `Flutter 3.22.0 • channel [user-branch]`, `Tools Dart 3.4.0`, `Dart SDK version: 3.4.0 (stable)` |
| `.\flutter_sdk\bin\flutter.bat doctor -v` | **WARN** | `0` | Windows OK; `[!] Flutter` (not on PATH, user-branch); `[!] Android toolchain` (`36.0.0`, Java 17 Temurin, `Some Android licenses not accepted`); Chrome/Edge detected. |
| `.\flutter_sdk\bin\flutter.bat pub outdated` | **INFO** | `0` | `11` direct dependencies constrained older than resolvable versions; transitive `js`, `build_resolvers`, `build_runner_core` discontinued. |
| `.\flutter_sdk\bin\dart.bat format --output=none --set-exit-if-changed lib test` | **FAIL** | `1` | `Formatted 197 files (124 changed) in 6.03 seconds.` Would fail CI formatting check immediately. |
| `.\flutter_sdk\bin\flutter.bat analyze` | **FAIL** | `1` | **`268 issues found. (ran in 181.4s)`** — Breakdown: **`2` errors**, **`28` warnings**, **`238` infos**. |
| `.\flutter_sdk\bin\flutter.bat test` | **PASS** | `0` | **`01:44 +116: All tests passed!`** Across 23 test files (`MissingPluginException` & `Helvetica` Unicode warnings printed to logs). |
| `.\flutter_sdk\bin\flutter.bat build apk --debug` (no flavor) | **STOPPED** | — | Superseded/cancelled (`task-134`) while running concurrent Gradle daemon against flavored build (`task-135`). Project requires `--flavor prod` or `--flavor beta`. |
| `$env:JAVA_HOME="...jdk-17..."; .\flutter_sdk\bin\flutter.bat build apk --debug --flavor prod` | **PASS** | `0` | **`Running Gradle task 'assembleProdDebug'... 879.4s`** -> `√ Built build\app\outputs\flutter-apk\app-prod-debug.apk` (`445,479,716` bytes). |
| `flutter emulators` / `adb devices` | **NONE** | `0` | Zero emulators configured; zero physical devices attached. Live UI/device/widget tests could not run. |

*(Note: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, and `dart format .` were NOT executed in mutating mode because Phases 0–4 require no source/generated-file modifications.)*

---

## 2. Static Analysis Breakdown (`flutter analyze`)

**Total: 268 issues (`2` errors, `28` warnings, `238` infos)**

### 2.1 Blocking Compile Errors (`2`)
- [`lib/features/timetable/presentation/controllers/today_schedule_provider.dart:157:18`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/controllers/today_schedule_provider.dart#L157) — `error: argument_type_not_assignable`: `The argument type 'dynamic' can't be assigned to the parameter type 'String'` (caused by `subjectMap = <int, dynamic>{}` at line `93` under `strict-casts: true`).
- [`lib/features/timetable/presentation/controllers/today_schedule_provider.dart:164:20`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/controllers/today_schedule_provider.dart#L164) — `error: argument_type_not_assignable`: `The argument type 'dynamic' can't be assigned to the parameter type 'String?'`.

### 2.2 Warnings (`28`)
- **`strict_raw_type` (1)**: [`lib/app/app.dart:19`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/app/app.dart#L19) (`StreamSubscription? _sub;`).
- **`unused_field` (3)**: [`backup_service.dart:24`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/backup/backup_service.dart#L24) (`_isar`), [`weekly_timetable_page.dart:26,28`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/pages/weekly_timetable_page.dart#L26-L28) (`_selectedWeekdayIndex`, `_dayNames`).
- **`unused_local_variable` (1)**: [`weekly_timetable_page.dart:38`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/pages/weekly_timetable_page.dart#L38) (`subjectsAsync`).
- **`unused_import` (12)**: [`add_edit_task_sheet.dart:6`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/academic_planner/presentation/widgets/add_edit_task_sheet.dart#L6), [`dashboard_page.dart:7,8,9`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/analytics/presentation/pages/dashboard_page.dart#L7-L9), [`reports_page.dart:2`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/analytics/presentation/pages/reports_page.dart#L2), [`academic_calendar_controller.dart:4,6,9,11,15`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/controllers/academic_calendar_controller.dart#L4-L15), [`timetable_controller.dart:2,3`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/controllers/timetable_controller.dart#L2-L3), [`weekly_schedule_view_controller.dart:6`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart#L6).
- **`inference_failure_on_function_invocation` (8)**: Untyped `showModalBottomSheet` / `showDialog` calls in `academic_planner_page.dart:124`, `task_card_widget.dart:79`, `dashboard_page.dart:782`, `academic_calendar_widget.dart:220`, `date_details_bottom_sheet.dart:189,340,437,502`.
- **`inference_failure_on_untyped_parameter` (1)**: [`notification_providers.dart:40`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/notifications/providers/notification_providers.dart#L40) (`catchError((e) ...)`).
- **`inference_failure_on_function_return_type` (1)**: [`day_timeline_view.dart:9`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/timetable/presentation/widgets/day_timeline_view.dart#L9).
*(Note: Remaining 1 warning is counted in the 28 total — specifically `dashboard_page.dart` has 3 + `academic_calendar_controller` 5 + `timetable_controller` 2 + `weekly_schedule_view_controller` 1 + `reports_page` 1 + `add_edit_task_sheet` 1 = 13 unused_import warnings, wait: let's verify exact sum: 1 `strict_raw_type` + 3 `unused_field` + 1 `unused_local_variable` + 13 `unused_import` + 8 `inference_failure_on_function_invocation` + 1 `inference_failure_on_untyped_parameter` + 1 `inference_failure_on_function_return_type` = **28**!)*

### 2.3 Info Diagnostics (`238`)
- Notably includes **`use_build_context_synchronously`** ([`export_success_dialog.dart:88`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/widgets/export_success_dialog.dart#L88)), **`await_only_futures`** across Isar v4 synchronous queries (`backup_exporter.dart`, `backup_scheduler.dart`, `isar_provider.dart`, `semester_repository_impl.dart`, `settings_repository_impl.dart`, `task_local_datasource.dart`, timetable datasources — because Isar 4 `findAll()`/`get()` are synchronous!), `unused_element` (`weekly_timetable_page.dart:30,330`), `require_trailing_commas`, `constant_identifier_names`, and `prefer_const_*`.

---

## 3. Test Suite Audit (`flutter test` — 23 files, 116 passed)

Although all `116` tests pass cleanly (`TEST_EXIT:0`), inspecting the 23 test files reveals **critical coverage blind spots and misleading mocks**:

| Test File | Tests | What It Actually Covers | Blind Spots / Masking Bugs |
|---|---:|---|---|
| [`analytics_calculator_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/core/analytics_calculator_test.dart) | 7 | Pure `AnalyticsCalculator` subject & overall metrics, streak, trends | Never tests `LATE` or `AnalyticsService` Isar integration (`EventLocal` vs `DailyScheduleOccurrence`). |
| [`attendance_engine_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/core/attendance_engine_test.dart) | 14 | Pure math: percentage, safe bunks, required classes, predictor, `BunkAnalyzer` | No `LATE` weight $W_l$ support; `calculatePercentage` only takes `int`. |
| [`backup_path_helper_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/core/backup/backup_path_helper_test.dart) | 4 | Filename sanitization & format helpers | Never tests Android `MediaStore` MethodChannel, `listBackupFiles()`, or scoped storage paths. |
| [`backup_scheduler_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/core/backup/backup_scheduler_test.dart) | 5 | `getNextScheduledBackup`, `getDisplayFolderPath`, `formattedSize` | Never tests `checkAndRunAutoBackup` or `Workmanager` initialization/execution. |
| [`backup_service_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/core/backup/backup_service_test.dart) | 4 | `BackupMetadata` & `BackupData` JSON, corrupted JSON, version > 2 | Uses `FakeIsar`; **never calls `BackupExporter.exportData` or `BackupImporter.importData(replace/merge)`**, hiding Merge FK corruption & empty `{}` Replace wipe! |
| [`notification_scheduler_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/core/notification_scheduler_test.dart) | 3 | `NotificationScheduler` with `MockNotificationDatabase` | **Mock auto-increments `item.id`**, masking `NotificationItem` ID=0 overwrite bug in real `IsarNotificationDatabaseImpl`; tests legacy `EventLocal`/`TimetableTemplateLocal` only. |
| [`academic_calendar_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/academic_calendar_test.dart) | 4 | Month grid + fake controller overrides | Overrides all providers with Fakes, hiding `ScheduleExceptionController` 30d/90d truncation and missing occurrences. Widget test triggers `MissingPluginException` (`path_provider`). |
| [`academic_planner_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/academic_planner_test.dart) | 5 | Urgency math, `TaskListController`, `TaskNotificationScheduler`, calendar tasks | Uses `FakeTaskRepository`; never tests `addTask` with empty `subjects` (`StateError` crash) or `AddEditTaskSheet` with deleted subject. Prints past-time warnings & `MissingPluginException`. |
| [`ai_advisor_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/ai_advisor_test.dart) | 7 | `AIResponseParser` & `LocalAdvisorService` with dummy context | Never tests `AIContextBuilder` (dormant `EventLocal` bug) or `AIChatController` online error fallback failure. |
| [`attendance_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/attendance_test.dart) | 5 | `AttendanceRepositoryImpl` CRUD via `FakeAttendanceLocalDataSource` | **No-op `updateEventStatus()` and stub `return 999` in `createExtraClassEvent`**, completely hiding real Isar `LateInitializationError` and `eventId` collisions! |
| [`daily_schedule_occurrence_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/daily_schedule_occurrence_test.dart) | 6+ | Entity instantiation & inline counters inside test body | Tests Dart object constructors rather than `TodayScheduleProvider`, `AttendanceController`, or Isar persistence. |
| [`dashboard_weekly_timetable_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/dashboard_weekly_timetable_test.dart) | 6 | `SemesterWeekCalculator` & standalone `WeekSelectorWidget` | Never mounts `SemesterWeeklyCalendarView` or `DayScheduleProvider`, hiding `PageController` leaks and shared `_dayPageController` crash. |
| [`end_to_end_verification_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/end_to_end_verification_test.dart) | 6 | In-memory fake attendance, entity construction, `BackupData` JSON | Does not test `Isar` or real `BackupImporter`/`BackupExporter`. |
| [`event_generator_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/event_generator_test.dart) | 4 | Legacy `EventGenerator` rolling/full generation | Tests unused legacy generator; zero tests for active `DailyScheduleOccurrence` flow. |
| [`flexible_timetable_architecture_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/flexible_timetable_architecture_test.dart) | 8+ | `WeeklyScheduleRule` / `DailyScheduleOccurrence` entity modeling | Pure model/list manipulation; does not test controllers, collision edge cases in dialogs, or providers. |
| [`production_readiness_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/production_readiness_test.dart) | 2 | `LocalAdvisorService` & `NotificationScheduler` exception safety | **Sets `subjects = []` in notification failure test**, so `_notificationService.scheduleNotification` is never actually invoked! |
| [`reports_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/reports_test.dart) | 5 | `ReportService` (with mocked `getActiveSemesterLocalId()`), PDF, CSV | **Mocks out buggy `getActiveSemesterLocalId()`**; emits `Helvetica has no Unicode support` warning. |
| [`settings_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/settings_test.dart) | 3 | `UserPreferences` entity & `SettingsController` | Fake repo; doesn't test persistence of auto-backup fields across backup/restore. |
| [`subject_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/subject_test.dart) | 3 | `SubjectRepositoryImpl` CRUD + soft delete | Uses `FakeSubjectLocalDataSource`; misses orphaned rules/occurrences/tasks and stats omission on soft delete. |
| [`timetable_exceptions_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/timetable_exceptions_test.dart) | 6 | `WeeklyScheduleRuleRepositoryImpl` & `ScheduleExceptionRepositoryImpl` | Uses fake data sources; omits controller 30d/90d truncation bug. |
| [`timetable_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/timetable_test.dart) | 3+ | Legacy `TimetableRepositoryImpl` CRUD | Legacy module only. |
| [`widgets_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/features/widgets_test.dart) | 5 | `WidgetDataService` generation & model JSON roundtrip | Never tests Kotlin providers, `Beta` deep links, `HomeWidget` channel, or `WidgetConfigNotifier` frequency scheduling. |
| [`widget_test.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/test/widget_test.dart) | 1 | `AttendIQApp()` renders `'AttendIQ'` + `CircularProgressIndicator` on first frame | Pumps 1 frame only (`no pumpAndSettle`); does not verify DB/router error states or post-splash navigation. |

---

## 4. Runtime Warnings Observed in Test Logs (`steps/60/output.txt`)
1. `Failed to get application documents directory, falling back to local: MissingPluginException(No implementation found for method getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)` — emitted repeatedly during `academic_calendar_test.dart` & `academic_planner_test.dart` because tests hit live `isarProvider`.
2. `Helvetica-Bold has no Unicode support see https://github.com/DavBfr/dart_pdf/wiki/Fonts-Management` and `Helvetica has no Unicode support` — emitted by `PdfReportGenerator.generatePdf` in `reports_test.dart`.
3. `Task reminder scheduled time 2026-07-24 23:59:00.000 is in the past. Skipping notification.` — hardcoded 2026 test dates in `academic_planner_test.dart`.

