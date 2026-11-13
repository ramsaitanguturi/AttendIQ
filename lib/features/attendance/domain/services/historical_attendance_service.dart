import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../timetable/data/utils/occurrence_identity.dart';
import '../../../timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../presentation/controllers/attendance_controller.dart';

final historicalAttendanceServiceProvider =
    Provider<HistoricalAttendanceService>((ref) {
  final occurrenceRepo = ref.watch(dailyScheduleOccurrenceRepositoryProvider);
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);
  return HistoricalAttendanceService(
    occurrenceRepository: occurrenceRepo,
    attendanceRepository: attendanceRepo,
  );
});

/// Centralized domain service responsible for mutating historical and current
/// class occurrences and persisting atomic attendance records across the application.
class HistoricalAttendanceService {
  final DailyScheduleOccurrenceRepository _occurrenceRepository;
  final AttendanceRepository _attendanceRepository;

  HistoricalAttendanceService({
    required DailyScheduleOccurrenceRepository occurrenceRepository,
    required AttendanceRepository attendanceRepository,
  })  : _occurrenceRepository = occurrenceRepository,
        _attendanceRepository = attendanceRepository;

  /// Modifies or records attendance for any scheduled class occurrence on [date].
  ///
  /// Supports all historical transitions:
  /// - Unmarked -> Present / Absent / Late / Cancelled
  /// - Present -> Absent / Late / Cancelled
  /// - Absent -> Present / Late / Cancelled
  /// - Late -> Present / Absent / Cancelled
  /// - Cancelled -> Present / Absent / Late / Unmarked
  ///
  /// Guarantees that:
  /// 1. The occurrence is materialized in Isar if it was only a virtual rule slot.
  /// 2. Occurrence status is updated with modification timestamp.
  /// 3. Attendance record is created, updated, or soft-deleted accordingly.
  Future<DailyScheduleOccurrence> setAttendanceStatus({
    required DateTime date,
    required int subjectId,
    int? occurrenceId,
    int? ruleId,
    required String startTime,
    required String endTime,
    required String title,
    String? room,
    required OccurrenceStatus targetStatus,
    OccurrenceType type = OccurrenceType.REGULAR_CLASS,
  }) async {
    final dateUtc = normalizeUtcDate(date);
    DailyScheduleOccurrence? occurrence;

    // 1. Locate existing occurrence by ID if provided
    if (occurrenceId != null && occurrenceId > 0) {
      occurrence = await _occurrenceRepository.getOccurrenceById(occurrenceId);
    }

    // 2. If not found by ID, search by date, subjectId, and startTime
    if (occurrence == null) {
      final allOnDate =
          await _occurrenceRepository.getOccurrencesForDate(dateUtc);
      for (final occ in allOnDate) {
        if (!occ.isDeleted &&
            occ.subjectId == subjectId &&
            occ.startTime == startTime) {
          occurrence = occ;
          break;
        }
      }
    }

    // 3. If no occurrence exists on disk yet, materialize it now
    if (occurrence == null) {
      final slotKey = computeCanonicalSlotKey(
        date: dateUtc,
        subjectId: subjectId,
        ruleId: ruleId,
        startTime: startTime,
        endTime: endTime,
        type: type.toShortString(),
        title: title,
      );

      final newOcc = DailyScheduleOccurrence(
        date: dateUtc,
        subjectId: subjectId,
        ruleId: ruleId,
        slotKey: slotKey,
        startTime: startTime,
        endTime: endTime,
        title: title,
        room: room,
        type: type,
        status: targetStatus,
        createdFrom: ruleId != null
            ? OccurrenceCreatedFrom.WEEKLY_RULE
            : OccurrenceCreatedFrom.MANUAL,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        isDirty: false,
        isDeleted: false,
      );
      occurrence = await _occurrenceRepository.saveOccurrence(newOcc);
    } else {
      // Update existing occurrence status and modification timestamp
      final updatedOcc = occurrence.copyWith(
        status: targetStatus,
        updatedAt: DateTime.now().toUtc(),
      );
      occurrence = await _occurrenceRepository.saveOccurrence(updatedOcc);
    }

    final occId = occurrence.id;
    if (occId != null && occId > 0 && occurrence.subjectId != null) {
      final existingRecord =
          await _attendanceRepository.getAttendanceForOccurrenceAnyStatus(occId);

      switch (targetStatus) {
        case OccurrenceStatus.PRESENT:
          final recStatus = occurrence.type == OccurrenceType.EXTRA_CLASS
              ? AttendanceStatus.EXTRA_PRESENT
              : AttendanceStatus.PRESENT;
          final record = AttendanceRecord(
            id: existingRecord?.id,
            serverId: existingRecord?.serverId,
            occurrenceId: occId,
            eventId: occId,
            subjectId: occurrence.subjectId!,
            status: recStatus,
            markedAt: occurrence.date,
            updatedAt: DateTime.now().toUtc(),
            isDirty: false,
            isDeleted: false,
          );
          await _attendanceRepository.saveAttendanceRecord(record);
          break;

        case OccurrenceStatus.ABSENT:
          final recStatus = occurrence.type == OccurrenceType.EXTRA_CLASS
              ? AttendanceStatus.EXTRA_ABSENT
              : AttendanceStatus.ABSENT;
          final record = AttendanceRecord(
            id: existingRecord?.id,
            serverId: existingRecord?.serverId,
            occurrenceId: occId,
            eventId: occId,
            subjectId: occurrence.subjectId!,
            status: recStatus,
            markedAt: occurrence.date,
            updatedAt: DateTime.now().toUtc(),
            isDirty: false,
            isDeleted: false,
          );
          await _attendanceRepository.saveAttendanceRecord(record);
          break;

        case OccurrenceStatus.LATE:
          final record = AttendanceRecord(
            id: existingRecord?.id,
            serverId: existingRecord?.serverId,
            occurrenceId: occId,
            eventId: occId,
            subjectId: occurrence.subjectId!,
            status: AttendanceStatus.LATE,
            markedAt: occurrence.date,
            updatedAt: DateTime.now().toUtc(),
            isDirty: false,
            isDeleted: false,
          );
          await _attendanceRepository.saveAttendanceRecord(record);
          break;

        case OccurrenceStatus.CANCELLED:
        case OccurrenceStatus.UPCOMING:
          // Invalidate/delete existing attendance record so it no longer counts
          if (existingRecord?.id != null) {
            await _attendanceRepository
                .deleteAttendanceRecord(existingRecord!.id!);
          }
          break;
      }
    }

    return occurrence;
  }
}
