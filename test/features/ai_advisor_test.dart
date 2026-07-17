import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/ai/context/attendance_ai_context.dart';
import 'package:attend_iq/core/ai/parsers/ai_response_parser.dart';
import 'package:attend_iq/core/ai/services/local_advisor_service.dart';

void main() {
  group('AI Attendance Advisor Tests', () {
    const dummyContext = AttendanceAIContext(
      studentInfo: {'name': 'Alice', 'email': 'alice@example.com'},
      semester: {
        'name': 'Semester 1',
        'startDate': '2026-07-01T00:00:00Z',
        'endDate': '2026-12-01T00:00:00Z',
        'weeksRemaining': 10,
      },
      attendanceSummary: {
        'overallPercentage': 72.0,
        'totalClasses': 20,
        'totalPresent': 13,
        'totalAbsent': 7,
      },
      subjectStatistics: [
        {
          'id': 1,
          'name': 'Mathematics IV',
          'code': 'MATH101',
          'credits': 4,
          'attendanceTarget': 75.0,
          'currentPercentage': 65.0,
          'present': 13,
          'absent': 7,
          'total': 20,
          'safeBunks': 0,
          'mustAttendConsecutive': 8,
          'predictedPercentage': 70.0,
        },
        {
          'id': 2,
          'name': 'Physics Lab',
          'code': 'PHY102',
          'credits': 2,
          'attendanceTarget': 75.0,
          'currentPercentage': 90.0,
          'present': 9,
          'absent': 1,
          'total': 10,
          'safeBunks': 2,
          'mustAttendConsecutive': 0,
          'predictedPercentage': 92.0,
        }
      ],
      riskSubjects: const [
        {
          'id': 1,
          'name': 'Mathematics IV',
          'status': 'Critical',
          'currentPercentage': 65.0,
          'target': 75.0,
          'mustAttendConsecutive': 8,
        }
      ],
      upcomingClasses: const [
        {
          'day': 'Today',
          'subjectId': 1,
          'subjectName': 'Mathematics IV',
          'time': '09:00-10:00',
          'status': 'UNMARKED',
        },
        {
          'day': 'Tomorrow',
          'subjectId': 2,
          'subjectName': 'Physics Lab',
          'time': '11:00-13:00',
          'status': 'UNMARKED',
        }
      ],
      attendanceTarget: 75.0,
      recentTrends: const {
        'recentPercentage': 70.0,
        'totalClassesLoggedLast30Days': 10,
        'presentClassesLoggedLast30Days': 7,
      },
    );

    group('Response Parsing Tests', () {
      test('Parses direct JSON correctly', () {
        const jsonStr = '''
        {
          "answer": "You should attend Math.",
          "confidence": 0.95,
          "relatedSubjects": ["Math"],
          "actionItems": ["Attend Wednesday class"]
        }
        ''';

        final response = AIResponseParser.parse(jsonStr);

        expect(response.answer, 'You should attend Math.');
        expect(response.confidence, 0.95);
        expect(response.relatedSubjects, ['Math']);
        expect(response.actionItems, ['Attend Wednesday class']);
      });

      test('Cleans up markdown JSON blocks and parses correctly', () {
        const markdownStr = '''
        ```json
        {
          "answer": "Skip Physics.",
          "confidence": 0.85,
          "relatedSubjects": ["Physics"],
          "actionItems": ["Skip Physics Friday"]
        }
        ```
        ''';

        final response = AIResponseParser.parse(markdownStr);

        expect(response.answer, 'Skip Physics.');
        expect(response.confidence, 0.85);
        expect(response.relatedSubjects, ['Physics']);
        expect(response.actionItems, ['Skip Physics Friday']);
      });

      test('Falls back gracefully on invalid JSON', () {
        const invalidStr = 'This is not a JSON string, just plain text response.';

        final response = AIResponseParser.parse(invalidStr);

        expect(response.answer, 'This is not a JSON string, just plain text response.');
        expect(response.confidence, 0.5);
        expect(response.actionItems.first, 'Check subject logs manually');
      });
    });

    group('Fallback Rules Tests', () {
      const localAdvisor = LocalAdvisorService();

      test('Generates generic advice applying threshold warnings and safe bunks', () async {
        final response = await localAdvisor.generateAdvice(context: dummyContext);

        expect(response.answer, contains('local rule-based'));
        expect(response.confidence, 1.0);
        // Mathematics IV is Critical
        expect(response.actionItems.any((item) => item.contains('Mathematics IV') && item.contains('consecutive')), isTrue);
        // Physics Lab has Safe Skips
        expect(response.actionItems.any((item) => item.contains('Physics Lab') && item.contains('safe skips')), isTrue);
      });

      test('Answers tomorrow skipping question locally', () async {
        final response = await localAdvisor.askQuestion(
          context: dummyContext,
          question: "Can I skip tomorrow's classes?",
        );

        expect(response.answer, contains('Yes, you can safely skip'));
        expect(response.relatedSubjects, contains('Physics Lab'));
      });

      test('Answers tomorrow skipping question with critical classes scheduled', () async {
        final contextWithCriticalTomorrow = AttendanceAIContext(
          studentInfo: dummyContext.studentInfo,
          semester: dummyContext.semester,
          attendanceSummary: dummyContext.attendanceSummary,
          subjectStatistics: dummyContext.subjectStatistics,
          riskSubjects: dummyContext.riskSubjects,
          upcomingClasses: const [
            {
              'day': 'Tomorrow',
              'subjectId': 1,
              'subjectName': 'Mathematics IV',
              'time': '09:00-10:00',
              'status': 'UNMARKED',
            }
          ],
          attendanceTarget: dummyContext.attendanceTarget,
          recentTrends: dummyContext.recentTrends,
        );

        final response = await localAdvisor.askQuestion(
          context: contextWithCriticalTomorrow,
          question: "Can I skip tomorrow's classes?",
        );

        expect(response.answer, contains('No, you should not skip'));
        expect(response.relatedSubjects, contains('Mathematics IV'));
      });

      test('Answers miss two classes question locally', () async {
        final response = await localAdvisor.askQuestion(
          context: dummyContext,
          question: 'What happens if I miss two classes?',
        );

        expect(response.answer, contains('drop you below your threshold'));
        expect(response.relatedSubjects, contains('Mathematics IV'));
      });

      test('Answers risky subjects question locally', () async {
        final response = await localAdvisor.askQuestion(
          context: dummyContext,
          question: 'Which subjects are risky?',
        );

        expect(response.answer, contains('critical'));
        expect(response.relatedSubjects, contains('Mathematics IV'));
      });

      test('Answers consecutive attend class question locally', () async {
        final response = await localAdvisor.askQuestion(
          context: dummyContext,
          question: 'How many classes do I need to attend?',
        );

        expect(response.answer, contains('consecutive classes'));
        expect(response.actionItems.any((item) => item.contains('Math') && item.contains('8')), isTrue);
      });
    });
  });
}
