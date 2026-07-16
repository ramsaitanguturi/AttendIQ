# CI/CD & Development Workflows: AttendIQ

This document defines the branching strategy, commit message standards, code review protocols, and automated Continuous Integration / Continuous Deployment (CI/CD) pipelines for AttendIQ.

---

## 1. Branching Strategy

AttendIQ uses a structured git branch model based on **GitHub Flow** to coordinate work.

```
       [ main ] (Stable Production Releases)
          ▲
          │ (Release Pull Request)
    [ development ] (Integration & Pre-Release testing)
          ▲
     ┌────┴────┐ (Feature Pull Request)
     │         │
[ feature/* ] [ bugfix/* ] [ refactor/* ] [ docs/* ]
```

*   **`main` Branch**: Contains the stable, production-ready source code. Directly mirrors what is deployed to the App Store and Google Play Store. Rejcts direct commits; updates occur exclusively via pull requests from `development`.
*   **`development` Branch**: The primary integration branch. Developers merge completed feature branches here. Automated integration tests and staging environments are run from this branch.
*   **Topic Branches (`feature/*`, `bugfix/*`, `refactor/*`, `docs/*`)**:
    - Temporary branches dedicated to a single task, branched off `development`.
    - Naming convention: `<type>/<short-description>` (e.g. `feature/onboarding-wizard`, `bugfix/bunk-calculator-rounding`).

---

## 2. Commit Conventions

Commits must follow the **Conventional Commits** standard. This enables automated changelog generation and maintains a clean history.

### 2.1 Format
`type(scope): description`

*   **Type** (required):
    - `feat`: A new user-facing feature.
    - `fix`: A bug fix.
    - `docs`: Documentation changes only.
    - `style`: Formatting, missing semi-colons, etc. (no business code changes).
    - `refactor`: Code changes that neither fix a bug nor add a feature.
    - `perf`: Code changes that improve performance.
    - `test`: Adding missing tests or correcting existing tests.
    - `chore`: Maintenance tasks, dependency updates, build configs.
*   **Scope** (optional): The specific module or feature affected (e.g. `auth`, `sync`, `math`).
*   **Description** (required): A concise, present-tense summary of the change in lowercase.

### 2.2 Examples
- `feat(subject): add threshold override validation rules`
- `fix(sync): resolve outbox duplicate write lock`
- `docs(readme): add environment flavor setup guides`
- `test(math): add border value tests for must-attend calculation`

---

## 3. Pull Request (PR) Process

To merge any code into `development` or `main`, a developer must open a Pull Request:

1.  **PR Template Verification**: The PR description must link to the corresponding issue/task (e.g., `Closes #12`) and summarize the implementation approach.
2.  **Code Review**: At least one senior developer must review and approve the PR.
3.  **Automated Checks**: The GitHub Actions CI pipeline must pass (zero errors or lints).
4.  **Merge Requirement**: Once approved and green, the PR is merged into `development` using the **Squash and Merge** strategy. This collapses topic branch commits into a single commit on the integration branch.

---

## 4. Continuous Integration Pipeline (GitHub Actions)

We run static checks, testing suite validation, and test builds on every pull request targeting `development` or `main`.

### 4.1 Configuration Pipeline Draft (`.github/workflows/ci.yml`)

```yaml
name: AttendIQ Continuous Integration

on:
  push:
    branches: [ main, development ]
  pull_request:
    branches: [ main, development ]

jobs:
  analyze_and_test:
    name: Code Analysis & Unit Testing
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Java Development Kit
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter SDK
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Verify formatting
        run: dart format --set-exit-if-changed .

      - name: Run code generators (build_runner)
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Static code analysis
        run: flutter analyze

      - name: Run unit & widget tests
        run: flutter test --coverage

  build_staging_apk:
    name: Compile Staging Android Build
    needs: analyze_and_test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Java JDK
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter SDK
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run build_runner
        run: dart run build_runner build --delete-conflicting-outputs

      - name: Build Dev Flavor APK
        run: flutter build apk --flavor dev -t lib/main_development.dart --release

      - name: Upload APK Artifact
        uses: actions/upload-artifact@v4
        with:
          name: attendiq-staging-apk
          path: build/app/outputs/flutter-apk/app-dev-release.apk
```

---

## 5. Release Process

Official releases follow semantic versioning standards.

1.  **Release Trigger**: Pushing a version tag matching `v*.*.*` (e.g. `v1.0.0`) to the `main` branch.
2.  **Changelog Compilation**: A GitHub Action parses the conventional commit history between tags and draft-generates the Release notes.
3.  **Signing & Compilation**:
    - The runner compiles the signed Android App Bundle (AAB) for Play Store deployment.
    - The runner compiles the signed iOS App Store Package (IPA) using Apple Developer certificates configured in GitHub Secrets.
4.  **Artifact Publishing**: Binaries are appended as artifacts directly to the GitHub Release draft.
