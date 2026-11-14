import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:attend_iq/features/attendance/domain/services/historical_attendance_service.dart';
import 'package:attend_iq/features/timetable/data/datasources/daily_schedule_occurrence_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/repositories/daily_schedule_occurrence_repository_impl.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import '../test_helpers/test_isar_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestIsarInstance testDb;
  late Isar isar;
  late DailyScheduleOccurrenceRepositoryImpl occurrenceRepo;
  late AttendanceRepositoryImpl attendanceRepo;
  late HistoricalAttendanceService historicalService;

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  setUp(() {
    testDb = openTestIsar(prefix: 'hist_att');
    isar = testDb.isar;

    final occDataSource = DailyScheduleOccurrenceLocalDataSourceImpl(isar);
    occurrenceRepo =
        DailyScheduleOccurrenceRepositoryImpl(localDataSource: occDataSource);

    final attDataSource = AttendanceLocalDataSourceImpl(isar);
    attendanceRepo = AttendanceRepositoryImpl(attDataSource);

    historicalService = HistoricalAttendanceService(
      occurrenceRepository: occurrenceRepo,
      attendanceRepository: attendanceRepo,
    );
  });

  tearDown(() async {
    await testDb.dispose();
  });

  group('HistoricalAttendanceService Integration Tests (Real Isar)', () {
    test('Unrecorded scheduled class modifies to PRESENT', () async {
      final pastDate = DateTime.utc(2026, 10, 10);

      final occ = await historicalService.setAttendanceStatus(
        date: pastDate,
        subjectId: 201,
        ruleId: 10,
        startTime: '09:00',
        endTime: '10:00',
        title: 'Algorithms',
        room: 'Hall A',
        targetStatus: OccurrenceStatus.present,
      );

      expect(occ.id, isNotNull);
      expect(occ.status, equals(OccurrenceStatus.present));
      expect(occ.room, equals('Hall A'));

      // Check Isar record
      final records = isar.attendanceRecordLocals.where().findAll();
      expect(records.length, equals(1));
      expect(records.first.status, equals('PRESENT'));
      expect(records.first.subjectId, equals(201));
      expect(records.first.occurrenceId, equals(occ.id));
    });

    test(
        'Full status transition cycle: Present -> Absent -> Late -> Cancelled -> Present',
        () async {
      final pastDate = DateTime.utc(2026, 10, 12);

      // 1. Unmarked -> Present
      final occ1 = await historicalService.setAttendanceStatus(
        date: pastDate,
        subjectId: 202,
        ruleId: 11,
        startTime: '10:00',
        endTime: '11:00',
        title: 'Database Systems',
        targetStatus: OccurrenceStatus.present,
      );
      expect(occ1.status, equals(OccurrenceStatus.present));
      var activeRecords =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(activeRecords.length, equals(1));
      expect(activeRecords.first.status, equals('PRESENT'));

      // 2. Present -> Absent
      final occ2 = await historicalService.setAttendanceStatus(
        date: pastDate,
        subjectId: 202,
        occurrenceId: occ1.id,
        startTime: '10:00',
        endTime: '11:00',
        title: 'Database Systems',
        targetStatus: OccurrenceStatus.absent,
      );
      expect(occ2.status, equals(OccurrenceStatus.absent));
      activeRecords =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(activeRecords.length, equals(1));
      expect(activeRecords.first.status, equals('ABSENT'));

      // 3. Absent -> Late
      final occ3 = await historicalService.setAttendanceStatus(
        date: pastDate,
        subjectId: 202,
        occurrenceId: occ1.id,
        startTime: '10:00',
        endTime: '11:00',
        title: 'Database Systems',
        targetStatus: OccurrenceStatus.late,
      );
      expect(occ3.status, equals(OccurrenceStatus.late));
      activeRecords =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(activeRecords.length, equals(1));
      expect(activeRecords.first.status, equals('LATE'));

      // 4. Late -> Cancelled
      final occ4 = await historicalService.setAttendanceStatus(
        date: pastDate,
        subjectId: 202,
        occurrenceId: occ1.id,
        startTime: '10:00',
        endTime: '11:00',
        title: 'Database Systems',
        targetStatus: OccurrenceStatus.cancelled,
      );
      expect(occ4.status, equals(OccurrenceStatus.cancelled));
      activeRecords =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(
        activeRecords.isEmpty,
        isTrue,
      ); // Cancelled classes have no active attendance records

      // 5. Cancelled -> Present
      final occ5 = await historicalService.setAttendanceStatus(
        date: pastDate,
        subjectId: 202,
        occurrenceId: occ1.id,
        startTime: '10:00',
        endTime: '11:00',
        title: 'Database Systems',
        targetStatus: OccurrenceStatus.present,
      );
      expect(occ5.status, equals(OccurrenceStatus.present));
      activeRecords =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(activeRecords.length, equals(1));
      expect(activeRecords.first.status, equals('PRESENT'));
    });

    test('Unrecorded past class modifies directly to ABSENT or CANCELLED',
        () async {
      final pastDate = DateTime.utc(2026, 10, 14);

      // Unrecorded -> Cancelled
      final occCancel = await historicalService.setAttendanceStatus(
        date: pastDate,
        subjectId: 203,
        ruleId: 12,
        startTime: '11:00',
        endTime: '12:00',
        title: 'Networks',
        targetStatus: OccurrenceStatus.cancelled,
      );
      expect(occCancel.status, equals(OccurrenceStatus.cancelled));
      var records =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(records.isEmpty, isTrue);

      // Unrecorded -> Absent
      final occAbsent = await historicalService.setAttendanceStatus(
        date: pastDate,
        subjectId: 204,
        ruleId: 13,
        startTime: '14:00',
        endTime: '15:00',
        title: 'Security',
        targetStatus: OccurrenceStatus.absent,
      );
      expect(occAbsent.status, equals(OccurrenceStatus.absent));
      records =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(records.length, equals(1));
      expect(records.first.status, equals('ABSENT'));
    });

    test('Modification timestamps are accurately recorded', () async {
      final beforeTime =
          DateTime.now().toUtc().subtract(const Duration(seconds: 1));
      final pastDate = DateTime.utc(2026, 10, 15);

      final occ = await historicalService.setAttendanceStatus(
        date: pastDate,
        subjectId: 205,
        startTime: '15:00',
        endTime: '16:00',
        title: 'Cloud Computing',
        targetStatus: OccurrenceStatus.present,
      );

      final afterTime = DateTime.now().toUtc().add(const Duration(seconds: 1));

      expect(occ.updatedAt.isAfter(beforeTime), isTrue);
      expect(occ.updatedAt.isBefore(afterTime), isTrue);

      final record = isar.attendanceRecordLocals.where().findFirst();
      expect(record, isNotNull);
      expect(record!.updatedAt.isAfter(beforeTime), isTrue);
      expect(record.updatedAt.isBefore(afterTime), isTrue);
    });
  });
}
