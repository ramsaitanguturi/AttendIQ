import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/repositories/weekly_schedule_rule_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/schedule_exception_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import 'package:attend_iq/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/timetable_controller.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart';
import 'package:attend_iq/features/timetable/data/utils/occurrence_identity.dart';

class _FakeSubjectListNotifier extends SubjectListController {
  final List<Subject> _subjects;
  _FakeSubjectListNotifier(this._subjects);

  @override
  FutureOr<List<Subject>> build() => _subjects;
}

class _InMemoryRuleRepo implements WeeklyScheduleRuleRepository {
  final List<WeeklyScheduleRule> rules = [];

  @override
  Future<List<WeeklyScheduleRule>> getRulesForSemester(int semesterId) async =>
      rules.where((r) => r.isActive).toList();

  @override
  Future<List<WeeklyScheduleRule>> getRulesForSubject(int subjectId) async =>
      rules.where((r) => r.subjectId == subjectId && r.isActive).toList();

  @override
  Future<WeeklyScheduleRule?> getRuleById(int id) async =>
      rules.where((r) => r.id == id).firstOrNull;

  @override
  Future<void> saveRule(WeeklyScheduleRule rule) async {
    rules.removeWhere((r) => r.id == rule.id);
    rules.add(rule);
  }

  @override
  Future<void> saveRules(List<WeeklyScheduleRule> ruleList) async {
    for (final r in ruleList) {
      await saveRule(r);
    }
  }

  @override
  Future<void> deleteRule(int id) async {
    rules.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> deleteRulesForSubject(int subjectId) async {
    rules.removeWhere((r) => r.subjectId == subjectId);
  }

  @override
  Stream<void> watchRules(int semesterId) => const Stream<void>.empty();
}

class _InMemoryExceptionRepo implements ScheduleExceptionRepository {
  final List<ScheduleException> exceptions = [];

  @override
  Future<List<ScheduleException>> getExceptionsForDate(DateTime date) async {
    final norm = normalizeUtcDate(date);
    return exceptions
        .where((e) => normalizeUtcDate(e.date).isAtSameMomentAs(norm))
        .toList();
  }

  @override
  Future<List<ScheduleException>> getExceptionsForRange(
      DateTime startDate, DateTime endDate) async {
    return exceptions
        .where((e) => !e.date.isBefore(startDate) && !e.date.isAfter(endDate))
        .toList();
  }

  @override
  Future<List<ScheduleException>> getAllExceptions() async =>
      List.unmodifiable(exceptions);

  @override
  Future<ScheduleException?> getExceptionById(int id) async =>
      exceptions.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> saveException(ScheduleException exception) async {
    exceptions.add(exception);
  }

  @override
  Future<void> deleteException(int id) async {
    exceptions.removeWhere((e) => e.id == id);
  }

  @override
  Stream<void> watchExceptions() => const Stream.empty();
}

class _InMemoryOccurrenceRepo implements DailyScheduleOccurrenceRepository {
  final List<DailyScheduleOccurrence> occurrences = [];

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDate(
      DateTime date) async {
    final norm = normalizeUtcDate(date);
    return occurrences
        .where((o) => normalizeUtcDate(o.date).isAtSameMomentAs(norm))
        .toList();
  }

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDateRange(
          DateTime start, DateTime end) async =>
      occurrences;

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForSubject(
          int subjectId) async =>
      occurrences.where((o) => o.subjectId == subjectId).toList();

  @override
  Future<DailyScheduleOccurrence?> getOccurrenceById(int id) async =>
      occurrences.where((o) => o.id == id).firstOrNull;

  Future<DailyScheduleOccurrence?> getOccurrenceBySlotKey(
          String slotKey) async =>
      occurrences.where((o) => o.slotKey == slotKey).firstOrNull;

  @override
  Future<DailyScheduleOccurrence> saveOccurrence(
      DailyScheduleOccurrence occurrence) async {
    occurrences.add(occurrence);
    return occurrence;
  }

  @override
  Future<List<DailyScheduleOccurrence>> saveOccurrences(
      List<DailyScheduleOccurrence> list) async {
    occurrences.addAll(list);
    return list;
  }

  @override
  Future<void> deleteOccurrence(int id) async {
    occurrences.removeWhere((o) => o.id == id);
  }

  @override
  Future<List<DailyScheduleOccurrence>> getAllOccurrences() async =>
      occurrences;

  @override
  Stream<void> watchOccurrencesForDate(DateTime date) => const Stream.empty();
}

class _InMemoryAttendanceRepo implements AttendanceRepository {
  final List<AttendanceRecord> records = [];

  @override
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId) async =>
      records.where((r) => r.subjectId == subjectId).toList();

  @override
  Future<AttendanceRecord?> getAttendanceForOccurrence(
          int occurrenceId) async =>
      records
          .where((r) => (r.occurrenceId ?? r.eventId) == occurrenceId)
          .firstOrNull;

  @override
  Future<AttendanceRecord?> getAttendanceForOccurrenceAnyStatus(
          int occurrenceId) async =>
      records
          .where((r) => (r.occurrenceId ?? r.eventId) == occurrenceId)
          .firstOrNull;

  @override
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId) =>
      getAttendanceForOccurrence(eventId);

  @override
  Future<AttendanceRecord?> getAttendanceForEventAnyStatus(int eventId) =>
      getAttendanceForOccurrenceAnyStatus(eventId);

  @override
  Future<void> saveAttendanceRecord(AttendanceRecord record) async =>
      records.add(record);

  @override
  Future<void> deleteAttendanceRecord(int id) async =>
      records.removeWhere((r) => r.id == id);

  @override
  Stream<void> watchAttendance(int subjectId) => const Stream.empty();

  @override
  Future<void> updateEventStatus(int eventId, String status) async {}

  @override
  Future<DailyScheduleOccurrence> saveExtraClassWithAttendance({
    int? occurrenceId,
    required int subjectId,
    required DateTime date,
    String? subjectTitle,
    String? startTime,
    String? endTime,
    String? reason,
    AttendanceStatus? status,
    bool autoAllocateSlot = false,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('NEW-BUG-03: Future occurrence date corruption regression tests', () {
    late _InMemoryRuleRepo ruleRepo;
    late _InMemoryExceptionRepo exceptionRepo;
    late _InMemoryOccurrenceRepo occurrenceRepo;
    late _InMemoryAttendanceRepo attendanceRepo;

    final nowUtc = DateTime.utc(2026, 1, 1);

    final activeSemester = Semester(
      id: 'sem_1',
      localId: 1,
      name: 'Spring 2026',
      startDate: DateTime.utc(2026, 1, 1),
      endDate: DateTime.utc(2026, 6, 30),
      requiredAttendanceRate: 75.0,
    );

    final subjectMath = Subject(
      id: 10,
      semesterId: 1,
      name: 'Mathematics',
      code: 'MATH101',
      credits: 4,
      attendanceTarget: 75,
      color: '#4F46E5',
      type: SubjectType.THEORY,
      updatedAt: nowUtc,
    );

    final subjectPhysics = Subject(
      id: 20,
      semesterId: 1,
      name: 'Physics',
      code: 'PHYS101',
      credits: 4,
      attendanceTarget: 75,
      color: '#06B6D4',
      type: SubjectType.THEORY,
      updatedAt: nowUtc,
    );

    setUp(() {
      ruleRepo = _InMemoryRuleRepo();
      exceptionRepo = _InMemoryExceptionRepo();
      occurrenceRepo = _InMemoryOccurrenceRepo();
      attendanceRepo = _InMemoryAttendanceRepo();

      // Rule: Monday (weekday 1) Mathematics 09:00 - 10:00
      ruleRepo.rules.add(
        WeeklyScheduleRule(
          id: 100,
          subjectId: 10,
          dayOfWeek: 1, // Monday
          startTime: '09:00',
          endTime: '10:00',
          room: 'Room 101',
          isActive: true,
          createdAt: nowUtc,
          updatedAt: nowUtc,
        ),
      );

      // Rule: Monday (weekday 1) Physics 10:15 - 11:15
      ruleRepo.rules.add(
        WeeklyScheduleRule(
          id: 200,
          subjectId: 20,
          dayOfWeek: 1, // Monday
          startTime: '10:15',
          endTime: '11:15',
          room: 'Lab 2',
          isActive: true,
          createdAt: nowUtc,
          updatedAt: nowUtc,
        ),
      );
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          activeSemesterProvider
              .overrideWith((ref) => Future.value(activeSemester)),
          subjectListControllerProvider.overrideWith(
              () => _FakeSubjectListNotifier([subjectMath, subjectPhysics])),
          weeklyScheduleRuleRepositoryProvider.overrideWithValue(ruleRepo),
          scheduleExceptionRepositoryProvider.overrideWithValue(exceptionRepo),
          dailyScheduleOccurrenceRepositoryProvider
              .overrideWithValue(occurrenceRepo),
          attendanceRepositoryProvider.overrideWithValue(attendanceRepo),
        ],
      );
    }

    test(
        '1. ScheduleClassSlot carries correct occurrence date populated from DayScheduleData.date',
        () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // 2026-03-02 is a Monday (weekday 1)
      final targetMonday = DateTime.utc(2026, 3, 2);
      final dayData =
          await container.read(dayScheduleProvider(targetMonday).future);

      expect(dayData.date, equals(targetMonday));
      expect(dayData.items.length, equals(2));

      // Each slot must carry the day's date!
      for (final slot in dayData.items) {
        expect(slot.date, isNotNull);
        expect(normalizeUtcDate(slot.date!), equals(targetMonday));
      }
    });

    test(
        '2. Cancelling future occurrence affects only that date and does not corrupt today',
        () async {
      final container = createContainer();
      addTearDown(container.dispose);

      // Today: Monday 2026-03-02
      final todayMonday = DateTime.utc(2026, 3, 2);
      // Future: Monday 2026-03-16 (two weeks later)
      final futureMonday = DateTime.utc(2026, 3, 16);

      // Both initially have Mathematics
      final todayBefore =
          await container.read(dayScheduleProvider(todayMonday).future);
      final futureBefore =
          await container.read(dayScheduleProvider(futureMonday).future);
      expect(todayBefore.items.any((s) => s.subjectId == 10), isTrue);
      expect(futureBefore.items.any((s) => s.subjectId == 10), isTrue);

      // Cancel Mathematics ONLY on futureMonday
      await exceptionRepo.saveException(
        ScheduleException(
          date: futureMonday,
          subjectId: 10,
          type: ScheduleExceptionType.CANCELLED_CLASS,
          title: 'Math Cancelled',
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      // Invalidate to simulate provider refresh after adding exception
      container.invalidate(dayScheduleByKeyProvider);

      // Re-read both days
      final todayAfter =
          await container.read(dayScheduleProvider(todayMonday).future);
      final futureAfter =
          await container.read(dayScheduleProvider(futureMonday).future);

      // Today still has Mathematics!
      expect(todayAfter.items.any((s) => s.subjectId == 10), isTrue);
      expect(todayAfter.items.length, equals(2));

      // Future date had Mathematics removed!
      expect(futureAfter.items.any((s) => s.subjectId == 10), isFalse);
      expect(futureAfter.items.length, equals(1)); // Only Physics remains
      expect(futureAfter.items.first.subjectId, equals(20));

      // Weekly schedule rules in repo remain completely unchanged (recurring rule preserved)
      final allRules = await ruleRepo.getRulesForSemester(1);
      expect(allRules.length, equals(2));
      expect(allRules.any((r) => r.subjectId == 10 && r.isActive), isTrue);
    });

    test(
        '3. Editing past occurrence leaves neighboring dates and recurring rules unchanged',
        () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final pastMonday = DateTime.utc(2026, 2, 2);
      final neighboringMonday = DateTime.utc(2026, 2, 9);

      // Cancel Physics on past Monday
      await exceptionRepo.saveException(
        ScheduleException(
          date: pastMonday,
          subjectId: 20,
          type: ScheduleExceptionType.CANCELLED_CLASS,
          title: 'Physics Postponed',
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      final pastSchedule =
          await container.read(dayScheduleProvider(pastMonday).future);
      final neighborSchedule =
          await container.read(dayScheduleProvider(neighboringMonday).future);

      expect(pastSchedule.items.any((s) => s.subjectId == 20), isFalse);
      expect(neighborSchedule.items.any((s) => s.subjectId == 20), isTrue);
      expect(neighborSchedule.items.length, equals(2));
    });

    test(
        '4. Adding Exam exception on future occurrence populates exam slot on that date only',
        () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final futureDate = DateTime.utc(2026, 4, 6);
      final todayDate = DateTime.utc(2026, 3, 2);

      await exceptionRepo.saveException(
        ScheduleException(
          date: futureDate,
          subjectId: 10,
          type: ScheduleExceptionType.EXAM,
          title: 'Math Midterm',
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      final futureSchedule =
          await container.read(dayScheduleProvider(futureDate).future);
      final todaySchedule =
          await container.read(dayScheduleProvider(todayDate).future);

      // Future schedule has the exam slot with the correct date
      final examSlot = futureSchedule.items
          .where((s) => s.type == ScheduleSlotType.exam)
          .firstOrNull;
      expect(examSlot, isNotNull);
      expect(examSlot!.date, equals(futureDate));
      expect(examSlot.title, equals('Mathematics Exam'));

      // Today has NO exam
      expect(todaySchedule.items.any((s) => s.type == ScheduleSlotType.exam),
          isFalse);
    });
  });
}
