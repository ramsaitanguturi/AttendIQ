import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../database/isar_provider.dart';
import '../models/attendance_analytics.dart';
import '../models/risk_status.dart';
import '../calculators/analytics_calculator.dart';
import '../../../features/auth/domain/entities/semester.dart';
import '../../../features/subject/presentation/controllers/subject_controller.dart';
import '../../../features/attendance/presentation/controllers/attendance_controller.dart';
import '../../../features/attendance/domain/entities/attendance_record.dart';
import '../../../features/auth/data/models/semester_local.dart';
import '../../../features/subject/data/models/subject_local.dart';
import '../../../features/attendance/data/models/attendance_record_local.dart';
import '../../event_generator/data/models/event_local.dart';

part 'analytics_service.g.dart';

class AnalyticsService {
  final Isar _isar;
  final Ref _ref;

  AnalyticsService(this._isar, this._ref);

  Future<AttendanceAnalytics?> getAnalytics() async {
    // 1. Get active semester
    final semesterLocal = _isar.semesterLocals
        .where()
        .isDeletedEqualTo(false)
        .findFirst();
    if (semesterLocal == null) return null;

    final semester = Semester(
      id: semesterLocal.serverId ?? semesterLocal.id.toString(),
      name: semesterLocal.name,
      startDate: semesterLocal.startDate,
      endDate: semesterLocal.endDate,
      requiredAttendanceRate: semesterLocal.requiredAttendanceRate,
    );

    // 2. Fetch subjects for semester
    final subjectRepo = _ref.read(subjectRepositoryProvider);
    final subjects = await subjectRepo.getSubjectsBySemester(semesterLocal.id);
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
        attendanceStreak: const AttendanceStreak(longestPresentStreak: 0, currentStreak: 0),
        riskLevel: RiskStatus.SAFE,
      );
    }

    // 3. Fetch attendance records
    final attendanceRepo = _ref.read(attendanceRepositoryProvider);
    final records = <AttendanceRecord>[];
    for (final subject in subjects) {
      if (subject.id != null) {
        final subRecords = await attendanceRepo.getAttendanceForSubject(subject.id!);
        records.addAll(subRecords);
      }
    }

    // 4. Fetch events
    final subjectIds = subjects.map((s) => s.id!).toSet();
    final allEvents = _isar.eventLocals.where().isDeletedEqualTo(false).findAll();
    final semesterEvents = allEvents.where((e) => subjectIds.contains(e.subjectId)).toList();

    // 5. Build logged occurrences
    final occurrences = <LoggedOccurrence>[];
    final eventMap = {for (var e in semesterEvents) e.id: e};
    for (final rec in records) {
      final event = eventMap[rec.eventId];
      if (event != null) {
        occurrences.add(LoggedOccurrence(
          date: event.date,
          startTime: event.startTime,
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
Future<AttendanceAnalytics?> attendanceAnalytics(AttendanceAnalyticsRef ref) async {
  final service = ref.watch(analyticsServiceProvider);

  // We want to re-run analytics whenever subject locals, attendance record locals or event locals change
  final isar = ref.watch(isarProvider).requireValue;
  
  final recStream = isar.attendanceRecordLocals.where().watchLazy();
  final recSub = recStream.listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(() => recSub.cancel());

  final subStream = isar.subjectLocals.where().watchLazy();
  final subSub = subStream.listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(() => subSub.cancel());

  final eventStream = isar.eventLocals.where().watchLazy();
  final eventSub = eventStream.listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(() => eventSub.cancel());

  return service.getAnalytics();
}
