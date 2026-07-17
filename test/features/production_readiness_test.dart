// ignore_for_file: subtype_of_sealed_class

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// App imports
import 'package:attend_iq/features/auth/data/models/user_local.dart';
import 'package:attend_iq/features/auth/data/models/semester_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/core/event_generator/data/models/event_local.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attend_iq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:attend_iq/core/ai/services/local_advisor_service.dart';
import 'package:attend_iq/core/ai/context/attendance_ai_context.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_scheduler.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';

// Manual Fakes
class MockUserCredential implements fb_auth.UserCredential {
  @override
  fb_auth.User? get user => MockFirebaseUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseUser implements fb_auth.User {
  @override
  String get uid => 'user_123';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  UserLocal? currentUser;
  SemesterLocal? activeSemester;
  bool saveUserCalled = false;

  @override
  Future<UserLocal?> getUser() async => currentUser;

  @override
  Future<void> saveUser(UserLocal user) async {
    saveUserCalled = true;
    currentUser = user;
  }

  @override
  Future<void> clearUser() async {
    currentUser = null;
    activeSemester = null;
  }

  @override
  Future<void> saveSemester(SemesterLocal semester) async {
    activeSemester = semester;
  }

  @override
  Future<SemesterLocal?> getActiveSemester() async {
    return activeSemester;
  }

  @override
  Future<bool> hasActiveSemester() async {
    return activeSemester != null;
  }
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  bool shouldThrow = false;
  bool shouldThrowFetch = false;

  @override
  Future<fb_auth.UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('Network disconnected');
    return MockUserCredential();
  }

  @override
  Future<fb_auth.UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('Network disconnected');
    return MockUserCredential();
  }

  @override
  Future<Map<String, dynamic>?> fetchUserProfile({required String uid}) async {
    if (shouldThrowFetch) throw Exception('Firestore access denied');
    return {'uid': uid, 'name': 'Bob'};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  group('Production Readiness - Authentication Edge Cases', () {
    late FakeAuthLocalDataSource localDS;
    late FakeAuthRemoteDataSource remoteDS;
    late AuthRepositoryImpl authRepo;

    setUp(() {
      localDS = FakeAuthLocalDataSource();
      remoteDS = FakeAuthRemoteDataSource();
      authRepo = AuthRepositoryImpl(
        localDataSource: localDS,
        remoteDataSource: remoteDS,
      );
    });

    test('Register fails when remote API throws an error (e.g. no internet)', () async {
      remoteDS.shouldThrow = true;

      expect(
        () => authRepo.registerWithEmailAndPassword(
          name: 'Bob',
          email: 'bob@test.com',
          password: 'password',
        ),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Network disconnected'))),
      );

      // Verify that local database was NOT modified
      expect(localDS.saveUserCalled, false);
    });

    test('Login fails when remote profile fetch throws exception', () async {
      remoteDS.shouldThrowFetch = true;

      expect(
        () => authRepo.loginWithEmailAndPassword(
          email: 'bob@test.com',
          password: 'password',
        ),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Firestore access denied'))),
      );

      expect(localDS.saveUserCalled, false);
    });
  });

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
            'total': 15, // 66.7%
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

      // Executing this should not crash
      await expectLater(
        scheduler.checkAttendanceRisks(customNow: DateTime.now()),
        completes,
      );
    });
  });
}
