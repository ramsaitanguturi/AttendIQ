import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/services/historical_attendance_service.dart';
import '../../data/datasources/attendance_local_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import '../../../timetable/presentation/controllers/today_schedule_provider.dart';
import '../../../timetable/presentation/controllers/weekly_schedule_view_controller.dart';
import '../../../timetable/presentation/controllers/academic_calendar_controller.dart';
import 'subject_attendance_stats_provider.dart';
import '../../../analytics/presentation/controllers/analytics_controller.dart';
import '../../../../core/analytics/services/analytics_service.dart';
import '../../../analytics/presentation/controllers/reports_controller.dart';
import '../../../widgets/services/widget_refresh_service.dart';

part 'attendance_controller.g.dart';

@riverpod
AttendanceLocalDataSource attendanceLocalDataSource(
  AttendanceLocalDataSourceRef ref,
) {
  final isar = ref.watch(isarProvider).requireValue;
  return AttendanceLocalDataSourceImpl(isar);
}

@riverpod
AttendanceRepository attendanceRepository(AttendanceRepositoryRef ref) {
  return AttendanceRepositoryImpl(
    ref.watch(attendanceLocalDataSourceProvider),
  );
}

@riverpod
class AttendanceController extends _$AttendanceController {
  @override
  FutureOr<void> build() async {
    // Empty build
  }

  Future<DailyScheduleOccurrence> markOccurrencePresent(
    DailyScheduleOccurrence occurrence,
  ) async {
    final occurrenceRepo = ref.read(dailyScheduleOccurrenceRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final updatedOccurrence = occurrence.copyWith(
      status: OccurrenceStatus.present,
      updatedAt: DateTime.now().toUtc(),
    );

    final savedOccurrence =
        await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.subjectId != null &&
        savedOccurrence.id != null &&
        savedOccurrence.id! > 0) {
      final occId = savedOccurrence.id!;
      final existingRecord =
          await attendanceRepo.getAttendanceForOccurrenceAnyStatus(occId);
      final status = savedOccurrence.type == OccurrenceType.extraClass
          ? AttendanceStatus.extraPresent
          : AttendanceStatus.present;

      final record = AttendanceRecord(
        id: existingRecord?.id,
        serverId: existingRecord?.serverId,
        occurrenceId: occId,
        eventId: occId,
        subjectId: savedOccurrence.subjectId!,
        status: status,
        markedAt: savedOccurrence.date,
        updatedAt: DateTime.now().toUtc(),
        isDirty: false,
        isDeleted: false,
      );
      await attendanceRepo.saveAttendanceRecord(record);
    }

    _invalidateProviders();
    return savedOccurrence;
  }

  Future<DailyScheduleOccurrence> markOccurrenceAbsent(
    DailyScheduleOccurrence occurrence,
  ) async {
    final occurrenceRepo = ref.read(dailyScheduleOccurrenceRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final updatedOccurrence = occurrence.copyWith(
      status: OccurrenceStatus.absent,
      updatedAt: DateTime.now().toUtc(),
    );

    final savedOccurrence =
        await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.subjectId != null &&
        savedOccurrence.id != null &&
        savedOccurrence.id! > 0) {
      final occId = savedOccurrence.id!;
      final existingRecord =
          await attendanceRepo.getAttendanceForOccurrenceAnyStatus(occId);
      final status = savedOccurrence.type == OccurrenceType.extraClass
          ? AttendanceStatus.extraAbsent
          : AttendanceStatus.absent;

      final record = AttendanceRecord(
        id: existingRecord?.id,
        serverId: existingRecord?.serverId,
        occurrenceId: occId,
        eventId: occId,
        subjectId: savedOccurrence.subjectId!,
        status: status,
        markedAt: savedOccurrence.date,
        updatedAt: DateTime.now().toUtc(),
        isDirty: false,
        isDeleted: false,
      );
      await attendanceRepo.saveAttendanceRecord(record);
    }

    _invalidateProviders();
    return savedOccurrence;
  }

  Future<DailyScheduleOccurrence> markOccurrenceLate(
    DailyScheduleOccurrence occurrence,
  ) async {
    final occurrenceRepo = ref.read(dailyScheduleOccurrenceRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final updatedOccurrence = occurrence.copyWith(
      status: OccurrenceStatus.late,
      updatedAt: DateTime.now().toUtc(),
    );

    final savedOccurrence =
        await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.subjectId != null &&
        savedOccurrence.id != null &&
        savedOccurrence.id! > 0) {
      final occId = savedOccurrence.id!;
      final existingRecord =
          await attendanceRepo.getAttendanceForOccurrenceAnyStatus(occId);

      final record = AttendanceRecord(
        id: existingRecord?.id,
        serverId: existingRecord?.serverId,
        occurrenceId: occId,
        eventId: occId,
        subjectId: savedOccurrence.subjectId!,
        status: AttendanceStatus.late,
        markedAt: savedOccurrence.date,
        updatedAt: DateTime.now().toUtc(),
        isDirty: false,
        isDeleted: false,
      );
      await attendanceRepo.saveAttendanceRecord(record);
    }

    _invalidateProviders();
    return savedOccurrence;
  }

  Future<DailyScheduleOccurrence> markOccurrenceCancelled(
    DailyScheduleOccurrence occurrence,
  ) async {
    final occurrenceRepo = ref.read(dailyScheduleOccurrenceRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final updatedOccurrence = occurrence.copyWith(
      status: OccurrenceStatus.cancelled,
      updatedAt: DateTime.now().toUtc(),
    );

    final savedOccurrence =
        await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.id != null && savedOccurrence.id! > 0) {
      final existingRecord = await attendanceRepo
          .getAttendanceForOccurrenceAnyStatus(savedOccurrence.id!);
      if (existingRecord?.id != null) {
        await attendanceRepo.deleteAttendanceRecord(existingRecord!.id!);
      }
    }

    _invalidateProviders();
    return savedOccurrence;
  }

  Future<DailyScheduleOccurrence> addExtraClass({
    int? occurrenceId,
    required DateTime date,
    required int subjectId,
    String? subjectTitle,
    required String startTime,
    required String endTime,
    String? reason,
    AttendanceStatus? initialStatus,
  }) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final saved = await repo.saveExtraClassWithAttendance(
      occurrenceId: occurrenceId,
      subjectId: subjectId,
      date: date,
      subjectTitle: subjectTitle,
      startTime: startTime,
      endTime: endTime,
      reason: reason,
      status: initialStatus,
      autoAllocateSlot: false,
    );
    _invalidateProviders(subjectId: subjectId);
    return saved;
  }

  Future<void> markAttendance({
    required int eventId,
    required int subjectId,
    required AttendanceStatus status,
  }) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final occRepo = ref.read(dailyScheduleOccurrenceRepositoryProvider);

    final occ = await occRepo.getOccurrenceById(eventId);
    final existing = await repo.getAttendanceForOccurrenceAnyStatus(eventId);
    final now = DateTime.now().toUtc();

    if (status == AttendanceStatus.cancelled) {
      if (existing?.id != null) {
        await repo.deleteAttendanceRecord(existing!.id!);
      }
      await repo.updateEventStatus(eventId, _mapToEventStatus(status));
      _invalidateProviders();
      return;
    }

    final record = AttendanceRecord(
      id: existing?.id,
      serverId: existing?.serverId,
      occurrenceId: eventId,
      eventId: eventId,
      subjectId: subjectId,
      status: status,
      markedAt: occ != null ? occ.date : now,
      updatedAt: now,
      isDirty: false,
      isDeleted: false,
    );

    await repo.saveAttendanceRecord(record);
    await repo.updateEventStatus(eventId, _mapToEventStatus(status));
    _invalidateProviders();
  }

  Future<DailyScheduleOccurrence> markExtraClass({
    int? occurrenceId,
    required int subjectId,
    required DateTime date,
    required AttendanceStatus status,
    String? startTime,
    String? endTime,
    String? reason,
  }) async {
    if ((startTime == null) != (endTime == null)) {
      throw const ValidationException(
        'Both startTime and endTime must be provided together.',
        'INVALID_TIME_RANGE',
      );
    }

    final repo = ref.read(attendanceRepositoryProvider);
    final hasExplicitTimes = startTime != null && endTime != null;
    final saved = await repo.saveExtraClassWithAttendance(
      occurrenceId: occurrenceId,
      subjectId: subjectId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      reason: reason,
      status: status,
      autoAllocateSlot: occurrenceId == null && !hasExplicitTimes,
    );
    _invalidateProviders(subjectId: subjectId);
    return saved;
  }

  Future<DailyScheduleOccurrence> markHistoricalAttendance({
    required DateTime date,
    required int subjectId,
    int? occurrenceId,
    int? ruleId,
    required String startTime,
    required String endTime,
    required String title,
    String? room,
    required OccurrenceStatus targetStatus,
    OccurrenceType type = OccurrenceType.regularClass,
  }) async {
    final service = ref.read(historicalAttendanceServiceProvider);
    final result = await service.setAttendanceStatus(
      date: date,
      subjectId: subjectId,
      occurrenceId: occurrenceId,
      ruleId: ruleId,
      startTime: startTime,
      endTime: endTime,
      title: title,
      room: room,
      targetStatus: targetStatus,
      type: type,
    );
    _invalidateProviders(subjectId: subjectId);
    return result;
  }

  void _invalidateProviders({int? subjectId}) {
    ref.invalidate(todayScheduleProvider);
    ref.invalidate(todayOccurrencesProvider);
    ref.invalidate(dayScheduleByKeyProvider);
    if (subjectId != null) {
      ref.invalidate(subjectOccurrencesProvider(subjectId));
      ref.invalidate(subjectAttendanceStatsProvider(subjectId));
    } else {
      ref.invalidate(subjectOccurrencesProvider);
      ref.invalidate(subjectAttendanceStatsProvider);
    }
    ref.invalidate(allSubjectAttendanceStatsProvider);
    ref.invalidate(overallAttendancePercentageProvider);
    ref.invalidate(analyticsControllerProvider);
    ref.invalidate(attendanceAnalyticsProvider);
    ref.invalidate(reportsControllerProvider);
    ref.invalidate(allDailyOccurrencesProvider);
    ref.invalidate(monthlyCalendarDataProvider);
    try {
      ref.read(widgetRefreshServiceProvider).refreshAllWidgets();
    } catch (_) {}
  }

  String _mapToEventStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
      case AttendanceStatus.extraPresent:
        return 'PRESENT';
      case AttendanceStatus.absent:
      case AttendanceStatus.extraAbsent:
        return 'ABSENT';
      case AttendanceStatus.cancelled:
        return 'CANCELLED';
      case AttendanceStatus.late:
        return 'LATE';
    }
  }
}
