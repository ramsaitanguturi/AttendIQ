import 'package:isar/isar.dart';
import '../../event_generator/data/models/event_local.dart';
import '../../../features/auth/data/models/semester_local.dart';
import '../../../features/subject/data/models/subject_local.dart';
import '../../../features/attendance/data/models/attendance_record_local.dart';
import '../../../features/timetable/data/models/timetable_template_local.dart';
import '../models/notification_item.dart';

abstract class NotificationDatabase {
  Future<List<EventLocal>> getEvents(DateTime start, DateTime end);
  Future<List<SubjectLocal>> getSubjects();
  Future<List<TimetableTemplateLocal>> getTemplates();
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(int subjectId);
  Future<List<AttendanceRecordLocal>> getAllAttendanceRecords();
  Future<SemesterLocal?> getActiveSemester();

  Future<List<NotificationItem>> getFutureNotifications(DateTime now);
  Future<List<NotificationItem>> getFutureNotificationsByType(String type, DateTime now);
  Future<NotificationItem?> getLastNotification(String type, String relatedId);

  Future<void> deleteNotification(int id);
  Future<void> saveNotification(NotificationItem item);
}

class IsarNotificationDatabaseImpl implements NotificationDatabase {
  final Isar _isar;

  IsarNotificationDatabaseImpl(this._isar);

  @override
  Future<List<EventLocal>> getEvents(DateTime start, DateTime end) async {
    return _isar.eventLocals
        .where()
        .dateBetween(start, end)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<SubjectLocal>> getSubjects() async {
    return _isar.subjectLocals.where().isDeletedEqualTo(false).findAll();
  }

  @override
  Future<List<TimetableTemplateLocal>> getTemplates() async {
    return _isar.timetableTemplateLocals.where().isDeletedEqualTo(false).findAll();
  }

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(int subjectId) async {
    return _isar.attendanceRecordLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<AttendanceRecordLocal>> getAllAttendanceRecords() async {
    return _isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
  }

  @override
  Future<SemesterLocal?> getActiveSemester() async {
    return _isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
  }

  @override
  Future<List<NotificationItem>> getFutureNotifications(DateTime now) async {
    return _isar.notificationItems
        .where()
        .scheduledTimeGreaterThan(now)
        .findAll();
  }

  @override
  Future<List<NotificationItem>> getFutureNotificationsByType(String type, DateTime now) async {
    return _isar.notificationItems
        .where()
        .typeEqualTo(type)
        .scheduledTimeGreaterThan(now)
        .findAll();
  }

  @override
  Future<NotificationItem?> getLastNotification(String type, String relatedId) async {
    return _isar.notificationItems
        .where()
        .typeEqualTo(type)
        .relatedIdEqualTo(relatedId)
        .sortByScheduledTimeDesc()
        .findFirst();
  }

  @override
  Future<void> deleteNotification(int id) async {
    await _isar.writeAsync((isar) => isar.notificationItems.delete(id));
  }

  @override
  Future<void> saveNotification(NotificationItem item) async {
    await _isar.writeAsync((isar) {
      isar.notificationItems.put(item);
    });
  }
}
