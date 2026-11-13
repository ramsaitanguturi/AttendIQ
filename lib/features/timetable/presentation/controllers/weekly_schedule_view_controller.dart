import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../../attendance/domain/entities/attendance_record.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';
import '../../domain/entities/daily_schedule_occurrence.dart';
import '../../domain/entities/schedule_exception.dart';
import '../../domain/entities/academic_event.dart';
import '../../domain/repositories/daily_schedule_occurrence_repository.dart';
import '../../domain/utils/semester_week_calculator.dart';
import '../../data/utils/occurrence_identity.dart';
import 'timetable_controller.dart';

enum ScheduleSlotType { classSlot, exam, event }

class ScheduleClassSlot {
  final int id;
  final int? ruleId;
  final int? occurrenceId;
  final String? slotKey;
  final ScheduleSlotType type;
  final int? subjectId;
  final String title;
  final String code;
  final String startTime;
  final String endTime;
  final String? room;
  final String? faculty;
  final String? description;
  final String colorHex;
  final String status; // 'PRESENT', 'ABSENT', 'CANCELLED', 'UNMARKED'
  final DateTime? date;

  const ScheduleClassSlot({
    required this.id,
    this.ruleId,
    this.occurrenceId,
    this.slotKey,
    required this.type,
    this.subjectId,
    required this.title,
    this.code = '',
    required this.startTime,
    required this.endTime,
    this.room,
    this.faculty,
    this.description,
    this.colorHex = '#4F46E5',
    this.status = 'UNMARKED',
    this.date,
  });

  String get uniqueKey => slotKey ?? '${type.name}:$id';
}

class DayScheduleData {
  final DateTime date;
  final int weekday; // 1 = Mon, 7 = Sun
  final bool isHoliday;
  final String? holidayTitle;
  final String? holidayDescription;
  final List<ScheduleClassSlot> items;

  const DayScheduleData({
    required this.date,
    required this.weekday,
    this.isHoliday = false,
    this.holidayTitle,
    this.holidayDescription,
    this.items = const [],
  });
}

class WeekScheduleData {
  final SemesterWeek week;
  final List<DayScheduleData> days;

  const WeekScheduleData({
    required this.week,
    required this.days,
  });
}

final semesterWeeksProvider = FutureProvider<List<SemesterWeek>>((ref) async {
  final activeSem = await ref.watch(activeSemesterProvider.future);
  if (activeSem == null) return [];
  return SemesterWeekCalculator.calculateWeeks(activeSem);
});

final dayScheduleProvider =
    FutureProvider.family<DayScheduleData, DateTime>((ref, date) {
  return ref.watch(dayScheduleByKeyProvider(formatUtcDateKey(date)).future);
});

final dayScheduleByKeyProvider =
    FutureProvider.family<DayScheduleData, String>((ref, dateKey) async {
  final parsed = DateTime.parse('${dateKey}T00:00:00Z');
  final utcDate = DateTime.utc(parsed.year, parsed.month, parsed.day);
  final weekday = utcDate.weekday;

  final exceptionRepo = ref.watch(scheduleExceptionRepositoryProvider);
  final exceptions = await exceptionRepo.getExceptionsForDate(utcDate);

  final holiday = exceptions
      .where((e) => e.type == ScheduleExceptionType.HOLIDAY)
      .firstOrNull;
  if (holiday != null) {
    return DayScheduleData(
      date: utcDate,
      weekday: weekday,
      isHoliday: true,
      holidayTitle: holiday.title,
      holidayDescription: holiday.description ?? 'College Holiday',
      items: const [],
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

  List<AcademicEvent> academicEvents = [];
  try {
    final academicEventRepo = ref.watch(academicEventRepositoryProvider);
    academicEvents = await academicEventRepo.getEventsForDate(utcDate);
  } catch (_) {}
  final activeAcademicEvents =
      academicEvents.where((e) => !e.isDeleted).toList();

  final ruleRepo = ref.watch(weeklyScheduleRuleRepositoryProvider);
  final occurrenceRepo = ref.watch(dailyScheduleOccurrenceRepositoryProvider);
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);
  final subjects = await ref.watch(subjectListControllerProvider.future);
  final subjectMap = {
    for (var s in subjects)
      if (s.id != null) s.id!: s
  };

  final activeSemester = await ref.watch(activeSemesterProvider.future);
  if (activeSemester == null || activeSemester.localId == null) {
    return DayScheduleData(
      date: utcDate,
      weekday: weekday,
      isHoliday: false,
      items: const [],
    );
  }

  final semId = activeSemester.localId!;
  final allRules = await ruleRepo.getRulesForSemester(semId);
  final savedOccurrences = await occurrenceRepo.getOccurrencesForDate(utcDate);

  final dayRules = allRules
      .where((r) =>
          r.dayOfWeek == weekday &&
          r.isActive &&
          !cancelledSubjectIds.contains(r.subjectId))
      .toList();

  final items = <ScheduleClassSlot>[];
  final consumedOccIds = <int>{};
  final unmaterializedRuleSubjectCount = <int, int>{};
  final matchedSavedByRuleIndex = <int, DailyScheduleOccurrence?>{};

  for (var i = 0; i < dayRules.length; i++) {
    final rule = dayRules[i];
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

    matchedSavedByRuleIndex[i] = saved;
    if (saved != null) {
      if (saved.id != null) consumedOccIds.add(saved.id!);
    } else {
      unmaterializedRuleSubjectCount[rule.subjectId] =
          (unmaterializedRuleSubjectCount[rule.subjectId] ?? 0) + 1;
    }
  }

  // Add Exams and Academic Events with actual start and end times and deduplication
  final consumedAcademicEventIds = <int>{};

  for (final exam in examExceptions) {
    final sub = exam.subjectId != null ? subjectMap[exam.subjectId] : null;

    AcademicEvent? matchingEvent;
    for (final ae in activeAcademicEvents) {
      if (consumedAcademicEventIds.contains(ae.id)) continue;
      final titleMatches =
          normalizeTitleForKey(ae.title) == normalizeTitleForKey(exam.title) ||
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

    final examTitle =
        sub != null ? '${sub.name} Exam' : (matchingEvent?.title ?? exam.title);

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
      ScheduleClassSlot(
        id: exam.id ?? (matchingEvent?.id ?? 0),
        slotKey: computeCanonicalSlotKey(
          date: utcDate,
          subjectId: exam.subjectId,
          startTime: startTime,
          endTime: endTime,
          type: 'EXAM',
          title: examTitle,
        ),
        type: ScheduleSlotType.exam,
        subjectId: exam.subjectId,
        title: examTitle,
        code: sub?.code ?? 'EXAM',
        startTime: startTime,
        endTime: endTime,
        description:
            matchingEvent?.description ?? exam.description ?? 'Exam Event',
        colorHex: '#EF4444',
        date: utcDate,
      ),
    );
  }

  // Add remaining academic events
  for (final ae in activeAcademicEvents) {
    if (ae.id != null && consumedAcademicEventIds.contains(ae.id)) continue;
    final isExam = ae.type == AcademicEventType.EXAM;
    final startTime = (ae.startTime != null && ae.startTime!.trim().isNotEmpty)
        ? normalizeTimeSlotPart(ae.startTime!)
        : '09:00';
    final endTime = (ae.endTime != null && ae.endTime!.trim().isNotEmpty)
        ? normalizeTimeSlotPart(ae.endTime!)
        : (isExam ? '12:00' : '10:00');

    items.add(
      ScheduleClassSlot(
        id: ae.id ?? 0,
        slotKey: computeCanonicalSlotKey(
          date: utcDate,
          startTime: startTime,
          endTime: endTime,
          type: isExam ? 'EXAM' : 'EVENT',
          title: ae.title,
        ),
        type: isExam ? ScheduleSlotType.exam : ScheduleSlotType.event,
        title: ae.title,
        code: isExam ? 'EXAM' : ae.type.toShortString(),
        startTime: startTime,
        endTime: endTime,
        description: ae.description ?? ae.type.toShortString(),
        colorHex: isExam ? '#EF4444' : '#3B82F6',
        date: utcDate,
      ),
    );
  }

  final recordsCache = <int, List<AttendanceRecord>>{};
  final savedOccIds = <int>{
    for (final o in savedOccurrences)
      if (o.id != null) o.id!,
  };

  // Add Normal Class Slots (materialized occurrence first, conservative fallback second)
  for (var i = 0; i < dayRules.length; i++) {
    final rule = dayRules[i];
    final sub = subjectMap[rule.subjectId];
    if (sub == null) continue;

    final saved = matchedSavedByRuleIndex[i];
    String status = 'UNMARKED';

    if (saved != null) {
      if (saved.status != OccurrenceStatus.UPCOMING) {
        status = saved.status.toShortString();
      } else if (saved.id != null && saved.id! > 0) {
        final rec = await attendanceRepo.getAttendanceForOccurrence(saved.id!);
        if (rec != null) {
          status = _attendanceToSlotStatus(rec.status);
        }
      }
    } else if ((unmaterializedRuleSubjectCount[rule.subjectId] ?? 0) == 1) {
      final records = recordsCache[rule.subjectId] ??=
          await attendanceRepo.getAttendanceForSubject(rule.subjectId);
      final unlinkedOnDate = records.where((r) {
        if (!normalizeUtcDate(r.markedAt).isAtSameMomentAs(utcDate))
          return false;
        final occId = r.occurrenceId ?? (r.eventId > 0 ? r.eventId : null);
        return occId == null || !savedOccIds.contains(occId);
      }).toList();
      if (unlinkedOnDate.length == 1) {
        status = _attendanceToSlotStatus(unlinkedOnDate.first.status);
      }
    }

    final slotKey = saved?.slotKey ??
        computeCanonicalSlotKey(
          date: utcDate,
          subjectId: rule.subjectId,
          ruleId: rule.id,
          startTime: rule.startTime,
          endTime: rule.endTime,
          type: 'REGULAR_CLASS',
          title: sub.name,
        );

    items.add(
      ScheduleClassSlot(
        id: rule.id ?? (saved?.id ?? 0),
        ruleId: rule.id,
        occurrenceId: saved?.id,
        slotKey: slotKey,
        type: ScheduleSlotType.classSlot,
        subjectId: rule.subjectId,
        title: sub.name,
        code: sub.code,
        startTime: rule.startTime,
        endTime: rule.endTime,
        room: saved?.room ?? rule.room,
        faculty: saved?.faculty ?? rule.faculty ?? sub.faculty,
        colorHex: sub.color,
        status: status,
        date: utcDate,
      ),
    );
  }

  // Add unconsumed extra classes / standalone occurrences on this date
  for (final extra in savedOccurrences) {
    if (extra.id != null && consumedOccIds.contains(extra.id)) continue;
    final sub = extra.subjectId != null ? subjectMap[extra.subjectId] : null;
    if (sub == null && extra.type != OccurrenceType.EXAM) continue;
    if (extra.type == OccurrenceType.EXAM) continue; // handled above

    items.add(
      ScheduleClassSlot(
        id: extra.id ?? 0,
        ruleId: extra.ruleId,
        occurrenceId: extra.id,
        slotKey: extra.slotKey ?? computeSlotKeyForEntity(extra),
        type: ScheduleSlotType.classSlot,
        subjectId: extra.subjectId,
        title: extra.title,
        code: sub?.code ?? 'EXTRA',
        startTime: extra.startTime,
        endTime: extra.endTime,
        room: extra.room,
        faculty: extra.faculty ?? sub?.faculty,
        description: extra.reason,
        colorHex: sub?.color ?? '#3B82F6',
        status: extra.status == OccurrenceStatus.UPCOMING
            ? 'UNMARKED'
            : extra.status.toShortString(),
        date: utcDate,
      ),
    );
  }

  items.sort((a, b) => a.startTime.compareTo(b.startTime));

  return DayScheduleData(
    date: utcDate,
    weekday: weekday,
    isHoliday: false,
    items: items,
  );
});

String _attendanceToSlotStatus(AttendanceStatus status) {
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

final weekScheduleProvider =
    FutureProvider.family<WeekScheduleData, SemesterWeek>((ref, week) async {
  final dayResults = <DayScheduleData>[];
  for (final date in week.dates) {
    final dayData = await ref
        .watch(dayScheduleByKeyProvider(formatUtcDateKey(date)).future);
    dayResults.add(dayData);
  }
  return WeekScheduleData(week: week, days: dayResults);
});
