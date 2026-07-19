import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/schedule_exception.dart';
import '../../domain/entities/daily_schedule_occurrence.dart';
import '../../domain/entities/weekly_schedule_rule.dart';
import '../../domain/repositories/daily_schedule_occurrence_repository.dart';
import 'timetable_controller.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';

part 'today_schedule_provider.g.dart';

class TodayScheduleState {
  final bool isHoliday;
  final String? holidayTitle;
  final String? holidayDescription;
  final List<DailyScheduleOccurrence> occurrences;

  TodayScheduleState({
    this.isHoliday = false,
    this.holidayTitle,
    this.holidayDescription,
    this.occurrences = const [],
  });
}

@riverpod
Future<TodayScheduleState> todaySchedule(TodayScheduleRef ref, {DateTime? customDate}) async {
  final now = customDate ?? DateTime.now();
  final todayUtc = DateTime.utc(now.year, now.month, now.day);
  final weekday = now.weekday; // 1 = Monday, 7 = Sunday

  if (kDebugMode) {
    developer.log('TodayScheduleProvider started', name: 'TodayScheduleProvider');
    developer.log('Today\'s date: $todayUtc', name: 'TodayScheduleProvider');
    developer.log('Weekday: $weekday', name: 'TodayScheduleProvider');
  }

  try {
    // 1. Fetch Schedule Exceptions for today
    if (kDebugMode) {
      developer.log('Loading exceptions...', name: 'TodayScheduleProvider');
    }
    final exceptionRepo = ref.watch(scheduleExceptionRepositoryProvider);
    final exceptions = await exceptionRepo.getExceptionsForDate(todayUtc);

    if (kDebugMode) {
      developer.log('Exceptions found: ${exceptions.length}', name: 'TodayScheduleProvider');
      developer.log('Number of ScheduleExceptions: ${exceptions.length}', name: 'TodayScheduleProvider');
    }

    // Check if today is a Holiday
    final holidayException = exceptions.where((e) => e.type == ScheduleExceptionType.HOLIDAY).firstOrNull;
    if (holidayException != null) {
      if (kDebugMode) {
        developer.log('Today is a holiday: ${holidayException.title}', name: 'TodayScheduleProvider');
        developer.log('Returning AsyncData', name: 'TodayScheduleProvider');
      }
      return TodayScheduleState(
        isHoliday: true,
        holidayTitle: holidayException.title,
        holidayDescription: holidayException.description ?? 'College Holiday - All classes cancelled today.',
        occurrences: const [],
      );
    }

    final cancelledSubjectIds = exceptions
        .where((e) => e.type == ScheduleExceptionType.CANCELLED_CLASS && e.subjectId != null)
        .map((e) => e.subjectId!)
        .toSet();

    final examExceptions = exceptions
        .where((e) => e.type == ScheduleExceptionType.EXAM)
        .toList();

    // 2. Fetch saved occurrences for today
    final occurrenceRepo = ref.watch(dailyScheduleOccurrenceRepositoryProvider);
    final savedOccurrences = await occurrenceRepo.getOccurrencesForDate(todayUtc);

    // 3. Loading WeeklyScheduleRules...
    if (kDebugMode) {
      developer.log('Loading WeeklyScheduleRules...', name: 'TodayScheduleProvider');
    }

    final activeSemester = await ref.watch(activeSemesterProvider.future);
    final semId = activeSemester?.localId;

    List<WeeklyScheduleRule> todayRules = [];
    final subjectMap = <int, dynamic>{};

    if (semId != null) {
      final ruleRepo = ref.watch(weeklyScheduleRuleRepositoryProvider);
      final allRules = await ruleRepo.getRulesForSemester(semId);
      todayRules = allRules.where((r) => r.dayOfWeek == weekday && r.isActive).toList();

      final subjects = await ref.watch(subjectListControllerProvider.future);
      for (final s in subjects) {
        if (s.id != null) subjectMap[s.id!] = s;
      }
    }

    if (kDebugMode) {
      developer.log('Rules found: ${todayRules.length}', name: 'TodayScheduleProvider');
      developer.log('Number of WeeklyScheduleRules loaded: ${todayRules.length}', name: 'TodayScheduleProvider');
      developer.log('Generating occurrences...', name: 'TodayScheduleProvider');
    }

    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    final Map<String, DailyScheduleOccurrence> ruleOccurrences = {};

    // Process rules into occurrences
    for (final rule in todayRules) {
      final sub = subjectMap[rule.subjectId];
      if (sub == null) continue;

      final key = rule.id != null
          ? '${rule.subjectId}_${rule.id}'
          : '${rule.subjectId}_${rule.startTime}_${rule.endTime}';

      // Check if saved occurrence exists for this rule slot
      final saved = savedOccurrences.where((o) =>
          o.subjectId == rule.subjectId &&
          o.startTime == rule.startTime &&
          o.createdFrom == OccurrenceCreatedFrom.WEEKLY_RULE).firstOrNull;

      if (saved != null) {
        ruleOccurrences[key] = saved;
      } else {
        // Check if cancelled by exception
        final isCancelled = cancelledSubjectIds.contains(rule.subjectId);

        // Check legacy AttendanceRecord for this date/subject
        final records = await attendanceRepo.getAttendanceForSubject(rule.subjectId);
        final record = records.where((r) =>
            r.markedAt.year == todayUtc.year &&
            r.markedAt.month == todayUtc.month &&
            r.markedAt.day == todayUtc.day).firstOrNull;

        OccurrenceStatus status = isCancelled ? OccurrenceStatus.CANCELLED : OccurrenceStatus.UPCOMING;
        if (record != null) {
          if (record.status == AttendanceStatus.PRESENT || record.status == AttendanceStatus.EXTRA_PRESENT) {
            status = OccurrenceStatus.PRESENT;
          } else if (record.status == AttendanceStatus.ABSENT || record.status == AttendanceStatus.EXTRA_ABSENT) {
            status = OccurrenceStatus.ABSENT;
          } else if (record.status == AttendanceStatus.CANCELLED) {
            status = OccurrenceStatus.CANCELLED;
          }
        }

        ruleOccurrences[key] = DailyScheduleOccurrence(
          date: todayUtc,
          subjectId: rule.subjectId,
          title: sub.name,
          startTime: rule.startTime,
          endTime: rule.endTime,
          type: OccurrenceType.REGULAR_CLASS,
          status: status,
          createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
          room: rule.room,
          faculty: rule.faculty ?? sub.faculty,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    }

    final resultList = <DailyScheduleOccurrence>[...ruleOccurrences.values];

    // 4. Add Manual / Extra Class Occurrences from saved occurrences
    final manualSaved = savedOccurrences.where((o) => o.createdFrom == OccurrenceCreatedFrom.MANUAL);
    for (final extra in manualSaved) {
      if (!resultList.any((e) => e.id == extra.id && e.id != null)) {
        resultList.add(extra);
      }
    }

    // 5. Add Exam Occurrences from exceptions if not already present
    for (final exam in examExceptions) {
      final sub = exam.subjectId != null ? subjectMap[exam.subjectId] : null;
      final title = sub != null ? '${sub.name} Exam' : exam.title;

      final existing = resultList.where((o) => o.type == OccurrenceType.EXAM && o.title == title).firstOrNull;
      if (existing == null) {
        resultList.add(
          DailyScheduleOccurrence(
            date: todayUtc,
            subjectId: exam.subjectId,
            title: title,
            startTime: '09:00',
            endTime: '12:00',
            type: OccurrenceType.EXAM,
            status: OccurrenceStatus.UPCOMING,
            createdFrom: OccurrenceCreatedFrom.MANUAL,
            reason: exam.description ?? 'Exam Event',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }

    // Sort occurrences by startTime
    resultList.sort((a, b) => a.startTime.compareTo(b.startTime));

    if (kDebugMode) {
      developer.log('Occurrences generated: ${resultList.length}', name: 'TodayScheduleProvider');
      developer.log('Number of DailyScheduleOccurrences: ${resultList.length}', name: 'TodayScheduleProvider');
      developer.log('Returning AsyncData', name: 'TodayScheduleProvider');
    }

    return TodayScheduleState(
      isHoliday: false,
      occurrences: resultList,
    );
  } catch (e, stackTrace) {
    if (kDebugMode) {
      developer.log(
        'Exception in TodayScheduleProvider: $e\n$stackTrace',
        name: 'TodayScheduleProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }
    rethrow;
  }
}
