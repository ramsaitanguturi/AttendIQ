# Architectural Decision Records (ADR) - AttendIQ

This document outlines the major architectural decisions made for the AttendIQ mobile application, the reasons behind them, and the alternatives considered.

---

## ADR 1: Clean Architecture + Feature-First Structure

### Context
A standard Flutter folder structure (layer-first: `lib/widgets`, `lib/screens`, `lib/models`) quickly becomes unmanageable as the application grows. Developers waste time navigating distant files to work on a single feature.

### Decision
We will use **Clean Architecture** combined with a **Feature-First** structure.
- The project is split into cohesive **features** (e.g., `auth`, `subject`, `attendance`, `timetable`, `analytics`, `ai_advisor`).
- Each feature contains three distinct layers matching Clean Architecture:
  1. **Presentation Layer**: Widgets, UI pages, and Riverpod controllers/notifiers.
  2. **Domain Layer**: Pure Dart business logic containing Entities, Repository interfaces, and Use Cases (if complex). This layer has *zero* dependencies on Flutter, database drivers, or remote API packages.
  3. **Data Layer**: Repository implementations, Local Data Sources (Isar schemas & queries), Remote Data Sources (Firestore clients), and Data Transfer Objects (DTOs / Models).

### Consequences
- **Pros**:
  - High cohesion: all files related to a single feature reside in the same directory.
  - Strict separation of concerns: domain business logic is isolated and fully testable without UI or network mock libraries.
  - Scalability: multiple developers can work on separate features with minimal merge conflicts.
- **Cons**:
  - Slight boilerplate overhead for small features due to layer separation.

### Alternatives Considered
- **Layer-First (MVC/MVVM)**: Easy to start, but scales poorly and breaks down as feature counts increase.

---

## ADR 2: State Management - Riverpod with Code Generation

### Context
We need a robust, testable, and compile-safe state management solution that also acts as a dependency injection (DI) container.

### Decision
We will use **Riverpod** (via the `flutter_riverpod`, `riverpod_annotation`, and `riverpod_generator` packages).
- UI will interact only with Riverpod providers.
- Async operations will use `AsyncNotifierProvider` to handle loading, error, and data states elegantly.
- We mandate the use of the Riverpod Code Generator (`@riverpod` annotations) to guarantee compile-time safety and automatic cleanup of unused states.

### Consequences
- **Pros**:
  - Compile-time safety: no `ProviderNotFoundException`.
  - State caching and automatic garbage collection.
  - Eliminates the need for external service locators (like `get_it`).
  - Highly testable via provider overrides.
- **Cons**:
  - Requires running code generation (`build_runner`) during development.

### Alternatives Considered
- **BLoC (Business Logic Component)**: Excellent separation, but introduces excessive boilerplate for simple state updates.
- **Provider**: Standard, but lacks compile-time safety, fails if widget tree context changes, and lacks auto-dispose by default.

---

## ADR 3: Local Storage - Isar Database

### Context
AttendIQ is designed to be **offline-first**. The database must handle frequent reads/writes, relationships (e.g., Subject has many AttendanceRecords), and complex query filtering (e.g., fetching attendance for a specific subject between dates) while running smoothly on mobile hardware.

### Decision
We will use the **Isar Database** (NoSQL for Flutter).
- Isar provides strong type-safety, fast query execution (ACID compliant), and native support for relational Links and Backlinks.
- Isar runs asynchronously and supports multi-isolate access.
- Datatypes map cleanly from Dart to Isar schemas.

### Consequences
- **Pros**:
  - Extremely fast compared to SQLite or Hive.
  - Support for multi-entry indexes, composite indexes, and native links.
  - Inbuilt full-text search capability.
- **Cons**:
  - Requires code generation via `build_runner`.

### Alternatives Considered
- **Drift (SQLite Wrapper)**: Excellent and robust, but writing SQL queries or mapping relational tables introduces high complexity and boilerplate.
- **Hive**: Key-value store that lacks native relational querying, meaning relationships (like linking attendance logs to subjects) would have to be manually computed in Dart memory.

---

## ADR 4: Synchronization Engine - Offline-First with LWW

### Context
Students must be able to log their attendance, modify subjects, and configure schedules without an internet connection. The app must silently sync changes with Firebase Firestore in the background when connectivity returns.

### Decision
We will implement an **Offline-First Synchronization Engine** using **Last-Write-Wins (LWW)** conflict resolution backed by a local **Sync Queue** (Outbox pattern).
- Every model contains metadata fields: `updatedAt` (timestamp), `isDeleted` (boolean tombstone for soft deletes), and `isDirty` (boolean flag representing un-synced local edits).
- Operations (create/update/delete) are written directly to Isar, marking the record as `isDirty = true` and `updatedAt = DateTime.now()`.
- A background Sync Worker monitors network connectivity. When online, it pushes local dirty records to Firestore, compares server timestamps, and resolves conflicts using LWW.
- Deleted items are kept locally as "tombstones" (records with `isDeleted = true`) until successfully synced, after which they are purged from the local database during maintenance windows.

### Consequences
- **Pros**:
  - Zero latency for user actions: writes are instant locally.
  - Resilient to poor network connectivity.
  - Simple conflict resolution logic.
- **Cons**:
  - Requires managing tombstones to prevent database bloat.
  - LWW can occasionally overwrite concurrent changes if system clocks drift (mitigated by using Firestore Server Timestamps during synchronization).

### Alternatives Considered
- **Online-only with Firestore Cache**: Firestore has an internal offline cache, but developer control over sync status, manual retry queues, complex conflict notification triggers, and advanced offline queries is highly limited.

---

## ADR 5: AI Provider - Google Generative AI (Gemini 1.5 Flash)

### Context
The "AttendIQ Advisor" feature requires an LLM to analyze student schedule, attendance data, and upcoming exams to provide smart suggestions.

### Decision
We will use **Gemini 1.5 Flash** using the official `google_generative_ai` Dart SDK.
- **Why Flash?** Flash offers low latency and low token costs, ideal for routine mobile recommendations, while its large context window allows parsing full schedules and historical logs easily.
- Predictions and reasoning are structured as JSON outputs by configuring schema schemas.

### Consequences
- **Pros**:
  - Very fast response time.
  - Low API cost.
  - First-party Google Dart SDK.
- **Cons**:
  - Requires API key management (handled securely via Firebase Remote Config or secure backend proxy to prevent API key extraction from the app binary).

### Alternatives Considered
- **OpenAI API**: Higher latency and cost, and lacks native integration with Google's cloud ecosystem.

---

## ADR 6: Outbox Synchronization Queue Pattern

### Context
Offline write operations must be recorded and synced to Cloud Firestore in a robust, crash-resilient manner. If the app crashes, is terminated by the OS, or loses network connectivity mid-sync, the application must be able to resume synchronization without data loss or duplicate updates.

### Decision
We will implement a database-backed **Sync Outbox Queue** using Isar (`SyncQueueEntry` collection) to store serializable write commands (INSERT, UPDATE, DELETE) and execute them sequentially (FIFO) upon restored connectivity. 
- Local database modifications write both the data model and a corresponding queue entry in a single ACID transaction block.
- The sync worker processes entries FIFO, removing them only when Firestore writes are successfully completed and acknowledged.

### Consequences
- **Pros**:
  - High resilience: synchronizations resume cleanly across app restarts.
  - Decoupled logic: the user interface updates instantly without waiting for network confirmations.
  - Supports retry policies (exponential backoff) and poison-pill isolation (moving corrupt models to a separate queue).
- **Cons**:
  - Modest write overhead on the device (dual database writes per transaction).

---

## ADR 7: MVP Scope Boundaries and Post-MVP AI Rollout

### Context
To establish a stable and deployable baseline for AttendIQ, we must prevent feature creep and ensure a timely release. Complex integrations such as the Gemini-powered AI Advisor, automatic OCR timetable scanner, and wearable watch integrations require significant cloud configurations and testing, which could delay the deployment of the core offline attendance engine.

### Decision
We will establish a strict boundary between the Minimum Viable Product (MVP) scope and post-MVP releases:
- The **MVP (Phases 0-3)** will contain only the core local tracker, weekly timetable schedules grid, local notification alarms, math calculators ($P$, $B_{safe}$, $A_{req}$), and offline outbox sync loops.
- The **AI Advisor (Phase 4)** is deferred and will be developed and integrated only after the core MVP features are fully verified and stable.

### Consequences
- **Pros**:
  - Faster time-to-market: focuses development on core student tracking value.
  - Reduced cost: limits early remote API token usage (Gemini) and cloud storage billing.
  - High testing isolation: core math calculations and offline sync are finalized and tested before overlaying generative AI features.
- **Cons**:
  - The initial launch will lack the smart advisory panel and conversational insights.

