# AttendIQ Firebase Cloud Sync — Architecture & Security Specification

## 1. Architectural Philosophy

AttendIQ operates on an **Offline-First, Zero-Secret-Leakage, User-Consent-Gated** architectural standard:

1. **Local Database is Master**: The local Isar database remains the single source of truth for all attendance calculations, rules, occurrences, and notifications.
2. **100% Offline Functional**: The application operates with zero degradation, zero blocking network calls, and zero external dependency when disconnected from the internet.
3. **Explicit Opt-In Only**: Academic data, subject names, or attendance history are **never** uploaded without explicit affirmative consent from the user (`cloudSyncConsentGiven == true`).
4. **No Hardcoded API Secrets**: Authentication tokens and endpoints are provisioned dynamically via OAuth/Firebase Auth. No private service keys or master credentials reside in the client repository.
5. **Conflict-Free Convergence**: Newer local data is never overwritten by older cloud data. Timestamps (`exportedAt` / `createdAt`) are validated before any synchronization.

---

## 2. Service Implementation: `CloudSyncNotifier`

Located at `lib/core/sync/cloud_sync_service.dart`.

```
[Local Database] ──► [BackupExporter] ──► Local Snapshot
                                                │
                                                ▼
                                    [Conflict Detection]
                                                │
                       ┌────────────────────────┴────────────────────────┐
                       ▼                                                 ▼
             Local Is Newer (Safe)                             Cloud Is Newer (Conflict)
                       │                                                 │
                       ▼                                                 ▼
         [Encrypt & Upload to Cloud]                          [Halt & Notify Student]
```

### State Machine (`CloudSyncState`)
- `CloudSyncStatus.idle`: Waiting for user or scheduled trigger.
- `CloudSyncStatus.disabled`: User has not enabled cloud sync or withheld consent.
- `CloudSyncStatus.syncing`: In-progress backup snapshot generation, conflict checking, or upload.
- `CloudSyncStatus.conflict`: Cloud data is newer than local data; manual confirmation required.
- `CloudSyncStatus.success`: Successfully synced with updated `lastSyncTime`.
- `CloudSyncStatus.error`: Network failure, authentication lapse, or corrupted payload.

---

## 3. Cloud Firestore Security Rules (`firestore.rules`)

User backups are isolated in user-specific subcollections guarded by cryptographic UID validation:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /backups/{backupId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow create, update: if request.auth != null 
          && request.auth.uid == userId
          && request.resource.data.keys().hasAll(['metadata', 'payload', 'schemaVersion'])
          && request.resource.data.schemaVersion is int
          && request.resource.data.schemaVersion >= 1;
        allow delete: if request.auth != null && request.auth.uid == userId;
      }
    }
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 4. Verification Evidence

Verified via `test/core/sync/cloud_sync_service_test.dart`:
- `Sync is disabled when cloud consent is not granted`: **PASS**
- `Conflict detection halts sync when remote backup is newer`: **PASS**
- `Sync completes successfully when authorized and no conflicts`: **PASS**
- `Delete cloud backup resets sync state`: **PASS**

