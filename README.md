# ACEDRA — Intelligent Academic & Attendance Management System

> A privacy-focused, offline-first student productivity application for managing attendance, timetable, academic calendar, tasks, and semester planning.

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Isar Database](https://img.shields.io/badge/Isar-4.0--dev-00A98F?style=for-the-badge&logo=database&logoColor=white)](https://isar.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-lightgrey?style=for-the-badge)]()

---

## Overview

### What is ACEDRA?
**ACEDRA** (formerly AttendIQ) is a comprehensive, offline-first academic management application built using Flutter, Riverpod, and Isar database. Designed for university and college students, ACEDRA provides real-time attendance analytics, intelligent timetable scheduling, individual class reminders with direct attendance action buttons, historical attendance editing, smart predictions, and an optional translucent dark smoked-glass design system.

### Key Highlights
- **100% Offline-First & Private**: Zero telemetry, zero tracking, all data resides in local on-device Isar storage.
- **Persistent Floating Bottom Navigation**: Seamless pill-shaped navigation container with 4 dedicated tabs (Home, Timetable, Analytics, Account).
- **Individual Class Notifications**: Separate persistent reminders for every scheduled class with 1-tap `PRESENT | ABSENT | CANCELLED` actions (+ `LATE` when enabled) that cannot be cleared accidentally.
- **Easy Historical Attendance Editing**: Modify attendance from any previous date with atomic recalculations and duplicate prevention.
- **Late Attendance (Toggleable, OFF by default)**: Completely hidden from UI and actions when disabled; full weighted policy support when enabled.
- **Optional Glassy Theme**: High-performance dark smoked glass design with silver reflections, subtle glows, and responsive tokens.
- **AI Attendance Advisor (Toggleable, ON by default)**: Strategic study guidance and attendance safety forecasting.

---

## Features

### Attendance Management
- **Subject-Wise Attendance Tracking**: Track conducted, attended, missed, and cancelled sessions for every subject.
- **Direct Status Logging**: Mark attendance (`Present`, `Absent`, `Cancelled`, `Late` if enabled) with instant persistence.
- **Historical Attendance Editing**: Jump to any past date via calendar picker or timeline, view recorded attendance, and modify statuses with immediate recalculation.
- **Safe Bunk & Must-Attend Analytics**:
  - *Safe Bunks*: Exact number of consecutive classes you can safely skip while staying above your target.
  - *Must-Attend*: Exact count of consecutive classes required to recover to your target threshold.
- **Attendance Reports**: Generate structured PDF and CSV summaries for academic reviews.

### Smart Timetable & Calendar
- **Weekly Schedule**: Interactive weekly timetable with collision prevention and room allocations.
- **Daily Timeline View**: Chronological schedule for any date with quick attendance marking.
- **Academic Calendar**: Unified monthly grid tracking classes, holidays, exams, events, and tasks.
- **Extra Classes & Exceptions**: Add one-off extra sessions or cancel specific occurrences without disturbing weekly recurring rules.

### Notifications & Reminders
- **Individual Class Notifications**: Distinct notifications per class occurrence identifying subject name, time, and room.
- **Direct Action Buttons**: Mark `PRESENT`, `ABSENT`, or `CANCELLED` directly from the notification shade.
- **Android Persistence**: Scheduled as ongoing reminders to prevent accidental dismissal via "Clear all", automatically dismissed upon action.
- **Attendance Warnings & Digest**: Automatic alerts when attendance nears risk thresholds and weekly summaries.

### Modern Interface & Navigation
- **Persistent Floating Bottom Bar**: Floating pill navigation bar preserving tab states across Home, Timetable, Analytics, and Account.
- **Complete Glassy Theme**: Smoked glass surfaces, platinum borders, and ambient dark backgrounds toggleable in Settings.

---

## Architecture

ACEDRA follows **Clean Architecture** decoupled into feature modules:

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
- **Presentation**: Flutter UI screens, floating navigation shell, Material 3 & Glass themes, Riverpod Notifiers/Providers.
- **Domain**: Pure Dart business logic, attendance calculators, historical attendance services, and repository contracts.
- **Data**: Isar database schemas, local datasources, backup engine adapters, and repository implementations.

---

## Tech Stack

| Technology | Purpose |
| :--- | :--- |
| **Flutter 3.22+** | Cross-platform UI framework for mobile & desktop |
| **Dart 3.4+** | High-performance type-safe programming language |
| **Riverpod 2.5+** | Reactive, compile-safe state management framework |
| **Isar 4.0** | Extremely fast, asynchronous local NoSQL database |
| **GoRouter 14+** | Declarative navigation with `StatefulShellRoute.indexedStack` |
| **Flutter Local Notifications** | Direct interactive class reminders with action buttons |

---

## Project Structure

```text
lib/
 ├── app/                   # App root, GoRouter indexedStack configuration, theme binding
 ├── core/                  # Shared utilities, database, notifications & base widgets
 │    ├── ai/               # AI Advisor services (Local heuristics & Gemini API)
 │    ├── attendance_engine/# Attendance percentage & safe bunk calculators
 │    ├── background/       # WorkManager background worker & periodic refresh
 │    ├── backup/           # Import/export backup manager (.attendiq, JSON)
 │    ├── database/         # Isar instance setup, schemas & migrations
 │    ├── notifications/    # Notification queue, action handlers & ongoing scheduling
 │    └── theme/            # Material 3 & centralized Glass design system
 └── features/              # Feature-First Clean Architecture modules
      ├── academic_planner/ # Tasks, assignments, projects & calendar events
      ├── account/          # Profile, active semester manager & quick links
      ├── ai_assistant/     # Academic counseling chat & recommendation UI
      ├── analytics/        # Attendance progress, reports & trends (PDF/CSV)
      ├── attendance/       # Daily check-ins, historical editing & stats
      ├── onboarding/       # Splash & initial configuration wizard
      ├── semester/         # Active semester metadata & management
      ├── settings/         # 5 grouped settings sections (Appearance, Attendance, etc.)
      ├── subject/          # Course subjects & weekly rule definitions
      ├── timetable/        # Weekly timetable, daily schedule & academic calendar
      └── widgets/          # Android home screen widgets & sync coordinator
```

---

## Installation Guide

### Prerequisites
- **Flutter SDK**: `>=3.22.0`
- **Dart SDK**: `>=3.4.0`
- **Android Studio** / **VS Code**: Latest version with Flutter plugin
- **JDK**: Version 17

### Installation Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/ramsaitanguturi/AttendIQ.git
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
   flutter run --flavor prod
   ```

---

## Testing Section

Run all tests using:
```bash
flutter test
```

---

## License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more details.
