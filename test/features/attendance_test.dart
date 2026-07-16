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
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record) async {
    if (record.id == 0) {
      record.id = _nextId++;
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
    });

    test('getAttendanceForSubject fetches active records only', () async {
      // Setup some records
      await fakeLocalDataSource.saveAttendanceRecord(
        AttendanceRecordLocal()
          ..id = 1
          ..eventId = 101
          ..subjectId = 5
          ..status = 'PRESENT'
          ..markedAt = DateTime.now()
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
          ..updatedAt = DateTime.now()
          ..isDirty = false
          ..isDeleted = true, // Deleted
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
          ..status = 'CANCELLED'
          ..markedAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..isDirty = false
          ..isDeleted = false,
      );

      final record = await repository.getAttendanceForEvent(200);
      expect(record, isNotNull);
      expect(record!.status, AttendanceStatus.CANCELLED);
    });

    test('deleteAttendanceRecord marks local copy as deleted', () async {
      await fakeLocalDataSource.saveAttendanceRecord(
        AttendanceRecordLocal()
          ..id = 1
          ..eventId = 300
          ..subjectId = 5
          ..status = 'PRESENT'
          ..markedAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..isDirty = false
          ..isDeleted = false,
      );

      await repository.deleteAttendanceRecord(1);
      expect(fakeLocalDataSource.records[1]!.isDeleted, isTrue);
    });
  });
}
