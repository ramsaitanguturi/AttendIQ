import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/semester.dart';
import '../../domain/validators/semester_validator.dart';
import '../controllers/semester_controller.dart';
import '../controllers/semester_management_controller.dart';
import 'add_edit_semester_dialog.dart';

class SemesterManagementSheet extends ConsumerWidget {
  const SemesterManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SemesterManagementSheet(),
    );
  }

  Future<void> _activateSemester(
    BuildContext context,
    WidgetRef ref,
    Semester semester,
  ) async {
    final localId = semester.localId;
    if (localId == null) return;

    try {
      await ref
          .read(semesterManagementControllerProvider.notifier)
          .setActiveSemester(localId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched active semester to "${semester.name}".'),
          ),
        );
      }
    } on ValidationException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    }
  }

  Future<void> _archiveSemester(
    BuildContext context,
    WidgetRef ref,
    Semester semester,
  ) async {
    final localId = semester.localId;
    if (localId == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (semester.isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Archive Active Semester?'),
          content: Text(
            'Archiving "${semester.name}" makes it read-only. '
            'You can reactivate it or create a new semester anytime.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primary : AppColors.gray900,
                foregroundColor: isDark ? AppColors.gray900 : AppColors.gray100,
              ),
              child: const Text('Archive'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }

    try {
      await ref
          .read(semesterManagementControllerProvider.notifier)
          .archiveSemester(localId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archived "${semester.name}".')),
        );
      }
    } on ValidationException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final semestersAsync = ref.watch(allSemestersProvider);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray700 : AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage Semesters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                key: const ValueKey<String>('sheet_new_semester_button'),
                onPressed: () => AddEditSemesterDialog.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.primary : AppColors.gray900,
                  foregroundColor:
                      isDark ? AppColors.gray900 : AppColors.gray100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'New Semester',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Flexible(
            child: semestersAsync.when(
              data: (semesters) {
                if (semesters.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No semesters configured yet.',
                        style:
                            TextStyle(color: AppColors.textSecondary(isDark)),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: semesters.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final sem = semesters[index];
                    return _SemesterTile(
                      key: ValueKey<int>(sem.localId ?? index),
                      semester: sem,
                      isDark: isDark,
                      onEdit: sem.isArchived
                          ? null
                          : () => AddEditSemesterDialog.show(
                                context,
                                existingSemester: sem,
                              ),
                      onActivate: sem.isActive
                          ? null
                          : () => _activateSemester(context, ref, sem),
                      onArchive: sem.isArchived
                          ? null
                          : () => _archiveSemester(context, ref, sem),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading semesters: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterTile extends StatelessWidget {
  final Semester semester;
  final bool isDark;
  final VoidCallback? onEdit;
  final VoidCallback? onActivate;
  final VoidCallback? onArchive;

  const _SemesterTile({
    super.key,
    required this.semester,
    required this.isDark,
    this.onEdit,
    this.onActivate,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final todayNorm = SemesterValidator.normalizeDate(DateTime.now());
    final isExpired =
        SemesterValidator.normalizeDate(semester.endDate).isBefore(todayNorm);

    final Color badgeColor;
    switch (semester.status) {
      case SemesterStatus.active:
        badgeColor = isDark ? AppColors.primary : AppColors.gray900;
        break;
      case SemesterStatus.draft:
        badgeColor = isDark ? AppColors.gray400 : AppColors.gray700;
        break;
      case SemesterStatus.archived:
        badgeColor = isDark ? AppColors.gray500 : AppColors.gray600;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: semester.isActive
              ? (isDark ? AppColors.primary : AppColors.gray900)
                  .withOpacity(0.6)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  semester.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (semester.isArchived) ...[
                      Icon(Icons.lock_outline, size: 12, color: badgeColor),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      semester.status.displayName,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${dateFmt.format(semester.startDate)} – ${dateFmt.format(semester.endDate)} '
            '• Target ${semester.requiredAttendanceRate.round()}%',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          if (semester.isActive && isExpired) ...[
            const SizedBox(height: 6),
            const Text(
              'Semester end date has passed — consider archiving or starting a new semester.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.gray400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (onActivate != null)
                OutlinedButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Activate'),
                ),
              if (onEdit != null)
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
              if (onArchive != null)
                OutlinedButton.icon(
                  onPressed: onArchive,
                  icon: const Icon(Icons.archive_outlined, size: 16),
                  label: const Text('Archive'),
                ),
              if (semester.isArchived)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Read-only (activate to edit)',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textMuted(isDark)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
