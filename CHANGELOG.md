# Changelog

All notable changes to the **AttendIQ** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] - 2026-07-19

### Added
- **Academic Task & Planner Feature**: Full support for tracking assignments, projects, mid-semester, and end-semester exams with priority tags and due date countdowns.
- **Monthly Academic Calendar View**: Interactive monthly calendar with single-date exception indicators (exams, holidays, extra classes, deadlines).
- **Flexible Multi-Slot Weekly Timetable**: Support for scheduling multiple time slots for the same subject across different days of the week.
- **Daily Attendance Execution System**: Dynamic generation of `DailyScheduleOccurrence` items with interactive Present, Absent, and Cancelled status actions on the Dashboard.
- **Attendance Reports Generator**: Export subject-wise attendance logs and summary sheets into PDF and CSV files.
- **Local Notification Engine**: Rolling 7-day scheduled notifications for upcoming classes, exam reminders, and task deadlines.

### Changed
- Refactored state management across all feature modules to use compile-safe Riverpod generators and notifiers.
- Updated Isar database integration to dev.14 for enhanced asynchronous querying performance.
- Upgraded UI design system to full Material 3 Dark/Light HSL color palette support.

### Fixed
- Resolved `TodayScheduleProvider` infinite loading state during initial database bootstrap.
- Fixed subject registration validation blocking timetable entry creation.
- Corrected safe bunk calculation logic when handling edge cases with zero conducted classes.

---

## [1.0.0] - 2026-07-10

### Added
- **Initial Release of AttendIQ**: Smart offline-first attendance manager for college students.
- **Onboarding Setup Wizard**: First-time active semester configuration and minimum attendance target setup.
- **Isar Local Storage Engine**: 100% offline data persistence without accounts, Firebase, or external API requirements.
- **Safe Bunk & Must-Attend Calculators**: Real-time mathematical indicators displaying safe miss counts and catch-up requirements.
- **Backup & Restore (.attendiq)**: Complete JSON container data import/export engine with replace or merge modes.
