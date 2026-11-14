import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/entities/semester.dart';
import '../../domain/validators/semester_validator.dart';
import '../controllers/semester_controller.dart';
import '../controllers/semester_management_controller.dart';

class AddEditSemesterDialog extends ConsumerStatefulWidget {
  final Semester? existingSemester;

  const AddEditSemesterDialog({
    super.key,
    this.existingSemester,
  });

  static Future<bool?> show(
    BuildContext context, {
    Semester? existingSemester,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AddEditSemesterDialog(
        existingSemester: existingSemester,
      ),
    );
  }

  @override
  ConsumerState<AddEditSemesterDialog> createState() =>
      _AddEditSemesterDialogState();
}

class _AddEditSemesterDialogState extends ConsumerState<AddEditSemesterDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late DateTime _startDate;
  late DateTime _endDate;
  late double _requiredAttendanceRate;
  late bool _activateImmediately;
  String? _validationError;
  bool _isSaving = false;

  bool get _isEdit => widget.existingSemester != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSemester;
    final now = DateTime.now();
    _nameController = TextEditingController(text: existing?.name ?? '');
    _startDate = existing?.startDate ?? DateTime(now.year, now.month, now.day);
    _endDate = existing?.endDate ??
        DateTime(now.year, now.month, now.day).add(const Duration(days: 120));
    _requiredAttendanceRate = existing?.requiredAttendanceRate ?? 75.0;
    _activateImmediately = existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 5),
      lastDate: DateTime(initial.year + 10),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _validationError = null;
      if (isStart) {
        _startDate = picked;
        if (!SemesterValidator.hasValidDateRange(_startDate, _endDate)) {
          _endDate = _startDate.add(const Duration(days: 120));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final rangeError = SemesterValidator.validateDateRangeMessage(
      _startDate,
      _endDate,
    );
    if (rangeError != null) {
      setState(() => _validationError = rangeError);
      return;
    }

    final existingList =
        ref.read(allSemestersProvider).valueOrNull ?? const <Semester>[];
    final existing = widget.existingSemester;
    final targetStatus = _isEdit
        ? (_activateImmediately ? SemesterStatus.active : existing!.status)
        : (_activateImmediately ? SemesterStatus.active : SemesterStatus.draft);

    final candidate = Semester(
      id: existing?.id,
      localId: existing?.localId,
      name: _nameController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      requiredAttendanceRate: _requiredAttendanceRate,
      status: targetStatus,
    );

    final overlapping = SemesterValidator.findOverlappingSemester(
      startDate: candidate.startDate,
      endDate: candidate.endDate,
      existingSemesters: existingList,
      excludeLocalId: candidate.localId,
    );
    if (overlapping != null) {
      setState(() {
        _validationError = 'Semester dates overlap with "${overlapping.name}" '
            '(${DateFormat('dd/MM/yyyy').format(overlapping.startDate)} – '
            '${DateFormat('dd/MM/yyyy').format(overlapping.endDate)}).';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _validationError = null;
    });

    try {
      final controller =
          ref.read(semesterManagementControllerProvider.notifier);
      if (_isEdit) {
        await controller.updateSemester(candidate);
      } else {
        await controller.createSemester(candidate);
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        setState(() {
          _validationError = e.message;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _validationError = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFmt = DateFormat('dd MMM yyyy');

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _isEdit ? 'Edit Semester' : 'Create Semester',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_validationError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.attendanceLow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.attendanceLow.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.attendanceLow,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: const TextStyle(
                            color: AppColors.attendanceLow,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Semester Name',
                  hintText: 'e.g. Spring 2027',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a semester name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      key: const ValueKey<String>('semester_start_date_picker'),
                      onTap: _isSaving ? null : () => _pickDate(isStart: true),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          dateFmt.format(_startDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      key: const ValueKey<String>('semester_end_date_picker'),
                      onTap: _isSaving ? null : () => _pickDate(isStart: false),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          dateFmt.format(_endDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attendance Target',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '${_requiredAttendanceRate.round()}%',
                    style: TextStyle(
                      color: isDark ? AppColors.primary : AppColors.gray900,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _requiredAttendanceRate,
                min: 50.0,
                max: 100.0,
                divisions: 50,
                activeColor: isDark ? AppColors.primary : AppColors.gray900,
                onChanged: _isSaving
                    ? null
                    : (val) => setState(() => _requiredAttendanceRate = val),
              ),
              if (!_isEdit || widget.existingSemester!.isDraft)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Set as Active Semester',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _activateImmediately
                        ? 'Archives any currently active semester'
                        : 'Save as draft for later activation',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  value: _activateImmediately,
                  activeColor: isDark ? AppColors.primary : AppColors.gray900,
                  onChanged: _isSaving
                      ? null
                      : (val) => setState(() => _activateImmediately = val),
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
            backgroundColor: isDark ? AppColors.primary : AppColors.gray900,
            foregroundColor: isDark ? AppColors.gray900 : AppColors.gray100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSaving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? AppColors.gray900 : AppColors.gray100,
                  ),
                )
              : Text(
                  _isEdit ? 'Save Changes' : 'Create',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
