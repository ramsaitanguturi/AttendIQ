# Recovery & Stabilization Roadmap: AttendIQ

**Audit Date:** 2026-11-10
**Approach:** Dependency-ordered, one-bug-at-a-time stabilization with regression test + `flutter analyze` + `flutter test` verification after each fix.

---

## 1. Dependency-Aware Fixing Order

### Phase 5.1 — Build, Initialization & State Foundation (Blockers First)
1. **BUG-001** (`today_schedule_provider.dart:93,157,164`): Fix `subjectMap` typing (`<int, Subject>{}`) so `flutter analyze` has zero compile errors. *(Prerequisite for clean CI/regression feedback on every subsequent fix.)*
2. **BUG-002** (`isar_provider.dart`, `main.dart`): Make `isarProvider` `@Riverpod(keepAlive: true)`, prevent silent boot on Isar init timeout/error by exposing safe error/retry UI, and remove unsafe `dir = '.'` fallback on mobile.
3. **BUG-003** (`notification_providers.dart`): Make `notificationServiceProvider`, `notificationSchedulerProvider`, and `notificationInitializerProvider` `@Riverpod(keepAlive: true)` so DB observers stay alive across the entire app lifecycle.
4. **BUG-028** (`app_router.dart`, `onboarding_page.dart`): Surface async semester error state instead of redirecting to `/onboarding`, guard all non-onboarding routes pre-setup, gate `debugLogDiagnostics` to `kDebugMode`, and add onboarding submit lock.

### Phase 5.2 — Core Data Model Unification & Database Consistency
5. **BUG-017** *(Completed & Verified)* (`semester_local.dart`, `semester_validator.dart`, `semester_repository_impl.dart`, `semester_repository.dart`, `semester_management_sheet.dart`, `settings_page.dart`, consumer services): Added explicit `draft`/`active`/`archived` lifecycle state, `startDate < endDate` & non-overlap validation, idempotent startup migration (`migrateLegacySemesters`), unified active semester lookup (`resolveActiveSemesterLocal` / `SemesterRepository.getActiveSemester()`) across all services, and Settings semester management UI.
6. **BUG-004 & BUG-005** (`attendance_controller.dart`, `attendance_local_data_source.dart`, `today_schedule_provider.dart`, `weekly_schedule_view_controller.dart`, `subject_details_page.dart`):
   - Eliminate the split-brain `TimetableTemplateLocal`/`EventLocal` vs `WeeklyScheduleRuleLocal`/`DailyScheduleOccurrenceLocal` architecture.
   - Route all attendance marking and extra-class logging through `DailyScheduleOccurrenceLocal` (removing broken `createExtraClassEvent` / `EventLocal` double-ID collision) and resolve multi-slot same-day attendance cleanly by slot/occurrence key rather than date-only `.firstOrNull`.
   - Consolidate startup legacy migration into one idempotent step (`isar_provider.dart`), ensuring `subject.type` is preserved and removing constructor side-effects from `WeeklyScheduleRuleLocalDataSourceImpl`.
7. **BUG-020** (`subject_repository_impl.dart`, `add_edit_subject_dialog.dart`, `task_repository_impl.dart`, `academic_event_repository_impl.dart` + **SUSP-004**):
   - Return created `Subject` ID directly from `createSubject`, enforce intra-dialog and semester-wide timetable slot collision checks, prefill target from user settings, ensure `serverId` UUIDs are generated on all entities, and cascade soft-delete active rules/future occurrences when soft-deleting a subject (preserving `AttendanceRecordLocal`).

### Phase 5.3 — Domain Business Logic & Attendance/Timetable Core
8. **BUG-018** (`attendance_record.dart`, `daily_schedule_occurrence.dart`, `calculator.dart`, `analytics_calculator.dart`, `user_preferences*`): Implement `LATE` attendance status and configurable `lateWeight` ($W_l$, `0.0–1.0`) with `double attended` arithmetic per `docs/DOMAIN_RULES.md` §1.1–1.2.
9. **BUG-010 & BUG-011** (`subject_attendance_stats_provider.dart`, `subject_details_page.dart`): Wire `SubjectDetailsPage` history logs to active occurrences/records, fix `remaining` classes forecasting via active `WeeklyScheduleRule`s minus `ScheduleException` holidays/cancellations and already-marked today classes, and calculate 30-day trend using occurrence date rather than `markedAt`.
10. **BUG-021 & BUG-022** (`semester_weekly_calendar_view.dart`, `weekly_timetable_page.dart`, `academic_calendar_controller.dart`, `timetable_controller.dart`, `weekly_schedule_view_controller.dart`):
    - Fix `ScrollController attached to multiple scroll views` & leaked `_weekPageController` by extracting a proper per-week stateful widget.
    - Fix tapped slot date propagation (`DateTime.now()` bug), fix Timetable FAB (`Add Class`), include `DailyScheduleOccurrence` in calendar & `DayScheduleProvider`, widen exception query range beyond 30d/90d, and normalize `DateTime` provider keys.
11. **BUG-019** (`task_controller.dart`, `add_edit_task_sheet.dart`): Guard `subjects` empty/deleted state in `TaskListController` & `AddEditTaskSheet` dropdown, exclude overdue tasks from `upcomingTasksProvider`, validate `startDate <= dueDate`, and await save before popping sheet.

### Phase 5.4 — Platform Integrations (Notifications, Backup/Security, Analytics, Reports, AI, Widgets)
12. **BUG-009, BUG-013 & BUG-014** (`notification_item.dart`, `notification_database.dart`, `notification_scheduler.dart`, `notification_service.dart`, `AndroidManifest.xml`):
    - Fix `NotificationItem` `autoIncrement()` ID assignment (`id = 0` bug).
    - Migrate `NotificationScheduler` and `notificationInitializerProvider` to active `WeeklyScheduleRuleLocal` + `DailyScheduleOccurrenceLocal` + `ScheduleExceptionLocal`, respect `UserPreferencesLocal` toggles/offsets, schedule risk alerts in future, create `'default'` channel, initialize `tz.local` with device timezone, and add `RECEIVE_BOOT_COMPLETED` + boot receivers.
13. **BUG-008, BUG-006, BUG-007 & BUG-023** (`AndroidManifest.xml`, `file_paths.xml`, `MainActivity.kt`, `backup_*`):
    - Remove `MANAGE_EXTERNAL_STORAGE` and `requestLegacyExternalStorage="true"`, restrict `file_paths.xml`, and align Android save/list/open paths with Scoped Storage (`MediaStore` / SAF / app storage).
    - Validate parsed JSON strictly before clearing collections in `Replace` mode, build FK/ID translation maps + deduplication in `Merge` mode, export/import `WeeklyScheduleRule.type` & auto-backup settings, invalidate Riverpod providers after restore, and validate canonical import paths.
14. **BUG-024** (`backup_scheduler.dart`, `main.dart`): Wire `Workmanager().initialize(callbackDispatcher)` and `@pragma('vm:entry-point')` dispatcher cleanly.
15. **BUG-012 & BUG-025** (`analytics_service.dart`, `analytics_page.dart`, `dashboard_page.dart`): Rewrite `AnalyticsService` to use unified occurrences & soft-deleted subject logs per `DOMAIN_RULES.md` §3, fix `LineChart` 1-point crash (`points.length < 2`), wire `onSlotTap` on Dashboard weekly strip, and fix `"null consecutive classes"` UI strings.
16. **BUG-026** (`report_service.dart`, `reports_page.dart`, `pdf_report_generator.dart`): Unify active semester & deleted subject history, pass dynamic thresholds/profile name, and bundle Unicode-capable PDF font.
17. **BUG-015 & BUG-016** (`ai_context_builder.dart`, `ai_chat_controller.dart`, `gemini_ai_provider.dart`, `advisor_prompts.dart`): Build AI context from active rules/occurrences, catch online Gemini failures into `LocalAdvisorService` fallback, upgrade retired `gemini-1.5-flash` endpoint, move API key to `x-goog-api-key` header with timeouts, and sanitize prompt interpolation.
18. **BUG-027** (`TodayWidgetProvider.kt`, `WeeklyWidgetProvider.kt`, `MonthWidgetProvider.kt`, `today_widget_info.xml`, `widget_data_service.dart`, `widget_config.dart`): Fix flavor-aware widget deep links, fix 2x2 Today layout & refresh action, include Sat/Sun in Weekly widget (or summary), filter/sort Month upcoming items cleanly, and wire periodic/midnight WorkManager widget updates.

### Phase 5.5 — UI Polish, Quality Gates, Documentation & Release Prep
19. **BUG-029** (`export_success_dialog.dart`, `add_extra_class_dialog.dart`, `date_details_bottom_sheet.dart`, `class_schedule_card.dart`, `text_styles.dart`, `pubspec.yaml` + **SUSP-005**): Fix dialog overflow/async context/time validation, fix `CANCELLED` badge color, bundle `'Outfit'`/`'Inter'` fonts or update `AppTextStyles`, remove unused `permission_handler`.
20. **BUG-030 & BUG-031** (Lint/Format/Codegen/Dead Code/Tests): Remove 350+ lines dead template UI, reconcile app version (`pubspec.yaml`, `AppConstants`, `AboutPage`), clean remaining 28 warnings & `await_only_futures`, regenerate `.g.dart` via `build_runner`, run `dart format .`, strengthen regression tests without masking mocks, and remove/reconcile conflicting legacy docs (**SUSP-006**).
21. **SUSP-001 & SUSP-002** (Live Android & Release Hardening): Configure release `lintOptions`, R8/ProGuard keep rules, enforce release signing failure if keystore missing, build `prod` & `beta` APKs/AABs, and test end-to-end on Android emulator/device.

---

## 2. Recommended Next Target

*(Completed to date: `BUG-001`, `BUG-002`, `BUG-003`, `BUG-009`, `BUG-017`.)*

**Next Recommended Target:** **`BUG-004` & `BUG-005`** (Timetable/Event architecture unification & Extra Class logging fix — now unblocked after `BUG-001`, `BUG-002`, and `BUG-017`).

