import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../attendance/presentation/controllers/subject_attendance_stats_provider.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../../core/event_generator/data/models/event_local.dart';
import '../../../../core/attendance_engine/bunk_analyzer.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userName = authState.valueOrNull?.name ?? 'Student';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final overallPercentageAsync = ref.watch(overallAttendancePercentageProvider);
    final statsListAsync = ref.watch(allSubjectAttendanceStatsProvider);
    final todayEventsAsync = ref.watch(todayEventsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AttendIQ Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allSubjectAttendanceStatsProvider);
          ref.invalidate(todayEventsProvider);
          ref.invalidate(overallAttendancePercentageProvider);
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header & Sync Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _buildSyncStatusPill(isDark),
                  ],
                ),
                const SizedBox(height: 24.0),

                // Overall Attendance Circular Progress Hero card
                _buildOverallProgressCard(context, overallPercentageAsync, isDark),
                const SizedBox(height: 24.0),

                // Today's schedule section
                const Text(
                  "Today's Schedule",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                _buildTodayScheduleList(context, ref, todayEventsAsync, statsListAsync, isDark),
                const SizedBox(height: 24.0),

                // Subjects Grid Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Subjects',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/timetable'),
                      child: const Text('Manage Timetable', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                _buildSubjectsGrid(context, statsListAsync, isDark),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusPill(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 14, color: Colors.grey),
          SizedBox(width: 6),
          Text(
            'Offline Mode',
            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(
    BuildContext context,
    AsyncValue<double> percentageAsync,
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
      child: percentageAsync.when(
        data: (percentage) {
          final isSafe = percentage >= 75.0; // Mock semester target check
          final strokeColor = isSafe ? AppColors.primary : AppColors.attendanceLow;
          
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Semester Attendance',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isSafe
                          ? 'You are currently above the target attendance threshold. Keep it up!'
                          : 'Your attendance is critical! Attend classes consecutively to restore eligibility.',
                      style: TextStyle(
                        fontSize: 13.0,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: percentage / 100.0,
                      strokeWidth: 8,
                      backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(strokeColor),
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading percentage: $err')),
      ),
    );
  }

  Widget _buildTodayScheduleList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<EventLocal>> todayEventsAsync,
    AsyncValue<List<SubjectAttendanceStats>> statsListAsync,
    bool isDark,
  ) {
    return todayEventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: const Center(
              child: Text(
                'No classes scheduled for today',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final statsList = statsListAsync.valueOrNull ?? [];
        final subjectMap = {
          for (var s in statsList) s.subject.id: s
        };

        return SizedBox(
          height: 110,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final event = events[index];
              final stats = subjectMap[event.subjectId];
              final subjectName = stats?.subject.name ?? 'Subject';
              final subjectColorHex = stats?.subject.color ?? '#00E599';
              final color = _parseColor(subjectColorHex);

              return Container(
                width: 250,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            subjectName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildQuickLogButton(
                                text: 'Present',
                                color: AppColors.primary,
                                isMarked: event.status == 'PRESENT',
                                onTap: () => ref
                                    .read(attendanceControllerProvider.notifier)
                                    .markAttendance(
                                      eventId: event.id,
                                      subjectId: event.subjectId,
                                      status: AttendanceStatus.PRESENT,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              _buildQuickLogButton(
                                text: 'Absent',
                                color: AppColors.attendanceLow,
                                isMarked: event.status == 'ABSENT',
                                onTap: () => ref
                                    .read(attendanceControllerProvider.notifier)
                                    .markAttendance(
                                      eventId: event.id,
                                      subjectId: event.subjectId,
                                      status: AttendanceStatus.ABSENT,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading today\'s schedule: $err')),
    );
  }

  Widget _buildQuickLogButton({
    required String text,
    required Color color,
    required bool isMarked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isMarked ? color : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMarked ? Colors.black : color,
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectsGrid(
    BuildContext context,
    AsyncValue<List<SubjectAttendanceStats>> statsListAsync,
    bool isDark,
  ) {
    return statsListAsync.when(
      data: (statsList) {
        if (statsList.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: const Center(
              child: Text(
                'No subjects added yet. Tap Onboarding or Timetable to add.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.15,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: statsList.length,
          itemBuilder: (context, index) {
            final stats = statsList[index];
            final color = _parseColor(stats.subject.color);

            Color alertBadgeColor = AppColors.primary;
            String alertBadgeText = 'Safe Skips: ${stats.safeBunks}';

            if (stats.bunkAnalysis.status == BunkStatus.CRITICAL) {
              alertBadgeColor = AppColors.attendanceLow;
              final req = stats.requiredClasses;
              alertBadgeText = req == null ? 'Critical' : 'Must Attend: $req';
            } else if (stats.bunkAnalysis.status == BunkStatus.WARNING) {
              alertBadgeColor = AppColors.attendanceMid;
              alertBadgeText = 'Warning skips: ${stats.safeBunks}';
            }

            return Card(
              elevation: 0,
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: InkWell(
                onTap: () => context.push('/subject/${stats.subject.id}'),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                '${stats.attendancePercentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: stats.attendancePercentage >= stats.subject.attendanceTarget
                                      ? AppColors.primary
                                      : AppColors.attendanceLow,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stats.subject.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          if (stats.subject.faculty != null && stats.subject.faculty!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              stats.subject.faculty!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: alertBadgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          alertBadgeText,
                          style: TextStyle(
                            color: alertBadgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading subjects: $err')),
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
}
