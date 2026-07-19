import '../entities/schedule_exception.dart';

abstract class ScheduleExceptionRepository {
  Future<List<ScheduleException>> getExceptionsForDate(DateTime date);
  Future<List<ScheduleException>> getExceptionsForRange(DateTime startDate, DateTime endDate);
  Future<ScheduleException?> getExceptionById(int id);
  Future<void> saveException(ScheduleException exception);
  Future<void> deleteException(int id);
  Stream<void> watchExceptions();
}
