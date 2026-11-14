import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/acedra_logo.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('About ACEDRA'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const AcedraLogo(size: 80, showWordmark: true, spacing: 14),
                  const SizedBox(height: 6),
                  Text(
                    'Version 2.0.0 (ACEDRA Edition)',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildFeatureRow(
                    Icons.wifi_off,
                    '100% Offline Intelligence',
                    'Runs completely offline on your device with zero dependency on external servers.',
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Icons.no_accounts,
                    'Zero User Tracking',
                    'No registration, no user accounts, complete privacy guaranteed.',
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Icons.storage,
                    'Local Isar Database',
                    'All academic data resides safely in your device high-performance Isar engine.',
                    isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureRow(
                    Icons.import_export,
                    'Seamless Backup & Restore',
                    'Export and import complete encrypted database backups anytime.',
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
      IconData icon, String title, String subtitle, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.iconPrimary(isDark), size: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
