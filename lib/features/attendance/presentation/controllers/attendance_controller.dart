import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../data/datasources/attendance_local_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import '../../../timetable/data/utils/occurrence_identity.dart';
import '../../../timetable/presentation/controllers/today_schedule_provider.dart';
import '../../../timetable/presentation/controllers/academic_calendar_controller.dart';
import 'subject_attendance_stats_provider.dart';
import '../../../analytics/presentation/controllers/analytics_controller.dart';
import '../../../analytics/presentation/controllers/reports_controller.dart';
import '../../../widgets/services/widget_refresh_service.dart';

part 'attendance_controller.g.dart';

@riverpod
AttendanceLocalDataSource attendanceLocalDataSource(AttendanceLocalDataSourceRef ref) {
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

  Future<DailyScheduleOccurrence> markOccurrencePresent(DailyScheduleOccurrence occurrence) async {
    final occurrenceRepo = ref.read(dailyScheduleOccurrenceRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final updatedOccurrence = occurrence.copyWith(
      status: OccurrenceStatus.PRESENT,
      updatedAt: DateTime.now().toUtc(),
    );

    final savedOccurrence = await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.subjectId != null && savedOccurrence.id != null && savedOccurrence.id! > 0) {
      final occId = savedOccurrence.id!;
      final existingRecord = await attendanceRepo.getAttendanceForOccurrenceAnyStatus(occId);
      final status = savedOccurrence.type == OccurrenceType.EXTRA_CLASS
          ? AttendanceStatus.EXTRA_PRESENT
          : AttendanceStatus.PRESENT;

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

  Future<DailyScheduleOccurrence> markOccurrenceAbsent(DailyScheduleOccurrence occurrence) async {
    final occurrenceRepo = ref.read(dailyScheduleOccurrenceRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final updatedOccurrence = occurrence.copyWith(
      status: OccurrenceStatus.ABSENT,
      updatedAt: DateTime.now().toUtc(),
    );

    final savedOccurrence = await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.subjectId != null && savedOccurrence.id != null && savedOccurrence.id! > 0) {
      final occId = savedOccurrence.id!;
      final existingRecord = await attendanceRepo.getAttendanceForOccurrenceAnyStatus(occId);
      final status = savedOccurrence.type == OccurrenceType.EXTRA_CLASS
          ? AttendanceStatus.EXTRA_ABSENT
          : AttendanceStatus.ABSENT;

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

  Future<DailyScheduleOccurrence> markOccurrenceCancelled(DailyScheduleOccurrence occurrence) async {
    final occurrenceRepo = ref.read(dailyScheduleOccurrenceRepositoryProvider);
    final attendanceRepo = ref.read(attendanceRepositoryProvider);

    final updatedOccurrence = occurrence.copyWith(
      status: OccurrenceStatus.CANCELLED,
      updatedAt: DateTime.now().toUtc(),
    );

    final savedOccurrence = await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.id != null && savedOccurrence.id! > 0) {
      final existingRecord =
          await attendanceRepo.getAttendanceForOccurrenceAnyStatus(savedOccurrence.id!);
      if (existingRecord?.id != null) {
        await attendanceRepo.deleteAttendanceRecord(existingRecord!.id!);
      }
    }

    _invalidateProviders();
    return savedOccurrence;
  }

  Future<DailyScheduleOccurrence> addExtraClass({
    required DateTime date,
    required int subjectId,
    required String subjectTitle,
    required String startTime,
    required String endTime,
    String? reason,
  }) async {
    final occurrenceRepo = ref.read(dailyScheduleOccurrenceRepositoryProvider);
    final dateUtc = normalizeUtcDate(date);
    final now = DateTime.now().toUtc();

    final occurrence = DailyScheduleOccurrence(
      date: dateUtc,
      subjectId: subjectId,
      title: subjectTitle,
      startTime: normalizeTimeSlotPart(startTime),
      endTime: normalizeTimeSlotPart(endTime),
      type: OccurrenceType.EXTRA_CLASS,
      status: OccurrenceStatus.UPCOMING,
      createdFrom: OccurrenceCreatedFrom.MANUAL,
      reason: reason,
      createdAt: now,
      updatedAt: now,
    );

    final saved = await occurrenceRepo.saveOccurrence(occurrence);
    _invalidateProviders();
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

    if (status == AttendanceStatus.CANCELLED) {
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

  Future<void> markExtraClass({
    required int subjectId,
    required DateTime date,
    required AttendanceStatus status,
  }) async {
    final repo = ref.read(attendanceRepositoryProvider);
    final dateUtc = normalizeUtcDate(date);
    final now = DateTime.now().toUtc();

    final occId = await repo.createExtraClassEvent(
      subjectId,
      dateUtc,
      _mapToEventStatus(status),
    );

    final record = AttendanceRecord(
      occurrenceId: occId,
      eventId: occId,
      subjectId: subjectId,
      status: status,
      markedAt: dateUtc,
      updatedAt: now,
      isDirty: false,
      isDeleted: false,
    );

    await repo.saveAttendanceRecord(record);
    _invalidateProviders();
  }

  void _invalidateProviders() {
    ref.invalidate(todayScheduleProvider);
    ref.invalidate(todayOccurrencesProvider);
    ref.invalidate(allSubjectAttendanceStatsProvider);
    ref.invalidate(overallAttendancePercentageProvider);
    ref.invalidate(analyticsControllerProvider);
    ref.invalidate(reportsControllerProvider);
    ref.invalidate(monthlyCalendarDataProvider);
    try {
      ref.read(widgetRefreshServiceProvider).refreshAllWidgets();
    } catch (_) {}
  }

  String _mapToEventStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.PRESENT:
      case AttendanceStatus.EXTRA_PRESENT:
        return 'PRESENT';
      case AttendanceStatus.ABSENT:
      case AttendanceStatus.EXTRA_ABSENT:
        return 'ABSENT';
      case AttendanceStatus.CANCELLED:
        return 'CANCELLED';
    }
  }
}
