import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../features/timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../theme/colors.dart';
import '../../services/pending_check_in_service.dart';

class PendingCheckInsBanner extends ConsumerWidget {
  const PendingCheckInsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingCheckInsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return pendingAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16161F) : const Color(0xFFF7F7FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.amber.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
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
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pending_actions,
                        color: Colors.amber,
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
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${items.length}',
                                  style: const TextStyle(
                                    color: Colors.black,
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
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
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
                              color: const Color(0xFF4CAF50),
                              onPressed: () => _resolveItem(
                                ref,
                                item,
                                OccurrenceStatus.PRESENT,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickButton(
                              context,
                              label: 'Late',
                              color: const Color(0xFFFFB300),
                              onPressed: () => _resolveItem(
                                ref,
                                item,
                                OccurrenceStatus.LATE,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickButton(
                              context,
                              label: 'Absent',
                              color: const Color(0xFFEF5350),
                              onPressed: () => _resolveItem(
                                ref,
                                item,
                                OccurrenceStatus.ABSENT,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _buildQuickButton(
                              context,
                              label: 'Cancel',
                              color: const Color(0xFF9E9E9E),
                              onPressed: () => _resolveItem(
                                ref,
                                item,
                                OccurrenceStatus.CANCELLED,
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.amber,
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
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
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
