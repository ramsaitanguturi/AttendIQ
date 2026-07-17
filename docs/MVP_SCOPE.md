# MVP Scope: AttendIQ

This document defines the scope of the Minimum Viable Product (MVP) for AttendIQ. Its purpose is to prevent feature creep, enforce boundaries, and establish clear release criteria for the first usable deployment.

---

## 1. MVP Goal

The primary goal of the AttendIQ MVP is to provide college students with a reliable, offline-first mobile tool to manage their semester schedule, log class attendance, and view real-time safe bunk / must-attend calculations to prevent academic penalties.

---

## 2. Included Features

The following features represent the core functions of the MVP. They must be fully implemented, tested, and verified before release.

### 2.1 Authentication & Session Cache
- Email and password sign-up and login.
- OAuth integration (Google Sign-In).
- Logout capability.
- Local caching of auth sessions in Isar, bypassing remote checks on startup to enable instant offline access.

### 2.2 Semester Management
- Creation of an active semester (Semester name, Start Date, End Date, default Target Attendance Rate).
- Editing active semester details.
- Basic date bounds checking (end date > start date, no overlapping semesters).

### 2.3 Subject Management
- Subject registration (Name, Course Code, Credits, UI theme color).
- Subject-specific target attendance rate overrides.
- Soft-delete subject operations preserving historical database records.

### 2.4 Timetable Grid
- Weekly template editor (defining slots for Monday through Sunday).
- Basic collision alerts displaying warnings if new slots overlap existing schedule slots.

### 2.5 Attendance Event Generator
- Background generator pre-creating `AttendanceRecord` items with `unlogged` status in a rolling 14-day window (`[Today - 7 days, Today + 7 days]`).
- Automatic generation triggers on onboarding complete, timetable edits, and daily app boot.

### 2.6 Attendance Logger
- Status tracking: Present, Absent, Late, Cancelled, Extra Class, Extra Class Absent.
- Dashboard logging: Quick-log swipe gestures (Swipe Right = Present, Swipe Left = Absent) on the Today carousel.
- Calendar logging: Direct log edits by tapping calendar days inside the subject details screen.
- Remarks: Ability to add optional text notes to logs.

### 2.7 Core Heuristic Calculations
- Dynamic calculations for current attendance percentage ($P$), Safe Bunks ($B_{safe}$), and Must-Attend counts ($A_{req}$).
- Baseline forecasting: Projecting the student's recent 30-day attendance habits onto the remaining semester classes to estimate their final percentage.

### 2.8 Synchronization Engine
- Offline outbox queue caching writes locally when disconnected.
- Automated push/pull synchronization on restored connection using Last-Write-Wins (LWW) resolution and tombstones.
- Background sync integration running periodically via WorkManager.

---

## 3. Excluded Features (Post-MVP Phases)

To maintain focus on the core value proposition, the following features are explicitly excluded from the MVP. They are scheduled for subsequent developmental phases:

*   **AI Attendance Advisor**: The generative advisory cards, goal-based bunk planning chat, and LLM integrations are excluded (moved to Phase 4).
*   **OCR Timetable Scanning**: Users cannot upload screenshots of timetables to auto-populate schedules; all slots must be input manually.
*   **GPA / Grade Tracker**: Grading systems, credit weightings for GPA calculations, and GPA goals are excluded.
*   **Wear OS & watchOS Integrations**: Android/Apple wearable companions for quick logging from smartwatches are excluded.
*   **Timetable Sharing**: Peer-to-peer schedule transfer, database exports, and timetable sharing via QR codes are excluded.
*   **Advanced Analytics**: Cross-semester analytics, predictive absence patterns, and detailed statistical reports are excluded.
*   **Export Reports**: PDF/CSV exports of attendance records for administration submission are excluded.

---

## 4. MVP Completion Criteria

The MVP is considered complete and ready for production staging when it satisfies the following requirements:

1.  **Test Coverage**:
    - $100\%$ unit test coverage on the core mathematics calculator (`attendance_math.dart`).
    - Core repositories, models, and sync handlers achieve at least $80\%$ unit test coverage.
2.  **Quality Control**:
    - The repository executes `flutter analyze` with zero lint errors or warnings.
    - All code formats conform to `dart format . --set-exit-if-changed`.
3.  **Sync Verification**:
    - Manual and integration tests verify that offline operations commit successfully when offline and resolve without duplicates upon online reconnect.
4.  **Distribution Quality**:
    - Clean release-ready staging builds (APK for Android, IPA for iOS) are compiled and signed without warnings or compilation failures.
