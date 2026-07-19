import '../../../../features/semester/domain/entities/semester.dart';

class SemesterWeek {
  final int weekIndex; // 0-indexed (0..totalWeeks-1)
  final int weekNumber; // 1-indexed (1..totalWeeks)
  final DateTime startDate;
  final DateTime endDate;
  final List<DateTime> dates; // 7 dates: Monday..Sunday

  const SemesterWeek({
    required this.weekIndex,
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.dates,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemesterWeek &&
          runtimeType == other.runtimeType &&
          weekIndex == other.weekIndex &&
          weekNumber == other.weekNumber &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      weekIndex.hashCode ^
      weekNumber.hashCode ^
      startDate.hashCode ^
      endDate.hashCode;

  @override
  String toString() {
    return 'SemesterWeek(Week $weekNumber: $startDate to $endDate)';
  }
}

class SemesterWeekCalculator {
  /// Generate list of SemesterWeeks from a Semester object.
  static List<SemesterWeek> calculateWeeks(Semester semester) {
    final start = DateTime.utc(
      semester.startDate.year,
      semester.startDate.month,
      semester.startDate.day,
    );
    final end = DateTime.utc(
      semester.endDate.year,
      semester.endDate.month,
      semester.endDate.day,
    );

    // Align start to Monday of week 1
    final week1Start = start.subtract(Duration(days: start.weekday - 1));

    final totalDays = end.difference(week1Start).inDays + 1;
    var totalWeeks = (totalDays / 7.0).ceil();
    if (totalWeeks < 1) totalWeeks = 1;

    final weeks = <SemesterWeek>[];
    for (int i = 0; i < totalWeeks; i++) {
      final wStart = week1Start.add(Duration(days: i * 7));
      final wEnd = wStart.add(const Duration(days: 6));
      final dates = List.generate(7, (d) => wStart.add(Duration(days: d)));

      weeks.add(
        SemesterWeek(
          weekIndex: i,
          weekNumber: i + 1,
          startDate: wStart,
          endDate: wEnd,
          dates: dates,
        ),
      );
    }

    return weeks;
  }

  /// Find the week index corresponding to a specific date (e.g. today).
  /// Returns 0 if before semester start, or last week index if after semester end.
  static int getWeekIndexForDate(List<SemesterWeek> weeks, DateTime targetDate) {
    if (weeks.isEmpty) return 0;
    final target = DateTime.utc(targetDate.year, targetDate.month, targetDate.day);

    for (int i = 0; i < weeks.length; i++) {
      final w = weeks[i];
      if (!target.isBefore(w.startDate) && !target.isAfter(w.endDate)) {
        return i;
      }
    }

    if (target.isBefore(weeks.first.startDate)) {
      return 0;
    }
    return weeks.length - 1;
  }
}
