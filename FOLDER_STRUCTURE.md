# Folder Structure & Clean Architecture: AttendIQ

This document defines the code organization and directory layout rules for the AttendIQ mobile project. AttendIQ adopts a **Feature-First** structure combined with **Clean Architecture** boundaries, powered by **Riverpod** for state management and dependency injection.

---

## 1. Directory Tree Overview

All source code resides inside the `lib/` folder, structured as follows:

```
lib/
├── app/                          # App-wide routing, startup configurations, and wrapper widgets
│   ├── app.dart                  # Root MaterialApp widget
│   └── app_router.dart           # GoRouter route declarations
│
├── core/                         # Shared cross-cutting components (Independent of features)
│   ├── constants/                # Global static configuration values (strings, keys, API endpoints)
│   ├── database/                 # Isar database initialization and schema registration
│   ├── errors/                   # Application exceptions, failures, and error boundary models
│   ├── network/                  # Internet connection handlers, Firebase client adapters
│   ├── sync/                     # Offline sync manager, queue handlers, background workers
│   ├── theme/                    # HSL design tokens, color schemas, and typography setup
│   ├── utils/                    # Common math utilities (attendance calculations) and extensions
│   └── widgets/                  # Reusable global UI controls (custom buttons, shimmer loaders)
│
├── features/                     # Functional modules (Self-contained business domains)
│   ├── auth/                     # User session management, login, and registration flow
│   ├── subject/                  # Course/Subject CRUD operations and target overrides
│   ├── attendance/               # Attendance logs, checking page, and events generation
│   ├── timetable/                # Weekly schedule grids, time slot builders, and reminders
│   ├── analytics/                # Subject charts, metrics panels, and trend calculations
│   └── ai_advisor/               # Generative context builders, Gemini client, fallback logic
│
└── main.dart                     # Application entry point (Production flavor default configuration)
```

---

## 2. Feature-First Layer Separation

To enforce Clean Architecture boundaries, every feature folder inside `lib/features/` (e.g. `subject/`) is partitioned into three distinct layers: `data`, `domain`, and `presentation`.

```
features/feature_name/
├── data/
│   ├── datasources/             # Reads/writes raw data (Local Isar, Remote Firestore)
│   ├── models/                  # Database schemas, JSON serialization DTOs, and mapping functions
│   └── repositories/            # Implements domain repository interfaces (orchestrates data sources)
│
├── domain/
│   ├── entities/                # Plain Old Dart Objects (PODOs) - Immutable business logic models
│   ├── repositories/            # Contract interfaces defining data operations
│   └── usecases/                # Specific units of business logic (Optional: only if complex)
│
└── presentation/
    ├── controllers/             # Riverpod notifiers managing state and user interactions
    ├── pages/                   # Navigable page routes (Screens)
    └── widgets/                 # Component widgets local to this feature
```

---

## 3. Structural Component Responsibilities

To maintain separation of concerns, each file category must follow strict operational rules:

### 3.1 Domain Layer (Inward / Pure)

*   **Entities** (`domain/entities/`):
    Pure Dart classes representing business data structure. They must be **immutable** (`@immutable`), contain no framework decorators, and be independent of Isar, Firestore, or JSON utilities.
*   **Repository Interfaces** (`domain/repositories/`):
    Abstract contract classes defining what data operations the feature supports (e.g., `Future<List<Subject>> fetchSubjects()`). They declare signatures but contain no implementation code.
*   **Use Cases** (`domain/usecases/`):
    Classes that execute a single task (e.g., `CalculateSubjectStats`). They encapsulate specific domain formulas. They are optional; controllers can talk directly to repositories if no complex middleware logic is needed.

### 3.2 Data Layer (Outward / Infrastructure)

*   **Models / DTOs** (`data/models/`):
    Implement storage-specific serialization. This includes:
    - **Isar Models**: Annotated with `@collection` for local storage schemas.
    - **Firestore DTOs**: Contain JSON converters (`fromJson`, `toJson`) for remote collection sync.
    - Models must contain mapping functions (e.g., `toEntity()` and `fromEntity()`) to translate infrastructure schemas to/from pure domain entities.
*   **Data Sources** (`data/datasources/`):
    Direct interfaces to external drivers.
    - `*_local_data_source.dart` manages Isar reads, writes, and local queries.
    - `*_remote_data_source.dart` manages remote Firestore collections, Google sign-ins, or API hits.
*   **Repository Implementations** (`data/repositories/`):
    Classes that implement the domain repository interfaces. They orchestrate local and remote data sources, manage transaction limits, handle cache fallback, and trigger the sync engine.

### 3.3 Presentation Layer (UI / State)

*   **Controllers** (`presentation/controllers/`):
    Riverpod `Notifier` or `AsyncNotifier` classes generated via Riverpod Annotations. They manage state changes, listen to database streams, execute actions asynchronously, and bubble up states (`AsyncValue`).
*   **Pages** (`presentation/pages/`):
    Material widgets representing full screens (e.g., `SubjectDetailPage`). They register under GoRouter routes and layout the core scaffolding.
*   **Widgets** (`presentation/widgets/`):
    Reusable interface sub-components local to this feature (e.g. `SubjectCardWidget`). They receive parameters, listen to controllers, and layout specific UI grids.

---

## 4. Key Cross-Cutting Placements

To prevent duplication and dependency violations, common technical components are isolated:

*   **Database Initializer**: Configured in `lib/core/database/isar_provider.dart`. It opens the local database connection, registers all feature Isar schemas, and acts as a single connection instance.
*   **Firebase Initializer**: Configured in the app entry points (`main_*.dart`) during setup initialization, keeping remote connection objects global.
*   **Global Utilities**: Located in `lib/core/utils/`. This is where common tools reside, such as HSL color hex parsers, date comparison extensions, and the mathematical equations package `attendance_math.dart`.
*   **Global Constants**: Placed in `lib/core/constants/`. Contains application-wide keys (e.g., Shared Preference tokens, sync parameters, notification channel IDs).
