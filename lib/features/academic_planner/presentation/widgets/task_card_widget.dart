import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:attend_iq/core/theme/colors.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import '../../domain/entities/academic_task.dart';
import '../../domain/entities/task_enums.dart';
import '../controllers/task_controller.dart';
import 'add_edit_task_sheet.dart';

class TaskCardWidget extends ConsumerWidget {
  final AcademicTask task;
  final VoidCallback? onTap;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final urgency = task.urgencyAt(now);
    final isCompleted = task.status == TaskStatus.COMPLETED;

    final subjects = ref.watch(subjectListControllerProvider).valueOrNull ?? [];
    Subject? subject;
    if (task.subjectId != null) {
      subject = subjects.firstWhere(
        (s) => s.id == task.subjectId,
        orElse: () => Subject(
          id: task.subjectId,
          semesterId: 0,
          name: 'Subject #${task.subjectId}',
          code: 'SUB',
          credits: 3,
          attendanceTarget: 75,
          color: '#42A5F5',
          type: SubjectType.THEORY,
          updatedAt: DateTime.now(),
        ),
      );
    }

    final formattedDeadline = DateFormat('E, MMM d • h:mm a').format(task.dueDate);
    final remainingText = task.remainingDaysText(now);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isCompleted
              ? (isDark ? Colors.grey[800]! : Colors.grey[300]!)
              : urgency.color.withOpacity(0.5),
          width: isCompleted ? 1.0 : 1.5,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap ??
              () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => AddEditTaskSheet(taskToEdit: task),
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Completion Checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Checkbox(
                    value: isCompleted,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: (val) {
                      if (task.id != null) {
                        ref.read(taskListControllerProvider.notifier).toggleTaskCompletion(task.id!);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Main Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Title & Priority Chip
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted
                                    ? (isDark ? Colors.grey[500] : Colors.grey[600])
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Priority Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: task.priority.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.priority.displayName,
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: task.priority.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Tags Row: Task Type & Subject
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Task Category Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(task.taskType.icon, size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  task.taskType.displayName,
                                  style: const TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Subject Tag
                          if (subject != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                subject.name,
                                style: const TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description if present
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Footer Row: Deadline Date & Urgency Chip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Deadline Date & Time
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedDeadline,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),

                          // Urgency Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.grey.withOpacity(0.12)
                                  : urgency.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              remainingText,
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                                color: isCompleted ? Colors.grey : urgency.color,
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
          ),
        ),
      ),
    );
  }
}
