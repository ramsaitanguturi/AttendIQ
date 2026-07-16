import 'package:flutter_test/flutter_test.dart';

// App Imports
import 'package:attend_iq/core/event_generator/domain/entities/event.dart';
import 'package:attend_iq/core/event_generator/domain/usecases/event_generator.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/timetable/domain/entities/timetable_template.dart';

void main() {
  group('Event Generator Foundation tests', () {
    late DateTime semesterStart;
    late DateTime semesterEnd;
    late List<Subject> subjects;
    late List<TimetableTemplate> templates;

    setUp(() {
      semesterStart = DateTime.utc(2026, 10, 1); // A Thursday
      semesterEnd = DateTime.utc(2026, 10, 31); // A Saturday
      
      subjects = [
        Subject(
          id: 1,
          semesterId: 1,
          name: 'Mathematics IV',
          code: 'MATH-401',
          credits: 4,
          attendanceTarget: 75.0,
          color: '#FF5733',
          type: SubjectType.THEORY,
          updatedAt: DateTime.now(),
        ),
        Subject(
          id: 2,
          semesterId: 1,
          name: 'Physics Lab',
          code: 'PHYS-202',
          credits: 2,
          attendanceTarget: 80.0,
          color: '#33FF57',
          type: SubjectType.LAB,
          updatedAt: DateTime.now(),
        ),
      ];

      templates = [
        TimetableTemplate(
          id: 1,
          subjectId: 1,
          weekday: 1, // Monday
          startTime: '09:00',
          endTime: '10:00',
          updatedAt: DateTime.now(),
        ),
        TimetableTemplate(
          id: 2,
          subjectId: 2,
          weekday: 4, // Thursday
          startTime: '14:00',
          endTime: '16:00',
          updatedAt: DateTime.now(),
        ),
      ];
    });

    test('generateWholeSemester creates correct slots across entire range', () {
      final events = EventGenerator.generateWholeSemester(
        startDate: semesterStart,
        endDate: semesterEnd,
        subjects: subjects,
        templates: templates,
        existingEvents: [],
      );

      // In October 2026 (starting Thurs 1st, ending Sat 31st):
      // Thursdays: 1, 8, 15, 22, 29 (5 Thursdays)
      // Mondays: 5, 12, 19, 26 (4 Mondays)
      // Expected total classes generated: 5 + 4 = 9 events.
      expect(events.length, 9);

      // Verify types
      final mathEvents = events.where((e) => e.subjectId == 1);
      final physEvents = events.where((e) => e.subjectId == 2);

      expect(mathEvents.length, 4);
      expect(physEvents.length, 5);

      expect(mathEvents.first.eventType, EventType.REGULAR_CLASS);
      expect(physEvents.first.eventType, EventType.LAB);
      expect(mathEvents.first.status, EventStatus.UNMARKED);
    });

    test('generateWholeSemester does not duplicate existing logged events', () {
      final existingEvent = Event(
        id: 100,
        subjectId: 1,
        date: DateTime.utc(2026, 10, 5), // First Monday
        startTime: '09:00',
        endTime: '10:00',
        eventType: EventType.REGULAR_CLASS,
        status: EventStatus.PRESENT, // Already logged Present
        updatedAt: DateTime.now(),
      );

      final events = EventGenerator.generateWholeSemester(
        startDate: semesterStart,
        endDate: semesterEnd,
        subjects: subjects,
        templates: templates,
        existingEvents: [existingEvent],
      );

      // Should skip 2026-10-05 and generate 8 new events
      expect(events.length, 8);
      expect(events.any((e) => e.date == DateTime.utc(2026, 10, 5)), isFalse);
    });

    test('generateRollingWindow confines events to a 14-day window [today-7, today+7]', () {
      final today = DateTime.utc(2026, 10, 15); // A Thursday
      // Window range: 2026-10-08 to 2026-10-22
      // Mondays in range: 12, 19 (2 Mondays)
      // Thursdays in range: 8, 15, 22 (3 Thursdays)
      // Expected: 2 + 3 = 5 events

      final events = EventGenerator.generateRollingWindow(
        startDate: semesterStart,
        endDate: semesterEnd,
        subjects: subjects,
        templates: templates,
        existingEvents: [],
        today: today,
      );

      expect(events.length, 5);
      
      // Ensure all event dates are strictly in range
      for (final event in events) {
        expect(event.date.isBefore(DateTime.utc(2026, 10, 8)), isFalse);
        expect(event.date.isAfter(DateTime.utc(2026, 10, 22)), isFalse);
      }
    });

    test('generateRollingWindow respects semester boundaries', () {
      final today = DateTime.utc(2026, 10, 2); // Friday (near start of semester)
      // Window range: 2026-09-25 to 2026-10-09
      // Semester start is 2026-10-01. So range should be confined to 2026-10-01 to 2026-10-09.
      // Thursdays in confined range: 1, 8 (2 Thursdays)
      // Mondays in confined range: 5 (1 Monday)
      // Expected: 2 + 1 = 3 events

      final events = EventGenerator.generateRollingWindow(
        startDate: semesterStart,
        endDate: semesterEnd,
        subjects: subjects,
        templates: templates,
        existingEvents: [],
        today: today,
      );

      expect(events.length, 3);
      for (final event in events) {
        expect(event.date.isBefore(semesterStart), isFalse);
      }
    });
  });
}
