import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/sync/sync_manager/sync_manager.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(settingsControllerProvider);
    final pendingCountAsync = ref.watch(pendingOperationsCountProvider);

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
                  _buildSectionHeader('Notifications & Reminders', isDark),
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
                          title: 'Weekly Sunday Digest',
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

                  // Account Section
                  _buildSectionHeader('Account Management', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.secondary),
                          title: const Text('Attendance Reports'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/reports'),
                        ),
                        _buildDivider(isDark),
                        ListTile(
                          leading: const Icon(Icons.person_outline, color: AppColors.secondary),
                          title: const Text('View Profile'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/profile'),
                        ),
                        _buildDivider(isDark),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.orangeAccent),
                          title: const Text('Logout'),
                          onTap: () => _showLogoutDialog(context, ref),
                        ),
                        _buildDivider(isDark),
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: AppColors.attendanceLow),
                          title: const Text(
                            'Delete Account',
                            style: TextStyle(color: AppColors.attendanceLow, fontWeight: FontWeight.bold),
                          ),
                          onTap: () => _showDeleteAccountDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Backup & Sync Section
                  _buildSectionHeader('Backup & Sync Status', isDark),
                  const SizedBox(height: 10),
                  _buildCard(
                    isDark,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sync State',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              pendingCountAsync.when(
                                data: (count) {
                                  if (count > 0) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.attendanceMid.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Pending Sync ($count)',
                                        style: const TextStyle(
                                          color: AppColors.attendanceMid,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Fully Synced',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                                loading: () => const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                error: (_, __) => const Text('Unknown'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Last Sync Time', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              Text(
                                settings.lastSyncTime != null
                                    ? settings.lastSyncTime!.toLocal().toString().split('.').first
                                    : 'Never',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Starting manual synchronization...')),
                                );
                                await ref.read(syncManagerProvider).sync();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.sync),
                              label: const Text('Sync Now', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out of AttendIQ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(authControllerProvider.notifier).logout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.orangeAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete Account', style: TextStyle(color: AppColors.attendanceLow)),
          content: const Text(
            'WARNING: This action is permanent and cannot be undone. All your attendance data, schedules, and cloud backups will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // Perform delete account
                ref.read(authControllerProvider.notifier).deleteAccount();
              },
              child: const Text(
                'Delete Permanently',
                style: TextStyle(color: AppColors.attendanceLow, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
