# Developer Playbook: AttendIQ

This document provides setup instructions, environment guidelines, CLI commands, and git branching policies for developers working on the AttendIQ project.

---

## 1. System Requirements & Environment

Ensure you have the following installed:
1. **Flutter SDK**: v3.22.0 or higher.
2. **Dart SDK**: v3.4.0 or higher.
3. **Android Studio** (for Android emulator & SDK tools) or **Xcode** (for iOS simulator, MacOS only).
4. **VS Code** with Flutter/Dart extensions installed.
5. **Firebase CLI**: Installed and logged in (`firebase login`).

---

## 2. Getting Started

### 2.1 Clone the Repository
```bash
git clone https://github.com/ramsaitanguturi/AttendIQ.git
cd AttendIQ
```

### 2.2 Install Dependencies
```bash
flutter pub get
```

### 2.3 Run Code Generation
Because we rely heavily on Riverpod and Isar annotations, you must trigger code generation before compiling or running the app:
```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Continuous build (runs in background and watches for changes)
dart run build_runner watch --delete-conflicting-outputs
```

---

## 3. Environment Flavors

AttendIQ supports three environments using target entry points and flavors.

| Environment | Flavor Name | Target Entry Point | Firebase Project ID |
|---|---|---|---|
| Development | `dev` | `lib/main_development.dart` | `attendiq-dev` |
| Staging | `stg` | `lib/main_staging.dart` | `attendiq-stg` |
| Production | `prod` | `lib/main.dart` | `attendiq-prod` |

### Running the App
```bash
# Run Development Flavor
flutter run --flavor dev -t lib/main_development.dart

# Run Production Flavor
flutter run --flavor prod -t lib/main.dart
```

---

## 4. Development Operations CLI Commands

### 4.1 Formatting & Quality Control
Always run these checks before opening a pull request:
```bash
# Format code
dart format .

# Check for formatting issues (will error out on CI if incorrect)
dart format . --set-exit-if-changed

# Static analysis (Linter check)
flutter analyze
```

### 4.2 Running Tests
```bash
# Run all unit and widget tests
flutter test

# Run a specific test file
flutter test test/features/subject/domain/calculate_subject_stats_test.dart

# Run integration tests (requires connected emulator/device)
flutter test integration_test/app_test.dart
```

---

## 5. Git Branching & Commit Guidelines

We enforce a structured git workflow based on **GitHub Flow** and **Conventional Commits**.

### 5.1 Branch Naming Conventions
- New Features: `feature/short-desc` (e.g. `feature/isar-schemas`)
- Bug Fixes: `bugfix/short-desc` (e.g. `bugfix/bunk-calculator-nan`)
- Performance Optimizations: `perf/short-desc` (e.g. `perf/query-indices`)
- Documentation Updates: `docs/short-desc` (e.g. `docs/dev-playbook`)

### 5.2 Commit Message Rules
Commit messages must follow the Conventional Commits format:
`<type>(<scope>): <description>`

Examples:
- `feat(subject): add required attendance override settings`
- `fix(sync): resolve datetime serialization timezone offset bug`
- `docs(readme): add troubleshooting tips for windows installation`
- `test(calculations): add edge cases for 100% target rate bunk math`
- `refactor(auth): simplify google sign in credentials extraction`
