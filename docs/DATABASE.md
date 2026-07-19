# Database Architecture: AttendIQ

AttendIQ implements a 100% offline-first storage mechanism using **Isar** as the high-performance local database engine. All user data resides on-device without cloud database dependencies. Data export and restoration is managed via structured `.attendiq` JSON backup files.

---

## 1. Local Database Design (Isar)

We define our schemas as Isar collections registered inside `isarProvider`.

### 1.1 SemesterLocal Schema
Represents active and historic academic semesters.

```dart
@collection
class SemesterLocal {
  int id = 0;
  String? serverId;

  late String name;
  late DateTime startDate;
  late DateTime endDate;
  late double requiredAttendanceRate;

  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
```

### 1.2 SubjectLocal Schema
Represents courses registered under a semester.

```dart
@collection
class SubjectLocal {
  int id = 0;
  String? serverId;

  @Index()
  late int semesterId;

  late String name;
  late String code;
  String? faculty;
  late int credits;
  late double attendanceTarget;
  late String color;
  late String type; // THEORY or LAB

  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
```

### 1.3 TimetableTemplateLocal Schema
Defines repeating weekly class slots.

```dart
@collection
class TimetableTemplateLocal {
  int id = 0;
  String? serverId;

  @Index()
  late int subjectId;

  @Index()
  late int weekday; // 1 = Monday, 7 = Sunday

  late String startTime; // "HH:mm"
  late String endTime;   // "HH:mm"
  String? room;
  String? faculty;
  String? notes;

  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
```

### 1.4 EventLocal Schema
Generated class instances derived from timetable templates or extra classes.

```dart
@collection
class EventLocal {
  int id = 0;
  String? serverId;

  @Index()
  late int subjectId;

  @Index()
  late DateTime date;

  late String startTime;
  late String endTime;
  late String eventType; // REGULAR_CLASS, LAB, TUTORIAL
  late String status;    // UNMARKED, PRESENT, ABSENT, CANCELLED

  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
```

### 1.5 AttendanceRecordLocal Schema
Individual log of attendance for a class event.

```dart
@collection
class AttendanceRecordLocal {
  int id = 0;
  String? serverId;

  @Index()
  late int eventId;

  @Index()
  late int subjectId;

  late String status; // PRESENT, ABSENT, CANCELLED, EXTRA_PRESENT, EXTRA_ABSENT
  late DateTime markedAt;

  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
```

### 1.6 UserPreferencesLocal Schema
Local user preferences and app settings.

```dart
@collection
class UserPreferencesLocal {
  int id = 0;
  String? serverId;

  late String themeMode; // 'light', 'dark', 'system'
  late double defaultAttendanceTarget;
  late int classReminderOffset;
  late bool enableNotifications;
  late bool enableAttendanceWarnings;
  late bool weeklyReportEnabled;
  DateTime? lastSyncTime;

  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
```

### 1.7 NotificationItem Schema
Scheduled and historic local push notifications.

```dart
@collection
class NotificationItem {
  int id = 0;

  late String title;
  late String body;

  @Index()
  late String type;

  late DateTime scheduledTime;
  String? relatedId;
  bool isRead = false;
}
```

---

## 2. Backup & Restore Format (.attendiq)

Data is exported to a single JSON container with the `.attendiq` file extension.

```json
{
  "metadata": {
    "appVersion": "1.1.0",
    "backupVersion": 1,
    "createdAt": "2026-07-19T11:54:43.000Z",
    "devicePlatform": "android"
  },
  "userPreferences": [...],
  "semesters": [...],
  "subjects": [...],
  "timetable": [...],
  "events": [...],
  "attendance": [...],
  "notifications": [...]
}
```
