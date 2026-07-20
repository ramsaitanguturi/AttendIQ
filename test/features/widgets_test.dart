import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/features/widgets/domain/widget_models.dart';
import 'package:attend_iq/features/widgets/data/widget_data_service.dart';
import 'package:attend_iq/features/timetable/domain/repositories/weekly_schedule_rule_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/schedule_exception_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/academic_event_repository.dart';
import 'package:attend_iq/features/academic_planner/domain/repositories/task_repository.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/subject/domain/repositories/subject_repository.dart';
import 'package:attend_iq/features/attendance/domain/repositories/attendance_repository.dart';

import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/entities/academic_event.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/task_enums.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';

// Fake implementations for testing WidgetDataService
class FakeWeeklyScheduleRuleRepository implements WeeklyScheduleRuleRepository {
  final List<WeeklyScheduleRule> rules;
  FakeWeeklyScheduleRuleRepository(this.rules);
  @override
  Future<List<WeeklyScheduleRule>> getRulesForSemester(int semesterId) async => rules;
  @override
  Future<List<WeeklyScheduleRule>> getRulesForSubject(int subjectId) async =>
      rules.where((r) => r.subjectId == subjectId).toList();
  @override
  Future<WeeklyScheduleRule?> getRuleById(int id) async => rules.where((r) => r.id == id).firstOrNull;
  @override
  Future<void> saveRule(WeeklyScheduleRule rule) async {}
  @override
  Future<void> saveRules(List<WeeklyScheduleRule> rules) async {}
  @override
  Future<void> deleteRule(int id) async {}
  @override
  Future<void> deleteRulesForSubject(int subjectId) async {}
  @override
  Stream<void> watchRules(int semesterId) => const Stream.empty();
}

class FakeDailyScheduleOccurrenceRepository implements DailyScheduleOccurrenceRepository {
  final List<DailyScheduleOccurrence> occurrences;
  FakeDailyScheduleOccurrenceRepository(this.occurrences);
  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDate(DateTime date) async {
    return occurrences.where((o) =>
        o.date.year == date.year && o.date.month == date.month && o.date.day == date.day).toList();
  }
  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDateRange(DateTime start, DateTime end) async => occurrences;
  @override
  Future<DailyScheduleOccurrence?> getOccurrenceById(int id) async => null;
  @override
  Future<DailyScheduleOccurrence> saveOccurrence(DailyScheduleOccurrence occurrence) async => occurrence;
  @override
  Future<List<DailyScheduleOccurrence>> saveOccurrences(List<DailyScheduleOccurrence> occurrences) async => occurrences;
  @override
  Future<void> deleteOccurrence(int id) async {}
  @override
  Future<List<DailyScheduleOccurrence>> getAllOccurrences() async => occurrences;
  @override
  Stream<void> watchOccurrencesForDate(DateTime date) => const Stream.empty();
}

class FakeScheduleExceptionRepository implements ScheduleExceptionRepository {
  final List<ScheduleException> exceptions;
  FakeScheduleExceptionRepository(this.exceptions);
  @override
  Future<List<ScheduleException>> getExceptionsForDate(DateTime date) async {
    return exceptions.where((e) =>
        e.date.year == date.year && e.date.month == date.month && e.date.day == date.day).toList();
  }
  @override
  Future<List<ScheduleException>> getExceptionsForRange(DateTime startDate, DateTime endDate) async => exceptions;
  @override
  Future<ScheduleException?> getExceptionById(int id) async => exceptions.where((e) => e.id == id).firstOrNull;
  @override
  Future<void> saveException(ScheduleException exception) async {}
  @override
  Future<void> deleteException(int id) async {}
  @override
  Stream<void> watchExceptions() => const Stream.empty();
}

class FakeAcademicEventRepository implements AcademicEventRepository {
  final List<AcademicEvent> events;
  FakeAcademicEventRepository(this.events);
  @override
  Future<List<AcademicEvent>> getAllEvents() async => events;
  @override
  Future<List<AcademicEvent>> getEventsForRange(DateTime startDate, DateTime endDate) async => events;
  @override
  Future<List<AcademicEvent>> getEventsForDate(DateTime date) async => events;
  @override
  Future<AcademicEvent?> getEventById(int id) async => null;
  @override
  Future<void> saveEvent(AcademicEvent event) async {}
  @override
  Future<void> deleteEvent(int id) async {}
  @override
  Stream<void> watchEvents() => const Stream.empty();
}

class FakeTaskRepository implements TaskRepository {
  final List<AcademicTask> tasks;
  FakeTaskRepository(this.tasks);
  @override
  Future<List<AcademicTask>> getAllTasks() async => tasks;
  @override
  Future<AcademicTask?> getTaskById(int id) async => null;
  @override
  Future<void> saveTask(AcademicTask task) async {}
  @override
  Future<void> deleteTask(int id) async {}
  @override
  Stream<void> watchTasks() => const Stream.empty();
}

class FakeSemesterRepository implements SemesterRepository {
  final Semester? activeSemester;
  FakeSemesterRepository(this.activeSemester);
  @override
  Future<Semester?> getActiveSemester() async => activeSemester;
  @override
  Future<bool> hasActiveSemester() async => activeSemester != null;
  @override
  Future<List<Semester>> getAllSemesters() async => activeSemester != null ? [activeSemester!] : [];
  @override
  Future<void> createSemester(Semester semester) async {}
}

class FakeSubjectRepository implements SubjectRepository {
  final List<Subject> subjects;
  FakeSubjectRepository(this.subjects);
  @override
  Future<List<Subject>> getSubjectsBySemester(int semesterId) async => subjects;
  @override
  Future<Subject?> getSubjectById(int id) async => subjects.firstOrNull;
  @override
  Future<void> createSubject(Subject subject) async {}
  @override
  Future<void> updateSubject(Subject subject) async {}
  @override
  Future<void> deleteSubject(int id) async {}
  @override
  Stream<void> watchSubjects(int semesterId) => const Stream.empty();
}

class FakeAttendanceRepository implements AttendanceRepository {
  final List<AttendanceRecord> records;
  FakeAttendanceRepository(this.records);
  @override
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId) async =>
      records.where((r) => r.subjectId == subjectId).toList();
  @override
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId) async => null;
  @override
  Future<AttendanceRecord?> getAttendanceForEventAnyStatus(int eventId) async => null;
  @override
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {}
  @override
  Future<void> deleteAttendanceRecord(int id) async {}
  @override
  Stream<void> watchAttendance(int subjectId) => const Stream.empty();
  @override
  Future<void> updateEventStatus(int eventId, String status) async {}
  @override
  Future<int> createExtraClassEvent(int subjectId, DateTime date, String status) async => 1;
}

void main() {
  group('Android Home Screen Widgets Unit Tests', () {
    final mondayDate = DateTime(2026, 7, 20); // Monday
    final activeSem = Semester(
      localId: 1,
      name: 'Fall 2026',
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 12, 1),
      requiredAttendanceRate: 75.0,
    );

    final subjects = <Subject>[
      Subject(
        id: 101,
        semesterId: 1,
        name: 'Operating Systems',
        code: 'CS301',
        credits: 4,
        attendanceTarget: 75.0,
        color: '#4CAF50',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now(),
      ),
      Subject(
        id: 102,
        semesterId: 1,
        name: 'Data Structures',
        code: 'CS302',
        credits: 4,
        attendanceTarget: 75.0,
        color: '#2196F3',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now(),
      ),
    ];

    final rules = [
      WeeklyScheduleRule(
        id: 1,
        subjectId: 101,
        dayOfWeek: 1, // Monday
        startTime: '09:00',
        endTime: '10:00',
        room: 'Lab 1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WeeklyScheduleRule(
        id: 2,
        subjectId: 102,
        dayOfWeek: 1, // Monday
        startTime: '11:00',
        endTime: '12:00',
        room: 'Hall B',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('1. Today schedule extraction generates correct class list & next class', () async {
      final service = WidgetDataService(
        ruleRepo: FakeWeeklyScheduleRuleRepository(rules),
        occurrenceRepo: FakeDailyScheduleOccurrenceRepository([]),
        exceptionRepo: FakeScheduleExceptionRepository([]),
        eventRepo: FakeAcademicEventRepository([]),
        taskRepo: FakeTaskRepository([]),
        semesterRepo: FakeSemesterRepository(activeSem),
        subjectRepo: FakeSubjectRepository(subjects),
        attendanceRepo: FakeAttendanceRepository([]),
      );

      final todayData = await service.generateTodayWidgetData(customDate: mondayDate);

      expect(todayData.isHoliday, isFalse);
      expect(todayData.classes.length, equals(2));
      expect(todayData.classes[0].subjectName, equals('Operating Systems'));
      expect(todayData.classes[0].startTime, equals('09:00'));
      expect(todayData.classes[1].subjectName, equals('Data Structures'));
      expect(todayData.nextClass, isNotNull);
      expect(todayData.nextClass?.subjectName, equals('Operating Systems'));
    });

    test('2. Empty state handling for holiday returns holiday title', () async {
      final holidayException = ScheduleException(
        id: 1,
        date: DateTime.utc(2026, 7, 20),
        type: ScheduleExceptionType.HOLIDAY,
        title: 'Founder\'s Day',
        description: 'College Holiday',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final service = WidgetDataService(
        ruleRepo: FakeWeeklyScheduleRuleRepository(rules),
        occurrenceRepo: FakeDailyScheduleOccurrenceRepository([]),
        exceptionRepo: FakeScheduleExceptionRepository([holidayException]),
        eventRepo: FakeAcademicEventRepository([]),
        taskRepo: FakeTaskRepository([]),
        semesterRepo: FakeSemesterRepository(activeSem),
        subjectRepo: FakeSubjectRepository(subjects),
        attendanceRepo: FakeAttendanceRepository([]),
      );

      final todayData = await service.generateTodayWidgetData(customDate: mondayDate);

      expect(todayData.isHoliday, isTrue);
      expect(todayData.holidayTitle, equals('Founder\'s Day'));
      expect(todayData.classes, isEmpty);
    });

    test('3. Weekly schedule extraction generates week number and weekday items', () async {
      final service = WidgetDataService(
        ruleRepo: FakeWeeklyScheduleRuleRepository(rules),
        occurrenceRepo: FakeDailyScheduleOccurrenceRepository([]),
        exceptionRepo: FakeScheduleExceptionRepository([]),
        eventRepo: FakeAcademicEventRepository([]),
        taskRepo: FakeTaskRepository([]),
        semesterRepo: FakeSemesterRepository(activeSem),
        subjectRepo: FakeSubjectRepository(subjects),
        attendanceRepo: FakeAttendanceRepository([]),
      );

      final weeklyData = await service.generateWeeklyWidgetData(customDate: mondayDate);

      expect(weeklyData.weekTitle, contains('Week'));
      expect(weeklyData.days.length, equals(7));
      final mon = weeklyData.days.firstWhere((d) => d.dayName == 'MON');
      expect(mon.classes.length, equals(2));
      expect(mon.classes[0].subjectName, equals('Operating Systems'));
    });

    test('4. Monthly calendar event extraction generates indicators and upcoming items', () async {
      final task = AcademicTask(
        id: 1,
        title: 'OS Project Submission',
        taskType: TaskType.ASSIGNMENT,
        startDate: mondayDate,
        dueDate: DateTime(2026, 7, 22),
        priority: TaskPriority.HIGH,
        status: TaskStatus.PENDING,
        reminder: TaskReminder.HOURS_1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final event = AcademicEvent(
        id: 1,
        title: 'Mid Semester Exam',
        date: DateTime.utc(2026, 7, 25),
        type: AcademicEventType.EXAM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final service = WidgetDataService(
        ruleRepo: FakeWeeklyScheduleRuleRepository(rules),
        occurrenceRepo: FakeDailyScheduleOccurrenceRepository([]),
        exceptionRepo: FakeScheduleExceptionRepository([]),
        eventRepo: FakeAcademicEventRepository([event]),
        taskRepo: FakeTaskRepository([task]),
        semesterRepo: FakeSemesterRepository(activeSem),
        subjectRepo: FakeSubjectRepository(subjects),
        attendanceRepo: FakeAttendanceRepository([]),
      );

      final monthData = await service.generateMonthWidgetData(customDate: mondayDate);

      expect(monthData.monthTitle, contains('July 2026'));
      expect(monthData.days.length, equals(5));
      expect(monthData.upcomingItems.length, greaterThanOrEqualTo(2));
      expect(monthData.upcomingItems.any((i) => i.title == 'OS Project Submission'), isTrue);
      expect(monthData.upcomingItems.any((i) => i.title == 'Mid Semester Exam'), isTrue);
    });

    test('5. Model JSON serialization and deserialization roundtrip', () {
      const todayItem = TodayWidgetItem(
        subjectName: 'Computer Networks',
        startTime: '14:00',
        endTime: '15:00',
        room: 'Lab 3',
        status: 'UPCOMING',
      );

      const todayData = TodayWidgetData(
        dateText: 'Monday, 20 July',
        isHoliday: false,
        nextClass: todayItem,
        classes: [todayItem],
      );

      final jsonStr = todayData.toJson();
      final parsed = TodayWidgetData.fromJson(jsonStr);

      expect(parsed.dateText, equals('Monday, 20 July'));
      expect(parsed.isHoliday, isFalse);
      expect(parsed.classes.length, equals(1));
      expect(parsed.classes[0].subjectName, equals('Computer Networks'));
      expect(parsed.nextClass?.room, equals('Lab 3'));
    });
  });
}
