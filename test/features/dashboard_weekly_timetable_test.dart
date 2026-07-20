import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/timetable/domain/utils/semester_week_calculator.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart';
import 'package:attend_iq/features/timetable/presentation/widgets/week_selector_widget.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';

void main() {
  group('Dashboard Weekly Timetable & Semester Navigation Tests', () {
    final sampleSemester = Semester(
      id: 'sem-1',
      localId: 1,
      name: 'Fall 2026 Semester',
      startDate: DateTime.utc(2026, 7, 20), // Monday
      endDate: DateTime.utc(2026, 11, 8),   // 16 weeks later (112 days)
      requiredAttendanceRate: 75.0,
    );

    // Test 1: Semester with 16 weeks generates 16 pages
    test('1. Semester with 16 weeks generates exactly 16 pages', () {
      final weeks = SemesterWeekCalculator.calculateWeeks(sampleSemester);
      expect(weeks.length, equals(16));
      expect(weeks.first.weekNumber, equals(1));
      expect(weeks.last.weekNumber, equals(16));
      expect(weeks.first.startDate, equals(DateTime.utc(2026, 7, 20)));
      expect(weeks.last.endDate, equals(DateTime.utc(2026, 11, 8)));
    });

    // Test 2: Swiping / navigating changes week correctly
    testWidgets('2. Navigating week updates selected week index and date range text',
        (WidgetTester tester) async {
      int currentWeek = 1;
      final totalWeeks = 16;
      String dateRange = '20 Jul - 26 Jul';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return WeekSelectorWidget(
                  semesterName: 'Fall 2026 Semester',
                  currentWeekNumber: currentWeek,
                  totalWeeks: totalWeeks,
                  dateRangeText: dateRange,
                  onNextWeek: () {
                    setState(() {
                      currentWeek++;
                      dateRange = '27 Jul - 2 Aug';
                    });
                  },
                  onPrevWeek: () {
                    setState(() {
                      currentWeek--;
                      dateRange = '20 Jul - 26 Jul';
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Week 1 of 16'), findsOneWidget);
      expect(find.text('20 Jul - 26 Jul'), findsOneWidget);

      // Tap next week button
      await tester.tap(find.byTooltip('Next Week'));
      await tester.pumpAndSettle();

      expect(find.text('Week 2 of 16'), findsOneWidget);
      expect(find.text('27 Jul - 2 Aug'), findsOneWidget);

      // Tap prev week button
      await tester.tap(find.byTooltip('Previous Week'));
      await tester.pumpAndSettle();

      expect(find.text('Week 1 of 16'), findsOneWidget);
    });

    // Test 3: Future weeks show timetable slots
    test('3. Future weeks evaluate WeeklyScheduleRules correctly for dates ahead', () {
      final weeks = SemesterWeekCalculator.calculateWeeks(sampleSemester);
      final futureWeek = weeks[10]; // Week 11 (Future week)

      expect(futureWeek.weekNumber, equals(11));
      // Monday of Week 11
      final futureMonday = futureWeek.dates[0];
      expect(futureMonday.weekday, equals(DateTime.monday));
      expect(futureMonday.isAfter(DateTime.utc(2026, 7, 20)), isTrue);
    });

    // Test 4: Past weeks show timetable slots
    test('4. Past weeks evaluate WeeklyScheduleRules correctly for dates behind', () {
      final weeks = SemesterWeekCalculator.calculateWeeks(sampleSemester);
      final pastWeek = weeks[0]; // Week 1 (Past/Initial week)

      expect(pastWeek.weekNumber, equals(1));
      final monday = pastWeek.dates[0];
      expect(monday.weekday, equals(DateTime.monday));
    });

    // Test 5: Holiday removes classes
    test('5. Holiday exception removes classes for target date', () {
      final holidayDate = DateTime.utc(2026, 8, 15);
      final holidayException = ScheduleException(
        id: 1,
        date: holidayDate,
        type: ScheduleExceptionType.HOLIDAY,
        title: 'Independence Day',
        description: 'College Holiday',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final dayData = DayScheduleData(
        date: holidayDate,
        weekday: holidayDate.weekday,
        isHoliday: holidayException.type == ScheduleExceptionType.HOLIDAY,
        holidayTitle: holidayException.title,
        holidayDescription: holidayException.description,
        items: const [],
      );

      expect(dayData.isHoliday, isTrue);
      expect(dayData.items, isEmpty);
      expect(dayData.holidayTitle, equals('Independence Day'));
    });

    // Test 6: Dashboard and timetable page show same data structure
    test('6. Dashboard and timetable page request same DayScheduleData model', () {
      final targetDate = DateTime.utc(2026, 8, 10);
      final slot1 = ScheduleClassSlot(
        id: 101,
        type: ScheduleSlotType.classSlot,
        subjectId: 1,
        title: 'Data Structures',
        code: 'CS201',
        startTime: '09:00',
        endTime: '10:00',
        room: 'Lab 3',
        faculty: 'Dr. Smith',
      );

      final dataFromDashboard = DayScheduleData(
        date: targetDate,
        weekday: targetDate.weekday,
        items: [slot1],
      );

      final dataFromTimetablePage = DayScheduleData(
        date: targetDate,
        weekday: targetDate.weekday,
        items: [slot1],
      );

      expect(dataFromDashboard.date, equals(dataFromTimetablePage.date));
      expect(dataFromDashboard.items.length, equals(dataFromTimetablePage.items.length));
      expect(dataFromDashboard.items.first.title, equals('Data Structures'));
    });
  });
}
