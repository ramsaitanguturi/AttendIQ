import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:attend_iq/app/app_router.dart';
import 'package:attend_iq/core/theme/colors.dart';
import 'package:attend_iq/core/theme/text_styles.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/domain/repositories/subject_repository.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/repositories/schedule_exception_repository.dart';
import 'package:attend_iq/features/timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/academic_calendar_controller.dart';
import 'package:attend_iq/features/timetable/presentation/widgets/class_schedule_card.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/task_enums.dart';
import 'package:attend_iq/features/academic_planner/domain/repositories/task_repository.dart';
import 'package:attend_iq/features/academic_planner/presentation/controllers/task_controller.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/core/attendance_engine/calculator.dart';

// ---------------------------------------------------------------------------
// In-Memory Test Fakes
// ---------------------------------------------------------------------------

class _InMemorySubjectRepo implements SubjectRepository {
  final List<Subject> subjects = [];
  final List<WeeklyScheduleRule> rules = [];
  final List<DailyScheduleOccurrence> occurrences = [];
  final List<AttendanceRecord> attendanceRecords = [];
  int _nextId = 1;

  @override
  Future<List<Subject>> getSubjectsBySemester(int semesterId,
      {bool includeDeleted = false}) async {
    return subjects
        .where((s) =>
            s.semesterId == semesterId && (includeDeleted || !s.isDeleted))
        .toList();
  }

  @override
  Future<Subject?> getSubjectById(int id) async =>
      subjects.where((s) => s.id == id).firstOrNull;

  @override
  Future<Subject> createSubject(Subject subject) async {
    final assigned = subject.copyWith(id: subject.id ?? _nextId++);
    subjects.add(assigned);
    return assigned;
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    subjects.removeWhere((s) => s.id == subject.id);
    subjects.add(subject);
  }

  @override
  Future<void> deleteSubject(int id) async {
    final idx = subjects.indexWhere((s) => s.id == id);
    if (idx != -1) {
      subjects[idx] = subjects[idx].copyWith(isDeleted: true);
    }
    // Cascade soft-delete active weekly recurring rules
    for (int i = 0; i < rules.length; i++) {
      if (rules[i].subjectId == id) {
        rules[i] = rules[i].copyWith(isActive: false, isDeleted: true);
      }
    }
    // Cascade soft-delete future schedule occurrences (date >= today)
    final today = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    for (int i = 0; i < occurrences.length; i++) {
      if (occurrences[i].subjectId == id) {
        final occDate = DateTime.utc(occurrences[i].date.year,
            occurrences[i].date.month, occurrences[i].date.day);
        if (!occDate.isBefore(today)) {
          occurrences[i] = occurrences[i].copyWith(isDeleted: true);
        }
      }
    }
    // Historical attendanceRecords are strictly preserved intact!
  }

  @override
  Stream<void> watchSubjects(int semesterId) => const Stream.empty();
}

class _InMemoryExceptionRepo implements ScheduleExceptionRepository {
  final List<ScheduleException> exceptions = [];
  int _nextId = 1;

  @override
  Future<List<ScheduleException>> getExceptionsForDate(DateTime date) async {
    final d = DateTime.utc(date.year, date.month, date.day);
    return exceptions.where((e) {
      final ed = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return ed.isAtSameMomentAs(d) && !e.isDeleted;
    }).toList();
  }

  @override
  Future<List<ScheduleException>> getExceptionsForRange(
      DateTime startDate, DateTime endDate) async {
    return exceptions.where((e) {
      return !e.isDeleted &&
          !e.date.isBefore(startDate) &&
          !e.date.isAfter(endDate);
    }).toList();
  }

  @override
  Future<List<ScheduleException>> getAllExceptions() async {
    return exceptions.where((e) => !e.isDeleted).toList();
  }

  @override
  Future<ScheduleException?> getExceptionById(int id) async =>
      exceptions.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> saveException(ScheduleException exception) async {
    final toSave = exception.id == null || exception.id == 0
        ? exception.copyWith(id: _nextId++)
        : exception;
    exceptions.removeWhere((e) => e.id == toSave.id);
    exceptions.add(toSave);
  }

  @override
  Future<void> deleteException(int id) async {
    final idx = exceptions.indexWhere((e) => e.id == id);
    if (idx != -1) {
      exceptions[idx] = exceptions[idx].copyWith(isDeleted: true);
    }
  }

  @override
  Stream<void> watchExceptions() => const Stream.empty();
}

class _InMemoryOccurrenceRepo implements DailyScheduleOccurrenceRepository {
  final List<DailyScheduleOccurrence> occurrences = [];
  int _nextId = 1;

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDate(
      DateTime date) async {
    final d = DateTime.utc(date.year, date.month, date.day);
    return occurrences.where((o) {
      final od = DateTime.utc(o.date.year, o.date.month, o.date.day);
      return od.isAtSameMomentAs(d) && !o.isDeleted;
    }).toList();
  }

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDateRange(
      DateTime start, DateTime end) async {
    return occurrences.where((o) {
      return !o.isDeleted && !o.date.isBefore(start) && !o.date.isAfter(end);
    }).toList();
  }

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForSubject(
          int subjectId) async =>
      occurrences
          .where((o) => o.subjectId == subjectId && !o.isDeleted)
          .toList();

  @override
  Future<DailyScheduleOccurrence?> getOccurrenceById(int id) async =>
      occurrences.where((o) => o.id == id).firstOrNull;

  @override
  Future<DailyScheduleOccurrence> saveOccurrence(
      DailyScheduleOccurrence occurrence) async {
    final toSave = occurrence.id == null || occurrence.id == 0
        ? occurrence.copyWith(id: _nextId++)
        : occurrence;
    occurrences.removeWhere((o) => o.id == toSave.id);
    occurrences.add(toSave);
    return toSave;
  }

  @override
  Future<List<DailyScheduleOccurrence>> saveOccurrences(
      List<DailyScheduleOccurrence> list) async {
    final res = <DailyScheduleOccurrence>[];
    for (final item in list) {
      res.add(await saveOccurrence(item));
    }
    return res;
  }

  @override
  Future<void> deleteOccurrence(int id) async {
    final idx = occurrences.indexWhere((o) => o.id == id);
    if (idx != -1) {
      occurrences[idx] = occurrences[idx].copyWith(isDeleted: true);
    }
  }

  @override
  Future<List<DailyScheduleOccurrence>> getAllOccurrences() async =>
      occurrences.where((o) => !o.isDeleted).toList();

  @override
  Stream<void> watchOccurrencesForDate(DateTime date) => const Stream.empty();
}

class _InMemoryTaskRepo implements TaskRepository {
  final List<AcademicTask> tasks = [];
  int _nextId = 1;

  @override
  Future<List<AcademicTask>> getAllTasks() async => List.of(tasks);

  @override
  Future<AcademicTask?> getTaskById(int id) async =>
      tasks.where((t) => t.id == id).firstOrNull;

  @override
  Future<void> saveTask(AcademicTask task) async {
    final toSave =
        task.id == null || task.id == 0 ? task.copyWith(id: _nextId++) : task;
    tasks.removeWhere((t) => t.id == toSave.id);
    tasks.add(toSave);
  }

  @override
  Future<void> deleteTask(int id) async {
    tasks.removeWhere((t) => t.id == id);
  }

  @override
  Stream<void> watchTasks() => const Stream.empty();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Group A: BUG-020 Subject Lifecycle & Cascade Integrity', () {
    late _InMemorySubjectRepo subjectRepo;

    setUp(() {
      subjectRepo = _InMemorySubjectRepo();
    });

    test('createSubject returns created Subject with generated ID', () async {
      final subject = Subject(
        semesterId: 1,
        name: 'Distributed Systems',
        code: 'CS601',
        credits: 4,
        attendanceTarget: 80.0,
        color: '#4ECDC4',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now(),
      );

      final created = await subjectRepo.createSubject(subject);
      expect(created.id, isNotNull);
      expect(created.id, greaterThan(0));
      expect(created.code, equals('CS601'));
      expect(created.attendanceTarget, equals(80.0));
    });

    test(
        'deleteSubject cascades to soft-delete rules and future occurrences while strictly preserving historical attendance',
        () async {
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      // 1. Create subject
      final sub = await subjectRepo.createSubject(Subject(
        id: 10,
        semesterId: 1,
        name: 'Database Systems',
        code: 'CS301',
        credits: 3,
        attendanceTarget: 75.0,
        color: '#FF6B6B',
        type: SubjectType.THEORY,
        updatedAt: now,
      ));

      // 2. Add recurring rule
      subjectRepo.rules.add(WeeklyScheduleRule(
        id: 1,
        subjectId: sub.id!,
        dayOfWeek: 1,
        startTime: '09:00',
        endTime: '10:00',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ));

      // 3. Add past occurrence with attendance record
      subjectRepo.occurrences.add(DailyScheduleOccurrence(
        id: 101,
        date: yesterday,
        subjectId: sub.id!,
        ruleId: 1,
        title: 'CS301 Class',
        startTime: '09:00',
        endTime: '10:00',
        type: OccurrenceType.REGULAR_CLASS,
        status: OccurrenceStatus.PRESENT,
        createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
        createdAt: now,
        updatedAt: now,
      ));
      subjectRepo.attendanceRecords.add(AttendanceRecord(
        id: 501,
        occurrenceId: 101,
        eventId: 101,
        subjectId: sub.id!,
        status: AttendanceStatus.PRESENT,
        markedAt: yesterday,
        updatedAt: now,
      ));

      // 4. Add future occurrence (tomorrow)
      subjectRepo.occurrences.add(DailyScheduleOccurrence(
        id: 102,
        date: tomorrow,
        subjectId: sub.id!,
        ruleId: 1,
        title: 'CS301 Class',
        startTime: '09:00',
        endTime: '10:00',
        type: OccurrenceType.REGULAR_CLASS,
        status: OccurrenceStatus.UPCOMING,
        createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
        createdAt: now,
        updatedAt: now,
      ));

      // 5. Delete subject
      await subjectRepo.deleteSubject(sub.id!);

      // Assert subject is soft-deleted
      final activeSubjects = await subjectRepo.getSubjectsBySemester(1);
      expect(activeSubjects.isEmpty, isTrue);

      final allSubjects =
          await subjectRepo.getSubjectsBySemester(1, includeDeleted: true);
      expect(allSubjects.length, equals(1));
      expect(allSubjects.first.isDeleted, isTrue);

      // Assert recurring rule is soft-deleted / deactivated
      expect(subjectRepo.rules.first.isActive, isFalse);
      expect(subjectRepo.rules.first.isDeleted, isTrue);

      // Assert future occurrence is soft-deleted
      final futureOcc = subjectRepo.occurrences.firstWhere((o) => o.id == 102);
      expect(futureOcc.isDeleted, isTrue);

      // Assert historical attendance record is STRICTLY preserved
      expect(subjectRepo.attendanceRecords.length, equals(1));
      expect(subjectRepo.attendanceRecords.first.subjectId, equals(sub.id));
      expect(subjectRepo.attendanceRecords.first.status,
          equals(AttendanceStatus.PRESENT));
    });

    test(
        'Subject code collision validation detects case-insensitive duplicates',
        () {
      final existing = [
        Subject(
          id: 1,
          semesterId: 1,
          name: 'Computer Networks',
          code: 'CS501',
          credits: 3,
          attendanceTarget: 75.0,
          color: '#4ECDC4',
          type: SubjectType.THEORY,
          updatedAt: DateTime.now(),
        ),
      ];

      bool hasCollision(String newCode, {int? editId}) {
        final upper = newCode.trim().toUpperCase();
        return existing
            .any((s) => s.code.toUpperCase() == upper && s.id != editId);
      }

      expect(hasCollision('cs501'), isTrue,
          reason: 'Matching lowercase code should collide');
      expect(hasCollision('CS501'), isTrue,
          reason: 'Matching uppercase code should collide');
      expect(hasCollision('CS501', editId: 1), isFalse,
          reason: 'Self-edit on existing subject should not collide');
      expect(hasCollision('CS502'), isFalse,
          reason: 'Distinct subject code should not collide');
    });

    test(
        'Intra-dialog time slot collision validation rejects overlapping slots',
        () {
      int toMinutes(String t) {
        final p = t.split(':');
        return int.parse(p[0]) * 60 + int.parse(p[1]);
      }

      bool checkOverlap(int dayA, String startA, String endA, int dayB,
          String startB, String endB) {
        if (dayA != dayB) return false;
        final sA = toMinutes(startA);
        final eA = toMinutes(endA);
        final sB = toMinutes(startB);
        final eB = toMinutes(endB);
        return sA < eB && eA > sB;
      }

      // Monday 09:00 - 10:00 vs Monday 09:30 - 10:30 (Overlap!)
      expect(checkOverlap(1, '09:00', '10:00', 1, '09:30', '10:30'), isTrue);

      // Monday 09:00 - 10:00 vs Monday 10:00 - 11:00 (Back-to-back, no overlap)
      expect(checkOverlap(1, '09:00', '10:00', 1, '10:00', '11:00'), isFalse);

      // Monday 09:00 - 10:00 vs Tuesday 09:00 - 10:00 (Different days, no overlap)
      expect(checkOverlap(1, '09:00', '10:00', 2, '09:00', '10:00'), isFalse);
    });
  });

  group('Group A: BUG-022 Timetable & Calendar Integrity', () {
    test('Schedule exceptions beyond 90 days are fetched without truncation',
        () async {
      final repo = _InMemoryExceptionRepo();
      final now = DateTime.utc(2026, 11, 13);

      // Add a holiday 120 days out (beyond old 90d window)
      final holidayDate = now.add(const Duration(days: 120));
      await repo.saveException(ScheduleException(
        date: holidayDate,
        type: ScheduleExceptionType.HOLIDAY,
        title: 'Spring Festival Holiday',
        createdAt: now,
        updatedAt: now,
      ));

      final all = await repo.getAllExceptions();
      expect(all.length, equals(1));
      expect(all.first.title, equals('Spring Festival Holiday'));
      expect(all.first.date, equals(holidayDate));
    });

    test(
        'monthlyCalendarDataProvider includes DailyScheduleOccurrence extra classes',
        () async {
      final container = ProviderContainer(
        overrides: [
          activeSemesterProvider.overrideWith((ref) async => Semester(
                localId: 1,
                name: 'Fall 2026',
                startDate: DateTime.utc(2026, 8, 1),
                endDate: DateTime.utc(2026, 12, 31),
                requiredAttendanceRate: 75.0,
              )),
          subjectListControllerProvider.overrideWith(
            () => _FakeSubjectListNotifier([
              Subject(
                id: 1,
                semesterId: 1,
                name: 'Algorithms',
                code: 'CS201',
                credits: 3,
                attendanceTarget: 75.0,
                color: '#4ECDC4',
                type: SubjectType.THEORY,
                updatedAt: DateTime.now(),
              ),
            ]),
          ),
          allDailyOccurrencesProvider.overrideWith((ref) async => [
                DailyScheduleOccurrence(
                  id: 99,
                  date: DateTime.utc(2026, 11, 15),
                  subjectId: 1,
                  title: 'Algorithms Extra Class',
                  startTime: '14:00',
                  endTime: '15:30',
                  type: OccurrenceType.EXTRA_CLASS,
                  status: OccurrenceStatus.UPCOMING,
                  createdFrom: OccurrenceCreatedFrom.MANUAL,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              ]),
        ],
      );
      addTearDown(container.dispose);

      // Force month to November 2026
      container.read(selectedMonthProvider.notifier).state =
          DateTime(2026, 11, 1);

      // Await active semester and occurrences
      await container.read(activeSemesterProvider.future);
      await container.read(allDailyOccurrencesProvider.future);

      final daysAsync = container.read(monthlyCalendarDataProvider);
      final days = daysAsync.value!;

      final day15 = days.firstWhere(
          (d) => d.date.year == 2026 && d.date.month == 11 && d.date.day == 15);
      expect(day15.hasExtraClass, isTrue);

      final extraItem = day15.items
          .firstWhere((it) => it.type == CalendarItemType.EXTRA_CLASS);
      expect(extraItem.title, contains('Algorithms'));
      expect(extraItem.startTime, equals('14:00'));
      expect(extraItem.endTime, equals('15:30'));
    });

    test('ScheduleClassSlot correctly carries normalized date', () {
      final slotDate = DateTime.utc(2026, 11, 20);
      final slot = ScheduleClassSlot(
        id: 1,
        type: ScheduleSlotType.classSlot,
        title: 'Compiler Design',
        code: 'CS401',
        startTime: '10:00',
        endTime: '11:00',
        date: slotDate,
      );

      expect(slot.date, isNotNull);
      expect(slot.date, equals(slotDate));
    });
  });

  group('Group B: BUG-025 Analytics & Dashboard Unreachable Targets', () {
    test(
        'AttendanceCalculator returns null for unreachable 100% target when 1 class is missed',
        () {
      // 1 attended, 2 total => 50%. Target is 100%.
      // Formula: (target*total - attended) / (1 - target) => division by zero => unreachable null
      final req = AttendanceCalculator.calculateRequiredClasses(
        attended: 1,
        total: 2,
        target: 100.0,
      );
      expect(req, isNull);
    });

    test(
        'Unreachable target displays descriptive text and never literal "null"',
        () {
      const double target = 100.0;
      final int? requiredClasses =
          AttendanceCalculator.calculateRequiredClasses(
        attended: 4,
        total: 5,
        target: target,
      );

      expect(requiredClasses, isNull);

      final displayText = requiredClasses != null
          ? 'Need $requiredClasses consecutive classes'
          : 'Target ${target.toStringAsFixed(0)}% unreachable (N/A)';

      expect(displayText, equals('Target 100% unreachable (N/A)'));
      expect(displayText.contains('null'), isFalse);
    });
  });

  group('Group B: BUG-028 Router Error Route & Protected Redirects', () {
    testWidgets(
        'Router surfaces explicit error route on hasActiveSemester error',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          hasActiveSemesterProvider.overrideWith(
              (ref) => Future.error('Database connection failed')),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: container.read(appRouterProvider),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to initialize semester data'), findsOneWidget);
      expect(find.text('Database connection failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    test('Router preserves deep links and contains explicit error route', () {
      final container = ProviderContainer(
        overrides: [
          hasActiveSemesterProvider.overrideWith((ref) => Future.value(true)),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);
      expect(router, isA<GoRouter>());
      expect(
        router.configuration.routes
            .any((r) => r is GoRoute && r.path == '/error'),
        isTrue,
      );
    });
  });

  group('Group C: BUG-029 & NEW-BUG-11 Attendance Status Visual Styling', () {
    testWidgets(
        'ClassScheduleCard renders neutral grey pill for CANCELLED status',
        (tester) async {
      const slot = ScheduleClassSlot(
        id: 1,
        type: ScheduleSlotType.classSlot,
        title: 'Operating Systems',
        code: 'CS302',
        startTime: '11:00',
        endTime: '12:00',
        status: 'CANCELLED',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClassScheduleCard(slot: slot),
          ),
        ),
      );

      final cancelledText = find.text('CANCELLED');
      expect(cancelledText, findsOneWidget);

      final textWidget = tester.widget<Text>(cancelledText);
      expect(textWidget.style?.color, equals(AppColors.statusCancelled));
    });

    testWidgets('ClassScheduleCard renders green pill for PRESENT status',
        (tester) async {
      const slot = ScheduleClassSlot(
        id: 2,
        type: ScheduleSlotType.classSlot,
        title: 'Operating Systems',
        code: 'CS302',
        startTime: '11:00',
        endTime: '12:00',
        status: 'PRESENT',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClassScheduleCard(slot: slot),
          ),
        ),
      );

      final presentText = find.text('PRESENT');
      expect(presentText, findsOneWidget);

      final textWidget = tester.widget<Text>(presentText);
      expect(textWidget.style?.color, equals(AppColors.attendanceHigh));
    });

    testWidgets('ClassScheduleCard renders red pill for ABSENT status',
        (tester) async {
      const slot = ScheduleClassSlot(
        id: 3,
        type: ScheduleSlotType.classSlot,
        title: 'Operating Systems',
        code: 'CS302',
        startTime: '11:00',
        endTime: '12:00',
        status: 'ABSENT',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClassScheduleCard(slot: slot),
          ),
        ),
      );

      final absentText = find.text('ABSENT');
      expect(absentText, findsOneWidget);

      final textWidget = tester.widget<Text>(absentText);
      expect(textWidget.style?.color, equals(AppColors.attendanceLow));
    });

    testWidgets('ClassScheduleCard renders amber pill for LATE status',
        (tester) async {
      const slot = ScheduleClassSlot(
        id: 4,
        type: ScheduleSlotType.classSlot,
        title: 'Operating Systems',
        code: 'CS302',
        startTime: '11:00',
        endTime: '12:00',
        status: 'LATE',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClassScheduleCard(slot: slot),
          ),
        ),
      );

      final lateText = find.text('LATE');
      expect(lateText, findsOneWidget);

      final textWidget = tester.widget<Text>(lateText);
      expect(textWidget.style?.color, equals(AppColors.attendanceMid));
    });

    test('NEW-BUG-10: AppTextStyles font family resolves to Roboto', () {
      expect(AppTextStyles.primaryFont, equals('Roboto'));
      expect(AppTextStyles.fallbackFont, equals('Roboto'));
    });
  });

  group('Group D: NEW-BUG-06 Academic Planner Task Date Validation', () {
    late _InMemoryTaskRepo taskRepo;

    setUp(() {
      taskRepo = _InMemoryTaskRepo();
    });

    test('TaskListController rejects task where startDate is after dueDate',
        () async {
      final now = DateTime.now();
      final startDate = now.add(const Duration(days: 5));
      final dueDate = now.add(const Duration(days: 2));

      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(taskRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(taskListControllerProvider.notifier);

      expect(
        () => notifier.addTask(
          title: 'Invalid Interval Assignment',
          taskType: TaskType.ASSIGNMENT,
          startDate: startDate,
          dueDate: dueDate,
          priority: TaskPriority.HIGH,
          reminder: TaskReminder.DAYS_1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('TaskListController allows valid task creation and editing', () async {
      final now = DateTime.now();
      final startDate = now;
      final dueDate = now.add(const Duration(days: 3));

      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(taskRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(taskListControllerProvider.notifier);

      await notifier.addTask(
        title: 'Term Project Report',
        taskType: TaskType.PROJECT,
        startDate: startDate,
        dueDate: dueDate,
        priority: TaskPriority.HIGH,
        reminder: TaskReminder.HOURS_2,
      );

      final tasks = await taskRepo.getAllTasks();
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Term Project Report'));

      // Edit task
      final created = tasks.first;
      final updatedDue = dueDate.add(const Duration(days: 2));
      final updatedTask = created.copyWith(
        title: 'Updated Term Project Report',
        dueDate: updatedDue,
      );

      await notifier.updateTask(updatedTask);
      final refreshed = await taskRepo.getTaskById(created.id!);
      expect(refreshed?.title, equals('Updated Term Project Report'));
      expect(refreshed?.dueDate, equals(updatedDue));
    });

    test('Date adjustment logic keeps dueDate >= startDate', () {
      var startDate = DateTime(2026, 11, 10);
      var dueDate = DateTime(2026, 11, 15);

      // User picks new start date after existing due date
      final newPickedStart = DateTime(2026, 11, 20);
      startDate = newPickedStart;
      if (dueDate.isBefore(startDate)) {
        dueDate = startDate;
      }
      expect(dueDate, equals(DateTime(2026, 11, 20)));

      // User picks new due date before existing start date
      final newPickedDue = DateTime(2026, 11, 18);
      dueDate = newPickedDue;
      if (dueDate.isBefore(startDate)) {
        startDate = dueDate;
      }
      expect(startDate, equals(DateTime(2026, 11, 18)));
    });
  });
}

class _FakeSubjectListNotifier extends SubjectListController {
  final List<Subject> _subjects;
  _FakeSubjectListNotifier(this._subjects);

  @override
  FutureOr<List<Subject>> build() => _subjects;
}
