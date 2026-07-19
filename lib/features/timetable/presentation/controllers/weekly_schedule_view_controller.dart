import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../subject/presentation/controllers/subject_controller.dart';
import '../../../attendance/presentation/controllers/attendance_controller.dart';
import '../../domain/entities/schedule_exception.dart';
import '../../domain/entities/weekly_schedule_rule.dart';
import '../../domain/utils/semester_week_calculator.dart';
import 'timetable_controller.dart';

enum ScheduleSlotType { classSlot, exam }

class ScheduleClassSlot {
  final int id;
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
  final String status; // 'PRESENT', 'ABSENT', 'UNMARKED'

  const ScheduleClassSlot({
    required this.id,
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
  });
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

final dayScheduleProvider = FutureProvider.family<DayScheduleData, DateTime>((ref, date) async {
  final utcDate = DateTime.utc(date.year, date.month, date.day);
  final weekday = date.weekday;

  final exceptionRepo = ref.watch(scheduleExceptionRepositoryProvider);
  final exceptions = await exceptionRepo.getExceptionsForDate(utcDate);

  final holiday = exceptions.where((e) => e.type == ScheduleExceptionType.HOLIDAY).firstOrNull;
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
      .where((e) => e.type == ScheduleExceptionType.CANCELLED_CLASS && e.subjectId != null)
      .map((e) => e.subjectId!)
      .toSet();

  final examExceptions = exceptions
      .where((e) => e.type == ScheduleExceptionType.EXAM)
      .toList();

  final ruleRepo = ref.watch(weeklyScheduleRuleRepositoryProvider);
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);
  final subjects = await ref.watch(subjectListControllerProvider.future);
  final subjectMap = {for (var s in subjects) if (s.id != null) s.id!: s};

  final activeSemester = await ref.watch(activeSemesterProvider.future);
  final semId = activeSemester?.localId ?? 1;
  final allRules = await ruleRepo.getRulesForSemester(semId);

  final dayRules = allRules
      .where((r) => r.dayOfWeek == weekday && r.isActive && !cancelledSubjectIds.contains(r.subjectId))
      .toList();

  final items = <ScheduleClassSlot>[];

  // Add Exams
  for (final exam in examExceptions) {
    final sub = exam.subjectId != null ? subjectMap[exam.subjectId] : null;
    items.add(
      ScheduleClassSlot(
        id: exam.id ?? 0,
        type: ScheduleSlotType.exam,
        subjectId: exam.subjectId,
        title: sub != null ? '${sub.name} Exam' : exam.title,
        code: sub?.code ?? 'EXAM',
        startTime: '09:00',
        endTime: '12:00',
        description: exam.description ?? 'Exam Event',
        colorHex: '#EF4444',
      ),
    );
  }

  // Add Normal Class Slots
  for (final rule in dayRules) {
    final sub = subjectMap[rule.subjectId];
    if (sub == null) continue;

    final records = await attendanceRepo.getAttendanceForSubject(rule.subjectId);
    final record = records.where((r) =>
        r.markedAt.year == utcDate.year &&
        r.markedAt.month == utcDate.month &&
        r.markedAt.day == utcDate.day).firstOrNull;

    final status = record != null ? record.status.toString().split('.').last : 'UNMARKED';

    items.add(
      ScheduleClassSlot(
        id: rule.id ?? 0,
        type: ScheduleSlotType.classSlot,
        subjectId: rule.subjectId,
        title: sub.name,
        code: sub.code,
        startTime: rule.startTime,
        endTime: rule.endTime,
        room: rule.room,
        faculty: rule.faculty ?? sub.faculty,
        colorHex: sub.color,
        status: status,
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

final weekScheduleProvider = FutureProvider.family<WeekScheduleData, SemesterWeek>((ref, week) async {
  final dayResults = <DayScheduleData>[];
  for (final date in week.dates) {
    final dayData = await ref.watch(dayScheduleProvider(date).future);
    dayResults.add(dayData);
  }
  return WeekScheduleData(week: week, days: dayResults);
});
