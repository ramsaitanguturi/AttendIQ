import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/schedule_exception.dart';
import '../../domain/entities/academic_event.dart';
import '../../domain/entities/daily_schedule_occurrence.dart';
import '../../domain/entities/weekly_schedule_rule.dart';
import '../../domain/repositories/daily_schedule_occurrence_repository.dart';
import '../../data/utils/occurrence_identity.dart';
import 'timetable_controller.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../subject/domain/entities/subject.dart';
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
Future<TodayScheduleState> todaySchedule(TodayScheduleRef ref,
    {DateTime? customDate}) async {
  final now = customDate ?? DateTime.now();
  final todayUtc = DateTime.utc(now.year, now.month, now.day);
  final weekday = now.weekday; // 1 = Monday, 7 = Sunday

  if (kDebugMode) {
    developer.log('TodayScheduleProvider started',
        name: 'TodayScheduleProvider');
    developer.log('Today\'s date: $todayUtc', name: 'TodayScheduleProvider');
    developer.log('Weekday: $weekday', name: 'TodayScheduleProvider');
  }

  try {
    // 1. Fetch Schedule Exceptions for today
    if (kDebugMode) {
      developer.log('Loading exceptions...', name: 'TodayScheduleProvider');
    }
    ref.watch(scheduleExceptionControllerProvider);
    final exceptionRepo = ref.watch(scheduleExceptionRepositoryProvider);
    final exceptions = await exceptionRepo.getExceptionsForDate(todayUtc);

    if (kDebugMode) {
      developer.log('Exceptions found: ${exceptions.length}',
          name: 'TodayScheduleProvider');
      developer.log('Number of ScheduleExceptions: ${exceptions.length}',
          name: 'TodayScheduleProvider');
    }

    // Check if today is a Holiday
    final holidayException = exceptions
        .where((e) => e.type == ScheduleExceptionType.HOLIDAY)
        .firstOrNull;
    if (holidayException != null) {
      if (kDebugMode) {
        developer.log('Today is a holiday: ${holidayException.title}',
            name: 'TodayScheduleProvider');
        developer.log('Returning AsyncData', name: 'TodayScheduleProvider');
      }
      return TodayScheduleState(
        isHoliday: true,
        holidayTitle: holidayException.title,
        holidayDescription: holidayException.description ??
            'College Holiday - All classes cancelled today.',
        occurrences: const [],
      );
    }

    final cancelledSubjectIds = exceptions
        .where((e) =>
            e.type == ScheduleExceptionType.CANCELLED_CLASS &&
            e.subjectId != null)
        .map((e) => e.subjectId!)
        .toSet();

    final examExceptions =
        exceptions.where((e) => e.type == ScheduleExceptionType.EXAM).toList();

    // 1b. Fetch Academic Events for today
    List<AcademicEvent> academicEvents = [];
    try {
      final academicEventRepo = ref.watch(academicEventRepositoryProvider);
      academicEvents = await academicEventRepo.getEventsForDate(todayUtc);
    } catch (e) {
      if (kDebugMode) {
        developer.log('Academic events unavailable: $e',
            name: 'TodayScheduleProvider');
      }
    }
    final activeAcademicEvents =
        academicEvents.where((e) => !e.isDeleted).toList();

    // 2. Fetch saved occurrences for today
    final occurrenceRepo = ref.watch(dailyScheduleOccurrenceRepositoryProvider);
    final savedOccurrences =
        await occurrenceRepo.getOccurrencesForDate(todayUtc);

    // 3. Loading WeeklyScheduleRules...
    if (kDebugMode) {
      developer.log('Loading WeeklyScheduleRules...',
          name: 'TodayScheduleProvider');
    }

    final activeSemester = await ref.watch(activeSemesterProvider.future);
    final semId = activeSemester?.localId;

    List<WeeklyScheduleRule> todayRules = [];
    final subjectMap = <int, Subject>{};

    if (semId != null) {
      final ruleRepo = ref.watch(weeklyScheduleRuleRepositoryProvider);
      final allRules = await ruleRepo.getRulesForSemester(semId);
      todayRules =
          allRules.where((r) => r.dayOfWeek == weekday && r.isActive).toList();

      final subjects = await ref.watch(subjectListControllerProvider.future);
      for (final s in subjects) {
        if (s.id != null) subjectMap[s.id!] = s;
      }
    }

    if (kDebugMode) {
      developer.log('Rules found: ${todayRules.length}',
          name: 'TodayScheduleProvider');
      developer.log(
          'Number of WeeklyScheduleRules loaded: ${todayRules.length}',
          name: 'TodayScheduleProvider');
      developer.log('Generating occurrences...', name: 'TodayScheduleProvider');
    }

    final attendanceRepo = ref.watch(attendanceRepositoryProvider);
    final Map<String, DailyScheduleOccurrence> ruleOccurrences = {};
    final Set<int> consumedSavedIds = <int>{};
    final List<({WeeklyScheduleRule rule, String key})> unmaterializedRules =
        [];
    final Map<int, int> unmaterializedCountBySubject = {};

    // First pass: bind each rule to any materialized occurrence via ruleId or
    // canonical (subjectId, startTime, endTime, WEEKLY_RULE) slot.
    for (final rule in todayRules) {
      final sub = subjectMap[rule.subjectId];
      if (sub == null) continue;

      final key = rule.id != null
          ? '${rule.subjectId}_${rule.id}'
          : '${rule.subjectId}_${rule.startTime}_${rule.endTime}';

      final normRuleStart = normalizeTimeSlotPart(rule.startTime);
      final normRuleEnd = normalizeTimeSlotPart(rule.endTime);

      DailyScheduleOccurrence? saved;
      if (rule.id != null) {
        saved = savedOccurrences.where((o) {
          final idNotConsumed =
              o.id == null || !consumedSavedIds.contains(o.id);
          return idNotConsumed && o.ruleId == rule.id;
        }).firstOrNull;
      }
      saved ??= savedOccurrences.where((o) {
        final idNotConsumed = o.id == null || !consumedSavedIds.contains(o.id);
        return idNotConsumed &&
            o.ruleId == null &&
            o.subjectId == rule.subjectId &&
            normalizeTimeSlotPart(o.startTime) == normRuleStart &&
            normalizeTimeSlotPart(o.endTime) == normRuleEnd &&
            o.createdFrom == OccurrenceCreatedFrom.WEEKLY_RULE;
      }).firstOrNull;

      if (saved != null) {
        if (saved.id != null) {
          consumedSavedIds.add(saved.id!);
        }
        ruleOccurrences[key] = (saved.ruleId == null && rule.id != null)
            ? saved.copyWith(
                ruleId: rule.id,
                slotKey: saved.slotKey ??
                    computeCanonicalSlotKey(
                      date: todayUtc,
                      subjectId: rule.subjectId,
                      ruleId: rule.id,
                      startTime: rule.startTime,
                      endTime: rule.endTime,
                      type: OccurrenceType.REGULAR_CLASS.toShortString(),
                      title: sub.name,
                    ),
              )
            : saved;
      } else {
        unmaterializedRules.add((rule: rule, key: key));
        unmaterializedCountBySubject[rule.subjectId] =
            (unmaterializedCountBySubject[rule.subjectId] ?? 0) + 1;
      }
    }

    // Second pass: materialize unconsumed rules with conservative unlinked
    // attendance fallback (only when a single unmaterialized slot exists for
    // that subject+date so multi-slot subjects never collide on date-only records).
    final savedOccIds = <int>{
      for (final o in savedOccurrences)
        if (o.id != null) o.id!,
    };
    final Map<int, List<AttendanceRecord>> recordsCache = {};

    for (final item in unmaterializedRules) {
      final rule = item.rule;
      final sub = subjectMap[rule.subjectId]!;
      final isCancelled = cancelledSubjectIds.contains(rule.subjectId);

      OccurrenceStatus status =
          isCancelled ? OccurrenceStatus.CANCELLED : OccurrenceStatus.UPCOMING;

      final unmaterializedForSubject =
          unmaterializedCountBySubject[rule.subjectId] ?? 0;
      if (unmaterializedForSubject == 1) {
        final records = recordsCache[rule.subjectId] ??=
            await attendanceRepo.getAttendanceForSubject(rule.subjectId);
        final unlinkedOnToday = records.where((r) {
          final markedDay = normalizeUtcDate(r.markedAt);
          if (!markedDay.isAtSameMomentAs(todayUtc)) return false;
          final linkedOccId =
              r.occurrenceId ?? (r.eventId > 0 ? r.eventId : null);
          return linkedOccId == null || !savedOccIds.contains(linkedOccId);
        }).toList();

        if (unlinkedOnToday.length == 1) {
          final record = unlinkedOnToday.first;
          if (record.status == AttendanceStatus.PRESENT ||
              record.status == AttendanceStatus.EXTRA_PRESENT) {
            status = OccurrenceStatus.PRESENT;
          } else if (record.status == AttendanceStatus.ABSENT ||
              record.status == AttendanceStatus.EXTRA_ABSENT) {
            status = OccurrenceStatus.ABSENT;
          } else if (record.status == AttendanceStatus.CANCELLED) {
            status = OccurrenceStatus.CANCELLED;
          }
        }
      }

      ruleOccurrences[item.key] = DailyScheduleOccurrence(
        date: todayUtc,
        subjectId: rule.subjectId,
        ruleId: rule.id,
        slotKey: computeCanonicalSlotKey(
          date: todayUtc,
          subjectId: rule.subjectId,
          ruleId: rule.id,
          startTime: rule.startTime,
          endTime: rule.endTime,
          type: OccurrenceType.REGULAR_CLASS.toShortString(),
          title: sub.name,
        ),
        title: sub.name,
        startTime: normalizeTimeSlotPart(rule.startTime),
        endTime: normalizeTimeSlotPart(rule.endTime),
        type: OccurrenceType.REGULAR_CLASS,
        status: status,
        createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
        room: rule.room,
        faculty: rule.faculty ?? sub.faculty,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );
    }

    final resultList = <DailyScheduleOccurrence>[...ruleOccurrences.values];

    // 4. Add Manual / Extra Class / unconsumed saved Occurrences for today
    for (final extra in savedOccurrences) {
      final alreadyIncluded =
          (extra.id != null && consumedSavedIds.contains(extra.id!)) ||
              (extra.id != null && resultList.any((e) => e.id == extra.id));
      if (!alreadyIncluded) {
        resultList.add(extra);
      }
    }

    // 5. Add Exam Occurrences from exceptions and Academic Events
    final consumedAcademicEventIds = <int>{};

    for (final exam in examExceptions) {
      final sub = exam.subjectId != null ? subjectMap[exam.subjectId] : null;

      // Deduplicate with matching AcademicEvent
      AcademicEvent? matchingEvent;
      for (final ae in activeAcademicEvents) {
        if (consumedAcademicEventIds.contains(ae.id)) continue;
        final titleMatches = normalizeTitleForKey(ae.title) ==
                normalizeTitleForKey(exam.title) ||
            normalizeTitleForKey(ae.title)
                .contains(normalizeTitleForKey(exam.title)) ||
            normalizeTitleForKey(exam.title)
                .contains(normalizeTitleForKey(ae.title));
        final subjectMatches = sub != null &&
            (normalizeTitleForKey(ae.title)
                    .contains(normalizeTitleForKey(sub.name)) ||
                (ae.type == AcademicEventType.EXAM && titleMatches));

        if (titleMatches || subjectMatches) {
          matchingEvent = ae;
          if (ae.id != null) consumedAcademicEventIds.add(ae.id!);
          break;
        }
      }

      final title = sub != null
          ? '${sub.name} Exam'
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

      final examSlotKey = computeCanonicalSlotKey(
        date: todayUtc,
        subjectId: exam.subjectId,
        startTime: startTime,
        endTime: endTime,
        type: OccurrenceType.EXAM.toShortString(),
        title: title,
      );

      final existing = resultList
          .where((o) =>
              o.type == OccurrenceType.EXAM &&
              (o.slotKey == examSlotKey || o.title == title))
          .firstOrNull;
      if (existing == null) {
        resultList.add(
          DailyScheduleOccurrence(
            date: todayUtc,
            subjectId: exam.subjectId,
            slotKey: examSlotKey,
            title: title,
            startTime: startTime,
            endTime: endTime,
            type: OccurrenceType.EXAM,
            status: OccurrenceStatus.UPCOMING,
            createdFrom: OccurrenceCreatedFrom.MANUAL,
            reason:
                matchingEvent?.description ?? exam.description ?? 'Exam Event',
            createdAt: matchingEvent?.createdAt ?? DateTime.now().toUtc(),
            updatedAt: matchingEvent?.updatedAt ?? DateTime.now().toUtc(),
          ),
        );
      }
    }

    // Add remaining Academic Events
    for (final ae in activeAcademicEvents) {
      if (ae.id != null && consumedAcademicEventIds.contains(ae.id)) continue;
      final isExam = ae.type == AcademicEventType.EXAM;
      final occType = isExam ? OccurrenceType.EXAM : OccurrenceType.EVENT;

      final startTime =
          (ae.startTime != null && ae.startTime!.trim().isNotEmpty)
              ? normalizeTimeSlotPart(ae.startTime!)
              : '09:00';
      final endTime = (ae.endTime != null && ae.endTime!.trim().isNotEmpty)
          ? normalizeTimeSlotPart(ae.endTime!)
          : (isExam ? '12:00' : '10:00');

      final slotKey = computeCanonicalSlotKey(
        date: todayUtc,
        startTime: startTime,
        endTime: endTime,
        type: occType.toShortString(),
        title: ae.title,
      );

      final existing = resultList
          .where((o) =>
              (o.type == occType) &&
              (o.slotKey == slotKey || o.title == ae.title))
          .firstOrNull;
      if (existing == null) {
        resultList.add(
          DailyScheduleOccurrence(
            date: todayUtc,
            slotKey: slotKey,
            title: ae.title,
            startTime: startTime,
            endTime: endTime,
            type: occType,
            status: OccurrenceStatus.UPCOMING,
            createdFrom: OccurrenceCreatedFrom.MANUAL,
            reason: ae.description ?? ae.type.toShortString(),
            createdAt: ae.createdAt,
            updatedAt: ae.updatedAt,
          ),
        );
      }
    }

    // Sort occurrences by startTime
    resultList.sort((a, b) => a.startTime.compareTo(b.startTime));

    if (kDebugMode) {
      developer.log('Occurrences generated: ${resultList.length}',
          name: 'TodayScheduleProvider');
      developer.log('Number of DailyScheduleOccurrences: ${resultList.length}',
          name: 'TodayScheduleProvider');
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
