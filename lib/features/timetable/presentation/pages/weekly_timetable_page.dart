import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../../subject/presentation/widgets/add_edit_subject_dialog.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../domain/entities/daily_schedule_occurrence.dart';
import '../../domain/entities/schedule_exception.dart';
import '../controllers/academic_calendar_controller.dart';
import '../controllers/timetable_controller.dart';
import '../controllers/weekly_schedule_view_controller.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../../../core/theme/colors.dart';
import '../../data/utils/occurrence_identity.dart';
import '../widgets/date_details_bottom_sheet.dart';
import '../widgets/semester_weekly_calendar_view.dart';
import '../widgets/add_extra_class_dialog.dart';

class WeeklyTimetablePage extends ConsumerStatefulWidget {
  const WeeklyTimetablePage({super.key});

  @override
  ConsumerState<WeeklyTimetablePage> createState() =>
      _WeeklyTimetablePageState();
}

class _WeeklyTimetablePageState extends ConsumerState<WeeklyTimetablePage> {
  @override
  Widget build(BuildContext context) {
    final semesterAsync = ref.watch(activeSemesterProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSemester = semesterAsync.valueOrNull;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Schedule',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            if (activeSemester != null)
              Text(
                activeSemester.name,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pick Date & Edit Attendance',
            icon: const Icon(Icons.edit_calendar_rounded),
            onPressed: () => _pickAndJumpToDate(context),
          ),
          IconButton(
            tooltip: 'Add Extra Class',
            icon: const Icon(Icons.add_task),
            onPressed: () => AddExtraClassDialog.show(context),
          ),
          IconButton(
            tooltip: 'Add Subject',
            icon: const Icon(Icons.library_add_outlined),
            onPressed: () => AddEditSubjectDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
            bottom: 110.0,
          ),
          child: SemesterWeeklyCalendarView(
            onSlotTap: (slot) => _handleSlotTap(context, slot),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            final subjects =
                ref.read(subjectListControllerProvider).valueOrNull ?? [];
            if (subjects.isEmpty) {
              _showNoSubjectsAlert(context);
            } else {
              AddExtraClassDialog.show(context);
            }
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text(
            'Add Class',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndJumpToDate(BuildContext context) async {
    final activeSemester = ref.read(activeSemesterProvider).valueOrNull;
    final now = DateTime.now();
    final firstDate =
        activeSemester?.startDate ?? now.subtract(const Duration(days: 365));
    final lastDate =
        activeSemester?.endDate ?? now.add(const Duration(days: 365));

    final initialDate = (now.isAfter(firstDate) && now.isBefore(lastDate))
        ? now
        : (now.isAfter(lastDate) ? lastDate : firstDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'SELECT DATE TO VIEW/EDIT ATTENDANCE',
    );

    if (picked == null || !context.mounted) return;

    ref.read(selectedMonthProvider.notifier).state =
        DateTime(picked.year, picked.month, 1);

    final calendarDays =
        ref.read(monthlyCalendarDataProvider).valueOrNull ?? [];
    CalendarDayData? targetDayData = calendarDays.firstWhereOrNull(
      (d) =>
          d.date.year == picked.year &&
          d.date.month == picked.month &&
          d.date.day == picked.day,
    );

    targetDayData ??= CalendarDayData(
      date: picked,
      items: const [],
      isCurrentMonth: true,
      isToday: picked.year == now.year &&
          picked.month == now.month &&
          picked.day == now.day,
      isInSemesterRange: true,
      hasRegularClass: false,
      hasExam: false,
      hasTask: false,
      hasHoliday: false,
      hasExtraClass: false,
      hasEvent: false,
    );

    if (context.mounted) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DateDetailsBottomSheet(dayData: targetDayData!),
      );
    }
  }

  void _handleSlotTap(BuildContext context, ScheduleClassSlot slot) async {
    final subjects = ref.read(subjectListControllerProvider).valueOrNull ?? [];
    final subject = subjects.where((s) => s.id == slot.subjectId).firstOrNull;
    if (subject == null) return;

    final lateEnabled = ref.read(isLateAttendanceEnabledProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        final currentStatus = slot.status.toUpperCase();
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${slot.code} - ${slot.title}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${slot.startTime} – ${slot.endTime}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  // Quick Attendance Status & Actions Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x28E2E8F0)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Attendance Status',
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                currentStatus,
                                style: const TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF4CAF50),
                                  side: BorderSide(
                                    color: currentStatus == 'PRESENT'
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey.withOpacity(0.3),
                                    width: currentStatus == 'PRESENT' ? 2 : 1,
                                  ),
                                  backgroundColor: currentStatus == 'PRESENT'
                                      ? const Color(0xFF4CAF50)
                                          .withOpacity(0.15)
                                      : null,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _markAttendance(
                                    context,
                                    slot,
                                    OccurrenceStatus.PRESENT,
                                    subject.name,
                                  );
                                },
                                child: const Text(
                                  'Present',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (lateEnabled) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFFB300),
                                    side: BorderSide(
                                      color: currentStatus == 'LATE'
                                          ? const Color(0xFFFFB300)
                                          : Colors.grey.withOpacity(0.3),
                                      width: currentStatus == 'LATE' ? 2 : 1,
                                    ),
                                    backgroundColor: currentStatus == 'LATE'
                                        ? const Color(0xFFFFB300)
                                            .withOpacity(0.15)
                                        : null,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await _markAttendance(
                                      context,
                                      slot,
                                      OccurrenceStatus.LATE,
                                      subject.name,
                                    );
                                  },
                                  child: const Text(
                                    'Late',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFEF5350),
                                  side: BorderSide(
                                    color: currentStatus == 'ABSENT'
                                        ? const Color(0xFFEF5350)
                                        : Colors.grey.withOpacity(0.3),
                                    width: currentStatus == 'ABSENT' ? 2 : 1,
                                  ),
                                  backgroundColor: currentStatus == 'ABSENT'
                                      ? const Color(0xFFEF5350)
                                          .withOpacity(0.15)
                                      : null,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _markAttendance(
                                    context,
                                    slot,
                                    OccurrenceStatus.ABSENT,
                                    subject.name,
                                  );
                                },
                                child: const Text(
                                  'Absent',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF9E9E9E),
                                  side: BorderSide(
                                    color: currentStatus == 'CANCELLED'
                                        ? const Color(0xFF9E9E9E)
                                        : Colors.grey.withOpacity(0.3),
                                    width: currentStatus == 'CANCELLED' ? 2 : 1,
                                  ),
                                  backgroundColor: currentStatus == 'CANCELLED'
                                      ? const Color(0xFF9E9E9E)
                                          .withOpacity(0.15)
                                      : null,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _markAttendance(
                                    context,
                                    slot,
                                    OccurrenceStatus.CANCELLED,
                                    subject.name,
                                  );
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.event_busy_outlined,
                        color: Colors.orange),
                    title: const Text('Edit this occurrence only'),
                    subtitle: const Text(
                        'Remove or set exception for this date without changing weekly rule'),
                    onTap: () {
                      Navigator.pop(context);
                      final occurrenceDate = slot.date != null
                          ? normalizeUtcDate(slot.date!)
                          : normalizeUtcDate(DateTime.now());
                      _showOccurrenceExceptionDialog(
                        context: context,
                        subject: subject,
                        date: occurrenceDate,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined,
                        color: AppColors.primary),
                    title: const Text('Edit entire subject schedule'),
                    subtitle:
                        const Text('Modify weekly recurring days and times'),
                    onTap: () {
                      Navigator.pop(context);
                      AddEditSubjectDialog.show(context,
                          existingSubject: subject);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline,
                        color: AppColors.attendanceLow),
                    title: const Text('Delete Class Slot',
                        style: TextStyle(color: AppColors.attendanceLow)),
                    onTap: () async {
                      Navigator.pop(context);
                      if (slot.type == ScheduleSlotType.classSlot) {
                        final targetRuleId = slot.ruleId ?? slot.id;
                        if (targetRuleId > 0) {
                          await ref
                              .read(weeklyScheduleRuleListControllerProvider
                                  .notifier)
                              .removeRule(targetRuleId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Class slot deleted.')),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _markAttendance(
    BuildContext context,
    ScheduleClassSlot slot,
    OccurrenceStatus targetStatus,
    String subjectName,
  ) async {
    try {
      final occurrenceDate = slot.date != null
          ? normalizeUtcDate(slot.date!)
          : normalizeUtcDate(DateTime.now());

      await ref
          .read(attendanceControllerProvider.notifier)
          .markHistoricalAttendance(
            date: occurrenceDate,
            subjectId: slot.subjectId ?? 0,
            occurrenceId: slot.occurrenceId,
            ruleId: slot.ruleId,
            startTime: slot.startTime,
            endTime: slot.endTime,
            title: slot.title,
            room: slot.room,
            targetStatus: targetStatus,
            type: slot.status.contains('EXTRA')
                ? OccurrenceType.EXTRA_CLASS
                : OccurrenceType.REGULAR_CLASS,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Marked $subjectName as ${targetStatus.toShortString()}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update attendance: $e')),
        );
      }
    }
  }

  void _showOccurrenceExceptionDialog({
    required BuildContext context,
    required Subject subject,
    required DateTime date,
  }) {
    ScheduleExceptionType selectedType = ScheduleExceptionType.CANCELLED_CLASS;
    final titleController =
        TextEditingController(text: '${subject.code} Class Cancelled');
    final descController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Date Exception'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${date.day}/${date.month}/${date.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ScheduleExceptionType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Exception Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: ScheduleExceptionType.CANCELLED_CLASS,
                        child: Text('Cancel Class for this Date'),
                      ),
                      DropdownMenuItem(
                        value: ScheduleExceptionType.EXAM,
                        child: Text('Exam for this Date'),
                      ),
                      DropdownMenuItem(
                        value: ScheduleExceptionType.HOLIDAY,
                        child: Text('Holiday (Remove all classes)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedType = val;
                          if (val == ScheduleExceptionType.CANCELLED_CLASS) {
                            titleController.text =
                                '${subject.code} Class Cancelled';
                          } else if (val == ScheduleExceptionType.EXAM) {
                            titleController.text = '${subject.code} Exam';
                          } else if (val == ScheduleExceptionType.HOLIDAY) {
                            titleController.text = 'Holiday';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description / Reason (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref
                        .read(scheduleExceptionControllerProvider.notifier)
                        .addException(
                          date: normalizeUtcDate(date),
                          subjectId:
                              selectedType == ScheduleExceptionType.HOLIDAY
                                  ? null
                                  : subject.id,
                          type: selectedType,
                          title: titleController.text.trim(),
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Date exception saved successfully.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: const Text('Save Exception',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Alert when no subjects exist: opens AddEditSubjectDialog
  void _showNoSubjectsAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Subject Registration Required'),
          content: const Text(
            'You have no registered subjects for this semester. Please register at least one subject to create your timetable.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                AddEditSubjectDialog.show(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Register Subject',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
