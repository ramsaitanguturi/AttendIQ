import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../semester/domain/entities/semester.dart';

class WeekSelectorWidget extends StatelessWidget {
  final String semesterName;
  final List<Semester> semesters;
  final Semester? activeSemester;
  final ValueChanged<Semester?>? onSemesterChanged;
  final int currentWeekNumber;
  final int totalWeeks;
  final String dateRangeText;
  final VoidCallback? onPrevWeek;
  final VoidCallback? onNextWeek;

  const WeekSelectorWidget({
    super.key,
    required this.semesterName,
    this.semesters = const [],
    this.activeSemester,
    this.onSemesterChanged,
    required this.currentWeekNumber,
    required this.totalWeeks,
    required this.dateRangeText,
    this.onPrevWeek,
    this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // Top Row: Semester Name or Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 18,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 8),
                  if (semesters.length > 1 && onSemesterChanged != null)
                    DropdownButtonHideUnderline(
                      child: DropdownButton<Semester>(
                        value: activeSemester,
                        icon: const Icon(Icons.arrow_drop_down),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        items: semesters.map((sem) {
                          return DropdownMenuItem<Semester>(
                            value: sem,
                            child: Text(sem.name),
                          );
                        }).toList(),
                        onChanged: onSemesterChanged,
                      ),
                    )
                  else
                    Text(
                      semesterName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Semester View',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom Row: Week Selector (< Week 3 >) and Date Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Week Button
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: currentWeekNumber > 1 ? onPrevWeek : null,
                color: AppColors.primary,
                disabledColor: Colors.grey.shade400,
                tooltip: 'Previous Week',
              ),

              // Center Week & Date Info
              Column(
                children: [
                  Text(
                    'Week $currentWeekNumber of $totalWeeks',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateRangeText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),

              // Next Week Button
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: currentWeekNumber < totalWeeks ? onNextWeek : null,
                color: AppColors.primary,
                disabledColor: Colors.grey.shade400,
                tooltip: 'Next Week',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
