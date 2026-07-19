import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:attend_iq/core/theme/colors.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import '../../domain/entities/academic_task.dart';
import '../../domain/entities/task_enums.dart';
import '../controllers/task_controller.dart';

class AddEditTaskSheet extends ConsumerStatefulWidget {
  final AcademicTask? taskToEdit;
  final DateTime? initialDate;

  const AddEditTaskSheet({
    super.key,
    this.taskToEdit,
    this.initialDate,
  });

  @override
  ConsumerState<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends ConsumerState<AddEditTaskSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late TaskType _selectedTaskType;
  int? _selectedSubjectId;
  late DateTime _startDate;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late TaskPriority _selectedPriority;
  late TaskReminder _selectedReminder;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    final now = DateTime.now();

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');

    _selectedTaskType = task?.taskType ?? TaskType.ASSIGNMENT;
    _selectedSubjectId = task?.subjectId;

    _startDate = task?.startDate ?? widget.initialDate ?? now;
    _dueDate = task?.dueDate ?? widget.initialDate ?? now.add(const Duration(days: 1));
    _dueTime = task != null
        ? TimeOfDay.fromDateTime(task.dueDate)
        : const TimeOfDay(hour: 23, minute: 59);

    _selectedPriority = task?.priority ?? TaskPriority.MEDIUM;
    _selectedReminder = task?.reminder ?? TaskReminder.DAYS_1;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime get _combinedDueDateTime {
    return DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _dueDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_dueDate.isBefore(_startDate)) {
            _dueDate = _startDate;
          }
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final finalDue = _combinedDueDateTime;

    if (widget.taskToEdit != null) {
      final updated = widget.taskToEdit!.copyWith(
        title: title,
        description: description.isEmpty ? null : description,
        taskType: _selectedTaskType,
        subjectId: _selectedSubjectId,
        startDate: _startDate,
        dueDate: finalDue,
        priority: _selectedPriority,
        reminder: _selectedReminder,
      );
      ref.read(taskListControllerProvider.notifier).updateTask(updated);
    } else {
      ref.read(taskListControllerProvider.notifier).addTask(
            title: title,
            description: description.isEmpty ? null : description,
            taskType: _selectedTaskType,
            subjectId: _selectedSubjectId,
            startDate: _startDate,
            dueDate: finalDue,
            priority: _selectedPriority,
            reminder: _selectedReminder,
          );
    }

    Navigator.of(context).pop();
  }

  void _deleteTask() {
    if (widget.taskToEdit?.id != null) {
      ref.read(taskListControllerProvider.notifier).deleteTask(widget.taskToEdit!.id!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjects = ref.watch(subjectListControllerProvider).valueOrNull ?? [];
    final isEditing = widget.taskToEdit != null;

    return Container(
      padding: EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
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

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'Add Academic Task',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: _deleteTask,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
              const Divider(height: 24),

              // Task Name Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  hintText: 'e.g. Operating Systems Project',
                  prefixIcon: Icon(Icons.task_alt),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category (TaskType) & Linked Subject Row
              Row(
                children: [
                  // Task Type Dropdown
                  Expanded(
                    child: DropdownButtonFormField<TaskType>(
                      value: _selectedTaskType,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: TaskType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTaskType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Subject Dropdown
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _selectedSubjectId,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: Icon(Icons.book),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('None'),
                        ),
                        ...subjects.map(
                          (s) => DropdownMenuItem<int?>(
                            value: s.id,
                            child: Text(s.name, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedSubjectId = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dates Selection Row (Start Date & Deadline Date)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: true),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('MMM d, yyyy').format(_startDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isStart: false),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Deadline Date',
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(
                          DateFormat('MMM d, yyyy').format(_dueDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Due Time & Priority Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDueTime,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _dueTime.format(context),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: TaskPriority.values
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Row(
                                  children: [
                                    Icon(Icons.circle, size: 10, color: p.color),
                                    const SizedBox(width: 6),
                                    Text(p.displayName),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPriority = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reminder Dropdown
              DropdownButtonFormField<TaskReminder>(
                value: _selectedReminder,
                decoration: const InputDecoration(
                  labelText: 'Reminder',
                  prefixIcon: Icon(Icons.notifications_active),
                ),
                items: TaskReminder.values
                    .map((rem) => DropdownMenuItem(
                          value: rem,
                          child: Text(rem.displayName),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReminder = val);
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description / Notes',
                  hintText: 'Optional task details or requirements...',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(isEditing ? 'Save Changes' : 'Create Task'),
                    onPressed: _saveTask,
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
