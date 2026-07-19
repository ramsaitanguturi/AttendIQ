import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/entities/academic_event.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/timetable_controller.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/academic_calendar_controller.dart';
import 'package:attend_iq/features/timetable/presentation/widgets/academic_calendar_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testSemester = Semester(
    id: 'sem_1',
    localId: 1,
    name: 'Fall 2026',
    startDate: DateTime(2026, 7, 1),
    endDate: DateTime(2026, 12, 31),
    requiredAttendanceRate: 75.0,
  );

  final testSubject = Subject(
    id: 101,
    semesterId: 1,
    name: 'Operating Systems',
    code: 'CS301',
    credits: 4,
    attendanceTarget: 75.0,
    color: '#42A5F5',
    type: SubjectType.THEORY,
    updatedAt: DateTime.now(),
  );

  final testRule = WeeklyScheduleRule(
    id: 1,
    subjectId: 101,
    dayOfWeek: 2, // Tuesday
    startTime: '09:00',
    endTime: '10:00',
    room: 'Lab 1',
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  test('Calendar aggregates recurring weekly classes within semester date range', () async {
    final container = ProviderContainer(
      overrides: [
        activeSemesterProvider.overrideWith((ref) => Future.value(testSemester)),
        weeklyScheduleRuleListControllerProvider.overrideWith(() => FakeRuleListNotifier([testRule])),
        scheduleExceptionControllerProvider.overrideWith(() => FakeExceptionNotifier([])),
        academicEventControllerProvider.overrideWith(() => FakeAcademicEventNotifier([])),
        subjectListControllerProvider.overrideWith(() => FakeSubjectListNotifier([testSubject])),
        selectedMonthProvider.overrideWith((ref) => DateTime(2026, 7, 1)),
      ],
    );
    addTearDown(container.dispose);

    final daysAsync = container.read(monthlyCalendarDataProvider);
    final days = daysAsync.value!;

    // July 21, 2026 is Tuesday
    final july21 = days.firstWhere((d) => d.date.year == 2026 && d.date.month == 7 && d.date.day == 21);
    expect(july21.isInSemesterRange, isTrue);
    expect(july21.hasRegularClass, isTrue);
    expect(july21.items.any((i) => i.title == 'Operating Systems'), isTrue);
  });

  test('Holiday hides regular recurring classes on that date', () async {
    final holidayException = ScheduleException(
      id: 5,
      date: DateTime(2026, 7, 21),
      type: ScheduleExceptionType.HOLIDAY,
      title: 'National Holiday',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        activeSemesterProvider.overrideWith((ref) => Future.value(testSemester)),
        weeklyScheduleRuleListControllerProvider.overrideWith(() => FakeRuleListNotifier([testRule])),
        scheduleExceptionControllerProvider.overrideWith(() => FakeExceptionNotifier([holidayException])),
        academicEventControllerProvider.overrideWith(() => FakeAcademicEventNotifier([])),
        subjectListControllerProvider.overrideWith(() => FakeSubjectListNotifier([testSubject])),
        selectedMonthProvider.overrideWith((ref) => DateTime(2026, 7, 1)),
      ],
    );
    addTearDown(container.dispose);

    final daysAsync = container.read(monthlyCalendarDataProvider);
    final days = daysAsync.value!;

    final july21 = days.firstWhere((d) => d.date.year == 2026 && d.date.month == 7 && d.date.day == 21);
    expect(july21.hasHoliday, isTrue);
    // Holiday hides regular class execution
    expect(july21.hasRegularClass, isFalse);
    expect(july21.items.any((i) => i.type == CalendarItemType.HOLIDAY), isTrue);
  });

  test('Multiple events on same date calculate priority correctly', () async {
    final examEvent = AcademicEvent(
      id: 1,
      title: 'Mathematics Exam',
      date: DateTime(2026, 7, 21),
      startTime: '10:00',
      endTime: '12:00',
      type: AcademicEventType.EXAM,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final deadlineEvent = AcademicEvent(
      id: 2,
      title: 'Assignment Submission',
      date: DateTime(2026, 7, 21),
      type: AcademicEventType.ASSIGNMENT,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final container = ProviderContainer(
      overrides: [
        activeSemesterProvider.overrideWith((ref) => Future.value(testSemester)),
        weeklyScheduleRuleListControllerProvider.overrideWith(() => FakeRuleListNotifier([testRule])),
        scheduleExceptionControllerProvider.overrideWith(() => FakeExceptionNotifier([])),
        academicEventControllerProvider.overrideWith(() => FakeAcademicEventNotifier([examEvent, deadlineEvent])),
        subjectListControllerProvider.overrideWith(() => FakeSubjectListNotifier([testSubject])),
        selectedMonthProvider.overrideWith((ref) => DateTime(2026, 7, 1)),
      ],
    );
    addTearDown(container.dispose);

    final daysAsync = container.read(monthlyCalendarDataProvider);
    final days = daysAsync.value!;

    final july21 = days.firstWhere((d) => d.date.year == 2026 && d.date.month == 7 && d.date.day == 21);
    expect(july21.hasExam, isTrue);
    expect(july21.hasEvent, isTrue);
    expect(july21.hasRegularClass, isTrue);

    // Verify priority sorting (Exam first, Regular Class, Event)
    expect(july21.items.first.type, equals(CalendarItemType.EXAM));
  });

  testWidgets('AcademicCalendarWidget renders month view and handles month navigation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeSemesterProvider.overrideWith((ref) => Future.value(testSemester)),
          weeklyScheduleRuleListControllerProvider.overrideWith(() => FakeRuleListNotifier([testRule])),
          scheduleExceptionControllerProvider.overrideWith(() => FakeExceptionNotifier([])),
          academicEventControllerProvider.overrideWith(() => FakeAcademicEventNotifier([])),
          subjectListControllerProvider.overrideWith(() => FakeSubjectListNotifier([testSubject])),
          selectedMonthProvider.overrideWith((ref) => DateTime(2026, 7, 1)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AcademicCalendarWidget(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Academic Calendar'), findsOneWidget);
    expect(find.text('July 2026'), findsOneWidget);

    // Tap next month chevron
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(find.text('August 2026'), findsOneWidget);
  });
}

class FakeRuleListNotifier extends WeeklyScheduleRuleListController {
  final List<WeeklyScheduleRule> _rules;
  FakeRuleListNotifier(this._rules);

  @override
  FutureOr<List<WeeklyScheduleRule>> build() => _rules;
}

class FakeExceptionNotifier extends ScheduleExceptionController {
  final List<ScheduleException> _exceptions;
  FakeExceptionNotifier(this._exceptions);

  @override
  FutureOr<List<ScheduleException>> build() => _exceptions;
}

class FakeAcademicEventNotifier extends AcademicEventController {
  final List<AcademicEvent> _events;
  FakeAcademicEventNotifier(this._events);

  @override
  FutureOr<List<AcademicEvent>> build() => _events;
}

class FakeSubjectListNotifier extends SubjectListController {
  final List<Subject> _subjects;
  FakeSubjectListNotifier(this._subjects);

  @override
  FutureOr<List<Subject>> build() => _subjects;
}
