# Contributing to AttendIQ

Thank you for your interest in contributing to **AttendIQ**! We welcome contributions from developers of all skill levels. Whether you are fixing a bug, improving documentation, adding new features, or optimizing performance, your help is appreciated.

Please take a moment to review this document to ensure a smooth contribution process.

---

## 📜 Code of Conduct

We aim to foster an open, welcoming, and inclusive community. Please treat all contributors with respect, courtesy, and constructive communication regardless of experience level, background, or identity.

---

## 🛠️ How to Contribute

### 1. Reporting Bugs
Before opening an issue, please search existing issues to see if the bug has already been reported.

When submitting a bug report:
- Use the **Bug Report Template** (`.github/ISSUE_TEMPLATE/bug_report.md`).
- Provide a clear and descriptive title.
- Include step-by-step instructions to reproduce the issue.
- Mention your environment details (Flutter SDK version, OS version, target device/emulator).

### 2. Suggesting Features
Enhancements and feature requests are always welcome!
- Use the **Feature Request Template** (`.github/ISSUE_TEMPLATE/feature_request.md`).
- Explain the problem your feature solves or the utility it provides.
- Describe the proposed solution and how it fits into AttendIQ's offline-first architecture.

### 3. Pull Requests Workflow
1. **Fork the Repository**: Click the "Fork" button at the top of the repository page.
2. **Clone Your Fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/AttendIQ.git
   cd AttendIQ
   ```
3. **Create a Feature Branch**:
   ```bash
   git checkout -b feat/my-new-feature
   ```
4. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
5. **Run Code Generation**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
6. **Make Your Changes**: Adhere to our coding guidelines and formatting conventions.
7. **Run Tests**: Ensure all unit and widget tests pass.
   ```bash
   flutter test
   ```
8. **Commit Changes**: Use conventional commit messages (e.g., `feat: add task deadline reminders`).
9. **Push to GitHub**:
   ```bash
   git push origin feat/my-new-feature
   ```
10. **Open a Pull Request**: Submit your PR targeting the `main` branch of the official repository.

---

## 📐 Coding Guidelines

AttendIQ strictly adheres to **Clean Architecture** combined with a **Feature-First** structure.

### 1. Architectural Layers
- **Presentation**: UI Widgets & Screens must not call database models or repositories directly. Use Riverpod providers and controllers.
- **Domain**: Pure Dart logic. Entities, repository interfaces, and use cases must have **zero Flutter or Isar dependencies**.
- **Data**: Implements domain repository interfaces, handles local Isar DB interactions, and handles data mapping.

### 2. Dart & Flutter Conventions
- Run `flutter analyze` before committing code to ensure zero lint errors or warnings.
- Keep widget files modular and reusable under `presentation/widgets/`.
- Use `const` constructors wherever applicable to optimize rendering performance.
- Maintain immutability for state entities and models.

### 3. Commit Message Format
We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` A new feature for the user
- `fix:` A bug fix
- `docs:` Documentation only changes
- `style:` Code style changes (formatting, missing semi-colons, etc.)
- `refactor:` Code changes that neither fix a bug nor add a feature
- `test:` Adding missing tests or correcting existing tests
- `chore:` Changes to build scripts, dependencies, or configuration

*Example*: `feat(academic_planner): add priority tags to exam tasks`

---

## 🧪 Testing Requirements

- Any new business logic in the `domain` or `core` layer must be accompanied by unit tests under the `test/` directory.
- Verify widget interactions using Flutter widget test suites.
- Ensure all tests pass locally via `flutter test` before submitting your PR.

---

## 💬 Getting Help

If you have questions or need clarification on any part of the project structure, feel free to open a discussion or ask questions within your Pull Request!
