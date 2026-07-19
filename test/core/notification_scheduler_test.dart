import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_scheduler.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/core/event_generator/data/models/event_local.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/timetable/data/models/academic_event_local.dart';

class MockNotificationDatabase implements NotificationDatabase {
  final List<EventLocal> events = [];
  final List<AcademicEventLocal> academicEvents = [];
  final List<SubjectLocal> subjects = [];
  final List<TimetableTemplateLocal> templates = [];
  final List<AttendanceRecordLocal> attendanceRecords = [];
  final List<NotificationItem> notifications = [];
  SemesterLocal? activeSemester;

  int _nextNotificationId = 1;

  @override
  Future<List<EventLocal>> getEvents(DateTime start, DateTime end) async {
    // start and end are typically stripped UTC dates for our queries
    return events.where((e) {
      final dateStripped = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<AcademicEventLocal>> getAcademicEvents(DateTime start, DateTime end) async {
    return academicEvents.where((e) {
      final dateStripped = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<SubjectLocal>> getSubjects() async => subjects;

  @override
  Future<List<TimetableTemplateLocal>> getTemplates() async => templates;

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(int subjectId) async {
    return attendanceRecords.where((r) => r.subjectId == subjectId).toList();
  }

  @override
  Future<List<AttendanceRecordLocal>> getAllAttendanceRecords() async => attendanceRecords;

  @override
  Future<SemesterLocal?> getActiveSemester() async => activeSemester;

  @override
  Future<List<NotificationItem>> getFutureNotifications(DateTime now) async {
    return notifications.where((n) => n.scheduledTime.isAfter(now)).toList();
  }

  @override
  Future<List<NotificationItem>> getFutureNotificationsByType(String type, DateTime now) async {
    return notifications.where((n) => n.type == type && n.scheduledTime.isAfter(now)).toList();
  }

  @override
  Future<NotificationItem?> getLastNotification(String type, String relatedId) async {
    final list = notifications.where((n) => n.type == type && n.relatedId == relatedId).toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    return list.first;
  }

  @override
  Future<void> deleteNotification(int id) async {
    notifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> saveNotification(NotificationItem item) async {
    if (item.id == 0) {
      item.id = _nextNotificationId++;
    } else {
      notifications.removeWhere((n) => n.id == item.id);
    }
    notifications.add(item);
  }
}

class MockNotificationService implements NotificationService {
  final List<NotificationItem> scheduled = [];
  final List<int> cancelled = [];
  bool allCancelled = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleNotification(NotificationItem item) async {
    scheduled.add(item);
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
    scheduled.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    allCancelled = true;
    scheduled.clear();
  }
}

void main() {
  late MockNotificationDatabase mockDb;
  late MockNotificationService mockService;
  late NotificationScheduler scheduler;

  setUp(() {
    mockDb = MockNotificationDatabase();
    mockService = MockNotificationService();
    scheduler = NotificationScheduler(mockDb, mockService);
  });

  group('NotificationScheduler Tests', () {
    test('rescheduleRollingWindow schedules class reminders correctly', () async {
      final now = DateTime(2026, 7, 17, 9, 0); // Friday 9:00 AM

      // Insert Semester
      mockDb.activeSemester = SemesterLocal()
        ..id = 1
        ..name = 'Fall 2026'
        ..startDate = DateTime(2026, 7, 1)
        ..endDate = DateTime(2026, 12, 31)
        ..requiredAttendanceRate = 75.0
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;

      // Insert Subject
      final subject = SubjectLocal()
        ..id = 1
        ..semesterId = 1
        ..name = 'Operating Systems'
        ..code = 'CS401'
        ..credits = 4
        ..attendanceTarget = 75.0
        ..color = '#FF5733'
        ..type = 'THEORY'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.subjects.add(subject);

      // Insert templates
      final template = TimetableTemplateLocal()
        ..id = 50
        ..subjectId = 1
        ..weekday = 5 // Friday
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..room = 'Room 302'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.templates.add(template);

      final templateSaturday = TimetableTemplateLocal()
        ..id = 51
        ..subjectId = 1
        ..weekday = 6 // Saturday
        ..startTime = '14:00'
        ..endTime = '15:00'
        ..room = 'Room 303'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.templates.add(templateSaturday);

      // Insert Events (one starting at 10:00 AM today, one starting at 2:00 PM tomorrow, one cancelled)
      final event1 = EventLocal()
        ..id = 101
        ..subjectId = 1
        ..date = DateTime.utc(2026, 7, 17)
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..eventType = 'REGULAR_CLASS'
        ..status = 'UNMARKED'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.events.add(event1);

      final event2 = EventLocal()
        ..id = 102
        ..subjectId = 1
        ..date = DateTime.utc(2026, 7, 18)
        ..startTime = '14:00'
        ..endTime = '15:00'
        ..eventType = 'REGULAR_CLASS'
        ..status = 'UNMARKED'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.events.add(event2);

      final eventCancelled = EventLocal()
        ..id = 103
        ..subjectId = 1
        ..date = DateTime.utc(2026, 7, 17)
        ..startTime = '12:00'
        ..endTime = '13:00'
        ..eventType = 'REGULAR_CLASS'
        ..status = 'CANCELLED'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.events.add(eventCancelled);

      // Run rolling scheduler
      await scheduler.rescheduleRollingWindow(offsets: [15, 30], customNow: now);

      // Verify that reminders were scheduled:
      // event 1 (starts 10:00 AM today):
      // - 15 mins before: 9:45 AM (future, should schedule)
      // - 30 mins before: 9:30 AM (future, should schedule)
      // event 2 (starts 2:00 PM tomorrow):
      // - 15 mins before: 1:45 PM tomorrow (future, should schedule)
      // - 30 mins before: 1:30 PM tomorrow (future, should schedule)
      // eventCancelled: should not be scheduled at all!

      final scheduledNotifs = mockDb.notifications;
      expect(scheduledNotifs.length, 4);

      final types = scheduledNotifs.map((n) => n.type).toSet();
      expect(types, {NotificationType.CLASS_REMINDER.toShortString()});

      // Verify mock service schedules them
      expect(mockService.scheduled.length, 4);

      // Verify body text includes room info
      final testReminder = mockService.scheduled.firstWhere((n) => n.relatedId == '101' && n.body.contains('Room 302'));
      expect(testReminder, isNotNull);

      // Try running scheduler again: should not schedule duplicates or double-register
      await scheduler.rescheduleRollingWindow(offsets: [15, 30], customNow: now);
      expect(mockDb.notifications.length, 4);
      expect(mockService.scheduled.length, 4);
    });

    test('checkAttendanceRisks schedules warning alerts correctly', () async {
      final now = DateTime(2026, 7, 17, 17, 0);

      // Insert Semester
      mockDb.activeSemester = SemesterLocal()
        ..id = 1
        ..name = 'Fall 2026'
        ..startDate = DateTime(2026, 7, 1)
        ..endDate = DateTime(2026, 12, 31)
        ..requiredAttendanceRate = 75.0
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;

      // Insert Subject
      final subject = SubjectLocal()
        ..id = 1
        ..semesterId = 1
        ..name = 'Database Management Systems'
        ..code = 'CS302'
        ..credits = 3
        ..attendanceTarget = 75.0
        ..color = '#33FF57'
        ..type = 'THEORY'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.subjects.add(subject);

      // Insert Attendance Record (e.g. 1 present, 1 absent -> 50% attendance)
      final rec1 = AttendanceRecordLocal()
        ..id = 1
        ..eventId = 201
        ..subjectId = 1
        ..status = 'PRESENT'
        ..markedAt = DateTime(2026, 7, 10, 10, 0)
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.attendanceRecords.add(rec1);

      final rec2 = AttendanceRecordLocal()
        ..id = 2
        ..eventId = 202
        ..subjectId = 1
        ..status = 'ABSENT'
        ..markedAt = DateTime(2026, 7, 17, 10, 0)
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.attendanceRecords.add(rec2);

      // Run risk checker
      await scheduler.checkAttendanceRisks(customNow: now);

      // Since rate is 50% (target 75%), a LOW_ATTENDANCE_ALERT should be triggered
      final warnings = mockDb.notifications;
      expect(warnings.length, 1);
      expect(warnings.first.type, NotificationType.LOW_ATTENDANCE_ALERT.toShortString());
      expect(warnings.first.title, contains('Low Attendance Alert'));
      expect(warnings.first.body, contains('Database Management Systems'));

      // If we run it again without new records, it should NOT trigger duplicate warning
      await scheduler.checkAttendanceRisks(customNow: now);
      expect(mockDb.notifications.length, 1);
    });

    test('scheduleWeeklyReport generates weekly report correctly', () async {
      final now = DateTime(2026, 7, 17, 9, 0); // Friday

      // Insert Semester
      mockDb.activeSemester = SemesterLocal()
        ..id = 1
        ..name = 'Fall 2026'
        ..startDate = DateTime(2026, 7, 1)
        ..endDate = DateTime(2026, 12, 31)
        ..requiredAttendanceRate = 75.0
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;

      // Insert Subject
      final subject = SubjectLocal()
        ..id = 1
        ..semesterId = 1
        ..name = 'Operating Systems'
        ..code = 'CS401'
        ..credits = 4
        ..attendanceTarget = 75.0
        ..color = '#FF5733'
        ..type = 'THEORY'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.subjects.add(subject);

      // Log 1 present record
      final rec = AttendanceRecordLocal()
        ..id = 1
        ..eventId = 301
        ..subjectId = 1
        ..status = 'PRESENT'
        ..markedAt = DateTime(2026, 7, 15, 10, 0)
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.attendanceRecords.add(rec);

      // Schedule Event
      final event = EventLocal()
        ..id = 301
        ..subjectId = 1
        ..date = DateTime.utc(2026, 7, 15)
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..eventType = 'REGULAR_CLASS'
        ..status = 'PRESENT'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.events.add(event);

      // Run weekly report scheduler
      await scheduler.scheduleWeeklyReport(customNow: now);

      final reports = mockDb.notifications
          .where((n) => n.type == NotificationType.WEEKLY_REPORT.toShortString())
          .toList();

      expect(reports.length, 1);
      expect(reports.first.title, 'Weekly Attendance Digest');
      expect(reports.first.body, contains('Overall: 100.0%'));
      expect(reports.first.body, contains('Best: Operating Systems'));

      // Check scheduled date is the upcoming Sunday (July 19, 2026) at 6:00 PM
      final expectedSunday = DateTime(2026, 7, 19, 18, 0);
      expect(reports.first.scheduledTime, expectedSunday);
    });
  });
}
