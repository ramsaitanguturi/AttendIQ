import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/background/background_worker.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/task_enums.dart';
import 'package:attend_iq/features/academic_planner/domain/repositories/task_repository.dart';
import 'package:attend_iq/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/domain/repositories/subject_repository.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/domain/entities/academic_event.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/repositories/academic_event_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/schedule_exception_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/weekly_schedule_rule_repository.dart';
import 'package:attend_iq/features/widgets/data/widget_data_service.dart';
import 'package:attend_iq/features/widgets/domain/widget_models.dart';
import 'package:attend_iq/features/widgets/presentation/widget_config.dart';
import 'package:attend_iq/features/widgets/services/widget_refresh_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

// Fake implementations for testing WidgetDataService
class FakeWeeklyScheduleRuleRepository implements WeeklyScheduleRuleRepository {
  final List<WeeklyScheduleRule> rules;
  FakeWeeklyScheduleRuleRepository(this.rules);
  @override
  Future<List<WeeklyScheduleRule>> getRulesForSemester(int semesterId) async =>
      rules;
  @override
  Future<List<WeeklyScheduleRule>> getRulesForSubject(int subjectId) async =>
      rules.where((r) => r.subjectId == subjectId).toList();
  @override
  Future<WeeklyScheduleRule?> getRuleById(int id) async =>
      rules.where((r) => r.id == id).firstOrNull;
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

class FakeDailyScheduleOccurrenceRepository
    implements DailyScheduleOccurrenceRepository {
  final List<DailyScheduleOccurrence> occurrences;
  FakeDailyScheduleOccurrenceRepository(this.occurrences);
  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDate(
    DateTime date,
  ) async {
    return occurrences
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
      occurrences;
  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForSubject(
    int subjectId,
  ) async =>
      occurrences.where((o) => o.subjectId == subjectId).toList();
  @override
  Future<DailyScheduleOccurrence?> getOccurrenceById(int id) async => null;
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
      occurrences;
  @override
  Stream<void> watchOccurrencesForDate(DateTime date) => const Stream.empty();
}

class FakeScheduleExceptionRepository implements ScheduleExceptionRepository {
  final List<ScheduleException> exceptions;
  FakeScheduleExceptionRepository(this.exceptions);
  @override
  Future<List<ScheduleException>> getExceptionsForDate(DateTime date) async {
    return exceptions
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
      exceptions;
  @override
  Future<List<ScheduleException>> getAllExceptions() async => exceptions;
  @override
  Future<ScheduleException?> getExceptionById(int id) async =>
      exceptions.where((e) => e.id == id).firstOrNull;
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
  Future<List<AcademicEvent>> getEventsForRange(
    DateTime startDate,
    DateTime endDate,
  ) async =>
      events;
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
  Future<List<Semester>> getAllSemesters() async =>
      activeSemester != null ? [activeSemester!] : [];
  @override
  Future<void> createSemester(Semester semester) async {}
  @override
  Future<void> updateSemester(Semester semester) async {}
  @override
  Future<void> setActiveSemester(int localId) async {}
  @override
  Future<void> archiveSemester(int localId) async {}
  @override
  Future<Semester?> getSemesterById(int localId) async => activeSemester;
}

class FakeSubjectRepository implements SubjectRepository {
  final List<Subject> subjects;
  FakeSubjectRepository(this.subjects);
  @override
  Future<List<Subject>> getSubjectsBySemester(
    int semesterId, {
    bool includeDeleted = false,
  }) async =>
      includeDeleted ? subjects : subjects.where((s) => !s.isDeleted).toList();
  @override
  Future<Subject?> getSubjectById(int id) async => subjects.firstOrNull;
  @override
  Future<Subject> createSubject(Subject subject) async => subject;
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
  Future<AttendanceRecord?> getAttendanceForOccurrence(
    int occurrenceId,
  ) async =>
      records
          .where((r) => !r.isDeleted && r.occurrenceId == occurrenceId)
          .firstOrNull;
  @override
  Future<AttendanceRecord?> getAttendanceForOccurrenceAnyStatus(
    int occurrenceId,
  ) async =>
      records.where((r) => r.occurrenceId == occurrenceId).firstOrNull;
  @override
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId) async => null;
  @override
  Future<AttendanceRecord?> getAttendanceForEventAnyStatus(int eventId) async =>
      null;
  @override
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {}
  @override
  Future<void> deleteAttendanceRecord(int id) async {}
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

Future<String?> _resolveIsarNativeLibraryPath() async {
  final packageConfigFile = File('.dart_tool/package_config.json').absolute;
  if (!packageConfigFile.existsSync()) return null;

  final decoded = jsonDecode(await packageConfigFile.readAsString());
  if (decoded is! Map<String, dynamic>) return null;
  final packages = decoded['packages'];
  if (packages is! List<dynamic>) return null;

  String? rawRootUri;
  for (final pkg in packages) {
    if (pkg is Map<String, dynamic> && pkg['name'] == 'isar_flutter_libs') {
      rawRootUri = pkg['rootUri'] as String?;
      break;
    }
  }
  if (rawRootUri == null) return null;

  final rootDir = Directory.fromUri(packageConfigFile.uri.resolve(rawRootUri));
  final String relativePath;
  if (Platform.isWindows) {
    relativePath = 'windows${Platform.pathSeparator}isar.dll';
  } else if (Platform.isLinux) {
    relativePath = 'linux${Platform.pathSeparator}libisar.so';
  } else if (Platform.isMacOS) {
    relativePath = 'macos${Platform.pathSeparator}libisar.dylib';
  } else {
    return null;
  }

  final file = File('${rootDir.path}${Platform.pathSeparator}$relativePath');
  return file.existsSync() ? file.path : null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Android Home Screen Widgets Unit Tests', () {
    final mondayDate = DateTime(2026, 7, 20); // Monday
    final activeSem = Semester(
      localId: 1,
      name: 'Fall 2026',
      startDate: DateTime.utc(2026, 7, 1),
      endDate: DateTime.utc(2026, 12, 1),
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
        type: SubjectType.theory,
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
        type: SubjectType.theory,
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

    test(
      '1. Today schedule extraction generates correct class list & next class',
      () async {
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

        final todayData =
            await service.generateTodayWidgetData(customDate: mondayDate);

        expect(todayData.isHoliday, isFalse);
        expect(todayData.classes.length, equals(2));
        expect(todayData.classes[0].subjectName, equals('Operating Systems'));
        expect(todayData.classes[0].startTime, equals('09:00'));
        expect(todayData.classes[1].subjectName, equals('Data Structures'));
        expect(todayData.nextClass, isNotNull);
        expect(todayData.nextClass?.subjectName, equals('Operating Systems'));
      },
    );

    test('2. Empty state handling for holiday returns holiday title', () async {
      final holidayException = ScheduleException(
        id: 1,
        date: DateTime.utc(2026, 7, 20),
        type: ScheduleExceptionType.holiday,
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

      final todayData =
          await service.generateTodayWidgetData(customDate: mondayDate);

      expect(todayData.isHoliday, isTrue);
      expect(todayData.holidayTitle, equals('Founder\'s Day'));
      expect(todayData.classes, isEmpty);
    });

    test(
      '3. Weekly schedule extraction generates week number, Sat/Sun, and cancelled occurrences',
      () async {
        final weekendRules = [
          ...rules,
          WeeklyScheduleRule(
            id: 3,
            subjectId: 101,
            dayOfWeek: 6, // Saturday
            startTime: '9:00',
            endTime: '10:30',
            room: 'Lab 2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          WeeklyScheduleRule(
            id: 4,
            subjectId: 102,
            dayOfWeek: 7, // Sunday
            startTime: '14:00',
            endTime: '15:00',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final cancelledMonOccurrence = DailyScheduleOccurrence(
          id: 50,
          ruleId: 1,
          date: DateTime.utc(2026, 7, 20),
          subjectId: 101,
          title: 'Operating Systems',
          startTime: '09:00',
          endTime: '10:00',
          type: OccurrenceType.regularClass,
          status: OccurrenceStatus.cancelled,
          createdFrom: OccurrenceCreatedFrom.weeklyRule,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final service = WidgetDataService(
          ruleRepo: FakeWeeklyScheduleRuleRepository(weekendRules),
          occurrenceRepo: FakeDailyScheduleOccurrenceRepository(
            [cancelledMonOccurrence],
          ),
          exceptionRepo: FakeScheduleExceptionRepository([]),
          eventRepo: FakeAcademicEventRepository([]),
          taskRepo: FakeTaskRepository([]),
          semesterRepo: FakeSemesterRepository(activeSem),
          subjectRepo: FakeSubjectRepository(subjects),
          attendanceRepo: FakeAttendanceRepository([]),
        );

        final weeklyData =
            await service.generateWeeklyWidgetData(customDate: mondayDate);

        expect(weeklyData.weekTitle, equals('Week 3'));
        expect(weeklyData.days.length, equals(7));

        final mon = weeklyData.days.firstWhere((d) => d.dayName == 'MON');
        expect(mon.classes.length, equals(2));
        expect(mon.classes[0].subjectName, equals('Operating Systems'));
        expect(mon.classes[0].isCancelled, isTrue);
        expect(mon.classes[1].isCancelled, isFalse);

        final sat = weeklyData.days.firstWhere((d) => d.dayName == 'SAT');
        expect(sat.classes.length, equals(1));
        expect(sat.classes[0].startTime, equals('09:00'));

        final sun = weeklyData.days.firstWhere((d) => d.dayName == 'SUN');
        expect(sun.classes.length, equals(1));
        expect(sun.classes[0].subjectName, equals('Data Structures'));
      },
    );

    test(
      '4. Monthly calendar excludes completed tasks and sorts upcoming items chronologically',
      () async {
        final completedTask = AcademicTask(
          id: 1,
          title: 'Completed Assignment',
          taskType: TaskType.assignment,
          startDate: mondayDate,
          dueDate: DateTime(2026, 7, 21),
          priority: TaskPriority.high,
          status: TaskStatus.completed,
          reminder: TaskReminder.hours1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final laterPendingTask = AcademicTask(
          id: 2,
          title: 'OS Project Submission',
          taskType: TaskType.assignment,
          startDate: mondayDate,
          dueDate: DateTime(2026, 7, 29),
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          reminder: TaskReminder.hours1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final soonerExam = AcademicEvent(
          id: 1,
          title: 'Mid Semester Exam',
          date: DateTime.utc(2026, 7, 23),
          type: AcademicEventType.exam,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final holidayException = ScheduleException(
          id: 2,
          date: DateTime.utc(2026, 7, 25),
          type: ScheduleExceptionType.holiday,
          title: 'College Foundation Day',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final service = WidgetDataService(
          ruleRepo: FakeWeeklyScheduleRuleRepository(rules),
          occurrenceRepo: FakeDailyScheduleOccurrenceRepository([]),
          exceptionRepo: FakeScheduleExceptionRepository([holidayException]),
          eventRepo: FakeAcademicEventRepository([soonerExam]),
          taskRepo: FakeTaskRepository([completedTask, laterPendingTask]),
          semesterRepo: FakeSemesterRepository(activeSem),
          subjectRepo: FakeSubjectRepository(subjects),
          attendanceRepo: FakeAttendanceRepository([]),
        );

        final monthData =
            await service.generateMonthWidgetData(customDate: mondayDate);

        expect(monthData.monthTitle, contains('July 2026'));
        expect(monthData.days.length, equals(5));
        // Tuesday (21 July) only had a completed task -> hasTasks must be false
        expect(monthData.days[1].hasTasks, isFalse);

        expect(monthData.upcomingItems.length, equals(3));
        expect(
          monthData.upcomingItems.any((i) => i.title == 'Completed Assignment'),
          isFalse,
        );
        expect(
          monthData.upcomingItems[0].title,
          equals('Mid Semester Exam'),
        );
        expect(
          monthData.upcomingItems[1].title,
          equals('College Foundation Day'),
        );
        expect(
          monthData.upcomingItems[2].title,
          equals('OS Project Submission'),
        );
      },
    );

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

    test(
      '6. Empty DB and deleted/missing subject rules return clean empty states',
      () async {
        final emptyService = WidgetDataService(
          ruleRepo: FakeWeeklyScheduleRuleRepository([
            WeeklyScheduleRule(
              id: 99,
              subjectId: 999, // missing subject
              dayOfWeek: 1,
              startTime: '09:00',
              endTime: '10:00',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ]),
          occurrenceRepo: FakeDailyScheduleOccurrenceRepository([]),
          exceptionRepo: FakeScheduleExceptionRepository([]),
          eventRepo: FakeAcademicEventRepository([]),
          taskRepo: FakeTaskRepository([]),
          semesterRepo: FakeSemesterRepository(null),
          subjectRepo: FakeSubjectRepository([]),
          attendanceRepo: FakeAttendanceRepository([]),
        );

        final today =
            await emptyService.generateTodayWidgetData(customDate: mondayDate);
        final weekly =
            await emptyService.generateWeeklyWidgetData(customDate: mondayDate);
        final month =
            await emptyService.generateMonthWidgetData(customDate: mondayDate);

        expect(today.classes, isEmpty);
        expect(today.nextClass, isNull);
        expect(weekly.weekTitle, equals('This Week'));
        expect(weekly.days.length, equals(7));
        expect(weekly.days.every((d) => d.classes.isEmpty), isTrue);
        expect(month.upcomingItems, isEmpty);
      },
    );

    test(
      '7. Today widget sorts single-digit times before afternoon and skips missing subjects',
      () async {
        final mixedRules = [
          WeeklyScheduleRule(
            id: 1,
            subjectId: 102,
            dayOfWeek: 1,
            startTime: '14:00',
            endTime: '15:00',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          WeeklyScheduleRule(
            id: 2,
            subjectId: 101,
            dayOfWeek: 1,
            startTime: '9:00',
            endTime: '10:00',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          WeeklyScheduleRule(
            id: 3,
            subjectId: 999, // missing subject -> skipped
            dayOfWeek: 1,
            startTime: '08:00',
            endTime: '09:00',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final service = WidgetDataService(
          ruleRepo: FakeWeeklyScheduleRuleRepository(mixedRules),
          occurrenceRepo: FakeDailyScheduleOccurrenceRepository([]),
          exceptionRepo: FakeScheduleExceptionRepository([]),
          eventRepo: FakeAcademicEventRepository([]),
          taskRepo: FakeTaskRepository([]),
          semesterRepo: FakeSemesterRepository(activeSem),
          subjectRepo: FakeSubjectRepository(subjects),
          attendanceRepo: FakeAttendanceRepository([]),
        );

        final today =
            await service.generateTodayWidgetData(customDate: mondayDate);
        expect(today.classes.length, equals(2));
        expect(today.classes[0].subjectName, equals('Operating Systems'));
        expect(today.classes[0].startTime, equals('09:00'));
        expect(today.classes[1].subjectName, equals('Data Structures'));
      },
    );

    test(
      '8. updateAllWidgets saves JSON and passes qualifiedAndroidName for prod & beta compatibility',
      () async {
        const channel = MethodChannel('home_widget');
        final saved = <String, dynamic>{};
        final updatedProviders = <String>[];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getWidgetData') {
            return saved[call.arguments['id']];
          }
          if (call.method == 'saveWidgetData') {
            saved[call.arguments['id'] as String] = call.arguments['data'];
            return true;
          }
          if (call.method == 'updateWidget') {
            final args = call.arguments as Map<dynamic, dynamic>;
            updatedProviders.add(args['qualifiedAndroidName'] as String);
            return true;
          }
          return null;
        });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
        });

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

        await service.updateAllWidgets(customDate: mondayDate);

        expect(saved.containsKey('today_widget_data'), isTrue);
        expect(saved.containsKey('weekly_widget_data'), isTrue);
        expect(saved.containsKey('month_widget_data'), isTrue);
        expect(
          updatedProviders,
          equals([
            'com.ramsa.attendiq.attend_iq.TodayWidgetProvider',
            'com.ramsa.attendiq.attend_iq.WeeklyWidgetProvider',
            'com.ramsa.attendiq.attend_iq.MonthWidgetProvider',
          ]),
        );

        // When widgets are disabled in settings, live data is not overwritten
        saved['widget_settings_config'] =
            const WidgetSettingsModel(enabled: false).toJson();
        saved.remove('today_widget_data');
        updatedProviders.clear();

        await service.updateAllWidgets(customDate: mondayDate);
        expect(saved.containsKey('today_widget_data'), isFalse);
        expect(updatedProviders.length, equals(3));
      },
    );

    test(
      '9. WidgetConfigNotifier syncs background schedule on enable/disable/frequency change',
      () async {
        const channel = MethodChannel('home_widget');
        final saved = <String, dynamic>{};
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'saveWidgetData') {
            saved[call.arguments['id'] as String] = call.arguments['data'];
            return true;
          }
          if (call.method == 'updateWidget') {
            return true;
          }
          return null;
        });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
        });

        final dataService = WidgetDataService(
          ruleRepo: FakeWeeklyScheduleRuleRepository(rules),
          occurrenceRepo: FakeDailyScheduleOccurrenceRepository([]),
          exceptionRepo: FakeScheduleExceptionRepository([]),
          eventRepo: FakeAcademicEventRepository([]),
          taskRepo: FakeTaskRepository([]),
          semesterRepo: FakeSemesterRepository(activeSem),
          subjectRepo: FakeSubjectRepository(subjects),
          attendanceRepo: FakeAttendanceRepository([]),
        );
        final synced = <WidgetSettingsModel>[];
        final notifier = WidgetConfigNotifier(
          WidgetRefreshService(dataService),
          autoLoad: false,
          syncSchedule: (settings) async => synced.add(settings),
        );

        await notifier.setRefreshFrequency('1h');
        await notifier.setRefreshFrequency('6h');
        await notifier.setEnabled(false);

        expect(synced.length, equals(3));
        expect(synced[0].refreshFrequency, equals('1h'));
        expect(synced[1].refreshFrequency, equals('6h'));
        expect(synced[2].enabled, isFalse);

        expect(
          WidgetBackgroundScheduler.frequencyForSetting('1h'),
          equals(const Duration(hours: 1)),
        );
        expect(
          WidgetBackgroundScheduler.frequencyForSetting('6h'),
          equals(const Duration(hours: 6)),
        );
        expect(
          WidgetBackgroundScheduler.frequencyForSetting('auto'),
          equals(const Duration(hours: 12)),
        );
      },
    );

    test(
      '10. Real Isar WidgetDataService.fromIsar reflects attendance marking and extra classes',
      () async {
        final libPath = await _resolveIsarNativeLibraryPath();
        if (libPath == null) return;

        await Isar.initialize(libPath);
        final tempDir = await Directory.systemTemp.createTemp(
          'attendiq_widget_isar_test_',
        );
        Isar? isar;
        try {
          isar = Isar.open(
            schemas: appIsarSchemas,
            name: 'widget_test_${DateTime.now().microsecondsSinceEpoch}',
            directory: tempDir.path,
            inspector: false,
          );

          final now = DateTime.now();
          final todayUtc = DateTime.utc(now.year, now.month, now.day);

          final subjectId = await isar.writeAsync<int>((db) {
            final sem = SemesterLocal()
              ..id = db.semesterLocals.autoIncrement()
              ..serverId = 'sem-1'
              ..name = 'Fall 2026'
              ..startDate = todayUtc.subtract(const Duration(days: 7))
              ..endDate = todayUtc.add(const Duration(days: 90))
              ..requiredAttendanceRate = 75.0
              ..isActive = true
              ..status = 'active'
              ..createdAt = now.toUtc()
              ..updatedAt = now.toUtc();
            db.semesterLocals.put(sem);

            final sub = SubjectLocal()
              ..id = db.subjectLocals.autoIncrement()
              ..serverId = 'sub-1'
              ..semesterId = sem.id
              ..name = 'Distributed Systems'
              ..code = 'CS401'
              ..credits = 4
              ..attendanceTarget = 75.0
              ..color = '#6C5CE7'
              ..type = 'THEORY'
              ..createdAt = now.toUtc()
              ..updatedAt = now.toUtc();
            db.subjectLocals.put(sub);

            final rule = WeeklyScheduleRuleLocal()
              ..id = db.weeklyScheduleRuleLocals.autoIncrement()
              ..serverId = 'rule-1'
              ..subjectId = sub.id
              ..dayOfWeek = now.weekday
              ..startTime = '09:00'
              ..endTime = '10:00'
              ..room = 'A-204'
              ..isActive = true
              ..createdAt = now.toUtc()
              ..updatedAt = now.toUtc();
            db.weeklyScheduleRuleLocals.put(rule);
            return sub.id;
          });

          final service = WidgetDataService.fromIsar(isar);
          var today = await service.generateTodayWidgetData(customDate: now);
          expect(today.classes.length, equals(1));
          expect(today.classes[0].subjectName, equals('Distributed Systems'));
          expect(today.classes[0].status, equals('UPCOMING'));

          // Mark an extra class present via real AttendanceLocalDataSourceImpl
          final attendanceDs = AttendanceLocalDataSourceImpl(isar);
          await attendanceDs.saveExtraClassWithAttendance(
            subjectId: subjectId,
            date: todayUtc,
            startTime: '15:00',
            endTime: '16:00',
            attendanceStatus: 'EXTRA_PRESENT',
          );

          today = await service.generateTodayWidgetData(customDate: now);
          expect(today.classes.length, equals(2));
          expect(today.classes[1].status, equals('PRESENT'));
          expect(today.nextClass?.startTime, equals('09:00'));
        } finally {
          if (isar != null && isar.isOpen) {
            isar.close(deleteFromDisk: true);
          }
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        }
      },
    );

    test(
      '11. WidgetSyncCoordinator coalesces bursts and serializes concurrent refreshes',
      () async {
        var calls = 0;
        var inFlight = 0;
        var maxConcurrent = 0;

        final coordinator = WidgetSyncCoordinator(
          debounceDuration: const Duration(milliseconds: 30),
          onRefresh: () async {
            calls++;
            inFlight++;
            if (inFlight > maxConcurrent) {
              maxConcurrent = inFlight;
            }
            await Future<void>.delayed(const Duration(milliseconds: 40));
            inFlight--;
          },
        );

        // Rapid burst should coalesce into 1 debounced run.
        coordinator.scheduleRefresh();
        coordinator.scheduleRefresh();
        coordinator.scheduleRefresh();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(calls, equals(1));
        expect(maxConcurrent, equals(1));

        // Overlapping immediate refreshes serialize cleanly (at most one queued follow-up).
        final f1 = coordinator.refreshNow();
        final f2 = coordinator.refreshNow();
        final f3 = coordinator.refreshNow();
        await Future.wait([f1, f2, f3]);

        expect(calls, equals(3));
        expect(maxConcurrent, equals(1));

        coordinator.dispose();
        coordinator.scheduleRefresh();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        expect(calls, equals(3));
      },
    );

    test(
      '12. WidgetSyncCoordinator watches real Isar mutations and stops after dispose',
      () async {
        final isarLibPath = await _resolveIsarNativeLibraryPath();
        if (isarLibPath == null) {
          markTestSkipped(
            'Native Isar library not found for this host platform',
          );
          return;
        }
        await Isar.initialize(isarLibPath);

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_watch_test_');
        Isar? isar;
        var refreshCount = 0;
        final coordinator = WidgetSyncCoordinator(
          debounceDuration: const Duration(milliseconds: 25),
          onRefresh: () async {
            refreshCount++;
          },
        );

        try {
          isar = Isar.open(
            schemas: appIsarSchemas,
            name: 'widget_watch_test_${DateTime.now().microsecondsSinceEpoch}',
            directory: tempDir.path,
            inspector: false,
          );
          coordinator.watchIsar(isar);
          expect(coordinator.isWatching, isTrue);

          final now = DateTime.now().toUtc();
          await isar.writeAsync<void>((db) {
            final sub = SubjectLocal()
              ..id = db.subjectLocals.autoIncrement()
              ..serverId = 'sub-w1'
              ..semesterId = 1
              ..name = 'Compilers'
              ..code = 'CS402'
              ..credits = 3
              ..attendanceTarget = 75.0
              ..color = '#00B894'
              ..type = 'THEORY'
              ..createdAt = now
              ..updatedAt = now;
            db.subjectLocals.put(sub);

            final rule = WeeklyScheduleRuleLocal()
              ..id = db.weeklyScheduleRuleLocals.autoIncrement()
              ..serverId = 'rule-w1'
              ..subjectId = sub.id
              ..dayOfWeek = 1
              ..startTime = '10:00'
              ..endTime = '11:00'
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now;
            db.weeklyScheduleRuleLocals.put(rule);
          });

          await Future<void>.delayed(const Duration(milliseconds: 120));
          expect(refreshCount, equals(1));

          await isar.writeAsync<void>((db) {
            final rec = AttendanceRecordLocal()
              ..id = db.attendanceRecordLocals.autoIncrement()
              ..serverId = 'att-w1'
              ..eventId = 1
              ..subjectId = 1
              ..status = 'PRESENT'
              ..markedAt = now
              ..createdAt = now
              ..updatedAt = now;
            db.attendanceRecordLocals.put(rec);
          });

          await Future<void>.delayed(const Duration(milliseconds: 120));
          expect(refreshCount, equals(2));

          coordinator.dispose();
          expect(coordinator.isWatching, isFalse);

          await isar.writeAsync<void>((db) {
            final rec2 = AttendanceRecordLocal()
              ..id = db.attendanceRecordLocals.autoIncrement()
              ..serverId = 'att-w2'
              ..eventId = 2
              ..subjectId = 1
              ..status = 'ABSENT'
              ..markedAt = now
              ..createdAt = now
              ..updatedAt = now;
            db.attendanceRecordLocals.put(rec2);
          });

          await Future<void>.delayed(const Duration(milliseconds: 120));
          expect(refreshCount, equals(2));
        } finally {
          coordinator.dispose();
          if (isar != null && isar.isOpen) {
            isar.close(deleteFromDisk: true);
          }
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        }
      },
    );
  });
}
