import '../entities/academic_event.dart';

abstract class AcademicEventRepository {
  Future<List<AcademicEvent>> getEventsForDate(DateTime date);
  Future<List<AcademicEvent>> getEventsForRange(DateTime startDate, DateTime endDate);
  Future<List<AcademicEvent>> getAllEvents();
  Future<AcademicEvent?> getEventById(int id);
  Future<void> saveEvent(AcademicEvent event);
  Future<void> deleteEvent(int id);
  Stream<void> watchEvents();
}
