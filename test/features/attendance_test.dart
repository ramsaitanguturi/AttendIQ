import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:attend_iq/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:attend_iq/core/sync/sync_queue/sync_queue.dart';
import 'package:attend_iq/core/sync/models/sync_operation.dart';

// Fakes
class FakeSyncQueue implements SyncQueue {
  final List<SyncOperation> operations = [];
  int _nextId = 1;

  @override
  Future<void> enqueue({
    required String collectionName,
    required String documentId,
    required String operationType,
    required String payload,
  }) async {
    operations.add(SyncOperation()
      ..id = _nextId++
      ..collectionName = collectionName
      ..documentId = documentId
      ..operationType = operationType
      ..payload = payload
      ..createdAt = DateTime.now().toUtc()
      ..retryCount = 0);
  }

  @override
  Future<List<SyncOperation>> getPendingOperations() async => operations;
  @override
  Future<void> remove(int id) async => operations.removeWhere((op) => op.id == id);
  @override
  Future<void> incrementRetryCount(int id) async {}
}

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
  Future<AttendanceRecordLocal?> getAttendanceRecordById(int id) async {
    return records[id];
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
    late FakeSyncQueue syncQueue;
    late AttendanceRepositoryImpl repository;

    setUp(() {
      fakeLocalDataSource = FakeAttendanceLocalDataSource();
      syncQueue = FakeSyncQueue();
      repository = AttendanceRepositoryImpl(fakeLocalDataSource, syncQueue);
    });

    test('saveAttendanceRecord persists and maps correctly and enqueues sync CREATE operation', () async {
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
      expect(savedLocal.isDirty, isTrue);

      expect(syncQueue.operations.length, 1);
      expect(syncQueue.operations.first.operationType, 'CREATE');
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

    test('deleteAttendanceRecord marks local isDeleted=true and enqueues DELETE operation', () async {
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

      expect(syncQueue.operations.length, 2);
      expect(syncQueue.operations.last.operationType, 'DELETE');
    });
  });
}
