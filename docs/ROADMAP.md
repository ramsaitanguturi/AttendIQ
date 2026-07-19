# Development Roadmap: AttendIQ

This roadmap outlines the systematic development plan for AttendIQ across five distinct phases. It details features, required files, dependencies, implementation sequence, and testing parameters for each phase.

---

## MVP Scope & Release Boundaries

To ensure focused execution and prevent scope creep, the development roadmap enforces a strict distinction between the Minimum Viable Product (MVP) and subsequent feature releases:

*   **MVP Release Phases (Phases 0-3)**: Consists of base setup, folder structure, offline database persistence, onboarding wizard, logging, timetable generator, backup & restore engine (.attendiq), notifications, and core calculators. This establishes the complete functional product for users.
*   **Post-MVP Release Phases (Phase 4)**: Includes the Gemini AI Advisor integration.

---

## Phase 0: Project Setup & Architecture

### Goal
Initialize the codebase structure, configure dependencies, set up environment flavors, configure compilation tools, and define theme styling.

### Features
- Multi-environment configurations (Development, Staging, Production).
- Local Database initializer (Isar configuration).
- Global theme definitions (HSL tokens mapping).
- Repository templates and base exception classes.

---

## Phase 1: Onboarding Setup & Semester Initialization

### Goal
Build the onboarding setup wizard to register semesters and initial subjects without authentication or accounts.

### Features
- 100% Offline startup without login or user accounts.
- Onboarding Setup Wizard:
  - If a user has no active semester, block dashboard access and redirect to Onboarding.
  - Wizard Step 1: Active Semester metadata (Name, Dates, Target Percentage).
  - Wizard Step 2: Initial Subjects builder.
- Subject CRUD logic (local Isar).

---

## Phase 2: Timetable, Event Generation & Core Logging

### Goal
Build the weekly class timetable scheduler and implement the rolling event generator to pre-create attendance records in the local database.

### Features
- Weekly Timetable Template Builder (slot allocations, times, collision checks).
- Timetable-to-Event Generator (`AttendanceEventGenerator`).
- Dashboard Schedule Widget: Chronological carousel showing today's class items.
- Attendance Quick Logging: Swipe Present/Absent actions.

---

## Phase 3: Backup & Restore Engine, Notifications & Analytics

### Goal
Implement local backup & restore engine (.attendiq), local rolling notifications, and build calculations with progress dashboards.

### Features
- Backup & Restore Engine: Export and import complete Isar collections (.attendiq) with Replace or Merge data options.
- Notification Service Architecture: Rolling 7-day scheduled reminders and 5-minute pre-class reminders.
- Attendance Calculators (Percentage, Safe Bunk, Must-Attend).
- Analytics Charts (Semester Trend Line, comparison bars).

---

## Phase 4: Post-Core AI Advisor Integration

### Goal
Integrate generative AI suggestions and forecasting advisory panels with local rule fallback.

### Features
- Gemini API Connector & Local Rule Engine Fallback.
- Context Packager: Serializes DB state to prompt JSONs.
- Interactive Advisor Panel Chat.
