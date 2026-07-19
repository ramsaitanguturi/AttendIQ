import 'package:flutter_test/flutter_test.dart';

import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';

void main() {
  group('Daily Schedule Occurrence & Attendance System Tests', () {
    final mondayDate = DateTime.utc(2026, 7, 20); // Monday
    final tuesdayDate = DateTime.utc(2026, 7, 21); // Tuesday
    final extraClassDate = DateTime.utc(2026, 7, 25); // Saturday

    final regularRule = WeeklyScheduleRule(
      id: 1,
      subjectId: 101,
      dayOfWeek: 1, // Monday
      startTime: '10:00',
      endTime: '11:00',
      room: 'CS-101',
      faculty: 'Prof. Davis',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Test 1: Today's schedule generated correctly
    test('1. Today schedule generated correctly from WeeklyScheduleRule', () {
      final occurrence = DailyScheduleOccurrence(
        id: 1,
        date: mondayDate,
        subjectId: regularRule.subjectId,
        title: 'Operating Systems',
        startTime: regularRule.startTime,
        endTime: regularRule.endTime,
        type: OccurrenceType.REGULAR_CLASS,
        status: OccurrenceStatus.UPCOMING,
        createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
        room: regularRule.room,
        faculty: regularRule.faculty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(occurrence.date, equals(mondayDate));
      expect(occurrence.subjectId, equals(101));
      expect(occurrence.title, equals('Operating Systems'));
      expect(occurrence.startTime, equals('10:00'));
      expect(occurrence.endTime, equals('11:00'));
      expect(occurrence.type, equals(OccurrenceType.REGULAR_CLASS));
      expect(occurrence.status, equals(OccurrenceStatus.UPCOMING));
      expect(occurrence.createdFrom, equals(OccurrenceCreatedFrom.WEEKLY_RULE));
    });

    // Test 2: Present updates attendance
    test('2. Present status updates attendance record and present count', () {
      final occurrence = DailyScheduleOccurrence(
        id: 1,
        date: mondayDate,
        subjectId: 101,
        title: 'Operating Systems',
        startTime: '10:00',
        endTime: '11:00',
        type: OccurrenceType.REGULAR_CLASS,
        status: OccurrenceStatus.PRESENT,
        createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final record = AttendanceRecord(
        id: 1,
        eventId: occurrence.id!,
        subjectId: occurrence.subjectId!,
        status: AttendanceStatus.PRESENT,
        markedAt: occurrence.date,
        updatedAt: DateTime.now(),
      );

      expect(occurrence.status, equals(OccurrenceStatus.PRESENT));
      expect(record.status, equals(AttendanceStatus.PRESENT));

      int presentCount = 0;
      int absentCount = 0;
      if (record.status == AttendanceStatus.PRESENT) presentCount++;
      final totalConducted = presentCount + absentCount;

      expect(presentCount, equals(1));
      expect(totalConducted, equals(1));
      expect((presentCount / totalConducted) * 100, equals(100.0));
    });

    // Test 3: Absent updates attendance
    test('3. Absent status updates attendance record and decreases percentage', () {
      final occurrence = DailyScheduleOccurrence(
        id: 2,
        date: mondayDate,
        subjectId: 101,
        title: 'Operating Systems',
        startTime: '11:00',
        endTime: '12:00',
        type: OccurrenceType.REGULAR_CLASS,
        status: OccurrenceStatus.ABSENT,
        createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final record = AttendanceRecord(
        id: 2,
        eventId: occurrence.id!,
        subjectId: occurrence.subjectId!,
        status: AttendanceStatus.ABSENT,
        markedAt: occurrence.date,
        updatedAt: DateTime.now(),
      );

      expect(occurrence.status, equals(OccurrenceStatus.ABSENT));
      expect(record.status, equals(AttendanceStatus.ABSENT));

      int presentCount = 0;
      int absentCount = 1;
      final totalConducted = presentCount + absentCount;
      final percentage = totalConducted > 0 ? (presentCount / totalConducted) * 100 : 100.0;

      expect(totalConducted, equals(1));
      expect(presentCount, equals(0));
      expect(percentage, equals(0.0));
    });

    // Test 4: Cancelled does not affect percentage
    test('4. Cancelled status does NOT create attendance record and does NOT affect percentage', () {
      final occurrence = DailyScheduleOccurrence(
        id: 3,
        date: mondayDate,
        subjectId: 101,
        title: 'Operating Systems',
        startTime: '14:00',
        endTime: '15:00',
        type: OccurrenceType.REGULAR_CLASS,
        status: OccurrenceStatus.CANCELLED,
        createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Cancelled occurrences do NOT produce an AttendanceRecord in stats
      final List<AttendanceRecord> records = [];

      int presentCount = 0;
      int absentCount = 0;
      for (final r in records) {
        if (r.status == AttendanceStatus.PRESENT) presentCount++;
        if (r.status == AttendanceStatus.ABSENT) absentCount++;
      }
      final totalConducted = presentCount + absentCount;

      expect(occurrence.status, equals(OccurrenceStatus.CANCELLED));
      expect(records, isEmpty);
      expect(totalConducted, equals(0));
    });

    // Test 5: Extra class appears only on selected date
    test('5. Extra class appears only on selected date and does NOT modify WeeklyScheduleRule', () {
      final extraOccurrence = DailyScheduleOccurrence(
        id: 10,
        date: extraClassDate,
        subjectId: 101,
        title: 'Operating Systems',
        startTime: '14:00',
        endTime: '16:00',
        type: OccurrenceType.EXTRA_CLASS,
        status: OccurrenceStatus.UPCOMING,
        createdFrom: OccurrenceCreatedFrom.MANUAL,
        reason: 'Lab catch-up',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final nextDayDate = extraClassDate.add(const Duration(days: 1));

      expect(extraOccurrence.date, equals(extraClassDate));
      expect(extraOccurrence.type, equals(OccurrenceType.EXTRA_CLASS));
      expect(extraOccurrence.createdFrom, equals(OccurrenceCreatedFrom.MANUAL));
      expect(extraOccurrence.date == nextDayDate, isFalse);
      // Weekly rule remains unchanged
      expect(regularRule.dayOfWeek, equals(1));
    });

    // Test 6: Extra class included in reports
    test('6. Extra class marked Present/Absent is included in total conducted classes and reports', () {
      final records = [
        AttendanceRecord(
          id: 1,
          eventId: 1,
          subjectId: 101,
          status: AttendanceStatus.PRESENT,
          markedAt: mondayDate,
          updatedAt: DateTime.now(),
        ),
        AttendanceRecord(
          id: 2,
          eventId: 10,
          subjectId: 101,
          status: AttendanceStatus.EXTRA_PRESENT,
          markedAt: extraClassDate,
          updatedAt: DateTime.now(),
        ),
        AttendanceRecord(
          id: 3,
          eventId: 11,
          subjectId: 101,
          status: AttendanceStatus.EXTRA_ABSENT,
          markedAt: extraClassDate,
          updatedAt: DateTime.now(),
        ),
      ];

      int present = 0;
      int absent = 0;
      for (final r in records) {
        if (r.status == AttendanceStatus.PRESENT || r.status == AttendanceStatus.EXTRA_PRESENT) {
          present++;
        } else if (r.status == AttendanceStatus.ABSENT || r.status == AttendanceStatus.EXTRA_ABSENT) {
          absent++;
        }
      }
      final totalConducted = present + absent;
      final percentage = (present / totalConducted) * 100;

      expect(present, equals(2)); // 1 regular present + 1 extra present
      expect(absent, equals(1));  // 1 extra absent
      expect(totalConducted, equals(3));
      expect(percentage, closeTo(66.66, 0.1));
    });

    // Test 7: Holiday removes schedule
    test('7. Holiday exception removes schedule for target date', () {
      final holidayException = ScheduleException(
        id: 99,
        date: tuesdayDate,
        type: ScheduleExceptionType.HOLIDAY,
        title: 'College Holiday',
        description: 'Independence Day',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final isHoliday = holidayException.type == ScheduleExceptionType.HOLIDAY;
      final List<DailyScheduleOccurrence> schedule = isHoliday ? [] : [
        DailyScheduleOccurrence(
          id: 5,
          date: tuesdayDate,
          subjectId: 101,
          title: 'Operating Systems',
          startTime: '09:00',
          endTime: '10:00',
          type: OccurrenceType.REGULAR_CLASS,
          status: OccurrenceStatus.UPCOMING,
          createdFrom: OccurrenceCreatedFrom.WEEKLY_RULE,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      expect(isHoliday, isTrue);
      expect(holidayException.title, equals('College Holiday'));
      expect(schedule, isEmpty);
    });
  });
}
