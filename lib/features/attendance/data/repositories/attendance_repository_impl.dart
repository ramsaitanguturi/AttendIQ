import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_data_source.dart';
import '../models/attendance_record_local.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../../timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../timetable/domain/entities/daily_schedule_occurrence.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource _localDataSource;

  AttendanceRepositoryImpl(this._localDataSource);

  AttendanceRecord _toEntity(AttendanceRecordLocal local) {
    return AttendanceRecord(
      id: local.id,
      serverId: local.serverId,
      occurrenceId: local.occurrenceId,
      legacyEventId: local.legacyEventId,
      eventId: local.occurrenceId ?? local.eventId,
      subjectId: local.subjectId,
      status: AttendanceStatus.fromString(local.status),
      markedAt: local.markedAt,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  AttendanceRecordLocal _toLocal(AttendanceRecord entity) {
    final resolvedOccurrenceId = entity.occurrenceId ??
        (entity.eventId > 0 && entity.legacyEventId == null
            ? entity.eventId
            : null);
    return AttendanceRecordLocal()
      ..id = entity.id ?? 0
      ..serverId = entity.serverId
      ..occurrenceId = resolvedOccurrenceId
      ..legacyEventId = entity.legacyEventId
      ..eventId = resolvedOccurrenceId ?? entity.eventId
      ..subjectId = entity.subjectId
      ..status = entity.status.toShortString()
      ..markedAt = entity.markedAt
      ..updatedAt = entity.updatedAt
      ..isDirty = entity.isDirty
      ..isDeleted = entity.isDeleted;
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId) async {
    final list = await _localDataSource.getAttendanceForSubject(subjectId);
    return list.map(_toEntity).toList();
  }

  @override
  Future<AttendanceRecord?> getAttendanceForOccurrence(int occurrenceId) async {
    final local =
        await _localDataSource.getAttendanceForOccurrence(occurrenceId);
    if (local != null) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<AttendanceRecord?> getAttendanceForOccurrenceAnyStatus(
    int occurrenceId,
  ) async {
    final local = await _localDataSource
        .getAttendanceForOccurrenceAnyStatus(occurrenceId);
    if (local != null) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId) =>
      getAttendanceForOccurrence(eventId);

  @override
  Future<AttendanceRecord?> getAttendanceForEventAnyStatus(int eventId) =>
      getAttendanceForOccurrenceAnyStatus(eventId);

  @override
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    final targetOccId = record.occurrenceId ??
        (record.eventId > 0 && record.legacyEventId == null
            ? record.eventId
            : null);
    final existing = (targetOccId != null && targetOccId > 0)
        ? await _localDataSource
            .getAttendanceForOccurrenceAnyStatus(targetOccId)
        : null;
    final serverId = record.serverId ?? existing?.serverId ?? generateUuid();
    final now = DateTime.now().toUtc();

    final local = _toLocal(record)
      ..id = record.id ?? existing?.id ?? 0
      ..serverId = serverId
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;

    local.createdAt = existing?.createdAt ?? now;

    await _localDataSource.saveAttendanceRecord(local);
  }

  @override
  Future<void> deleteAttendanceRecord(int id) async {
    final local = await _localDataSource.getAttendanceRecordById(id);
    if (local != null) {
      final now = DateTime.now().toUtc();
      local.isDeleted = true;
      local.isDirty = false;
      local.updatedAt = now;

      await _localDataSource.saveAttendanceRecord(local);
    }
  }

  @override
  Stream<void> watchAttendance(int subjectId) {
    return _localDataSource.watchAttendance(subjectId);
  }

  @override
  Future<void> updateEventStatus(int eventId, String status) async {
    await _localDataSource.updateEventStatus(eventId, status);
  }

  DailyScheduleOccurrence _occurrenceToEntity(
    DailyScheduleOccurrenceLocal local,
  ) {
    return DailyScheduleOccurrence(
      id: local.id,
      serverId: local.serverId,
      date: local.date,
      subjectId: local.subjectId,
      ruleId: local.ruleId,
      legacyEventId: local.legacyEventId,
      slotKey: local.slotKey,
      title: local.title,
      startTime: local.startTime,
      endTime: local.endTime,
      type: OccurrenceType.fromString(local.type),
      status: OccurrenceStatus.fromString(local.status),
      createdFrom: OccurrenceCreatedFrom.fromString(local.createdFrom),
      room: local.room,
      faculty: local.faculty,
      reason: local.reason,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  @override
  Future<DailyScheduleOccurrence> saveExtraClassWithAttendance({
    int? occurrenceId,
    required int subjectId,
    required DateTime date,
    String? subjectTitle,
    String? startTime,
    String? endTime,
    String? reason,
    AttendanceStatus? status,
    bool autoAllocateSlot = false,
  }) async {
    final saved = await _localDataSource.saveExtraClassWithAttendance(
      occurrenceId: occurrenceId,
      subjectId: subjectId,
      date: date,
      subjectTitle: subjectTitle,
      startTime: startTime,
      endTime: endTime,
      reason: reason,
      attendanceStatus: status?.toShortString(),
      autoAllocateSlot: autoAllocateSlot,
    );
    return _occurrenceToEntity(saved);
  }
}
