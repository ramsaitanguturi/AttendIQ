import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../database/isar_provider.dart';
import '../models/attendance_analytics.dart';
import '../models/risk_status.dart';
import '../calculators/analytics_calculator.dart';
import '../../../features/subject/presentation/controllers/subject_controller.dart';
import '../../../features/attendance/presentation/controllers/attendance_controller.dart';
import '../../../features/attendance/domain/entities/attendance_record.dart';
import '../../../features/semester/data/models/semester_local.dart';
import '../../../features/semester/data/repositories/semester_repository_impl.dart';
import '../../../features/semester/presentation/controllers/semester_controller.dart';
import '../../../features/subject/data/models/subject_local.dart';
import '../../../features/attendance/data/models/attendance_record_local.dart';
import '../../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../features/timetable/data/models/weekly_schedule_rule_local.dart';

part 'analytics_service.g.dart';

class AnalyticsService {
  final Isar _isar;
  final Ref _ref;

  AnalyticsService(this._isar, this._ref);

  Future<AttendanceAnalytics?> getAnalytics() async {
    // 1. Get active semester through canonical repository lookup
    final semester =
        await _ref.read(semesterRepositoryProvider).getActiveSemester();
    final semesterId =
        semester?.localId ?? resolveActiveSemesterLocal(_isar)?.id;
    if (semester == null || semesterId == null) return null;

    // 2. Fetch subjects for semester (including soft-deleted for historical records)
    final subjectRepo = _ref.read(subjectRepositoryProvider);
    final subjects = await subjectRepo.getSubjectsBySemester(semesterId,
        includeDeleted: true);
    if (subjects.isEmpty) {
      return AttendanceAnalytics(
        overallPercentage: 100.0,
        totalClasses: 0,
        totalPresent: 0,
        totalAbsent: 0,
        attendanceTrend: AttendanceTrend(
          daily: [TrendPoint(date: semester.startDate, percentage: 100.0)],
          weekly: [TrendPoint(date: semester.startDate, percentage: 100.0)],
          monthly: [TrendPoint(date: semester.startDate, percentage: 100.0)],
        ),
        subjectComparison: const SubjectComparison(),
        attendanceStreak:
            const AttendanceStreak(longestPresentStreak: 0, currentStreak: 0),
        riskLevel: RiskStatus.SAFE,
      );
    }

    // 3. Fetch attendance records
    final attendanceRepo = _ref.read(attendanceRepositoryProvider);
    final records = <AttendanceRecord>[];
    for (final subject in subjects) {
      if (subject.id != null) {
        final subRecords =
            await attendanceRepo.getAttendanceForSubject(subject.id!);
        records.addAll(subRecords);
      }
    }

    // 4. Fetch canonical schedule occurrences for semester subjects
    final subjectIds = subjects.map((s) => s.id!).toSet();
    final allOccurrences = _isar.dailyScheduleOccurrenceLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();
    final semesterOccurrences = allOccurrences
        .where((o) => o.subjectId != null && subjectIds.contains(o.subjectId))
        .toList();

    // 5. Build logged occurrences using canonical occurrenceId (no legacy eventId collision)
    final occurrences = <LoggedOccurrence>[];
    final occurrenceMap = <int, DailyScheduleOccurrenceLocal>{
      for (final o in semesterOccurrences) o.id: o,
    };
    for (final rec in records) {
      final occId = rec.occurrenceId;
      final occ = (occId != null && occId > 0) ? occurrenceMap[occId] : null;
      if (occ != null) {
        occurrences.add(LoggedOccurrence(
          date: occ.date,
          startTime: occ.startTime,
          status: rec.status,
        ));
      } else {
        occurrences.add(LoggedOccurrence(
          date: rec.markedAt,
          startTime: '09:00',
          status: rec.status,
        ));
      }
    }

    // 6. Compute analytics
    return AnalyticsCalculator.calculateOverallAnalytics(
      semester: semester,
      subjects: subjects,
      records: records,
      occurrences: occurrences,
    );
  }
}

@riverpod
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return AnalyticsService(isar, ref);
}

@riverpod
Future<AttendanceAnalytics?> attendanceAnalytics(
    AttendanceAnalyticsRef ref) async {
  ref.watch(activeSemesterProvider);
  final service = ref.watch(analyticsServiceProvider);

  // Re-run analytics whenever semester, subject, attendance, occurrence, or rule tables change.
  var isDisposed = false;
  ref.onDispose(() => isDisposed = true);

  final isar = ref.watch(isarProvider).requireValue;
  final watchStreams = <Stream<void>>[
    isar.semesterLocals.where().watchLazy(),
    isar.attendanceRecordLocals.where().watchLazy(),
    isar.subjectLocals.where().watchLazy(),
    isar.dailyScheduleOccurrenceLocals.where().watchLazy(),
    isar.weeklyScheduleRuleLocals.where().watchLazy(),
  ];
  for (final stream in watchStreams) {
    final sub = stream.listen((_) {
      if (!isDisposed) {
        ref.invalidateSelf();
      }
    });
    ref.onDispose(() => sub.cancel().catchError((Object _) {}));
  }

  return service.getAnalytics();
}
