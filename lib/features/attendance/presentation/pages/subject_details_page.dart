import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/glass/glass_theme_tokens.dart';
import '../../../../core/attendance_engine/bunk_analyzer.dart';
import '../../../timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../timetable/presentation/widgets/add_extra_class_dialog.dart';
import '../controllers/subject_attendance_stats_provider.dart';
import '../controllers/attendance_controller.dart';
import '../../domain/entities/attendance_record.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

class SubjectDetailsPage extends ConsumerWidget {
  final int subjectId;

  const SubjectDetailsPage({
    super.key,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(subjectAttendanceStatsProvider(subjectId));
    final occurrencesAsync = ref.watch(subjectOccurrencesProvider(subjectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Subject Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          statsAsync.when(
            data: (stats) {
              if (stats == null || stats.subject.id == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Extra Class',
                onPressed: () => AddExtraClassDialog.show(
                  context,
                  initialSubjectId: stats.subject.id,
                  initialSubject: stats.subject,
                  initialStatus: AttendanceStatus.extraPresent,
                  lockSubject: true,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: statsAsync.when(
        skipLoadingOnReload: true,
        data: (stats) {
          if (stats == null) {
            return const Center(child: Text('Subject not found'));
          }

          final subjectColor = _parseColor(stats.subject.color);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Card
                  _buildHeroCard(
                    context,
                    stats,
                    subjectColor,
                    isDark,
                    isGlassy,
                  ),
                  const SizedBox(height: 20),

                  // Status and Recommendation Alert
                  _buildRecommendationAlert(stats, isDark, isGlassy),
                  const SizedBox(height: 20),

                  // Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBox(
                          context: context,
                          label: 'Safe Bunks',
                          value: '${stats.safeBunks}',
                          valueColor:
                              isDark ? AppColors.primary : AppColors.gray900,
                          icon: Icons.check_circle_outline,
                          isDark: isDark,
                          isGlassy: isGlassy,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricBox(
                          context: context,
                          label: 'Must Attend',
                          value: stats.requiredClasses == null
                              ? 'N/A'
                              : '${stats.requiredClasses}',
                          valueColor: stats.requiredClasses == 0
                              ? (isDark ? AppColors.primary : AppColors.gray900)
                              : (isDark
                                  ? AppColors.gray300
                                  : AppColors.gray800),
                          icon: Icons.warning_amber_rounded,
                          isDark: isDark,
                          isGlassy: isGlassy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary Statistics
                  _buildStatsSection(context, stats, isDark, isGlassy),
                  const SizedBox(height: 24),

                  // Class Logs Header
                  const Text(
                    'Class History Logs',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Occurrence history list
                  occurrencesAsync.when(
                    skipLoadingOnReload: true,
                    data: (occurrences) {
                      if (occurrences.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32.0),
                          decoration: isGlassy
                              ? GlassTokens.glassBoxDecoration(
                                  isDark: isDark,
                                  borderRadius: 16.0,
                                )
                              : BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurface
                                      : AppColors.lightSurface,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder,
                                  ),
                                ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.history_toggle_off,
                                size: 40,
                                color: isDark
                                    ? AppColors.darkIconSecondary
                                    : AppColors.lightIconSecondary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No classes logged yet',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: occurrences.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final occurrence = occurrences[index];
                          return _buildOccurrenceItem(
                            context,
                            ref,
                            occurrence,
                            subjectColor,
                            isDark,
                            isGlassy,
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) =>
                        Center(child: Text('Error loading classes: $err')),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading stats: $err')),
      ),
    );
  }

  Color _parseColor(String colorHex) {
    return AppColors.parseMonochromeHex(colorHex);
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildHeroCard(
    BuildContext context,
    SubjectAttendanceStats stats,
    Color subjectColor,
    bool isDark,
    bool isGlassy,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: isGlassy
          ? GlassTokens.glassBoxDecoration(
              isDark: isDark,
              borderRadius: 20.0,
              customBorderColor: subjectColor.withOpacity(0.35),
            )
          : BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stats.subject.code,
                    style: TextStyle(
                      color: subjectColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  stats.subject.name,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (stats.subject.faculty != null &&
                    stats.subject.faculty!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Instructor: ${stats.subject.faculty}',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 14.0,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Credits: ${stats.subject.credits}',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Percentage display
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: stats.attendancePercentage / 100,
                      strokeWidth: 8,
                      backgroundColor:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                    ),
                  ),
                  Text(
                    '${stats.attendancePercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Target: ${stats.subject.attendanceTarget.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationAlert(
    SubjectAttendanceStats stats,
    bool isDark,
    bool isGlassy,
  ) {
    Color alertBg;
    Color alertBorder;
    Color alertText;
    IconData alertIcon;

    if (isDark) {
      switch (stats.bunkAnalysis.status) {
        case BunkStatus.critical:
          alertBg = AppColors.gray700.withOpacity(0.3);
          alertBorder = AppColors.gray400;
          alertText = AppColors.gray100;
          alertIcon = Icons.error_outline;
          break;
        case BunkStatus.warning:
          alertBg = AppColors.gray700.withOpacity(0.25);
          alertBorder = AppColors.gray400;
          alertText = AppColors.gray200;
          alertIcon = Icons.warning_amber_rounded;
          break;
        case BunkStatus.normal:
          alertBg = isGlassy
              ? AppColors.darkSurfaceGlass
              : AppColors.gray100.withOpacity(0.08);
          alertBorder = isGlassy
              ? GlassTokens.silverBorder
              : AppColors.gray300.withOpacity(0.4);
          alertText = AppColors.gray100;
          alertIcon = Icons.check_circle_outline;
          break;
      }
    } else {
      switch (stats.bunkAnalysis.status) {
        case BunkStatus.critical:
          alertBg = AppColors.gray200;
          alertBorder = AppColors.gray700;
          alertText = AppColors.gray900;
          alertIcon = Icons.error_outline;
          break;
        case BunkStatus.warning:
          alertBg = AppColors.gray200;
          alertBorder = AppColors.gray700;
          alertText = AppColors.gray800;
          alertIcon = Icons.warning_amber_rounded;
          break;
        case BunkStatus.normal:
          alertBg =
              isGlassy ? AppColors.surfaceGlass(isDark) : AppColors.gray200;
          alertBorder =
              isGlassy ? GlassTokens.lightGlassBorder : AppColors.gray700;
          alertText = AppColors.gray900;
          alertIcon = Icons.check_circle_outline;
          break;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: alertBg,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: alertBorder),
        boxShadow: isGlassy
            ? GlassTokens.cardShadows(isGlassy: true, isDark: isDark)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(alertIcon, color: alertText, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${stats.bunkAnalysis.statusText}',
                  style: TextStyle(
                    color: alertText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stats.bunkAnalysis.recommendation,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontSize: 13.0,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required BuildContext context,
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
    required bool isDark,
    required bool isGlassy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: isGlassy
          ? GlassTokens.glassBoxDecoration(
              isDark: isDark,
              borderRadius: 16.0,
            )
          : BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark
                    ? AppColors.darkIconSecondary
                    : AppColors.lightIconSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
    BuildContext context,
    SubjectAttendanceStats stats,
    bool isDark,
    bool isGlassy,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: isGlassy
          ? GlassTokens.glassBoxDecoration(
              isDark: isDark,
              borderRadius: 20.0,
            )
          : BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Breakdown',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Present Classes',
            '${stats.presentCount}',
            AppColors.statusPresent(isDark),
            isDark,
          ),
          const Divider(height: 24),
          _buildStatRow(
            'Absent Classes',
            '${stats.absentCount}',
            AppColors.statusAbsent(isDark),
            isDark,
          ),
          const Divider(height: 24),
          _buildStatRow(
            'Total Logged',
            '${stats.totalClasses}',
            AppColors.textPrimary(isDark),
            isDark,
          ),
          const Divider(height: 24),
          _buildStatRow(
            'Predicted Final Rate',
            '${stats.predictedPercentage.toStringAsFixed(1)}%',
            stats.predictedPercentage >= stats.subject.attendanceTarget
                ? AppColors.primaryColor(isDark)
                : AppColors.statusAbsent(isDark),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color? valueColor,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(isDark),
            fontSize: 14.0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
        ),
      ],
    );
  }

  Widget _buildOccurrenceItem(
    BuildContext context,
    WidgetRef ref,
    DailyScheduleOccurrence occurrence,
    Color subjectColor,
    bool isDark,
    bool isGlassy,
  ) {
    final lateEnabled = ref.watch(isLateAttendanceEnabledProvider);
    Color statusColor = AppColors.textSecondary(isDark);
    IconData statusIcon = Icons.help_outline;

    switch (occurrence.status) {
      case OccurrenceStatus.present:
        statusColor = AppColors.statusPresent(isDark);
        statusIcon = Icons.check_circle_outline;
        break;
      case OccurrenceStatus.absent:
        statusColor = AppColors.statusAbsent(isDark);
        statusIcon = Icons.cancel_outlined;
        break;
      case OccurrenceStatus.cancelled:
        statusColor = AppColors.statusCancelledAdaptive(isDark);
        statusIcon = Icons.block_outlined;
        break;
      case OccurrenceStatus.upcoming:
        statusColor = isDark ? AppColors.gray400 : AppColors.gray700;
        statusIcon = Icons.radio_button_unchecked;
        break;
      case OccurrenceStatus.late:
        statusColor = AppColors.statusLate(isDark);
        statusIcon = Icons.access_time_outlined;
        break;
    }

    final subtitleText = occurrence.type == OccurrenceType.extraClass
        ? '${occurrence.startTime} - ${occurrence.endTime} • Extra Class'
        : '${occurrence.startTime} - ${occurrence.endTime}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: isGlassy
          ? GlassTokens.glassBoxDecoration(
              isDark: isDark,
              borderRadius: 14.0,
            )
          : BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(isDark ? 0.22 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(occurrence.date),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.iconSecondary(isDark)),
            onSelected: (value) {
              final notifier = ref.read(attendanceControllerProvider.notifier);
              if (value == 'present') {
                notifier.markOccurrencePresent(occurrence);
              } else if (value == 'late') {
                notifier.markOccurrenceLate(occurrence);
              } else if (value == 'absent') {
                notifier.markOccurrenceAbsent(occurrence);
              } else if (value == 'cancelled') {
                notifier.markOccurrenceCancelled(occurrence);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'present',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.statusPresent(isDark),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mark Present',
                      style: TextStyle(color: AppColors.textPrimary(isDark)),
                    ),
                  ],
                ),
              ),
              if (lateEnabled) ...[
                PopupMenuItem(
                  value: 'late',
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: AppColors.statusLate(isDark),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mark Late',
                        style: TextStyle(color: AppColors.textPrimary(isDark)),
                      ),
                    ],
                  ),
                ),
              ],
              PopupMenuItem(
                value: 'absent',
                child: Row(
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: AppColors.statusAbsent(isDark),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mark Absent',
                      style: TextStyle(color: AppColors.textPrimary(isDark)),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cancelled',
                child: Row(
                  children: [
                    Icon(
                      Icons.block_outlined,
                      color: AppColors.statusCancelledAdaptive(isDark),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mark Cancelled',
                      style: TextStyle(color: AppColors.textPrimary(isDark)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
