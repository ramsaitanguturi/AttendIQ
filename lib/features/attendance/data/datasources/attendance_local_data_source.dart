import 'package:isar/isar.dart';
import '../models/attendance_record_local.dart';
import '../../../../core/event_generator/data/models/event_local.dart';

abstract class AttendanceLocalDataSource {
  Future<List<AttendanceRecordLocal>> getAttendanceForSubject(int subjectId);
  Future<AttendanceRecordLocal?> getAttendanceForEvent(int eventId);
  Future<AttendanceRecordLocal?> getAttendanceForEventAnyStatus(int eventId);
  Future<AttendanceRecordLocal?> getAttendanceRecordById(int id);
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record);
  Future<void> deleteAttendanceRecord(int id);
  Stream<void> watchAttendance(int subjectId);
  Future<void> updateEventStatus(int eventId, String status);
  Future<int> createExtraClassEvent(int subjectId, DateTime date, String status);
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
  Future<AttendanceRecordLocal?> getAttendanceForEventAnyStatus(int eventId) async {
    return _isar.attendanceRecordLocals
        .where()
        .eventIdEqualTo(eventId)
        .findFirst();
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceRecordById(int id) async {
    return _isar.attendanceRecordLocals.get(id);
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record) async {
    await _isar.writeAsync((isar) {
      if (record.id == 0) {
        final existing = isar.attendanceRecordLocals
            .where()
            .eventIdEqualTo(record.eventId)
            .findFirst();
        if (existing != null) {
          record.id = existing.id;
        } else {
          record.id = isar.attendanceRecordLocals.autoIncrement();
        }
      }
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
        record.updatedAt = DateTime.now().toUtc();
        isar.attendanceRecordLocals.put(record);
      }
    });
  }

  @override
  Stream<void> watchAttendance(int subjectId) {
    return _isar.attendanceRecordLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .watch();
  }

  @override
  Future<void> updateEventStatus(int eventId, String status) async {
    await _isar.writeAsync((isar) {
      final event = isar.eventLocals.get(eventId);
      if (event != null) {
        event.status = status;
        event.updatedAt = DateTime.now().toUtc();
        event.isDirty = true;
        isar.eventLocals.put(event);
      }
    });
  }

  @override
  Future<int> createExtraClassEvent(int subjectId, DateTime date, String status) async {
    int eventId = 0;
    await _isar.writeAsync((isar) {
      final event = EventLocal()
        ..subjectId = subjectId
        ..date = date
        ..startTime = '09:00'
        ..endTime = '10:00'
        ..eventType = 'REGULAR_CLASS'
        ..status = status
        ..updatedAt = DateTime.now().toUtc()
        ..isDirty = true
        ..isDeleted = false;
      isar.eventLocals.put(event);
      eventId = event.id;
    });
    return eventId;
  }
}
