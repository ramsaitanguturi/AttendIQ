# AttendIQ Database Architecture & Schema Specification

## 1. Overview

AttendIQ is architected as a **100% offline-first, privacy-focused application**.
It relies entirely on an embedded, high-performance local NoSQL database: **Isar Database 4 (`isar: ^4.0.0-dev.14`)**.

- **Zero Cloud Dependency**: No user data is sent to external servers or cloud databases (no Firebase, no Cloud Firestore, no remote SQL).
- **Zero Authentication Overhead**: All data is stored locally in device private storage (`getApplicationDocumentsDirectory()`), indexed and queried via typed Dart objects.
- **ACID Transactions**: Synchronous and asynchronous write transactions with strict rollback semantics.
- **Portability**: Complete database state can be exported and imported as structured, encrypted `.attendiq` or standard `.json` backup files.

---

## 2. The 13 Isar Collections (Schemas)

All schemas are declared in `lib/core/database/isar_provider.dart` under `appIsarSchemas`.

### 2.1 `SemesterLocal` (`SemesterLocalSchema`)
Defines academic semester boundaries. All timetable rules, subjects, and calendar occurrences are partitioned by semester.
- `id`: Isar auto-increment integer ID (`Id`).
- `name`: Semester display name (e.g., "Fall 2026", "Semester 6").
- `startDate`: Start date of the semester (`DateTime`).
- `endDate`: End date of the semester (`DateTime`).
- `isArchived`: Whether the semester is archived (`bool`).
- `createdAt`, `updatedAt`: Timestamps (`DateTime`).
- `isDirty`, `isDeleted`: Offline sync metadata (`bool`).
- `serverId`: Optional UUID string (`String?`).

### 2.2 `SubjectLocal` (`SubjectLocalSchema`)
Academic course/subject tracked within a semester.
- `id`: Isar auto-increment ID (`Id`).
- `semesterId`: Foreign key to `SemesterLocal.id` (`int`, indexed).
- `name`: Course title (e.g., "Operating Systems").
- `code`: Course code (e.g., "CS301").
- `faculty`: Instructor / Professor name.
- `credits`: Academic credits (e.g., 3 or 4).
- `attendanceTarget`: Target attendance percentage (e.g., 75.0 or 80.0).
- `color`: Hex color string for UI chips and timetable blocks (e.g., `"#4CAF50"`).
- `type`: Course type (`THEORY`, `LAB`, `TUTORIAL`).
- `createdAt`, `updatedAt`, `isDirty`, `isDeleted`, `serverId`.

### 2.3 `WeeklyScheduleRuleLocal` (`WeeklyScheduleRuleLocalSchema`)
Canonical recurring timetable slots. Supports multiple slots per week for the same subject across different weekdays.
- `id`: Isar auto-increment ID (`Id`).
- `subjectId`: Foreign key to `SubjectLocal.id` (`int`, indexed).
- `semesterId`: Foreign key to `SemesterLocal.id` (`int`, indexed).
- `dayOfWeek`: Weekday index (1 = Monday through 7 = Sunday).
- `startTime`: Slot start time in `HH:mm` format (e.g., `"09:00"`).
- `endTime`: Slot end time in `HH:mm` format (e.g., `"10:00"`).
- `room`: Room or laboratory identifier (e.g., `"Hall A"`, `"Lab 302"`).
- `type`: Slot category (`REGULAR_CLASS`, `LAB`, `TUTORIAL`).
- `isActive`: Whether the recurring rule is active (`bool`).
- `createdAt`, `updatedAt`, `isDirty`, `isDeleted`, `serverId`.

### 2.4 `DailyScheduleOccurrenceLocal` (`DailyScheduleOccurrenceLocalSchema`)
Canonical daily schedule occurrences. Materialized dynamically from weekly rules or created as manual extra classes.
- `id`: Isar auto-increment ID (`Id`).
- `ruleId`: Optional foreign key to `WeeklyScheduleRuleLocal.id` (`int?`).
- `subjectId`: Optional foreign key to `SubjectLocal.id` (`int?`, indexed).
- `semesterId`: Optional foreign key to `SemesterLocal.id` (`int?`, indexed).
- `date`: Calendar date of the occurrence normalized to UTC (`DateTime`, indexed).
- `startTime`: Occurrence start time (`HH:mm`).
- `endTime`: Occurrence end time (`HH:mm`).
- `room`: Room identifier.
- `type`: Category (`REGULAR_CLASS`, `EXTRA_CLASS`, `LAB`, `TUTORIAL`, `EXAM`).
- `status`: Occurrence state (`UPCOMING`, `PRESENT`, `ABSENT`, `CANCELLED`).
- `createdFrom`: Origin tracking (`WEEKLY_RULE`, `EXTRA_CLASS`, `EXCEPTION`).
- `slotKey`: Canonical deterministic slot identity key (`String?`, indexed).
- `createdAt`, `updatedAt`, `isDirty`, `isDeleted`, `serverId`.

### 2.5 `AttendanceRecordLocal` (`AttendanceRecordLocalSchema`)
Immutable attendance logs created when an occurrence status is checked.
- `id`: Isar auto-increment ID (`Id`).
- `occurrenceId`: Foreign key to `DailyScheduleOccurrenceLocal.id` (`int?`, indexed).
- `eventId`: Cross-collection compatibility foreign key (`int?`, indexed).
- `subjectId`: Foreign key to `SubjectLocal.id` (`int`, indexed).
- `status`: Attendance check-in status (`PRESENT`, `ABSENT`, `CANCELLED`, `EXTRA_PRESENT`, `EXTRA_ABSENT`).
- `markedAt`: Date when the session took place (`DateTime`, indexed).
- `createdAt`, `updatedAt`, `isDirty`, `isDeleted`, `serverId`.

### 2.6 `ScheduleExceptionLocal` (`ScheduleExceptionLocalSchema`)
Date-specific overrides that modify regular timetable generation without mutating recurring rules.
- `id`: Isar auto-increment ID (`Id`).
- `semesterId`: Foreign key to `SemesterLocal.id` (`int?`, indexed).
- `subjectId`: Optional foreign key to `SubjectLocal.id` (`int?`).
- `date`: Date of the exception in UTC (`DateTime`, indexed).
- `type`: Exception category (`HOLIDAY`, `CANCELLED_CLASS`, `EXTRA_CLASS`, `EXAM`).
- `title`: Exception title (e.g., "National Holiday", "Guest Lecture").
- `description`: Optional notes or reasons.
- `originalStartTime`, `originalEndTime`: Replaced slot times.
- `createdAt`, `updatedAt`, `isDirty`, `isDeleted`, `serverId`.

### 2.7 `AcademicEventLocal` (`AcademicEventLocalSchema`)
Institutional milestones and calendar commitments.
- `id`: Isar auto-increment ID (`Id`).
- `title`: Event name (e.g., "Mid-Semester Examination").
- `description`: Detailed description.
- `date`: Event date (`DateTime`, indexed).
- `startTime`, `endTime`: Optional time range (`String?`).
- `type`: Event classification (`EXAM`, `ASSIGNMENT_DUE`, `PROJECT_DEADLINE`, `HOLIDAY`, `COLLEGE_EVENT`).
- `createdAt`, `updatedAt`, `isDirty`, `isDeleted`, `serverId`.

### 2.8 `AcademicTaskLocal` (`AcademicTaskLocalSchema`)
Coursework, assignments, projects, and deadlines.
- `id`: Isar auto-increment ID (`Id`).
- `title`: Task title.
- `description`: Optional notes.
- `taskType`: Category (`ASSIGNMENT`, `PROJECT`, `EXAM`, `READING`, `OTHER`).
- `subjectId`: Optional foreign key to associated `SubjectLocal.id` (`int?`).
- `startDate`: Task start date (`DateTime?`).
- `dueDate`: Task deadline (`DateTime`, indexed).
- `priority`: Urgency level (`LOW`, `MEDIUM`, `HIGH`, `URGENT`).
- `reminder`: Reminder notification offset (`DateTime?`).
- `isCompleted`: Task completion status (`bool`).
- `createdAt`, `updatedAt`, `isDirty`, `isDeleted`, `serverId`.

### 2.9 `NotificationItem` (`NotificationItemSchema`)
Audit and scheduling persistence for local notifications.
- `id`: Notification ID (`Id`).
- `title`: Notification title.
- `body`: Notification message content.
- `scheduledTime`: Exact trigger time (`DateTime`).
- `type`: Notification type (`CLASS_REMINDER`, `ATTENDANCE_WARNING`, `WEEKLY_REPORT`, `TASK_REMINDER`, `GENERAL`).
- `relatedId`: ID of associated entity (`int?`).
- `relatedKey`: Canonical slot or event key (`String?`).
- `createdAt`: Scheduling timestamp (`DateTime`).
- `isSent`: Delivery status (`bool`).
- `isCancelled`: Cancellation status (`bool`).

### 2.10 `UserPreferencesLocal` (`UserPreferencesLocalSchema`)
Persistent app configuration and user settings.
- `id`: Isar ID (`Id`).
- `attendanceTarget`: Default minimum attendance percentage target (default: `75.0`).
- `reminderOffsetMinutes`: Minutes before class to trigger notification (default: `15`).
- `enableAutoBackup`: Automatic weekly backup toggle (`bool`).
- `autoBackupDay`: Weekday for auto backup (default: Sunday = `7`).
- `autoBackupHour`: Hour for auto backup (default: `2` AM).
- `lastBackupDate`: Timestamp of last successful backup (`DateTime?`).
- `darkMode`: App theme mode preference.
- `createdAt`, `updatedAt`, `isDirty`.

### 2.11 `MigrationAuditRecordLocal` (`MigrationAuditRecordLocalSchema`)
Durable audit log recording schema migrations, deduplication events, and foreign-key reconciliations.
- `id`: Isar ID (`Id`).
- `auditKey`: Deterministic unique audit key preventing duplicate entries (`String`, indexed).
- `kind`: Audit event kind (`duplicateOccurrenceMerged`, `missingOccurrenceTarget`, `subjectMismatch`, `ambiguousAttendanceCollision`, `recoveredAttendance`).
- `attendanceRecordId`, `legacyEventId`, `sourceEventId`, `occurrenceId`, `sourceOccurrenceId`, `subjectId`: Reconciled entity IDs.
- `slotKey`: Associated slot key (`String?`).
- `candidateOccurrenceIds`: Candidate list for collision resolution (`List<int>`).
- `status`: Reconciled status string (`String?`).
- `date`: Session date (`DateTime?`).
- `reason`: Human-readable explanation of migration action.
- `diagnosticDetails`: JSON diagnostic string.
- `timestamp`: Execution timestamp (`DateTime`).

### 2.12 Legacy & Compatibility Collections
- **`TimetableTemplateLocal` (`TimetableTemplateLocalSchema`)**: Legacy timetable template collection maintained for backward compatibility, backup import, and automated schema migration.
- **`EventLocal` (`EventLocalSchema`)**: Legacy event generator collection maintained for pre-BUG-004 attendance record reconciliation and data migration.

---

## 3. Entity Relationships & Foreign Key Map

```text
SemesterLocal (1)
  ├──> SubjectLocal (N) [via semesterId]
  │      ├──> WeeklyScheduleRuleLocal (N) [via subjectId]
  │      │      └──> DailyScheduleOccurrenceLocal (N) [via ruleId, subjectId]
  │      │             └──> AttendanceRecordLocal (1) [via occurrenceId, subjectId]
  │      └──> AcademicTaskLocal (N) [via optional subjectId]
  ├──> ScheduleExceptionLocal (N) [via semesterId]
  └──> AcademicEventLocal (N) [via date matching]
```

---

## 4. Migration & Integrity Guarantees

1. **Transactional Boundaries**: All Isar operations that modify multiple entities execute inside `isar.writeTxn(...)` or `isar.writeAsync(...)`. Any unexpected error triggers an automatic rollback leaving the database unmodified.
2. **Startup Migrations**: On application launch, `runMigration(isar)` verifies database schema versioning. Legacy events and templates are safely translated into `WeeklyScheduleRuleLocal` and `DailyScheduleOccurrenceLocal` entities without loss of attendance history.
3. **Foreign Key Integrity in Backups**:
   - **Merge Mode**: Remaps all imported IDs, skips orphaned records whose parents do not exist, and logs audit events.
   - **Replace Mode**: Validates the complete backup JSON structure before wiping, aborting cleanly without modifying existing data if the file is corrupted or invalid.
