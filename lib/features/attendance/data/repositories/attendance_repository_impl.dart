import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_data_source.dart';
import '../models/attendance_record_local.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource _localDataSource;

  AttendanceRepositoryImpl(this._localDataSource);

  AttendanceRecord _toEntity(AttendanceRecordLocal local) {
    return AttendanceRecord(
      id: local.id,
      serverId: local.serverId,
      eventId: local.eventId,
      subjectId: local.subjectId,
      status: AttendanceStatus.fromString(local.status),
      markedAt: local.markedAt,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  AttendanceRecordLocal _toLocal(AttendanceRecord entity) {
    return AttendanceRecordLocal()
      ..id = entity.id ?? 0
      ..serverId = entity.serverId
      ..eventId = entity.eventId
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
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId) async {
    final local = await _localDataSource.getAttendanceForEvent(eventId);
    if (local != null) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {
    final local = _toLocal(record);
    await _localDataSource.saveAttendanceRecord(local);
  }

  @override
  Future<void> deleteAttendanceRecord(int id) async {
    await _localDataSource.deleteAttendanceRecord(id);
  }
}
