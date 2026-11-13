import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/core/notifications/services/pending_check_in_service.dart';
import 'package:attend_iq/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:attend_iq/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:attend_iq/features/attendance/domain/services/historical_attendance_service.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/datasources/daily_schedule_occurrence_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/schedule_exception_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/repositories/daily_schedule_occurrence_repository_impl.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../test_helpers/test_isar_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestIsarInstance testDb;
  late Isar isar;
  late HistoricalAttendanceService historicalService;
  late ProviderContainer container;

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  setUp(() async {
    testDb = openTestIsar(prefix: 'pending_ci');
    isar = testDb.isar;

    final occDataSource = DailyScheduleOccurrenceLocalDataSourceImpl(isar);
    final occRepo = DailyScheduleOccurrenceRepositoryImpl(localDataSource: occDataSource);
    final attDataSource = AttendanceLocalDataSourceImpl(isar);
    final attRepo = AttendanceRepositoryImpl(attDataSource);

    historicalService = HistoricalAttendanceService(
      occurrenceRepository: occRepo,
      attendanceRepository: attRepo,
    );

    container = ProviderContainer();

    // Populate a test subject
    final subject = SubjectLocal()
      ..id = 301
      ..semesterId = 1
      ..name = 'Embedded Systems'
      ..code = 'CS301'
      ..attendanceTarget = 75
      ..credits = 3
      ..type = 'THEORY'
      ..color = '#3366FF'
      ..createdAt = DateTime.now().toUtc()
      ..updatedAt = DateTime.now().toUtc();

    isar.write((isar) {
      isar.subjectLocals.put(subject);
    });
  });

  tearDown(() async {
    container.dispose();
    await testDb.dispose();
  });

  group('PendingCheckInService Tests (Real Isar)', () {
    test('Unrecorded past classes surface as pending check-ins', () async {
      final now = DateTime(2026, 11, 15, 14, 0); // 2:00 PM
      final morningClassDate = DateTime.utc(2026, 11, 15);

      // Add a past morning class occurrence today at 09:00 - 10:00 (already passed)
      final pastOcc = DailyScheduleOccurrenceLocal()
        ..id = 1
        ..date = morningClassDate
        ..subjectId = 301
        ..startTime = '09:00'
        ..endTime = '10:00'
        ..title = 'Embedded Systems'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = DateTime.now().toUtc()
        ..updatedAt = DateTime.now().toUtc();

      // Add an upcoming afternoon class today at 16:00 - 17:00 (future today, not yet pending)
      final futureOcc = DailyScheduleOccurrenceLocal()
        ..id = 2
        ..date = morningClassDate
        ..subjectId = 301
        ..startTime = '16:00'
        ..endTime = '17:00'
        ..title = 'Embedded Systems'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = DateTime.now().toUtc()
        ..updatedAt = DateTime.now().toUtc();

      isar.write((isar) {
        isar.dailyScheduleOccurrenceLocals.putAll([pastOcc, futureOcc]);
      });

      final service = PendingCheckInService(isar, historicalService);
      final pending = await service.getPendingCheckIns(customNow: now, lookbackDays: 3);

      expect(pending.length, equals(1));
      expect(pending.first.occurrenceId, equals(1));
      expect(pending.first.subjectName, equals('Embedded Systems'));
      expect(pending.first.startTime, equals('09:00'));
    });

    test('Holiday suppresses pending check-in', () async {
      final now = DateTime(2026, 11, 16, 15, 0);
      final holidayDate = DateTime.utc(2026, 11, 16);

      final occ = DailyScheduleOccurrenceLocal()
        ..id = 3
        ..date = holidayDate
        ..subjectId = 301
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..title = 'Embedded Systems'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = DateTime.now().toUtc()
        ..updatedAt = DateTime.now().toUtc();

      final holiday = ScheduleExceptionLocal()
        ..id = 1
        ..date = holidayDate
        ..title = 'National Holiday'
        ..type = 'HOLIDAY'
        ..createdAt = DateTime.now().toUtc()
        ..updatedAt = DateTime.now().toUtc();

      isar.write((isar) {
        isar.dailyScheduleOccurrenceLocals.put(occ);
        isar.scheduleExceptionLocals.put(holiday);
      });

      final service = PendingCheckInService(isar, historicalService);
      final pending = await service.getPendingCheckIns(customNow: now, lookbackDays: 3);

      expect(pending.isEmpty, isTrue);
    });

    test('Resolving pending check-in marks attendance and removes from pending list', () async {
      final now = DateTime(2026, 11, 17, 12, 0);
      final classDate = DateTime.utc(2026, 11, 17);

      final occ = DailyScheduleOccurrenceLocal()
        ..id = 4
        ..date = classDate
        ..subjectId = 301
        ..startTime = '09:00'
        ..endTime = '10:00'
        ..title = 'Embedded Systems'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = DateTime.now().toUtc()
        ..updatedAt = DateTime.now().toUtc();

      isar.write((isar) {
        isar.dailyScheduleOccurrenceLocals.put(occ);
      });

      final service = PendingCheckInService(isar, historicalService);
      var pending = await service.getPendingCheckIns(customNow: now, lookbackDays: 3);
      expect(pending.length, equals(1));

      // Resolve as PRESENT
      await service.resolveCheckIn(
        item: pending.first,
        status: OccurrenceStatus.PRESENT,
      );

      // Verify pending list is now empty
      pending = await service.getPendingCheckIns(customNow: now, lookbackDays: 3);
      expect(pending.isEmpty, isTrue);

      // Verify Isar state
      final updatedOcc = isar.dailyScheduleOccurrenceLocals.get(4);
      expect(updatedOcc!.status, equals('PRESENT'));
    });
  });
}
