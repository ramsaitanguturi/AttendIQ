import 'dart:convert';
import 'package:isar/isar.dart';

import '../../features/semester/data/models/semester_local.dart';
import '../../features/subject/data/models/subject_local.dart';
import '../../features/timetable/data/models/timetable_template_local.dart';
import '../event_generator/data/models/event_local.dart';
import '../../features/attendance/data/models/attendance_record_local.dart';
import '../notifications/models/notification_item.dart';
import '../../features/settings/data/models/user_preferences_local.dart';
import 'backup_models.dart';

enum ImportStrategy { replace, merge }

class BackupImporter {
  final Isar _isar;
  static const int currentSupportedBackupVersion = 1;

  BackupImporter(this._isar);

  BackupData parseAndValidateJson(String rawJson) {
    dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup payload layout');
    }

    final backupData = BackupData.fromJson(decoded);

    if (backupData.metadata.backupVersion > currentSupportedBackupVersion) {
      throw FormatException(
        'Unsupported backup version ${backupData.metadata.backupVersion}. Current maximum supported version is $currentSupportedBackupVersion.',
      );
    }

    return backupData;
  }

  Future<void> importData(
    String rawJson, {
    ImportStrategy strategy = ImportStrategy.replace,
  }) async {
    final data = parseAndValidateJson(rawJson);

    await _isar.writeAsync((isar) {
      if (strategy == ImportStrategy.replace) {
        isar.userPreferencesLocals.clear();
        isar.semesterLocals.clear();
        isar.subjectLocals.clear();
        isar.timetableTemplateLocals.clear();
        isar.eventLocals.clear();
        isar.attendanceRecordLocals.clear();
        isar.notificationItems.clear();
      }

      // 1. User Preferences
      for (final map in data.userPreferences) {
        final pref = UserPreferencesLocal()
          ..id = (strategy == ImportStrategy.replace ? (map['id'] as int? ?? 0) : 0)
          ..serverId = map['serverId'] as String?
          ..themeMode = map['themeMode'] as String? ?? 'system'
          ..defaultAttendanceTarget = (map['defaultAttendanceTarget'] as num?)?.toDouble() ?? 75.0
          ..classReminderOffset = map['classReminderOffset'] as int? ?? 5
          ..enableNotifications = map['enableNotifications'] as bool? ?? true
          ..enableAttendanceWarnings = map['enableAttendanceWarnings'] as bool? ?? true
          ..weeklyReportEnabled = map['weeklyReportEnabled'] as bool? ?? true
          ..lastSyncTime = DateTime.tryParse(map['lastSyncTime'] as String? ?? '')
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        if (pref.id == 0) {
          pref.id = isar.userPreferencesLocals.autoIncrement();
        }
        isar.userPreferencesLocals.put(pref);
      }

      // 2. Semesters
      for (final map in data.semesters) {
        final sem = SemesterLocal.fromJson(map);
        if (strategy == ImportStrategy.merge || sem.id == 0) {
          sem.id = isar.semesterLocals.autoIncrement();
        }
        isar.semesterLocals.put(sem);
      }

      // 3. Subjects
      for (final map in data.subjects) {
        final sub = SubjectLocal()
          ..id = (strategy == ImportStrategy.replace ? (map['id'] as int? ?? 0) : 0)
          ..serverId = map['serverId'] as String?
          ..semesterId = map['semesterId'] as int? ?? 0
          ..name = map['name'] as String? ?? ''
          ..code = map['code'] as String? ?? ''
          ..faculty = map['faculty'] as String?
          ..credits = map['credits'] as int? ?? 3
          ..attendanceTarget = (map['attendanceTarget'] as num?)?.toDouble() ?? 75.0
          ..color = map['color'] as String? ?? '0xFF10B981'
          ..type = map['type'] as String? ?? 'THEORY'
          ..createdAt = DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        if (sub.id == 0) {
          sub.id = isar.subjectLocals.autoIncrement();
        }
        isar.subjectLocals.put(sub);
      }

      // 4. Timetable
      for (final map in data.timetable) {
        final tt = TimetableTemplateLocal()
          ..id = (strategy == ImportStrategy.replace ? (map['id'] as int? ?? 0) : 0)
          ..serverId = map['serverId'] as String?
          ..subjectId = map['subjectId'] as int? ?? 0
          ..weekday = map['weekday'] as int? ?? 1
          ..startTime = map['startTime'] as String? ?? '09:00'
          ..endTime = map['endTime'] as String? ?? '10:00'
          ..room = map['room'] as String?
          ..faculty = map['faculty'] as String?
          ..notes = map['notes'] as String?
          ..createdAt = DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        if (tt.id == 0) {
          tt.id = isar.timetableTemplateLocals.autoIncrement();
        }
        isar.timetableTemplateLocals.put(tt);
      }

      // 5. Events
      for (final map in data.events) {
        final ev = EventLocal()
          ..id = (strategy == ImportStrategy.replace ? (map['id'] as int? ?? 0) : 0)
          ..serverId = map['serverId'] as String?
          ..subjectId = map['subjectId'] as int? ?? 0
          ..date = DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now()
          ..startTime = map['startTime'] as String? ?? '09:00'
          ..endTime = map['endTime'] as String? ?? '10:00'
          ..eventType = map['eventType'] as String? ?? 'REGULAR_CLASS'
          ..status = map['status'] as String? ?? 'UNMARKED'
          ..createdAt = DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        if (ev.id == 0) {
          ev.id = isar.eventLocals.autoIncrement();
        }
        isar.eventLocals.put(ev);
      }

      // 6. Attendance
      for (final map in data.attendance) {
        final att = AttendanceRecordLocal()
          ..id = (strategy == ImportStrategy.replace ? (map['id'] as int? ?? 0) : 0)
          ..serverId = map['serverId'] as String?
          ..eventId = map['eventId'] as int? ?? 0
          ..subjectId = map['subjectId'] as int? ?? 0
          ..status = map['status'] as String? ?? 'PRESENT'
          ..markedAt = DateTime.tryParse(map['markedAt'] as String? ?? '') ?? DateTime.now()
          ..createdAt = DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        if (att.id == 0) {
          att.id = isar.attendanceRecordLocals.autoIncrement();
        }
        isar.attendanceRecordLocals.put(att);
      }

      // 7. Notifications
      for (final map in data.notifications) {
        final notif = NotificationItem()
          ..id = (strategy == ImportStrategy.replace ? (map['id'] as int? ?? 0) : 0)
          ..title = map['title'] as String? ?? ''
          ..body = map['body'] as String? ?? ''
          ..type = map['type'] as String? ?? 'CLASS_REMINDER'
          ..scheduledTime = DateTime.tryParse(map['scheduledTime'] as String? ?? '') ?? DateTime.now()
          ..relatedId = map['relatedId'] as String?
          ..isRead = map['isRead'] as bool? ?? false;

        if (notif.id == 0) {
          notif.id = isar.notificationItems.autoIncrement();
        }
        isar.notificationItems.put(notif);
      }
    });
  }
}
