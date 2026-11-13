import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/attendance_engine/calculator.dart';
import 'package:attend_iq/core/analytics/calculators/analytics_calculator.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';

void main() {
  group('Late Attendance Math & Calculations', () {
    test('calculatePercentage supports fractional attended from late weighting', () {
      // 10 present, 2 late at 0.5 weight = 11.0 attended out of 12 total = 91.666...%
      final percentage = AttendanceCalculator.calculatePercentage(
        attended: 11.0,
        total: 12,
      );
      expect(percentage, closeTo(91.666, 0.01));
    });

    test('calculateSafeBunks accounts for weighted late classes', () {
      // Target: 75%
      // 10 present, 4 late @ 0.5 weight -> 12 attended, 16 total -> 12/16 = 75.0%
      // Safe bunks should be 0 (cannot skip any class without dropping below 75%)
      final safeBunks = AttendanceCalculator.calculateSafeBunks(
        attended: 12.0,
        total: 16,
        target: 75.0,
      );
      expect(safeBunks, equals(0));

      // 14 attended out of 16 total -> 87.5% -> can safely bunk 2 classes
      final safeBunks2 = AttendanceCalculator.calculateSafeBunks(
        attended: 14.0,
        total: 16,
        target: 75.0,
      );
      expect(safeBunks2, equals(2));
    });

    test('calculateRequiredClasses accounts for weighted late classes', () {
      // Target: 75%
      // 8 present, 2 late @ 0.5 -> 9 attended out of 16 total (56.25%)
      // Needed to reach 75%: (0.75 * 16 - 9) / (1 - 0.75) = (12 - 9) / 0.25 = 12 classes
      final needed = AttendanceCalculator.calculateRequiredClasses(
        attended: 9.0,
        total: 16,
        target: 75.0,
      );
      expect(needed, equals(12));
    });

    test('AnalyticsCalculator calculates SubjectAnalytics with configurable lateWeight', () {
      final now = DateTime.now().toUtc();
      final subject = Subject(
        id: 1,
        semesterId: 1,
        name: 'Distributed Systems',
        code: 'CS401',
        credits: 3,
        attendanceTarget: 75.0,
        type: SubjectType.THEORY,
        color: '#2196F3',
        updatedAt: now,
      );

      final records = [
        // 6 PRESENT
        for (int i = 0; i < 6; i++)
          AttendanceRecord(
            id: i + 1,
            subjectId: 1,
            status: AttendanceStatus.PRESENT,
            markedAt: now.subtract(Duration(days: i)),
            updatedAt: now,
          ),
        // 2 ABSENT
        for (int i = 0; i < 2; i++)
          AttendanceRecord(
            id: i + 10,
            subjectId: 1,
            status: AttendanceStatus.ABSENT,
            markedAt: now.subtract(Duration(days: i + 10)),
            updatedAt: now,
          ),
        // 2 LATE
        for (int i = 0; i < 2; i++)
          AttendanceRecord(
            id: i + 20,
            subjectId: 1,
            status: AttendanceStatus.LATE,
            markedAt: now.subtract(Duration(days: i + 20)),
            updatedAt: now,
          ),
      ];

      // With lateWeight = 0.5:
      // effectiveAttended = 6 + (2 * 0.5) = 7.0
      // totalClasses = 6 + 2 + 2 = 10
      // percentage = 70.0%
      final stats50 = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: subject,
        records: records,
        lateWeight: 0.5,
      );

      expect(stats50.present, equals(6));
      expect(stats50.absent, equals(2));
      expect(stats50.lateCount, equals(2));
      expect(stats50.totalClasses, equals(10));
      expect(stats50.percentage, equals(70.0));

      // With lateWeight = 1.0 (Full present):
      // effectiveAttended = 6 + (2 * 1.0) = 8.0
      // percentage = 80.0%
      final stats100 = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: subject,
        records: records,
        lateWeight: 1.0,
      );
      expect(stats100.percentage, equals(80.0));

      // With lateWeight = 0.0 (Treated as absent):
      // effectiveAttended = 6.0
      // percentage = 60.0%
      final stats0 = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: subject,
        records: records,
        lateWeight: 0.0,
      );
      expect(stats0.percentage, equals(60.0));
    });
  });
}
