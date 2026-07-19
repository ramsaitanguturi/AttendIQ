import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../semester/domain/entities/semester.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../subject/domain/entities/subject.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../domain/entities/academic_event.dart';
import '../../domain/entities/daily_schedule_occurrence.dart';
import '../../domain/entities/schedule_exception.dart';
import '../../domain/entities/weekly_schedule_rule.dart';
import 'timetable_controller.dart';

import '../../../academic_planner/presentation/controllers/task_controller.dart';
import '../../../academic_planner/domain/entities/task_enums.dart';

enum CalendarItemType {
  EXAM,
  TASK,
  HOLIDAY,
  CANCELLED_CLASS,
  EXTRA_CLASS,
  REGULAR_CLASS,
  EVENT;

  int get priority {
    switch (this) {
      case CalendarItemType.EXAM:
        return 1;
      case CalendarItemType.TASK:
        return 2;
      case CalendarItemType.HOLIDAY:
        return 3;
      case CalendarItemType.CANCELLED_CLASS:
        return 4;
      case CalendarItemType.EXTRA_CLASS:
        return 5;
      case CalendarItemType.REGULAR_CLASS:
        return 6;
      case CalendarItemType.EVENT:
        return 7;
    }
  }

  Color get indicatorColor {
    switch (this) {
      case CalendarItemType.REGULAR_CLASS:
        return const Color(0xFF66BB6A); // 🟢 Green
      case CalendarItemType.EXAM:
        return const Color(0xFFEF5350); // 🔴 Red
      case CalendarItemType.TASK:
        return const Color(0xFFFF9800); // 🟠 Orange Task Deadline
      case CalendarItemType.HOLIDAY:
        return const Color(0xFFFFCA28); // 🟡 Yellow
      case CalendarItemType.EXTRA_CLASS:
        return const Color(0xFF42A5F5); // 🔵 Blue
      case CalendarItemType.CANCELLED_CLASS:
        return const Color(0xFF8D6E63); // Brown / Grey
      case CalendarItemType.EVENT:
        return const Color(0xFFAB47BC); // 🟣 Purple
    }
  }
}

class CalendarItem {
  final String id;
  final String title;
  final String? subtitle;
  final String? startTime;
  final String? endTime;
  final CalendarItemType type;
  final int? subjectId;
  final String? status; // PRESENT, ABSENT, CANCELLED, UPCOMING, PENDING, COMPLETED
  final String? description;

  const CalendarItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.startTime,
    this.endTime,
    required this.type,
    this.subjectId,
    this.status,
    this.description,
  });
}

class CalendarDayData {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isInSemesterRange;
  final List<CalendarItem> items;

  final bool hasRegularClass;
  final bool hasExam;
  final bool hasTask;
  final bool hasHoliday;
  final bool hasExtraClass;
  final bool hasEvent;

  const CalendarDayData({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isInSemesterRange,
    required this.items,
    required this.hasRegularClass,
    required this.hasExam,
    required this.hasTask,
    required this.hasHoliday,
    required this.hasExtraClass,
    required this.hasEvent,
  });
}

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final isCalendarExpandedProvider = StateProvider<bool>((ref) => true);

final monthlyCalendarDataProvider = Provider<AsyncValue<List<CalendarDayData>>>((ref) {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final semesterAsync = ref.watch(activeSemesterProvider);
  final rulesAsync = ref.watch(weeklyScheduleRuleListControllerProvider);
  final exceptionsAsync = ref.watch(scheduleExceptionControllerProvider);
  final academicEventsAsync = ref.watch(academicEventControllerProvider);
  final subjectsAsync = ref.watch(subjectListControllerProvider);
  final tasks = ref.watch(allTasksProvider);

  final semester = semesterAsync.valueOrNull;
  final rules = rulesAsync.valueOrNull ?? [];
  final exceptions = exceptionsAsync.valueOrNull ?? [];
  final academicEvents = academicEventsAsync.valueOrNull ?? [];
  final subjects = subjectsAsync.valueOrNull ?? [];
  final subjectMap = {for (final s in subjects) if (s.id != null) s.id!: s};

  // Build grid matrix for selectedMonth (starting from Monday of first week)
  final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
  final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

  // 1 = Mon, ..., 7 = Sun
  final firstWeekday = firstDayOfMonth.weekday;
  final daysBefore = firstWeekday - 1;

  final gridStartDate = firstDayOfMonth.subtract(Duration(days: daysBefore));
  // Ensure we show 5 or 6 full weeks (up to 35 or 42 cells)
  final totalDays = (daysBefore + daysInMonth) > 35 ? 42 : 35;

  final todayClean = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final List<CalendarDayData> dayList = [];

  for (int i = 0; i < totalDays; i++) {
    final date = gridStartDate.add(Duration(days: i));
    final cleanDate = DateTime.utc(date.year, date.month, date.day);
    final isCurrentMonth = date.month == selectedMonth.month && date.year == selectedMonth.year;
    final isToday = cleanDate.year == todayClean.year &&
        cleanDate.month == todayClean.month &&
        cleanDate.day == todayClean.day;

    bool isInSemesterRange = true;
    if (semester != null) {
      final startClean = DateTime.utc(semester.startDate.year, semester.startDate.month, semester.startDate.day);
      final endClean = DateTime.utc(semester.endDate.year, semester.endDate.month, semester.endDate.day);
      isInSemesterRange = (cleanDate.isAfter(startClean) || cleanDate.isAtSameMomentAs(startClean)) &&
          (cleanDate.isBefore(endClean) || cleanDate.isAtSameMomentAs(endClean));
    }

    final dayItems = <CalendarItem>[];

    // 1. Check Exceptions on date
    final dayExceptions = exceptions.where((e) {
      final ed = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return ed.isAtSameMomentAs(cleanDate);
    }).toList();

    final isHoliday = dayExceptions.any((e) => e.type == ScheduleExceptionType.HOLIDAY);
    String? holidayTitle;
    if (isHoliday) {
      holidayTitle = dayExceptions.firstWhere((e) => e.type == ScheduleExceptionType.HOLIDAY).title;
      dayItems.add(CalendarItem(
        id: 'holiday_${cleanDate.toIso8601String()}',
        title: holidayTitle.isEmpty ? 'Holiday' : holidayTitle,
        subtitle: 'Semester Holiday',
        type: CalendarItemType.HOLIDAY,
        description: dayExceptions.firstWhere((e) => e.type == ScheduleExceptionType.HOLIDAY).description,
      ));
    }

    // 2. Academic Events on date
    final dayAcademicEvents = academicEvents.where((e) {
      final ed = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return ed.isAtSameMomentAs(cleanDate);
    }).toList();

    for (final ae in dayAcademicEvents) {
      CalendarItemType cType = CalendarItemType.EVENT;
      if (ae.type == AcademicEventType.EXAM) {
        cType = CalendarItemType.EXAM;
      }
      dayItems.add(CalendarItem(
        id: 'academic_event_${ae.id}',
        title: ae.title,
        subtitle: ae.type.toShortString(),
        startTime: ae.startTime,
        endTime: ae.endTime,
        type: cType,
        description: ae.description,
      ));
    }

    // Also check exception exams/events
    for (final ex in dayExceptions) {
      if (ex.type == ScheduleExceptionType.EXAM) {
        final sub = ex.subjectId != null ? subjectMap[ex.subjectId] : null;
        dayItems.add(CalendarItem(
          id: 'exception_exam_${ex.id}',
          title: ex.title,
          subtitle: sub?.name ?? 'Exam',
          type: CalendarItemType.EXAM,
          subjectId: ex.subjectId,
          description: ex.description,
        ));
      } else if (ex.type == ScheduleExceptionType.EVENT) {
        dayItems.add(CalendarItem(
          id: 'exception_event_${ex.id}',
          title: ex.title,
          subtitle: 'Event',
          type: CalendarItemType.EVENT,
          description: ex.description,
        ));
      }
    }

    // 3. Academic Tasks due on date
    final dayTasks = tasks.where((t) {
      final td = DateTime.utc(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return td.isAtSameMomentAs(cleanDate);
    }).toList();

    for (final task in dayTasks) {
      final sub = task.subjectId != null ? subjectMap[task.subjectId] : null;
      dayItems.add(CalendarItem(
        id: 'task_${task.id}',
        title: task.title,
        subtitle: '${task.taskType.displayName}${sub != null ? ' (${sub.name})' : ''}',
        type: CalendarItemType.TASK,
        subjectId: task.subjectId,
        description: task.description,
        status: task.status.displayName,
      ));
    }

    // 4. Regular Recurring Classes (WeeklyScheduleRule) if within semester and not holiday
    if (isInSemesterRange && !isHoliday) {
      final dayOfWeek = cleanDate.weekday; // 1=Mon ... 7=Sun
      final matchingRules = rules.where((r) => r.isActive && r.dayOfWeek == dayOfWeek).toList();

      for (final rule in matchingRules) {
        final isCancelled = dayExceptions.any((e) =>
            e.type == ScheduleExceptionType.CANCELLED_CLASS && e.subjectId == rule.subjectId);

        final sub = subjectMap[rule.subjectId];
        final subName = sub?.name ?? 'Subject';

        if (isCancelled) {
          dayItems.add(CalendarItem(
            id: 'cancelled_rule_${rule.id}_${cleanDate.toIso8601String()}',
            title: subName,
            subtitle: 'Cancelled Class',
            startTime: rule.startTime,
            endTime: rule.endTime,
            type: CalendarItemType.CANCELLED_CLASS,
            subjectId: rule.subjectId,
            status: 'CANCELLED',
          ));
        } else {
          dayItems.add(CalendarItem(
            id: 'regular_rule_${rule.id}_${cleanDate.toIso8601String()}',
            title: subName,
            subtitle: rule.room != null && rule.room!.isNotEmpty ? 'Room ${rule.room}' : 'Regular Class',
            startTime: rule.startTime,
            endTime: rule.endTime,
            type: CalendarItemType.REGULAR_CLASS,
            subjectId: rule.subjectId,
          ));
        }
      }
    }

    // Sort items by priority
    dayItems.sort((a, b) => a.type.priority.compareTo(b.type.priority));

    // Dots calculation
    final hasExam = dayItems.any((it) => it.type == CalendarItemType.EXAM);
    final hasTask = dayItems.any((it) => it.type == CalendarItemType.TASK);
    final hasHoliday = dayItems.any((it) => it.type == CalendarItemType.HOLIDAY);
    final hasExtraClass = dayItems.any((it) => it.type == CalendarItemType.EXTRA_CLASS);
    final hasRegularClass = dayItems.any((it) => it.type == CalendarItemType.REGULAR_CLASS);
    final hasEvent = dayItems.any((it) => it.type == CalendarItemType.EVENT);

    dayList.add(CalendarDayData(
      date: cleanDate,
      isCurrentMonth: isCurrentMonth,
      isToday: isToday,
      isInSemesterRange: isInSemesterRange,
      items: dayItems,
      hasRegularClass: hasRegularClass,
      hasExam: hasExam,
      hasTask: hasTask,
      hasHoliday: hasHoliday,
      hasExtraClass: hasExtraClass,
      hasEvent: hasEvent,
    ));
  }

  return AsyncValue.data(dayList);
});

final upcomingMonthEventsCountProvider = Provider<int>((ref) {
  final daysAsync = ref.watch(monthlyCalendarDataProvider);
  final days = daysAsync.valueOrNull ?? [];
  int count = 0;
  for (final day in days) {
    if (day.isCurrentMonth) {
      count += day.items.where((it) => it.type != CalendarItemType.REGULAR_CLASS).length;
    }
  }
  return count;
});
