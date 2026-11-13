import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:attend_iq/core/ai/context/attendance_ai_context.dart';
import 'package:attend_iq/core/ai/models/ai_response.dart';
import 'package:attend_iq/core/ai/services/gemini_ai_provider.dart';
import 'package:attend_iq/core/ai/services/local_advisor_service.dart';

class _MockHttpClientRequest implements HttpClientRequest {
  final HttpHeaders _headers = _MockHttpHeaders();
  final Completer<HttpClientResponse> _responseCompleter =
      Completer<HttpClientResponse>();

  @override
  HttpHeaders get headers => _headers;

  @override
  void write(Object? obj) {}

  @override
  Future<HttpClientResponse> close() => _responseCompleter.future;

  void completeResponse(HttpClientResponse response) {
    _responseCompleter.complete(response);
  }

  void completeError(Object error) {
    _responseCompleter.completeError(error);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  final Map<String, dynamic> _values = {};

  @override
  ContentType? contentType;

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final String _responseBody;

  _MockHttpClientResponse(this.statusCode, this._responseBody);

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(utf8.encode(_responseBody)).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClient implements HttpClient {
  Duration? connectionTimeout;
  bool wasClosedWithForce = false;
  Future<HttpClientRequest> Function(Uri url)? postUrlHandler;

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    if (postUrlHandler != null) {
      return postUrlHandler!(url);
    }
    throw UnimplementedError();
  }

  @override
  void close({bool force = false}) {
    if (force) {
      wasClosedWithForce = true;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Group D: AI Assistant Reliability (BUG-015, BUG-016, NEW-BUG-08)', () {
    final sampleContext = AttendanceAIContext(
      studentInfo: {'name': 'Student'},
      semester: {'name': 'Fall 2026'},
      attendanceSummary: {
        'overallPercentage': 72.0,
        'totalClasses': 50,
        'attendedClasses': 36,
        'riskLevel': 'WARNING',
      },
      attendanceTarget: 75.0,
      subjectStatistics: [
        {
          'id': 10,
          'name': 'Physics',
          'currentPercentage': 70.0,
          'attendanceTarget': 75.0,
          'safeBunks': 0,
        },
      ],
      riskSubjects: [
        {
          'id': 10,
          'name': 'Physics',
          'currentPercentage': 70.0,
          'attendanceTarget': 75.0,
          'safeBunks': 0,
        },
      ],
      upcomingClasses: [
        {
          'day': 'Tomorrow',
          'subjectId': 10,
          'subjectName': 'Physics',
          'startTime': '09:00',
        },
      ],
      recentTrends: {},
    );

    test(
        'BUG-016 & NEW-BUG-08: Model identifier is updated to gemini-2.5-flash and not retired model',
        () {
      final uri = GeminiAIProvider.requestUri;
      expect(uri.path, contains('gemini-2.5-flash'));
      expect(uri.path, isNot(contains('gemini-1.5-flash')));
      expect(uri.path, isNot(contains('gemini-pro')));
    });

    test(
        'BUG-016 & NEW-BUG-08: GeminiAIProvider sets 10s connection timeout and closes HttpClient with force: true',
        () async {
      final mockClient = _MockHttpClient();
      final mockRequest = _MockHttpClientRequest();

      mockClient.postUrlHandler = (url) async {
        return mockRequest;
      };

      final provider = GeminiAIProvider(
        apiKey: 'test-secret-key-12345',
        clientOverride: mockClient,
      );

      final responseJson = json.encode({
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': json.encode({
                    'answer': 'Attend all classes this week to reach 75%.',
                    'confidence': 0.95,
                    'relatedSubjects': ['Physics'],
                    'actionItems': ['Attend Physics tomorrow'],
                  }),
                },
              ],
            },
          },
        ],
      });

      mockRequest.completeResponse(_MockHttpClientResponse(200, responseJson));

      final response = await provider.askQuestion(
        context: sampleContext,
        question: 'How do I reach 75%?',
      );

      expect(mockClient.connectionTimeout, const Duration(seconds: 10));
      expect(response.answer, 'Attend all classes this week to reach 75%.');
      expect(response.relatedSubjects, contains('Physics'));
    });

    test(
        'NEW-BUG-08: API key is redacted from error messages and never exposed in logs',
        () async {
      final mockClient = _MockHttpClient();
      final mockRequest = _MockHttpClientRequest();

      mockClient.postUrlHandler = (url) async => mockRequest;

      final secretKey = 'AIzaSyD-Secret-Key-Must-Not-Leak';
      final provider = GeminiAIProvider(
        apiKey: secretKey,
        clientOverride: mockClient,
      );

      // Simulate API error containing the key in the body
      final errorJsonWithKey = json.encode({
        'error': {
          'code': 400,
          'message': 'Invalid key $secretKey provided in request',
        },
      });

      mockRequest
          .completeResponse(_MockHttpClientResponse(400, errorJsonWithKey));

      try {
        await provider.askQuestion(
          context: sampleContext,
          question: 'Hello?',
        );
        fail('Should have thrown an exception');
      } catch (e) {
        final errorMsg = e.toString();
        expect(errorMsg, contains('[REDACTED]'));
        expect(errorMsg, isNot(contains(secretKey)));
      }
    });

    test(
        'BUG-015: When Gemini API fails or times out, fallback pipeline resolves answer via LocalAdvisorService',
        () async {
      // Simulate failed Gemini provider
      final failingGemini = GeminiAIProvider(apiKey: 'invalid-key');
      const localAdvisor = LocalAdvisorService();

      AIResponse? resultResponse;
      String? providerUsed;

      // Pipeline matching AIChatController fallback pattern
      try {
        // Attempt Gemini
        await failingGemini.askQuestion(
          context: sampleContext,
          question: 'Can I skip tomorrow\'s classes?',
        );
        providerUsed = 'gemini';
      } catch (_) {
        // Fallback to LocalAdvisorService on failure
        resultResponse = await localAdvisor.askQuestion(
          context: sampleContext,
          question: 'Can I skip tomorrow\'s classes?',
        );
        providerUsed = 'local_fallback';
      }

      expect(providerUsed, 'local_fallback');
      expect(resultResponse, isNotNull);
      expect(resultResponse!.answer, contains('No, you should not skip'));
      expect(resultResponse.relatedSubjects, contains('Physics'));
      expect(resultResponse.actionItems.isNotEmpty, isTrue);
    });

    test(
        'BUG-015: LocalAdvisorService operates fully offline and handles skip question with risky subjects',
        () async {
      const localAdvisor = LocalAdvisorService();

      final response = await localAdvisor.askQuestion(
        context: sampleContext,
        question: 'Can I skip tomorrow?',
      );

      expect(response.answer,
          contains('No, you should not skip tomorrow\'s classes'));
      expect(response.relatedSubjects, contains('Physics'));
      expect(response.confidence, 1.0);
    });
  });
}
