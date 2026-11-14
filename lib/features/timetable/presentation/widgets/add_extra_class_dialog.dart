import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/glass/glass_theme_tokens.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';
import '../../../semester/domain/entities/semester.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../data/utils/occurrence_identity.dart';

class AddExtraClassDialog extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final int? initialSubjectId;
  final Subject? initialSubject;
  final AttendanceStatus? initialStatus;
  final bool lockSubject;

  const AddExtraClassDialog({
    super.key,
    this.initialDate,
    this.initialSubjectId,
    this.initialSubject,
    this.initialStatus,
    this.lockSubject = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    DateTime? initialDate,
    int? initialSubjectId,
    Subject? initialSubject,
    AttendanceStatus? initialStatus,
    bool lockSubject = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AddExtraClassDialog(
        initialDate: initialDate,
        initialSubjectId: initialSubjectId,
        initialSubject: initialSubject,
        initialStatus: initialStatus,
        lockSubject: lockSubject,
      ),
    );
  }

  @override
  ConsumerState<AddExtraClassDialog> createState() =>
      _AddExtraClassDialogState();
}

class _AddExtraClassDialogState extends ConsumerState<AddExtraClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();

  late DateTime _selectedDate;
  int? _selectedSubjectId;
  Subject? _selectedSubject;
  AttendanceStatus? _selectedStatus;

  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 15, minute: 0);

  bool _isSaving = false;
  bool _isLoadingSemester = false;
  int? _resolvingSubjectId;
  Semester? _resolvedSemester;
  String? _semesterError;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    final rawDate = widget.initialDate ?? DateTime.now();
    _selectedDate = DateTime(rawDate.year, rawDate.month, rawDate.day);
    _selectedSubject = widget.initialSubject;
    _selectedSubjectId = widget.initialSubjectId ?? widget.initialSubject?.id;
    _selectedStatus = _normalizeInitialStatus(widget.initialStatus);

    if (_selectedSubject != null) {
      _isLoadingSemester = true;
      _resolvingSubjectId = _selectedSubject!.id;
      Future.microtask(() => _resolveSubjectAndSemester(_selectedSubject!));
    } else if (_selectedSubjectId != null) {
      _isLoadingSemester = true;
      _resolvingSubjectId = _selectedSubjectId;
      Future.microtask(() => _resolveBySubjectId(_selectedSubjectId!));
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  static AttendanceStatus? _normalizeInitialStatus(AttendanceStatus? status) {
    if (status == null) return null;
    switch (status) {
      case AttendanceStatus.present:
      case AttendanceStatus.extraPresent:
        return AttendanceStatus.extraPresent;
      case AttendanceStatus.absent:
      case AttendanceStatus.extraAbsent:
        return AttendanceStatus.extraAbsent;
      case AttendanceStatus.cancelled:
        return null;
      case AttendanceStatus.late:
        return AttendanceStatus.late;
    }
  }

  Future<void> _resolveBySubjectId(int subjectId) async {
    try {
      final subject =
          await ref.read(subjectRepositoryProvider).getSubjectById(subjectId);
      if (!mounted || _selectedSubjectId != subjectId) return;
      if (subject == null || subject.isDeleted) {
        setState(() {
          _isLoadingSemester = false;
          _resolvedSemester = null;
          _semesterError =
              'Selected subject was not found or has been deleted.';
        });
        return;
      }
      await _resolveSubjectAndSemester(subject);
    } catch (e) {
      if (!mounted || _selectedSubjectId != subjectId) return;
      setState(() {
        _isLoadingSemester = false;
        _resolvedSemester = null;
        _semesterError = 'Failed to load subject details: $e';
      });
    }
  }

  Future<void> _resolveSubjectAndSemester(Subject subject) async {
    if (!mounted) return;
    final subjectId = subject.id;
    if (subjectId == null || subjectId <= 0) {
      setState(() {
        _isLoadingSemester = false;
        _resolvedSemester = null;
        _semesterError = 'Selected subject has an invalid ID.';
      });
      return;
    }

    setState(() {
      _selectedSubject = subject;
      _selectedSubjectId = subjectId;
      _resolvingSubjectId = subjectId;
      _isLoadingSemester = true;
      _resolvedSemester = null;
      _semesterError = null;
      _submitError = null;
    });

    try {
      final freshSubject =
          await ref.read(subjectRepositoryProvider).getSubjectById(subjectId);
      if (!mounted || _resolvingSubjectId != subjectId) return;
      if (freshSubject == null || freshSubject.isDeleted) {
        setState(() {
          _isLoadingSemester = false;
          _resolvedSemester = null;
          _semesterError =
              'Selected subject was not found or has been deleted.';
        });
        return;
      }

      final semester = await ref
          .read(semesterRepositoryProvider)
          .getSemesterById(freshSubject.semesterId);
      if (!mounted || _resolvingSubjectId != subjectId) return;

      if (semester == null) {
        setState(() {
          _selectedSubject = freshSubject;
          _isLoadingSemester = false;
          _resolvedSemester = null;
          _semesterError =
              'Semester for "${freshSubject.name}" was not found or has been deleted.';
        });
        return;
      }

      if (!semester.isActive) {
        setState(() {
          _selectedSubject = freshSubject;
          _isLoadingSemester = false;
          _resolvedSemester = semester;
          _semesterError =
              'Cannot add extra class: "${semester.name}" is ${semester.status.displayName.toLowerCase()}.';
        });
        return;
      }

      final normStart = normalizeUtcDate(semester.startDate);
      final normEnd = normalizeUtcDate(semester.endDate);
      if (!normStart.isBefore(normEnd)) {
        setState(() {
          _selectedSubject = freshSubject;
          _isLoadingSemester = false;
          _resolvedSemester = semester;
          _semesterError =
              'Invalid semester date range for "${semester.name}".';
        });
        return;
      }

      setState(() {
        _selectedSubject = freshSubject;
        _isLoadingSemester = false;
        _resolvedSemester = semester;
        _semesterError = null;
      });
    } catch (e) {
      if (!mounted || _resolvingSubjectId != subjectId) return;
      setState(() {
        _isLoadingSemester = false;
        _resolvedSemester = null;
        _semesterError = 'Failed to resolve subject semester: $e';
      });
    }
  }

  ({DateTime firstDate, DateTime lastDate})? _validSemesterBounds() {
    final sem = _resolvedSemester;
    if (sem == null || !sem.isActive || _semesterError != null) {
      return null;
    }
    final normStart = normalizeUtcDate(sem.startDate);
    final normEnd = normalizeUtcDate(sem.endDate);
    if (!normStart.isBefore(normEnd)) {
      return null;
    }
    return (
      firstDate: DateTime(normStart.year, normStart.month, normStart.day),
      lastDate: DateTime(normEnd.year, normEnd.month, normEnd.day),
    );
  }

  String? _selectedDateRangeError() {
    if (_selectedSubject == null || _isLoadingSemester) return null;
    if (_semesterError != null) return _semesterError;
    final bounds = _validSemesterBounds();
    if (bounds == null) {
      return 'Unable to validate semester date range for this subject.';
    }
    final selDay =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    if (selDay.isBefore(bounds.firstDate) || selDay.isAfter(bounds.lastDate)) {
      return 'Selected date must be between '
          '${DateFormat('d MMM yyyy').format(bounds.firstDate)} and '
          '${DateFormat('d MMM yyyy').format(bounds.lastDate)}.';
    }
    return null;
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String? _timeRangeError() {
    if (_toMinutes(_endTime) <= _toMinutes(_startTime)) {
      return 'End time must be after start time.';
    }
    return null;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickDate() async {
    if (_isLoadingSemester) return;
    final bounds = _validSemesterBounds();
    if (bounds == null) {
      setState(() {
        _submitError = _semesterError ??
            'Please select a subject with an active semester first.';
      });
      return;
    }

    var clampedInitial = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    if (clampedInitial.isBefore(bounds.firstDate)) {
      clampedInitial = bounds.firstDate;
    } else if (clampedInitial.isAfter(bounds.lastDate)) {
      clampedInitial = bounds.lastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: bounds.firstDate,
      lastDate: bounds.lastDate,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _submitError = null;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && mounted) {
      setState(() {
        _startTime = picked;
        if (_toMinutes(_endTime) <= _toMinutes(_startTime)) {
          if (_startTime.hour < 23) {
            _endTime = TimeOfDay(
              hour: _startTime.hour + 1,
              minute: _startTime.minute,
            );
          } else {
            _endTime = const TimeOfDay(hour: 23, minute: 59);
          }
        }
        _submitError = null;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && mounted) {
      setState(() {
        _endTime = picked;
        _submitError = null;
      });
    }
  }

  bool get _canSubmit {
    if (_isSaving || _isLoadingSemester) return false;
    if (_selectedSubject == null || _selectedSubjectId == null) return false;
    if (_semesterError != null) return false;
    if (_selectedDateRangeError() != null) return false;
    if (_timeRangeError() != null) return false;
    return true;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedSubject == null || _selectedSubject!.id == null) {
      setState(() {
        _submitError = 'Please select a subject for the extra class.';
      });
      return;
    }
    if (_isLoadingSemester) {
      setState(() {
        _submitError = 'Waiting for subject semester validation...';
      });
      return;
    }

    final semOrDateError = _semesterError ?? _selectedDateRangeError();
    if (semOrDateError != null) {
      setState(() {
        _submitError = semOrDateError;
      });
      return;
    }

    final timeError = _timeRangeError();
    if (timeError != null) {
      setState(() {
        _submitError = timeError;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _submitError = null;
    });

    try {
      final startStr = _formatTimeOfDay(_startTime);
      final endStr = _formatTimeOfDay(_endTime);
      final trimmedReason = _reasonController.text.trim();

      await ref.read(attendanceControllerProvider.notifier).addExtraClass(
            date: _selectedDate,
            subjectId: _selectedSubject!.id!,
            subjectTitle: _selectedSubject!.name,
            startTime: startStr,
            endTime: endStr,
            reason: trimmedReason.isEmpty ? null : trimmedReason,
            initialStatus: _selectedStatus,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      final message =
          e is AppException ? e.message : 'Failed to save extra class: $e';
      if (mounted) {
        setState(() {
          _submitError = message;
        });
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(message)),
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
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final subjectsAsync = ref.watch(subjectListControllerProvider);
    final dateError = _selectedDateRangeError();
    final timeError = _timeRangeError();
    final bounds = _validSemesterBounds();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isGlassy
            ? BorderSide(
                color: isDark
                    ? AppColors.silverBorder
                    : GlassTokens.lightGlassBorder,
              )
            : BorderSide.none,
      ),
      backgroundColor:
          isGlassy ? AppColors.surfaceGlass(isDark) : AppColors.surface(isDark),
      title: Row(
        children: [
          Icon(Icons.add_task, color: AppColors.iconPrimary(isDark)),
          const SizedBox(width: 10),
          const Text(
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
              // Subject selection (or locked subject card from Subject Details)
              if (widget.lockSubject && _selectedSubject != null)
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: const Icon(Icons.book_outlined, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '${_selectedSubject!.name} (${_selectedSubject!.code})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                subjectsAsync.when(
                  data: (subjects) {
                    if (subjects.isEmpty) {
                      return Text(
                        'No subjects available. Please create a subject first.',
                        style:
                            TextStyle(color: AppColors.textSecondary(isDark)),
                      );
                    }
                    final validSelectedId =
                        subjects.any((s) => s.id == _selectedSubjectId)
                            ? _selectedSubjectId
                            : null;
                    return DropdownButtonFormField<int>(
                      value: validSelectedId,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: const Icon(Icons.book_outlined, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: subjects.where((s) => s.id != null).map((sub) {
                        return DropdownMenuItem<int>(
                          value: sub.id!,
                          child: Text(
                            '${sub.name} (${sub.code})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _isSaving
                          ? null
                          : (val) {
                              if (val == null) return;
                              final chosen = subjects
                                  .where((s) => s.id == val)
                                  .firstOrNull;
                              if (chosen != null) {
                                _resolveSubjectAndSemester(chosen);
                              }
                            },
                      validator: (val) => val == null ? 'Required' : null,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => Text(
                    'Error loading subjects: $err',
                    style: TextStyle(color: AppColors.textSecondary(isDark)),
                  ),
                ),

              if (_isLoadingSemester) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Checking subject semester...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ],

              if (_semesterError != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.attendanceLow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.attendanceLow.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    _semesterError!,
                    style: const TextStyle(
                      color: AppColors.attendanceLow,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Date picker tile
              InkWell(
                onTap: (bounds == null || _isLoadingSemester || _isSaving)
                    ? null
                    : _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: dateError != null
                          ? AppColors.attendanceLow
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: bounds == null
                                ? AppColors.iconSecondary(isDark)
                                : (isDark
                                    ? AppColors.primary
                                    : AppColors.gray900),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEE, d MMM yyyy').format(_selectedDate),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: bounds == null
                                  ? AppColors.textSecondary(isDark)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
              if (dateError != null && _semesterError == null) ...[
                const SizedBox(height: 6),
                Text(
                  dateError,
                  style: const TextStyle(
                    color: AppColors.attendanceLow,
                    fontSize: 12,
                  ),
                ),
              ] else if (bounds != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Semester: ${DateFormat('d MMM yyyy').format(bounds.firstDate)} – ${DateFormat('d MMM yyyy').format(bounds.lastDate)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _isSaving ? null : _pickStartTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: timeError != null
                                ? AppColors.attendanceLow
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimeOfDay(_startTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _isSaving ? null : _pickEndTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: timeError != null
                                ? AppColors.attendanceLow
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Time',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimeOfDay(_endTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (timeError != null) ...[
                const SizedBox(height: 6),
                Text(
                  timeError,
                  style: const TextStyle(
                    color: AppColors.attendanceLow,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Attendance Status
              DropdownButtonFormField<AttendanceStatus?>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Attendance Status',
                  prefixIcon: const Icon(Icons.fact_check_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownColor:
                    isDark ? AppColors.darkSurface : AppColors.lightSurface,
                items: const [
                  DropdownMenuItem<AttendanceStatus?>(
                    value: null,
                    child: Text('Scheduled (Upcoming)'),
                  ),
                  DropdownMenuItem<AttendanceStatus?>(
                    value: AttendanceStatus.extraPresent,
                    child: Text('Extra Present'),
                  ),
                  DropdownMenuItem<AttendanceStatus?>(
                    value: AttendanceStatus.extraAbsent,
                    child: Text('Extra Absent'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (val) {
                        setState(() {
                          _selectedStatus = val;
                          _submitError = null;
                        });
                      },
              ),
              const SizedBox(height: 16),

              // Reason (optional)
              TextFormField(
                controller: _reasonController,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'Reason / Notes (Optional)',
                  hintText: 'e.g., Make-up lecture for lab',
                  prefixIcon: const Icon(Icons.notes, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (_submitError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _submitError!,
                  style: const TextStyle(
                    color: AppColors.attendanceLow,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
          onPressed: _canSubmit ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.primary : AppColors.gray900,
            foregroundColor: isDark ? AppColors.gray900 : AppColors.gray100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isSaving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? AppColors.gray900 : AppColors.gray100,
                  ),
                )
              : const Text(
                  'Save Extra Class',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
