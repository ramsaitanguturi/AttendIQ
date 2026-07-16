import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/attendance_engine/bunk_analyzer.dart';
import '../../../../core/event_generator/data/models/event_local.dart';
import '../controllers/subject_attendance_stats_provider.dart';
import '../controllers/attendance_controller.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../domain/entities/attendance_record.dart';

class SubjectDetailsPage extends ConsumerWidget {
  final int subjectId;

  const SubjectDetailsPage({
    super.key,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(subjectAttendanceStatsProvider(subjectId));
    final eventsAsync = ref.watch(subjectEventsProvider(subjectId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
              if (stats == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Extra Class',
                onPressed: () => _showExtraClassDialog(context, ref, stats.subject),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats == null) {
            return const Center(child: Text('Subject not found'));
          }

          final subjectColor = _parseColor(stats.subject.color);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Card
                  _buildHeroCard(context, stats, subjectColor, isDark),
                  const SizedBox(height: 20),

                  // Status and Recommendation Alert
                  _buildRecommendationAlert(stats, isDark),
                  const SizedBox(height: 20),

                  // Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBox(
                          context: context,
                          label: 'Safe Bunks',
                          value: '${stats.safeBunks}',
                          valueColor: AppColors.primary,
                          icon: Icons.check_circle_outline,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricBox(
                          context: context,
                          label: 'Must Attend',
                          value: stats.requiredClasses == null ? 'N/A' : '${stats.requiredClasses}',
                          valueColor: stats.requiredClasses == 0 ? AppColors.primary : AppColors.attendanceLow,
                          icon: Icons.warning_amber_rounded,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Summary Statistics
                  _buildStatsSection(context, stats, isDark),
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

                  // Event list
                  eventsAsync.when(
                    data: (events) {
                      if (events.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.history_toggle_off, size: 40, color: Colors.grey),
                              SizedBox(height: 12),
                              Text(
                                'No classes logged yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _buildEventItem(context, ref, event, subjectColor, isDark);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error loading events: $err')),
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
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildHeroCard(
    BuildContext context,
    SubjectAttendanceStats stats,
    Color subjectColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                if (stats.subject.faculty != null && stats.subject.faculty!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Instructor: ${stats.subject.faculty}',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontSize: 14.0,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Credits: ${stats.subject.credits}',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                      backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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

  Widget _buildRecommendationAlert(SubjectAttendanceStats stats, bool isDark) {
    Color alertBg;
    Color alertBorder;
    Color alertText;
    IconData alertIcon;

    switch (stats.bunkAnalysis.status) {
      case BunkStatus.CRITICAL:
        alertBg = AppColors.attendanceLow.withOpacity(0.08);
        alertBorder = AppColors.attendanceLow.withOpacity(0.3);
        alertText = AppColors.attendanceLow;
        alertIcon = Icons.error_outline;
        break;
      case BunkStatus.WARNING:
        alertBg = AppColors.attendanceMid.withOpacity(0.08);
        alertBorder = AppColors.attendanceMid.withOpacity(0.3);
        alertText = AppColors.attendanceMid;
        alertIcon = Icons.warning_amber_rounded;
        break;
      case BunkStatus.NORMAL:
        alertBg = AppColors.primary.withOpacity(0.08);
        alertBorder = AppColors.primary.withOpacity(0.3);
        alertText = AppColors.primary;
        alertIcon = Icons.check_circle_outline;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: alertBg,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: alertBorder),
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
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
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
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
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

  Widget _buildStatsSection(BuildContext context, SubjectAttendanceStats stats, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
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
          _buildStatRow('Present Classes', '${stats.presentCount}', AppColors.primary),
          const Divider(height: 24),
          _buildStatRow('Absent Classes', '${stats.absentCount}', AppColors.attendanceLow),
          const Divider(height: 24),
          _buildStatRow('Total Logged', '${stats.totalClasses}', null),
          const Divider(height: 24),
          _buildStatRow(
            'Predicted Final Rate',
            '${stats.predictedPercentage.toStringAsFixed(1)}%',
            stats.predictedPercentage >= stats.subject.attendanceTarget ? AppColors.primary : AppColors.attendanceLow,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14.0),
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

  Widget _buildEventItem(
    BuildContext context,
    WidgetRef ref,
    EventLocal event,
    Color subjectColor,
    bool isDark,
  ) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    switch (event.status) {
      case 'PRESENT':
        statusColor = AppColors.primary;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'ABSENT':
        statusColor = AppColors.attendanceLow;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'CANCELLED':
        statusColor = Colors.grey.shade600;
        statusIcon = Icons.block_outlined;
        break;
      case 'UNMARKED':
        statusColor = AppColors.attendanceMid;
        statusIcon = Icons.radio_button_unchecked;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
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
              color: statusColor.withOpacity(0.12),
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
                  _formatDate(event.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.startTime} - ${event.endTime}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              final statusMap = {
                'present': AttendanceStatus.PRESENT,
                'absent': AttendanceStatus.ABSENT,
                'cancelled': AttendanceStatus.CANCELLED,
              };
              ref.read(attendanceControllerProvider.notifier).markAttendance(
                    eventId: event.id,
                    subjectId: event.subjectId,
                    status: statusMap[value]!,
                  );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'present',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Mark Present'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'absent',
                child: Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: AppColors.attendanceLow, size: 20),
                    SizedBox(width: 8),
                    Text('Mark Absent'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancelled',
                child: Row(
                  children: [
                    Icon(Icons.block_outlined, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text('Mark Cancelled'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExtraClassDialog(BuildContext context, WidgetRef ref, Subject subject) {
    DateTime selectedDate = DateTime.now();
    AttendanceStatus status = AttendanceStatus.EXTRA_PRESENT;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Add Extra Class'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Register an unscheduled/extra class for ${subject.name}.'),
                  const SizedBox(height: 16),
                  // Date selection button
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date of Class'),
                    subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                    trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 90)),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Attendance Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<AttendanceStatus>(
                    value: status,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    items: const [
                      DropdownMenuItem(
                        value: AttendanceStatus.EXTRA_PRESENT,
                        child: Text('Extra Present'),
                      ),
                      DropdownMenuItem(
                        value: AttendanceStatus.EXTRA_ABSENT,
                        child: Text('Extra Absent'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => status = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    await ref.read(attendanceControllerProvider.notifier).markExtraClass(
                          subjectId: subject.id!,
                          date: selectedDate,
                          status: status,
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Log'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
