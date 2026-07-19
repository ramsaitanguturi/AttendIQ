# AttendIQ - Smart Academic Management System

> A privacy-focused offline-first student productivity application for managing attendance, timetable, academic calendar, tasks, and semester planning.

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Isar Database](https://img.shields.io/badge/Isar-4.0--dev-00A98F?style=for-the-badge&logo=database&logoColor=white)](https://isar.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-lightgrey?style=for-the-badge)]()

---

## Overview

### What is AttendIQ?
**AttendIQ** is a comprehensive, offline-first academic management application built using Flutter and Material 3 design. It equips college and university students with real-time attendance analytics, intelligent timetable scheduling, monthly calendar tracking, deadline prioritization, and manual backup control.

### The Problem It Solves
Academic institutions typically mandate strict attendance thresholds (e.g., 75% or 80%) for exam eligibility. Students struggle with manual spreadsheet calculations, unexpected timetable shifts, missing assignment deadlines, and tracking allowable absences ("safe bunks"). A simple mistake can lead to academic debarment.

AttendIQ automates schedule generation, calculates exact safety margins, alerts students to upcoming classes/deadlines, and provides end-of-semester eligibility predictions without relying on central university servers or third-party cloud services.

### Target Users
- **College & University Students**: Managing multi-subject weekly schedules and attendance targets.
- **Academic Planners**: Students managing assignments, lab submissions, mid-semester, and end-semester exams.
- **Privacy-Conscious Individuals**: Users who want complete control over their personal data without sign-ups or cloud sync.

### Why Offline-First Architecture?
1. **100% Data Privacy**: No user data leaves the device. Zero tracking, zero telemetry, zero server storage.
2. **Airplane Mode Reliability**: Fully operational inside basements, auditoriums, or areas with poor cellular connectivity.
3. **Instant Responsiveness**: Zero network latencies with local database reads and writes via Isar DB.
4. **No Account Overhead**: Instant onboarding without registration, email verification, or passwords.

---

## Features

### Attendance Management
- **Subject-Wise Attendance Tracking**: Track total conducted, attended, missed, and cancelled sessions for every subject.
- **Present / Absent / Cancelled Tracking**: Direct status logging with real-time UI status updates.
- **Attendance Percentage Calculation**: Instant calculation of current attendance rates versus minimum target percentage (e.g., 75%).
- **Safe Bunk & Must-Attend Calculation**:
  - *Safe Bunks*: Mathematical count of consecutive classes you can safely skip while remaining above target.
  - *Must-Attend*: Precise number of consecutive classes required to recover from an attendance dip.
- **Attendance Reports**: Generate structured PDF and CSV summaries for academic reviews.

### Smart Timetable
- **Weekly Timetable**: Interactive weekly schedule view with collision prevention and room allocations.
- **Semester-Based Navigation**: Seamlessly manage active semesters and start/end dates.
- **Flexible Subject Scheduling**: Custom colors, credit hours, course codes, and faculty details.
- **Multiple Timings for Same Subject**: Configure recurring weekly rules with multiple distinct slots on different days.
  ```text
  Example: Operating Systems (OS)
  ├── Monday:   09:00 AM - 10:00 AM (Lecture - Hall A)
  ├── Tuesday:  12:00 PM - 01:00 PM (Lecture - Hall B)
  └── Friday:   10:00 AM - 11:00 AM (Lab - Room 302)
  ```

### Daily Schedule
- **Today's Classes**: Chronological carousel displaying scheduled slots for the current day.
- **Mark Attendance Directly**: Quick interactive check-ins (`Present`, `Absent`, `Cancelled`) directly from the home screen card.
- **Extra Classes Support**: Add single-occurrence extra sessions without modifying recurring weekly templates.
- **Cancelled Classes Handling**: Cancel specific sessions without affecting future weekly rules.

### Academic Calendar
- **Monthly Calendar View**: Comprehensive overview of academic commitments across the semester.
- **Semester Date Navigation**: Filter calendar items by date boundaries and months.
- **Exams**: Visually highlighted exam dates with subject associations.
- **Holidays**: Mark single-day or multi-day institutional holidays that auto-suppress class alerts.
- **Events**: Track guest lectures, seminars, and campus events.
- **Extra Classes & Task Deadlines**: Unified calendar rendering of all deadlines and extra sessions.

### Academic Planner
- **Assignments & Projects**: Organize coursework by priority, category, and due dates.
- **Mid-Semester & End-Semester Exams**: Dedicated tracking for major academic milestones.
- **Deadlines & Reminders**: Countdown indicators for urgent tasks.
- **Priority Tracking**: High, Medium, and Low priority tagging for efficient task scheduling.

### Backup System
- **Offline Data Storage**: Powered by ultra-fast Isar local storage engine.
- **Import / Export Backup**: Package entire database schemas into portable `.attendiq` backup files.
- **No Account Required**: Full data portability without cloud logins or server locks.
- **User Owns Their Data**: Complete control to back up, restore, or wipe data at any time.

### Notifications
- **Class Reminders**: Pre-class alerts (e.g., 5 or 15 minutes before class starts).
- **Deadline Reminders**: Alerts for upcoming assignments, projects, and exam schedules.
- **Exam Reminders**: Timely notifications for scheduled mid-semester and final exams.

---

## Architecture

AttendIQ follows **Clean Architecture** principles decoupled into feature modules:

```text
               ┌─────────────────────────────────────────┐
               │           Presentation Layer            │
               │  (Flutter UI Widgets & Riverpod State)  │
               └────────────────────┬────────────────────┘
                                    │
                                    ▼
               ┌─────────────────────────────────────────┐
               │              Domain Layer               │
               │   (Entities, Use Cases & Interfaces)    │
               └────────────────────┬────────────────────┘
                                    │
                                    ▼
               ┌─────────────────────────────────────────┐
               │               Data Layer                │
               │  (Isar DB, Models & Repositories Impl)  │
               └─────────────────────────────────────────┘
```

### Layer Responsibilities
- **Presentation**: UI screens, Material 3 themes, interactive widgets, and Riverpod Notifiers/Providers.
- **Domain**: Pure Dart business logic, mathematical engines (safe bunk / must-attend algorithms), entities, and abstract repository contracts.
- **Data**: Isar database schemas, local datasources, backup engine adapters, and repository implementations.

---

## Tech Stack

| Technology | Purpose |
| :--- | :--- |
| **Flutter** | Cross-platform UI framework for mobile & desktop |
| **Dart** | High-performance type-safe programming language |
| **Riverpod** | Reactive, compile-safe state management framework |
| **Isar** | Extremely fast, asynchronous local NoSQL database |
| **Build Runner** | Code generation engine for Isar schemas & Riverpod generators |
| **Material 3** | Modern design system with dynamic HSL color tokens |

---

## Project Structure

```text
lib/
 ├── core/                  # Shared utilities, database, notifications & base widgets
 │    ├── attendance_engine/# Attendance percentage & safe bunk calculators
 │    ├── backup/           # Import/export backup manager (.attendiq)
 │    ├── database/         # Isar instance setup & schemas
 │    ├── notifications/    # Local notification queue manager
 │    └── theme/            # Material 3 dark/light HSL color tokens
 └── features/              # Feature-First Clean Architecture modules
      ├── academic_planner/ # Tasks, assignments, projects & calendar events
      ├── attendance/       # Daily check-ins, event generation & status updates
      ├── analytics/        # Attendance progress, reports & trends (PDF/CSV)
      ├── onboarding/       # Initial semester configuration wizard
      ├── semester/         # Active semester metadata & subject management
      ├── settings/         # App settings, backups, theme selection
      └── timetable/        # Weekly slot rules & schedule generation
```

---

## Screenshots

> *Note: Visual screenshots can be added here as the UI design evolves.*

| Dashboard | Timetable | Attendance |
| :---: | :---: | :---: |
| *(Placeholder)* | *(Placeholder)* | *(Placeholder)* |

| Calendar | Tasks | Reports |
| :---: | :---: | :---: |
| *(Placeholder)* | *(Placeholder)* | *(Placeholder)* |

---

## Installation Guide

### Prerequisites
- **Flutter SDK**: `>=3.22.0`
- **Dart SDK**: `>=3.4.0`
- **Android Studio** / **VS Code**: Latest version with Flutter plugin installed
- **JDK**: Version 17

### Installation Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/username/AttendIQ.git
   cd AttendIQ
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Code Generation**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the Application**:
   ```bash
   flutter run
   ```

---

## Build Release APK

To generate a production release APK for Android:

```bash
flutter build apk --release
```

**Output Location**:
```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Testing Section

AttendIQ includes comprehensive automated tests ensuring business logic accuracy and widget integrity.

- **Unit Tests**: Mathematical validation for safe bunk calculations, percentage algorithms, and Isar database adapters.
- **Widget Tests**: UI layout verification, timetable carousel interactions, and status transitions.
- **Architecture Tests**: Dependency rules and repository isolation checks.

Run all tests using:
```bash
flutter test
```

---

## Privacy Section

AttendIQ is built around strict data privacy guarantees:

- 🔒 **Zero Data Collection**: No metrics, tracking pixels, or telemetry collected.
- 🚫 **No Cloud Dependency**: Operates 100% offline without Firebase or AWS backend connections.
- 🔑 **No Authentication**: Instant usage without requiring email, phone number, or social logins.
- 💾 **Local Ownership**: All attendance logs and timetable entries stay stored locally on your device.

---

## Roadmap

- [ ] **iOS Release**: Finalize App Store distribution pipeline and iOS notifications.
- [ ] **Optional Cloud Sync**: Opt-in encrypted backup sync via user-owned Google Drive or iCloud.
- [ ] **AI Academic Assistant**: Local AI recommendations for study schedules based on attendance margins.
- [ ] **Smart Attendance Predictions**: Predictive forecasting for exam eligibility based on historical trends.
- [ ] **College Timetable Import**: ICS calendar import & OCR-based timetable image parsing.

---

## Contribution Section

Contributions are welcome! If you'd like to contribute:

1. Fork the project repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes adhering to conventional commit messages (`git commit -m 'feat: Add AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## License Section

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more details.

---

<p align="center">
  Built with ❤️ for students worldwide.
</p>
