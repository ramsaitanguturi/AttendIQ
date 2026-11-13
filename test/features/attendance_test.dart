import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:attend_iq/features/attendance/data/repositories/attendance_repository_impl.dart';
import '../test_helpers/test_isar_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestIsarInstance testDb;
  late AttendanceLocalDataSourceImpl localDataSource;
  late AttendanceRepositoryImpl repository;

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  setUp(() {
    testDb = openTestIsar(prefix: 'attendance_crud');
    localDataSource = AttendanceLocalDataSourceImpl(testDb.isar);
    repository = AttendanceRepositoryImpl(localDataSource);
  });

  tearDown(() async {
    await testDb.dispose();
  });

  group('Attendance Repository Implementation Tests (Real Isar Database)', () {
    test('saveAttendanceRecord persists and maps correctly', () async {
      final record = AttendanceRecord(
        eventId: 10,
        subjectId: 5,
        status: AttendanceStatus.PRESENT,
        markedAt: DateTime.utc(2026, 10, 15),
        updatedAt: DateTime.utc(2026, 10, 15),
      );

      await repository.saveAttendanceRecord(record);

      final records = testDb.isar.attendanceRecordLocals.where().findAll();
      expect(records.length, 1);
      final savedLocal = records.first;
      expect(savedLocal.eventId, 10);
      expect(savedLocal.subjectId, 5);
      expect(savedLocal.status, 'PRESENT');
      expect(savedLocal.serverId, isNotNull);
    });

    test('getAttendanceForSubject fetches active records only', () async {
      await localDataSource.saveAttendanceRecord(
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

      await localDataSource.saveAttendanceRecord(
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
      await localDataSource.saveAttendanceRecord(
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
      final created = testDb.isar.attendanceRecordLocals.where().findFirst()!;

      await repository.deleteAttendanceRecord(created.id);

      final finalLocal = testDb.isar.attendanceRecordLocals.get(created.id);
      expect(finalLocal, isNotNull);
      expect(finalLocal!.isDeleted, isTrue);
    });

    test(
        'Editing attendance status multiple times updates existing record without duplicates',
        () async {
      // 1. Initial Present
      final recordPresent = AttendanceRecord(
        eventId: 500,
        subjectId: 10,
        status: AttendanceStatus.PRESENT,
        markedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveAttendanceRecord(recordPresent);
      var allRecords = testDb.isar.attendanceRecordLocals.where().findAll();
      expect(allRecords.length, 1);
      expect(allRecords.first.status, 'PRESENT');

      // 2. Edit to Absent
      final recordAbsent = AttendanceRecord(
        eventId: 500,
        subjectId: 10,
        status: AttendanceStatus.ABSENT,
        markedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveAttendanceRecord(recordAbsent);
      allRecords = testDb.isar.attendanceRecordLocals.where().findAll();
      expect(allRecords.length, 1); // No duplicates
      expect(allRecords.first.status, 'ABSENT');

      // 3. Edit to Cancelled (Soft Delete)
      final existing = await repository.getAttendanceForEventAnyStatus(500);
      expect(existing, isNotNull);
      await repository.deleteAttendanceRecord(existing!.id!);
      allRecords = testDb.isar.attendanceRecordLocals.where().findAll();
      expect(allRecords.length, 1);
      expect(allRecords.first.isDeleted, isTrue);

      // 4. Edit back to Present
      final recordBackPresent = AttendanceRecord(
        eventId: 500,
        subjectId: 10,
        status: AttendanceStatus.PRESENT,
        markedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveAttendanceRecord(recordBackPresent);
      allRecords = testDb.isar.attendanceRecordLocals.where().findAll();
      expect(allRecords.length, 1); // Reused row
      expect(allRecords.first.isDeleted, isFalse);
      expect(allRecords.first.status, 'PRESENT');
    });
  });
}
