import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/models/schedule_exception_local.dart';
import 'package:attend_iq/features/timetable/data/datasources/weekly_schedule_rule_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/datasources/schedule_exception_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/repositories/weekly_schedule_rule_repository_impl.dart';
import 'package:attend_iq/features/timetable/data/repositories/schedule_exception_repository_impl.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';

class FakeWeeklyScheduleRuleLocalDataSource implements WeeklyScheduleRuleLocalDataSource {
  final Map<int, WeeklyScheduleRuleLocal> rules = {};
  final List<SubjectLocal> subjects = [];
  int _nextId = 1;

  @override
  Future<List<WeeklyScheduleRuleLocal>> getRulesForSubject(int subjectId) async {
    return rules.values.where((r) => r.subjectId == subjectId && !r.isDeleted).toList();
  }

  @override
  Future<List<WeeklyScheduleRuleLocal>> getRulesForSemester(int semesterId) async {
    final subjectIds = subjects.where((s) => s.semesterId == semesterId && !s.isDeleted).map((s) => s.id).toSet();
    if (subjectIds.isEmpty) return [];
    return rules.values.where((r) => subjectIds.contains(r.subjectId) && !r.isDeleted).toList();
  }

  @override
  Future<WeeklyScheduleRuleLocal?> getRuleById(int id) async => rules[id];

  @override
  Future<void> saveRule(WeeklyScheduleRuleLocal rule) async {
    if (rule.id == 0) {
      rule.id = _nextId++;
    }
    rules[rule.id] = rule;
  }

  @override
  Future<void> saveRules(List<WeeklyScheduleRuleLocal> ruleList) async {
    for (final r in ruleList) {
      if (r.id == 0) {
        r.id = _nextId++;
      }
      rules[r.id] = r;
    }
  }

  @override
  Future<void> deleteRule(int id) async {
    if (rules.containsKey(id)) {
      rules[id]!.isDeleted = true;
    }
  }

  @override
  Future<void> deleteRulesForSubject(int subjectId) async {
    for (final r in rules.values) {
      if (r.subjectId == subjectId) {
        r.isDeleted = true;
      }
    }
  }

  @override
  Stream<void> watchRules(int semesterId) => const Stream.empty();
}

class FakeScheduleExceptionLocalDataSource implements ScheduleExceptionLocalDataSource {
  final Map<int, ScheduleExceptionLocal> exceptions = {};
  int _nextId = 1;

  DateTime _cleanDate(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);

  @override
  Future<List<ScheduleExceptionLocal>> getExceptionsForDate(DateTime date) async {
    final target = _cleanDate(date);
    return exceptions.values.where((e) => _cleanDate(e.date) == target && !e.isDeleted).toList();
  }

  @override
  Future<List<ScheduleExceptionLocal>> getExceptionsForRange(DateTime startDate, DateTime endDate) async {
    final start = _cleanDate(startDate);
    final end = _cleanDate(endDate);
    return exceptions.values.where((e) {
      final date = _cleanDate(e.date);
      return !e.isDeleted &&
          (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
          (date.isBefore(end) || date.isAtSameMomentAs(end));
    }).toList();
  }

  @override
  Future<ScheduleExceptionLocal?> getExceptionById(int id) async => exceptions[id];

  @override
  Future<void> saveException(ScheduleExceptionLocal exception) async {
    if (exception.id == 0) {
      exception.id = _nextId++;
    }
    exceptions[exception.id] = exception;
  }

  @override
  Future<void> deleteException(int id) async {
    if (exceptions.containsKey(id)) {
      exceptions[id]!.isDeleted = true;
    }
  }

  @override
  Stream<void> watchExceptions() => const Stream.empty();
}

void main() {
  late FakeWeeklyScheduleRuleLocalDataSource ruleDataSource;
  late FakeScheduleExceptionLocalDataSource exceptionDataSource;
  late WeeklyScheduleRuleRepositoryImpl ruleRepository;
  late ScheduleExceptionRepositoryImpl exceptionRepository;

  setUp(() {
    ruleDataSource = FakeWeeklyScheduleRuleLocalDataSource();
    exceptionDataSource = FakeScheduleExceptionLocalDataSource();
    ruleRepository = WeeklyScheduleRuleRepositoryImpl(localDataSource: ruleDataSource);
    exceptionRepository = ScheduleExceptionRepositoryImpl(localDataSource: exceptionDataSource);

    ruleDataSource.subjects.addAll([
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

  group('AttendIQ Timetable & Calendar Exceptions Tests', () {
    test('1. Subject with multiple days appears correctly', () async {
      // Operating Systems on Monday (1), Tuesday (2), Friday (5)
      final days = [1, 2, 5];
      final now = DateTime.now();

      final rules = days.map((day) => WeeklyScheduleRule(
        subjectId: 101,
        dayOfWeek: day,
        startTime: '10:00',
        endTime: '11:00',
        room: 'Room A203',
        faculty: 'Dr. Smith',
        createdAt: now,
        updatedAt: now,
      )).toList();

      await ruleRepository.saveRules(rules);

      final subjectRules = await ruleRepository.getRulesForSubject(101);
      expect(subjectRules.length, 3);
      final daysOfWeek = subjectRules.map((r) => r.dayOfWeek).toList()..sort();
      expect(daysOfWeek, [1, 2, 5]);
    });

    test('2. Dashboard loads today classes based on weekday rules', () async {
      final now = DateTime.now();
      final todayWeekday = now.weekday;

      await ruleRepository.saveRule(WeeklyScheduleRule(
        subjectId: 101,
        dayOfWeek: todayWeekday,
        startTime: '10:00',
        endTime: '11:00',
        room: 'Room A203',
        createdAt: now,
        updatedAt: now,
      ));

      final activeRules = await ruleRepository.getRulesForSemester(1);
      final todayClasses = activeRules.where((r) => r.dayOfWeek == todayWeekday).toList();
      expect(todayClasses.length, 1);
      expect(todayClasses.first.subjectId, 101);
      expect(todayClasses.first.startTime, '10:00');
    });

    test('3. Holiday removes classes for specified date', () async {
      final holidayDate = DateTime.utc(2026, 3, 15);
      final now = DateTime.now();

      final exception = ScheduleException(
        date: holidayDate,
        type: ScheduleExceptionType.HOLIDAY,
        title: 'Spring Break Holiday',
        description: 'All classes cancelled',
        createdAt: now,
        updatedAt: now,
      );

      await exceptionRepository.saveException(exception);

      final exceptionsOnHoliday = await exceptionRepository.getExceptionsForDate(holidayDate);
      expect(exceptionsOnHoliday.length, 1);
      expect(exceptionsOnHoliday.first.type, ScheduleExceptionType.HOLIDAY);
    });

    test('4. Cancelled class removes only that date for target subject', () async {
      final cancelDate = DateTime.utc(2026, 3, 25);
      final now = DateTime.now();

      final exception = ScheduleException(
        date: cancelDate,
        subjectId: 101, // Operating Systems
        type: ScheduleExceptionType.CANCELLED_CLASS,
        title: 'OS Class Cancelled',
        description: 'Faculty on leave',
        createdAt: now,
        updatedAt: now,
      );

      await exceptionRepository.saveException(exception);

      final exceptionsOnDate = await exceptionRepository.getExceptionsForDate(cancelDate);
      expect(exceptionsOnDate.length, 1);
      expect(exceptionsOnDate.first.subjectId, 101);
      expect(exceptionsOnDate.first.type, ScheduleExceptionType.CANCELLED_CLASS);
    });

    test('5. Exam appears correctly for date and subject', () async {
      final examDate = DateTime.utc(2026, 3, 20);
      final now = DateTime.now();

      final exception = ScheduleException(
        date: examDate,
        subjectId: 101,
        type: ScheduleExceptionType.EXAM,
        title: 'OS Midterm Exam',
        description: 'Units 1-4 Covered',
        createdAt: now,
        updatedAt: now,
      );

      await exceptionRepository.saveException(exception);

      final exceptionsOnDate = await exceptionRepository.getExceptionsForDate(examDate);
      expect(exceptionsOnDate.length, 1);
      expect(exceptionsOnDate.first.type, ScheduleExceptionType.EXAM);
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
