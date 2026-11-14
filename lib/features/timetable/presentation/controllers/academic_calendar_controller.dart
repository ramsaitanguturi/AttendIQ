import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/colors.dart';

import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../domain/entities/academic_event.dart';
import '../../domain/entities/schedule_exception.dart';
import '../../domain/entities/daily_schedule_occurrence.dart';
import '../../domain/repositories/daily_schedule_occurrence_repository.dart';
import 'timetable_controller.dart';

import '../../../academic_planner/presentation/controllers/task_controller.dart';

enum CalendarItemType {
  exam,
  task,
  holiday,
  cancelledClass,
  extraClass,
  regularClass,
  event;

  int get priority {
    switch (this) {
      case CalendarItemType.exam:
        return 1;
      case CalendarItemType.task:
        return 2;
      case CalendarItemType.holiday:
        return 3;
      case CalendarItemType.cancelledClass:
        return 4;
      case CalendarItemType.extraClass:
        return 5;
      case CalendarItemType.regularClass:
        return 6;
      case CalendarItemType.event:
        return 7;
    }
  }

  Color get indicatorColor => getAdaptiveIndicatorColor(true);

  Color getAdaptiveIndicatorColor(bool isDark) {
    if (isDark) {
      switch (this) {
        case CalendarItemType.regularClass:
          return AppColors.gray100;
        case CalendarItemType.exam:
          return AppColors.gray300;
        case CalendarItemType.task:
          return AppColors.gray400;
        case CalendarItemType.holiday:
          return AppColors.gray200;
        case CalendarItemType.extraClass:
          return AppColors.gray300;
        case CalendarItemType.cancelledClass:
          return AppColors.gray400;
        case CalendarItemType.event:
          return AppColors.gray400;
      }
    } else {
      switch (this) {
        case CalendarItemType.regularClass:
          return AppColors.gray900;
        case CalendarItemType.exam:
          return AppColors.gray700;
        case CalendarItemType.task:
          return AppColors.gray800;
        case CalendarItemType.holiday:
          return AppColors.gray700;
        case CalendarItemType.extraClass:
          return AppColors.gray800;
        case CalendarItemType.cancelledClass:
          return AppColors.gray700;
        case CalendarItemType.event:
          return AppColors.gray800;
      }
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
  final int? occurrenceId;
  final int? ruleId;
  final String? slotKey;
  final String? room;
  final String?
      status; // PRESENT, ABSENT, LATE, CANCELLED, UPCOMING, UNMARKED, etc.
  final String? originalStatus;
  final String? description;
  final DateTime? updatedAt;

  const CalendarItem({
    required this.id,
    required this.title,
    this.subtitle,
    this.startTime,
    this.endTime,
    required this.type,
    this.subjectId,
    this.occurrenceId,
    this.ruleId,
    this.slotKey,
    this.room,
    this.status,
    this.originalStatus,
    this.description,
    this.updatedAt,
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

final allDailyOccurrencesProvider =
    FutureProvider<List<DailyScheduleOccurrence>>((ref) async {
  final repo = ref.watch(dailyScheduleOccurrenceRepositoryProvider);
  return repo.getAllOccurrences();
});

final monthlyCalendarDataProvider =
    Provider<AsyncValue<List<CalendarDayData>>>((ref) {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final semesterAsync = ref.watch(activeSemesterProvider);
  final rulesAsync = ref.watch(weeklyScheduleRuleListControllerProvider);
  final exceptionsAsync = ref.watch(scheduleExceptionControllerProvider);
  final academicEventsAsync = ref.watch(academicEventControllerProvider);
  final subjectsAsync = ref.watch(subjectListControllerProvider);
  final tasks = ref.watch(allTasksProvider);
  final occurrencesAsync = ref.watch(allDailyOccurrencesProvider);

  final semester = semesterAsync.valueOrNull;
  final rules = rulesAsync.valueOrNull ?? [];
  final exceptions = exceptionsAsync.valueOrNull ?? [];
  final academicEvents = academicEventsAsync.valueOrNull ?? [];
  final subjects = subjectsAsync.valueOrNull ?? [];
  final occurrences = occurrencesAsync.valueOrNull ?? [];
  final subjectMap = {
    for (final s in subjects)
      if (s.id != null) s.id!: s,
  };

  // Build grid matrix for selectedMonth (starting from Monday of first week)
  final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
  final daysInMonth =
      DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;

  // 1 = Mon, ..., 7 = Sun
  final firstWeekday = firstDayOfMonth.weekday;
  final daysBefore = firstWeekday - 1;

  final gridStartDate = firstDayOfMonth.subtract(Duration(days: daysBefore));
  // Ensure we show 5 or 6 full weeks (up to 35 or 42 cells)
  final totalDays = (daysBefore + daysInMonth) > 35 ? 42 : 35;

  final todayClean =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final List<CalendarDayData> dayList = [];

  for (int i = 0; i < totalDays; i++) {
    final date = gridStartDate.add(Duration(days: i));
    final cleanDate = DateTime.utc(date.year, date.month, date.day);
    final isCurrentMonth =
        date.month == selectedMonth.month && date.year == selectedMonth.year;
    final isToday = cleanDate.year == todayClean.year &&
        cleanDate.month == todayClean.month &&
        cleanDate.day == todayClean.day;

    bool isInSemesterRange = true;
    if (semester != null) {
      final startClean = DateTime.utc(
        semester.startDate.year,
        semester.startDate.month,
        semester.startDate.day,
      );
      final endClean = DateTime.utc(
        semester.endDate.year,
        semester.endDate.month,
        semester.endDate.day,
      );
      isInSemesterRange = (cleanDate.isAfter(startClean) ||
              cleanDate.isAtSameMomentAs(startClean)) &&
          (cleanDate.isBefore(endClean) ||
              cleanDate.isAtSameMomentAs(endClean));
    }

    final dayItems = <CalendarItem>[];

    // 1. Check Exceptions on date
    final dayExceptions = exceptions.where((e) {
      final ed = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return ed.isAtSameMomentAs(cleanDate);
    }).toList();

    final isHoliday =
        dayExceptions.any((e) => e.type == ScheduleExceptionType.holiday);
    String? holidayTitle;
    if (isHoliday) {
      holidayTitle = dayExceptions
          .firstWhere((e) => e.type == ScheduleExceptionType.holiday)
          .title;
      dayItems.add(
        CalendarItem(
          id: 'holiday_${cleanDate.toIso8601String()}',
          title: holidayTitle.isEmpty ? 'Holiday' : holidayTitle,
          subtitle: 'Semester Holiday',
          type: CalendarItemType.holiday,
          description: dayExceptions
              .firstWhere((e) => e.type == ScheduleExceptionType.holiday)
              .description,
        ),
      );
    }

    // 2. Academic Events on date
    final dayAcademicEvents = academicEvents.where((e) {
      final ed = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return ed.isAtSameMomentAs(cleanDate);
    }).toList();

    for (final ae in dayAcademicEvents) {
      CalendarItemType cType = CalendarItemType.event;
      if (ae.type == AcademicEventType.exam) {
        cType = CalendarItemType.exam;
      }
      dayItems.add(
        CalendarItem(
          id: 'academic_event_${ae.id}',
          title: ae.title,
          subtitle: ae.type.toShortString(),
          startTime: ae.startTime,
          endTime: ae.endTime,
          type: cType,
          description: ae.description,
        ),
      );
    }

    // Also check exception exams/events
    for (final ex in dayExceptions) {
      if (ex.type == ScheduleExceptionType.exam) {
        final sub = ex.subjectId != null ? subjectMap[ex.subjectId] : null;
        dayItems.add(
          CalendarItem(
            id: 'exception_exam_${ex.id}',
            title: ex.title,
            subtitle: sub?.name ?? 'Exam',
            type: CalendarItemType.exam,
            subjectId: ex.subjectId,
            description: ex.description,
          ),
        );
      } else if (ex.type == ScheduleExceptionType.event) {
        dayItems.add(
          CalendarItem(
            id: 'exception_event_${ex.id}',
            title: ex.title,
            subtitle: 'Event',
            type: CalendarItemType.event,
            description: ex.description,
          ),
        );
      }
    }

    // 3. Academic Tasks due on date
    final dayTasks = tasks.where((t) {
      final td = DateTime.utc(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      return td.isAtSameMomentAs(cleanDate);
    }).toList();

    for (final task in dayTasks) {
      final sub = task.subjectId != null ? subjectMap[task.subjectId] : null;
      dayItems.add(
        CalendarItem(
          id: 'task_${task.id}',
          title: task.title,
          subtitle:
              '${task.taskType.displayName}${sub != null ? ' (${sub.name})' : ''}',
          type: CalendarItemType.task,
          subjectId: task.subjectId,
          description: task.description,
          status: task.status.displayName,
        ),
      );
    }

    // 4. Daily Schedule Occurrences on date
    final dayOccurrences = occurrences.where((o) {
      final od = DateTime.utc(o.date.year, o.date.month, o.date.day);
      return od.isAtSameMomentAs(cleanDate);
    }).toList();

    // 5. Regular Recurring Classes (WeeklyScheduleRule) if within semester and not holiday
    if (isInSemesterRange && !isHoliday) {
      final dayOfWeek = cleanDate.weekday; // 1=Mon ... 7=Sun
      final matchingRules =
          rules.where((r) => r.isActive && r.dayOfWeek == dayOfWeek).toList();

      for (final rule in matchingRules) {
        final isCancelled = dayExceptions.any(
          (e) =>
              e.type == ScheduleExceptionType.cancelledClass &&
              e.subjectId == rule.subjectId,
        );

        final sub = subjectMap[rule.subjectId];
        final subName = sub?.name ?? 'Subject';

        // Check if there is already a materialized occurrence for this date and rule/slot
        final matchingOcc = dayOccurrences.firstWhereOrNull(
          (o) =>
              !o.isDeleted &&
              o.subjectId == rule.subjectId &&
              o.startTime == rule.startTime,
        );

        final effectiveStatus = matchingOcc != null
            ? matchingOcc.status.toShortString()
            : (isCancelled ? 'CANCELLED' : 'UNMARKED');

        if (isCancelled && matchingOcc == null) {
          dayItems.add(
            CalendarItem(
              id: 'cancelled_rule_${rule.id}_${cleanDate.toIso8601String()}',
              title: subName,
              subtitle: 'Cancelled Class',
              startTime: rule.startTime,
              endTime: rule.endTime,
              type: CalendarItemType.cancelledClass,
              subjectId: rule.subjectId,
              ruleId: rule.id,
              room: rule.room,
              status: 'CANCELLED',
              originalStatus: 'CANCELLED',
            ),
          );
        } else {
          dayItems.add(
            CalendarItem(
              id: matchingOcc != null
                  ? 'occ_${matchingOcc.id}'
                  : 'regular_rule_${rule.id}_${cleanDate.toIso8601String()}',
              title: subName,
              subtitle: rule.room != null && rule.room!.isNotEmpty
                  ? 'Room ${rule.room}'
                  : 'Regular Class',
              startTime: rule.startTime,
              endTime: rule.endTime,
              type: (matchingOcc?.status == OccurrenceStatus.cancelled ||
                      isCancelled)
                  ? CalendarItemType.cancelledClass
                  : CalendarItemType.regularClass,
              subjectId: rule.subjectId,
              occurrenceId: matchingOcc?.id,
              ruleId: rule.id,
              slotKey: matchingOcc?.slotKey,
              room: matchingOcc?.room ?? rule.room,
              status: effectiveStatus,
              originalStatus: matchingOcc?.status.toShortString() ?? 'UNMARKED',
              updatedAt: matchingOcc?.updatedAt,
            ),
          );
        }
      }
    }

    // 6. Daily Schedule Occurrences (Extra Classes) on date
    for (final occ in dayOccurrences) {
      if (occ.type == OccurrenceType.extraClass) {
        final sub = occ.subjectId != null ? subjectMap[occ.subjectId] : null;
        dayItems.add(
          CalendarItem(
            id: 'extra_class_${occ.id}_${cleanDate.toIso8601String()}',
            title:
                occ.title.isNotEmpty ? occ.title : (sub?.name ?? 'Extra Class'),
            subtitle: 'Extra Class',
            startTime: occ.startTime,
            endTime: occ.endTime,
            type: CalendarItemType.extraClass,
            subjectId: occ.subjectId,
            occurrenceId: occ.id,
            slotKey: occ.slotKey,
            room: occ.room,
            status: occ.status.toShortString(),
            originalStatus: occ.status.toShortString(),
            description: occ.reason,
            updatedAt: occ.updatedAt,
          ),
        );
      }
    }

    // Sort items by priority
    dayItems.sort((a, b) => a.type.priority.compareTo(b.type.priority));

    // Dots calculation
    final hasExam = dayItems.any((it) => it.type == CalendarItemType.exam);
    final hasTask = dayItems.any((it) => it.type == CalendarItemType.task);
    final hasHoliday =
        dayItems.any((it) => it.type == CalendarItemType.holiday);
    final hasExtraClass =
        dayItems.any((it) => it.type == CalendarItemType.extraClass);
    final hasRegularClass =
        dayItems.any((it) => it.type == CalendarItemType.regularClass);
    final hasEvent = dayItems.any((it) => it.type == CalendarItemType.event);

    dayList.add(
      CalendarDayData(
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
      ),
    );
  }

  return AsyncValue.data(dayList);
});

final upcomingMonthEventsCountProvider = Provider<int>((ref) {
  final daysAsync = ref.watch(monthlyCalendarDataProvider);
  final days = daysAsync.valueOrNull ?? [];
  int count = 0;
  for (final day in days) {
    if (day.isCurrentMonth) {
      count += day.items
          .where((it) => it.type != CalendarItemType.regularClass)
          .length;
    }
  }
  return count;
});
