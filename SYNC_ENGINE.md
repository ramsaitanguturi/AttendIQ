# Synchronization Engine: AttendIQ

This document details the design, architecture, and recovery mechanics of AttendIQ's offline-first synchronization engine. The sync engine ensures that students can log, edit, and view attendance data without network connectivity, with silent, background synchronization to Cloud Firestore when the network becomes available.

---

## 1. Sync Architecture

AttendIQ employs a unidirectional write-ahead synchronization pattern. The local database (Isar) acts as the primary client-side authority. The diagram below illustrates the path data takes from UI interactions down to Firestore persistence:

```
[ User UI Interaction ]
         │
         ▼
[ Repository Layer ] ──────────────► [ Update Isar Collection ]
         │                              (isDirty = true, updatedAt = now)
         ▼
[ Sync Outbox Queue ] (Isar Collection)
         │
         ▼ (Triggers Sync Event via Network Status / WorkManager)
[ Sync Manager ]
         │
         ▼
 ┌───────────────┐
 │   Firestore   │ <─── [ Conflict Resolver ] ─── [ Compare timestamps ]
 └───────────────┘
```

1.  **Local Write**: Any user mutation (Add Subject, Log Attendance, Edit Timetable) is immediately committed to Isar via the Repository layer. The record is flagged with `isDirty = true` and `updatedAt = DateTime.now().toUtc()`.
2.  **Outbox Queue Insertion**: A corresponding record is written into the local `SyncQueue` collection describing the target table, operation type, and model ID.
3.  **Sync Trigger**: The `SyncManager` is notified immediately if online, or wakes up via connectivity changes (`connectivity_plus`) or WorkManager periodic executions.
4.  **Remote Sync & Conflict Resolution**: The `SyncManager` processes outbox entries in a FIFO sequence. It compares the local `updatedAt` metadata with the remote document's Firestore `updatedAt` timestamp, resolving conflicts using a Last-Write-Wins (LWW) strategy.

---

## 2. Offline Operations

When network connectivity is unavailable, the application operates in disconnected mode.

*   **Create Offline**: A UUID is generated locally on the device and stored as the record's `serverId`. The record is written to Isar with `isDirty = true`, and a `SyncQueueEntry` of type `INSERT` is created. The UI renders the new item instantly.
*   **Edit Offline**: The local Isar model is updated. `isDirty` is updated to `true`, and `updatedAt` is set to the current UTC timestamp. A `SyncQueueEntry` of type `UPDATE` is added.
*   **Delete Offline**: The local Isar record is soft-deleted by setting `isDeleted = true` and `isDirty = true`. A `SyncQueueEntry` of type `DELETE` is added.
*   **Outbox Isolation**: All offline operations are appended to the local queue. No network operations are attempted. The queue resides in Isar's ACID-compliant storage, making it resilient to application crashes or battery depletion.

---

## 3. Outbox Pattern

The outbox queue is modeled as a persistent database collection in Isar, ensuring transactions are preserved across app lifecycles.

### 3.1 Outbox Schema (`SyncQueueEntry`)

```dart
@collection
class SyncQueueEntry {
  Id id = Isar.autoIncrement;

  late String collectionName; // e.g., "subjects", "attendance_records"
  late String recordServerId;  // UUID linking to the model's serverId
  late String operationType;   // "INSERT", "UPDATE", "DELETE"
  
  late DateTime createdAt;     // Timestamp of queue insertion
  late int retryCount;         // Counter tracking failed attempts
}
```

### 3.2 Queue Handling & Retry Mechanics

1.  **FIFO Processing**: The sync runner fetches pending entries ordered by `createdAt ASC`.
2.  **Exponential Backoff**: If a network request fails due to temporary errors (e.g. timeout, DNS resolution, network drop):
    - The runner stops processing the queue.
    - It schedules a retry task with exponential backoff:
      $$T_{retry} = 2^{\text{retryCount}} \times 5 \text{ seconds} + \text{jitter}$$
    - `retryCount` is capped at $5$. After 5 consecutive failures, the sync loop goes idle until a connectivity change is broadcast.
3.  **Failed Sync Handling (Poison Pill Isolation)**:
    If a sync entry fails due to client validation, Firestore permission rules check failures, or data corruption (e.g. HTTP 400 or HTTP 403):
    - The entry is deemed "poisonous" and cannot be synced.
    - It is removed from the active `SyncQueueEntry` collection and moved to a `FailedSyncQueue` logging collection.
    - A dashboard alert or log is generated. This prevents a single corrupt write from blocking subsequent sync items.

---

## 4. Conflict Resolution

AttendIQ uses a **Last-Write-Wins (LWW)** resolution strategy. The state of the record with the most recent UTC timestamp is preserved.

### 4.1 Timestamp Synchronization Heuristics

To prevent clock drift issues (e.g., if a student's phone clock is set to a future date):
1.  **Local Authority**: Client-side writes record `updatedAt` using the device's UTC clock.
2.  **Remote Verification**:
    - During sync, the client reads the document from Firestore.
    - If a remote document exists:
      - Compare `local.updatedAt` with `remote.updatedAt`.
      - **Client Wins**: If `local.updatedAt > remote.updatedAt`, the client pushes its payload to Firestore. Firestore updates `updatedAt` with the client's timestamp, and records `serverUpdatedAt = FieldValue.serverTimestamp()`.
      - **Server Wins**: If `remote.updatedAt > local.updatedAt`, the client downloads the remote document, overwrites the local Isar database row, and marks `isDirty = false`.
3.  **Audit Logs**: When the server resolves a write, it uses the server's authoritative clock for audit logs, but the record's primary timestamp remains the logical write time (`updatedAt`).

---

## 5. Delete Handling

Deletions must propagate cleanly across offline states without leaving orphan records or causing data bloat.

*   **Soft Delete**: When a record is deleted, it is marked with `isDeleted = true` and `isDirty = true` in Isar.
*   **Tombstones**: The soft-deleted record is pushed to Firestore as a "tombstone" (a document with `isDeleted: true`).
*   **Permanent Purging**:
    - Once Firestore acknowledges the delete write with a success response, the client permanently deletes the record from the local Isar database.
    - If a client pulls a record from Firestore that has `isDeleted == true`, it permanently deletes the local Isar record.
    - A periodic maintenance job (running weekly or on semester start) triggers a clean-up task to delete synced tombstoned records from Isar.

---

## 6. Background Synchronization

The synchronization loop runs in the background to ensure data is updated without user action.

*   **WorkManager Integration**:
    - Android and iOS use the `workmanager` library to register a periodic background task named `com.attendiq.sync_worker`.
    - **Frequency**: Configured to run every **15 minutes** (the minimum allowed duration on Android to preserve battery life).
*   **Network Detection**:
    - The app registers a listener to `connectivity_plus` streams.
    - When connectivity switches from `none` to `mobile/wifi`, a one-off sync task is immediately scheduled in the foreground.
*   **Execution Constraints**:
    - The background task requires internet accessibility (`NetworkType.connected`). If the device is offline, the operating system yields execution, saving battery.

---

## 7. Security & Isolation

Security rules are validated on the server but respected during synchronization.

*   **User Isolation Check**:
    Every outbox request adds the current authenticated `userId` to the payload. The Firestore security rules verify that `request.auth.uid == request.resource.data.userId` before accepting writes. The client cannot write records belonging to other users.
*   **Strict Write Validation**:
    If Firestore rejects a synchronization write (resulting in permission-denied errors), the engine moves the queue entry to the `FailedSyncQueue` immediately, flagging it for administrative audit. It does not crash the client application.
