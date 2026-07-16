import 'package:isar/isar.dart';
import '../models/attendance_record_local.dart';

abstract class AttendanceLocalDataSource {
  Future<List<AttendanceRecordLocal>> getAttendanceForSubject(int subjectId);
  Future<AttendanceRecordLocal?> getAttendanceForEvent(int eventId);
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record);
  Future<void> deleteAttendanceRecord(int id);
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final Isar _isar;

  AttendanceLocalDataSourceImpl(this._isar);

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceForSubject(int subjectId) async {
    return _isar.attendanceRecordLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForEvent(int eventId) async {
    return _isar.attendanceRecordLocals
        .where()
        .eventIdEqualTo(eventId)
        .isDeletedEqualTo(false)
        .findFirst();
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record) async {
    await _isar.writeAsync((isar) {
      isar.attendanceRecordLocals.put(record);
    });
  }

  @override
  Future<void> deleteAttendanceRecord(int id) async {
    await _isar.writeAsync((isar) {
      final record = isar.attendanceRecordLocals.get(id);
      if (record != null) {
        record.isDeleted = true;
        record.isDirty = true;
        record.updatedAt = DateTime.now();
        isar.attendanceRecordLocals.put(record);
      }
    });
  }
}
