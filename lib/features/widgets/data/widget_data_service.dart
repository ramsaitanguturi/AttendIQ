import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../domain/widget_models.dart';
import '../../timetable/domain/repositories/weekly_schedule_rule_repository.dart';
import '../../timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import '../../timetable/domain/repositories/schedule_exception_repository.dart';
import '../../timetable/domain/repositories/academic_event_repository.dart';
import '../../timetable/domain/entities/schedule_exception.dart';
import '../../timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../timetable/domain/entities/academic_event.dart';
import '../../academic_planner/domain/repositories/task_repository.dart';
import '../../semester/domain/repositories/semester_repository.dart';
import '../../subject/domain/repositories/subject_repository.dart';
import '../../attendance/domain/repositories/attendance_repository.dart';
import '../../attendance/domain/entities/attendance_record.dart';

// Providers for dependency injection
import '../../timetable/presentation/controllers/timetable_controller.dart';
import '../../academic_planner/presentation/controllers/task_controller.dart';
import '../../semester/presentation/controllers/semester_controller.dart';
import '../../subject/presentation/controllers/subject_controller.dart';
import '../../attendance/presentation/controllers/attendance_controller.dart';

final widgetDataServiceProvider = Provider<WidgetDataService>((ref) {
  final ruleRepo = ref.watch(weeklyScheduleRuleRepositoryProvider);
  final occurrenceRepo = ref.watch(dailyScheduleOccurrenceRepositoryProvider);
  final exceptionRepo = ref.watch(scheduleExceptionRepositoryProvider);
  final eventRepo = ref.watch(academicEventRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  final semesterRepo = ref.watch(semesterRepositoryProvider);
  final subjectRepo = ref.watch(subjectRepositoryProvider);
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);

  return WidgetDataService(
    ruleRepo: ruleRepo,
    occurrenceRepo: occurrenceRepo,
    exceptionRepo: exceptionRepo,
    eventRepo: eventRepo,
    taskRepo: taskRepo,
    semesterRepo: semesterRepo,
    subjectRepo: subjectRepo,
    attendanceRepo: attendanceRepo,
  );
});

class WidgetDataService {
  final WeeklyScheduleRuleRepository ruleRepo;
  final DailyScheduleOccurrenceRepository occurrenceRepo;
  final ScheduleExceptionRepository exceptionRepo;
  final AcademicEventRepository eventRepo;
  final TaskRepository taskRepo;
  final SemesterRepository semesterRepo;
  final SubjectRepository subjectRepo;
  final AttendanceRepository attendanceRepo;

  WidgetDataService({
    required this.ruleRepo,
    required this.occurrenceRepo,
    required this.exceptionRepo,
    required this.eventRepo,
    required this.taskRepo,
    required this.semesterRepo,
    required this.subjectRepo,
    required this.attendanceRepo,
  });

  /// 1. Generate Today's Schedule Widget Data
  Future<TodayWidgetData> generateTodayWidgetData({DateTime? customDate}) async {
    final now = customDate ?? DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final weekday = now.weekday; // 1 = Mon, 7 = Sun
    final dateText = DateFormat('EEEE, d MMMM').format(now);

    // Fetch schedule exceptions for today
    final exceptions = await exceptionRepo.getExceptionsForDate(todayUtc);
    final holidayException = exceptions.where((e) => e.type == ScheduleExceptionType.HOLIDAY).firstOrNull;

    if (holidayException != null) {
      return TodayWidgetData(
        dateText: dateText,
        isHoliday: true,
        holidayTitle: holidayException.title,
        classes: const [],
      );
    }

    final cancelledSubjectIds = exceptions
        .where((e) => e.type == ScheduleExceptionType.CANCELLED_CLASS && e.subjectId != null)
        .map((e) => e.subjectId!)
        .toSet();

    final activeSemester = await semesterRepo.getActiveSemester();
    final semId = activeSemester?.localId;

    final items = <TodayWidgetItem>[];
    final subjectMap = <int, String>{};

    if (semId != null) {
      final subjects = await subjectRepo.getSubjectsBySemester(semId);
      for (final s in subjects) {
        if (s.id != null) subjectMap[s.id!] = s.name;
      }

      final rules = await ruleRepo.getRulesForSemester(semId);
      final todayRules = rules.where((r) => r.dayOfWeek == weekday && r.isActive).toList();

      final savedOccurrences = await occurrenceRepo.getOccurrencesForDate(todayUtc);

      for (final rule in todayRules) {
        final subName = subjectMap[rule.subjectId] ?? 'Subject';
        final saved = savedOccurrences.where((o) =>
            o.subjectId == rule.subjectId &&
            o.startTime == rule.startTime &&
            o.createdFrom == OccurrenceCreatedFrom.WEEKLY_RULE).firstOrNull;

        String statusStr = 'UPCOMING';
        if (saved != null) {
          statusStr = _statusToString(saved.status);
        } else if (cancelledSubjectIds.contains(rule.subjectId)) {
          statusStr = 'CANCELLED';
        } else {
          final records = await attendanceRepo.getAttendanceForSubject(rule.subjectId);
          final record = records.where((r) =>
              r.markedAt.year == todayUtc.year &&
              r.markedAt.month == todayUtc.month &&
              r.markedAt.day == todayUtc.day).firstOrNull;

          if (record != null) {
            if (record.status == AttendanceStatus.PRESENT || record.status == AttendanceStatus.EXTRA_PRESENT) {
              statusStr = 'PRESENT';
            } else if (record.status == AttendanceStatus.ABSENT || record.status == AttendanceStatus.EXTRA_ABSENT) {
              statusStr = 'ABSENT';
            } else if (record.status == AttendanceStatus.CANCELLED) {
              statusStr = 'CANCELLED';
            }
          }
        }

        items.add(TodayWidgetItem(
          subjectName: subName,
          startTime: rule.startTime,
          endTime: rule.endTime,
          room: rule.room,
          status: statusStr,
        ));
      }

      // Add extra / manual occurrences
      final manualSaved = savedOccurrences.where((o) => o.createdFrom == OccurrenceCreatedFrom.MANUAL);
      for (final extra in manualSaved) {
        items.add(TodayWidgetItem(
          subjectName: extra.title,
          startTime: extra.startTime,
          endTime: extra.endTime,
          room: extra.room,
          status: _statusToString(extra.status),
        ));
      }
    }

    // Sort items by start time
    items.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Determine next class (first upcoming class or next scheduled item)
    TodayWidgetItem? nextClass;
    if (items.isNotEmpty) {
      nextClass = items.where((i) => i.status == 'UPCOMING').firstOrNull ?? items.first;
    }

    return TodayWidgetData(
      dateText: dateText,
      isHoliday: false,
      nextClass: nextClass,
      classes: items,
    );
  }

  /// 2. Generate Weekly Schedule Widget Data
  Future<WeeklyWidgetData> generateWeeklyWidgetData({DateTime? customDate}) async {
    final now = customDate ?? DateTime.now();
    final activeSemester = await semesterRepo.getActiveSemester();

    String weekTitle = 'This Week';
    if (activeSemester != null) {
      final start = activeSemester.startDate;
      if (now.isAfter(start) || now.isAtSameMomentAs(start)) {
        final diffDays = now.difference(start).inDays;
        final weekNum = (diffDays / 7).floor() + 1;
        weekTitle = 'Week $weekNum';
      }
    }

    // Find Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    final daysList = <WeeklyWidgetDay>[];

    final semId = activeSemester?.localId;
    final subjectMap = <int, String>{};
    if (semId != null) {
      final subjects = await subjectRepo.getSubjectsBySemester(semId);
      for (final s in subjects) {
        if (s.id != null) subjectMap[s.id!] = s.name;
      }
    }

    for (int i = 0; i < 7; i++) {
      final dayDate = monday.add(Duration(days: i));
      final dayDateUtc = DateTime.utc(dayDate.year, dayDate.month, dayDate.day);
      final dayName = dayNames[i];
      final weekdayNum = i + 1;

      // Check holiday exception
      final exceptions = await exceptionRepo.getExceptionsForDate(dayDateUtc);
      final holiday = exceptions.where((e) => e.type == ScheduleExceptionType.HOLIDAY).firstOrNull;

      if (holiday != null) {
        daysList.add(WeeklyWidgetDay(
          dayName: dayName,
          dateText: '${dayDate.day}',
          isHoliday: true,
          holidayTitle: holiday.title,
          classes: const [],
        ));
        continue;
      }

      final cancelledSubjectIds = exceptions
          .where((e) => e.type == ScheduleExceptionType.CANCELLED_CLASS && e.subjectId != null)
          .map((e) => e.subjectId!)
          .toSet();

      final dayClasses = <WeeklyWidgetClass>[];

      if (semId != null) {
        final allRules = await ruleRepo.getRulesForSemester(semId);
        final dayRules = allRules.where((r) => r.dayOfWeek == weekdayNum && r.isActive).toList();

        for (final rule in dayRules) {
          final subName = subjectMap[rule.subjectId] ?? 'Subject';
          final isCancelled = cancelledSubjectIds.contains(rule.subjectId);

          dayClasses.add(WeeklyWidgetClass(
            subjectName: subName,
            startTime: rule.startTime,
            endTime: rule.endTime,
            isCancelled: isCancelled,
            isExtra: false,
          ));
        }

        // Add extra class occurrences
        final occurrences = await occurrenceRepo.getOccurrencesForDate(dayDateUtc);
        final manualOccurrences = occurrences.where((o) => o.createdFrom == OccurrenceCreatedFrom.MANUAL);
        for (final extra in manualOccurrences) {
          dayClasses.add(WeeklyWidgetClass(
            subjectName: extra.title,
            startTime: extra.startTime,
            endTime: extra.endTime,
            isCancelled: extra.status == OccurrenceStatus.CANCELLED,
            isExtra: true,
          ));
        }
      }

      dayClasses.sort((a, b) => a.startTime.compareTo(b.startTime));

      daysList.add(WeeklyWidgetDay(
        dayName: dayName,
        dateText: '${dayDate.day}',
        isHoliday: false,
        classes: dayClasses,
      ));
    }

    return WeeklyWidgetData(
      weekTitle: weekTitle,
      days: daysList,
    );
  }

  /// 3. Generate Monthly Academic Calendar Widget Data
  Future<MonthWidgetData> generateMonthWidgetData({DateTime? customDate}) async {
    final now = customDate ?? DateTime.now();
    final monthTitle = DateFormat('MMMM yyyy').format(now);

    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayStrip = <MonthWidgetDay>[];

    final activeSemester = await semesterRepo.getActiveSemester();
    final semId = activeSemester?.localId;

    final allTasks = await taskRepo.getAllTasks();

    for (int i = 0; i < 5; i++) { // Monday to Friday date strip
      final dayDate = monday.add(Duration(days: i));
      final dayUtc = DateTime.utc(dayDate.year, dayDate.month, dayDate.day);

      final exceptions = await exceptionRepo.getExceptionsForDate(dayUtc);
      final events = await eventRepo.getEventsForRange(dayUtc, dayUtc);

      final hasHolidays = exceptions.any((e) => e.type == ScheduleExceptionType.HOLIDAY);

      final hasExams = exceptions.any((e) => e.type == ScheduleExceptionType.EXAM) ||
          events.any((e) => e.type == AcademicEventType.EXAM);

      final hasEvents = events.any((e) =>
          e.type == AcademicEventType.EVENT ||
          e.type == AcademicEventType.ASSIGNMENT ||
          e.type == AcademicEventType.DEADLINE);

      final hasTasks = allTasks.any((t) =>
          t.dueDate.year == dayDate.year &&
          t.dueDate.month == dayDate.month &&
          t.dueDate.day == dayDate.day);

      bool hasClasses = false;
      if (semId != null && !hasHolidays) {
        final rules = await ruleRepo.getRulesForSemester(semId);
        hasClasses = rules.any((r) => r.dayOfWeek == dayDate.weekday && r.isActive);
      }

      final isToday = dayDate.year == now.year && dayDate.month == now.month && dayDate.day == now.day;

      dayStrip.add(MonthWidgetDay(
        dayNumber: dayDate.day,
        dateString: DateFormat('EEE').format(dayDate).toUpperCase(),
        isToday: isToday,
        hasClasses: hasClasses,
        hasExams: hasExams,
        hasTasks: hasTasks,
        hasHolidays: hasHolidays,
        hasEvents: hasEvents,
      ));
    }

    // Upcoming academic items starting from today
    final upcomingList = <MonthUpcomingItem>[];
    final todayStart = DateTime(now.year, now.month, now.day);

    // 1. Tasks
    for (final task in allTasks) {
      if (task.dueDate.isAfter(todayStart) || task.dueDate.isAtSameMomentAs(todayStart)) {
        upcomingList.add(MonthUpcomingItem(
          dateText: DateFormat('d MMMM').format(task.dueDate),
          title: task.title,
          type: 'TASK',
        ));
      }
    }

    // 2. Events & Exams
    final futureEvents = await eventRepo.getAllEvents();
    for (final event in futureEvents) {
      if (event.date.isAfter(todayStart) || event.date.isAtSameMomentAs(todayStart)) {
        final typeStr = event.type == AcademicEventType.EXAM ? 'EXAM' : 'EVENT';
        upcomingList.add(MonthUpcomingItem(
          dateText: DateFormat('d MMMM').format(event.date),
          title: event.title,
          type: typeStr,
        ));
      }
    }

    return MonthWidgetData(
      monthTitle: monthTitle,
      days: dayStrip,
      upcomingItems: upcomingList.take(5).toList(),
    );
  }

  /// 4. Serialize JSON and send to HomeWidget / Android SharedPreferences
  Future<void> updateAllWidgets({DateTime? customDate}) async {
    try {
      final todayData = await generateTodayWidgetData(customDate: customDate);
      final weeklyData = await generateWeeklyWidgetData(customDate: customDate);
      final monthData = await generateMonthWidgetData(customDate: customDate);

      await HomeWidget.saveWidgetData<String>('today_widget_data', todayData.toJson());
      await HomeWidget.saveWidgetData<String>('weekly_widget_data', weeklyData.toJson());
      await HomeWidget.saveWidgetData<String>('month_widget_data', monthData.toJson());

      await HomeWidget.updateWidget(androidName: 'TodayWidgetProvider');
      await HomeWidget.updateWidget(androidName: 'WeeklyWidgetProvider');
      await HomeWidget.updateWidget(androidName: 'MonthWidgetProvider');

      if (kDebugMode) {
        developer.log('Updated all Android Home Screen Widgets successfully', name: 'WidgetDataService');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        developer.log('Error updating widgets: $e\n$stack', name: 'WidgetDataService', error: e);
      }
    }
  }

  String _statusToString(OccurrenceStatus status) {
    switch (status) {
      case OccurrenceStatus.PRESENT:
        return 'PRESENT';
      case OccurrenceStatus.ABSENT:
        return 'ABSENT';
      case OccurrenceStatus.CANCELLED:
        return 'CANCELLED';
      case OccurrenceStatus.UPCOMING:
      default:
        return 'UPCOMING';
    }
  }
}
