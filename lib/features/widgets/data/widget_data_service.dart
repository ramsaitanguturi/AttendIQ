import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import '../domain/widget_models.dart';
import '../../timetable/domain/repositories/weekly_schedule_rule_repository.dart';
import '../../timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import '../../timetable/domain/repositories/schedule_exception_repository.dart';
import '../../timetable/domain/repositories/academic_event_repository.dart';
import '../../timetable/domain/entities/schedule_exception.dart';
import '../../timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../timetable/domain/entities/weekly_schedule_rule.dart';
import '../../timetable/domain/entities/academic_event.dart';
import '../../timetable/data/datasources/weekly_schedule_rule_local_data_source.dart';
import '../../timetable/data/datasources/daily_schedule_occurrence_local_data_source.dart';
import '../../timetable/data/datasources/schedule_exception_local_data_source.dart';
import '../../timetable/data/datasources/academic_event_local_data_source.dart';
import '../../timetable/data/repositories/weekly_schedule_rule_repository_impl.dart';
import '../../timetable/data/repositories/daily_schedule_occurrence_repository_impl.dart';
import '../../timetable/data/repositories/schedule_exception_repository_impl.dart';
import '../../timetable/data/repositories/academic_event_repository_impl.dart';
import '../../timetable/data/utils/occurrence_identity.dart';
import '../../academic_planner/domain/repositories/task_repository.dart';
import '../../academic_planner/domain/entities/task_enums.dart';
import '../../academic_planner/data/datasources/task_local_datasource.dart';
import '../../academic_planner/data/repositories/task_repository_impl.dart';
import '../../semester/domain/repositories/semester_repository.dart';
import '../../semester/data/repositories/semester_repository_impl.dart';
import '../../subject/domain/repositories/subject_repository.dart';
import '../../subject/data/datasources/subject_local_data_source.dart';
import '../../subject/data/repositories/subject_repository_impl.dart';
import '../../attendance/domain/repositories/attendance_repository.dart';
import '../../attendance/domain/entities/attendance_record.dart';
import '../../attendance/data/datasources/attendance_local_data_source.dart';
import '../../attendance/data/repositories/attendance_repository_impl.dart';

// Providers for dependency injection
import '../../timetable/presentation/controllers/timetable_controller.dart';
import '../../academic_planner/presentation/controllers/task_controller.dart';
import '../../semester/presentation/controllers/semester_controller.dart';
import '../../subject/presentation/controllers/subject_controller.dart';
import '../../attendance/presentation/controllers/attendance_controller.dart';

const String _androidWidgetPackage = 'com.ramsa.attendiq.attend_iq';

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

  factory WidgetDataService.fromIsar(Isar isar) {
    return WidgetDataService(
      ruleRepo: WeeklyScheduleRuleRepositoryImpl(
        localDataSource: WeeklyScheduleRuleLocalDataSourceImpl(isar),
      ),
      occurrenceRepo: DailyScheduleOccurrenceRepositoryImpl(
        localDataSource: DailyScheduleOccurrenceLocalDataSourceImpl(isar),
      ),
      exceptionRepo: ScheduleExceptionRepositoryImpl(
        localDataSource: ScheduleExceptionLocalDataSourceImpl(isar),
      ),
      eventRepo: AcademicEventRepositoryImpl(
        AcademicEventLocalDataSourceImpl(isar),
      ),
      taskRepo: TaskRepositoryImpl(TaskLocalDataSourceImpl(isar)),
      semesterRepo: SemesterRepositoryImpl(isar),
      subjectRepo: SubjectRepositoryImpl(
        localDataSource: SubjectLocalDataSourceImpl(isar),
      ),
      attendanceRepo: AttendanceRepositoryImpl(
        AttendanceLocalDataSourceImpl(isar),
      ),
    );
  }

  /// 1. Generate Today's Schedule Widget Data
  Future<TodayWidgetData> generateTodayWidgetData({
    DateTime? customDate,
  }) async {
    final now = customDate ?? DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final weekday = now.weekday; // 1 = Mon, 7 = Sun
    final dateText = DateFormat('EEEE, d MMMM').format(now);

    // Fetch schedule exceptions for today
    final exceptions = await exceptionRepo.getExceptionsForDate(todayUtc);
    final holidayException = exceptions
        .where((e) => e.type == ScheduleExceptionType.HOLIDAY)
        .firstOrNull;

    if (holidayException != null) {
      return TodayWidgetData(
        dateText: dateText,
        isHoliday: true,
        holidayTitle: holidayException.title.trim().isNotEmpty
            ? holidayException.title
            : 'Holiday',
        classes: const [],
      );
    }

    final cancelledSubjectIds = exceptions
        .where(
          (e) =>
              e.type == ScheduleExceptionType.CANCELLED_CLASS &&
              e.subjectId != null,
        )
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
      final todayRules = rules
          .where(
            (r) =>
                r.dayOfWeek == weekday &&
                r.isActive &&
                !r.isDeleted &&
                subjectMap.containsKey(r.subjectId),
          )
          .toList();

      final savedOccurrences =
          await occurrenceRepo.getOccurrencesForDate(todayUtc);
      final consumedOccIds = <int>{};
      final savedOccIds = <int>{
        for (final o in savedOccurrences)
          if (o.id != null) o.id!,
      };
      final matchedByRuleIndex = <int, DailyScheduleOccurrence?>{};
      final unmaterializedCountBySubject = <int, int>{};

      for (var i = 0; i < todayRules.length; i++) {
        final rule = todayRules[i];
        final normStart = normalizeTimeSlotPart(rule.startTime);
        final normEnd = normalizeTimeSlotPart(rule.endTime);

        DailyScheduleOccurrence? saved;
        if (rule.id != null) {
          saved = savedOccurrences.where((o) {
            final ok = o.id == null || !consumedOccIds.contains(o.id);
            return ok && o.ruleId == rule.id;
          }).firstOrNull;
        }
        saved ??= savedOccurrences.where((o) {
          final ok = o.id == null || !consumedOccIds.contains(o.id);
          return ok &&
              o.ruleId == null &&
              o.subjectId == rule.subjectId &&
              normalizeTimeSlotPart(o.startTime) == normStart &&
              normalizeTimeSlotPart(o.endTime) == normEnd &&
              o.createdFrom == OccurrenceCreatedFrom.WEEKLY_RULE;
        }).firstOrNull;

        matchedByRuleIndex[i] = saved;
        if (saved != null) {
          if (saved.id != null) consumedOccIds.add(saved.id!);
        } else {
          unmaterializedCountBySubject[rule.subjectId] =
              (unmaterializedCountBySubject[rule.subjectId] ?? 0) + 1;
        }
      }

      final recordsCache = <int, List<AttendanceRecord>>{};
      for (var i = 0; i < todayRules.length; i++) {
        final rule = todayRules[i];
        final subName = subjectMap[rule.subjectId];
        if (subName == null) continue;
        final saved = matchedByRuleIndex[i];

        String statusStr = 'UPCOMING';
        if (saved != null) {
          if (saved.status != OccurrenceStatus.UPCOMING) {
            statusStr = _statusToString(saved.status);
          } else if (saved.id != null && saved.id! > 0) {
            final rec =
                await attendanceRepo.getAttendanceForOccurrence(saved.id!);
            if (rec != null) {
              statusStr = _attendanceStatusToString(rec.status);
            } else if (cancelledSubjectIds.contains(rule.subjectId)) {
              statusStr = 'CANCELLED';
            }
          } else if (cancelledSubjectIds.contains(rule.subjectId)) {
            statusStr = 'CANCELLED';
          }
        } else if (cancelledSubjectIds.contains(rule.subjectId)) {
          statusStr = 'CANCELLED';
        } else if ((unmaterializedCountBySubject[rule.subjectId] ?? 0) == 1) {
          final records = recordsCache[rule.subjectId] ??=
              await attendanceRepo.getAttendanceForSubject(rule.subjectId);
          final unlinkedOnToday = records.where((r) {
            if (!normalizeUtcDate(r.markedAt).isAtSameMomentAs(todayUtc)) {
              return false;
            }
            final linkedOccId =
                r.occurrenceId ?? (r.eventId > 0 ? r.eventId : null);
            return linkedOccId == null || !savedOccIds.contains(linkedOccId);
          }).toList();

          if (unlinkedOnToday.length == 1) {
            statusStr = _attendanceStatusToString(unlinkedOnToday.first.status);
          }
        }

        items.add(
          TodayWidgetItem(
            subjectName: subName,
            startTime: normalizeTimeSlotPart(rule.startTime),
            endTime: normalizeTimeSlotPart(rule.endTime),
            room: saved?.room ?? rule.room,
            status: statusStr,
          ),
        );
      }

      // Add extra / unconsumed manual occurrences
      for (final extra in savedOccurrences) {
        if (extra.id != null && consumedOccIds.contains(extra.id)) continue;
        if (extra.createdFrom == OccurrenceCreatedFrom.MANUAL ||
            extra.type == OccurrenceType.EXTRA_CLASS) {
          final fallbackName = extra.subjectId != null
              ? (subjectMap[extra.subjectId] ?? 'Extra Class')
              : 'Extra Class';
          final name =
              extra.title.trim().isNotEmpty ? extra.title.trim() : fallbackName;
          items.add(
            TodayWidgetItem(
              subjectName: name,
              startTime: normalizeTimeSlotPart(extra.startTime),
              endTime: normalizeTimeSlotPart(extra.endTime),
              room: extra.room,
              status: _statusToString(extra.status),
            ),
          );
        }
      }
    }

    // Fetch Academic Events and merge with Exam Exceptions
    List<AcademicEvent> academicEvents = [];
    try {
      academicEvents = await eventRepo.getEventsForDate(todayUtc);
    } catch (_) {}
    final activeAcademicEvents =
        academicEvents.where((e) => !e.isDeleted).toList();

    final examExceptions =
        exceptions.where((e) => e.type == ScheduleExceptionType.EXAM).toList();

    final consumedAcademicEventIds = <int>{};

    for (final exam in examExceptions) {
      final subName =
          exam.subjectId != null ? subjectMap[exam.subjectId] : null;

      AcademicEvent? matchingEvent;
      for (final ae in activeAcademicEvents) {
        if (consumedAcademicEventIds.contains(ae.id)) continue;
        final titleMatches = normalizeTitleForKey(ae.title) ==
                normalizeTitleForKey(exam.title) ||
            normalizeTitleForKey(ae.title)
                .contains(normalizeTitleForKey(exam.title)) ||
            normalizeTitleForKey(exam.title)
                .contains(normalizeTitleForKey(ae.title));
        final subjectMatches = subName != null &&
            (normalizeTitleForKey(ae.title)
                    .contains(normalizeTitleForKey(subName)) ||
                (ae.type == AcademicEventType.EXAM && titleMatches));

        if (titleMatches || subjectMatches) {
          matchingEvent = ae;
          if (ae.id != null) consumedAcademicEventIds.add(ae.id!);
          break;
        }
      }

      final examTitle = subName != null
          ? '$subName Exam'
          : (matchingEvent?.title ?? exam.title);

      String startTime = '09:00';
      String endTime = '12:00';
      if (matchingEvent != null) {
        if (matchingEvent.startTime != null &&
            matchingEvent.startTime!.trim().isNotEmpty) {
          startTime = normalizeTimeSlotPart(matchingEvent.startTime!);
        }
        if (matchingEvent.endTime != null &&
            matchingEvent.endTime!.trim().isNotEmpty) {
          endTime = normalizeTimeSlotPart(matchingEvent.endTime!);
        }
      } else if (exam.description != null) {
        final match = RegExp(r'(\d{1,2}:\d{2})\s*[-–to]+\s*(\d{1,2}:\d{2})')
            .firstMatch(exam.description!);
        if (match != null) {
          startTime = normalizeTimeSlotPart(match.group(1)!);
          endTime = normalizeTimeSlotPart(match.group(2)!);
        }
      }

      items.add(
        TodayWidgetItem(
          subjectName: examTitle,
          startTime: startTime,
          endTime: endTime,
          room: 'Exam Hall',
          status: 'UPCOMING',
        ),
      );
    }

    for (final ae in activeAcademicEvents) {
      if (ae.id != null && consumedAcademicEventIds.contains(ae.id)) continue;
      final startTime =
          (ae.startTime != null && ae.startTime!.trim().isNotEmpty)
              ? normalizeTimeSlotPart(ae.startTime!)
              : '09:00';
      final endTime = (ae.endTime != null && ae.endTime!.trim().isNotEmpty)
          ? normalizeTimeSlotPart(ae.endTime!)
          : (ae.type == AcademicEventType.EXAM ? '12:00' : '10:00');

      items.add(
        TodayWidgetItem(
          subjectName: ae.title,
          startTime: startTime,
          endTime: endTime,
          room: null,
          status: 'UPCOMING',
        ),
      );
    }

    // Sort items by normalized start time
    items.sort(
      (a, b) => normalizeTimeSlotPart(a.startTime)
          .compareTo(normalizeTimeSlotPart(b.startTime)),
    );

    // Determine next class (first upcoming class or first scheduled item)
    TodayWidgetItem? nextClass;
    if (items.isNotEmpty) {
      nextClass =
          items.where((i) => i.status == 'UPCOMING').firstOrNull ?? items.first;
    }

    return TodayWidgetData(
      dateText: dateText,
      isHoliday: false,
      nextClass: nextClass,
      classes: items,
    );
  }

  /// 2. Generate Weekly Schedule Widget Data
  Future<WeeklyWidgetData> generateWeeklyWidgetData({
    DateTime? customDate,
  }) async {
    final now = customDate ?? DateTime.now();
    final todayUtc = normalizeUtcDate(now);
    final activeSemester = await semesterRepo.getActiveSemester();

    String weekTitle = 'This Week';
    if (activeSemester != null) {
      final startUtc = normalizeUtcDate(activeSemester.startDate);
      if (!todayUtc.isBefore(startUtc)) {
        final diffDays = todayUtc.difference(startUtc).inDays;
        final weekNum = (diffDays / 7).floor() + 1;
        weekTitle = 'Week $weekNum';
      }
    }

    // Find Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    final daysList = <WeeklyWidgetDay>[];

    final semId = activeSemester?.localId;
    final subjectMap = <int, String>{};
    List<WeeklyScheduleRule> allRules = const [];
    if (semId != null) {
      final subjects = await subjectRepo.getSubjectsBySemester(semId);
      for (final s in subjects) {
        if (s.id != null) subjectMap[s.id!] = s.name;
      }
      allRules = await ruleRepo.getRulesForSemester(semId);
    }

    for (int i = 0; i < 7; i++) {
      final dayDate = monday.add(Duration(days: i));
      final dayDateUtc = DateTime.utc(dayDate.year, dayDate.month, dayDate.day);
      final dayName = dayNames[i];
      final weekdayNum = i + 1;

      // Check holiday exception
      final exceptions = await exceptionRepo.getExceptionsForDate(dayDateUtc);
      final holiday = exceptions
          .where((e) => e.type == ScheduleExceptionType.HOLIDAY)
          .firstOrNull;

      if (holiday != null) {
        daysList.add(
          WeeklyWidgetDay(
            dayName: dayName,
            dateText: '${dayDate.day}',
            isHoliday: true,
            holidayTitle:
                holiday.title.trim().isNotEmpty ? holiday.title : 'Holiday',
            classes: const [],
          ),
        );
        continue;
      }

      final cancelledSubjectIds = exceptions
          .where(
            (e) =>
                e.type == ScheduleExceptionType.CANCELLED_CLASS &&
                e.subjectId != null,
          )
          .map((e) => e.subjectId!)
          .toSet();

      final dayClasses = <WeeklyWidgetClass>[];

      if (semId != null) {
        final dayRules = allRules
            .where(
              (r) =>
                  r.dayOfWeek == weekdayNum &&
                  r.isActive &&
                  !r.isDeleted &&
                  subjectMap.containsKey(r.subjectId),
            )
            .toList();

        final occurrences =
            await occurrenceRepo.getOccurrencesForDate(dayDateUtc);
        final consumedOccIds = <int>{};

        for (final rule in dayRules) {
          final subName = subjectMap[rule.subjectId];
          if (subName == null) continue;
          final normStart = normalizeTimeSlotPart(rule.startTime);
          final normEnd = normalizeTimeSlotPart(rule.endTime);

          DailyScheduleOccurrence? matched;
          if (rule.id != null) {
            matched = occurrences.where((o) {
              final ok = o.id == null || !consumedOccIds.contains(o.id);
              return ok && o.ruleId == rule.id;
            }).firstOrNull;
          }
          matched ??= occurrences.where((o) {
            final ok = o.id == null || !consumedOccIds.contains(o.id);
            return ok &&
                o.ruleId == null &&
                o.subjectId == rule.subjectId &&
                normalizeTimeSlotPart(o.startTime) == normStart &&
                normalizeTimeSlotPart(o.endTime) == normEnd &&
                o.createdFrom == OccurrenceCreatedFrom.WEEKLY_RULE;
          }).firstOrNull;

          if (matched?.id != null) {
            consumedOccIds.add(matched!.id!);
          }

          final isCancelled = matched != null
              ? matched.status == OccurrenceStatus.CANCELLED
              : cancelledSubjectIds.contains(rule.subjectId);

          dayClasses.add(
            WeeklyWidgetClass(
              subjectName: subName,
              startTime: normStart,
              endTime: normEnd,
              isCancelled: isCancelled,
              isExtra: false,
            ),
          );
        }

        // Add extra / manual occurrences
        for (final extra in occurrences) {
          if (extra.id != null && consumedOccIds.contains(extra.id)) continue;
          if (extra.createdFrom == OccurrenceCreatedFrom.MANUAL ||
              extra.type == OccurrenceType.EXTRA_CLASS) {
            final fallbackName = extra.subjectId != null
                ? (subjectMap[extra.subjectId] ?? 'Extra Class')
                : 'Extra Class';
            final name = extra.title.trim().isNotEmpty
                ? extra.title.trim()
                : fallbackName;
            dayClasses.add(
              WeeklyWidgetClass(
                subjectName: name,
                startTime: normalizeTimeSlotPart(extra.startTime),
                endTime: normalizeTimeSlotPart(extra.endTime),
                isCancelled: extra.status == OccurrenceStatus.CANCELLED,
                isExtra: true,
              ),
            );
          }
        }
      }

      dayClasses.sort(
        (a, b) => normalizeTimeSlotPart(a.startTime)
            .compareTo(normalizeTimeSlotPart(b.startTime)),
      );

      daysList.add(
        WeeklyWidgetDay(
          dayName: dayName,
          dateText: '${dayDate.day}',
          isHoliday: false,
          classes: dayClasses,
        ),
      );
    }

    return WeeklyWidgetData(
      weekTitle: weekTitle,
      days: daysList,
    );
  }

  /// 3. Generate Monthly Academic Calendar Widget Data
  Future<MonthWidgetData> generateMonthWidgetData({
    DateTime? customDate,
  }) async {
    final now = customDate ?? DateTime.now();
    final todayUtc = normalizeUtcDate(now);
    final monthTitle = DateFormat('MMMM yyyy').format(now);

    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayStrip = <MonthWidgetDay>[];

    final activeSemester = await semesterRepo.getActiveSemester();
    final semId = activeSemester?.localId;

    final allTasks = await taskRepo.getAllTasks();
    final pendingTasks =
        allTasks.where((t) => t.status != TaskStatus.COMPLETED).toList();
    final rules = semId != null
        ? (await ruleRepo.getRulesForSemester(semId))
            .where((r) => r.isActive && !r.isDeleted)
            .toList()
        : const <WeeklyScheduleRule>[];

    for (int i = 0; i < 5; i++) {
      // Monday to Friday date strip
      final dayDate = monday.add(Duration(days: i));
      final dayUtc = DateTime.utc(dayDate.year, dayDate.month, dayDate.day);

      final exceptions = await exceptionRepo.getExceptionsForDate(dayUtc);
      final events = await eventRepo.getEventsForRange(dayUtc, dayUtc);

      final hasHolidays =
          exceptions.any((e) => e.type == ScheduleExceptionType.HOLIDAY);

      final hasExams =
          exceptions.any((e) => e.type == ScheduleExceptionType.EXAM) ||
              events.any((e) => e.type == AcademicEventType.EXAM);

      final hasEvents = events.any(
        (e) =>
            e.type == AcademicEventType.EVENT ||
            e.type == AcademicEventType.ASSIGNMENT ||
            e.type == AcademicEventType.DEADLINE,
      );

      final hasTasks = pendingTasks.any(
        (t) => normalizeUtcDate(t.dueDate).isAtSameMomentAs(dayUtc),
      );

      bool hasClasses = false;
      if (semId != null && !hasHolidays) {
        hasClasses = rules.any((r) => r.dayOfWeek == dayDate.weekday);
        if (!hasClasses) {
          final occurrences =
              await occurrenceRepo.getOccurrencesForDate(dayUtc);
          hasClasses = occurrences.any(
            (o) =>
                o.type == OccurrenceType.EXTRA_CLASS ||
                o.createdFrom == OccurrenceCreatedFrom.MANUAL,
          );
        }
      }

      final isToday = dayUtc.isAtSameMomentAs(todayUtc);

      dayStrip.add(
        MonthWidgetDay(
          dayNumber: dayDate.day,
          dateString: DateFormat('EEE').format(dayDate).toUpperCase(),
          isToday: isToday,
          hasClasses: hasClasses,
          hasExams: hasExams,
          hasTasks: hasTasks,
          hasHolidays: hasHolidays,
          hasEvents: hasEvents,
        ),
      );
    }

    // Collect upcoming academic items starting from today, sorted chronologically
    final sortableUpcoming =
        <({DateTime date, int priority, MonthUpcomingItem item})>[];

    // 1. Pending Tasks
    for (final task in pendingTasks) {
      final dueUtc = normalizeUtcDate(task.dueDate);
      if (!dueUtc.isBefore(todayUtc)) {
        sortableUpcoming.add(
          (
            date: dueUtc,
            priority: 1,
            item: MonthUpcomingItem(
              dateText: DateFormat('d MMMM').format(dueUtc),
              title: task.title,
              type: 'TASK',
            ),
          ),
        );
      }
    }

    // 2. Academic Events & Exams
    final futureEvents = await eventRepo.getAllEvents();
    for (final event in futureEvents) {
      final eventUtc = normalizeUtcDate(event.date);
      if (!eventUtc.isBefore(todayUtc)) {
        final isExam = event.type == AcademicEventType.EXAM;
        sortableUpcoming.add(
          (
            date: eventUtc,
            priority: isExam ? 0 : 2,
            item: MonthUpcomingItem(
              dateText: DateFormat('d MMMM').format(eventUtc),
              title: event.title,
              type: isExam ? 'EXAM' : 'EVENT',
            ),
          ),
        );
      }
    }

    // 3. Upcoming Schedule Exceptions (Holidays & Exams)
    final upcomingExceptions = await exceptionRepo.getExceptionsForRange(
      todayUtc,
      todayUtc.add(const Duration(days: 90)),
    );
    for (final ex in upcomingExceptions) {
      final exUtc = normalizeUtcDate(ex.date);
      if (exUtc.isBefore(todayUtc)) continue;
      if (ex.type == ScheduleExceptionType.HOLIDAY) {
        sortableUpcoming.add(
          (
            date: exUtc,
            priority: 3,
            item: MonthUpcomingItem(
              dateText: DateFormat('d MMMM').format(exUtc),
              title: ex.title.trim().isNotEmpty ? ex.title : 'Holiday',
              type: 'HOLIDAY',
            ),
          ),
        );
      } else if (ex.type == ScheduleExceptionType.EXAM) {
        sortableUpcoming.add(
          (
            date: exUtc,
            priority: 0,
            item: MonthUpcomingItem(
              dateText: DateFormat('d MMMM').format(exUtc),
              title: ex.title.trim().isNotEmpty ? ex.title : 'Exam',
              type: 'EXAM',
            ),
          ),
        );
      } else if (ex.type == ScheduleExceptionType.EVENT) {
        sortableUpcoming.add(
          (
            date: exUtc,
            priority: 2,
            item: MonthUpcomingItem(
              dateText: DateFormat('d MMMM').format(exUtc),
              title: ex.title.trim().isNotEmpty ? ex.title : 'Event',
              type: 'EVENT',
            ),
          ),
        );
      }
    }

    sortableUpcoming.sort((a, b) {
      final dateCmp = a.date.compareTo(b.date);
      if (dateCmp != 0) return dateCmp;
      final prioCmp = a.priority.compareTo(b.priority);
      if (prioCmp != 0) return prioCmp;
      return a.item.title.compareTo(b.item.title);
    });

    final upcomingList =
        sortableUpcoming.map((entry) => entry.item).take(5).toList();

    return MonthWidgetData(
      monthTitle: monthTitle,
      days: dayStrip,
      upcomingItems: upcomingList,
    );
  }

  /// 4. Serialize JSON and send to HomeWidget / Android SharedPreferences
  Future<void> updateAllWidgets({
    DateTime? customDate,
    bool respectEnabledSetting = true,
  }) async {
    try {
      if (respectEnabledSetting) {
        final enabled = await _isWidgetEnabled();
        if (!enabled) {
          await notifyProvidersUpdated();
          return;
        }
      }

      final todayData = await generateTodayWidgetData(customDate: customDate);
      final weeklyData = await generateWeeklyWidgetData(customDate: customDate);
      final monthData = await generateMonthWidgetData(customDate: customDate);

      await HomeWidget.saveWidgetData<String>(
        'today_widget_data',
        todayData.toJson(),
      );
      await HomeWidget.saveWidgetData<String>(
        'weekly_widget_data',
        weeklyData.toJson(),
      );
      await HomeWidget.saveWidgetData<String>(
        'month_widget_data',
        monthData.toJson(),
      );

      await notifyProvidersUpdated();

      if (kDebugMode) {
        developer.log(
          'Updated all Android Home Screen Widgets successfully',
          name: 'WidgetDataService',
        );
      }
    } catch (e, stack) {
      if (kDebugMode) {
        developer.log(
          'Error updating widgets: $e\n$stack',
          name: 'WidgetDataService',
          error: e,
        );
      }
    }
  }

  Future<void> notifyProvidersUpdated() async {
    await HomeWidget.updateWidget(
      androidName: 'TodayWidgetProvider',
      qualifiedAndroidName: '$_androidWidgetPackage.TodayWidgetProvider',
    );
    await HomeWidget.updateWidget(
      androidName: 'WeeklyWidgetProvider',
      qualifiedAndroidName: '$_androidWidgetPackage.WeeklyWidgetProvider',
    );
    await HomeWidget.updateWidget(
      androidName: 'MonthWidgetProvider',
      qualifiedAndroidName: '$_androidWidgetPackage.MonthWidgetProvider',
    );
  }

  Future<bool> _isWidgetEnabled() async {
    try {
      final raw =
          await HomeWidget.getWidgetData<String>('widget_settings_config');
      if (raw == null || raw.isEmpty) return true;
      return WidgetSettingsModel.fromJson(raw).enabled;
    } catch (_) {
      return true;
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
        return 'UPCOMING';
    }
  }

  String _attendanceStatusToString(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.PRESENT:
      case AttendanceStatus.EXTRA_PRESENT:
        return 'PRESENT';
      case AttendanceStatus.ABSENT:
      case AttendanceStatus.EXTRA_ABSENT:
        return 'ABSENT';
      case AttendanceStatus.CANCELLED:
        return 'CANCELLED';
    }
  }
}
