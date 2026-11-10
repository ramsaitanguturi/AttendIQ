import 'package:isar/isar.dart';
import '../models/attendance_record_local.dart';
import '../../../subject/data/models/subject_local.dart';
import '../../../timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../timetable/data/utils/occurrence_identity.dart';

abstract class AttendanceLocalDataSource {
  Future<List<AttendanceRecordLocal>> getAttendanceForSubject(int subjectId);
  Future<AttendanceRecordLocal?> getAttendanceForOccurrence(int occurrenceId);
  Future<AttendanceRecordLocal?> getAttendanceForOccurrenceAnyStatus(
      int occurrenceId);
  Future<AttendanceRecordLocal?> getAttendanceForEvent(int eventId);
  Future<AttendanceRecordLocal?> getAttendanceForEventAnyStatus(int eventId);
  Future<AttendanceRecordLocal?> getAttendanceRecordById(int id);
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record);
  Future<void> deleteAttendanceRecord(int id);
  Stream<void> watchAttendance(int subjectId);
  Future<void> updateEventStatus(int occurrenceId, String status);
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
  Future<AttendanceRecordLocal?> getAttendanceForOccurrence(
      int occurrenceId) async {
    if (occurrenceId <= 0) return null;
    return _isar.attendanceRecordLocals
        .where()
        .occurrenceIdEqualTo(occurrenceId)
        .isDeletedEqualTo(false)
        .findFirst();
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForOccurrenceAnyStatus(
      int occurrenceId) async {
    if (occurrenceId <= 0) return null;
    return _isar.attendanceRecordLocals
        .where()
        .occurrenceIdEqualTo(occurrenceId)
        .findFirst();
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForEvent(int eventId) =>
      getAttendanceForOccurrence(eventId);

  @override
  Future<AttendanceRecordLocal?> getAttendanceForEventAnyStatus(int eventId) =>
      getAttendanceForOccurrenceAnyStatus(eventId);

  @override
  Future<AttendanceRecordLocal?> getAttendanceRecordById(int id) async {
    return _isar.attendanceRecordLocals.get(id);
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record) async {
    await _isar.writeAsync((isar) {
      final occId = record.occurrenceId;
      if (occId != null && occId > 0) {
        record.eventId = occId;
      }

      if (record.id == 0) {
        if (occId != null && occId > 0) {
          final existing = isar.attendanceRecordLocals
              .where()
              .occurrenceIdEqualTo(occId)
              .findFirst();
          if (existing != null) {
            record.id = existing.id;
          } else {
            record.id = isar.attendanceRecordLocals.autoIncrement();
          }
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
  Future<void> updateEventStatus(int occurrenceId, String status) async {
    if (occurrenceId <= 0) return;
    final mappedStatus = _mapAttendanceStatusToOccurrenceStatus(status);
    final now = DateTime.now().toUtc();
    await _isar.writeAsync((isar) {
      final occurrence = isar.dailyScheduleOccurrenceLocals.get(occurrenceId);
      if (occurrence != null && !occurrence.isDeleted) {
        occurrence
          ..status = mappedStatus
          ..updatedAt = now
          ..isDirty = true;
        isar.dailyScheduleOccurrenceLocals.put(occurrence);
      }
    });
  }

  @override
  Future<int> createExtraClassEvent(
      int subjectId, DateTime date, String status) async {
    final normalizedDate = normalizeUtcDate(date);
    final mappedStatus = _mapAttendanceStatusToOccurrenceStatus(status);
    final now = DateTime.now().toUtc();

    final saved = await _isar.writeAsync<DailyScheduleOccurrenceLocal>((isar) {
      final subject = isar.subjectLocals.get(subjectId);
      final title = subject?.name ?? 'Extra Class';

      final dayStart = normalizedDate;
      final dayEnd = DateTime.utc(
        normalizedDate.year,
        normalizedDate.month,
        normalizedDate.day,
        23,
        59,
        59,
      );
      final sameDayKeys = isar.dailyScheduleOccurrenceLocals
          .where()
          .dateBetween(dayStart, dayEnd)
          .isDeletedEqualTo(false)
          .findAll()
          .map((o) => o.slotKey)
          .toSet();

      var selectedStart = '09:00';
      var selectedEnd = '10:00';
      for (var hour = 9; hour <= 22; hour++) {
        final s = '${hour.toString().padLeft(2, '0')}:00';
        final e = '${(hour + 1).toString().padLeft(2, '0')}:00';
        final candidateKey = computeCanonicalSlotKey(
          date: normalizedDate,
          subjectId: subjectId,
          startTime: s,
          endTime: e,
          type: 'EXTRA_CLASS',
          title: title,
        );
        if (!sameDayKeys.contains(candidateKey)) {
          selectedStart = s;
          selectedEnd = e;
          break;
        }
      }

      final occurrence = DailyScheduleOccurrenceLocal()
        ..date = normalizedDate
        ..subjectId = subjectId
        ..title = title
        ..startTime = selectedStart
        ..endTime = selectedEnd
        ..type = 'EXTRA_CLASS'
        ..status = mappedStatus
        ..createdFrom = 'MANUAL'
        ..faculty = subject?.faculty
        ..createdAt = now
        ..updatedAt = now
        ..isDirty = true
        ..isDeleted = false;

      return upsertCanonicalOccurrenceInWriteTx(isar, occurrence);
    });

    return saved.id;
  }

  static String _mapAttendanceStatusToOccurrenceStatus(String status) {
    switch (status.trim().toUpperCase()) {
      case 'PRESENT':
      case 'EXTRA_PRESENT':
        return 'PRESENT';
      case 'ABSENT':
      case 'EXTRA_ABSENT':
        return 'ABSENT';
      case 'CANCELLED':
        return 'CANCELLED';
      default:
        return 'UPCOMING';
    }
  }
}
