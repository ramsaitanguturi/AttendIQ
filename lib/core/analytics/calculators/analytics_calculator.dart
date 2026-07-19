import '../../attendance_engine/calculator.dart';
import '../models/risk_status.dart';
import '../models/subject_analytics.dart';
import '../models/attendance_analytics.dart';
import '../../../features/subject/domain/entities/subject.dart';
import '../../../features/attendance/domain/entities/attendance_record.dart';
import '../../../features/semester/domain/entities/semester.dart';

class LoggedOccurrence {
  final DateTime date;
  final String startTime;
  final AttendanceStatus status;

  const LoggedOccurrence({
    required this.date,
    required this.startTime,
    required this.status,
  });
}

class AnalyticsCalculator {
  AnalyticsCalculator._();

  static SubjectAnalytics calculateSubjectAnalytics({
    required Subject subject,
    required List<AttendanceRecord> records,
  }) {
    int present = 0;
    int absent = 0;

    for (final record in records) {
      if (record.isDeleted) continue;
      if (record.status == AttendanceStatus.PRESENT ||
          record.status == AttendanceStatus.EXTRA_PRESENT) {
        present++;
      } else if (record.status == AttendanceStatus.ABSENT ||
          record.status == AttendanceStatus.EXTRA_ABSENT) {
        absent++;
      }
    }

    final totalClasses = present + absent;
    final percentage = AttendanceCalculator.calculatePercentage(
      attended: present,
      total: totalClasses,
    );

    final target = subject.attendanceTarget;
    final safeBunks = AttendanceCalculator.calculateSafeBunks(
      attended: present,
      total: totalClasses,
      target: target,
    );

    final classesNeeded = AttendanceCalculator.calculateRequiredClasses(
      attended: present,
      total: totalClasses,
      target: target,
    );

    // Risk Status:
    // SAFE: Attendance comfortably above target (percentage - target > 2.5)
    // WARNING: Near attendance limit (percentage >= target and percentage - target <= 2.5)
    // CRITICAL: Below target (percentage < target)
    RiskStatus riskStatus;
    if (percentage < target) {
      riskStatus = RiskStatus.CRITICAL;
    } else if (percentage - target <= 2.5) {
      riskStatus = RiskStatus.WARNING;
    } else {
      riskStatus = RiskStatus.SAFE;
    }

    return SubjectAnalytics(
      subjectId: subject.id ?? 0,
      subjectName: subject.name,
      percentage: percentage,
      present: present,
      absent: absent,
      totalClasses: totalClasses,
      safeBunks: safeBunks,
      classesNeeded: classesNeeded,
      riskStatus: riskStatus,
    );
  }

  static AttendanceAnalytics calculateOverallAnalytics({
    required Semester semester,
    required List<Subject> subjects,
    required List<AttendanceRecord> records,
    required List<LoggedOccurrence> occurrences,
  }) {
    // 1. Calculate subject analytics
    final List<SubjectAnalytics> subjectAnalyticsList = [];
    final Map<int, List<AttendanceRecord>> recordsBySubject = {};

    for (final sub in subjects) {
      recordsBySubject[sub.id!] = [];
    }
    for (final rec in records) {
      if (recordsBySubject.containsKey(rec.subjectId)) {
        recordsBySubject[rec.subjectId]!.add(rec);
      }
    }

    for (final sub in subjects) {
      subjectAnalyticsList.add(
        calculateSubjectAnalytics(
          subject: sub,
          records: recordsBySubject[sub.id!] ?? [],
        ),
      );
    }

    // 2. Overall statistics
    int totalPresent = 0;
    int totalAbsent = 0;
    for (final subAnalytic in subjectAnalyticsList) {
      totalPresent += subAnalytic.present;
      totalAbsent += subAnalytic.absent;
    }
    final totalClasses = totalPresent + totalAbsent;
    final overallPercentage = AttendanceCalculator.calculatePercentage(
      attended: totalPresent,
      total: totalClasses,
    );

    // 3. Subject comparison
    SubjectAnalytics? highestAttendanceSubject;
    SubjectAnalytics? lowestAttendanceSubject;
    SubjectAnalytics? mostMissedSubject;
    SubjectAnalytics? mostAttendedSubject;

    if (subjectAnalyticsList.isNotEmpty) {
      highestAttendanceSubject = subjectAnalyticsList.reduce((curr, next) =>
          curr.percentage > next.percentage ? curr : next);
      lowestAttendanceSubject = subjectAnalyticsList.reduce((curr, next) =>
          curr.percentage < next.percentage ? curr : next);
      mostMissedSubject = subjectAnalyticsList.reduce((curr, next) =>
          curr.absent > next.absent ? curr : next);
      mostAttendedSubject = subjectAnalyticsList.reduce((curr, next) =>
          curr.present > next.present ? curr : next);
    }

    final subjectComparison = SubjectComparison(
      highestAttendanceSubject: highestAttendanceSubject,
      lowestAttendanceSubject: lowestAttendanceSubject,
      mostMissedSubject: mostMissedSubject,
      mostAttendedSubject: mostAttendedSubject,
    );

    // 4. Streaks
    // Sort occurrences chronologically
    final List<LoggedOccurrence> sortedOccurrences = List.from(occurrences);
    sortedOccurrences.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.startTime.compareTo(b.startTime);
    });

    int longestPresentStreak = 0;
    int currentStreak = 0;

    for (final occ in sortedOccurrences) {
      if (occ.status == AttendanceStatus.PRESENT ||
          occ.status == AttendanceStatus.EXTRA_PRESENT) {
        currentStreak++;
        if (currentStreak > longestPresentStreak) {
          longestPresentStreak = currentStreak;
        }
      } else if (occ.status == AttendanceStatus.ABSENT ||
          occ.status == AttendanceStatus.EXTRA_ABSENT) {
        currentStreak = 0;
      }
      // CANCELLED is ignored and does not break or increment streak
    }

    final attendanceStreak = AttendanceStreak(
      longestPresentStreak: longestPresentStreak,
      currentStreak: currentStreak,
    );

    // 5. Risk Analysis
    final target = semester.requiredAttendanceRate;
    RiskStatus riskLevel;
    if (overallPercentage < target) {
      riskLevel = RiskStatus.CRITICAL;
    } else if (overallPercentage - target <= 2.5) {
      riskLevel = RiskStatus.WARNING;
    } else {
      riskLevel = RiskStatus.SAFE;
    }

    // 6. Trend Generation
    final attendanceTrend = _calculateTrend(
      semester: semester,
      occurrences: sortedOccurrences,
    );

    return AttendanceAnalytics(
      overallPercentage: overallPercentage,
      totalClasses: totalClasses,
      totalPresent: totalPresent,
      totalAbsent: totalAbsent,
      attendanceTrend: attendanceTrend,
      subjectComparison: subjectComparison,
      attendanceStreak: attendanceStreak,
      riskLevel: riskLevel,
    );
  }

  static AttendanceTrend _calculateTrend({
    required Semester semester,
    required List<LoggedOccurrence> occurrences,
  }) {
    if (occurrences.isEmpty) {
      final defaultPoint = TrendPoint(
        date: semester.startDate,
        percentage: 100.0,
      );
      return AttendanceTrend(
        daily: [defaultPoint],
        weekly: [defaultPoint],
        monthly: [defaultPoint],
      );
    }

    final List<TrendPoint> dailyPoints = [];
    final List<TrendPoint> weeklyPoints = [];
    final List<TrendPoint> monthlyPoints = [];

    // --- Daily Trend ---
    // Extract unique dates that have occurrences
    final Set<DateTime> uniqueDatesSet = {};
    for (final occ in occurrences) {
      final dateOnly = DateTime.utc(occ.date.year, occ.date.month, occ.date.day);
      uniqueDatesSet.add(dateOnly);
    }
    final List<DateTime> sortedDates = uniqueDatesSet.toList()..sort();

    for (final date in sortedDates) {
      int presentUpToDate = 0;
      int totalUpToDate = 0;

      for (final occ in occurrences) {
        final occDateOnly = DateTime.utc(occ.date.year, occ.date.month, occ.date.day);
        if (!occDateOnly.isAfter(date)) {
          if (occ.status == AttendanceStatus.PRESENT ||
              occ.status == AttendanceStatus.EXTRA_PRESENT) {
            presentUpToDate++;
            totalUpToDate++;
          } else if (occ.status == AttendanceStatus.ABSENT ||
              occ.status == AttendanceStatus.EXTRA_ABSENT) {
            totalUpToDate++;
          }
        }
      }

      final percentage = AttendanceCalculator.calculatePercentage(
        attended: presentUpToDate,
        total: totalUpToDate,
      );
      dailyPoints.add(TrendPoint(date: date, percentage: percentage));
    }

    // --- Weekly Trend ---
    // Calculate cumulative overall percentage at the end of each calendar week (Sunday)
    final semesterStart = DateTime.utc(
      semester.startDate.year,
      semester.startDate.month,
      semester.startDate.day,
    );
    final today = DateTime.now().toUtc();
    final semesterEnd = DateTime.utc(
      semester.endDate.year,
      semester.endDate.month,
      semester.endDate.day,
    );
    final limitDate = today.isBefore(semesterEnd) ? today : semesterEnd;

    // Find all Sundays from semester start to limitDate
    DateTime current = semesterStart;
    final List<DateTime> sundays = [];
    while (!current.isAfter(limitDate)) {
      if (current.weekday == DateTime.sunday) {
        sundays.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    // If no Sundays are in the range, or we want the start of semester to be included
    if (sundays.isEmpty) {
      sundays.add(limitDate);
    } else if (sundays.last.isBefore(limitDate)) {
      sundays.add(limitDate); // Make sure the last date is included
    }

    for (final sunday in sundays) {
      int presentUpToDate = 0;
      int totalUpToDate = 0;

      for (final occ in occurrences) {
        final occDateOnly = DateTime.utc(occ.date.year, occ.date.month, occ.date.day);
        if (!occDateOnly.isAfter(sunday)) {
          if (occ.status == AttendanceStatus.PRESENT ||
              occ.status == AttendanceStatus.EXTRA_PRESENT) {
            presentUpToDate++;
            totalUpToDate++;
          } else if (occ.status == AttendanceStatus.ABSENT ||
              occ.status == AttendanceStatus.EXTRA_ABSENT) {
            totalUpToDate++;
          }
        }
      }

      final percentage = AttendanceCalculator.calculatePercentage(
        attended: presentUpToDate,
        total: totalUpToDate,
      );
      weeklyPoints.add(TrendPoint(date: sunday, percentage: percentage));
    }

    // --- Monthly Trend ---
    // Calculate cumulative overall percentage at the end of each calendar month
    DateTime currentMonth = DateTime.utc(semesterStart.year, semesterStart.month, 1);
    final List<DateTime> monthEnds = [];
    while (!currentMonth.isAfter(limitDate)) {
      // Find the last day of currentMonth
      final nextMonth = DateTime.utc(currentMonth.year, currentMonth.month + 1, 1);
      final lastDay = nextMonth.subtract(const Duration(days: 1));
      if (!lastDay.isAfter(limitDate)) {
        monthEnds.add(lastDay);
      } else {
        monthEnds.add(limitDate);
      }
      currentMonth = nextMonth;
    }

    if (monthEnds.isEmpty) {
      monthEnds.add(limitDate);
    } else if (monthEnds.last.isBefore(limitDate)) {
      monthEnds.add(limitDate);
    }

    // De-duplicate monthEnds just in case
    final List<DateTime> uniqueMonthEnds = monthEnds.toSet().toList()..sort();

    for (final monthEnd in uniqueMonthEnds) {
      int presentUpToDate = 0;
      int totalUpToDate = 0;

      for (final occ in occurrences) {
        final occDateOnly = DateTime.utc(occ.date.year, occ.date.month, occ.date.day);
        if (!occDateOnly.isAfter(monthEnd)) {
          if (occ.status == AttendanceStatus.PRESENT ||
              occ.status == AttendanceStatus.EXTRA_PRESENT) {
            presentUpToDate++;
            totalUpToDate++;
          } else if (occ.status == AttendanceStatus.ABSENT ||
              occ.status == AttendanceStatus.EXTRA_ABSENT) {
            totalUpToDate++;
          }
        }
      }

      final percentage = AttendanceCalculator.calculatePercentage(
        attended: presentUpToDate,
        total: totalUpToDate,
      );
      monthlyPoints.add(TrendPoint(date: monthEnd, percentage: percentage));
    }

    return AttendanceTrend(
      daily: dailyPoints,
      weekly: weeklyPoints,
      monthly: monthlyPoints,
    );
  }
}
