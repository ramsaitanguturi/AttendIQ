# Project Tasks Checklist: AttendIQ

This document provides a detailed list of tasks required to build the AttendIQ mobile application. Tasks are ordered logically by phase and dependency, with the AI Advisor scheduled strictly as a post-core integration.

---

## Phase 0: Project Setup

### TASK 0.1: Multi-Environment Boilerplate Configuration
- **Priority**: High
- **Description**: Configure Dart entrypoints for Dev, Staging, and Prod. Configure target flavors on Android (`build.gradle`) and iOS (Xcode Configurations). Define strict linter guidelines.
- **Dependencies**: None
- **Completion Criteria**:
  - `main_development.dart`, `main_staging.dart`, and `main.dart` run successfully.
  - Command `flutter analyze` runs without failures.

### TASK 0.2: Local Database (Isar) Initializer
- **Priority**: High
- **Description**: Write Isar connection classes and schema registration. Provide connection providers in Riverpod.
- **Dependencies**: TASK 0.1
- **Completion Criteria**:
  - Code generation runs successfully with `dart run build_runner build`.
  - Local database opens and logs an active instance during development start.

### TASK 0.3: Clean Architecture Folder Structure Setup
- **Priority**: High
- **Description**: Create the directory tree under `lib/` matching [FOLDER_STRUCTURE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/FOLDER_STRUCTURE.md) including features (`auth`, `subject`, `attendance`, `timetable`, `analytics`, `ai_advisor`), core subdirectories, and app routing layouts.
- **Dependencies**: TASK 0.1
- **Completion Criteria**:
  - All directories exist, and dummy barrel files or template layout classes are set up successfully.

### TASK 0.4: CI/CD Pipeline Automation (GitHub Actions)
- **Priority**: High
- **Description**: Configure the Git repository branch protection rules for `main` and `development`, and create the `.github/workflows/ci.yml` workflow file as specified in [CI_CD.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/CI_CD.md).
- **Dependencies**: TASK 0.1
- **Completion Criteria**:
  - Pushing commits triggers formatting, static analysis checks, testing, and staging build tasks on GitHub Actions successfully.

---

## Phase 1: Authentication & Onboarding Setup

### TASK 1.1: Firebase Authentication & Session Cache
- **Priority**: High
- **Description**: Integrate Email/Password login and Google Sign-in. Store the user session locally so that the app starts instantly without internet hits.
- **Dependencies**: TASK 0.2
- **Completion Criteria**:
  - User can sign up, log in, and log out.
  - App state detects local user token on start when offline and displays the dashboard/onboarding.

### TASK 1.2: Semester Onboarding Setup Wizard
- **Priority**: High
- **Description**: Create onboarding screens prompting users to set semester names, start/end dates, and target rate. Check on app boot if an active semester exists; if not, block dashboard and force Onboarding.
- **Dependencies**: TASK 1.1
- **Completion Criteria**:
  - Displays onboarding ONLY if user has no active semester in Isar.
  - Submitting wizard creates an active `Semester` entry in local database.

### TASK 1.3: Subject Management CRUD
- **Priority**: High
- **Description**: Implement UI and repository for adding, listing, editing, and deleting subjects in Isar.
- **Dependencies**: TASK 1.2
- **Completion Criteria**:
  - User can create subjects (name, code, credits, colorHex).
  - List of subjects is rendered reactively from local Isar streams.

---

## Phase 2: Timetable, Event Generation & Logging

### TASK 2.1: Timetable Scheduler & Collision Detector
- **Priority**: High
- **Description**: Build the schedule template builder. Users can specify Monday-Sunday class slots with room names and start/end times. Alert user if new slot overlaps existing slot.
- **Dependencies**: TASK 1.3
- **Completion Criteria**:
  - Timetable inputs are saved to Isar `ScheduleDay` and `TimeSlot` collections.
  - Collision detector alerts user if new slot overlaps existing slot.

### TASK 2.2: Timetable-to-Event Generator
- **Priority**: High
- **Description**: Implement `AttendanceEventGenerator` to pre-generate daily `AttendanceRecord` items (status = `unlogged`) in a rolling 14-day window.
- **Dependencies**: TASK 2.1
- **Completion Criteria**:
  - The generator automatically runs on semester onboarding complete, timetable edits, and daily app launches.
  - Generates correct unlogged records for dates in range `[Today - 7, Today + 7]`.

### TASK 2.3: Attendance Toggler (Quick Log Dashboard)
- **Priority**: High
- **Description**: Build today's class carousel on the dashboard. Allow students to quick log attendance (Present / Absent) using swiping gestures (Right = Present, Left = Absent).
- **Dependencies**: TASK 2.2
- **Completion Criteria**:
  - Dashboard loads today's events from Isar in chronological order.
  - Swiping updates record status and triggers haptics.

---

## Phase 3: Sync Engine, Notifications & Analytics

### TASK 3.1: Outbox Sync Queue & Sync Manager Engine
- **Priority**: High
- **Description**: Implement the offline-first synchronization process following the architecture defined in [SYNC_ENGINE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/SYNC_ENGINE.md). Build the `SyncQueueEntry` Outbox system, write FIFO queue processing with exponential backoff and poison-pill isolation, LWW conflict resolution, and soft-delete tombstone synchronization.
- **Dependencies**: TASK 2.3
- **Completion Criteria**:
  - Intercepting local writes adds them to the outbox and marks Isar models as dirty.
  - The sync cycle correctly processes the outbox queue, pushes edits to Firestore, resolves conflicts using client/server timestamp checks, and purges deleted records.

### TASK 3.2: Background Sync Runner (Workmanager)
- **Priority**: Medium
- **Description**: Bind the sync manager calls into native periodic tasks using `workmanager`.
- **Dependencies**: TASK 3.1
- **Completion Criteria**:
  - App syncs local changes even when minimized or closed, periodically running every 15 minutes.

### TASK 3.3: Rolling Notification Service
- **Priority**: Medium
- **Description**: Implement a rolling 7-day scheduled notifications queue to circumvent Android/iOS local scheduled alerts ceilings. Set alerts for 5 minutes before scheduled classes.
- **Dependencies**: TASK 2.1
- **Completion Criteria**:
  - Rescheduling occurs on app launch, timetable changes, or sync completions.
  - Notifications display before class slot start times.

### TASK 3.4: Mathematical Calculators Utility
- **Priority**: High
- **Description**: Code the formulas for Attendance Percentage, Safe Bunks ($B_{safe}$), Must-Attend ($A_{req}$), and Forecasting predictions inside a pure utility class. Add test coverage.
- **Dependencies**: TASK 2.3
- **Completion Criteria**:
  - Unit tests have 100% code coverage.
  - Correct values are calculated for boundary conditions ($0\%$ and $100\%$ target rates).

### TASK 3.5: Analytics Dashboard (FL Chart)
- **Priority**: Medium
- **Description**: Render Circular Progress indicators for current rates, Line Chart representing semester trends, and forecast badge indicators.
- **Dependencies**: TASK 3.4
- **Completion Criteria**:
  - Charts draw accurately.
  - Dashboard details display predicted final stats.

### TASK 3.6: Domain Rules & Heuristics Verification
- **Priority**: High
- **Description**: Implement and run comprehensive unit tests confirming that all attendance logging calculations, semester date boundary rules, and calculations for $P$, $B_{safe}$, and $A_{req}$ comply strictly with the formulas and edge cases specified in [DOMAIN_RULES.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/DOMAIN_RULES.md).
- **Dependencies**: TASK 3.4
- **Completion Criteria**:
  - 100% unit test coverage for `attendance_math.dart`.
  - Edge cases (such as $0\%$ current attendance, $100\%$ target rates, and division-by-zero limits) pass verification without failures.

---

## Phase 4: Post-Core AI Advisor Integration

### TASK 4.1: Gemini API Connector & Context DTO
- **Priority**: Low
- **Description**: Create data transfer objects formatting student schedule, attendance logs, and constraints to prompt template. Send query to Gemini API using Google Generative AI SDK.
- **Dependencies**: TASK 3.4, TASK 3.5
- **Completion Criteria**:
  - App parses database to JSON format.
  - Safe API communication is established.

### TASK 4.2: Local Advisor Heuristics Rule Engine
- **Priority**: Medium
- **Description**: Implement rule-based heuristics that analyze the local database to generate warning summaries when offline or when Gemini rate limit is hit.
- **Dependencies**: TASK 3.4
- **Completion Criteria**:
  - Offline dashboard displays local fallback recommendations instantly.
