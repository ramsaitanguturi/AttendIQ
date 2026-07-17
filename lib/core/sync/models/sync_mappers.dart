import '../../../../features/auth/data/models/semester_local.dart';
import '../../../../features/subject/data/models/subject_local.dart';
import '../../../../features/timetable/data/models/timetable_template_local.dart';
import '../../event_generator/data/models/event_local.dart';
import '../../../../features/attendance/data/models/attendance_record_local.dart';

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
      ..id = map['id'] ?? 0
      ..serverId = map['serverId']
      ..name = map['name']
      ..startDate = DateTime.parse(map['startDate']).toUtc()
      ..endDate = DateTime.parse(map['endDate']).toUtc()
      ..requiredAttendanceRate = (map['requiredAttendanceRate'] as num).toDouble()
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt']).toUtc()
      ..isDirty = map['isDirty'] ?? false
      ..isDeleted = map['isDeleted'] ?? false;
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
      ..id = map['id'] ?? 0
      ..serverId = map['serverId']
      ..semesterId = map['semesterId'] ?? 0
      ..name = map['name']
      ..code = map['code']
      ..faculty = map['faculty']
      ..credits = map['credits'] ?? 0
      ..attendanceTarget = (map['attendanceTarget'] as num).toDouble()
      ..color = map['color']
      ..type = map['type']
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt']).toUtc()
      ..isDirty = map['isDirty'] ?? false
      ..isDeleted = map['isDeleted'] ?? false;
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
      ..id = map['id'] ?? 0
      ..serverId = map['serverId']
      ..subjectId = map['subjectId'] ?? 0
      ..weekday = map['weekday'] ?? 1
      ..startTime = map['startTime']
      ..endTime = map['endTime']
      ..room = map['room']
      ..faculty = map['faculty']
      ..notes = map['notes']
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt']).toUtc()
      ..isDirty = map['isDirty'] ?? false
      ..isDeleted = map['isDeleted'] ?? false;
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
      ..id = map['id'] ?? 0
      ..serverId = map['serverId']
      ..subjectId = map['subjectId'] ?? 0
      ..date = DateTime.parse(map['date']).toUtc()
      ..startTime = map['startTime']
      ..endTime = map['endTime']
      ..eventType = map['eventType']
      ..status = map['status']
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt']).toUtc()
      ..isDirty = map['isDirty'] ?? false
      ..isDeleted = map['isDeleted'] ?? false;
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
      ..id = map['id'] ?? 0
      ..serverId = map['serverId']
      ..eventId = map['eventId'] ?? 0
      ..subjectId = map['subjectId'] ?? 0
      ..status = map['status']
      ..markedAt = DateTime.parse(map['markedAt']).toUtc()
      ..createdAt = map['createdAt'] != null
          ? DateTime.parse(map['createdAt']).toUtc()
          : DateTime.now().toUtc()
      ..updatedAt = DateTime.parse(map['updatedAt']).toUtc()
      ..isDirty = map['isDirty'] ?? false
      ..isDeleted = map['isDeleted'] ?? false;
  }
}
