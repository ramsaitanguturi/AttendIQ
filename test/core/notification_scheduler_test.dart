import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_scheduler.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/schedule_exception_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/models/academic_event_local.dart';
import 'package:attend_iq/features/settings/data/models/user_preferences_local.dart';
import 'package:attend_iq/features/timetable/data/utils/occurrence_identity.dart';

class MockNotificationDatabase implements NotificationDatabase {
  final List<DailyScheduleOccurrenceLocal> occurrences = [];
  final List<WeeklyScheduleRuleLocal> weeklyRules = [];
  final List<ScheduleExceptionLocal> scheduleExceptions = [];
  final List<AcademicEventLocal> academicEvents = [];
  final List<SubjectLocal> subjects = [];
  final List<AttendanceRecordLocal> attendanceRecords = [];
  final List<NotificationItem> notifications = [];
  SemesterLocal? activeSemester;
  UserPreferencesLocal? userPreferences;

  int _nextNotificationId = 1;

  @override
  Future<UserPreferencesLocal?> getUserPreferences() async => userPreferences;

  @override
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrences(
      DateTime start, DateTime end) async {
    return occurrences.where((o) {
      final dateStripped = DateTime.utc(o.date.year, o.date.month, o.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<WeeklyScheduleRuleLocal>> getWeeklyRules() async => weeklyRules;

  @override
  Future<List<ScheduleExceptionLocal>> getScheduleExceptions(
      DateTime start, DateTime end) async {
    return scheduleExceptions.where((e) {
      final dateStripped = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<AcademicEventLocal>> getAcademicEvents(
      DateTime start, DateTime end) async {
    return academicEvents.where((e) {
      final dateStripped = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<SubjectLocal>> getSubjects() async => subjects;

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(
      int subjectId) async {
    return attendanceRecords.where((r) => r.subjectId == subjectId).toList();
  }

  @override
  Future<List<AttendanceRecordLocal>> getAllAttendanceRecords() async =>
      attendanceRecords;

  @override
  Future<SemesterLocal?> getActiveSemester() async => activeSemester;

  @override
  Future<List<NotificationItem>> getFutureNotifications(DateTime now) async {
    return notifications.where((n) => n.scheduledTime.isAfter(now)).toList();
  }

  @override
  Future<List<NotificationItem>> getFutureNotificationsByType(
      String type, DateTime now) async {
    return notifications
        .where((n) => n.type == type && n.scheduledTime.isAfter(now))
        .toList();
  }

  @override
  Future<NotificationItem?> getLastNotification(
      String type, String relatedId) async {
    final list = notifications
        .where((n) => n.type == type && n.relatedId == relatedId)
        .toList();
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
    if (item.id <= 0) {
      item.id = _nextNotificationId++;
    } else {
      notifications.removeWhere((n) => n.id == item.id);
    }
    item.androidNotificationId ??=
        NotificationItem.deriveAndroidNotificationId(item.id);
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
    scheduled.removeWhere((item) => item.effectiveAndroidNotificationId == id);
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
    test('rescheduleRollingWindow schedules class reminders correctly',
        () async {
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

      // Insert canonical weekly rules
      final ruleFri = WeeklyScheduleRuleLocal()
        ..id = 50
        ..subjectId = 1
        ..dayOfWeek = 5 // Friday
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..room = 'Room 302'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.weeklyRules.add(ruleFri);

      final ruleSat = WeeklyScheduleRuleLocal()
        ..id = 51
        ..subjectId = 1
        ..dayOfWeek = 6 // Saturday
        ..startTime = '14:00'
        ..endTime = '15:00'
        ..room = 'Room 303'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.weeklyRules.add(ruleSat);

      // Insert canonical occurrences (one starting at 10:00 AM today, one starting at 2:00 PM tomorrow, one cancelled)
      final occ1 = DailyScheduleOccurrenceLocal()
        ..id = 101
        ..subjectId = 1
        ..ruleId = 50
        ..date = DateTime.utc(2026, 7, 17)
        ..title = 'Operating Systems'
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      occ1.slotKey = computeSlotKeyForLocal(occ1);
      mockDb.occurrences.add(occ1);

      final occ2 = DailyScheduleOccurrenceLocal()
        ..id = 102
        ..subjectId = 1
        ..ruleId = 51
        ..date = DateTime.utc(2026, 7, 18)
        ..title = 'Operating Systems'
        ..startTime = '14:00'
        ..endTime = '15:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      occ2.slotKey = computeSlotKeyForLocal(occ2);
      mockDb.occurrences.add(occ2);

      final occCancelled = DailyScheduleOccurrenceLocal()
        ..id = 103
        ..subjectId = 1
        ..date = DateTime.utc(2026, 7, 17)
        ..title = 'Operating Systems'
        ..startTime = '12:00'
        ..endTime = '13:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'CANCELLED'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      occCancelled.slotKey = computeSlotKeyForLocal(occCancelled);
      mockDb.occurrences.add(occCancelled);

      // Run rolling scheduler
      await scheduler
          .rescheduleRollingWindow(offsets: [15, 30], customNow: now);

      // Verify that reminders were scheduled:
      // occ 1 (starts 10:00 AM today): 9:45 AM, 9:30 AM
      // occ 2 (starts 2:00 PM tomorrow): 1:45 PM tomorrow, 1:30 PM tomorrow
      // occCancelled: should not be scheduled at all!

      final scheduledNotifs = mockDb.notifications;
      expect(scheduledNotifs.length, 4);

      final types = scheduledNotifs.map((n) => n.type).toSet();
      expect(types, {NotificationType.CLASS_REMINDER.toShortString()});

      // Verify mock service schedules them
      expect(mockService.scheduled.length, 4);

      // Verify body text includes room info and namespaced slotKey relatedId
      final expectedKey1 = NotificationRelatedKeys.forSlotKey(occ1.slotKey!);
      final testReminder = mockService.scheduled.firstWhere(
          (n) => n.relatedId == expectedKey1 && n.body.contains('Room 302'));
      expect(testReminder, isNotNull);

      // Try running scheduler again: should not schedule duplicates or double-register
      await scheduler
          .rescheduleRollingWindow(offsets: [15, 30], customNow: now);
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
      expect(warnings.first.type,
          NotificationType.LOW_ATTENDANCE_ALERT.toShortString());
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

      // Schedule Occurrence
      final occ = DailyScheduleOccurrenceLocal()
        ..id = 301
        ..subjectId = 1
        ..date = DateTime.utc(2026, 7, 15)
        ..title = 'Operating Systems'
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'PRESENT'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;
      mockDb.occurrences.add(occ);

      // Run weekly report scheduler
      await scheduler.scheduleWeeklyReport(customNow: now);

      final reports = mockDb.notifications
          .where(
              (n) => n.type == NotificationType.WEEKLY_REPORT.toShortString())
          .toList();

      expect(reports.length, 1);
      expect(reports.first.title, 'Weekly Attendance Digest');
      expect(reports.first.body, contains('Overall: 100.0%'));
      expect(reports.first.body, contains('Best: Operating Systems'));

      // Check scheduled date is the upcoming Sunday (July 19, 2026) at 6:00 PM
      final expectedSunday = DateTime(2026, 7, 19, 18, 0);
      expect(reports.first.scheduledTime, expectedSunday);
    });

    test(
        'rescheduleRollingWindow deduplicates repeated offsets and cancels exact Android ID on occurrence cancellation',
        () async {
      final now = DateTime(2026, 7, 17, 9, 0);
      mockDb.subjects.add(
        SubjectLocal()
          ..id = 1
          ..semesterId = 1
          ..name = 'Algorithms'
          ..code = 'CS301'
          ..credits = 4
          ..attendanceTarget = 75.0
          ..color = '#2563EB'
          ..type = 'THEORY'
          ..createdAt = now
          ..updatedAt = now,
      );

      final occ1 = DailyScheduleOccurrenceLocal()
        ..id = 201
        ..subjectId = 1
        ..date = DateTime.utc(2026, 7, 17)
        ..title = 'Algorithms'
        ..startTime = '11:00'
        ..endTime = '12:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = now
        ..updatedAt = now;
      occ1.slotKey = computeSlotKeyForLocal(occ1);

      final occ2 = DailyScheduleOccurrenceLocal()
        ..id = 202
        ..subjectId = 1
        ..date = DateTime.utc(2026, 7, 17)
        ..title = 'Algorithms'
        ..startTime = '15:00'
        ..endTime = '16:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = now
        ..updatedAt = now;
      occ2.slotKey = computeSlotKeyForLocal(occ2);
      mockDb.occurrences.addAll([occ1, occ2]);

      await scheduler.rescheduleRollingWindow(
        offsets: [15, 15],
        customNow: now,
      );

      expect(mockDb.notifications, hasLength(2));
      expect(mockService.scheduled, hasLength(2));
      expect(
        mockDb.notifications.map((n) => n.id).toSet(),
        hasLength(2),
      );
      expect(
        mockDb.notifications
            .map((n) => n.effectiveAndroidNotificationId)
            .toSet(),
        hasLength(2),
      );

      // Cancel occ1 and verify only occ1's Android ID is cancelled.
      final key1 = NotificationRelatedKeys.forSlotKey(occ1.slotKey!);
      final key2 = NotificationRelatedKeys.forSlotKey(occ2.slotKey!);
      final occ1Notif =
          mockDb.notifications.firstWhere((n) => n.relatedId == key1);
      final occ2Notif =
          mockDb.notifications.firstWhere((n) => n.relatedId == key2);
      occ1.status = 'CANCELLED';

      await scheduler.rescheduleRollingWindow(
        offsets: [15],
        customNow: now,
      );

      expect(
        mockService.cancelled,
        equals([occ1Notif.effectiveAndroidNotificationId]),
      );
      expect(mockDb.notifications.map((n) => n.id), equals([occ2Notif.id]));
      expect(mockService.scheduled.map((n) => n.id), equals([occ2Notif.id]));
    });
  });
}
