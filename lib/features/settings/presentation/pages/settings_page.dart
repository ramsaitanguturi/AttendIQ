import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance Section
                  _buildSectionHeader('Appearance', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark,
                    child: Column(
                      children: [
                        _buildRadioTile(
                          title: 'System Default',
                          value: 'system',
                          groupValue: settings.themeMode,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(settingsControllerProvider.notifier).updateThemeMode(val);
                            }
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildRadioTile(
                          title: 'Light Mode',
                          value: 'light',
                          groupValue: settings.themeMode,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(settingsControllerProvider.notifier).updateThemeMode(val);
                            }
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildRadioTile(
                          title: 'Dark Mode',
                          value: 'dark',
                          groupValue: settings.themeMode,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(settingsControllerProvider.notifier).updateThemeMode(val);
                            }
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Attendance Section
                  _buildSectionHeader('Attendance Settings', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Default Attendance Target',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                            inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            onChanged: (val) {
                              ref.read(settingsControllerProvider.notifier).updateDefaultAttendanceTarget(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notifications Section
                  _buildSectionHeader('Notifications', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark,
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          title: 'Class Reminders',
                          subtitle: 'Alert 5 minutes before scheduled classes',
                          value: settings.enableNotifications,
                          onChanged: (val) {
                            ref.read(settingsControllerProvider.notifier).updateEnableNotifications(val);
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          title: 'Attendance Warnings',
                          subtitle: 'Notify if attendance falls near threshold',
                          value: settings.enableAttendanceWarnings,
                          onChanged: (val) {
                            ref.read(settingsControllerProvider.notifier).updateEnableAttendanceWarnings(val);
                          },
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildSwitchTile(
                          title: 'Weekly Digest',
                          subtitle: 'Summary of the week\'s attendance metrics',
                          value: settings.weeklyReportEnabled,
                          onChanged: (val) {
                            ref.read(settingsControllerProvider.notifier).updateWeeklyReportEnabled(val);
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Widgets Section
                  _buildSectionHeader('Home Screen Widgets', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark,
                    child: ListTile(
                      leading: const Icon(Icons.widgets_outlined, color: AppColors.primary),
                      title: const Text('Widgets Configuration'),
                      subtitle: const Text('Configure Today, Weekly, and Calendar widgets'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/widget-settings'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Backup & Data Section
                  _buildSectionHeader('Data Management', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.backup_outlined, color: AppColors.primary),
                          title: const Text('Backup & Restore'),
                          subtitle: const Text('Export or restore database backup (.attendiq)'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/backup'),
                        ),
                        _buildDivider(isDark),
                        ListTile(
                          leading: const Icon(Icons.download_outlined, color: AppColors.secondary),
                          title: const Text('Export Data'),
                          onTap: () => context.push('/backup'),
                        ),
                        _buildDivider(isDark),
                        ListTile(
                          leading: const Icon(Icons.upload_outlined, color: AppColors.secondary),
                          title: const Text('Import Data'),
                          onTap: () => context.push('/backup'),
                        ),
                        _buildDivider(isDark),
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.secondary),
                          title: const Text('Attendance Reports'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/reports'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About & Info Section
                  _buildSectionHeader('App & Privacy', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline, color: AppColors.primary),
                          title: const Text('App Info'),
                          subtitle: const Text('Version 1.1.0 (Offline-First)'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/about'),
                        ),
                        _buildDivider(isDark),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                          title: const Text('Privacy Commitment'),
                          subtitle: const Text('100% On-Device Data Privacy'),
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

  Widget _buildCard(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
