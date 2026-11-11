import 'dart:async';

import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:attend_iq/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/schedule_exception_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/weekly_schedule_rule_repository.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/timetable_controller.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/today_schedule_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final timestamp = DateTime.utc(2026, 7, 1);

  final testSemester = Semester(
    id: 'sem_1',
    localId: 1,
    name: 'Fall 2026',
    startDate: DateTime(2026, 7, 1),
    endDate: DateTime(2026, 12, 31),
    requiredAttendanceRate: 75.0,
  );

  final algorithmsSubject = Subject(
    id: 101,
    semesterId: 1,
    name: 'Algorithms',
    code: 'CS301',
    faculty: 'Dr. Ada Lovelace',
    credits: 4,
    attendanceTarget: 75.0,
    color: '#2196F3',
    type: SubjectType.THEORY,
    updatedAt: timestamp,
  );

  final osLabSubject = Subject(
    id: 102,
    semesterId: 1,
    name: 'Operating Systems Lab',
    code: 'CS302L',
    faculty: 'Prof. Grace Hopper',
    credits: 2,
    attendanceTarget: 75.0,
    color: '#4CAF50',
    type: SubjectType.LAB,
    updatedAt: timestamp,
  );

  ProviderContainer createContainer({
    Semester? semester,
    List<Subject> subjects = const [],
    List<WeeklyScheduleRule> rules = const [],
    List<ScheduleException> exceptions = const [],
    List<DailyScheduleOccurrence> savedOccurrences = const [],
    List<AttendanceRecord> attendanceRecords = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        activeSemesterProvider.overrideWith(
          (ref) => Future<Semester?>.value(semester),
        ),
        subjectListControllerProvider.overrideWith(
          () => _FakeSubjectListNotifier(subjects),
        ),
        scheduleExceptionControllerProvider.overrideWith(
          () => _FakeScheduleExceptionNotifier(exceptions),
        ),
        scheduleExceptionRepositoryProvider.overrideWithValue(
          _FakeScheduleExceptionRepository(exceptions),
        ),
        dailyScheduleOccurrenceRepositoryProvider.overrideWithValue(
          _FakeDailyScheduleOccurrenceRepository(savedOccurrences),
        ),
        weeklyScheduleRuleRepositoryProvider.overrideWithValue(
          _FakeWeeklyScheduleRuleRepository(rules),
        ),
        attendanceRepositoryProvider.overrideWithValue(
          _FakeAttendanceRepository(attendanceRecords),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('todayScheduleProvider (BUG-001 regression)', () {
    test(
      'resolves typed Subject name and faculty fallback for active weekly rules',
      () async {
        // 2026-07-06 is Monday (weekday == 1).
        final monday = DateTime(2026, 7, 6);
        final rules = [
          WeeklyScheduleRule(
            id: 11,
            subjectId: 102,
            dayOfWeek: 1,
            startTime: '11:00',
            endTime: '12:00',
            room: 'Lab-2',
            faculty: 'Dr. Alan Turing',
            type: SubjectType.LAB,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
          WeeklyScheduleRule(
            id: 10,
            subjectId: 101,
            dayOfWeek: 1,
            startTime: '09:00',
            endTime: '10:00',
            room: 'LH-1',
            faculty: null,
            type: SubjectType.THEORY,
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        ];

        final container = createContainer(
          semester: testSemester,
          subjects: [algorithmsSubject, osLabSubject],
          rules: rules,
        );

        final result = await container.read(
          todayScheduleProvider(customDate: monday).future,
        );

        expect(result.isHoliday, isFalse);
        expect(result.occurrences, hasLength(2));

        // Sorted ascending by startTime: 09:00 first, 11:00 second.
        final first = result.occurrences[0];
        expect(first.subjectId, equals(101));
        expect(first.title, equals('Algorithms'));
        expect(first.faculty, equals('Dr. Ada Lovelace'));
        expect(first.room, equals('LH-1'));
        expect(first.type, equals(OccurrenceType.REGULAR_CLASS));
        expect(first.status, equals(OccurrenceStatus.UPCOMING));

        final second = result.occurrences[1];
        expect(second.subjectId, equals(102));
        expect(second.title, equals('Operating Systems Lab'));
        expect(second.faculty, equals('Dr. Alan Turing'));
        expect(second.room, equals('Lab-2'));
      },
    );

    test(
      'resolves typed Subject name for exam exceptions and preserves subjectless exams',
      () async {
        // 2026-07-07 is Tuesday (weekday == 2).
        final tuesday = DateTime(2026, 7, 7);
        final tuesdayUtc = DateTime.utc(2026, 7, 7);

        final exceptions = [
          ScheduleException(
            id: 1,
            date: tuesdayUtc,
            subjectId: 101,
            type: ScheduleExceptionType.EXAM,
            title: 'Midterm',
            description: 'Room 101',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
          ScheduleException(
            id: 2,
            date: tuesdayUtc,
            subjectId: null,
            type: ScheduleExceptionType.EXAM,
            title: 'General Aptitude Test',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        ];

        final container = createContainer(
          semester: testSemester,
          subjects: [algorithmsSubject],
          exceptions: exceptions,
        );

        final result = await container.read(
          todayScheduleProvider(customDate: tuesday).future,
        );

        expect(result.isHoliday, isFalse);
        expect(result.occurrences, hasLength(2));

        final subjectExam = result.occurrences.firstWhere(
          (o) => o.subjectId == 101,
        );
        expect(subjectExam.title, equals('Algorithms Exam'));
        expect(subjectExam.type, equals(OccurrenceType.EXAM));
        expect(subjectExam.reason, equals('Room 101'));

        final generalExam = result.occurrences.firstWhere(
          (o) => o.subjectId == null,
        );
        expect(generalExam.title, equals('General Aptitude Test'));
        expect(generalExam.reason, equals('Exam Event'));
      },
    );

    test(
      'skips weekly rules whose subjectId is missing from subjectMap',
      () async {
        final monday = DateTime(2026, 7, 6);
        final rules = [
          WeeklyScheduleRule(
            id: 20,
            subjectId: 999,
            dayOfWeek: 1,
            startTime: '08:00',
            endTime: '09:00',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
          WeeklyScheduleRule(
            id: 21,
            subjectId: 101,
            dayOfWeek: 1,
            startTime: '10:00',
            endTime: '11:00',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        ];

        final container = createContainer(
          semester: testSemester,
          subjects: [algorithmsSubject],
          rules: rules,
        );

        final result = await container.read(
          todayScheduleProvider(customDate: monday).future,
        );

        expect(result.occurrences, hasLength(1));
        expect(result.occurrences.single.subjectId, equals(101));
        expect(result.occurrences.single.title, equals('Algorithms'));
      },
    );

    test(
      'returns holiday state with empty occurrences when HOLIDAY exception exists',
      () async {
        final wednesday = DateTime(2026, 7, 8);
        final exceptions = [
          ScheduleException(
            id: 3,
            date: DateTime.utc(2026, 7, 8),
            type: ScheduleExceptionType.HOLIDAY,
            title: 'Founders Day',
            description: 'Campus closed',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        ];

        final container = createContainer(
          semester: testSemester,
          subjects: [algorithmsSubject],
          exceptions: exceptions,
        );

        final result = await container.read(
          todayScheduleProvider(customDate: wednesday).future,
        );

        expect(result.isHoliday, isTrue);
        expect(result.holidayTitle, equals('Founders Day'));
        expect(result.holidayDescription, equals('Campus closed'));
        expect(result.occurrences, isEmpty);
      },
    );

    test(
      'merges saved occurrences, manual extra classes, cancellations, and attendance records',
      () async {
        // 2026-07-06 is Monday (weekday == 1).
        final monday = DateTime(2026, 7, 6);
        final mondayUtc = DateTime.utc(2026, 7, 6);

        final rules = [
          WeeklyScheduleRule(
            id: 30,
            subjectId: 101,
            dayOfWeek: 1,
            startTime: '09:00',
            endTime: '10:00',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
          WeeklyScheduleRule(
            id: 31,
            subjectId: 102,
            dayOfWeek: 1,
            startTime: '11:00',
            endTime: '12:00',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        ];

        final savedRegular = DailyScheduleOccurrence(
          id: 500,
          date: mondayUtc,
          subjectId: 101,
          title: 'Algorithms',
          startTime: '09:00',
          endTime: '10:00',
          type: OccurrenceType.REGULAR_CLASS,
          status: OccurrenceStatus.PRESENT,
          createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        final manualExtra = DailyScheduleOccurrence(
          id: 501,
          date: mondayUtc,
          subjectId: 102,
          title: 'Operating Systems Lab Extra',
          startTime: '15:00',
          endTime: '16:00',
          type: OccurrenceType.EXTRA_CLASS,
          status: OccurrenceStatus.UPCOMING,
          createdFrom: OccurrenceCreatedFrom.MANUAL,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        final attendanceRecords = [
          AttendanceRecord(
            id: 700,
            eventId: 99,
            subjectId: 102,
            status: AttendanceStatus.ABSENT,
            markedAt: mondayUtc,
            updatedAt: timestamp,
          ),
        ];

        final container = createContainer(
          semester: testSemester,
          subjects: [algorithmsSubject, osLabSubject],
          rules: rules,
          savedOccurrences: [savedRegular, manualExtra],
          attendanceRecords: attendanceRecords,
        );

        final result = await container.read(
          todayScheduleProvider(customDate: monday).future,
        );

        expect(result.isHoliday, isFalse);
        expect(result.occurrences, hasLength(3));
        expect(result.occurrences[0].id, equals(500));
        expect(result.occurrences[0].status, equals(OccurrenceStatus.PRESENT));
        expect(result.occurrences[1].subjectId, equals(102));
        expect(result.occurrences[1].status, equals(OccurrenceStatus.ABSENT));
        expect(result.occurrences[2].id, equals(501));
        expect(result.occurrences[2].type, equals(OccurrenceType.EXTRA_CLASS));
      },
    );

    test(
      'marks rule occurrence CANCELLED on CANCELLED_CLASS and handles null semester',
      () async {
        final monday = DateTime(2026, 7, 6);
        final mondayUtc = DateTime.utc(2026, 7, 6);

        final cancelledContainer = createContainer(
          semester: testSemester,
          subjects: [algorithmsSubject],
          rules: [
            WeeklyScheduleRule(
              id: 40,
              subjectId: 101,
              dayOfWeek: 1,
              startTime: '09:00',
              endTime: '10:00',
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          ],
          exceptions: [
            ScheduleException(
              id: 4,
              date: mondayUtc,
              subjectId: 101,
              type: ScheduleExceptionType.CANCELLED_CLASS,
              title: 'Instructor unavailable',
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          ],
        );

        final cancelledResult = await cancelledContainer.read(
          todayScheduleProvider(customDate: monday).future,
        );
        expect(cancelledResult.occurrences, hasLength(1));
        expect(
          cancelledResult.occurrences.single.status,
          equals(OccurrenceStatus.CANCELLED),
        );

        final noSemesterContainer = createContainer(semester: null);
        final noSemesterResult = await noSemesterContainer.read(
          todayScheduleProvider(customDate: monday).future,
        );
        expect(noSemesterResult.isHoliday, isFalse);
        expect(noSemesterResult.occurrences, isEmpty);
      },
    );
  });
}

class _FakeSubjectListNotifier extends SubjectListController {
  final List<Subject> _subjects;
  _FakeSubjectListNotifier(this._subjects);

  @override
  FutureOr<List<Subject>> build() => _subjects;
}

class _FakeScheduleExceptionNotifier extends ScheduleExceptionController {
  final List<ScheduleException> _exceptions;
  _FakeScheduleExceptionNotifier(this._exceptions);

  @override
  FutureOr<List<ScheduleException>> build() => _exceptions;
}

class _FakeScheduleExceptionRepository implements ScheduleExceptionRepository {
  final List<ScheduleException> _exceptions;
  _FakeScheduleExceptionRepository(this._exceptions);

  @override
  Future<List<ScheduleException>> getExceptionsForDate(DateTime date) async {
    return _exceptions
        .where(
          (e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day,
        )
        .toList();
  }

  @override
  Future<List<ScheduleException>> getExceptionsForRange(
    DateTime startDate,
    DateTime endDate,
  ) async =>
      _exceptions;

  @override
  Future<ScheduleException?> getExceptionById(int id) async =>
      _exceptions.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> saveException(ScheduleException exception) async {}

  @override
  Future<void> deleteException(int id) async {}

  @override
  Stream<void> watchExceptions() => const Stream<void>.empty();
}

class _FakeDailyScheduleOccurrenceRepository
    implements DailyScheduleOccurrenceRepository {
  final List<DailyScheduleOccurrence> _occurrences;
  _FakeDailyScheduleOccurrenceRepository(this._occurrences);

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDate(
    DateTime date,
  ) async {
    return _occurrences
        .where(
          (o) =>
              o.date.year == date.year &&
              o.date.month == date.month &&
              o.date.day == date.day,
        )
        .toList();
  }

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDateRange(
    DateTime start,
    DateTime end,
  ) async =>
      _occurrences;

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForSubject(
    int subjectId,
  ) async =>
      _occurrences.where((o) => o.subjectId == subjectId).toList();

  @override
  Future<DailyScheduleOccurrence?> getOccurrenceById(int id) async =>
      _occurrences.where((o) => o.id == id).firstOrNull;

  @override
  Future<DailyScheduleOccurrence> saveOccurrence(
    DailyScheduleOccurrence occurrence,
  ) async =>
      occurrence;

  @override
  Future<List<DailyScheduleOccurrence>> saveOccurrences(
    List<DailyScheduleOccurrence> occurrences,
  ) async =>
      occurrences;

  @override
  Future<void> deleteOccurrence(int id) async {}

  @override
  Future<List<DailyScheduleOccurrence>> getAllOccurrences() async =>
      _occurrences;

  @override
  Stream<void> watchOccurrencesForDate(DateTime date) =>
      const Stream<void>.empty();
}

class _FakeWeeklyScheduleRuleRepository
    implements WeeklyScheduleRuleRepository {
  final List<WeeklyScheduleRule> _rules;
  _FakeWeeklyScheduleRuleRepository(this._rules);

  @override
  Future<List<WeeklyScheduleRule>> getRulesForSubject(int subjectId) async =>
      _rules.where((r) => r.subjectId == subjectId).toList();

  @override
  Future<List<WeeklyScheduleRule>> getRulesForSemester(int semesterId) async =>
      _rules;

  @override
  Future<WeeklyScheduleRule?> getRuleById(int id) async =>
      _rules.where((r) => r.id == id).firstOrNull;

  @override
  Future<void> saveRule(WeeklyScheduleRule rule) async {}

  @override
  Future<void> saveRules(List<WeeklyScheduleRule> rules) async {}

  @override
  Future<void> deleteRule(int id) async {}

  @override
  Future<void> deleteRulesForSubject(int subjectId) async {}

  @override
  Stream<void> watchRules(int semesterId) => const Stream<void>.empty();
}

class _FakeAttendanceRepository implements AttendanceRepository {
  final List<AttendanceRecord> _records;
  _FakeAttendanceRepository(this._records);

  @override
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId) async =>
      _records.where((r) => r.subjectId == subjectId).toList();

  @override
  Future<AttendanceRecord?> getAttendanceForOccurrence(
    int occurrenceId,
  ) async =>
      _records
          .where((r) => (r.occurrenceId ?? r.eventId) == occurrenceId)
          .firstOrNull;

  @override
  Future<AttendanceRecord?> getAttendanceForOccurrenceAnyStatus(
    int occurrenceId,
  ) async =>
      _records
          .where((r) => (r.occurrenceId ?? r.eventId) == occurrenceId)
          .firstOrNull;

  @override
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId) =>
      getAttendanceForOccurrence(eventId);

  @override
  Future<AttendanceRecord?> getAttendanceForEventAnyStatus(int eventId) =>
      getAttendanceForOccurrenceAnyStatus(eventId);

  @override
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {}

  @override
  Future<void> deleteAttendanceRecord(int id) async {}

  @override
  Stream<void> watchAttendance(int subjectId) => const Stream<void>.empty();

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
