import 'package:flutter_test/flutter_test.dart';

// App imports
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/timetable/data/models/academic_event_local.dart';
import 'package:attend_iq/core/event_generator/data/models/event_local.dart';
import 'package:attend_iq/core/ai/services/local_advisor_service.dart';
import 'package:attend_iq/core/ai/context/attendance_ai_context.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_scheduler.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';

class FakeNotificationDatabase implements NotificationDatabase {
  SemesterLocal? activeSemester;
  List<NotificationItem> notifications = [];

  @override
  Future<SemesterLocal?> getActiveSemester() async => activeSemester;

  @override
  Future<List<NotificationItem>> getFutureNotifications(DateTime now) async => notifications;

  @override
  Future<List<SubjectLocal>> getSubjects() async => [];

  @override
  Future<List<EventLocal>> getEvents(DateTime start, DateTime end) async => [];

  @override
  Future<List<AcademicEventLocal>> getAcademicEvents(DateTime start, DateTime end) async => [];

  @override
  Future<List<TimetableTemplateLocal>> getTemplates() async => [];

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(int subjectId) async => [];

  @override
  Future<List<AttendanceRecordLocal>> getAllAttendanceRecords() async => [];

  @override
  Future<List<NotificationItem>> getFutureNotificationsByType(String type, DateTime now) async => [];

  @override
  Future<NotificationItem?> getLastNotification(String type, String relatedId) async => null;

  @override
  Future<void> deleteNotification(int id) async {}

  @override
  Future<void> saveNotification(NotificationItem item) async {}
}

class FakeNotificationService implements NotificationService {
  bool shouldThrow = false;

  @override
  Future<void> scheduleNotification(NotificationItem item) async {
    if (shouldThrow) throw Exception('Notification platform channel failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Production Readiness - AI Fallback Heuristics', () {
    test('LocalAdvisorService fallback generates mathematically correct suggestions when offline', () async {
      const localAdvisor = LocalAdvisorService();
      final context = AttendanceAIContext(
        studentInfo: const {},
        semester: const {},
        attendanceSummary: const {},
        recentTrends: const {},
        attendanceTarget: 75.0,
        subjectStatistics: const [
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
        upcomingClasses: const [
          {
            'subjectId': 1,
            'subjectName': 'Math',
            'day': 'Tomorrow',
          }
        ],
        riskSubjects: const [
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
      expect(response.answer, contains('No, you should not skip tomorrow\'s classes.'));
      expect(response.relatedSubjects, contains('Math'));
      expect(response.actionItems.first, contains('Attend Math'));
    });
  });

  group('Production Readiness - Notification Failures', () {
    late FakeNotificationDatabase mockDb;
    late FakeNotificationService mockService;
    late NotificationScheduler scheduler;

    setUp(() {
      mockDb = FakeNotificationDatabase();
      mockService = FakeNotificationService();
      scheduler = NotificationScheduler(mockDb, mockService);
    });

    test('Scheduler handles notification service failures gracefully without crashing', () async {
      final semester = SemesterLocal()
        ..name = 'Spring 2026'
        ..startDate = DateTime.now()
        ..endDate = DateTime.now().add(const Duration(days: 90))
        ..requiredAttendanceRate = 75.0;

      mockDb.activeSemester = semester;
      mockDb.notifications = [];
      mockService.shouldThrow = true;

      await expectLater(
        scheduler.checkAttendanceRisks(customNow: DateTime.now()),
        completes,
      );
    });
  });
}
