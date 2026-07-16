import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId);
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId);
  Future<void> saveAttendanceRecord(AttendanceRecord record);
  Future<void> deleteAttendanceRecord(int id);
}
