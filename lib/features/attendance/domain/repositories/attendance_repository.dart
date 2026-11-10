import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId);
  Future<AttendanceRecord?> getAttendanceForOccurrence(int occurrenceId);
  Future<AttendanceRecord?> getAttendanceForOccurrenceAnyStatus(
      int occurrenceId);
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId);
  Future<AttendanceRecord?> getAttendanceForEventAnyStatus(int eventId);
  Future<void> saveAttendanceRecord(AttendanceRecord record);
  Future<void> deleteAttendanceRecord(int id);
  Stream<void> watchAttendance(int subjectId);
  Future<void> updateEventStatus(int occurrenceId, String status);
  Future<int> createExtraClassEvent(int subjectId, DateTime date, String status);
}
