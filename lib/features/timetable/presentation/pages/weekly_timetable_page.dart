import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../../subject/presentation/widgets/add_edit_subject_dialog.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../domain/entities/timetable_template.dart';
import '../../domain/entities/schedule_exception.dart';
import '../controllers/timetable_controller.dart';
import '../controllers/weekly_schedule_view_controller.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../../../core/theme/colors.dart';

import '../widgets/semester_weekly_calendar_view.dart';

import '../widgets/add_extra_class_dialog.dart';

class WeeklyTimetablePage extends ConsumerStatefulWidget {
  const WeeklyTimetablePage({super.key});

  @override
  ConsumerState<WeeklyTimetablePage> createState() => _WeeklyTimetablePageState();
}

class _WeeklyTimetablePageState extends ConsumerState<WeeklyTimetablePage> {
  int _selectedWeekdayIndex = 0;

  final List<String> _dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  List<DateTime> _getCurrentWeekDates() {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectListControllerProvider);
    final semesterAsync = ref.watch(activeSemesterProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeSemester = semesterAsync.valueOrNull;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SemesterWeeklyCalendarView(
            onSlotTap: (slot) => _handleSlotTap(context, slot),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final subjects = ref.read(subjectListControllerProvider).valueOrNull ?? [];
          if (subjects.isEmpty) {
            _showNoSubjectsAlert(context);
          } else {
            AddEditSubjectDialog.show(context);
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Add Class',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleSlotTap(BuildContext context, ScheduleClassSlot slot) async {
    final subjects = ref.read(subjectListControllerProvider).valueOrNull ?? [];
    final subject = subjects.where((s) => s.id == slot.subjectId).firstOrNull;
    if (subject == null) return;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  '${slot.startTime} – ${slot.endTime}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.event_busy_outlined, color: Colors.orange),
                  title: const Text('Edit this occurrence only'),
                  subtitle: const Text('Remove or set exception for this date without changing weekly rule'),
                  onTap: () {
                    Navigator.pop(context);
                    _showOccurrenceExceptionDialog(
                      context: context,
                      subject: subject,
                      date: DateTime.now(),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                  title: const Text('Edit entire subject schedule'),
                  subtitle: const Text('Modify weekly recurring days and times'),
                  onTap: () {
                    Navigator.pop(context);
                    AddEditSubjectDialog.show(context, existingSubject: subject);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.attendanceLow),
                  title: const Text('Delete Class Slot', style: TextStyle(color: AppColors.attendanceLow)),
                  onTap: () async {
                    Navigator.pop(context);
                    if (slot.id != 0) {
                      await ref.read(weeklyScheduleRuleListControllerProvider.notifier).removeRule(slot.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Class slot deleted.')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOccurrenceExceptionDialog({
    required BuildContext context,
    required Subject subject,
    required DateTime date,
  }) {
    ScheduleExceptionType selectedType = ScheduleExceptionType.CANCELLED_CLASS;
    final titleController = TextEditingController(text: '${subject.code} Class Cancelled');
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
                            titleController.text = '${subject.code} Class Cancelled';
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
                    await ref.read(scheduleExceptionControllerProvider.notifier).addException(
                          date: date,
                          subjectId: selectedType == ScheduleExceptionType.HOLIDAY ? null : subject.id,
                          type: selectedType,
                          title: titleController.text.trim(),
                          description: descController.text.trim().isEmpty ? null : descController.text.trim(),
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
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Save Exception', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Register Subject', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditTemplateBottomSheet({
    required BuildContext context,
    required List<Subject> subjects,
    required int weekday,
    TimetableTemplate? existingTemplate,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddEditTemplateForm(
            subjects: subjects,
            weekday: weekday,
            existingTemplate: existingTemplate,
          ),
        );
      },
    );
  }
}

class _AddEditTemplateForm extends ConsumerStatefulWidget {
  final List<Subject> subjects;
  final int weekday;
  final TimetableTemplate? existingTemplate;

  const _AddEditTemplateForm({
    required this.subjects,
    required this.weekday,
    this.existingTemplate,
  });

  @override
  ConsumerState<_AddEditTemplateForm> createState() => _AddEditTemplateFormState();
}

class _AddEditTemplateFormState extends ConsumerState<_AddEditTemplateForm> {
  final _formKey = GlobalKey<FormState>();
  late int _selectedSubjectId;
  late int _selectedWeekday;
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _roomController = TextEditingController();
  final _facultyController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _selectedWeekday = widget.weekday;
    if (widget.existingTemplate != null) {
      final t = widget.existingTemplate!;
      _selectedSubjectId = t.subjectId;
      _selectedWeekday = t.weekday;
      _startTimeController.text = t.startTime;
      _endTimeController.text = t.endTime;
      _roomController.text = t.room ?? '';
      _facultyController.text = t.faculty ?? '';
      _notesController.text = t.notes ?? '';
    } else {
      _selectedSubjectId = widget.subjects.first.id!;
      _startTimeController.text = '09:00';
      _endTimeController.text = '10:00';
    }
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _roomController.dispose();
    _facultyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final initialTime = controller.text.split(':');
    final hour = int.parse(initialTime[0]);
    final minute = int.parse(initialTime[1]);

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );

    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$h:$m';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final notifier = ref.read(timetableListControllerProvider.notifier);
      if (widget.existingTemplate != null) {
        final updated = widget.existingTemplate!.copyWith(
          subjectId: _selectedSubjectId,
          weekday: _selectedWeekday,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          room: _roomController.text,
          faculty: _facultyController.text,
          notes: _notesController.text,
          updatedAt: DateTime.now(),
        );
        await notifier.updateTemplateDetails(updated);
      } else {
        await notifier.addTemplate(
          subjectId: _selectedSubjectId,
          weekday: _selectedWeekday,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          room: _roomController.text,
          faculty: _facultyController.text,
          notes: _notesController.text,
        );
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class schedule saved successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Schedule Conflict'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _delete() async {
    if (widget.existingTemplate?.id == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Are you sure you want to remove this class from your timetable?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.attendanceLow),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(timetableListControllerProvider.notifier).removeTemplate(widget.existingTemplate!.id!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class deleted successfully.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existingTemplate != null ? 'Edit Class Slot' : 'Add Class Slot';

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.existingTemplate != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.attendanceLow),
                      onPressed: _delete,
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<int>(
                value: _selectedSubjectId,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                items: widget.subjects.map((sub) {
                  return DropdownMenuItem<int>(
                    value: sub.id,
                    child: Text('${sub.code} - ${sub.name}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSubjectId = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<int>(
                value: _selectedWeekday,
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(7, (i) {
                  return DropdownMenuItem<int>(
                    value: i + 1,
                    child: Text(_days[i]),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedWeekday = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () => _selectTime(_startTimeController),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: () => _selectTime(_endTimeController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Room / Lecture Hall (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _facultyController,
                decoration: const InputDecoration(
                  labelText: 'Instructor / Faculty (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 16.0,
                      ),
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
