import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../features/timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../../features/settings/presentation/controllers/settings_controller.dart';
import '../../../theme/colors.dart';
import '../../../theme/glass/glass_theme_tokens.dart';
import '../../services/pending_check_in_service.dart';

class PendingCheckInsBanner extends ConsumerWidget {
  const PendingCheckInsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingCheckInsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);

    return pendingAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: isGlassy
              ? GlassTokens.glassBoxDecoration(
                  isDark: isDark,
                  borderRadius: 16.0,
                )
              : BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.gray700 : AppColors.gray200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.pending_actions,
                        color: isDark ? AppColors.gray100 : AppColors.gray900,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Pending Check-Ins',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.primary
                                      : AppColors.gray900,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${items.length}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.onPrimary
                                        : AppColors.gray100,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Unanswered class check-ins require your attention',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Item list (display up to 3 directly, or all)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length > 3 ? 3 : items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final formattedDate =
                      DateFormat('EEE, MMM d').format(item.date);

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.subjectName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Text(
                              '$formattedDate • ${item.startTime}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildQuickButton(
                              context,
                              label: 'Present',
                              color: AppColors.statusPresent(isDark),
                              onPressed: () => _resolveItem(
                                ref,
                                item,
                                OccurrenceStatus.present,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickButton(
                              context,
                              label: 'Late',
                              color: AppColors.statusLate(isDark),
                              onPressed: () => _resolveItem(
                                ref,
                                item,
                                OccurrenceStatus.late,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickButton(
                              context,
                              label: 'Absent',
                              color: AppColors.statusAbsent(isDark),
                              onPressed: () => _resolveItem(
                                ref,
                                item,
                                OccurrenceStatus.absent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickButton(
                              context,
                              label: 'Cancel',
                              color: AppColors.statusCancelledAdaptive(isDark),
                              onPressed: () => _resolveItem(
                                ref,
                                item,
                                OccurrenceStatus.cancelled,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              if (items.length > 3) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      '+ ${items.length - 3} more pending classes in Calendar',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        (!isDark && color.computeLuminance() > 0.6) ? AppColors.gray900 : color;
    final borderColor =
        (!isDark && color.computeLuminance() > 0.6) ? AppColors.gray700 : color;

    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor.withOpacity(0.35)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resolveItem(
    WidgetRef ref,
    PendingCheckInItem item,
    OccurrenceStatus status,
  ) async {
    final service = ref.read(pendingCheckInServiceProvider);
    await service.resolveCheckIn(item: item, status: status);
  }
}
