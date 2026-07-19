import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../semester/domain/entities/semester.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../domain/utils/semester_week_calculator.dart';
import '../controllers/weekly_schedule_view_controller.dart';
import 'week_selector_widget.dart';
import 'day_header_strip.dart';
import 'day_timeline_view.dart';

class SemesterWeeklyCalendarView extends ConsumerStatefulWidget {
  final Function(ScheduleClassSlot)? onSlotTap;

  const SemesterWeeklyCalendarView({
    super.key,
    this.onSlotTap,
  });

  @override
  ConsumerState<SemesterWeeklyCalendarView> createState() => _SemesterWeeklyCalendarViewState();
}

class _SemesterWeeklyCalendarViewState extends ConsumerState<SemesterWeeklyCalendarView> {
  late PageController _weekPageController;
  late PageController _dayPageController;
  int _selectedWeekIndex = 0;
  int _selectedDayIndex = 0; // 0 = Mon, 6 = Sun
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Default day to today's weekday (1=Mon -> 0, 7=Sun -> 6)
    final todayWeekday = DateTime.now().weekday;
    _selectedDayIndex = (todayWeekday - 1).clamp(0, 6);

    _weekPageController = PageController(initialPage: 0);
    _dayPageController = PageController(initialPage: _selectedDayIndex);
  }

  @override
  void dispose() {
    _weekPageController.dispose();
    _dayPageController.dispose();
    super.dispose();
  }

  void _initInitialWeek(List<SemesterWeek> weeks) {
    if (_isInitialized || weeks.isEmpty) return;
    _isInitialized = true;
    final initialIndex = SemesterWeekCalculator.getWeekIndexForDate(weeks, DateTime.now());
    _selectedWeekIndex = initialIndex;
    _weekPageController = PageController(initialPage: initialIndex);
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatDateRange(SemesterWeek week) {
    return '${_formatDate(week.startDate)} - ${_formatDate(week.endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final semesterAsync = ref.watch(activeSemesterProvider);
    final weeksAsync = ref.watch(semesterWeeksProvider);
    final allSemestersAsync = ref.watch(allSemestersProvider);

    final activeSemester = semesterAsync.valueOrNull;
    final weeks = weeksAsync.valueOrNull ?? [];
    final allSemesters = allSemestersAsync.valueOrNull ?? [];

    if (activeSemester == null) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Center(
          child: Text(
            'No active semester found. Please set up a semester in settings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    if (weeks.isNotEmpty && !_isInitialized) {
      _initInitialWeek(weeks);
    }

    final currentWeek = weeks.isNotEmpty && _selectedWeekIndex < weeks.length
        ? weeks[_selectedWeekIndex]
        : SemesterWeek(
            weekIndex: 0,
            weekNumber: 1,
            startDate: activeSemester.startDate,
            endDate: activeSemester.startDate.add(const Duration(days: 6)),
            dates: List.generate(7, (d) => activeSemester.startDate.add(Duration(days: d))),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Semester & Week Selector Header
        WeekSelectorWidget(
          semesterName: activeSemester.name,
          semesters: allSemesters,
          activeSemester: activeSemester,
          currentWeekNumber: currentWeek.weekNumber,
          totalWeeks: weeks.isNotEmpty ? weeks.length : 1,
          dateRangeText: _formatDateRange(currentWeek),
          onPrevWeek: () {
            if (_selectedWeekIndex > 0) {
              _weekPageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          onNextWeek: () {
            if (_selectedWeekIndex < weeks.length - 1) {
              _weekPageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
        ),

        const SizedBox(height: 12),

        // 2. Main Swappable Semester Week View
        Expanded(
          child: PageView.builder(
            controller: _weekPageController,
            itemCount: weeks.isNotEmpty ? weeks.length : 1,
            onPageChanged: (index) {
              setState(() {
                _selectedWeekIndex = index;
              });
            },
            itemBuilder: (context, weekIdx) {
              final week = weeks.isNotEmpty && weekIdx < weeks.length
                  ? weeks[weekIdx]
                  : currentWeek;

              return Column(
                children: [
                  // Day Header Strip (MON - SUN tabs)
                  DayHeaderStrip(
                    weekDates: week.dates,
                    selectedIndex: _selectedDayIndex,
                    onDaySelected: (dayIdx) {
                      setState(() {
                        _selectedDayIndex = dayIdx;
                      });
                      _dayPageController.animateToPage(
                        dayIdx,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Day Timeline PageView (swappable MON-SUN)
                  Expanded(
                    child: PageView.builder(
                      controller: _dayPageController,
                      itemCount: 7,
                      onPageChanged: (dayIdx) {
                        setState(() {
                          _selectedDayIndex = dayIdx;
                        });
                      },
                      itemBuilder: (context, dayIdx) {
                        final date = week.dates[dayIdx];
                        final dayScheduleAsync = ref.watch(dayScheduleProvider(date));

                        return dayScheduleAsync.when(
                          data: (dayData) {
                            return DayTimelineView(
                              dayData: dayData,
                              onSlotTap: widget.onSlotTap,
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                          error: (e, s) => Center(
                            child: Text(
                              'Error loading timetable: $e',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
