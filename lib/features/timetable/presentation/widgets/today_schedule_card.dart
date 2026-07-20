import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entities/daily_schedule_occurrence.dart';
import '../controllers/today_schedule_provider.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import 'add_extra_class_dialog.dart';

class TodayScheduleCard extends ConsumerWidget {
  final DateTime? targetDate;

  const TodayScheduleCard({
    super.key,
    this.targetDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = targetDate ?? DateTime.now();
    final normalizedParam = targetDate != null ? DateTime(targetDate!.year, targetDate!.month, targetDate!.day) : null;
    final todayScheduleAsync = ref.watch(todayScheduleProvider(customDate: normalizedParam));
    final subjectsAsync = ref.watch(subjectListControllerProvider);

    final subjectMap = subjectsAsync.maybeWhen<Map<int, Subject>>(
      data: (list) => {for (var s in list) s.id!: s},
      orElse: () => <int, Subject>{},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header: Date & Add Extra Class Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, d MMMM').format(date),
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => AddExtraClassDialog.show(context, initialDate: date),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.15),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                ),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Extra Class',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Content: Holiday / Empty / Occurrences List
        todayScheduleAsync.when(
          data: (state) {
            if (state.isHoliday) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.beach_access, size: 40, color: Colors.amber),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.holidayTitle ?? 'College Holiday',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.holidayDescription ?? 'All classes removed for holiday.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.occurrences.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.event_available, size: 42, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    const Text(
                      'No classes scheduled today.',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.occurrences.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final occurrence = state.occurrences[index];
                final subject = occurrence.subjectId != null ? subjectMap[occurrence.subjectId] : null;

                return _OccurrenceCard(
                  occurrence: occurrence,
                  subjectCode: subject?.code,
                  subjectColorHex: subject?.color,
                  isDark: isDark,
                );
              },
            );
          },
          loading: () => Container(
            height: 140,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
          error: (err, stackTrace) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error loading today schedule',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  err.toString(),
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.red.shade200 : Colors.red.shade900),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  Text(
                    stackTrace.toString(),
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.redAccent),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OccurrenceCard extends ConsumerWidget {
  final DailyScheduleOccurrence occurrence;
  final String? subjectCode;
  final String? subjectColorHex;
  final bool isDark;

  const _OccurrenceCard({
    required this.occurrence,
    this.subjectCode,
    this.subjectColorHex,
    required this.isDark,
  });

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.primary;
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _parseColor(subjectColorHex);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Slot & Type Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_filled, size: 16, color: color),
                  const SizedBox(width: 6),
                  Text(
                    '${occurrence.startTime} - ${occurrence.endTime}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              _buildTypeBadge(occurrence.type),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Code
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      occurrence.title,
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subjectCode != null || occurrence.room != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${subjectCode ?? ""} ${occurrence.room != null ? "• ${occurrence.room}" : ""}'.trim(),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (occurrence.reason != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Note: ${occurrence.reason}',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.deepPurpleAccent.shade100,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Animated Status & Action Buttons
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: _buildActionArea(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(OccurrenceType type) {
    Color badgeColor;
    String label;

    switch (type) {
      case OccurrenceType.REGULAR_CLASS:
        badgeColor = AppColors.primary;
        label = 'Regular';
        break;
      case OccurrenceType.EXTRA_CLASS:
        badgeColor = Colors.purpleAccent;
        label = 'Extra Class';
        break;
      case OccurrenceType.EXAM:
        badgeColor = Colors.deepOrangeAccent;
        label = 'Exam';
        break;
      case OccurrenceType.EVENT:
        badgeColor = Colors.blueAccent;
        label = 'Event';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionArea(BuildContext context, WidgetRef ref) {
    return _buildActionButtons(ref);
  }

  Widget _buildActionButtons(WidgetRef ref) {
    final currentStatus = occurrence.status;

    return Row(
      key: ValueKey('ActionButtons_${currentStatus.name}'),
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Present',
            color: AppColors.primary,
            icon: Icons.check_circle_outline,
            isSelected: currentStatus == OccurrenceStatus.PRESENT,
            onPressed: () => ref
                .read(attendanceControllerProvider.notifier)
                .markOccurrencePresent(occurrence),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            label: 'Absent',
            color: AppColors.attendanceLow,
            icon: Icons.cancel_outlined,
            isSelected: currentStatus == OccurrenceStatus.ABSENT,
            onPressed: () => ref
                .read(attendanceControllerProvider.notifier)
                .markOccurrenceAbsent(occurrence),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            label: 'Cancelled',
            color: Colors.grey,
            icon: Icons.remove_circle_outline,
            isSelected: currentStatus == OccurrenceStatus.CANCELLED,
            onPressed: () => ref
                .read(attendanceControllerProvider.notifier)
                .markOccurrenceCancelled(occurrence),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    this.isSelected = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        ),
        icon: Icon(icon, size: 14),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      ),
      icon: Icon(icon, size: 14),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
