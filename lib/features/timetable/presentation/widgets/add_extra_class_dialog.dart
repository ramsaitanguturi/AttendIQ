import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';

class AddExtraClassDialog extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const AddExtraClassDialog({
    super.key,
    this.initialDate,
  });

  static Future<bool?> show(BuildContext context, {DateTime? initialDate}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AddExtraClassDialog(initialDate: initialDate),
    );
  }

  @override
  ConsumerState<AddExtraClassDialog> createState() => _AddExtraClassDialogState();
}

class _AddExtraClassDialogState extends ConsumerState<AddExtraClassDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  Subject? _selectedSubject;
  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 15, minute: 0);
  final TextEditingController _reasonController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // Auto bump end time if before start time
        if (_endTime.hour < _startTime.hour ||
            (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
          _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: _startTime.minute);
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject for the extra class')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final startStr = _formatTimeOfDay(_startTime);
      final endStr = _formatTimeOfDay(_endTime);

      await ref.read(attendanceControllerProvider.notifier).addExtraClass(
            date: _selectedDate,
            subjectId: _selectedSubject!.id!,
            subjectTitle: _selectedSubject!.name,
            startTime: startStr,
            endTime: endStr,
            reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save extra class: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjectsAsync = ref.watch(subjectListControllerProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      title: const Row(
        children: [
          Icon(Icons.add_task, color: AppColors.primary),
          SizedBox(width: 10),
          Text(
            'Add Extra Class',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker tile
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEE, d MMM yyyy').format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Subject selection
              subjectsAsync.when(
                data: (subjects) {
                  if (subjects.isEmpty) {
                    return const Text(
                      'No subjects available. Please create a subject first.',
                      style: TextStyle(color: Colors.red),
                    );
                  }
                  return DropdownButtonFormField<Subject>(
                    value: _selectedSubject,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: const Icon(Icons.book_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: subjects.map((sub) {
                      return DropdownMenuItem<Subject>(
                        value: sub,
                        child: Text(
                          '${sub.name} (${sub.code})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSubject = val;
                      });
                    },
                    validator: (val) => val == null ? 'Required' : null,
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => Text('Error loading subjects: $err'),
              ),
              const SizedBox(height: 16),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickStartTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Time', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimeOfDay(_startTime),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickEndTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Time', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimeOfDay(_endTime),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reason (optional)
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason / Notes (Optional)',
                  hintText: 'e.g., Make-up lecture for lab',
                  prefixIcon: const Icon(Icons.notes, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : const Text('Save Extra Class', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
