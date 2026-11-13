import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/glass/glass_bottom_sheet.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';
import '../../domain/entities/academic_event.dart';
import '../../domain/entities/daily_schedule_occurrence.dart';
import '../../domain/entities/schedule_exception.dart';
import '../controllers/academic_calendar_controller.dart';
import '../controllers/timetable_controller.dart';
import 'add_extra_class_dialog.dart';

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
    final calendarDaysAsync = ref.watch(monthlyCalendarDataProvider);
    final activeDayData = calendarDaysAsync.valueOrNull?.firstWhereOrNull(
          (d) =>
              d.date.year == dayData.date.year &&
              d.date.month == dayData.date.month &&
              d.date.day == dayData.date.day,
        ) ??
        dayData;
    final formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(activeDayData.date);

    final regularClasses = activeDayData.items
        .where((i) => i.type == CalendarItemType.REGULAR_CLASS)
        .toList();
    final cancelledClasses = activeDayData.items
        .where((i) => i.type == CalendarItemType.CANCELLED_CLASS)
        .toList();
    final extraClasses = activeDayData.items
        .where((i) => i.type == CalendarItemType.EXTRA_CLASS)
        .toList();
    final exams = activeDayData.items
        .where((i) => i.type == CalendarItemType.EXAM)
        .toList();
    final holidays = activeDayData.items
        .where((i) => i.type == CalendarItemType.HOLIDAY)
        .toList();
    final events = activeDayData.items
        .where((i) => i.type == CalendarItemType.EVENT)
        .toList();
    final tasks = activeDayData.items
        .where((i) => i.type == CalendarItemType.TASK)
        .toList();

    return GlassBottomSheetContainer(
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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
              _buildSectionHeader(
                  context, 'Holidays', Icons.beach_access, Colors.amber),
              ...holidays.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Exams
            if (exams.isNotEmpty) ...[
              _buildSectionHeader(
                  context, 'Exams', Icons.assignment_late, Colors.redAccent),
              ...exams.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Regular Classes & Cancelled Classes (with interactive historical editing)
            if (regularClasses.isNotEmpty || cancelledClasses.isNotEmpty) ...[
              _buildSectionHeader(
                  context, 'Classes', Icons.class_, Colors.green),
              ...regularClasses.map((item) => _buildClassItemCard(
                  context, ref, item, activeDayData.date, isDark)),
              ...cancelledClasses.map((item) => _buildClassItemCard(
                  context, ref, item, activeDayData.date, isDark)),
              const SizedBox(height: 16),
            ],

            // Extra Classes
            if (extraClasses.isNotEmpty) ...[
              _buildSectionHeader(
                  context, 'Extra Classes', Icons.more_time, Colors.blueAccent),
              ...extraClasses.map((item) => _buildClassItemCard(
                  context, ref, item, activeDayData.date, isDark)),
              const SizedBox(height: 16),
            ],

            // Events & Deadlines
            if (events.isNotEmpty) ...[
              _buildSectionHeader(context, 'Events & Deadlines', Icons.event,
                  Colors.purpleAccent),
              ...events.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Academic Tasks
            if (tasks.isNotEmpty) ...[
              _buildSectionHeader(context, 'Tasks & Submissions',
                  Icons.task_alt, Colors.orange),
              ...tasks.map((item) => _buildItemTile(context, item, isDark)),
              const SizedBox(height: 16),
            ],

            // Empty state if no items exist on this day
            if (activeDayData.items.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'No classes or events scheduled for this day.',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
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
                  avatar: const Icon(Icons.add_task,
                      size: 16, color: Colors.orange),
                  label: const Text('+ Add Task'),
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) =>
                          AddEditTaskSheet(initialDate: dayData.date),
                    );
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.event,
                      size: 16, color: Colors.purpleAccent),
                  label: const Text('+ Add Event'),
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  onPressed: () => _showAddEventDialog(
                      context, ref, dayData.date, AcademicEventType.EVENT),
                ),
                ActionChip(
                  avatar: const Icon(Icons.add_alarm,
                      size: 16, color: Colors.blueAccent),
                  label: const Text('+ Add Extra Class'),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  onPressed: () async {
                    final saved = await AddExtraClassDialog.show(
                      context,
                      initialDate: dayData.date,
                    );
                    if (saved == true && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.beach_access,
                      size: 16, color: Colors.amber),
                  label: const Text('+ Add Holiday'),
                  backgroundColor: Colors.amber.withOpacity(0.1),
                  onPressed: () =>
                      _showAddHolidayDialog(context, ref, dayData.date),
                ),
                ActionChip(
                  avatar: const Icon(Icons.assignment,
                      size: 16, color: Colors.redAccent),
                  label: const Text('+ Add Exam'),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  onPressed: () => _showAddEventDialog(
                      context, ref, dayData.date, AcademicEventType.EXAM),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
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
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
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

  Widget _buildClassItemCard(
    BuildContext context,
    WidgetRef ref,
    CalendarItem item,
    DateTime classDate,
    bool isDark,
  ) {
    final lateEnabled = ref.watch(isLateAttendanceEnabledProvider);
    final currentStatus = item.status?.toUpperCase() ?? 'UNMARKED';
    final isPresent = currentStatus == 'PRESENT';
    final isAbsent = currentStatus == 'ABSENT';
    final isLate = currentStatus == 'LATE';
    final isCancelled = currentStatus == 'CANCELLED';
    final isUnmarked = !isPresent && !isAbsent && !isLate && !isCancelled;

    Color statusColor;
    String statusLabel;
    if (isPresent) {
      statusColor = const Color(0xFF4CAF50);
      statusLabel = 'PRESENT';
    } else if (isAbsent) {
      statusColor = const Color(0xFFEF5350);
      statusLabel = 'ABSENT';
    } else if (isLate) {
      statusColor = const Color(0xFFFFB300);
      statusLabel = 'LATE';
    } else if (isCancelled) {
      statusColor = const Color(0xFF9E9E9E);
      statusLabel = 'CANCELLED';
    } else {
      statusColor = const Color(0xFF90A4AE);
      statusLabel = 'UNMARKED';
    }

    final hasModified = item.originalStatus != null &&
        item.originalStatus!.toUpperCase() != currentStatus &&
        item.originalStatus!.toUpperCase() != 'UNMARKED';

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161D) : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        decoration: isCancelled
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (item.startTime != null &&
                            item.startTime!.isNotEmpty)
                          item.endTime != null && item.endTime!.isNotEmpty
                              ? '${item.startTime} - ${item.endTime}'
                              : item.startTime!,
                        if (item.room != null && item.room!.isNotEmpty)
                          'Room ${item.room}',
                        if (item.type == CalendarItemType.EXTRA_CLASS)
                          'Extra Class',
                      ].join(' • '),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (hasModified) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Text(
                'Original status: ${item.originalStatus}',
                style: const TextStyle(
                  fontSize: 11.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Action Buttons for Historical Attendance Mutation
          Row(
            children: [
              _buildAttendanceButton(
                label: 'Present',
                isSelected: isPresent,
                activeColor: const Color(0xFF4CAF50),
                onTap: item.subjectId == null
                    ? null
                    : () => _updateAttendance(
                          context,
                          ref,
                          item,
                          classDate,
                          OccurrenceStatus.PRESENT,
                        ),
              ),
              if (lateEnabled) ...[
                const SizedBox(width: 6),
                _buildAttendanceButton(
                  label: 'Late',
                  isSelected: isLate,
                  activeColor: const Color(0xFFFFB300),
                  onTap: item.subjectId == null
                      ? null
                      : () => _updateAttendance(
                            context,
                            ref,
                            item,
                            classDate,
                            OccurrenceStatus.LATE,
                          ),
                ),
              ],
              const SizedBox(width: 6),
              _buildAttendanceButton(
                label: 'Absent',
                isSelected: isAbsent,
                activeColor: const Color(0xFFEF5350),
                onTap: item.subjectId == null
                    ? null
                    : () => _updateAttendance(
                          context,
                          ref,
                          item,
                          classDate,
                          OccurrenceStatus.ABSENT,
                        ),
              ),
              const SizedBox(width: 6),
              _buildAttendanceButton(
                label: 'Cancel',
                isSelected: isCancelled,
                activeColor: const Color(0xFF9E9E9E),
                onTap: item.subjectId == null
                    ? null
                    : () => _updateAttendance(
                          context,
                          ref,
                          item,
                          classDate,
                          OccurrenceStatus.CANCELLED,
                        ),
              ),
              if (!isUnmarked) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Reset to unmarked',
                  icon: const Icon(Icons.undo, size: 16, color: Colors.grey),
                  onPressed: item.subjectId == null
                      ? null
                      : () => _updateAttendance(
                            context,
                            ref,
                            item,
                            classDate,
                            OccurrenceStatus.UPCOMING,
                          ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton({
    required String label,
    required bool isSelected,
    required Color activeColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color:
                isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : Colors.grey.withOpacity(0.3),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? activeColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateAttendance(
    BuildContext context,
    WidgetRef ref,
    CalendarItem item,
    DateTime classDate,
    OccurrenceStatus targetStatus,
  ) async {
    try {
      await ref
          .read(attendanceControllerProvider.notifier)
          .markHistoricalAttendance(
            date: classDate,
            subjectId: item.subjectId!,
            occurrenceId: item.occurrenceId,
            ruleId: item.ruleId,
            startTime: item.startTime ?? '09:00',
            endTime: item.endTime ?? '10:00',
            title: item.title,
            room: item.room,
            targetStatus: targetStatus,
            type: item.type == CalendarItemType.EXTRA_CLASS
                ? OccurrenceType.EXTRA_CLASS
                : OccurrenceType.REGULAR_CLASS,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update attendance: $e')),
        );
      }
    }
  }

  int? _toMinutes(TimeOfDay? time) {
    if (time == null) return null;
    return time.hour * 60 + time.minute;
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref, DateTime date,
      AcademicEventType defaultType) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final startTimeController = TextEditingController(text: '10:00');
    final endTimeController = TextEditingController(text: '11:00');
    AcademicEventType selectedType = defaultType;
    TimeOfDay? startTime = const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay? endTime = const TimeOfDay(hour: 11, minute: 0);
    String? timeError;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(defaultType == AcademicEventType.EXAM
              ? 'Add Exam'
              : 'Add Academic Event'),
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
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          hintText: 'HH:mm',
                          suffixIcon: Icon(Icons.access_time, size: 20),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: dialogCtx,
                            initialTime: startTime ??
                                const TimeOfDay(hour: 10, minute: 0),
                          );
                          if (picked != null) {
                            setState(() {
                              startTime = picked;
                              final hh = picked.hour.toString().padLeft(2, '0');
                              final mm =
                                  picked.minute.toString().padLeft(2, '0');
                              startTimeController.text = '$hh:$mm';
                              final sMin = _toMinutes(startTime);
                              final eMin = _toMinutes(endTime);
                              if (sMin != null &&
                                  eMin != null &&
                                  eMin <= sMin) {
                                timeError = 'End time must be after start time';
                              } else {
                                timeError = null;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endTimeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          hintText: 'HH:mm',
                          suffixIcon: Icon(Icons.access_time, size: 20),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: dialogCtx,
                            initialTime: endTime ??
                                startTime ??
                                const TimeOfDay(hour: 11, minute: 0),
                          );
                          if (picked != null) {
                            setState(() {
                              endTime = picked;
                              final hh = picked.hour.toString().padLeft(2, '0');
                              final mm =
                                  picked.minute.toString().padLeft(2, '0');
                              endTimeController.text = '$hh:$mm';
                              final sMin = _toMinutes(startTime);
                              final eMin = _toMinutes(endTime);
                              if (sMin != null &&
                                  eMin != null &&
                                  eMin <= sMin) {
                                timeError = 'End time must be after start time';
                              } else {
                                timeError = null;
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (timeError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    timeError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<AcademicEventType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Event Type'),
                  items: AcademicEventType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.toShortString())))
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

                final sMin = _toMinutes(startTime);
                final eMin = _toMinutes(endTime);
                if (sMin != null && eMin != null && eMin <= sMin) {
                  setState(() {
                    timeError = 'End time must be after start time';
                  });
                  return;
                }

                await ref
                    .read(academicEventControllerProvider.notifier)
                    .addEvent(
                      title: title,
                      description: descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim(),
                      date: date,
                      startTime: startTimeController.text.trim().isEmpty
                          ? null
                          : startTimeController.text.trim(),
                      endTime: endTimeController.text.trim().isEmpty
                          ? null
                          : endTimeController.text.trim(),
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

  void _showAddHolidayDialog(
      BuildContext context, WidgetRef ref, DateTime date) {
    final titleController = TextEditingController(text: 'Holiday');
    final descController = TextEditingController();

    showDialog<void>(
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

              await ref
                  .read(scheduleExceptionControllerProvider.notifier)
                  .addException(
                    date: date,
                    type: ScheduleExceptionType.HOLIDAY,
                    title: title,
                    description: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
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
}
