import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/attendance_engine/calculator.dart';
import 'package:attend_iq/core/attendance_engine/predictor.dart';
import 'package:attend_iq/core/attendance_engine/bunk_analyzer.dart';

void main() {
  group('AttendanceCalculator Tests', () {
    test('calculatePercentage normal case', () {
      final percentage = AttendanceCalculator.calculatePercentage(attended: 27, total: 31);
      expect(percentage.toStringAsFixed(1), '87.1');
    });

    test('calculatePercentage zero total division guard', () {
      final percentage = AttendanceCalculator.calculatePercentage(attended: 0, total: 0);
      expect(percentage, 100.0);
    });

    test('calculateSafeBunks 27/31 with 75% target', () {
      final safeBunks = AttendanceCalculator.calculateSafeBunks(attended: 27, total: 31, target: 75.0);
      expect(safeBunks, 5); // floor((2700 - 2325)/75) = floor(375/75) = 5
    });

    test('calculateSafeBunks 27/31 with 87% target', () {
      final safeBunks = AttendanceCalculator.calculateSafeBunks(attended: 27, total: 31, target: 87.0);
      // floor((2700 - 2697)/87) = floor(3/87) = 0
      expect(safeBunks, 0);
    });

    test('calculateSafeBunks below target threshold returns 0', () {
      final safeBunks = AttendanceCalculator.calculateSafeBunks(attended: 20, total: 30, target: 75.0);
      expect(safeBunks, 0);
    });

    test('calculateSafeBunks zero total returns 0', () {
      final safeBunks = AttendanceCalculator.calculateSafeBunks(attended: 0, total: 0, target: 75.0);
      expect(safeBunks, 0);
    });

    test('calculateRequiredClasses when above target returns 0', () {
      final required = AttendanceCalculator.calculateRequiredClasses(attended: 27, total: 31, target: 75.0);
      expect(required, 0);
    });

    test('calculateRequiredClasses when below target 75%', () {
      // 20/30 = 66.7%
      final required = AttendanceCalculator.calculateRequiredClasses(attended: 20, total: 30, target: 75.0);
      // ceil((75 * 30 - 100 * 20) / 25) = ceil((2250 - 2000) / 25) = ceil(250 / 25) = 10
      expect(required, 10);
    });

    test('calculateRequiredClasses target 100% returns null when a class is missed', () {
      final required = AttendanceCalculator.calculateRequiredClasses(attended: 29, total: 30, target: 100.0);
      expect(required, isNull);
    });
  });

  group('AttendancePredictor Tests', () {
    test('predictFutureAttendance normal case', () {
      // 27 attended out of 31 total classes, 10 remaining classes, recent rate of 80%
      final predicted = AttendancePredictor.predictFutureAttendance(
        attended: 27,
        total: 31,
        remaining: 10,
        recentRate: 0.8,
      );
      // forecasted present = 27 + (10 * 0.8) = 35
      // forecasted total = 31 + 10 = 41
      // predicted percentage = (35 / 41) * 100 = 85.365%
      expect(predicted.toStringAsFixed(1), '85.4');
    });

    test('predictFutureAttendance zero remaining classes returns current percentage', () {
      final predicted = AttendancePredictor.predictFutureAttendance(
        attended: 27,
        total: 31,
        remaining: 0,
        recentRate: 0.5,
      );
      expect(predicted.toStringAsFixed(1), '87.1');
    });
  });

  group('BunkAnalyzer Heuristic Tests', () {
    test('Critical status when percentage is below target', () {
      final analysis = BunkAnalyzer.analyze(
        currentPercentage: 70.0,
        targetPercentage: 75.0,
        safeBunks: 0,
        requiredClasses: 6,
      );
      expect(analysis.status, BunkStatus.CRITICAL);
      expect(analysis.statusText, 'Critical');
      expect(analysis.recommendation, contains('below target'));
    });

    test('Warning status when within narrow margin (<= 2.5%)', () {
      final analysis = BunkAnalyzer.analyze(
        currentPercentage: 76.5,
        targetPercentage: 75.0,
        safeBunks: 1,
        requiredClasses: 0,
      );
      expect(analysis.status, BunkStatus.WARNING);
      expect(analysis.statusText, 'Warning');
      expect(analysis.recommendation, contains('Narrow attendance margin'));
    });

    test('Normal status when above margin (> 2.5%)', () {
      final analysis = BunkAnalyzer.analyze(
        currentPercentage: 80.0,
        targetPercentage: 75.0,
        safeBunks: 3,
        requiredClasses: 0,
      );
      expect(analysis.status, BunkStatus.NORMAL);
      expect(analysis.statusText, 'Normal');
      expect(analysis.recommendation, contains('safe zone'));
    });
  });
}
