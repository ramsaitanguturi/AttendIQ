import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../widget_config.dart';

class WidgetSettingsPage extends ConsumerWidget {
  const WidgetSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final widgetSettings = ref.watch(widgetConfigProvider);
    final notifier = ref.read(widgetConfigProvider.notifier);

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
          'Home Screen Widgets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Widget Status Section
              _buildSectionHeader('General Settings', isDark),
              const SizedBox(height: 10),
              _buildCard(
                isDark,
                child: SwitchListTile(
                  title: const Text(
                    'Enable Widgets',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: const Text(
                    'Allow AttendIQ widgets to display live academic data on your home screen',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  value: widgetSettings.enabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) => notifier.setEnabled(val),
                ),
              ),
              const SizedBox(height: 24),

              // Refresh Frequency Section
              _buildSectionHeader('Refresh Frequency', isDark),
              const SizedBox(height: 10),
              _buildCard(
                isDark,
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text(
                        'Automatic',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Sync widgets when attendance is marked, schedule updates, or app opens',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      value: 'auto',
                      groupValue: widgetSettings.refreshFrequency,
                      activeColor: AppColors.primary,
                      onChanged: widgetSettings.enabled
                          ? (val) {
                              if (val != null) notifier.setRefreshFrequency(val);
                            }
                          : null,
                    ),
                    _buildDivider(isDark),
                    RadioListTile<String>(
                      title: const Text(
                        'Every Hour',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Periodic background refresh every hour',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      value: '1h',
                      groupValue: widgetSettings.refreshFrequency,
                      activeColor: AppColors.primary,
                      onChanged: widgetSettings.enabled
                          ? (val) {
                              if (val != null) notifier.setRefreshFrequency(val);
                            }
                          : null,
                    ),
                    _buildDivider(isDark),
                    RadioListTile<String>(
                      title: const Text(
                        'Every 6 Hours',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text(
                        'Periodic background refresh every 6 hours',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      value: '6h',
                      groupValue: widgetSettings.refreshFrequency,
                      activeColor: AppColors.primary,
                      onChanged: widgetSettings.enabled
                          ? (val) {
                              if (val != null) notifier.setRefreshFrequency(val);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Available Widgets Showcase
              _buildSectionHeader('Available Widgets', isDark),
              const SizedBox(height: 10),
              _buildCard(
                isDark,
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.today, color: AppColors.primary),
                      ),
                      title: const Text('AttendIQ - Today', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Shows today\'s classes and attendance status (Small 2x2, Medium 4x2)'),
                    ),
                    _buildDivider(isDark),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_view_week, color: AppColors.secondary),
                      ),
                      title: const Text('AttendIQ - This Week', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Shows complete weekly timetable with exceptions (Large 4x4)'),
                    ),
                    _buildDivider(isDark),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_month, color: Colors.purple),
                      ),
                      title: const Text('AttendIQ - Month', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Shows upcoming academic events, exams, and task deadlines (Medium/Large)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Force Refresh Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Refresh Widgets Now',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: widgetSettings.enabled
                      ? () async {
                          await notifier.forceRefresh();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Widgets updated successfully!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      : null,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
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
}
