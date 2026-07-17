import 'risk_status.dart';
import 'subject_analytics.dart';

class TrendPoint {
  final DateTime date;
  final double percentage;

  const TrendPoint({
    required this.date,
    required this.percentage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendPoint &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          percentage == other.percentage;

  @override
  int get hashCode => date.hashCode ^ percentage.hashCode;

  @override
  String toString() => 'TrendPoint(date: $date, percentage: $percentage)';
}

class AttendanceTrend {
  final List<TrendPoint> daily;
  final List<TrendPoint> weekly;
  final List<TrendPoint> monthly;

  const AttendanceTrend({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });
}

class SubjectComparison {
  final SubjectAnalytics? highestAttendanceSubject;
  final SubjectAnalytics? lowestAttendanceSubject;
  final SubjectAnalytics? mostMissedSubject;
  final SubjectAnalytics? mostAttendedSubject;

  const SubjectComparison({
    this.highestAttendanceSubject,
    this.lowestAttendanceSubject,
    this.mostMissedSubject,
    this.mostAttendedSubject,
  });
}

class AttendanceStreak {
  final int longestPresentStreak;
  final int currentStreak;

  const AttendanceStreak({
    required this.longestPresentStreak,
    required this.currentStreak,
  });
}

class AttendanceAnalytics {
  final double overallPercentage;
  final int totalClasses;
  final int totalPresent;
  final int totalAbsent;
  final AttendanceTrend attendanceTrend;
  final SubjectComparison subjectComparison;
  final AttendanceStreak attendanceStreak;
  final RiskStatus riskLevel;

  const AttendanceAnalytics({
    required this.overallPercentage,
    required this.totalClasses,
    required this.totalPresent,
    required this.totalAbsent,
    required this.attendanceTrend,
    required this.subjectComparison,
    required this.attendanceStreak,
    required this.riskLevel,
  });
}
