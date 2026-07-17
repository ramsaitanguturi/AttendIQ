# Development Roadmap: AttendIQ

This roadmap outlines the systematic development plan for AttendIQ across five distinct phases. It details features, required files, dependencies, implementation sequence, and testing parameters for each phase.

---

## MVP Scope & Release Boundaries

To ensure focused execution and prevent scope creep, the development roadmap enforces a strict distinction between the Minimum Viable Product (MVP) and subsequent feature releases:

*   **MVP Release Phases (Phases 0-3)**: Consists of the base setup, folder structure establishment, authentication, logging, rolling schedule generator, offline outbox synchronization, notifications, and core calculators. This establishes the complete functional product for users.
*   **Post-MVP Release Phases (Phase 4)**: Includes the Gemini AI Advisor integration. Development on Phase 4 will *only* commence after all MVP phase completion criteria have been fully verified and approved.

For details on boundaries and criteria, refer to [MVP_SCOPE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/MVP_SCOPE.md).

---

## Phase 0: Project Setup & Architecture

### Goal
Initialize the codebase structure, configure dependencies, set up environment flavors, configure compilation tools, and define theme styling.

### Features
- Multi-environment configurations (Development, Staging, Production).
- Database initializer (Isar configuration).
- Global theme definitions (HSL tokens mapping).
- Repository templates and base exception classes.

### Required Files
- [x] [FOLDER_STRUCTURE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/FOLDER_STRUCTURE.md)
- [x] [CI_CD.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/CI_CD.md)
- `lib/main_development.dart` & `lib/main_staging.dart` & `lib/main.dart`
- `pubspec.yaml` (dependencies config)
- `analysis_options.yaml` (strict linter rules)
- `lib/core/theme/app_theme.dart` (color palette mappings)
- `lib/core/database/isar_provider.dart` (Isar connection pool notifier)
- `lib/core/errors/failures.dart` (generic application exceptions)

### Dependencies
- `flutter_riverpod`, `isar`, `isar_flutter_libs`, `firebase_core`, `build_runner`, `isar_generator`, `riverpod_generator`.

### Development Order
1. **Folder Structure Setup**: Initialize the base project directories (app, core, features, shared) as defined in [FOLDER_STRUCTURE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/FOLDER_STRUCTURE.md).
2. **CI/CD Pipeline Setup**: Configure Git branch protections and the GitHub Actions workflow script according to [CI_CD.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/CI_CD.md).
3. **Linter & Flavor Config**: Add `analysis_options.yaml` and entrypoints (`main_*.dart`).
4. **Pubspec Dependencies**: Add packages and trigger `flutter pub get`.
5. **Core Theme System**: Create HSL color tokens and `AppTheme` class.
6. **Isar DB Initializer**: Write `isar_provider.dart` to instantiate Isar schema configurations asynchronously.
7. **Code Generation Check**: Validate compile safety by running `dart run build_runner build`.

### Testing Requirements
- Run `flutter analyze` to ensure 0 lint errors.
- Confirm successful compilation of all dev, stg, and prod flavors on local simulators.

---

## Phase 1: Authentication & Onboarding Setup (Core MVP Base)

### Goal
Establish the security architecture, handle authentication, persist sessions, and build the onboarding setup wizard to register semesters and initial subjects.

### Features
- Firebase Authentication (Email/Password + Google Sign-In).
- User Profile Creation & Session Caching (allowing instant offline startup).
- Onboarding Setup Wizard:
  - If a user has no active semester, block dashboard access and redirect to Onboarding.
  - Wizard Step 1: Active Semester metadata (Name, Dates, Target Percentage).
  - Wizard Step 2: Initial Subjects builder (at least 3 subjects).
- Subject CRUD logic (local Isar).

### Required Files
- `lib/features/auth/domain/entities/user_profile.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/onboarding_wizard_page.dart`
- `lib/features/subject/data/models/subject_isar_model.dart`
- `lib/features/subject/domain/repositories/subject_repository.dart`
- `lib/features/subject/presentation/controllers/subject_list_controller.dart`

### Dependencies
- Firebase Auth SDK, `google_sign_in`, `uuid`, `shared_preferences`.

### Development Order
1. **Firebase Auth Integration**: Implement auth data sources and persistent caching.
2. **Onboarding Guard**: Create middleware checking for active semesters in Isar on app boot.
3. **Onboarding Wizard UI**: Implement form flows (semester meta -> subject list generation).
4. **Subject CRUD Repositories**: Implement local subject creation, reading, and updates.

### Testing Requirements
- **Unit Tests**: Mock auth responses, verify Date bounds checks.
- **Widget Tests**: Onboarding flow validation, form validation assertions.

---

## Phase 2: Timetable, Event Generation & Core Logging

### Goal
Build the weekly class timetable scheduler and implement the rolling event generator to pre-create attendance records in the local database.

### Features
- Weekly Timetable Template Builder (slot allocations, times, collision checks).
- Timetable-to-Event Generator (`AttendanceEventGenerator`):
  - Pre-generates daily `AttendanceRecord` items (status = `unlogged`) in a rolling 14-day window.
- Dashboard Schedule Widget: Chronological carousel showing today's class items.
- Attendance Quick Logging: Swipe Present/Absent actions.

### Required Files
- `lib/features/timetable/data/models/schedule_day_model.dart`
- `lib/features/timetable/data/models/time_slot_model.dart`
- `lib/features/timetable/presentation/pages/timetable_editor_page.dart`
- `lib/features/attendance/data/models/attendance_record_model.dart`
- `lib/features/attendance/domain/services/attendance_event_generator.dart`
- `lib/features/attendance/presentation/widgets/today_schedule_carousel.dart`

### Dependencies
- Phase 1 core libraries, local haptic feedbacks API.

### Development Order
1. **Timetable Schemas**: Write Isar models for schedule days and timeslots.
2. **Timetable Editor Grid UI**: Implement visual scheduler with collision detection alert blocks.
3. **Attendance Record Schema**: Add Isar definitions.
4. **Attendance Event Generator Service**: Implement rolling 14-day generator logic running on startup or timetable updates.
5. **Dashboard UI and Swipe Logs**: Build today's checklist widget with swipe triggers.

### Testing Requirements
- **Unit Tests**: Test the scheduler collision detector, verify that `AttendanceEventGenerator` generates correct number of events in range.
- **Widget Tests**: Carousel gesture swipes triggers verification.

---

## Phase 3: Sync Engine, Notification Service & Analytics

### Goal
Implement background synchronization, establish local rolling notifications, and build calculations with progress dashboards.

### Features
- Outbox Sync Queue & Sync Manager: bidirectional push/pull with LWW conflict rules.
- Background Worker: periodic database sync loops (Workmanager).
- Notification Service Architecture: rolling 7-day scheduled reminders (circumventing OS limit ceilings) and 5-minute pre-class reminders.
- Attendance Calculators (Percentage, Safe Bunk, Must-Attend).
- Analytics Charts (Semester Trend Line, comparison bars).

### Required Files
- [x] [DOMAIN_RULES.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/DOMAIN_RULES.md)
- [x] [SYNC_ENGINE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/SYNC_ENGINE.md)
- [x] [ATTENDANCE_ENGINE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/ATTENDANCE_ENGINE.md)
- [x] [FIREBASE_SECURITY.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/FIREBASE_SECURITY.md)
- [x] [NOTIFICATION_SERVICE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/NOTIFICATION_SERVICE.md)
- `lib/core/sync/sync_manager.dart`
- `lib/core/sync/sync_worker.dart` (Workmanager binding)
- `lib/core/notifications/notification_service.dart`
- `lib/core/utils/attendance_math.dart`
- `lib/features/analytics/presentation/pages/analytics_dashboard_page.dart`

### Dependencies
- `connectivity_plus`, `cloud_firestore`, `workmanager`, `flutter_local_notifications`, `firebase_messaging`, `fl_chart`.

### Development Order
1. **Domain Logic & Math Heuristics**: Package `attendance_math.dart` ensuring calculations conform strictly to [DOMAIN_RULES.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/DOMAIN_RULES.md) and build unit tests.
2. **Notification Service**: Implement rolling 7-day queue manager.
3. **Sync Engine Outbox Pattern**: Implement outbox sync queue logic and synchronization execution flow conforming strictly to [SYNC_ENGINE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/SYNC_ENGINE.md).
4. **Background Sync Runner**: Configure Workmanager background schedule.
5. **Analytics Charts UI**: Integrate FL Charts.

### Testing Requirements
- **Unit Tests**: 100% test coverage on `attendance_math.dart`. Test LWW merging logic.
- **Integration Tests**: Mock offline network states, perform edits, toggle network online, verify Firestore update matches rules.

---

## Phase 4: Post-Core AI Advisor Integration

### Goal
Integrate generative AI suggestions and forecasting advisory panels. This runs strictly after all core features (onboarding, logging, timetable, sync, notifications, and analytics) are implemented and verified.

### Features
- Gemini API Connector (Google AI SDK with proxy endpoints).
- Context Packager: Serializes DB state to prompt JSONs.
- Interactive Advisor Panel Chat.
- Local Offline Heuristic Rule Fallback.

### Required Files
- `lib/features/ai_advisor/data/models/advisor_context_dto.dart`
- `lib/features/ai_advisor/domain/usecases/generate_advisor_insights.dart`
- `lib/features/ai_advisor/presentation/pages/ai_advisor_page.dart`

### Dependencies
- `google_generative_ai`.

### Development Order
1. **API Client**: Establish communication flow with Gemini 1.5 Flash.
2. **Context DTO Converter**: Serialize timetable and logs to context.
3. **Offline Fallback Engine**: Implement rule heuristics in Dart to generate recommendations without network access.
4. **Chat UI Panel**: Build card deck list and chat bubble screens.

### Testing Requirements
- **Unit Tests**: Mock LLM responses, verify offline local heuristics execute correctly.
