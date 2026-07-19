import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subject.dart';
import '../controllers/subject_controller.dart';
import '../../../timetable/domain/entities/weekly_schedule_rule.dart';
import '../../../timetable/presentation/controllers/timetable_controller.dart';
import '../../../../core/theme/colors.dart';

class _ScheduleSlotInput {
  int dayOfWeek; // 1 = Monday, 7 = Sunday
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final TextEditingController roomController;
  SubjectType type;
  int? ruleId;

  _ScheduleSlotInput({
    required this.dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
    this.type = SubjectType.THEORY,
    this.ruleId,
  })  : startTimeController = TextEditingController(text: startTime),
        endTimeController = TextEditingController(text: endTime),
        roomController = TextEditingController(text: room ?? '');

  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    roomController.dispose();
  }
}

class AddEditSubjectDialog extends ConsumerStatefulWidget {
  final Subject? existingSubject;

  const AddEditSubjectDialog({
    super.key,
    this.existingSubject,
  });

  static Future<void> show(BuildContext context, {Subject? existingSubject}) async {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddEditSubjectDialog(existingSubject: existingSubject),
      ),
    );
  }

  @override
  ConsumerState<AddEditSubjectDialog> createState() => _AddEditSubjectDialogState();
}

class _AddEditSubjectDialogState extends ConsumerState<AddEditSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _facultyController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  final _attendanceTargetController = TextEditingController(text: '75.0');

  final List<_ScheduleSlotInput> _slots = [];

  SubjectType _selectedType = SubjectType.THEORY;
  String _selectedColor = '#4ECDC4';
  bool _isLoading = false;

  static const List<String> _colorPalette = [
    '#4ECDC4', // Teal / Turquoise
    '#FF6B6B', // Coral Red
    '#45B7D1', // Sky Blue
    '#FFE66D', // Warm Yellow
    '#9B59B6', // Purple
    '#3498DB', // Royal Blue
    '#00E676', // Bright Green
    '#FF9800', // Amber
    '#EC407A', // Pink
    '#78909C', // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingSubject != null) {
      final s = widget.existingSubject!;
      _nameController.text = s.name;
      _codeController.text = s.code;
      _facultyController.text = s.faculty ?? '';
      _creditsController.text = s.credits.toString();
      _attendanceTargetController.text = s.attendanceTarget.toString();
      _selectedType = s.type;
      _selectedColor = s.color;
      _loadExistingScheduleRules(s.id!);
    } else {
      _slots.add(
        _ScheduleSlotInput(
          dayOfWeek: 1, // Monday
          startTime: '09:00',
          endTime: '10:00',
          type: _selectedType,
        ),
      );
    }
  }

  Future<void> _loadExistingScheduleRules(int subjectId) async {
    final repo = ref.read(weeklyScheduleRuleRepositoryProvider);
    final rules = await repo.getRulesForSubject(subjectId);
    if (mounted) {
      setState(() {
        for (final s in _slots) {
          s.dispose();
        }
        _slots.clear();
        if (rules.isNotEmpty) {
          for (final r in rules) {
            if (r.isActive) {
              _slots.add(
                _ScheduleSlotInput(
                  dayOfWeek: r.dayOfWeek,
                  startTime: r.startTime,
                  endTime: r.endTime,
                  room: r.room,
                  type: r.type,
                  ruleId: r.id,
                ),
              );
            }
          }
        }
        if (_slots.isEmpty) {
          _slots.add(
            _ScheduleSlotInput(
              dayOfWeek: 1,
              startTime: '09:00',
              endTime: '10:00',
              type: _selectedType,
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _facultyController.dispose();
    _creditsController.dispose();
    _attendanceTargetController.dispose();
    for (final s in _slots) {
      s.dispose();
    }
    super.dispose();
  }

  Color _parseHex(String hex) {
    try {
      var h = hex.replaceAll('#', '');
      if (h.length == 6) h = 'FF$h';
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
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

  void _addSlot() {
    setState(() {
      int nextDay = 1;
      if (_slots.isNotEmpty) {
        nextDay = (_slots.last.dayOfWeek % 7) + 1;
      }
      _slots.add(
        _ScheduleSlotInput(
          dayOfWeek: nextDay,
          startTime: '10:00',
          endTime: '11:00',
          type: _selectedType,
        ),
      );
    });
  }

  void _removeSlot(int index) {
    if (_slots.length <= 1) return;
    setState(() {
      final removed = _slots.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one weekly schedule slot.')),
      );
      return;
    }

    for (int i = 0; i < _slots.length; i++) {
      final slot = _slots[i];
      final start = slot.startTimeController.text.trim();
      final end = slot.endTimeController.text.trim();
      if (start.compareTo(end) >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Slot ${i + 1}: End time ($end) must be after start time ($start).'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(subjectListControllerProvider.notifier);
      final credits = int.tryParse(_creditsController.text.trim()) ?? 3;
      final target = double.tryParse(_attendanceTargetController.text.trim()) ?? 75.0;

      int subjectId;

      if (widget.existingSubject != null) {
        final updated = widget.existingSubject!.copyWith(
          name: _nameController.text.trim(),
          code: _codeController.text.trim().toUpperCase(),
          faculty: _facultyController.text.trim().isEmpty ? null : _facultyController.text.trim(),
          credits: credits,
          attendanceTarget: target,
          color: _selectedColor,
          type: _selectedType,
          updatedAt: DateTime.now(),
        );
        await notifier.updateSubjectDetails(updated);
        subjectId = widget.existingSubject!.id!;
      } else {
        await notifier.addSubject(
          name: _nameController.text.trim(),
          code: _codeController.text.trim().toUpperCase(),
          faculty: _facultyController.text.trim().isEmpty ? null : _facultyController.text.trim(),
          credits: credits,
          attendanceTarget: target,
          color: _selectedColor,
          type: _selectedType,
        );
        final subjects = await ref.read(subjectListControllerProvider.future);
        final created = subjects.firstWhere((s) => s.code == _codeController.text.trim().toUpperCase());
        subjectId = created.id!;
      }

      // Replace schedule rules for subject
      final ruleRepo = ref.read(weeklyScheduleRuleRepositoryProvider);
      await ruleRepo.deleteRulesForSubject(subjectId);

      final now = DateTime.now().toUtc();
      final newRules = _slots.map((slot) {
        return WeeklyScheduleRule(
          subjectId: subjectId,
          dayOfWeek: slot.dayOfWeek,
          startTime: slot.startTimeController.text.trim(),
          endTime: slot.endTimeController.text.trim(),
          room: slot.roomController.text.trim().isEmpty ? null : slot.roomController.text.trim(),
          faculty: _facultyController.text.trim().isEmpty ? null : _facultyController.text.trim(),
          type: slot.type,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

      await ruleRepo.saveRules(newRules);
      ref.invalidate(weeklyScheduleRuleListControllerProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingSubject != null
                  ? 'Subject and timetable updated successfully'
                  : 'Subject and timetable created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save subject: $e'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existingSubject != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                isEdit ? 'Edit Subject Schedule' : 'Register New Subject Schedule',
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Subject Code *',
                        hintText: 'e.g. CS101',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Subject Name *',
                        hintText: 'e.g. Data Structures',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _facultyController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Faculty / Instructor (Optional)',
                  hintText: 'e.g. Dr. Alan Turing',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _creditsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Credits',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        final n = int.tryParse(val ?? '');
                        if (n == null || n < 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: TextFormField(
                      controller: _attendanceTargetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Target %',
                        suffixText: '%',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        final n = double.tryParse(val ?? '');
                        if (n == null || n < 0 || n > 100) return 'Invalid %';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<SubjectType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Default Subject Type',
                  border: OutlineInputBorder(),
                ),
                items: SubjectType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t == SubjectType.THEORY ? 'Theory Class' : 'Lab / Practical'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 20.0),

              // Weekly Schedule Slots Builder Header
              const Text(
                'Weekly Schedule',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12.0),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _slots.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  return Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Slot ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                            ),
                            if (_slots.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.attendanceLow, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _removeSlot(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        DropdownButtonFormField<int>(
                          value: slot.dayOfWeek,
                          decoration: const InputDecoration(
                            labelText: 'Day',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('Monday')),
                            DropdownMenuItem(value: 2, child: Text('Tuesday')),
                            DropdownMenuItem(value: 3, child: Text('Wednesday')),
                            DropdownMenuItem(value: 4, child: Text('Thursday')),
                            DropdownMenuItem(value: 5, child: Text('Friday')),
                            DropdownMenuItem(value: 6, child: Text('Saturday')),
                            DropdownMenuItem(value: 7, child: Text('Sunday')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => slot.dayOfWeek = val);
                          },
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: slot.startTimeController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Start',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.access_time, size: 18),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onTap: () => _selectTime(slot.startTimeController),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: TextFormField(
                                controller: slot.endTimeController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'End',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.access_time, size: 18),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onTap: () => _selectTime(slot.endTimeController),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: slot.roomController,
                                decoration: const InputDecoration(
                                  labelText: 'Room (Optional)',
                                  hintText: 'e.g. Room A203',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<SubjectType>(
                                value: slot.type,
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: SubjectType.THEORY, child: Text('Theory')),
                                  DropdownMenuItem(value: SubjectType.LAB, child: Text('Lab')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => slot.type = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10.0),
              OutlinedButton.icon(
                onPressed: _addSlot,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('+ Add Another Time Slot', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20.0),
              const Text(
                'Color Label',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorPalette.map((hex) {
                  final isSelected = _selectedColor == hex;
                  final c = _parseHex(hex);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: c.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                      )
                    : Text(
                        isEdit ? 'Save Subject' : 'Save Subject',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }
}
