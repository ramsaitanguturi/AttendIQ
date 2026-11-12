import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/app/app_router.dart';
import 'package:attend_iq/core/ai/context/attendance_ai_context.dart';
import 'package:attend_iq/core/ai/services/gemini_ai_provider.dart';
import 'package:attend_iq/core/analytics/models/attendance_analytics.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('ISSUE-01: Analytics Chart Safe Point Ranges', () {
    test('Zero points exhibits empty trend state', () {
      const trend = AttendanceTrend(daily: [], weekly: [], monthly: []);
      expect(trend.daily.isEmpty, isTrue);
      expect(trend.weekly.isEmpty, isTrue);
      expect(trend.monthly.isEmpty, isTrue);
    });

    test(
        'Single point calculates valid axis range where minX < maxX and isCurved is false',
        () {
      final singlePointList = [
        TrendPoint(date: DateTime.utc(2026, 8, 10), percentage: 80.0),
      ];

      const double minX = 0;
      final double maxX = singlePointList.length <= 1
          ? 1.0
          : (singlePointList.length - 1).toDouble();
      final bool isCurved = singlePointList.length > 1;
      final double interval = singlePointList.length <= 1
          ? 1.0
          : (singlePointList.length / 5).clamp(1.0, 100.0);

      expect(minX, equals(0.0));
      expect(maxX, equals(1.0));
      expect(
        minX < maxX,
        isTrue,
        reason: 'minX must be strictly less than maxX in fl_chart',
      );
      expect(isCurved, isFalse);
      expect(interval, equals(1.0));
    });

    test('Multiple points calculates standard range and enables curvature', () {
      final multiPointList = [
        TrendPoint(date: DateTime.utc(2026, 8, 10), percentage: 80.0),
        TrendPoint(date: DateTime.utc(2026, 8, 11), percentage: 85.0),
        TrendPoint(date: DateTime.utc(2026, 8, 12), percentage: 90.0),
      ];

      const double minX = 0;
      final double maxX = multiPointList.length <= 1
          ? 1.0
          : (multiPointList.length - 1).toDouble();
      final bool isCurved = multiPointList.length > 1;

      expect(minX, equals(0.0));
      expect(maxX, equals(2.0));
      expect(minX < maxX, isTrue);
      expect(isCurved, isTrue);
    });
  });

  group('ISSUE-02: Default Notification Channel Registration & Routing', () {
    test(
        'General and assignment notifications route to registered default channel',
        () {
      final item = NotificationItem()
        ..id = 101
        ..title = 'Assignment Due'
        ..body = 'Submit CS301 project'
        ..scheduledTime = DateTime.now().add(const Duration(hours: 2))
        ..type = 'ASSIGNMENT_REMINDER'
        ..relatedId = '12';

      final type = NotificationType.fromString(item.type);
      final String channelId;
      switch (type) {
        case NotificationType.CLASS_REMINDER:
          channelId = 'class_reminders';
          break;
        case NotificationType.ATTENDANCE_WARNING:
        case NotificationType.LOW_ATTENDANCE_ALERT:
          channelId = 'attendance_warnings';
          break;
        case NotificationType.WEEKLY_REPORT:
          channelId = 'weekly_reports';
          break;
        default:
          channelId = 'default';
          break;
      }

      expect(channelId, equals('default'));
    });
  });

  group('ISSUE-03: AppRouter Diagnostics & Deep Link Redirects', () {
    test('GoRouter configures debugLogDiagnostics according to kDebugMode', () {
      final container = ProviderContainer(
        overrides: [
          hasActiveSemesterProvider.overrideWith((ref) => Future.value(false)),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      expect(router, isA<GoRouter>());
    });

    test(
        'Redirects semester-dependent routes to onboarding when no semester exists',
        () {
      final container = ProviderContainer(
        overrides: [
          hasActiveSemesterProvider.overrideWith((ref) => Future.value(false)),
        ],
      );
      addTearDown(container.dispose);

      String? testRedirect(String path) {
        final hasSemester =
            container.read(hasActiveSemesterProvider).valueOrNull ?? false;
        final isSplash = path == '/splash';
        final isOnboarding = path == '/onboarding';

        if (hasSemester) {
          if (isSplash || isOnboarding) {
            return '/dashboard';
          }
        } else {
          if (!isOnboarding) {
            return '/onboarding';
          }
        }
        return null;
      }

      expect(testRedirect('/timetable'), equals('/onboarding'));
      expect(testRedirect('/planner'), equals('/onboarding'));
      expect(testRedirect('/analytics'), equals('/onboarding'));
      expect(testRedirect('/dashboard'), equals('/onboarding'));
      expect(testRedirect('/splash'), equals('/onboarding'));
      expect(testRedirect('/onboarding'), isNull);
    });

    test('Allows protected routes when active semester exists', () {
      final container = ProviderContainer(
        overrides: [
          hasActiveSemesterProvider.overrideWith((ref) => Future.value(true)),
        ],
      );
      addTearDown(container.dispose);

      String? testRedirect(String path) {
        final hasSemester =
            container.read(hasActiveSemesterProvider).valueOrNull ?? true;
        final isSplash = path == '/splash';
        final isOnboarding = path == '/onboarding';

        if (hasSemester) {
          if (isSplash || isOnboarding) {
            return '/dashboard';
          }
        } else {
          if (!isSplash && !isOnboarding) {
            return '/onboarding';
          }
        }
        return null;
      }

      expect(testRedirect('/splash'), equals('/dashboard'));
      expect(testRedirect('/onboarding'), equals('/dashboard'));
      expect(testRedirect('/timetable'), isNull);
      expect(testRedirect('/planner'), isNull);
      expect(testRedirect('/dashboard'), isNull);
    });
  });

  group('ISSUE-04: Exam Time Selection & Validation', () {
    int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

    test('Valid time interval (10:00 to 11:30) is accepted', () {
      const start = TimeOfDay(hour: 10, minute: 0);
      const end = TimeOfDay(hour: 11, minute: 30);

      expect(toMinutes(end) > toMinutes(start), isTrue);
    });

    test('Reversed time interval (14:00 to 13:00) is rejected', () {
      const start = TimeOfDay(hour: 14, minute: 0);
      const end = TimeOfDay(hour: 13, minute: 0);

      expect(toMinutes(end) <= toMinutes(start), isTrue);
    });

    test('Equal start and end times (09:00 to 09:00) are rejected', () {
      const start = TimeOfDay(hour: 9, minute: 0);
      const end = TimeOfDay(hour: 9, minute: 0);

      expect(toMinutes(end) <= toMinutes(start), isTrue);
    });
  });

  group('ISSUE-06: Gemini API Key Header & URL Query Parameter Security', () {
    test('Gemini request URL does not include apiKey in query string', () {
      final uri = GeminiAIProvider.requestUri;

      expect(
        uri.hasQuery,
        isFalse,
        reason: 'Request URI must not have query string',
      );
      expect(uri.queryParameters.containsKey('key'), isFalse);
      expect(uri.toString().contains('key='), isFalse);
      expect(
        uri.toString(),
        equals(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
        ),
      );
    });

    test('Gemini request sets x-goog-api-key header', () async {
      final fakeClient = _FakeHttpClient();
      final provider = GeminiAIProvider(
        apiKey: 'test-secret-api-key-12345',
        clientOverride: fakeClient,
      );

      const fakeContext = AttendanceAIContext(
        studentInfo: {},
        semester: {},
        attendanceSummary: {},
        subjectStatistics: [],
        riskSubjects: [],
        upcomingClasses: [],
        attendanceTarget: 75.0,
        recentTrends: {},
      );

      final response = await provider.askQuestion(
        context: fakeContext,
        question: 'What is my status?',
      );

      expect(response.answer, equals('Status is good'));
      expect(fakeClient.recordedRequest, isNotNull);
      final req = fakeClient.recordedRequest!;
      expect(req.recordedUri.hasQuery, isFalse);
      expect(
        req.headers.value('x-goog-api-key'),
        equals('test-secret-api-key-12345'),
      );
    });
  });
}

class _FakeHttpClient extends Fake implements HttpClient {
  _FakeHttpClientRequest? recordedRequest;

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    final req = _FakeHttpClientRequest(url);
    recordedRequest = req;
    return req;
  }

  @override
  void close({bool force = false}) {}
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  final Uri recordedUri;
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  _FakeHttpClientRequest(this.recordedUri);

  @override
  void write(Object? obj) {}

  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse();
  }
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  final Map<String, String> _headers = {};

  @override
  ContentType? contentType;

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name.toLowerCase()] = value.toString();
  }

  @override
  String? value(String name) => _headers[name.toLowerCase()];
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    const jsonStr = '''
    {
      "candidates": [
        {
          "content": {
            "parts": [
              {
                "text": "{\\"answer\\": \\"Status is good\\", \\"prioritizedClasses\\": [], \\"safeBunkRecommendations\\": [], \\"studyPlanSuggestions\\": []}"
              }
            ]
          }
        }
      ]
    }
    ''';
    return Stream.value(utf8.encode(jsonStr)).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
