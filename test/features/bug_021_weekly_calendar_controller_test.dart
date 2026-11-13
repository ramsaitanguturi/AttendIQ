import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/timetable/domain/utils/semester_week_calculator.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart';
import 'package:attend_iq/features/timetable/presentation/widgets/semester_weekly_calendar_view.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';

class _FakeEmptySubjectListNotifier extends SubjectListController {
  @override
  FutureOr<List<Subject>> build() => [];
}

void main() {
  group('BUG-021: Weekly calendar PageController regression tests', () {
    final now = DateTime.now();
    // Monday of current week
    final currentMonday = DateTime.utc(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final testSemester = Semester(
      id: 'sem_bug021',
      localId: 1,
      name: 'Spring 2026',
      startDate: currentMonday,
      endDate: currentMonday.add(const Duration(days: 7 * 16 - 1)), // 16 weeks
      requiredAttendanceRate: 75.0,
    );

    final weeks = SemesterWeekCalculator.calculateWeeks(testSemester);

    List<Override> buildOverrides() => [
          activeSemesterProvider
              .overrideWith((ref) => Future.value(testSemester)),
          allSemestersProvider
              .overrideWith((ref) => Future.value([testSemester])),
          semesterWeeksProvider.overrideWith((ref) => Future.value(weeks)),
          subjectListControllerProvider
              .overrideWith(() => _FakeEmptySubjectListNotifier()),
          dayScheduleByKeyProvider.overrideWith((ref, key) async {
            final parsed = DateTime.parse('${key}T00:00:00Z');
            return DayScheduleData(
              date: parsed,
              weekday: parsed.weekday,
              isHoliday: false,
              items: const [],
            );
          }),
        ];

    Widget createTestWidget({void Function(ScheduleClassSlot)? onSlotTap}) {
      return ProviderScope(
        overrides: buildOverrides(),
        child: MaterialApp(
          home: Scaffold(
            body: SemesterWeeklyCalendarView(
              onSlotTap: onSlotTap,
            ),
          ),
        ),
      );
    }

    testWidgets(
        '1. Renders multiple week pages without multiple attachment assertion',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SemesterWeeklyCalendarView), findsOneWidget);
      expect(find.text('Week 1 of 16'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '2. Swiping between weeks repeatedly does not throw ScrollController multi-attach',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the PageView
      final pageViews = find.byType(PageView);
      expect(pageViews, findsWidgets);

      // Tap Next Week repeatedly
      for (int i = 0; i < 4; i++) {
        final nextBtn = find.byTooltip('Next Week');
        if (nextBtn.evaluate().isNotEmpty) {
          await tester.tap(nextBtn);
          await tester.pumpAndSettle();
        }
      }

      // Tap Prev Week repeatedly
      for (int i = 0; i < 4; i++) {
        final prevBtn = find.byTooltip('Previous Week');
        if (prevBtn.evaluate().isNotEmpty) {
          await tester.tap(prevBtn);
          await tester.pumpAndSettle();
        }
      }

      // Swipe horizontally across weeks using drag
      final outerPageView = find.byType(PageView).first;
      await tester.drag(outerPageView, const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(outerPageView, const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(outerPageView, const Offset(400, 0));
      await tester.pumpAndSettle();

      // Zero assertion errors thrown!
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '3. Navigates between days within a week without controller conflict',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Friday (FRI)
      final friTab = find.text('FRI');
      expect(friTab, findsWidgets);
      await tester.tap(friTab.first);
      await tester.pumpAndSettle();

      // Tap Monday (MON)
      final monTab = find.text('MON');
      expect(monTab, findsWidgets);
      await tester.tap(monTab.first);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '4. Rebuilding the widget repeatedly does not leak controllers or reallocate in build',
        (tester) async {
      int rebuildCount = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: buildOverrides(),
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => rebuildCount++),
                        child: Text('Rebuild $rebuildCount'),
                      ),
                      const Expanded(child: SemesterWeeklyCalendarView()),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger multiple rebuilds via setState
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
      expect(find.text('Rebuild 5'), findsOneWidget);
    });

    testWidgets('5. Disposing the widget cleans up all controllers cleanly',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Replace with empty container to trigger dispose()
      await tester
          .pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
