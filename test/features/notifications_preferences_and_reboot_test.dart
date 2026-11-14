import 'dart:io';
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

class _FakeNotificationDatabase implements NotificationDatabase {
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
    DateTime start,
    DateTime end,
  ) async {
    return occurrences.where((o) {
      final dateStripped = DateTime.utc(o.date.year, o.date.month, o.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<WeeklyScheduleRuleLocal>> getWeeklyRules() async => weeklyRules;

  @override
  Future<List<ScheduleExceptionLocal>> getScheduleExceptions(
    DateTime start,
    DateTime end,
  ) async {
    return scheduleExceptions.where((e) {
      final dateStripped = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<AcademicEventLocal>> getAcademicEvents(
    DateTime start,
    DateTime end,
  ) async {
    return academicEvents.where((e) {
      final dateStripped = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<SubjectLocal>> getSubjects() async => subjects;

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(
    int subjectId,
  ) async {
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
    String type,
    DateTime now,
  ) async {
    return notifications
        .where((n) => n.type == type && n.scheduledTime.isAfter(now))
        .toList();
  }

  @override
  Future<NotificationItem?> getLastNotification(
    String type,
    String relatedId,
  ) async {
    final list = notifications
        .where((n) => n.type == type && n.relatedId == relatedId)
        .toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    return list.first;
  }

  @override
  Future<int> saveNotification(NotificationItem item) async {
    if (item.id == 0) {
      item.id = _nextNotificationId++;
      notifications.add(item);
    } else {
      final idx = notifications.indexWhere((n) => n.id == item.id);
      if (idx != -1) {
        notifications[idx] = item;
      } else {
        notifications.add(item);
      }
    }
    return item.id;
  }

  @override
  Future<void> deleteNotification(int id) async {
    notifications.removeWhere((n) => n.id == id);
  }

  Future<void> cleanupOldNotifications(DateTime threshold) async {
    notifications.removeWhere((n) => n.scheduledTime.isBefore(threshold));
  }
}

class _FakeNotificationService implements NotificationService {
  final List<int> cancelledNotificationIds = [];
  final List<NotificationItem> scheduledNotifications = [];

  @override
  Future<void> cancelNotification(int id) async {
    cancelledNotificationIds.add(id);
    scheduledNotifications.removeWhere((n) => n.id == id);
  }

  Future<void> cancelNotificationsForEvent(int eventId) async {}

  Future<void> cancelNotificationsForOccurrence(int occurrenceId) async {}

  @override
  Future<void> scheduleNotification(NotificationItem item) async {
    scheduledNotifications.add(item);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  UserPreferencesLocal createTestPrefs({
    bool enableNotifications = true,
    int classReminderOffset = 15,
    bool enableAttendanceWarnings = true,
    bool weeklyReportEnabled = true,
  }) {
    return UserPreferencesLocal()
      ..themeMode = 'system'
      ..defaultAttendanceTarget = 75.0
      ..classReminderOffset = classReminderOffset
      ..enableNotifications = enableNotifications
      ..enableAttendanceWarnings = enableAttendanceWarnings
      ..weeklyReportEnabled = weeklyReportEnabled
      ..updatedAt = DateTime.now();
  }

  group('Group C: Notification Reliability & Preferences', () {
    late _FakeNotificationDatabase db;
    late _FakeNotificationService service;
    late NotificationScheduler scheduler;

    setUp(() {
      db = _FakeNotificationDatabase();
      service = _FakeNotificationService();
      scheduler = NotificationScheduler(
        db,
        service,
      );

      // Seed active semester
      db.activeSemester = SemesterLocal()
        ..id = 1
        ..name = 'Fall 2026'
        ..startDate = DateTime.utc(2026, 8, 1)
        ..endDate = DateTime.utc(2026, 12, 31)
        ..requiredAttendanceRate = 75.0
        ..isActive = true;

      // Seed subject
      db.subjects.add(
        SubjectLocal()
          ..id = 10
          ..semesterId = 1
          ..name = 'Data Structures'
          ..code = 'CS201'
          ..type = 'THEORY'
          ..credits = 4
          ..attendanceTarget = 75.0
          ..color = '#2563EB'
          ..isDeleted = false
          ..updatedAt = DateTime.utc(2026, 8, 1),
      );
    });

    tearDown(() {
      scheduler.dispose();
    });

    test(
        'BUG-013 & NEW-BUG-09: enableNotifications = false cancels all future notifications and stops scheduling',
        () async {
      final now = DateTime(2026, 11, 16, 8, 0);

      // Seed existing future notification
      final futureItem = NotificationItem()
        ..id = 101
        ..title = 'Class Reminder'
        ..body = 'Data Structures in 15 mins'
        ..type = NotificationType.classReminder.toShortString()
        ..scheduledTime = now.add(const Duration(hours: 1))
        ..relatedId = 'occ_1'
        ..isRead = false;
      db.notifications.add(futureItem);

      // Set user preference to disable all notifications
      db.userPreferences = createTestPrefs(enableNotifications: false);

      await scheduler.rescheduleAll(customNow: now);

      // Should have called cancelNotification on service and deleted from db
      expect(
        service.cancelledNotificationIds,
        contains(futureItem.effectiveAndroidNotificationId),
      );
      expect(db.notifications, isEmpty);
      expect(service.scheduledNotifications, isEmpty);
    });

    test(
        'BUG-013: Uses classReminderOffset preference instead of hardcoded 15 minutes',
        () async {
      final now = DateTime(2026, 11, 16, 8, 0); // Monday

      // Class is at 10:00 AM on Monday Nov 16
      final rule = WeeklyScheduleRuleLocal()
        ..id = 1
        ..subjectId = 10
        ..dayOfWeek = 1
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..isActive = true;
      db.weeklyRules.add(rule);

      // Preference sets reminder to 30 minutes before class
      db.userPreferences = createTestPrefs(
        enableNotifications: true,
        classReminderOffset: 30,
      );

      await scheduler.rescheduleAll(customNow: now);

      // Should have scheduled a reminder at 09:30 AM (30 min before 10:00 AM)
      final reminder = db.notifications.firstWhere(
        (n) => n.type == NotificationType.classReminder.toShortString(),
      );
      expect(reminder.scheduledTime, DateTime(2026, 11, 16, 9, 30));
    });

    test(
        'BUG-013: checkAttendanceRisks schedules alert strictly in the future, never in past',
        () async {
      final now = DateTime(2026, 11, 16, 10, 0);

      // Add low attendance records (0% attended)
      db.attendanceRecords.add(
        AttendanceRecordLocal()
          ..id = 1
          ..subjectId = 10
          ..eventId = 101
          ..occurrenceId = 101
          ..status = 'ABSENT'
          ..markedAt = now.subtract(const Duration(hours: 2))
          ..updatedAt = now.subtract(const Duration(hours: 2)),
      );

      db.userPreferences = createTestPrefs(
        enableNotifications: true,
        enableAttendanceWarnings: true,
      );

      await scheduler.checkAttendanceRisks(customNow: now);

      // Check scheduled warning item
      final riskNotifications = db.notifications
          .where(
            (n) =>
                n.type == NotificationType.attendanceWarning.toShortString() ||
                n.type == NotificationType.lowAttendanceAlert.toShortString(),
          )
          .toList();

      expect(riskNotifications.isNotEmpty, isTrue);
      final warning = riskNotifications.first;
      expect(warning.scheduledTime.isAfter(now), isTrue);
      expect(
        warning.scheduledTime.difference(now).inSeconds,
        greaterThanOrEqualTo(4),
      );
    });

    test(
        'NEW-BUG-09: Toggling enableAttendanceWarnings to false cancels pending warnings',
        () async {
      final now = DateTime(2026, 11, 16, 8, 0);

      // Existing scheduled attendance warning
      final warningItem = NotificationItem()
        ..id = 201
        ..title = 'Attendance Warning'
        ..body = 'Attendance dropped below 75%'
        ..type = NotificationType.attendanceWarning.toShortString()
        ..scheduledTime = now.add(const Duration(hours: 2))
        ..relatedId = 'risk_10'
        ..isRead = false;
      db.notifications.add(warningItem);

      // Disable attendance warnings in user preferences
      db.userPreferences = createTestPrefs(
        enableNotifications: true,
        enableAttendanceWarnings: false,
      );

      await scheduler.rescheduleAll(customNow: now);

      // Warning should be cancelled and removed from DB
      expect(
        service.cancelledNotificationIds,
        contains(warningItem.effectiveAndroidNotificationId),
      );
      expect(db.notifications.any((n) => n.id == 201), isFalse);
    });

    test(
        'NEW-BUG-09: Toggling weeklyReportEnabled to false cancels pending weekly reports',
        () async {
      final now = DateTime(2026, 11, 16, 8, 0);

      // Existing scheduled weekly report
      final reportItem = NotificationItem()
        ..id = 301
        ..title = 'Weekly Summary'
        ..body = 'Here is your weekly summary'
        ..type = NotificationType.weeklyReport.toShortString()
        ..scheduledTime = now.add(const Duration(days: 6))
        ..relatedId = 'weekly_report'
        ..isRead = false;
      db.notifications.add(reportItem);

      // Disable weekly reports in user preferences
      db.userPreferences = createTestPrefs(
        enableNotifications: true,
        weeklyReportEnabled: false,
      );

      await scheduler.rescheduleAll(customNow: now);

      // Weekly report should be cancelled and removed from DB
      expect(
        service.cancelledNotificationIds,
        contains(reportItem.effectiveAndroidNotificationId),
      );
      expect(db.notifications.any((n) => n.id == 301), isFalse);
    });

    test(
        'BUG-014: AndroidManifest.xml registers RECEIVE_BOOT_COMPLETED and ScheduledNotificationBootReceiver',
        () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue);

      final manifestContent = manifestFile.readAsStringSync();
      expect(
        manifestContent.contains('android.permission.RECEIVE_BOOT_COMPLETED'),
        isTrue,
        reason:
            'RECEIVE_BOOT_COMPLETED permission must be declared in AndroidManifest.xml',
      );
      expect(
        manifestContent.contains('ScheduledNotificationBootReceiver'),
        isTrue,
        reason:
            'ScheduledNotificationBootReceiver must be registered in AndroidManifest.xml',
      );
      expect(
        manifestContent.contains('android.intent.action.BOOT_COMPLETED'),
        isTrue,
        reason:
            'BOOT_COMPLETED action intent-filter must be present on boot receiver',
      );
    });
  });
}
