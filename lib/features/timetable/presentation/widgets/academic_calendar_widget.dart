import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../controllers/academic_calendar_controller.dart';
import 'date_details_bottom_sheet.dart';

class AcademicCalendarWidget extends ConsumerWidget {
  const AcademicCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpanded = ref.watch(isCalendarExpandedProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final calendarDataAsync = ref.watch(monthlyCalendarDataProvider);
    final upcomingEventsCount = ref.watch(upcomingMonthEventsCountProvider);

    final monthTitle = DateFormat('MMMM yyyy').format(selectedMonth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Collapsible Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Academic Calendar',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  ref.read(isCalendarExpandedProvider.notifier).state = !isExpanded;
                },
              ),
            ],
          ),

          if (!isExpanded) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  monthTitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$upcomingEventsCount Upcoming Events',
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (isExpanded) ...[
            const SizedBox(height: 12),
            // Month Selector Bar: < July 2026 >
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
                    ref.read(selectedMonthProvider.notifier).state = prevMonth;
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                  child: Text(
                    monthTitle,
                    key: ValueKey(selectedMonth),
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
                    ref.read(selectedMonthProvider.notifier).state = nextMonth;
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Weekdays Header (Mon Tue Wed Thu Fri Sat Sun)
            Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Calendar Grid with Swipe Left/Right Support
            calendarDataAsync.when(
              data: (days) {
                return GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! < -200) {
                        // Swipe left -> next month
                        final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
                        ref.read(selectedMonthProvider.notifier).state = nextMonth;
                      } else if (details.primaryVelocity! > 200) {
                        // Swipe right -> previous month
                        final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
                        ref.read(selectedMonthProvider.notifier).state = prevMonth;
                      }
                    }
                  },
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final dayData = days[index];
                      return _buildDateCell(context, dayData, isDark);
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(
                child: Text('Error loading calendar: $err'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateCell(BuildContext context, CalendarDayData dayData, bool isDark) {
    final isDisabled = !dayData.isInSemesterRange;

    Color textColor = isDark ? Colors.white : Colors.black87;
    if (!dayData.isCurrentMonth) {
      textColor = isDark ? Colors.white30 : Colors.black26;
    }
    if (isDisabled) {
      textColor = isDark ? Colors.white24 : Colors.black26;
    }

    return InkWell(
      onTap: isDisabled
          ? null
          : () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => DateDetailsBottomSheet(dayData: dayData),
              );
            },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: dayData.isToday
              ? AppColors.primary.withOpacity(0.15)
              : (isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dayData.isToday
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: dayData.isToday ? 1.5 : 0.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${dayData.date.day}',
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: dayData.isToday ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),

            // Indicator Dots Row: 🟢 Class, 🔴 Exam, 🟠 Task Deadline, 🟡 Holiday, 🔵 Extra Class, 🟣 Event
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (dayData.hasRegularClass && !isDisabled)
                  _buildDot(const Color(0xFF66BB6A)),
                if (dayData.hasExam && !isDisabled)
                  _buildDot(const Color(0xFFEF5350)),
                if (dayData.hasTask && !isDisabled)
                  _buildDot(const Color(0xFFFF9800)),
                if (dayData.hasHoliday && !isDisabled)
                  _buildDot(const Color(0xFFFFCA28)),
                if (dayData.hasExtraClass && !isDisabled)
                  _buildDot(const Color(0xFF42A5F5)),
                if (dayData.hasEvent && !isDisabled)
                  _buildDot(const Color(0xFFAB47BC)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 5.5,
      height: 5.5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
