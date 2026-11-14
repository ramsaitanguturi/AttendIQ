import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/core/analytics/calculators/analytics_calculator.dart';
import 'package:attend_iq/core/analytics/models/risk_status.dart';
import 'package:attend_iq/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/domain/services/historical_attendance_service.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/datasources/daily_schedule_occurrence_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/repositories/daily_schedule_occurrence_repository_impl.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import '../test_helpers/test_isar_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestIsarInstance testDb;
  late Isar isar;
  late HistoricalAttendanceService historicalService;

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  setUp(() {
    testDb = openTestIsar(prefix: 'acedra_hist_audit');
    isar = testDb.isar;

    final occDataSource = DailyScheduleOccurrenceLocalDataSourceImpl(isar);
    final occRepo =
        DailyScheduleOccurrenceRepositoryImpl(localDataSource: occDataSource);
    final attDataSource = AttendanceLocalDataSourceImpl(isar);
    final attRepo = AttendanceRepositoryImpl(attDataSource);

    historicalService = HistoricalAttendanceService(
      occurrenceRepository: occRepo,
      attendanceRepository: attRepo,
    );
  });

  tearDown(() async {
    await testDb.dispose();
  });

  group('ACEDRA Historical Attendance & Recalculation Independent Verification',
      () {
    test(
        '1. Edit yesterday and previous week attendance: transitions between PRESENT, ABSENT, CANCELLED',
        () async {
      final nowUtc = DateTime.utc(2026, 11, 14);
      final yesterdayUtc = DateTime.utc(2026, 11, 13);
      final lastWeekUtc = DateTime.utc(2026, 11, 7);
      final futureDateUtc = DateTime.utc(2026, 11, 20);

      // Set up subject: CS101 with 75% target
      final subject = SubjectLocal()
        ..id = 100
        ..name = 'Data Structures'
        ..code = 'CS101'
        ..attendanceTarget = 75.0
        ..color = '#2563EB'
        ..credits = 4
        ..semesterId = 1
        ..type = 'THEORY'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      // Set up future occurrence
      final futureOcc = DailyScheduleOccurrenceLocal()
        ..id = 999
        ..date = futureDateUtc
        ..subjectId = 100
        ..title = 'Data Structures (Future)'
        ..startTime = '10:00'
        ..endTime = '11:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      isar.write((isar) {
        isar.subjectLocals.put(subject);
        isar.dailyScheduleOccurrenceLocals.put(futureOcc);
      });

      // --- Part A: Edit yesterday's class (PRESENT -> ABSENT -> CANCELLED -> PRESENT) ---
      // 1. Mark yesterday as PRESENT
      final yOcc1 = await historicalService.setAttendanceStatus(
        date: yesterdayUtc,
        subjectId: 100,
        startTime: '09:00',
        endTime: '10:00',
        title: 'Data Structures',
        targetStatus: OccurrenceStatus.present,
      );
      expect(yOcc1.status, OccurrenceStatus.present);

      var records =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(records.length, 1);
      expect(records.first.status, 'PRESENT');

      // 2. Change yesterday to ABSENT
      final yOcc2 = await historicalService.setAttendanceStatus(
        date: yesterdayUtc,
        subjectId: 100,
        occurrenceId: yOcc1.id,
        startTime: '09:00',
        endTime: '10:00',
        title: 'Data Structures',
        targetStatus: OccurrenceStatus.absent,
      );
      expect(yOcc2.status, OccurrenceStatus.absent);

      records =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(records.length, 1);
      expect(records.first.status, 'ABSENT');

      // 3. Change yesterday to CANCELLED (should soft-delete attendance record)
      final yOcc3 = await historicalService.setAttendanceStatus(
        date: yesterdayUtc,
        subjectId: 100,
        occurrenceId: yOcc1.id,
        startTime: '09:00',
        endTime: '10:00',
        title: 'Data Structures',
        targetStatus: OccurrenceStatus.cancelled,
      );
      expect(yOcc3.status, OccurrenceStatus.cancelled);

      records =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(records.isEmpty, isTrue); // Cancelled excluded from attendance

      // 4. Change yesterday back to PRESENT
      final yOcc4 = await historicalService.setAttendanceStatus(
        date: yesterdayUtc,
        subjectId: 100,
        occurrenceId: yOcc1.id,
        startTime: '09:00',
        endTime: '10:00',
        title: 'Data Structures',
        targetStatus: OccurrenceStatus.present,
      );
      expect(yOcc4.status, OccurrenceStatus.present);

      records =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(records.length, 1);
      expect(records.first.status, 'PRESENT');

      // --- Part B: Edit previous week's class ---
      final lwOcc = await historicalService.setAttendanceStatus(
        date: lastWeekUtc,
        subjectId: 100,
        startTime: '14:00',
        endTime: '15:00',
        title: 'Data Structures',
        targetStatus: OccurrenceStatus.absent,
      );
      expect(lwOcc.status, OccurrenceStatus.absent);

      records =
          isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(records.length, 2);

      // Verify that future occurrence (999) remains completely UNCHANGED on disk
      final verifiedFutureOcc = isar.dailyScheduleOccurrenceLocals.get(999);
      expect(verifiedFutureOcc, isNotNull);
      expect(verifiedFutureOcc!.status, 'UPCOMING');
      expect(verifiedFutureOcc.title, 'Data Structures (Future)');
      expect(verifiedFutureOcc.date.toUtc(), futureDateUtc);
    });

    test(
        '2. Subject percentage, overall attendance, safe bunks, and analytics update accurately after historical edits',
        () async {
      final subject = Subject(
        id: 100,
        name: 'Data Structures',
        code: 'CS101',
        attendanceTarget: 75.0,
        color: '#2563EB',
        credits: 4,
        semesterId: 1,
        type: SubjectType.theory,
        updatedAt: DateTime.now(),
      );

      // Scenario: Subject has 20 classes conducted so far.
      // Initially: 16 PRESENT, 4 ABSENT (16/20 = 80.0%, target = 75.0%)
      final records1 = [
        ...List.generate(
          16,
          (i) => AttendanceRecord(
            id: i + 1,
            subjectId: 100,
            status: AttendanceStatus.present,
            markedAt: DateTime.utc(2026, 10, i + 1),
            updatedAt: DateTime.utc(2026, 10, i + 1),
          ),
        ),
        ...List.generate(
          4,
          (i) => AttendanceRecord(
            id: i + 17,
            subjectId: 100,
            status: AttendanceStatus.absent,
            markedAt: DateTime.utc(2026, 10, i + 17),
            updatedAt: DateTime.utc(2026, 10, i + 17),
          ),
        ),
      ];

      final a1 = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: subject,
        records: records1,
      );
      expect(a1.percentage, 80.0);
      expect(a1.safeBunks, 1);
      expect(a1.riskStatus, RiskStatus.safe);

      // Historical Edit: User changes 1 past ABSENT into PRESENT.
      // Now: 17 PRESENT, 3 ABSENT out of 20 total.
      final records2 = [
        ...List.generate(
          17,
          (i) => AttendanceRecord(
            id: i + 1,
            subjectId: 100,
            status: AttendanceStatus.present,
            markedAt: DateTime.utc(2026, 10, i + 1),
            updatedAt: DateTime.utc(2026, 10, i + 1),
          ),
        ),
        ...List.generate(
          3,
          (i) => AttendanceRecord(
            id: i + 18,
            subjectId: 100,
            status: AttendanceStatus.absent,
            markedAt: DateTime.utc(2026, 10, i + 18),
            updatedAt: DateTime.utc(2026, 10, i + 18),
          ),
        ),
      ];

      final a2 = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: subject,
        records: records2,
      );
      expect(a2.percentage, 85.0);
      expect(a2.safeBunks, 2);
      expect(a2.riskStatus, RiskStatus.safe);

      // Historical Edit: User changes 3 past PRESENT into ABSENT.
      // Now: 14 PRESENT, 6 ABSENT out of 20 total.
      final records3 = [
        ...List.generate(
          14,
          (i) => AttendanceRecord(
            id: i + 1,
            subjectId: 100,
            status: AttendanceStatus.present,
            markedAt: DateTime.utc(2026, 10, i + 1),
            updatedAt: DateTime.utc(2026, 10, i + 1),
          ),
        ),
        ...List.generate(
          6,
          (i) => AttendanceRecord(
            id: i + 15,
            subjectId: 100,
            status: AttendanceStatus.absent,
            markedAt: DateTime.utc(2026, 10, i + 15),
            updatedAt: DateTime.utc(2026, 10, i + 15),
          ),
        ),
      ];

      final a3 = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: subject,
        records: records3,
      );
      expect(a3.percentage, 70.0);
      expect(a3.safeBunks, 0);
      expect(a3.classesNeeded, 4);
      expect(a3.riskStatus, RiskStatus.critical);

      // Historical Edit: User marks 2 classes as CANCELLED.
      // Cancelled records have isDeleted = true (or are omitted).
      // Total conducted: 18 classes (14 PRESENT, 4 ABSENT).
      final records4 = [
        ...List.generate(
          14,
          (i) => AttendanceRecord(
            id: i + 1,
            subjectId: 100,
            status: AttendanceStatus.present,
            markedAt: DateTime.utc(2026, 10, i + 1),
            updatedAt: DateTime.utc(2026, 10, i + 1),
          ),
        ),
        ...List.generate(
          4,
          (i) => AttendanceRecord(
            id: i + 15,
            subjectId: 100,
            status: AttendanceStatus.absent,
            markedAt: DateTime.utc(2026, 10, i + 15),
            updatedAt: DateTime.utc(2026, 10, i + 15),
          ),
        ),
        // 2 Cancelled records marked isDeleted = true
        AttendanceRecord(
          id: 19,
          subjectId: 100,
          status: AttendanceStatus.cancelled,
          isDeleted: true,
          markedAt: DateTime.utc(2026, 10, 19),
          updatedAt: DateTime.utc(2026, 10, 19),
        ),
        AttendanceRecord(
          id: 20,
          subjectId: 100,
          status: AttendanceStatus.cancelled,
          isDeleted: true,
          markedAt: DateTime.utc(2026, 10, 20),
          updatedAt: DateTime.utc(2026, 10, 20),
        ),
      ];

      final a4 = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: subject,
        records: records4,
      );
      expect(a4.percentage.toStringAsFixed(1), '77.8');
      expect(a4.safeBunks, 0);
      expect(a4.classesNeeded, 0);
      expect(a4.riskStatus, RiskStatus.safe);
    });
  });
}
