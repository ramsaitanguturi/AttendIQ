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
import '../../../timetable/presentation/controllers/timetable_controller.dart';
import '../../../../core/event_generator/data/models/event_local.dart';

part 'subject_attendance_stats_provider.g.dart';

class SubjectAttendanceStats {
  final Subject subject;
  final double attendancePercentage;
  final int presentCount;
  final int absentCount;
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
  final timetableRepo = ref.watch(timetableRepositoryProvider);

  // Watch attendance changes using repository stream
  final stream = attendanceRepo.watchAttendance(subjectId);
  final sub = stream.listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(() => sub.cancel());

  // 1. Fetch Subject
  final subject = await repo.getSubjectById(subjectId);
  if (subject == null) return null;

  // 2. Fetch active semester for end date
  final semester = await ref.watch(semesterRepositoryProvider).getActiveSemester();
  if (semester == null) return null;

  // 3. Fetch all attendance records for this subject
  final records = await attendanceRepo.getAttendanceForSubject(subjectId);

  // 4. Calculate present, absent counts
  int present = 0;
  int absent = 0;
  for (final r in records) {
    if (r.status == AttendanceStatus.PRESENT || r.status == AttendanceStatus.EXTRA_PRESENT) {
      present++;
    } else if (r.status == AttendanceStatus.ABSENT || r.status == AttendanceStatus.EXTRA_ABSENT) {
      absent++;
    }
  }
  final total = present + absent;

  // 5. Calculate percentage, safe bunks, must-attend
  final target = subject.attendanceTarget;
  final percentage = AttendanceCalculator.calculatePercentage(attended: present, total: total);
  final safeBunks = AttendanceCalculator.calculateSafeBunks(attended: present, total: total, target: target);
  final requiredClasses = AttendanceCalculator.calculateRequiredClasses(attended: present, total: total, target: target);

  // 6. Calculate remaining classes using repository
  final templates = await timetableRepo.getTemplatesForSubject(subjectId);
  final templateWeekdays = templates.map((t) => t.weekday).toList();

  int remaining = 0;
  final today = DateTime.now();
  if (today.isBefore(semester.endDate)) {
    // Count remaining scheduled classes starting from today
    DateTime current = DateTime.utc(today.year, today.month, today.day);
    final end = DateTime.utc(semester.endDate.year, semester.endDate.month, semester.endDate.day);
    while (!current.isAfter(end)) {
      remaining += templateWeekdays.where((int w) => w == current.weekday).length;
      current = current.add(const Duration(days: 1));
    }
  }

  // 7. Calculate recent attendance rate
  final lifetimeRate = total > 0 ? (present / total) : 1.0;
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  final recentRecords = records.where((AttendanceRecord r) => r.markedAt.isAfter(thirtyDaysAgo)).toList();

  int recentPresent = 0;
  int recentTotal = 0;
  for (final r in recentRecords) {
    if (r.status == AttendanceStatus.PRESENT || r.status == AttendanceStatus.EXTRA_PRESENT) {
      recentPresent++;
      recentTotal++;
    } else if (r.status == AttendanceStatus.ABSENT || r.status == AttendanceStatus.EXTRA_ABSENT) {
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
    totalClasses: total,
    safeBunks: safeBunks,
    requiredClasses: requiredClasses,
    predictedPercentage: predictedPercentage,
    bunkAnalysis: bunkAnalysis,
  );
}

@riverpod
Future<List<SubjectAttendanceStats>> allSubjectAttendanceStats(AllSubjectAttendanceStatsRef ref) async {
  final semester = await ref.watch(semesterRepositoryProvider).getActiveSemester();
  if (semester == null || semester.localId == null) return const [];

  final subjects = await ref.watch(subjectRepositoryProvider).getSubjectsBySemester(semester.localId!);
  final List<SubjectAttendanceStats> statsList = [];
  for (final sub in subjects) {
    final stats = await ref.watch(subjectAttendanceStatsProvider(sub.id!).future);
    if (stats != null) {
      statsList.add(stats);
    }
  }
  return statsList;
}

@riverpod
Future<double> overallAttendancePercentage(OverallAttendancePercentageRef ref) async {
  final statsList = await ref.watch(allSubjectAttendanceStatsProvider.future);
  if (statsList.isEmpty) return 100.0;

  int totalPresent = 0;
  int totalClasses = 0;

  for (final stats in statsList) {
    totalPresent += stats.presentCount;
    totalClasses += stats.totalClasses;
  }

  if (totalClasses == 0) return 100.0;
  return (totalPresent / totalClasses) * 100.0;
}

@riverpod
Future<List<EventLocal>> subjectEvents(SubjectEventsRef ref, int subjectId) async {
  final isar = ref.watch(isarProvider).requireValue;

  final stream = isar.eventLocals.where().subjectIdEqualTo(subjectId).watch();
  final sub = stream.listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(() => sub.cancel());

  final list = isar.eventLocals
      .where()
      .subjectIdEqualTo(subjectId)
      .isDeletedEqualTo(false)
      .findAll();
  
  list.sort((EventLocal a, EventLocal b) => b.date.compareTo(a.date));
  return list;
}

@riverpod
Future<List<EventLocal>> todayEvents(TodayEventsRef ref) async {
  final isar = ref.watch(isarProvider).requireValue;
  final now = DateTime.now();
  final todayUtc = DateTime.utc(now.year, now.month, now.day);

  final stream = isar.eventLocals.where().dateEqualTo(todayUtc).watch();
  final sub = stream.listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(() => sub.cancel());

  final list = isar.eventLocals
      .where()
      .dateEqualTo(todayUtc)
      .isDeletedEqualTo(false)
      .findAll();
  
  list.sort((EventLocal a, EventLocal b) => a.startTime.compareTo(b.startTime));
  return list;
}
