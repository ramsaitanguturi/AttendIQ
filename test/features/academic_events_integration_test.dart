import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:attend_iq/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/domain/repositories/subject_repository.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:attend_iq/features/timetable/domain/entities/academic_event.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/repositories/academic_event_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/schedule_exception_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/weekly_schedule_rule_repository.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/timetable_controller.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/today_schedule_provider.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart';
import 'package:attend_iq/features/widgets/data/widget_data_service.dart';
import 'package:attend_iq/features/academic_planner/domain/repositories/task_repository.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';

// --- Fakes extending Fake ---

class _FakeAcademicEventRepository extends Fake
    implements AcademicEventRepository {
  final List<AcademicEvent> events;
  _FakeAcademicEventRepository(this.events);

  @override
  Future<List<AcademicEvent>> getEventsForDate(DateTime date) async {
    final target = DateTime.utc(date.year, date.month, date.day);
    return events.where((e) {
      final d = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return d.isAtSameMomentAs(target) && !e.isDeleted;
    }).toList();
  }

  @override
  Future<List<AcademicEvent>> getEventsForRange(
      DateTime startDate, DateTime endDate) async {
    return events;
  }

  @override
  Future<List<AcademicEvent>> getAllEvents() async => events;

  @override
  Future<AcademicEvent?> getEventById(int id) async =>
      events.where((e) => e.id == id).firstOrNull;

  @override
  Stream<void> watchEvents() => const Stream<void>.empty();
}

class _FakeScheduleExceptionRepository extends Fake
    implements ScheduleExceptionRepository {
  final List<ScheduleException> exceptions;
  _FakeScheduleExceptionRepository(this.exceptions);

  @override
  Future<List<ScheduleException>> getExceptionsForDate(DateTime date) async {
    final target = DateTime.utc(date.year, date.month, date.day);
    return exceptions.where((e) {
      final d = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return d.isAtSameMomentAs(target) && !e.isDeleted;
    }).toList();
  }

  @override
  Future<List<ScheduleException>> getExceptionsForRange(
          DateTime start, DateTime end) async =>
      exceptions;

  @override
  Stream<void> watchExceptions() => const Stream<void>.empty();
}

class _FakeWeeklyScheduleRuleRepository extends Fake
    implements WeeklyScheduleRuleRepository {
  final List<WeeklyScheduleRule> rules;
  _FakeWeeklyScheduleRuleRepository(this.rules);

  @override
  Future<List<WeeklyScheduleRule>> getRulesForSemester(int semesterId) async =>
      rules;

  @override
  Future<List<WeeklyScheduleRule>> getRulesForSubject(int subjectId) async =>
      rules.where((r) => r.subjectId == subjectId).toList();

  @override
  Stream<void> watchRules(int semesterId) => const Stream<void>.empty();
}

class _FakeDailyScheduleOccurrenceRepository extends Fake
    implements DailyScheduleOccurrenceRepository {
  final List<DailyScheduleOccurrence> occurrences;
  _FakeDailyScheduleOccurrenceRepository(this.occurrences);

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDate(
          DateTime date) async =>
      occurrences;

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDateRange(
          DateTime start, DateTime end) async =>
      occurrences;

  @override
  Stream<void> watchOccurrencesForDate(DateTime date) =>
      const Stream<void>.empty();
}

class _FakeAttendanceRepository extends Fake implements AttendanceRepository {
  final List<AttendanceRecord> records;
  _FakeAttendanceRepository([this.records = const []]);

  @override
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId) async =>
      records.where((r) => r.subjectId == subjectId).toList();

  @override
  Future<AttendanceRecord?> getAttendanceForOccurrence(
          int occurrenceId) async =>
      null;

  @override
  Stream<void> watchAttendance(int subjectId) => const Stream<void>.empty();
}

class _FakeSubjectRepository extends Fake implements SubjectRepository {
  final List<Subject> subjects;
  _FakeSubjectRepository(this.subjects);

  @override
  Future<List<Subject>> getSubjectsBySemester(int semesterId,
      {bool includeDeleted = false}) async {
    return includeDeleted
        ? subjects
        : subjects.where((s) => !s.isDeleted).toList();
  }

  @override
  Future<Subject?> getSubjectById(int id) async =>
      subjects.where((s) => s.id == id).firstOrNull;

  @override
  Stream<void> watchSubjects(int semesterId) => const Stream<void>.empty();
}

class _FakeSemesterRepository extends Fake implements SemesterRepository {
  final Semester? activeSemester;
  _FakeSemesterRepository(this.activeSemester);

  @override
  Future<Semester?> getActiveSemester() async => activeSemester;

  @override
  Future<bool> hasActiveSemester() async => activeSemester != null;

  @override
  Future<List<Semester>> getAllSemesters() async =>
      activeSemester != null ? [activeSemester!] : [];

  @override
  Future<Semester?> getSemesterById(int id) async => activeSemester;
}

class _FakeTaskRepository extends Fake implements TaskRepository {
  @override
  Future<List<AcademicTask>> getAllTasks() async => [];
  @override
  Future<AcademicTask?> getTaskById(int id) async => null;
  @override
  Stream<void> watchTasks() => const Stream<void>.empty();
}

class _FakeSubjectListNotifier extends SubjectListController {
  final List<Subject> _initial;
  _FakeSubjectListNotifier(this._initial);

  @override
  FutureOr<List<Subject>> build() => _initial;
}

class _FakeScheduleExceptionNotifier extends ScheduleExceptionController {
  final List<ScheduleException> _initial;
  _FakeScheduleExceptionNotifier(this._initial);

  @override
  FutureOr<List<ScheduleException>> build() => _initial;
}

class _FakeAcademicEventNotifier extends AcademicEventController {
  final List<AcademicEvent> _initial;
  _FakeAcademicEventNotifier(this._initial);

  @override
  FutureOr<List<AcademicEvent>> build() => _initial;
}

void main() {
  final testDate = DateTime.utc(2026, 11, 16); // Monday
  final testSemester = Semester(
    id: 'sem_1',
    localId: 1,
    name: 'Fall 2026',
    startDate: DateTime.utc(2026, 8, 1),
    endDate: DateTime.utc(2026, 12, 31),
    requiredAttendanceRate: 75.0,
  );

  final mathSubject = Subject(
    id: 10,
    semesterId: 1,
    name: 'Mathematics',
    code: 'MATH101',
    credits: 4,
    color: '#4F46E5',
    attendanceTarget: 75.0,
    type: SubjectType.THEORY,
    updatedAt: DateTime.utc(2026, 8, 1),
  );

  final regularMathRule = WeeklyScheduleRule(
    id: 1,
    subjectId: 10,
    dayOfWeek: 1, // Monday
    startTime: '08:30',
    endTime: '09:30',
    room: 'Hall A',
    isActive: true,
    createdAt: DateTime.utc(2026, 8, 1),
    updatedAt: DateTime.utc(2026, 8, 1),
  );

  ProviderContainer createContainer({
    List<AcademicEvent> academicEvents = const [],
    List<ScheduleException> exceptions = const [],
    List<WeeklyScheduleRule> rules = const [],
    List<Subject> subjects = const [],
    List<DailyScheduleOccurrence> savedOccurrences = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        activeSemesterProvider.overrideWith(
          (ref) => testSemester,
        ),
        semesterRepositoryProvider
            .overrideWithValue(_FakeSemesterRepository(testSemester)),
        subjectListControllerProvider.overrideWith(
          () => _FakeSubjectListNotifier(subjects),
        ),
        subjectRepositoryProvider
            .overrideWithValue(_FakeSubjectRepository(subjects)),
        scheduleExceptionControllerProvider.overrideWith(
          () => _FakeScheduleExceptionNotifier(exceptions),
        ),
        scheduleExceptionRepositoryProvider.overrideWithValue(
          _FakeScheduleExceptionRepository(exceptions),
        ),
        academicEventControllerProvider.overrideWith(
          () => _FakeAcademicEventNotifier(academicEvents),
        ),
        academicEventRepositoryProvider.overrideWithValue(
          _FakeAcademicEventRepository(academicEvents),
        ),
        dailyScheduleOccurrenceRepositoryProvider.overrideWithValue(
          _FakeDailyScheduleOccurrenceRepository(savedOccurrences),
        ),
        weeklyScheduleRuleRepositoryProvider.overrideWithValue(
          _FakeWeeklyScheduleRuleRepository(rules),
        ),
        attendanceRepositoryProvider.overrideWithValue(
          _FakeAttendanceRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Group A: Exam & Academic Event Integration (NEW-BUG-01 & NEW-BUG-02)',
      () {
    test(
        '1. TodayScheduleProvider integrates AcademicEvent with actual start and end times',
        () async {
      final academicEvent = AcademicEvent(
        id: 101,
        title: 'Tech Symposium Keynote',
        description: 'Auditorium Main Hall',
        date: testDate,
        startTime: '10:30',
        endTime: '12:00',
        type: AcademicEventType.EVENT,
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      );

      final container = createContainer(
        subjects: [mathSubject],
        rules: [regularMathRule],
        academicEvents: [academicEvent],
      );

      final sub = container.listen(
          todayScheduleProvider(customDate: testDate), (_, __) {});
      final state = await container
          .read(todayScheduleProvider(customDate: testDate).future);
      sub.close();

      expect(state.isHoliday, isFalse);
      expect(state.occurrences.length, 2);

      // Verify regular rule occurrence is preserved
      final mathOcc =
          state.occurrences.firstWhere((o) => o.title == 'Mathematics');
      expect(mathOcc.startTime, '08:30');
      expect(mathOcc.endTime, '09:30');
      expect(mathOcc.type, OccurrenceType.REGULAR_CLASS);

      // Verify academic event occurrence is present with actual start & end times
      final eventOcc = state.occurrences
          .firstWhere((o) => o.title == 'Tech Symposium Keynote');
      expect(eventOcc.startTime, '10:30');
      expect(eventOcc.endTime, '12:00');
      expect(eventOcc.type, OccurrenceType.EVENT);
      expect(eventOcc.status, OccurrenceStatus.UPCOMING);
      expect(eventOcc.reason, 'Auditorium Main Hall');
    });

    test(
        '2. Deduplication: ScheduleException EXAM and AcademicEvent EXAM on same date are merged without duplicates',
        () async {
      final examException = ScheduleException(
        id: 201,
        date: testDate,
        subjectId: 10,
        type: ScheduleExceptionType.EXAM,
        title: 'Mathematics Midterm',
        description: 'Room 301',
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      );

      // Corresponding AcademicEvent with custom exam hours 14:00 - 16:30
      final examEvent = AcademicEvent(
        id: 301,
        title: 'Mathematics Midterm',
        date: testDate,
        startTime: '14:00',
        endTime: '16:30',
        type: AcademicEventType.EXAM,
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      );

      final container = createContainer(
        subjects: [mathSubject],
        rules: [regularMathRule],
        exceptions: [examException],
        academicEvents: [examEvent],
      );

      final sub = container.listen(
          todayScheduleProvider(customDate: testDate), (_, __) {});
      final state = await container
          .read(todayScheduleProvider(customDate: testDate).future);
      sub.close();

      // Should contain regular class + EXACTLY ONE exam occurrence (not two)
      expect(state.occurrences.length, 2);
      final examOccs = state.occurrences
          .where((o) => o.type == OccurrenceType.EXAM)
          .toList();
      expect(examOccs.length, 1);

      // Verified NEW-BUG-02: Uses actual 14:00 - 16:30 instead of hardcoded 09:00 - 12:00
      expect(examOccs.first.startTime, '14:00');
      expect(examOccs.first.endTime, '16:30');
      expect(examOccs.first.title, contains('Mathematics'));
    });

    test(
        '3. WeeklyScheduleViewController integrates academic events with ScheduleSlotType.event',
        () async {
      final workshopEvent = AcademicEvent(
        id: 401,
        title: 'AI Robotics Workshop',
        date: testDate,
        startTime: '13:00',
        endTime: '15:00',
        type: AcademicEventType.EVENT,
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      );

      final container = createContainer(
        subjects: [mathSubject],
        rules: [regularMathRule],
        academicEvents: [workshopEvent],
      );

      final dayData =
          await container.read(dayScheduleProvider(testDate).future);

      expect(dayData.isHoliday, isFalse);
      expect(dayData.items.length, 2);

      final eventSlot =
          dayData.items.firstWhere((i) => i.title == 'AI Robotics Workshop');
      expect(eventSlot.type, ScheduleSlotType.event);
      expect(eventSlot.startTime, '13:00');
      expect(eventSlot.endTime, '15:00');
      expect(eventSlot.colorHex, '#3B82F6');
    });

    test(
        '4. WidgetDataService.generateTodayWidgetData includes academic events and exams with actual times',
        () async {
      final examEvent = AcademicEvent(
        id: 501,
        title: 'Physics Practical Exam',
        date: testDate,
        startTime: '11:00',
        endTime: '13:00',
        type: AcademicEventType.EXAM,
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      );

      final seminarEvent = AcademicEvent(
        id: 502,
        title: 'Guest Lecture on Quantum Computing',
        date: testDate,
        startTime: '15:00',
        endTime: '16:30',
        type: AcademicEventType.EVENT,
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 1),
      );

      final widgetService = WidgetDataService(
        ruleRepo: _FakeWeeklyScheduleRuleRepository([regularMathRule]),
        occurrenceRepo: _FakeDailyScheduleOccurrenceRepository([]),
        exceptionRepo: _FakeScheduleExceptionRepository([]),
        eventRepo: _FakeAcademicEventRepository([examEvent, seminarEvent]),
        taskRepo: _FakeTaskRepository(),
        semesterRepo: _FakeSemesterRepository(testSemester),
        subjectRepo: _FakeSubjectRepository([mathSubject]),
        attendanceRepo: _FakeAttendanceRepository(),
      );

      final widgetData =
          await widgetService.generateTodayWidgetData(customDate: testDate);

      expect(widgetData.isHoliday, isFalse);
      expect(widgetData.classes.length, 3);

      final practicalItem = widgetData.classes
          .firstWhere((c) => c.subjectName == 'Physics Practical Exam');
      expect(practicalItem.startTime, '11:00');
      expect(practicalItem.endTime, '13:00');

      final lectureItem = widgetData.classes.firstWhere(
          (c) => c.subjectName == 'Guest Lecture on Quantum Computing');
      expect(lectureItem.startTime, '15:00');
      expect(lectureItem.endTime, '16:30');
    });
  });
}
