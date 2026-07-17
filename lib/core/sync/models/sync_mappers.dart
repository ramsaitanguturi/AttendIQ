import '../../../../features/auth/data/models/semester_local.dart';
import '../../../../features/subject/data/models/subject_local.dart';
import '../../../../features/timetable/data/models/timetable_template_local.dart';
import '../../event_generator/data/models/event_local.dart';
import '../../../../features/attendance/data/models/attendance_record_local.dart';
import '../../../../features/settings/data/models/user_preferences_local.dart';

extension SemesterLocalMapper on SemesterLocal {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverId': serverId,
      'name': name,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'requiredAttendanceRate': requiredAttendanceRate,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  static SemesterLocal fromMap(Map<String, dynamic> map) {
    return SemesterLocal()
      ..id = (map['id'] as num?)?.toInt() ?? 0
      ..serverId = map['serverId'] as String?
      ..name = map['name'] as String
      ..startDate = DateTime.parse(map['startDate'] as String).toUtc()
      ..endDate = DateTime.parse(map['endDate'] as String).toUtc()
      ..requiredAttendanceRate = (map['requiredAttendanceRate'] as num).toDouble()
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt'] as String).toUtc()
      ..isDirty = map['isDirty'] as bool? ?? false
      ..isDeleted = map['isDeleted'] as bool? ?? false;
  }
}

extension SubjectLocalMapper on SubjectLocal {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverId': serverId,
      'semesterId': semesterId,
      'name': name,
      'code': code,
      'faculty': faculty,
      'credits': credits,
      'attendanceTarget': attendanceTarget,
      'color': color,
      'type': type,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  static SubjectLocal fromMap(Map<String, dynamic> map) {
    return SubjectLocal()
      ..id = (map['id'] as num?)?.toInt() ?? 0
      ..serverId = map['serverId'] as String?
      ..semesterId = (map['semesterId'] as num?)?.toInt() ?? 0
      ..name = map['name'] as String
      ..code = map['code'] as String
      ..faculty = map['faculty'] as String?
      ..credits = (map['credits'] as num?)?.toInt() ?? 0
      ..attendanceTarget = (map['attendanceTarget'] as num).toDouble()
      ..color = map['color'] as String
      ..type = map['type'] as String
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt'] as String).toUtc()
      ..isDirty = map['isDirty'] as bool? ?? false
      ..isDeleted = map['isDeleted'] as bool? ?? false;
  }
}

extension TimetableTemplateLocalMapper on TimetableTemplateLocal {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverId': serverId,
      'subjectId': subjectId,
      'weekday': weekday,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'faculty': faculty,
      'notes': notes,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  static TimetableTemplateLocal fromMap(Map<String, dynamic> map) {
    return TimetableTemplateLocal()
      ..id = (map['id'] as num?)?.toInt() ?? 0
      ..serverId = map['serverId'] as String?
      ..subjectId = (map['subjectId'] as num?)?.toInt() ?? 0
      ..weekday = (map['weekday'] as num?)?.toInt() ?? 1
      ..startTime = map['startTime'] as String
      ..endTime = map['endTime'] as String
      ..room = map['room'] as String?
      ..faculty = map['faculty'] as String?
      ..notes = map['notes'] as String?
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt'] as String).toUtc()
      ..isDirty = map['isDirty'] as bool? ?? false
      ..isDeleted = map['isDeleted'] as bool? ?? false;
  }
}

extension EventLocalMapper on EventLocal {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverId': serverId,
      'subjectId': subjectId,
      'date': date.toUtc().toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'eventType': eventType,
      'status': status,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  static EventLocal fromMap(Map<String, dynamic> map) {
    return EventLocal()
      ..id = (map['id'] as num?)?.toInt() ?? 0
      ..serverId = map['serverId'] as String?
      ..subjectId = (map['subjectId'] as num?)?.toInt() ?? 0
      ..date = DateTime.parse(map['date'] as String).toUtc()
      ..startTime = map['startTime'] as String
      ..endTime = map['endTime'] as String
      ..eventType = map['eventType'] as String
      ..status = map['status'] as String
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt'] as String).toUtc()
      ..isDirty = map['isDirty'] as bool? ?? false
      ..isDeleted = map['isDeleted'] as bool? ?? false;
  }
}

extension AttendanceRecordLocalMapper on AttendanceRecordLocal {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverId': serverId,
      'eventId': eventId,
      'subjectId': subjectId,
      'status': status,
      'markedAt': markedAt.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  static AttendanceRecordLocal fromMap(Map<String, dynamic> map) {
    return AttendanceRecordLocal()
      ..id = (map['id'] as num?)?.toInt() ?? 0
      ..serverId = map['serverId'] as String?
      ..eventId = (map['eventId'] as num?)?.toInt() ?? 0
      ..subjectId = (map['subjectId'] as num?)?.toInt() ?? 0
      ..status = map['status'] as String
      ..markedAt = DateTime.parse(map['markedAt'] as String).toUtc()
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt'] as String).toUtc()
      ..isDirty = map['isDirty'] as bool? ?? false
      ..isDeleted = map['isDeleted'] as bool? ?? false;
  }
}

extension UserPreferencesLocalMapper on UserPreferencesLocal {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverId': serverId,
      'themeMode': themeMode,
      'defaultAttendanceTarget': defaultAttendanceTarget,
      'classReminderOffset': classReminderOffset,
      'enableNotifications': enableNotifications,
      'enableAttendanceWarnings': enableAttendanceWarnings,
      'weeklyReportEnabled': weeklyReportEnabled,
      'lastSyncTime': lastSyncTime?.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  static UserPreferencesLocal fromMap(Map<String, dynamic> map) {
    return UserPreferencesLocal()
      ..id = (map['id'] as num?)?.toInt() ?? 0
      ..serverId = map['serverId'] as String?
      ..themeMode = map['themeMode'] as String? ?? 'system'
      ..defaultAttendanceTarget = (map['defaultAttendanceTarget'] as num?)?.toDouble() ?? 75.0
      ..classReminderOffset = (map['classReminderOffset'] as num?)?.toInt() ?? 5
      ..enableNotifications = map['enableNotifications'] as bool? ?? true
      ..enableAttendanceWarnings = map['enableAttendanceWarnings'] as bool? ?? true
      ..weeklyReportEnabled = map['weeklyReportEnabled'] as bool? ?? true
      ..lastSyncTime = map['lastSyncTime'] != null ? DateTime.parse(map['lastSyncTime'] as String).toUtc() : null
      ..updatedAt = DateTime.parse(map['updatedAt'] as String).toUtc()
      ..isDirty = map['isDirty'] as bool? ?? false
      ..isDeleted = map['isDeleted'] as bool? ?? false;
  }
}
