import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('App Info & Privacy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.school, size: 56, color: AppColors.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'AttendIQ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.1.0 (Offline-First Build)',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildFeatureRow(
                    Icons.wifi_off,
                    '100% Offline Application',
                    'Runs completely without internet connection or external servers.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Icons.no_accounts,
                    'Zero User Tracking',
                    'No registration, no user accounts, no login required.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Icons.storage,
                    'Local Isar Database',
                    'All data resides safely on your device in high-performance Isar database.',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Icons.import_export,
                    'Manual Backup & Restore',
                    'Export and import complete database backups (.attendiq) anytime.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
