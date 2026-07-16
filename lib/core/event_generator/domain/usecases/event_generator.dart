import '../entities/event.dart';
import '../../../../features/subject/domain/entities/subject.dart';
import '../../../../features/timetable/domain/entities/timetable_template.dart';

class EventGenerator {
  EventGenerator._();

  static DateTime _stripTime(DateTime dt) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }

  /// Pure logic to generate events for the whole semester range.
  static List<Event> generateWholeSemester({
    required DateTime startDate,
    required DateTime endDate,
    required List<Subject> subjects,
    required List<TimetableTemplate> templates,
    required List<Event> existingEvents,
  }) {
    final List<Event> newEvents = [];
    final subjectMap = {for (var s in subjects) s.id: s};
    
    DateTime current = _stripTime(startDate);
    final end = _stripTime(endDate);

    while (!current.isAfter(end)) {
      final dayOfWeek = current.weekday; // 1 = Monday, 7 = Sunday
      final matchingTemplates = templates.where((t) => t.weekday == dayOfWeek);

      for (final template in matchingTemplates) {
        final subject = subjectMap[template.subjectId];
        if (subject == null) continue;

        // Check if event already exists
        final exists = existingEvents.any((e) =>
            e.subjectId == template.subjectId &&
            _stripTime(e.date).isAtSameMomentAs(current) &&
            e.startTime == template.startTime &&
            e.endTime == template.endTime);

        if (!exists) {
          final eventType = subject.type == SubjectType.LAB ? EventType.LAB : EventType.REGULAR_CLASS;

          newEvents.add(Event(
            subjectId: template.subjectId,
            date: current,
            startTime: template.startTime,
            endTime: template.endTime,
            eventType: eventType,
            status: EventStatus.UNMARKED,
            updatedAt: DateTime.now(),
          ));
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return newEvents;
  }

  /// Pure logic to generate events for a rolling 14-day window: [today - 7, today + 7].
  static List<Event> generateRollingWindow({
    required DateTime startDate,
    required DateTime endDate,
    required List<Subject> subjects,
    required List<TimetableTemplate> templates,
    required List<Event> existingEvents,
    required DateTime today,
  }) {
    final todayStripped = _stripTime(today);
    final startWindow = todayStripped.subtract(const Duration(days: 7));
    final endWindow = todayStripped.add(const Duration(days: 7));

    // Limit to semester range
    final semStart = _stripTime(startDate);
    final semEnd = _stripTime(endDate);
    final rangeStart = startWindow.isBefore(semStart) ? semStart : startWindow;
    final rangeEnd = endWindow.isAfter(semEnd) ? semEnd : endWindow;

    if (rangeStart.isAfter(rangeEnd)) return [];

    final List<Event> newEvents = [];
    final subjectMap = {for (var s in subjects) s.id: s};

    DateTime current = rangeStart;
    while (!current.isAfter(rangeEnd)) {
      final dayOfWeek = current.weekday;
      final matchingTemplates = templates.where((t) => t.weekday == dayOfWeek);

      for (final template in matchingTemplates) {
        final subject = subjectMap[template.subjectId];
        if (subject == null) continue;

        final exists = existingEvents.any((e) =>
            e.subjectId == template.subjectId &&
            _stripTime(e.date).isAtSameMomentAs(current) &&
            e.startTime == template.startTime &&
            e.endTime == template.endTime);

        if (!exists) {
          final eventType = subject.type == SubjectType.LAB ? EventType.LAB : EventType.REGULAR_CLASS;

          newEvents.add(Event(
            subjectId: template.subjectId,
            date: current,
            startTime: template.startTime,
            endTime: template.endTime,
            eventType: eventType,
            status: EventStatus.UNMARKED,
            updatedAt: DateTime.now(),
          ));
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return newEvents;
  }
}
