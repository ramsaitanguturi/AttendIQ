# AttendIQ Backup & Restoration Reliability — Architecture & Audit

## 1. Overview & Data Security Architecture

AttendIQ stores student attendance, subjects, timetables, and notes exclusively on-device in a high-performance Isar database. Because app-private storage is deleted upon app uninstall, AttendIQ implements a multi-tier data protection architecture:

1. **Storage Access Framework (SAF) Public Export**: Allows students to export `.attendiq` archives directly to Downloads, USB OTG, or user-selected cloud drives (Google Drive, OneDrive).
2. **Schema Versioning & Backward Compatibility**: Supports Version 1 (legacy single-event model) and Version 2 (canonical occurrence model with 13 collections) with migration audit logging.
3. **Fail-Safe Integrity Validation**: Pre-transaction JSON validation checks schema bounds, foreign key constraints, and checksums before opening a database write transaction.
4. **ACID Transaction Rollback**: If an error occurs during restoration, the Isar write transaction rolls back completely, ensuring zero partial data corruption or loss.
5. **Configurable Auto-Backup Engine**: Background WorkManager tasks generate periodic snapshots according to user preferences.

---

## 2. Backup Archive Structure (`.attendiq`)

```json
{
  "metadata": {
    "appVersion": "1.1.0",
    "backupVersion": 2,
    "createdAt": "2026-11-15T10:00:00.000Z",
    "devicePlatform": "android"
  },
  "semesters": [ ... ],
  "subjects": [ ... ],
  "timetableTemplates": [ ... ],
  "weeklyScheduleRules": [ ... ],
  "dailyScheduleOccurrences": [ ... ],
  "attendanceRecords": [ ... ],
  "scheduleExceptions": [ ... ],
  "academicEvents": [ ... ],
  "academicTasks": [ ... ],
  "userPreferences": [ ... ],
  "notificationItems": [ ... ],
  "migrationAuditRecords": [ ... ]
}
```

---

## 3. Storage Access Framework (SAF) Export Pipeline

```
[User initiates "Export Backup"]
               │
               ▼
[BackupExporter.exportData()] ──► Compiles 13 collections into JSON snapshot
               │
               ▼
[BackupPathHelper.generateFileName()] ──► Format: AttendIQ_Backup_YYYYMMDD_HHmmss.attendiq
               │
               ▼
[Android SAF Intent / MediaStore API]
  ├─► User selects destination folder in Android Document Picker
  ├─► Direct byte stream written via ContentResolver
  └─► Confirmed with display path & file size
```

---

## 4. Integrity Validation & Error Resilience

Before modifying disk state, `BackupValidator` validates:
1. **Root Structure**: Rejects non-JSON, empty, arrays, or non-object payloads.
2. **Metadata**: Enforces valid `backupVersion` ($\le 2$), non-future export dates, and valid version strings.
3. **Type Safety**: Strictly validates each record's required fields across all 13 collections, preventing `TypeError` runtime escapes.
4. **Referential Integrity**:
   - `Replace Strategy`: Validates that every `subjectId`, `semesterId`, and `ruleId` references an existing or concurrently imported parent.
   - `Merge Strategy`: Gracefully skips orphaned records and logs `migrationAuditRecord` entries without failing the overall restore.
5. **File Size Protection**: Rejects corrupted or malicious files exceeding 20 MB.

---

## 5. Test Suite Verification

| Test Suite | Purpose | Result |
|---|---|---|
| `backup_service_test.dart` | Real Isar serialization, corrupted JSON rejection, version bounds | **PASS (4/4)** |
| `backup_validation_test.dart` | Comprehensive edge cases, malformed dates, dangling FKs, oversized files | **PASS (19/19)** |
| `backup_merge_test.dart` | Merging across 13 collections, ID remapping, conflict resolution | **PASS** |

