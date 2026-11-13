import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../../core/attendance_engine/calculator.dart';
import '../../../../core/attendance_engine/predictor.dart';
import '../../../../core/attendance_engine/bunk_analyzer.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../domain/entities/attendance_record.dart';
import 'attendance_controller.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../timetable/data/models/weekly_schedule_rule_local.dart';
import '../../../timetable/data/utils/occurrence_identity.dart';
import '../../../timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../timetable/domain/entities/schedule_exception.dart';
import '../../../timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import '../../../timetable/presentation/controllers/timetable_controller.dart';
import '../../../timetable/presentation/controllers/today_schedule_provider.dart';

part 'subject_attendance_stats_provider.g.dart';

class SubjectAttendanceStats {
  final Subject subject;
  final double attendancePercentage;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int totalClasses;
  final int safeBunks;
  final int? requiredClasses;
  final double predictedPercentage;
  final BunkAnalysis bunkAnalysis;

  SubjectAttendanceStats({
    required this.subject,
    required this.attendancePercentage,
    required this.presentCount,
    required this.absentCount,
    this.lateCount = 0,
    required this.totalClasses,
    required this.safeBunks,
    this.requiredClasses,
    required this.predictedPercentage,
    required this.bunkAnalysis,
  });
}

@riverpod
Future<SubjectAttendanceStats?> subjectAttendanceStats(
  SubjectAttendanceStatsRef ref,
  int subjectId,
) async {
  final repo = ref.watch(subjectRepositoryProvider);
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);
  final ruleRepo = ref.watch(weeklyScheduleRuleRepositoryProvider);

  var isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  // Watch attendance changes using repository stream
  final stream = attendanceRepo.watchAttendance(subjectId);
  final sub = stream.listen((_) {
    if (!isDisposed) {
      ref.invalidateSelf();
    }
  });
  ref.onDispose(() => sub.cancel().catchError((Object _) {}));

  // Watch canonical weekly schedule rules if database is open
  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar != null && isar.isOpen) {
    final ruleSub =
        isar.weeklyScheduleRuleLocals.where().watchLazy().listen((_) {
      if (!isDisposed) {
        ref.invalidateSelf();
      }
    });
    ref.onDispose(() => ruleSub.cancel().catchError((Object _) {}));
  }

  // 1. Fetch Subject
  final subject = await repo.getSubjectById(subjectId);
  if (subject == null) return null;

  // 2. Fetch active semester for end date
  final semester = await ref.watch(activeSemesterProvider.future);
  if (semester == null) return null;

  // 3. Fetch all attendance records for this subject
  final records = await attendanceRepo.getAttendanceForSubject(subjectId);

  // 4. Calculate present, absent, and late counts
  int present = 0;
  int absent = 0;
  int lateCount = 0;
  for (final r in records) {
    if (r.status == AttendanceStatus.PRESENT ||
        r.status == AttendanceStatus.EXTRA_PRESENT) {
      present++;
    } else if (r.status == AttendanceStatus.ABSENT ||
        r.status == AttendanceStatus.EXTRA_ABSENT) {
      absent++;
    } else if (r.status == AttendanceStatus.LATE) {
      lateCount++;
    }
  }

  // Calculate effective attended based on user preferences
  double lateWeight = 0.5;
  try {
    final prefs = ref.watch(settingsControllerProvider).valueOrNull;
    if (prefs != null) {
      if (prefs.lateAttendancePolicy == 'present') {
        lateWeight = 1.0;
      } else if (prefs.lateAttendancePolicy == 'absent') {
        lateWeight = 0.0;
      } else {
        lateWeight = prefs.lateAttendanceWeight;
      }
    }
  } catch (_) {}

  final effectiveAttended = present + (lateCount * lateWeight);
  final total = present + absent + lateCount;

  // 5. Calculate percentage, safe bunks, must-attend
  final target = subject.attendanceTarget;
  final percentage =
      AttendanceCalculator.calculatePercentage(attended: effectiveAttended, total: total);
  final safeBunks = AttendanceCalculator.calculateSafeBunks(
      attended: effectiveAttended, total: total, target: target);
  final requiredClasses = AttendanceCalculator.calculateRequiredClasses(
      attended: effectiveAttended, total: total, target: target);

  // 6. Calculate remaining classes using canonical WeeklyScheduleRuleRepository,
  // accounting for schedule exceptions (holidays, cancelled classes) and already-marked classes today
  final rules = await ruleRepo.getRulesForSubject(subjectId);
  final activeRuleWeekdays = rules
      .where((r) => r.isActive && !r.isDeleted)
      .map((r) => r.dayOfWeek)
      .toList();

  int remaining = 0;
  final today = DateTime.now();
  final todayUtc = normalizeUtcDate(today);
  final endUtc = normalizeUtcDate(semester.endDate);

  if (!todayUtc.isAfter(endUtc)) {
    // Fetch exceptions across semester range
    List<ScheduleException> exceptions = [];
    try {
      final exceptionRepo = ref.watch(scheduleExceptionRepositoryProvider);
      exceptions = await exceptionRepo.getExceptionsForRange(todayUtc, endUtc);
    } catch (_) {}

    final holidayDates = <String>{};
    final cancelledDatesForSubject = <String>{};
    for (final ex in exceptions) {
      if (ex.isDeleted) continue;
      final exDateKey = formatUtcDateKey(ex.date);
      if (ex.type == ScheduleExceptionType.HOLIDAY) {
        holidayDates.add(exDateKey);
      } else if (ex.type == ScheduleExceptionType.CANCELLED_CLASS &&
          (ex.subjectId == null || ex.subjectId == subjectId)) {
        cancelledDatesForSubject.add(exDateKey);
      }
    }

    // Classes already marked today for this subject
    final alreadyMarkedTodayCount = records
        .where((r) =>
            !r.isDeleted &&
            normalizeUtcDate(r.markedAt).isAtSameMomentAs(todayUtc))
        .length;

    DateTime current = todayUtc;
    while (!current.isAfter(endUtc)) {
      final dateKey = formatUtcDateKey(current);
      if (!holidayDates.contains(dateKey) &&
          !cancelledDatesForSubject.contains(dateKey)) {
        final scheduledForDay =
            activeRuleWeekdays.where((int w) => w == current.weekday).length;
        if (current.isAtSameMomentAs(todayUtc)) {
          // On today, deduct classes that have already been marked
          final remainingToday = scheduledForDay - alreadyMarkedTodayCount;
          if (remainingToday > 0) {
            remaining += remainingToday;
          }
        } else {
          remaining += scheduledForDay;
        }
      }
      current = current.add(const Duration(days: 1));
    }
  }

  // 7. Calculate recent attendance rate (using normalized 30-day UTC window)
  final lifetimeRate = total > 0 ? (present / total) : 1.0;
  final thirtyDaysAgoUtc = todayUtc.subtract(const Duration(days: 30));
  final recentRecords = records.where((AttendanceRecord r) {
    if (r.isDeleted) return false;
    final recordDate = normalizeUtcDate(r.markedAt);
    return !recordDate.isBefore(thirtyDaysAgoUtc);
  }).toList();

  int recentPresent = 0;
  int recentTotal = 0;
  for (final r in recentRecords) {
    if (r.status == AttendanceStatus.PRESENT ||
        r.status == AttendanceStatus.EXTRA_PRESENT) {
      recentPresent++;
      recentTotal++;
    } else if (r.status == AttendanceStatus.ABSENT ||
        r.status == AttendanceStatus.EXTRA_ABSENT) {
      recentTotal++;
    }
  }

  final recentRate = (records.length < 10 || recentTotal == 0)
      ? lifetimeRate
      : (recentPresent / recentTotal);

  // 8. Predict future attendance
  final predictedPercentage = AttendancePredictor.predictFutureAttendance(
    attended: present,
    total: total,
    remaining: remaining,
    recentRate: recentRate,
  );

  // 9. Analyze bunk warnings
  final bunkAnalysis = BunkAnalyzer.analyze(
    currentPercentage: percentage,
    targetPercentage: target,
    safeBunks: safeBunks,
    requiredClasses: requiredClasses,
  );

  return SubjectAttendanceStats(
    subject: subject,
    attendancePercentage: percentage,
    presentCount: present,
    absentCount: absent,
    lateCount: lateCount,
    totalClasses: total,
    safeBunks: safeBunks,
    requiredClasses: requiredClasses,
    predictedPercentage: predictedPercentage,
    bunkAnalysis: bunkAnalysis,
  );
}

@riverpod
Future<List<SubjectAttendanceStats>> allSubjectAttendanceStats(
    AllSubjectAttendanceStatsRef ref) async {
  final semester = await ref.watch(activeSemesterProvider.future);
  if (semester == null || semester.localId == null) return const [];

  final subjects = await ref
      .watch(subjectRepositoryProvider)
      .getSubjectsBySemester(semester.localId!);
  final List<SubjectAttendanceStats> statsList = [];
  for (final sub in subjects) {
    final stats =
        await ref.watch(subjectAttendanceStatsProvider(sub.id!).future);
    if (stats != null) {
      statsList.add(stats);
    }
  }
  return statsList;
}

@riverpod
Future<double> overallAttendancePercentage(
    OverallAttendancePercentageRef ref) async {
  final statsList = await ref.watch(allSubjectAttendanceStatsProvider.future);
  if (statsList.isEmpty) return 100.0;

  int totalPresent = 0;
  int totalLate = 0;
  int totalClasses = 0;

  for (final stats in statsList) {
    totalPresent += stats.presentCount;
    totalLate += stats.lateCount;
    totalClasses += stats.totalClasses;
  }

  if (totalClasses == 0) return 100.0;
  double lateWeight = 0.5;
  try {
    final prefs = ref.watch(settingsControllerProvider).valueOrNull;
    if (prefs != null) {
      if (prefs.lateAttendancePolicy == 'present') {
        lateWeight = 1.0;
      } else if (prefs.lateAttendancePolicy == 'absent') {
        lateWeight = 0.0;
      } else {
        lateWeight = prefs.lateAttendanceWeight;
      }
    }
  } catch (_) {}

  final effectiveAttended = totalPresent + (totalLate * lateWeight);
  return (effectiveAttended / totalClasses) * 100.0;
}

@riverpod
Future<List<DailyScheduleOccurrence>> subjectOccurrences(
    SubjectOccurrencesRef ref, int subjectId) async {
  var isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final isar = ref.watch(isarProvider).valueOrNull;
  if (isar != null && isar.isOpen) {
    final stream = isar.dailyScheduleOccurrenceLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .watch();
    final sub = stream.listen((_) {
      if (!isDisposed) {
        ref.invalidateSelf();
      }
    });
    ref.onDispose(() => sub.cancel().catchError((Object _) {}));
  }

  final repo = ref.watch(dailyScheduleOccurrenceRepositoryProvider);
  final list = await repo.getOccurrencesForSubject(subjectId);
  list.sort((a, b) {
    final dateCmp = b.date.compareTo(a.date);
    if (dateCmp != 0) return dateCmp;
    return b.startTime.compareTo(a.startTime);
  });
  return list;
}

@riverpod
Future<List<DailyScheduleOccurrence>> todayOccurrences(
    TodayOccurrencesRef ref) async {
  final scheduleState = await ref.watch(todayScheduleProvider().future);
  return scheduleState.occurrences;
}
