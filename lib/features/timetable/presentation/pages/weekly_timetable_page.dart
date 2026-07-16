import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../domain/entities/timetable_template.dart';
import '../controllers/timetable_controller.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../../../core/theme/colors.dart';

class WeeklyTimetablePage extends ConsumerStatefulWidget {
  const WeeklyTimetablePage({super.key});

  @override
  ConsumerState<WeeklyTimetablePage> createState() => _WeeklyTimetablePageState();
}

class _WeeklyTimetablePageState extends ConsumerState<WeeklyTimetablePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
    // Default to today's weekday (1 = Mon, 7 = Sun)
    final initialIndex = (DateTime.now().weekday - 1).clamp(0, 6);
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      var h = hex.replaceAll('#', '');
      if (h.length == 6) {
        h = 'FF$h';
      }
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(timetableListControllerProvider);
    final subjectsAsync = ref.watch(subjectListControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Weekly Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: timetableAsync.when(
        data: (templates) {
          return subjectsAsync.when(
            data: (subjects) {
              return TabBarView(
                controller: _tabController,
                children: List.generate(7, (index) {
                  final weekday = index + 1;
                  final dayTemplates = templates
                      .where((t) => t.weekday == weekday)
                      .toList();
                  
                  // Sort chronologically by start time
                  dayTemplates.sort((a, b) => a.startTime.compareTo(b.startTime));

                  return _buildDayView(
                    context,
                    dayTemplates,
                    subjects,
                    weekday,
                  );
                }),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error loading subjects: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading schedule: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final subjects = ref.read(subjectListControllerProvider).valueOrNull ?? [];
          if (subjects.isEmpty) {
            _showNoSubjectsAlert(context);
          } else {
            _showAddEditTemplateBottomSheet(
              context: context,
              subjects: subjects,
              weekday: _tabController.index + 1,
            );
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildDayView(
    BuildContext context,
    List<TimetableTemplate> templates,
    List<Subject> subjects,
    int weekday,
  ) {
    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 80.0,
              color: Colors.grey,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'No Classes Scheduled',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Enjoy your rest day, or schedule one below!',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final subject = subjects.firstWhere(
          (s) => s.id == template.subjectId,
          orElse: () => Subject(
            semesterId: 0,
            name: 'Unknown Subject',
            code: 'N/A',
            credits: 0,
            attendanceTarget: 75.0,
            color: '#FF5733',
            type: SubjectType.THEORY,
            updatedAt: DateTime.now(),
          ),
        );

        final subjectColor = _parseColor(subject.color);

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              _showAddEditTemplateBottomSheet(
                context: context,
                subjects: subjects,
                weekday: weekday,
                existingTemplate: template,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: subjectColor,
                    width: 6.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: subjectColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                subject.code,
                                style: TextStyle(
                                  color: subjectColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 2.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                subject.type.toShortString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          subject.name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (template.room != null && template.room!.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              const Icon(Icons.room, size: 14.0, color: Colors.grey),
                              const SizedBox(width: 4.0),
                              Text(
                                'Room: ${template.room}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                        if (template.faculty != null && template.faculty!.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 14.0, color: Colors.grey),
                              const SizedBox(width: 4.0),
                              Text(
                                'Faculty: ${template.faculty}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        template.startTime,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_downward, size: 12.0, color: Colors.grey),
                      Text(
                        template.endTime,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNoSubjectsAlert(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Subjects Registered'),
          content: const Text(
            'Please register at least one subject before scheduling classes in your weekly timetable.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // In Phase 2: Subject management UI is stubbed, but we can navigate to subject list.
                // For now, show alert or mock creation.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subject registration is required.'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Add Subject', style: TextStyle(color: Colors.black)),
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
