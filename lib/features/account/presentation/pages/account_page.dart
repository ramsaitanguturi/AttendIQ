import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/acedra_logo.dart';
import '../../../semester/domain/entities/semester.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../semester/presentation/widgets/add_edit_semester_dialog.dart';
import '../../../semester/presentation/widgets/semester_management_sheet.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../../attendance/presentation/controllers/subject_attendance_stats_provider.dart';
import '../../../../core/widgets/acedra_floating_bottom_bar.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final activeSemester = ref.watch(activeSemesterProvider).valueOrNull;
    final subjects = ref.watch(subjectListControllerProvider).valueOrNull ?? [];
    final overallPercentage =
        ref.watch(overallAttendancePercentageProvider).valueOrNull ?? 0.0;
    final aiAdvisorEnabled = ref.watch(isAiAdvisorEnabledProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 8.0,
          bottom: AcedraFloatingBottomBar.contentBottomPadding(context,
              additionalClearance: 44.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile / Student Card
            _buildProfileCard(
              context,
              activeSemester?.name ?? 'Academic Session',
              subjects.length,
              overallPercentage,
              isDark,
              isGlassy,
            ),
            const SizedBox(height: 20),

            // 2. Semester Management Section
            _buildSectionHeader('Semester Management', isDark),
            const SizedBox(height: 10),
            _buildSemesterCard(context, ref, activeSemester, isDark, isGlassy),
            const SizedBox(height: 24),

            // 3. Preferences & Features Section
            _buildSectionHeader('Features & Control', isDark),
            const SizedBox(height: 10),
            _buildMenuCard(
              isDark: isDark,
              isGlassy: isGlassy,
              children: [
                _buildMenuItem(
                  icon: Icons.tune_rounded,
                  iconColor: AppColors.iconPrimary(isDark),
                  title: 'Settings & Preferences',
                  subtitle: 'Appearance, notifications, target percentages',
                  onTap: () => context.push('/settings'),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildMenuItem(
                  icon: Icons.backup_rounded,
                  iconColor: AppColors.iconPrimary(isDark),
                  title: 'Backup & Restore',
                  subtitle: 'Export and import offline database snapshots',
                  onTap: () => context.push('/backup'),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildMenuItem(
                  icon: Icons.task_alt_rounded,
                  iconColor: AppColors.iconPrimary(isDark),
                  title: 'Academic Planner',
                  subtitle: 'Assignments, exams, and academic tasks',
                  onTap: () => context.push('/planner'),
                  isDark: isDark,
                ),
                if (aiAdvisorEnabled) ...[
                  _buildDivider(isDark),
                  _buildMenuItem(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: AppColors.iconPrimary(isDark),
                    title: 'AI Attendance Advisor',
                    subtitle:
                        'Intelligent schedule advice & attendance insights',
                    onTap: () => context.push('/ai-assistant'),
                    isDark: isDark,
                  ),
                ],
                _buildDivider(isDark),
                _buildMenuItem(
                  icon: Icons.widgets_rounded,
                  iconColor: AppColors.iconPrimary(isDark),
                  title: 'Home Screen Widgets',
                  subtitle: 'Live timetable and attendance widgets',
                  onTap: () => context.push('/widget-settings'),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. About & System
            _buildSectionHeader('System & Information', isDark),
            const SizedBox(height: 10),
            _buildMenuCard(
              isDark: isDark,
              isGlassy: isGlassy,
              children: [
                _buildMenuItem(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.iconPrimary(isDark),
                  title: 'About ACEDRA',
                  subtitle: 'Version 2.0.0 (ACEDRA Edition) • 100% Offline',
                  onTap: () => context.push('/about'),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Brand Footer
            Center(
              child: Column(
                children: [
                  const AcedraLogo(size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'ACEDRA',
                    style: TextStyle(
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Academic & Attendance Intelligence',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary.withOpacity(0.6)
                          : AppColors.lightTextSecondary.withOpacity(0.6),
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

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color:
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    String semesterName,
    int subjectCount,
    double attendanceRate,
    bool isDark,
    bool isGlassy,
  ) {
    final statusColor = AppColors.attendanceMetricColor(attendanceRate, isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isGlassy
            ? AppColors.surfaceGlass(isDark)
            : AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color:
              isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const AcedraLogo(size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Profile',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  semesterName,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${attendanceRate.toStringAsFixed(1)}% Overall',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.gray400 : AppColors.gray700)
                            .withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color:
                                (isDark ? AppColors.gray400 : AppColors.gray700)
                                    .withOpacity(0.3)),
                      ),
                      child: Text(
                        '$subjectCount Subjects',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.gray300 : AppColors.gray800,
                        ),
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
  }

  Widget _buildSemesterCard(
    BuildContext context,
    WidgetRef ref,
    Semester? activeSemester,
    bool isDark,
    bool isGlassy,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: isGlassy
            ? AppColors.surfaceGlass(isDark)
            : AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color:
              isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.school_rounded,
                      color: AppColors.iconPrimary(isDark), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    activeSemester?.name ?? 'No Active Semester',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (activeSemester != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primary : AppColors.gray900)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.primary : AppColors.gray900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => SemesterManagementSheet.show(context),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Manage Semesters'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => AddEditSemesterDialog.show(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('New'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  side: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required bool isDark,
    required bool isGlassy,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isGlassy
            ? AppColors.surfaceGlass(isDark)
            : AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color:
              isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.0,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 20, color: AppColors.iconSecondary(isDark)),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.06),
    );
  }
}
