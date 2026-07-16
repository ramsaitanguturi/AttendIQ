# Database Architecture: AttendIQ

AttendIQ implements an offline-first storage mechanism. It uses **Isar** as the local database engine and **Cloud Firestore** as the remote document store. This document outlines the schemas, relationships, synchronization metadata, and security implications of the database design.

---

## 1. Local Database Design (Isar)

We define our schemas as Isar collections. Every collection includes synchronization metadata fields (`serverId`, `updatedAt`, `isDirty`, and `isDeleted`).

### 1.1 Semester Schema
Represents a student's active semester.

```dart
import 'package:isar/isar.dart';

part 'semester.g.dart';

@collection
class Semester {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String? serverId; // Remote Firestore ID

  late String name;
  late DateTime startDate;
  late DateTime endDate;
  late double requiredAttendanceRate; // e.g. 75.0

  // Sync Metadata
  late DateTime updatedAt;
  late bool isDirty;
  late bool isDeleted;

  @Backlink(to: 'semester')
  final subjects = IsarLinks<Subject>();

  @Backlink(to: 'semester')
  final scheduleDays = IsarLinks<ScheduleDay>();
}
```

### 1.2 Subject Schema
Represents a course/subject registered in a semester.

```dart
import 'package:isar/isar.dart';

part 'subject.g.dart';

@collection
class Subject {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String? serverId;

  late String name;
  late String courseCode;
  String? instructor;
  late int credits;
  late String colorHex; // UI color representation (e.g. "#FF5733")
  double? requiredAttendanceOverride; // Target override if different from semester

  final semester = IsarLink<Semester>();

  @Backlink(to: 'subject')
  final attendanceRecords = IsarLinks<AttendanceRecord>();

  // Sync Metadata
  late DateTime updatedAt;
  late bool isDirty;
  late bool isDeleted;
}
```

### 1.3 AttendanceRecord Schema
Represents an individual log of a class occurrence.

```dart
import 'package:isar/isar.dart';

part 'attendance_record.g.dart';

@collection
class AttendanceRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String? serverId;

  @Index()
  late DateTime dateTime;
  
  // Status: "present", "absent", "late", "cancelled", "extraClass"
  @Index()
  late String status;
  
  late double lateWeight; // Configured weight if status is "late" (e.g. 0.5)
  String? remarks;

  final subject = IsarLink<Subject>();

  // Sync Metadata
  late DateTime updatedAt;
  late bool isDirty;
  late bool isDeleted;
}
```

### 1.4 ScheduleDay & TimeSlot Schemas
Represents the weekly timetable slots.

```dart
import 'package:isar/isar.dart';

part 'schedule_day.g.dart';
part 'time_slot.g.dart';

@collection
class ScheduleDay {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String? serverId;

  late int dayOfWeek; // 1 = Monday, 7 = Sunday
  
  final semester = IsarLink<Semester>();

  @Backlink(to: 'scheduleDay')
  final timeSlots = IsarLinks<TimeSlot>();

  // Sync Metadata
  late DateTime updatedAt;
  late bool isDirty;
  late bool isDeleted;
}

@collection
class TimeSlot {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String? serverId;

  late int subjectLocalId; // References Isar subject id (or use serverId)
  late String subjectServerId;
  late String startTime; // Format: "HH:mm" (e.g., "09:00")
  late String endTime;   // Format: "HH:mm" (e.g., "09:55")
  String? room;          // Room/Lecture hall

  final scheduleDay = IsarLink<ScheduleDay>();

  // Sync Metadata
  late DateTime updatedAt;
  late bool isDirty;
  late bool isDeleted;
}
```

### 1.5 SyncLog Schema
Keeps track of local sync state.

```dart
import 'package:isar/isar.dart';

part 'sync_log.g.dart';

@collection
class SyncLog {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String collectionName;
  late DateTime lastSyncedAt;
}
```

---

## 2. Remote Database Design (Cloud Firestore)

Firestore is structured using top-level, normalized collections. This allows for clean syncing and prevents monolithic documents. The `userId` field acts as the primary key partition for secure isolation.

### 2.1 Collection: `users`
- Path: `/users/{userId}`
```json
{
  "uid": "String",
  "email": "String",
  "displayName": "String",
  "createdAt": "Timestamp"
}
```

### 2.2 Collection: `semesters`
- Path: `/semesters/{semesterId}`
```json
{
  "userId": "String", // Index for querying
  "name": "String",
  "startDate": "Timestamp",
  "endDate": "Timestamp",
  "requiredAttendanceRate": "Double",
  "updatedAt": "Timestamp",
  "isDeleted": "Boolean"
}
```

### 2.3 Collection: `subjects`
- Path: `/subjects/{subjectId}`
```json
{
  "userId": "String", // Index
  "semesterId": "String", // Index
  "name": "String",
  "courseCode": "String",
  "instructor": "String",
  "credits": "Integer",
  "colorHex": "String",
  "requiredAttendanceOverride": "Double | Null",
  "updatedAt": "Timestamp",
  "isDeleted": "Boolean"
}
```

### 2.4 Collection: `attendance_records`
- Path: `/attendance_records/{recordId}`
```json
{
  "userId": "String", // Index
  "subjectId": "String", // Index
  "dateTime": "Timestamp", // Index
  "status": "String",
  "lateWeight": "Double",
  "remarks": "String | Null",
  "updatedAt": "Timestamp",
  "isDeleted": "Boolean"
}
```

### 2.5 Collection: `schedules`
- Path: `/schedules/{scheduleId}`
```json
{
  "userId": "String", // Index
  "semesterId": "String", // Index
  "dayOfWeek": "Integer",
  "timeSlots": [
    {
      "subjectId": "String",
      "startTime": "String",
      "endTime": "String",
      "room": "String"
    }
  ],
  "updatedAt": "Timestamp",
  "isDeleted": "Boolean"
}
```

---

## 3. Relationships & Joins

| Source Entity | Target Entity | Relationship Type | Local Implementation (Isar) | Remote Implementation (Firestore) |
|---|---|---|---|---|
| `Subject` | `Semester` | Many-to-One | `IsarLink<Semester>` | `semesterId` String field in Subject document |
| `Semester` | `Subject` | One-to-Many | `@Backlink` `IsarLinks<Subject>` | Derived query: fetch subjects where `semesterId` |
| `AttendanceRecord` | `Subject` | Many-to-One | `IsarLink<Subject>` | `subjectId` String field in Attendance document |
| `TimeSlot` | `ScheduleDay` | Many-to-One | `IsarLink<ScheduleDay>` | Embedded as Array of Maps in schedule document |

---

## 4. Sync Metadata Schema mapping

When local records are pushed to Firestore, dates are converted from local datetime representations to Firestore timestamps. 
During pulls, Firestore timestamps are parsed back to UTC Dart DateTime objects.
- **Local primary keys**: Isar requires integer primary keys. Firestore requires string keys (UUIDs). To map them, every Isar collection retains a `serverId` string. If a record is generated locally, `serverId` is set to a UUID string. When written to Firestore, that UUID is used as the document ID. This ensures we can lookup documents quickly on either side.
- **Tombstones**: Items deleted while offline have their `isDeleted` flag set to `true` and `isDirty` set to `true`. When syncing, Firestore is updated with `isDeleted = true`. If the client pulls an item with `isDeleted == true`, it deletes it locally from the active database.
