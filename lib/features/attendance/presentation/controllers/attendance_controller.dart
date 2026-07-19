import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../data/datasources/attendance_local_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import '../../../timetable/presentation/controllers/today_schedule_provider.dart';
import 'subject_attendance_stats_provider.dart';
import '../../../analytics/presentation/controllers/analytics_controller.dart';

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
      updatedAt: DateTime.now(),
    );

    final savedOccurrence = await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.subjectId != null) {
      final eventId = savedOccurrence.id ?? 0;
      final existingRecord = await attendanceRepo.getAttendanceForEvent(eventId);
      final status = savedOccurrence.type == OccurrenceType.EXTRA_CLASS
          ? AttendanceStatus.EXTRA_PRESENT
          : AttendanceStatus.PRESENT;

      final record = AttendanceRecord(
        id: existingRecord?.id,
        serverId: existingRecord?.serverId,
        eventId: eventId,
        subjectId: savedOccurrence.subjectId!,
        status: status,
        markedAt: savedOccurrence.date,
        updatedAt: DateTime.now(),
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
      updatedAt: DateTime.now(),
    );

    final savedOccurrence = await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.subjectId != null) {
      final eventId = savedOccurrence.id ?? 0;
      final existingRecord = await attendanceRepo.getAttendanceForEvent(eventId);
      final status = savedOccurrence.type == OccurrenceType.EXTRA_CLASS
          ? AttendanceStatus.EXTRA_ABSENT
          : AttendanceStatus.ABSENT;

      final record = AttendanceRecord(
        id: existingRecord?.id,
        serverId: existingRecord?.serverId,
        eventId: eventId,
        subjectId: savedOccurrence.subjectId!,
        status: status,
        markedAt: savedOccurrence.date,
        updatedAt: DateTime.now(),
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
      updatedAt: DateTime.now(),
    );

    final savedOccurrence = await occurrenceRepo.saveOccurrence(updatedOccurrence);

    if (savedOccurrence.id != null) {
      final existingRecord = await attendanceRepo.getAttendanceForEvent(savedOccurrence.id!);
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
    final dateUtc = DateTime.utc(date.year, date.month, date.day);

    final occurrence = DailyScheduleOccurrence(
      date: dateUtc,
      subjectId: subjectId,
      title: subjectTitle,
      startTime: startTime,
      endTime: endTime,
      type: OccurrenceType.EXTRA_CLASS,
      status: OccurrenceStatus.UPCOMING,
      createdFrom: OccurrenceCreatedFrom.MANUAL,
      reason: reason,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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

    final existing = await repo.getAttendanceForEvent(eventId);
    final record = AttendanceRecord(
      id: existing?.id,
      serverId: existing?.serverId,
      eventId: eventId,
      subjectId: subjectId,
      status: status,
      markedAt: DateTime.now(),
      updatedAt: DateTime.now(),
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

    final eventId = await repo.createExtraClassEvent(
      subjectId,
      date,
      _mapToEventStatus(status),
    );

    final record = AttendanceRecord(
      eventId: eventId,
      subjectId: subjectId,
      status: status,
      markedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: false,
      isDeleted: false,
    );

    await repo.saveAttendanceRecord(record);
    _invalidateProviders();
  }

  void _invalidateProviders() {
    ref.invalidate(todayScheduleProvider);
    ref.invalidate(allSubjectAttendanceStatsProvider);
    ref.invalidate(analyticsControllerProvider);
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
