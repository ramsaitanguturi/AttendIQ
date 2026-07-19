# Project Tasks Checklist: AttendIQ

This document provides a detailed list of tasks for the AttendIQ mobile application under the 100% offline-first architecture.

---

## Phase 0: Project Setup & Local Infrastructure

### TASK 0.1: Architecture & Local Infrastructure Setup
- **Status**: [x] Completed
- **Description**: Configure entrypoints, linter rules, HSL theme palette, and Clean Architecture layout.

### TASK 0.2: Local Database (Isar) Initializer
- **Status**: [x] Completed
- **Description**: Schema definitions for `SemesterLocal`, `SubjectLocal`, `TimetableTemplateLocal`, `EventLocal`, `AttendanceRecordLocal`, `UserPreferencesLocal`, `NotificationItem`.

---

## Phase 1: Onboarding Setup & Semester Initialization

### TASK 1.1: Semester Onboarding Setup Wizard
- **Status**: [x] Completed
- **Description**: 100% offline startup. Prompts users for semester metadata (Name, Dates, Target Attendance Rate) if no active semester exists in Isar.

### TASK 1.2: Subject Management CRUD
- **Status**: [x] Completed
- **Description**: Implement UI and repository for adding, listing, editing, and deleting subjects in Isar.

---

## Phase 2: Timetable, Event Generation & Logging

### TASK 2.1: Timetable Scheduler & Collision Detector
- **Status**: [x] Completed
- **Description**: Build weekly schedule builder with real-time slot collision detection.

### TASK 2.2: Timetable-to-Event Generator
- **Status**: [x] Completed
- **Description**: Automate creation of physical class event logs in Isar.

### TASK 2.3: Attendance Quick Logging
- **Status**: [x] Completed
- **Description**: Today's class carousel with swipe gestures (Right = Present, Left = Absent).

---

## Phase 3: Backup & Restore Engine, Notifications & Analytics

### TASK 3.1: Backup & Restore System (.attendiq)
- **Status**: [x] Completed
- **Description**: Built `BackupExporter`, `BackupImporter`, and `BackupService` allowing full data exports and imports with Replace vs. Merge data modes.

### TASK 3.2: Rolling Notification Service
- **Status**: [x] Completed
- **Description**: Rolling 7-day scheduled reminders queue for class alerts and low attendance warnings.

### TASK 3.3: Mathematical Calculators Utility & Analytics
- **Status**: [x] Completed
- **Description**: Mathematical formulas for Attendance Rate, Safe Bunks ($B_{safe}$), Must-Attend ($A_{req}$), and semester trends.

---

## Phase 4: Post-Core AI Advisor Integration

### TASK 4.1: Gemini AI Advisor & Local Rule Engine Fallback
- **Status**: [x] Completed
- **Description**: AI advisory panel with offline fallback heuristics.
