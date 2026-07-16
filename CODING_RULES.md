# Coding Rules & Conventions: AttendIQ

To maintain a high standard of quality, reliability, and consistency across the AttendIQ codebase, all developers must adhere to these coding guidelines and practices.

---

## 1. Static Analysis & Lints

We configure strict lint rules in `analysis_options.yaml`. The build will fail if any lints are violated.

Key Rules to Enforce:
- **Immutability**: Always mark domain entities and states with `@immutable`. Use packages like `freezed` or manual `copyWith` methods for updates.
- **Explicit Types**: Avoid `var` for member variables and function parameters. Use explicit type signatures (e.g. `final List<Subject> subjects = []` instead of `final subjects = []`).
- **Required Parameters**: Use named, required constructor parameters instead of positional parameters to avoid order mismatch bugs.

---

## 2. Architecture & Layer Boundaries

- **No Shortcuts**: The UI layer must *never* talk directly to a data source, repository, or database client. All data retrieval and mutation actions must proceed through Riverpod providers.
- **Pure Entities**: Domain entities inside `domain/entities/` must not contain any annotation or import from `isar`, `cloud_firestore`, or `json_annotation`. They must be raw Dart.
- **DTOs vs Entities**: Models defined in `data/models/` are Data Transfer Objects (DTOs). These classes are responsible for mapping from and to database formats (e.g., `toIsarModel()`, `fromFirestoreMap()`). The UI never handles DTOs directly; it only interacts with Domain Entities.

---

## 3. Riverpod Conventions

### 3.1 Provider Declarations
Always use the Riverpod code generator (`@riverpod` or `@Riverpod(keepAlive: true)`). Avoid declaring legacy global providers (`Provider()`, `StateProvider()`).

```dart
// CORRECT (Generator)
@riverpod
class SubjectListController extends _$SubjectListController {
  @override
  FutureOr<List<Subject>> build() {
    return ref.watch(subjectRepositoryProvider).fetchSubjects();
  }
  
  Future<void> addSubject(Subject subject) async { ... }
}
```

### 3.2 Naming Rules
- Providers must match their generated classes: e.g., a provider named `subjectListControllerProvider` maps to notifier class `SubjectListController`.
- Providers managing collections should end in `Controller` if they handle writes/mutations, or `Provider` if they are read-only streams/futures.

### 3.3 State Encapsulation & Errors
- UI widgets must only read the state of a provider using `ref.watch(provider)`.
- If a provider holds async data, it should return `AsyncValue<T>`. Never swallow errors inside providers; bubble them up so the UI can render standard error widgets:
  ```dart
  // In Widget build()
  subjectsState.when(
    data: (subjects) => ListView(...),
    loading: () => ShimmerList(),
    error: (err, stack) => ErrorIndicator(message: err.toString()),
  );
  ```

---

## 4. Local Storage Conventions (Isar)

- **Transactions**: All writes (inserts, updates, deletes) in Isar must run inside an asynchronous transaction block:
  ```dart
  await isar.writeTxn(() async {
    await isar.subjects.put(isarModel);
  });
  ```
- **Async Execution**: Avoid calling synchronous Isar operations (`putSync()`, `getSync()`) inside the UI or repository methods. Use the asynchronous API to keep the main thread free.
- **Indexes**: Include `@Index` on any field that is frequently queried (e.g., `dateTime` in `AttendanceRecord`, `dayOfWeek` in `ScheduleDay`).

---

## 5. Remote Database Conventions (Firestore)

- **Type Safety**: Always use Firestore converters (`.withConverter<T>`) to serialize and deserialize data. Never read raw maps directly in the repository.
  ```dart
  final subjectsRef = firestore
      .collection('subjects')
      .withConverter<SubjectFirestoreDto>(
        fromFirestore: (snapshot, _) => SubjectFirestoreDto.fromJson(snapshot.data()!),
        toFirestore: (dto, _) => dto.toJson(),
      );
  ```
- **Query Limits**: Never perform queries that fetch entire collections without filters or pagination. Always filter by `userId` and order logs using limits where appropriate.
- **Network Resilience**: Check network status (using `connectivity_plus`) before performing critical non-cached remote writes.
