import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../domain/entities/academic_event.dart';
import '../../domain/entities/schedule_exception.dart';
import '../controllers/academic_calendar_controller.dart';
import '../controllers/timetable_controller.dart';

import '../../../academic_planner/presentation/widgets/add_edit_task_sheet.dart';

class DateDetailsBottomSheet extends ConsumerWidget {
  final CalendarDayData dayData;

  const DateDetailsBottomSheet({
    super.key,
    required this.dayData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(dayData.date);

    final regularClasses = dayData.items.where((i) => i.type == CalendarItemType.REGULAR_CLASS).toList();
    final cancelledClasses = dayData.items.where((i) => i.type == CalendarItemType.CANCELLED_CLASS).toList();
    final extraClasses = dayData.items.where((i) => i.type == CalendarItemType.EXTRA_CLASS).toList();
    final exams = dayData.items.where((i) => i.type == CalendarItemType.EXAM).toList();
    final holidays = dayData.items.where((i) => i.type == CalendarItemType.HOLIDAY).toList();
    final events = dayData.items.where((i) => i.type == CalendarItemType.EVENT).toList();
    final tasks = dayData.items.where((i) => i.type == CalendarItemType.TASK).toList();

    return Container(
      padding: const EdgeInsets.only(top: 16.0, left: 20.0, right: 20.0, bottom: 24.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dayData.isToday) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TODAY',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Holidays
            if (holidays.isNotEmpty) ...[
              _buildSectionHeader(context, 'Holidays', Icons.beach_access, Colors.amber),
              ...holidays.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Exams
            if (exams.isNotEmpty) ...[
              _buildSectionHeader(context, 'Exams', Icons.assignment_late, Colors.redAccent),
              ...exams.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Regular Classes
            if (regularClasses.isNotEmpty || cancelledClasses.isNotEmpty) ...[
              _buildSectionHeader(context, 'Classes', Icons.class_, Colors.green),
              ...regularClasses.map((item) => _buildItemTile(context, item, isDark)),
              ...cancelledClasses.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Extra Classes
            if (extraClasses.isNotEmpty) ...[
              _buildSectionHeader(context, 'Extra Classes', Icons.more_time, Colors.blueAccent),
              ...extraClasses.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Events & Deadlines
            if (events.isNotEmpty) ...[
              _buildSectionHeader(context, 'Events & Deadlines', Icons.event, Colors.purpleAccent),
              ...events.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Academic Tasks
            if (tasks.isNotEmpty) ...[
              _buildSectionHeader(context, 'Tasks & Submissions', Icons.task_alt, Colors.orange),
              ...tasks.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Empty state if no items exist on this day
            if (dayData.items.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'No classes or events scheduled for this day.',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Action Buttons
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.add_task, size: 16, color: Colors.orange),
                  label: const Text('+ Add Task'),
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => AddEditTaskSheet(initialDate: dayData.date),
                    );
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.event, size: 16, color: Colors.purpleAccent),
                  label: const Text('+ Add Event'),
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  onPressed: () => _showAddEventDialog(context, ref, dayData.date, AcademicEventType.EVENT),
                ),
                ActionChip(
                  avatar: const Icon(Icons.add_alarm, size: 16, color: Colors.blueAccent),
                  label: const Text('+ Add Extra Class'),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  onPressed: () => _showAddExtraClassDialog(context, ref, dayData.date),
                ),
                ActionChip(
                  avatar: const Icon(Icons.beach_access, size: 16, color: Colors.amber),
                  label: const Text('+ Add Holiday'),
                  backgroundColor: Colors.amber.withOpacity(0.1),
                  onPressed: () => _showAddHolidayDialog(context, ref, dayData.date),
                ),
                ActionChip(
                  avatar: const Icon(Icons.assignment, size: 16, color: Colors.redAccent),
                  label: const Text('+ Add Exam'),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  onPressed: () => _showAddEventDialog(context, ref, dayData.date, AcademicEventType.EXAM),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, CalendarItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.type.indicatorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: item.type.indicatorColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    decoration: item.type == CalendarItemType.CANCELLED_CLASS
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: 11.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.startTime != null && item.startTime!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.type.indicatorColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.endTime != null && item.endTime!.isNotEmpty
                    ? '${item.startTime} - ${item.endTime}'
                    : item.startTime!,
                style: TextStyle(
                  color: item.type.indicatorColor,
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref, DateTime date, AcademicEventType defaultType) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final startTimeController = TextEditingController(text: '10:00');
    final endTimeController = TextEditingController(text: '11:00');
    AcademicEventType selectedType = defaultType;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(defaultType == AcademicEventType.EXAM ? 'Add Exam' : 'Add Academic Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g. Mid Semester Exam / Assignment Submission',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional notes',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          hintText: 'HH:mm',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endTimeController,
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          hintText: 'HH:mm',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AcademicEventType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Event Type'),
                  items: AcademicEventType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toShortString())))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedType = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                await ref.read(academicEventControllerProvider.notifier).addEvent(
                      title: title,
                      description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                      date: date,
                      startTime: startTimeController.text.trim().isEmpty ? null : startTimeController.text.trim(),
                      endTime: endTimeController.text.trim().isEmpty ? null : endTimeController.text.trim(),
                      type: selectedType,
                    );
                if (context.mounted) {
                  Navigator.of(dialogCtx).pop();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHolidayDialog(BuildContext context, WidgetRef ref, DateTime date) {
    final titleController = TextEditingController(text: 'Holiday');
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add Holiday'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Holiday Title *',
                hintText: 'e.g. Independence Day',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional notes',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              await ref.read(scheduleExceptionControllerProvider.notifier).addException(
                    date: date,
                    type: ScheduleExceptionType.HOLIDAY,
                    title: title,
                    description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                  );
              if (context.mounted) {
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save Holiday'),
          ),
        ],
      ),
    );
  }

  void _showAddExtraClassDialog(BuildContext context, WidgetRef ref, DateTime date) {
    final subjects = ref.read(subjectListControllerProvider).valueOrNull ?? [];
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add subjects first before scheduling extra classes.')),
      );
      return;
    }

    Subject selectedSubject = subjects.first;
    final startTimeController = TextEditingController(text: '15:00');
    final endTimeController = TextEditingController(text: '16:00');

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Extra Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Subject>(
                value: selectedSubject,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedSubject = val);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        hintText: 'HH:mm',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        hintText: 'HH:mm',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save extra class as an AcademicEvent or ScheduleException for display
                await ref.read(academicEventControllerProvider.notifier).addEvent(
                      title: 'Extra ${selectedSubject.name} Class',
                      description: 'Extra Class for ${selectedSubject.name}',
                      date: date,
                      startTime: startTimeController.text.trim(),
                      endTime: endTimeController.text.trim(),
                      type: AcademicEventType.EVENT,
                    );
                if (context.mounted) {
                  Navigator.of(dialogCtx).pop();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Extra Class'),
            ),
          ],
        ),
      ),
    );
  }
}
