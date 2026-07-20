import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:attend_iq/features/attendance/data/repositories/attendance_repository_impl.dart';

class FakeAttendanceLocalDataSource implements AttendanceLocalDataSource {
  final Map<int, AttendanceRecordLocal> records = {};
  int _nextId = 1;

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceForSubject(int subjectId) async {
    return records.values
        .where((r) => r.subjectId == subjectId && !r.isDeleted)
        .toList();
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForEvent(int eventId) async {
    try {
      return records.values.firstWhere((r) => r.eventId == eventId && !r.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForEventAnyStatus(int eventId) async {
    try {
      return records.values.firstWhere((r) => r.eventId == eventId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceRecordById(int id) async {
    return records[id];
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record) async {
    if (record.id == 0) {
      final existing = records.values.where((r) => r.eventId == record.eventId).firstOrNull;
      if (existing != null) {
        record.id = existing.id;
      } else {
        record.id = _nextId++;
      }
    }
    records[record.id] = record;
  }

  @override
  Future<void> deleteAttendanceRecord(int id) async {
    final record = records[id];
    if (record != null) {
      record.isDeleted = true;
      record.isDirty = true;
      record.updatedAt = DateTime.now();
    }
  }

  @override
  Stream<void> watchAttendance(int subjectId) {
    return const Stream.empty();
  }

  @override
  Future<void> updateEventStatus(int eventId, String status) async {}

  @override
  Future<int> createExtraClassEvent(int subjectId, DateTime date, String status) async {
    return 999;
  }
}

void main() {
  group('Attendance Repository Implementation Tests', () {
    late FakeAttendanceLocalDataSource fakeLocalDataSource;
    late AttendanceRepositoryImpl repository;

    setUp(() {
      fakeLocalDataSource = FakeAttendanceLocalDataSource();
      repository = AttendanceRepositoryImpl(fakeLocalDataSource);
    });

    test('saveAttendanceRecord persists and maps correctly', () async {
      final record = AttendanceRecord(
        eventId: 10,
        subjectId: 5,
        status: AttendanceStatus.PRESENT,
        markedAt: DateTime.utc(2026, 10, 15),
        updatedAt: DateTime.utc(2026, 10, 15),
      );

      await repository.saveAttendanceRecord(record);

      expect(fakeLocalDataSource.records.length, 1);
      final savedLocal = fakeLocalDataSource.records.values.first;
      expect(savedLocal.eventId, 10);
      expect(savedLocal.subjectId, 5);
      expect(savedLocal.status, 'PRESENT');
      expect(savedLocal.serverId, isNotNull);
    });

    test('getAttendanceForSubject fetches active records only', () async {
      await fakeLocalDataSource.saveAttendanceRecord(
        AttendanceRecordLocal()
          ..id = 1
          ..eventId = 101
          ..subjectId = 5
          ..status = 'PRESENT'
          ..markedAt = DateTime.now()
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..isDirty = false
          ..isDeleted = false,
      );

      await fakeLocalDataSource.saveAttendanceRecord(
        AttendanceRecordLocal()
          ..id = 2
          ..eventId = 102
          ..subjectId = 5
          ..status = 'ABSENT'
          ..markedAt = DateTime.now()
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..isDirty = false
          ..isDeleted = true,
      );

      final result = await repository.getAttendanceForSubject(5);
      expect(result.length, 1);
      expect(result.first.eventId, 101);
      expect(result.first.status, AttendanceStatus.PRESENT);
    });

    test('getAttendanceForEvent returns matching entity', () async {
      await fakeLocalDataSource.saveAttendanceRecord(
        AttendanceRecordLocal()
          ..id = 1
          ..eventId = 200
          ..subjectId = 5
          ..status = 'ABSENT'
          ..markedAt = DateTime.now()
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..isDirty = false
          ..isDeleted = false,
      );

      final result = await repository.getAttendanceForEvent(200);
      expect(result, isNotNull);
      expect(result!.eventId, 200);
      expect(result.status, AttendanceStatus.ABSENT);
    });

    test('deleteAttendanceRecord marks local isDeleted=true', () async {
      final record = AttendanceRecord(
        eventId: 300,
        subjectId: 5,
        status: AttendanceStatus.PRESENT,
        markedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveAttendanceRecord(record);
      final created = fakeLocalDataSource.records.values.first;

      await repository.deleteAttendanceRecord(created.id);

      final finalLocal = fakeLocalDataSource.records[created.id];
      expect(finalLocal, isNotNull);
      expect(finalLocal!.isDeleted, isTrue);
    });

    test('Editing attendance status multiple times updates existing record without duplicates', () async {
      // 1. Initial Present
      final recordPresent = AttendanceRecord(
        eventId: 500,
        subjectId: 10,
        status: AttendanceStatus.PRESENT,
        markedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveAttendanceRecord(recordPresent);
      expect(fakeLocalDataSource.records.length, 1);
      expect(fakeLocalDataSource.records.values.first.status, 'PRESENT');

      // 2. Edit to Absent
      final recordAbsent = AttendanceRecord(
        eventId: 500,
        subjectId: 10,
        status: AttendanceStatus.ABSENT,
        markedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveAttendanceRecord(recordAbsent);
      expect(fakeLocalDataSource.records.length, 1); // No duplicates
      expect(fakeLocalDataSource.records.values.first.status, 'ABSENT');

      // 3. Edit to Cancelled (Soft Delete)
      final existing = await repository.getAttendanceForEventAnyStatus(500);
      expect(existing, isNotNull);
      await repository.deleteAttendanceRecord(existing!.id!);
      expect(fakeLocalDataSource.records.length, 1);
      expect(fakeLocalDataSource.records.values.first.isDeleted, isTrue);

      // 4. Edit back to Present
      final recordBackPresent = AttendanceRecord(
        eventId: 500,
        subjectId: 10,
        status: AttendanceStatus.PRESENT,
        markedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveAttendanceRecord(recordBackPresent);
      expect(fakeLocalDataSource.records.length, 1); // Reused row
      expect(fakeLocalDataSource.records.values.first.isDeleted, isFalse);
      expect(fakeLocalDataSource.records.values.first.status, 'PRESENT');
    });
  });
}
