import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../controllers/auth_controller.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Student info
  final _formKeyStep1 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // Step 2: Semester info
  final _formKeyStep2 = GlobalKey<FormState>();
  final _semesterNameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Step 3: Attendance Target
  double _requiredAttendanceRate = 75.0;

  bool _initialized = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _semesterNameController.dispose();
    super.dispose();
  }

  void _initUserData() {
    if (_initialized) return;
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _initialized = true;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final theme = Theme.of(context);
    final initialDate = DateTime.now();
    final firstDate = DateTime(initialDate.year - 2);
    final lastDate = DateTime(initialDate.year + 5);

    final selected = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? initialDate) : (_endDate ?? initialDate.add(const Duration(days: 120))),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        final isDark = theme.brightness == Brightness.dark;
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.darkSurface,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    surface: AppColors.lightSurface,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isStart) {
          _startDate = selected;
          // Clear end date if it is before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = selected;
        }
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKeyStep1.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (!_formKeyStep2.currentState!.validate()) return;
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both start and end dates.'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
        return;
      }
      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date must be after start date.'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
        return;
      }
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishSetup() async {
    try {
      await ref.read(authControllerProvider.notifier).completeOnboarding(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            semesterName: _semesterNameController.text.trim(),
            startDate: _startDate!,
            endDate: _endDate!,
            requiredAttendanceRate: _requiredAttendanceRate,
          );
      // Go router dynamic redirect will push to dashboard.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Onboarding failed: ${e.toString()}'),
            backgroundColor: AppColors.attendanceLow,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    _initUserData();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Setup Your Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: List.generate(4, (index) {
                  final isActive = index <= _currentStep;
                  final isCurrent = index == _currentStep;
                  return Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? AppColors.primary
                                : (isActive ? AppColors.primary.withOpacity(0.4) : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                            border: Border.all(
                              color: isActive ? AppColors.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.black : (isDark ? Colors.white : Colors.black),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (index < 3)
                          Expanded(
                            child: Container(
                              height: 2.0,
                              color: index < _currentStep
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(theme, isDark),
                  _buildStep2(theme, isDark),
                  _buildStep3(theme, isDark),
                  _buildStep4(theme, isDark),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _prevStep,
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: _currentStep == 3 ? _finishSetup : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'Finish Setup' : 'Continue',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.badge_outlined, size: 48.0, color: AppColors.primary),
            const SizedBox(height: 16.0),
            Text(
              'Student Information',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 22.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Please confirm your academic profile details.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32.0),
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Academic Name',
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.calendar_month_outlined, size: 48.0, color: AppColors.primary),
            const SizedBox(height: 16.0),
            Text(
              'Create First Semester',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 22.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Define the date parameters of your active semester.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 32.0),
            TextFormField(
              controller: _semesterNameController,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Semester Name (e.g. Fall 2026)',
                prefixIcon: const Icon(Icons.school_outlined, color: AppColors.primary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a semester name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(_startDate)),
                              const Icon(Icons.calendar_today, size: 18.0, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDate(_endDate)),
                              const Icon(Icons.calendar_today, size: 18.0, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.track_changes_outlined, size: 48.0, color: AppColors.primary),
          const SizedBox(height: 16.0),
          Text(
            'Attendance Target',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 22.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Set your minimum required attendance percentage.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 48.0),
          Center(
            child: Column(
              children: [
                Text(
                  '${_requiredAttendanceRate.round()}%',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 64.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: _requiredAttendanceRate >= 75.0
                        ? AppColors.attendanceHigh.withOpacity(0.1)
                        : AppColors.attendanceLow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    _requiredAttendanceRate >= 75.0 ? 'Safe Baseline' : 'Warning: Below standard threshold',
                    style: TextStyle(
                      color: _requiredAttendanceRate >= 75.0 ? AppColors.primary : AppColors.attendanceLow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48.0),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            child: Slider(
              value: _requiredAttendanceRate,
              min: 50.0,
              max: 100.0,
              divisions: 50,
              label: '${_requiredAttendanceRate.round()}%',
              onChanged: (value) {
                setState(() => _requiredAttendanceRate = value);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('50%'),
                Text('75% (Default)'),
                Text('100%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 48.0, color: AppColors.primary),
          const SizedBox(height: 16.0),
          Text(
            'Confirm Setup',
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 22.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Review your configurations before finalizing setup.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 32.0),

          // Summary Card
          Card(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildSummaryItem('Name', _nameController.text, Icons.person_outline),
                  const Divider(),
                  _buildSummaryItem('Email', _emailController.text, Icons.email_outlined),
                  const Divider(),
                  _buildSummaryItem('Semester', _semesterNameController.text, Icons.school_outlined),
                  const Divider(),
                  _buildSummaryItem('Timeline', '${_formatDate(_startDate)} to ${_formatDate(_endDate)}', Icons.date_range_outlined),
                  const Divider(),
                  _buildSummaryItem('Target Attendance', '${_requiredAttendanceRate.round()}%', Icons.track_changes_outlined),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20.0, color: AppColors.primary),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
