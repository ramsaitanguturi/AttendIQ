import 'package:flutter_test/flutter_test.dart';

import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/data/datasources/weekly_schedule_rule_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/datasources/schedule_exception_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/repositories/weekly_schedule_rule_repository_impl.dart';
import 'package:attend_iq/features/timetable/data/repositories/schedule_exception_repository_impl.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import '../test_helpers/test_isar_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestIsarInstance testDb;
  late WeeklyScheduleRuleLocalDataSourceImpl ruleDataSource;
  late ScheduleExceptionLocalDataSourceImpl exceptionDataSource;
  late WeeklyScheduleRuleRepositoryImpl ruleRepository;
  late ScheduleExceptionRepositoryImpl exceptionRepository;

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  setUp(() {
    testDb = openTestIsar(prefix: 'exceptions_rules');
    ruleDataSource = WeeklyScheduleRuleLocalDataSourceImpl(testDb.isar);
    exceptionDataSource = ScheduleExceptionLocalDataSourceImpl(testDb.isar);
    ruleRepository =
        WeeklyScheduleRuleRepositoryImpl(localDataSource: ruleDataSource);
    exceptionRepository =
        ScheduleExceptionRepositoryImpl(localDataSource: exceptionDataSource);

    testDb.isar.write((isar) {
      isar.subjectLocals.putAll([
        SubjectLocal()
          ..id = 101
          ..semesterId = 1
          ..name = 'Operating Systems'
          ..code = 'CS301'
          ..credits = 4
          ..color = '#4ECDC4'
          ..attendanceTarget = 75.0
          ..type = 'THEORY'
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now(),
        SubjectLocal()
          ..id = 102
          ..semesterId = 1
          ..name = 'Data Structures'
          ..code = 'CS302'
          ..credits = 3
          ..color = '#FF6B6B'
          ..attendanceTarget = 75.0
          ..type = 'THEORY'
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now(),
      ]);
    });
  });

  tearDown(() async {
    await testDb.dispose();
  });

  group('AttendIQ Timetable & Calendar Exceptions Tests (Real Isar Database)',
      () {
    test('1. Subject with multiple days appears correctly', () async {
      // Operating Systems on Monday (1), Tuesday (2), Friday (5)
      final days = [1, 2, 5];
      final now = DateTime.now();

      final rules = days
          .map(
            (day) => WeeklyScheduleRule(
              subjectId: 101,
              dayOfWeek: day,
              startTime: '10:00',
              endTime: '11:00',
              room: 'Room A203',
              faculty: 'Dr. Smith',
              createdAt: now,
              updatedAt: now,
            ),
          )
          .toList();

      await ruleRepository.saveRules(rules);

      final subjectRules = await ruleRepository.getRulesForSubject(101);
      expect(subjectRules.length, 3);
      final daysOfWeek = subjectRules.map((r) => r.dayOfWeek).toList()..sort();
      expect(daysOfWeek, [1, 2, 5]);
    });

    test('2. Dashboard loads today classes based on weekday rules', () async {
      final now = DateTime.now();
      final todayWeekday = now.weekday;

      await ruleRepository.saveRule(
        WeeklyScheduleRule(
          subjectId: 101,
          dayOfWeek: todayWeekday,
          startTime: '10:00',
          endTime: '11:00',
          room: 'Room A203',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final activeRules = await ruleRepository.getRulesForSemester(1);
      final todayClasses =
          activeRules.where((r) => r.dayOfWeek == todayWeekday).toList();
      expect(todayClasses.length, 1);
      expect(todayClasses.first.subjectId, 101);
      expect(todayClasses.first.startTime, '10:00');
    });

    test('3. Holiday removes classes for specified date', () async {
      final holidayDate = DateTime.utc(2026, 3, 15);
      final now = DateTime.now();

      final exception = ScheduleException(
        date: holidayDate,
        type: ScheduleExceptionType.holiday,
        title: 'Spring Break Holiday',
        description: 'All classes cancelled',
        createdAt: now,
        updatedAt: now,
      );

      await exceptionRepository.saveException(exception);

      final exceptionsOnHoliday =
          await exceptionRepository.getExceptionsForDate(holidayDate);
      expect(exceptionsOnHoliday.length, 1);
      expect(exceptionsOnHoliday.first.type, ScheduleExceptionType.holiday);
    });

    test('4. Cancelled class removes only that date for target subject',
        () async {
      final cancelDate = DateTime.utc(2026, 3, 25);
      final now = DateTime.now();

      final exception = ScheduleException(
        date: cancelDate,
        subjectId: 101, // Operating Systems
        type: ScheduleExceptionType.cancelledClass,
        title: 'OS Class Cancelled',
        description: 'Faculty on leave',
        createdAt: now,
        updatedAt: now,
      );

      await exceptionRepository.saveException(exception);

      final exceptionsOnDate =
          await exceptionRepository.getExceptionsForDate(cancelDate);
      expect(exceptionsOnDate.length, 1);
      expect(exceptionsOnDate.first.subjectId, 101);
      expect(
        exceptionsOnDate.first.type,
        ScheduleExceptionType.cancelledClass,
      );
    });

    test('5. Exam appears correctly for date and subject', () async {
      final examDate = DateTime.utc(2026, 3, 20);
      final now = DateTime.now();

      final exception = ScheduleException(
        date: examDate,
        subjectId: 101,
        type: ScheduleExceptionType.exam,
        title: 'OS Midterm Exam',
        description: 'Units 1-4 Covered',
        createdAt: now,
        updatedAt: now,
      );

      await exceptionRepository.saveException(exception);

      final exceptionsOnDate =
          await exceptionRepository.getExceptionsForDate(examDate);
      expect(exceptionsOnDate.length, 1);
      expect(exceptionsOnDate.first.type, ScheduleExceptionType.exam);
      expect(exceptionsOnDate.first.title, 'OS Midterm Exam');
    });

    test('6. Offline database persistence works', () async {
      final now = DateTime.now();
      final rule = WeeklyScheduleRule(
        subjectId: 102,
        dayOfWeek: 3,
        startTime: '11:00',
        endTime: '12:00',
        createdAt: now,
        updatedAt: now,
      );

      await ruleRepository.saveRule(rule);
      final savedRules = await ruleRepository.getRulesForSubject(102);
      expect(savedRules.isNotEmpty, isTrue);

      final localRaw = await ruleDataSource.getRuleById(savedRules.first.id!);
      expect(localRaw, isNotNull);
      expect(localRaw!.subjectId, 102);
      expect(localRaw.dayOfWeek, 3);
    });
  });
}
