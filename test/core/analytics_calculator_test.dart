import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/analytics/models/risk_status.dart';
import 'package:attend_iq/core/analytics/calculators/analytics_calculator.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/auth/domain/entities/semester.dart';

void main() {
  group('AnalyticsCalculator - Subject Analytics Tests', () {
    final mockSubject = Subject(
      id: 1,
      semesterId: 1,
      name: 'Mobile Computing',
      code: 'CS402',
      credits: 4,
      attendanceTarget: 75.0,
      color: '#FF5733',
      type: SubjectType.THEORY,
      updatedAt: DateTime.now(),
    );

    test('Normal case (27 present, 4 absent)', () {
      final records = List.generate(
        27,
        (i) => AttendanceRecord(
          id: i,
          eventId: i,
          subjectId: 1,
          status: AttendanceStatus.PRESENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ) +
      List.generate(
        4,
        (i) => AttendanceRecord(
          id: i + 100,
          eventId: i + 100,
          subjectId: 1,
          status: AttendanceStatus.ABSENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final result = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: mockSubject,
        records: records,
      );

      expect(result.subjectId, 1);
      expect(result.subjectName, 'Mobile Computing');
      expect(result.percentage.toStringAsFixed(1), '87.1');
      expect(result.present, 27);
      expect(result.absent, 4);
      expect(result.totalClasses, 31);
      expect(result.safeBunks, 5);
      expect(result.classesNeeded, 0);
      expect(result.riskStatus, RiskStatus.SAFE);
    });

    test('Zero total classes fallback', () {
      final result = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: mockSubject,
        records: const [],
      );

      expect(result.percentage, 100.0);
      expect(result.totalClasses, 0);
      expect(result.riskStatus, RiskStatus.SAFE);
    });

    test('Critical status (below target 75.0%)', () {
      final records = [
        AttendanceRecord(
          id: 1,
          eventId: 1,
          subjectId: 1,
          status: AttendanceStatus.PRESENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AttendanceRecord(
          id: 2,
          eventId: 2,
          subjectId: 1,
          status: AttendanceStatus.ABSENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]; // 50% attendance

      final result = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: mockSubject,
        records: records,
      );

      expect(result.percentage, 50.0);
      expect(result.riskStatus, RiskStatus.CRITICAL);
      expect(result.classesNeeded, 2); // needs 2 more presents to reach 75%
    });

    test('Warning status (close to target threshold 75.0%)', () {
      // 23 present, 7 absent -> 23 / 30 = 76.7% (within 2.5% warning of 75.0%)
      final records = List.generate(
        23,
        (i) => AttendanceRecord(
          id: i,
          eventId: i,
          subjectId: 1,
          status: AttendanceStatus.PRESENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ) +
      List.generate(
        7,
        (i) => AttendanceRecord(
          id: i + 100,
          eventId: i + 100,
          subjectId: 1,
          status: AttendanceStatus.ABSENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final result = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: mockSubject,
        records: records,
      );

      expect(result.percentage.toStringAsFixed(1), '76.7');
      expect(result.riskStatus, RiskStatus.WARNING);
      expect(result.safeBunks, 0);
    });
  });

  group('AnalyticsCalculator - Overall Analytics Tests', () {
    final mockSemester = Semester(
      id: 'sem_1',
      name: 'Semester 5',
      startDate: DateTime.utc(2026, 1, 1),
      endDate: DateTime.utc(2026, 5, 30),
      requiredAttendanceRate: 75.0,
    );

    final subjectA = Subject(
      id: 1,
      semesterId: 1,
      name: 'Subject A',
      code: 'SA',
      credits: 3,
      attendanceTarget: 75.0,
      color: '#FF5733',
      type: SubjectType.THEORY,
      updatedAt: DateTime.now(),
    );

    final subjectB = Subject(
      id: 2,
      semesterId: 1,
      name: 'Subject B',
      code: 'SB',
      credits: 4,
      attendanceTarget: 75.0,
      color: '#33FF57',
      type: SubjectType.THEORY,
      updatedAt: DateTime.now(),
    );

    test('Subject rankings and overall statistics', () {
      final records = [
        // Subject A: 4 present, 1 absent -> 80% (Safe)
        AttendanceRecord(
            id: 1, eventId: 1, subjectId: 1, status: AttendanceStatus.PRESENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),
        AttendanceRecord(
            id: 2, eventId: 2, subjectId: 1, status: AttendanceStatus.PRESENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),
        AttendanceRecord(
            id: 3, eventId: 3, subjectId: 1, status: AttendanceStatus.PRESENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),
        AttendanceRecord(
            id: 4, eventId: 4, subjectId: 1, status: AttendanceStatus.PRESENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),
        AttendanceRecord(
            id: 5, eventId: 5, subjectId: 1, status: AttendanceStatus.ABSENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),

        // Subject B: 2 present, 3 absent -> 40% (Critical)
        AttendanceRecord(
            id: 6, eventId: 6, subjectId: 2, status: AttendanceStatus.PRESENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),
        AttendanceRecord(
            id: 7, eventId: 7, subjectId: 2, status: AttendanceStatus.PRESENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),
        AttendanceRecord(
            id: 8, eventId: 8, subjectId: 2, status: AttendanceStatus.ABSENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),
        AttendanceRecord(
            id: 9, eventId: 9, subjectId: 2, status: AttendanceStatus.ABSENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),
        AttendanceRecord(
            id: 10, eventId: 10, subjectId: 2, status: AttendanceStatus.ABSENT, markedAt: DateTime.now(), updatedAt: DateTime.now()),
      ];

      final occurrences = [
        LoggedOccurrence(date: DateTime.utc(2026, 1, 10), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 11), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 12), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 13), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 14), startTime: '09:00', status: AttendanceStatus.ABSENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 15), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 16), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 17), startTime: '09:00', status: AttendanceStatus.ABSENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 18), startTime: '09:00', status: AttendanceStatus.ABSENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 19), startTime: '09:00', status: AttendanceStatus.ABSENT),
      ];

      final overall = AnalyticsCalculator.calculateOverallAnalytics(
        semester: mockSemester,
        subjects: [subjectA, subjectB],
        records: records,
        occurrences: occurrences,
      );

      // Overall calculations
      expect(overall.totalClasses, 10);
      expect(overall.totalPresent, 6);
      expect(overall.totalAbsent, 4);
      expect(overall.overallPercentage, 60.0);
      expect(overall.riskLevel, RiskStatus.CRITICAL);

      // Rankings check
      final comparison = overall.subjectComparison;
      expect(comparison.highestAttendanceSubject?.subjectId, 1); // Subject A
      expect(comparison.lowestAttendanceSubject?.subjectId, 2); // Subject B
      expect(comparison.mostAttendedSubject?.subjectId, 1); // 4 vs 2
      expect(comparison.mostMissedSubject?.subjectId, 2); // 3 vs 1
    });

    test('Streak calculations (ignoring cancelled status)', () {
      final occurrences = [
        LoggedOccurrence(date: DateTime.utc(2026, 1, 5), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 6), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 7), startTime: '10:00', status: AttendanceStatus.CANCELLED),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 8), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 9), startTime: '09:00', status: AttendanceStatus.ABSENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 10), startTime: '09:00', status: AttendanceStatus.PRESENT),
      ];

      final overall = AnalyticsCalculator.calculateOverallAnalytics(
        semester: mockSemester,
        subjects: [subjectA],
        records: const [],
        occurrences: occurrences,
      );

      // Streaks:
      // P, P -> streak 2
      // C -> skipped, streak 2
      // P -> streak 3
      // A -> streak reset (0)
      // P -> streak 1
      // Expect currentStreak = 1, longestPresentStreak = 3
      expect(overall.attendanceStreak.currentStreak, 1);
      expect(overall.attendanceStreak.longestPresentStreak, 3);
    });

    test('Trend generation yields sorted points', () {
      final occurrences = [
        LoggedOccurrence(date: DateTime.utc(2026, 1, 10), startTime: '09:00', status: AttendanceStatus.PRESENT),
        LoggedOccurrence(date: DateTime.utc(2026, 1, 15), startTime: '09:00', status: AttendanceStatus.ABSENT),
      ];

      final overall = AnalyticsCalculator.calculateOverallAnalytics(
        semester: mockSemester,
        subjects: [subjectA],
        records: const [],
        occurrences: occurrences,
      );

      final dailyTrend = overall.attendanceTrend.daily;
      expect(dailyTrend.length, 2);
      expect(dailyTrend[0].date, DateTime.utc(2026, 1, 10));
      expect(dailyTrend[0].percentage, 100.0);
      expect(dailyTrend[1].date, DateTime.utc(2026, 1, 15));
      expect(dailyTrend[1].percentage, 50.0);
    });
  });
}
