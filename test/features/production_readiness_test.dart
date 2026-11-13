import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

// App imports
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/core/ai/services/local_advisor_service.dart';
import 'package:attend_iq/core/ai/context/attendance_ai_context.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_scheduler.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/features/settings/data/models/user_preferences_local.dart';
import '../test_helpers/test_isar_helper.dart';

class FakeNotificationService implements NotificationService {
  bool shouldThrow = false;
  final List<NotificationItem> scheduledItems = [];

  @override
  Future<void> scheduleNotification(NotificationItem item) async {
    if (shouldThrow) throw Exception('Notification platform channel failed');
    scheduledItems.add(item);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  group('Production Readiness - AI Fallback Heuristics', () {
    test(
        'LocalAdvisorService fallback generates mathematically correct suggestions when offline',
        () async {
      const localAdvisor = LocalAdvisorService();
      const context = AttendanceAIContext(
        studentInfo: {},
        semester: {},
        attendanceSummary: {},
        recentTrends: {},
        attendanceTarget: 75.0,
        subjectStatistics: [
          {
            'id': 1,
            'name': 'Math',
            'present': 10,
            'total': 15,
            'attendanceTarget': 75.0,
            'safeBunks': 0,
            'mustAttendConsecutive': 5,
            'currentPercentage': 66.7,
          }
        ],
        upcomingClasses: [
          {
            'subjectId': 1,
            'subjectName': 'Math',
            'day': 'Tomorrow',
          }
        ],
        riskSubjects: [
          {
            'name': 'Math',
            'status': 'Critical',
            'currentPercentage': 66.7,
            'mustAttendConsecutive': 5,
          }
        ],
      );

      final response = await localAdvisor.askQuestion(
        context: context,
        question: 'Can I skip tomorrow\'s classes?',
      );

      expect(response.confidence, 1.0);
      expect(response.answer,
          contains('No, you should not skip tomorrow\'s classes.'));
      expect(response.relatedSubjects, contains('Math'));
      expect(response.actionItems.first, contains('Attend Math'));
    });
  });

  group('Production Readiness - Notification Failures (Real Isar Database)',
      () {
    late TestIsarInstance testDb;
    late IsarNotificationDatabaseImpl notificationDb;
    late FakeNotificationService mockService;
    late NotificationScheduler scheduler;

    setUp(() {
      testDb = openTestIsar(prefix: 'prod_notif');
      notificationDb = IsarNotificationDatabaseImpl(testDb.isar);
      mockService = FakeNotificationService();
      scheduler = NotificationScheduler(notificationDb, mockService);

      testDb.isar.write((isar) {
        isar.semesterLocals.put(
          SemesterLocal()
            ..id = 1
            ..name = 'Spring 2026'
            ..startDate = DateTime.now().subtract(const Duration(days: 30))
            ..endDate = DateTime.now().add(const Duration(days: 60))
            ..requiredAttendanceRate = 75.0
            ..isActive = true
            ..status = 'active'
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        );
        isar.userPreferencesLocals.put(
          UserPreferencesLocal()
            ..themeMode = 'system'
            ..defaultAttendanceTarget = 75.0
            ..classReminderOffset = 15
            ..enableNotifications = true
            ..enableAttendanceWarnings = true
            ..weeklyReportEnabled = true
            ..updatedAt = DateTime.now(),
        );
        isar.subjectLocals.put(
          SubjectLocal()
            ..id = 1
            ..semesterId = 1
            ..name = 'Operating Systems'
            ..code = 'CS301'
            ..credits = 4
            ..attendanceTarget = 75.0
            ..color = '#FF0000'
            ..type = 'THEORY'
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        );
        isar.attendanceRecordLocals.put(
          AttendanceRecordLocal()
            ..eventId = 1
            ..subjectId = 1
            ..status = 'ABSENT'
            ..markedAt = DateTime.now()
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now(),
        );
      });
    });

    tearDown(() async {
      await testDb.dispose();
    });

    test(
        'Scheduler handles notification service failures gracefully without crashing on active risk subjects',
        () async {
      mockService.shouldThrow = true;

      await expectLater(
        scheduler.checkAttendanceRisks(customNow: DateTime.now()),
        completes,
      );
    });

    test(
        'Scheduler schedules and persists notification item to real Isar when service succeeds',
        () async {
      mockService.shouldThrow = false;

      await scheduler.checkAttendanceRisks(customNow: DateTime.now());

      expect(mockService.scheduledItems.length, 1);
      final persisted = testDb.isar.notificationItems.where().findAll();
      expect(persisted.length, 1);
      expect(persisted.first.type, 'LOW_ATTENDANCE_ALERT');
      expect(persisted.first.title, contains('Low Attendance Alert'));
    });
  });
}
