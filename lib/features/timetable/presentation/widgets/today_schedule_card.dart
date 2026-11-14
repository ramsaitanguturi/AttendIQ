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
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../../core/theme/glass/glass_theme_tokens.dart';
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
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final date = targetDate ?? DateTime.now();
    final normalizedParam = targetDate != null
        ? DateTime(targetDate!.year, targetDate!.month, targetDate!.day)
        : null;
    final todayScheduleAsync =
        ref.watch(todayScheduleProvider(customDate: normalizedParam));
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
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
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
              onPressed: () =>
                  AddExtraClassDialog.show(context, initialDate: date),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.gray900.withOpacity(0.08),
                foregroundColor: isDark ? AppColors.primary : AppColors.gray900,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.primary.withOpacity(0.4)
                        : AppColors.lightBorder,
                  ),
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
                  color: AppColors.gray700.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.beach_access,
                      size: 40,
                      color: AppColors.gray300,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.holidayTitle ?? 'College Holiday',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.holidayDescription ??
                                'All classes removed for holiday.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
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
                decoration: isGlassy
                    ? GlassTokens.glassBoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        fillColor: isDark
                            ? GlassTokens.smokedGlassSurface
                            : GlassTokens.lightGlassSurface,
                        borderColor: isDark
                            ? GlassTokens.silverBorder
                            : GlassTokens.lightGlassBorder,
                        isDark: isDark,
                      )
                    : BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 42,
                      color: isDark
                          ? AppColors.darkIconPrimary
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No classes scheduled today.',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
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
                final subject = occurrence.subjectId != null
                    ? subjectMap[occurrence.subjectId]
                    : null;

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
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray600),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error loading today schedule',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  err.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  Text(
                    stackTrace.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextSecondary,
                    ),
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
    return AppColors.parseMonochromeHex(hex, AppColors.gray300);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _parseColor(subjectColorHex);
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: isGlassy
          ? GlassTokens.glassBoxDecoration(
              isDark: isDark,
              borderRadius: 20.0,
            )
          : BoxDecoration(
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
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
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
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    if (subjectCode != null || occurrence.room != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${subjectCode ?? ""} ${occurrence.room != null ? "• ${occurrence.room}" : ""}'
                            .trim(),
                        style: TextStyle(
                          fontSize: 12.0,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
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
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextSecondary,
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
    Color badgeBg;
    Color badgeBorder;
    String label;

    if (isDark) {
      switch (type) {
        case OccurrenceType.regularClass:
          badgeColor = AppColors.gray100;
          badgeBg = AppColors.gray100.withOpacity(0.12);
          badgeBorder = AppColors.gray300;
          label = 'Regular';
          break;
        case OccurrenceType.extraClass:
          badgeColor = AppColors.gray200;
          badgeBg = AppColors.gray300.withOpacity(0.12);
          badgeBorder = AppColors.gray400;
          label = 'Extra Class';
          break;
        case OccurrenceType.exam:
          badgeColor = AppColors.gray100;
          badgeBg = AppColors.gray700.withOpacity(0.5);
          badgeBorder = AppColors.gray400;
          label = 'Exam';
          break;
        case OccurrenceType.event:
          badgeColor = AppColors.gray200;
          badgeBg = AppColors.gray700.withOpacity(0.4);
          badgeBorder = AppColors.gray400;
          label = 'Event';
          break;
      }
    } else {
      switch (type) {
        case OccurrenceType.regularClass:
          badgeColor = AppColors.gray900;
          badgeBg = AppColors.gray900.withOpacity(0.08);
          badgeBorder = AppColors.gray700;
          label = 'Regular';
          break;
        case OccurrenceType.extraClass:
          badgeColor = AppColors.gray800;
          badgeBg = AppColors.gray800.withOpacity(0.08);
          badgeBorder = AppColors.gray700;
          label = 'Extra Class';
          break;
        case OccurrenceType.exam:
          badgeColor = AppColors.gray900;
          badgeBg = AppColors.gray200;
          badgeBorder = AppColors.gray700;
          label = 'Exam';
          break;
        case OccurrenceType.event:
          badgeColor = AppColors.gray800;
          badgeBg = AppColors.gray200;
          badgeBorder = AppColors.gray700;
          label = 'Event';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeBorder.withOpacity(0.6)),
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
    final lateEnabled = ref.watch(isLateAttendanceEnabledProvider);

    return Row(
      key: ValueKey('ActionButtons_${currentStatus.name}_$lateEnabled'),
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Present',
            color: AppColors.statusPresent(isDark),
            icon: Icons.check_circle_outline,
            isSelected: currentStatus == OccurrenceStatus.present,
            onPressed: () => ref
                .read(attendanceControllerProvider.notifier)
                .markOccurrencePresent(occurrence),
          ),
        ),
        if (lateEnabled) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              label: 'Late',
              color: AppColors.statusLate(isDark),
              icon: Icons.access_time,
              isSelected: currentStatus == OccurrenceStatus.late,
              onPressed: () => ref
                  .read(attendanceControllerProvider.notifier)
                  .markOccurrenceLate(occurrence),
            ),
          ),
        ],
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            label: 'Absent',
            color: AppColors.statusAbsent(isDark),
            icon: Icons.cancel_outlined,
            isSelected: currentStatus == OccurrenceStatus.absent,
            onPressed: () => ref
                .read(attendanceControllerProvider.notifier)
                .markOccurrenceAbsent(occurrence),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            label: 'Cancelled',
            color: AppColors.statusCancelledAdaptive(isDark),
            icon: Icons.remove_circle_outline,
            isSelected: currentStatus == OccurrenceStatus.cancelled,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isSelected) {
      final btnBg = color;
      final btnFg = color.computeLuminance() > 0.4
          ? AppColors.gray900
          : AppColors.gray100;
      return ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnBg,
          foregroundColor: btnFg,
          elevation: 2,
          minimumSize: const Size(0, 42),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        ),
        icon: Icon(icon, size: 14, color: btnFg),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: btnFg,
          ),
        ),
      );
    }

    final outlineColor = color.withOpacity(isDark ? 0.45 : 0.60);
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        minimumSize: const Size(0, 42),
        side: BorderSide(color: outlineColor, width: 1.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      ),
      icon: Icon(icon, size: 14, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
