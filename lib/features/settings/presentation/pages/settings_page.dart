import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../semester/presentation/widgets/add_edit_semester_dialog.dart';
import '../../../semester/presentation/widgets/semester_management_sheet.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: isGlassy
          ? const Color(0xFF090D16)
          : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: settingsAsync.when(
        data: (settings) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Semester Management Section
                  _buildSectionHeader('Semester Management', isDark),
                  const SizedBox(height: 10),
                  _SemesterManagementCard(isDark: isDark, isGlassy: isGlassy),
                  const SizedBox(height: 24),

                  // 1. APPEARANCE SECTION
                  _buildSectionHeader('Appearance', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark: isDark,
                    isGlassy: isGlassy,
                    child: Column(
                      children: [
                        _buildRadioTile(
                          title: 'System Default',
                          value: 'system',
                          groupValue: settings.themeMode,
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .updateThemeMode(val);
                            }
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, isGlassy),
                        _buildRadioTile(
                          title: 'Light Mode',
                          value: 'light',
                          groupValue: settings.themeMode,
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .updateThemeMode(val);
                            }
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, isGlassy),
                        _buildRadioTile(
                          title: 'Dark Mode',
                          value: 'dark',
                          groupValue: settings.themeMode,
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .updateThemeMode(val);
                            }
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, isGlassy),
                        _buildSwitchTile(
                          title: 'Glassy Interface',
                          subtitle:
                              'Smoked glass surfaces and platinum reflections',
                          value: settings.enableGlassyTheme,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateEnableGlassyTheme(val);
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. ATTENDANCE SECTION
                  _buildSectionHeader('Attendance Settings', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark: isDark,
                    isGlassy: isGlassy,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Default Attendance Target',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '${settings.defaultAttendanceTarget.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: settings.defaultAttendanceTarget,
                            min: 50.0,
                            max: 100.0,
                            divisions: 50,
                            activeColor: AppColors.primary,
                            inactiveColor: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            onChanged: (val) {
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .updateDefaultAttendanceTarget(val);
                            },
                          ),
                          _buildDivider(isDark, isGlassy),
                          const SizedBox(height: 6),
                          _buildSwitchTile(
                            title: 'Enable Late Attendance',
                            subtitle:
                                'Allow Late as an additional attendance status',
                            value: settings.enableLateAttendance,
                            onChanged: (val) {
                              ref
                                  .read(settingsControllerProvider.notifier)
                                  .updateEnableLateAttendance(val);
                            },
                            isDark: isDark,
                          ),
                          if (settings.enableLateAttendance) ...[
                            _buildDivider(isDark, isGlassy),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Late Attendance Policy',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      settings.lateAttendancePolicy == 'present'
                                          ? 'Counts as Present'
                                          : (settings.lateAttendancePolicy ==
                                                  'absent'
                                              ? 'Counts as Absent'
                                              : 'Weighted (${(settings.lateAttendanceWeight * 100).round()}%)'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                DropdownButton<String>(
                                  value: settings.lateAttendancePolicy,
                                  dropdownColor: isDark
                                      ? const Color(0xFF1E1E26)
                                      : Colors.white,
                                  underline: const SizedBox.shrink(),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'weighted',
                                        child: Text('Weighted')),
                                    DropdownMenuItem(
                                        value: 'present',
                                        child: Text('Full Present')),
                                    DropdownMenuItem(
                                        value: 'absent', child: Text('Absent')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      ref
                                          .read(settingsControllerProvider
                                              .notifier)
                                          .updateLateAttendanceSettings(
                                            weight:
                                                settings.lateAttendanceWeight,
                                            policy: val,
                                          );
                                    }
                                  },
                                ),
                              ],
                            ),
                            if (settings.lateAttendancePolicy ==
                                'weighted') ...[
                              const SizedBox(height: 4),
                              Slider(
                                value: settings.lateAttendanceWeight,
                                min: 0.1,
                                max: 0.9,
                                divisions: 8,
                                activeColor: const Color(0xFFFFB300),
                                inactiveColor: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                                onChanged: (val) {
                                  ref
                                      .read(settingsControllerProvider.notifier)
                                      .updateLateAttendanceSettings(
                                        weight: val,
                                        policy: 'weighted',
                                      );
                                },
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. NOTIFICATIONS SECTION
                  _buildSectionHeader('Notifications', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark: isDark,
                    isGlassy: isGlassy,
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          title: 'Class Reminders',
                          subtitle:
                              'Separate notifications for every scheduled class',
                          value: settings.enableNotifications,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateEnableNotifications(val);
                          },
                          isDark: isDark,
                        ),
                        if (settings.enableNotifications) ...[
                          _buildDivider(isDark, isGlassy),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Reminder Offset',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                DropdownButton<int>(
                                  value: settings.classReminderOffset > 0
                                      ? settings.classReminderOffset
                                      : 15,
                                  dropdownColor: isDark
                                      ? const Color(0xFF1E1E26)
                                      : Colors.white,
                                  underline: const SizedBox.shrink(),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 5,
                                        child: Text('5 minutes before')),
                                    DropdownMenuItem(
                                        value: 10,
                                        child: Text('10 minutes before')),
                                    DropdownMenuItem(
                                        value: 15,
                                        child: Text('15 minutes before')),
                                    DropdownMenuItem(
                                        value: 30,
                                        child: Text('30 minutes before')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      ref
                                          .read(settingsControllerProvider
                                              .notifier)
                                          .updateClassReminderOffset(val);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        _buildDivider(isDark, isGlassy),
                        _buildSwitchTile(
                          title: 'Notification Sound',
                          subtitle: 'Play sound for class alerts and reports',
                          value: settings.notificationSound,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateNotificationAudioVibration(
                                  sound: val,
                                  vibration: settings.notificationVibration,
                                );
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, isGlassy),
                        _buildSwitchTile(
                          title: 'Vibration',
                          subtitle: 'Vibrate device on incoming reminders',
                          value: settings.notificationVibration,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateNotificationAudioVibration(
                                  sound: settings.notificationSound,
                                  vibration: val,
                                );
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, isGlassy),
                        _buildSwitchTile(
                          title: 'Quiet Hours',
                          subtitle: settings.quietHoursEnabled
                              ? 'Mute from ${settings.quietHoursStartHour}:00 to ${settings.quietHoursEndHour}:00'
                              : 'Disabled',
                          value: settings.quietHoursEnabled,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateQuietHours(
                                  enabled: val,
                                  startHour: settings.quietHoursStartHour,
                                  endHour: settings.quietHoursEndHour,
                                );
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, isGlassy),
                        _buildSwitchTile(
                          title: 'Missed Attendance Reminders',
                          subtitle:
                              'Follow-up notification if class check-in is pending',
                          value: settings.missedAttendanceReminderEnabled,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateMissedAttendanceReminder(
                                  enabled: val,
                                  offsetMinutes:
                                      settings.missedAttendanceReminderOffset,
                                );
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, isGlassy),
                        _buildSwitchTile(
                          title: 'Attendance Warnings',
                          subtitle:
                              'Notify if attendance falls near or below threshold',
                          value: settings.enableAttendanceWarnings,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateEnableAttendanceWarnings(val);
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, isGlassy),
                        _buildSwitchTile(
                          title: 'Weekly Digest',
                          subtitle: 'Summary of the week\'s attendance metrics',
                          value: settings.weeklyReportEnabled,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateWeeklyReportEnabled(val);
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. AI INTELLIGENCE SECTION
                  _buildSectionHeader('AI Intelligence', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark: isDark,
                    isGlassy: isGlassy,
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          title: 'Enable AI Advisor',
                          subtitle:
                              'Intelligent attendance forecasting and advisor prompts',
                          value: settings.enableAiAdvisor,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateEnableAiAdvisor(val);
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. APPLICATION & DATA SECTION
                  _buildSectionHeader('Application & Data', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark: isDark,
                    isGlassy: isGlassy,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.widgets_outlined,
                              color: AppColors.primary),
                          title: const Text('Home Screen Widgets'),
                          subtitle: const Text(
                              'Configure Today, Weekly, and Calendar widgets'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/widget-settings'),
                        ),
                        _buildDivider(isDark, isGlassy),
                        ListTile(
                          leading: const Icon(Icons.backup_outlined,
                              color: AppColors.primary),
                          title: const Text('Backup & Restore'),
                          subtitle: const Text(
                              'Export or restore database backup (.attendiq)'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/backup'),
                        ),
                        _buildDivider(isDark, isGlassy),
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf_outlined,
                              color: AppColors.secondary),
                          title: const Text('Attendance Reports'),
                          subtitle: const Text('Generate PDF & CSV reports'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/reports'),
                        ),
                        _buildDivider(isDark, isGlassy),
                        _buildSwitchTile(
                          title: 'Cloud Synchronization (Opt-In)',
                          subtitle: settings.enableCloudSync
                              ? 'Encrypted cloud backup enabled'
                              : 'Disabled (100% Offline-First)',
                          value: settings.enableCloudSync,
                          onChanged: (val) {
                            ref
                                .read(settingsControllerProvider.notifier)
                                .updateCloudSyncSettings(
                                  enabled: val,
                                  consentGiven: val,
                                );
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    isDark: isDark,
                    isGlassy: isGlassy,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline,
                              color: AppColors.primary),
                          title: const Text('About ACEDRA'),
                          subtitle: const Text(
                              'Version 1.1.0 • Academic & Attendance Intelligence'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/about'),
                        ),
                        _buildDivider(isDark, isGlassy),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined,
                              color: AppColors.primary),
                          title: const Text('Privacy Commitment'),
                          subtitle: const Text(
                              '100% On-Device Data Privacy & Local Storage'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/about'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading settings: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _buildCard({
    required bool isDark,
    required bool isGlassy,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isGlassy
            ? const Color(0xB8141822)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGlassy
              ? const Color(0x33E2E8F0)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildDivider(bool isDark, bool isGlassy) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isGlassy
          ? const Color(0x20E2E8F0)
          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}

class _SemesterManagementCard extends ConsumerWidget {
  final bool isDark;
  final bool isGlassy;

  const _SemesterManagementCard({
    required this.isDark,
    required this.isGlassy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeSemesterProvider);
    final allSemestersAsync = ref.watch(allSemestersProvider);
    final active = activeAsync.valueOrNull;
    final totalCount = allSemestersAsync.valueOrNull?.length ?? 0;
    final dateFmt = DateFormat('dd MMM yyyy');

    final subtitleText = active != null
        ? '${dateFmt.format(active.startDate)} – ${dateFmt.format(active.endDate)}'
            ' • ${active.requiredAttendanceRate.round()}% target'
        : 'No active semester selected ($totalCount saved)';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isGlassy
            ? const Color(0xB8141822)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGlassy
              ? const Color(0x33E2E8F0)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.school_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                active?.name ?? 'No Active Semester',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                subtitleText,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (active != null ? AppColors.primary : Colors.amber)
                      .withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  active != null ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: active != null ? AppColors.primary : Colors.amber,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () => SemesterManagementSheet.show(context),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: isGlassy
                  ? const Color(0x20E2E8F0)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey<String>('manage_semesters_button'),
                      onPressed: () => SemesterManagementSheet.show(context),
                      icon: const Icon(Icons.tune_outlined, size: 18),
                      label: Text('Manage ($totalCount)'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      key: const ValueKey<String>('new_semester_button'),
                      onPressed: () => AddEditSemesterDialog.show(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'New Semester',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
