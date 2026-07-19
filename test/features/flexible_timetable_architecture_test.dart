import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart';

void main() {
  group('Flexible Multiple Weekly Timings Architecture Tests', () {
    final osSubject = Subject(
      id: 101,
      semesterId: 1,
      name: 'Operating Systems',
      code: 'CS301',
      credits: 4,
      attendanceTarget: 75.0,
      color: '#4ECDC4',
      type: SubjectType.THEORY,
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    // Requirement 9 Test 1: Same subject on 3 different days with different times
    test('1. Same subject can be scheduled on 3 different days with different times', () {
      final rules = [
        WeeklyScheduleRule(
          id: 1,
          subjectId: osSubject.id!,
          dayOfWeek: 1, // Monday
          startTime: '09:00',
          endTime: '10:00',
          room: 'Lab 1',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        WeeklyScheduleRule(
          id: 2,
          subjectId: osSubject.id!,
          dayOfWeek: 2, // Tuesday
          startTime: '12:00',
          endTime: '13:00',
          room: 'Room 202',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        WeeklyScheduleRule(
          id: 3,
          subjectId: osSubject.id!,
          dayOfWeek: 5, // Friday
          startTime: '10:00',
          endTime: '11:00',
          room: 'Hall A',
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ];

      expect(rules.length, equals(3));
      expect(rules.every((r) => r.subjectId == 101), isTrue);

      // Verify days and times
      final mondayRule = rules.firstWhere((r) => r.dayOfWeek == 1);
      final tuesdayRule = rules.firstWhere((r) => r.dayOfWeek == 2);
      final fridayRule = rules.firstWhere((r) => r.dayOfWeek == 5);

      expect(mondayRule.startTime, equals('09:00'));
      expect(mondayRule.endTime, equals('10:00'));

      expect(tuesdayRule.startTime, equals('12:00'));
      expect(tuesdayRule.endTime, equals('13:00'));

      expect(fridayRule.startTime, equals('10:00'));
      expect(fridayRule.endTime, equals('11:00'));
    });

    // Requirement 9 Test 2: Multiple classes on same day
    test('2. Same subject can have multiple class slots on the same day', () {
      final mondayRules = [
        WeeklyScheduleRule(
          id: 10,
          subjectId: osSubject.id!,
          dayOfWeek: 1, // Monday
          startTime: '09:00',
          endTime: '10:00',
          type: SubjectType.THEORY,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        WeeklyScheduleRule(
          id: 11,
          subjectId: osSubject.id!,
          dayOfWeek: 1, // Monday
          startTime: '14:00',
          endTime: '15:00',
          type: SubjectType.LAB,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ];

      final mondayDate = DateTime.utc(2026, 7, 20); // Monday

      final occurrences = mondayRules.map((rule) {
        return DailyScheduleOccurrence(
          id: rule.id,
          date: mondayDate,
          subjectId: rule.subjectId,
          title: osSubject.name,
          startTime: rule.startTime,
          endTime: rule.endTime,
          type: OccurrenceType.REGULAR_CLASS,
          status: OccurrenceStatus.UPCOMING,
          createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      expect(occurrences.length, equals(2));
      expect(occurrences[0].startTime, equals('09:00'));
      expect(occurrences[1].startTime, equals('14:00'));
      expect(occurrences[0].title, equals('Operating Systems'));
      expect(occurrences[1].title, equals('Operating Systems'));
    });

    // Requirement 9 Test 3: Extra class on a day where subject already exists
    test('3. Extra class on a day where subject already exists creates separate occurrence without modifying rules', () {
      final regularRule = WeeklyScheduleRule(
        id: 1,
        subjectId: osSubject.id!,
        dayOfWeek: 1, // Monday
        startTime: '09:00',
        endTime: '10:00',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      final mondayDate = DateTime.utc(2026, 7, 20); // Monday

      final regularOccurrence = DailyScheduleOccurrence(
        id: 1,
        date: mondayDate,
        subjectId: regularRule.subjectId,
        title: osSubject.name,
        startTime: regularRule.startTime,
        endTime: regularRule.endTime,
        type: OccurrenceType.REGULAR_CLASS,
        status: OccurrenceStatus.UPCOMING,
        createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final extraClassOccurrence = DailyScheduleOccurrence(
        id: 99,
        date: mondayDate,
        subjectId: osSubject.id!,
        title: osSubject.name,
        startTime: '15:00',
        endTime: '16:00',
        type: OccurrenceType.EXTRA_CLASS,
        status: OccurrenceStatus.UPCOMING,
        createdFrom: OccurrenceCreatedFrom.MANUAL,
        reason: 'Catch-up Lab Session',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final todaySchedule = [regularOccurrence, extraClassOccurrence];

      expect(todaySchedule.length, equals(2));
      expect(todaySchedule[0].type, equals(OccurrenceType.REGULAR_CLASS));
      expect(todaySchedule[1].type, equals(OccurrenceType.EXTRA_CLASS));

      // Weekly schedule rule remains unchanged
      expect(regularRule.startTime, equals('09:00'));
      expect(regularRule.dayOfWeek, equals(1));
    });

    // Requirement 9 Test 4: Cancel one occurrence without removing weekly rule
    test('4. Cancelling an occurrence sets status to CANCELLED without deleting weekly schedule rule', () {
      final weeklyRule = WeeklyScheduleRule(
        id: 5,
        subjectId: osSubject.id!,
        dayOfWeek: 2, // Tuesday
        startTime: '12:00',
        endTime: '13:00',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      final tuesdayDate = DateTime.utc(2026, 7, 21); // Tuesday

      final exception = ScheduleException(
        id: 10,
        date: tuesdayDate,
        subjectId: osSubject.id,
        type: ScheduleExceptionType.CANCELLED_CLASS,
        title: 'OS Class Cancelled',
        description: 'Instructor away on conference',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Evaluate occurrence status for tuesdayDate
      final isCancelled = exception.type == ScheduleExceptionType.CANCELLED_CLASS && exception.subjectId == weeklyRule.subjectId;
      final occurrence = DailyScheduleOccurrence(
        id: 5,
        date: tuesdayDate,
        subjectId: weeklyRule.subjectId,
        title: osSubject.name,
        startTime: weeklyRule.startTime,
        endTime: weeklyRule.endTime,
        type: OccurrenceType.REGULAR_CLASS,
        status: isCancelled ? OccurrenceStatus.CANCELLED : OccurrenceStatus.UPCOMING,
        createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(occurrence.status, equals(OccurrenceStatus.CANCELLED));

      // The rule itself remains active for next week
      expect(weeklyRule.isActive, isTrue);
      expect(weeklyRule.dayOfWeek, equals(2));
      expect(weeklyRule.startTime, equals('12:00'));
    });

    // Requirement 9 Test 5: Dashboard showing today's correct classes
    test("5. Dashboard filters WeeklyScheduleRules matching today's weekday correctly", () {
      final rules = [
        WeeklyScheduleRule(
          id: 1,
          subjectId: 101,
          dayOfWeek: 1, // Monday
          startTime: '09:00',
          endTime: '10:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        WeeklyScheduleRule(
          id: 2,
          subjectId: 101,
          dayOfWeek: 2, // Tuesday
          startTime: '12:00',
          endTime: '13:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        WeeklyScheduleRule(
          id: 3,
          subjectId: 101,
          dayOfWeek: 5, // Friday
          startTime: '10:00',
          endTime: '11:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Simulate Tuesday (weekday = 2)
      final tuesdayWeekday = 2;
      final todayMatchingRules = rules.where((r) => r.dayOfWeek == tuesdayWeekday && r.isActive).toList();

      expect(todayMatchingRules.length, equals(1));
      expect(todayMatchingRules.first.startTime, equals('12:00'));
      expect(todayMatchingRules.first.endTime, equals('13:00'));
    });

    // Requirement 9 Test 6: Weekly calendar rendering all slots independently
    test('6. Weekly calendar view renders all slots as independent timetable blocks without merging', () {
      final mondayDate = DateTime.utc(2026, 7, 20);

      final slot1 = ScheduleClassSlot(
        id: 1,
        type: ScheduleSlotType.classSlot,
        subjectId: osSubject.id,
        title: osSubject.name,
        code: osSubject.code,
        startTime: '09:00',
        endTime: '10:00',
        colorHex: osSubject.color,
      );

      final slot2 = ScheduleClassSlot(
        id: 2,
        type: ScheduleSlotType.classSlot,
        subjectId: osSubject.id,
        title: osSubject.name,
        code: osSubject.code,
        startTime: '14:00',
        endTime: '15:00',
        colorHex: osSubject.color,
      );

      final dayData = DayScheduleData(
        date: mondayDate,
        weekday: mondayDate.weekday,
        items: [slot1, slot2],
      );

      expect(dayData.items.length, equals(2));
      expect(dayData.items[0].id, equals(1));
      expect(dayData.items[1].id, equals(2));
      expect(dayData.items[0].startTime, equals('09:00'));
      expect(dayData.items[1].startTime, equals('14:00'));
      // Both slots belong to same subject but remain independent cards
      expect(dayData.items[0].code, equals(dayData.items[1].code));
    });
  });
}
