import '../entities/attendance_record.dart';
import '../../../timetable/domain/entities/daily_schedule_occurrence.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId);
  Future<AttendanceRecord?> getAttendanceForOccurrence(int occurrenceId);
  Future<AttendanceRecord?> getAttendanceForOccurrenceAnyStatus(
    int occurrenceId,
  );
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId);
  Future<AttendanceRecord?> getAttendanceForEventAnyStatus(int eventId);
  Future<void> saveAttendanceRecord(AttendanceRecord record);
  Future<void> deleteAttendanceRecord(int id);
  Stream<void> watchAttendance(int subjectId);
  Future<void> updateEventStatus(int occurrenceId, String status);
  Future<DailyScheduleOccurrence> saveExtraClassWithAttendance({
    int? occurrenceId,
    required int subjectId,
    required DateTime date,
    String? subjectTitle,
    String? startTime,
    String? endTime,
    String? reason,
    AttendanceStatus? status,
    bool autoAllocateSlot = false,
  });
}
