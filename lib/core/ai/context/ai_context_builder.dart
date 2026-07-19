import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../database/isar_provider.dart';
import '../../../features/attendance/presentation/controllers/subject_attendance_stats_provider.dart';
import '../../../features/semester/data/models/semester_local.dart';
import '../../../features/attendance/data/models/attendance_record_local.dart';
import '../../event_generator/data/models/event_local.dart';
import 'attendance_ai_context.dart';

part 'ai_context_builder.g.dart';

@riverpod
Future<AttendanceAIContext> aiContext(AiContextRef ref) async {
  const userName = 'Student';
  const userEmail = 'student@attendiq.local';

  final isar = ref.watch(isarProvider).requireValue;

  // Active semester
  final semesterLocal = isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
  if (semesterLocal == null) {
    throw Exception('No active semester found.');
  }

  // All subject statistics
  final statsList = await ref.watch(allSubjectAttendanceStatsProvider.future);

  // Today's events
  final todayEvents = await ref.watch(todayEventsProvider.future);

  // Tomorrow's events
  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));
  final tomorrowUtc = DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day);
  final tomorrowEventsLocal = isar.eventLocals
      .where()
      .dateEqualTo(tomorrowUtc)
      .isDeletedEqualTo(false)
      .findAll();

  // 1. Student info
  final studentInfo = {
    'name': userName,
    'email': userEmail,
  };

  // 2. Semester info
  final weeksRemaining = semesterLocal.endDate.difference(now).inDays ~/ 7;
  final semester = {
    'name': semesterLocal.name,
    'startDate': semesterLocal.startDate.toIso8601String(),
    'endDate': semesterLocal.endDate.toIso8601String(),
    'weeksRemaining': weeksRemaining < 0 ? 0 : weeksRemaining,
  };

  // 3. Attendance Summary
  int totalPresent = 0;
  int totalClasses = 0;
  int totalAbsent = 0;
  for (final s in statsList) {
    totalPresent += s.presentCount;
    totalClasses += s.totalClasses;
    totalAbsent += s.absentCount;
  }
  final overallPercentage = totalClasses > 0 ? (totalPresent / totalClasses) * 100.0 : 100.0;

  final attendanceSummary = {
    'overallPercentage': overallPercentage,
    'totalClasses': totalClasses,
    'totalPresent': totalPresent,
    'totalAbsent': totalAbsent,
  };

  // 4. Subject Statistics
  final List<Map<String, dynamic>> subjectStatistics = [];
  final List<Map<String, dynamic>> riskSubjects = [];

  for (final s in statsList) {
    final subMap = {
      'id': s.subject.id,
      'name': s.subject.name,
      'code': s.subject.code,
      'credits': s.subject.credits,
      'attendanceTarget': s.subject.attendanceTarget,
      'currentPercentage': s.attendancePercentage,
      'present': s.presentCount,
      'absent': s.absentCount,
      'total': s.totalClasses,
      'safeBunks': s.safeBunks,
      'mustAttendConsecutive': s.requiredClasses ?? 0,
      'predictedPercentage': s.predictedPercentage,
    };
    subjectStatistics.add(subMap);

    // Identify if risky
    final diff = s.attendancePercentage - s.subject.attendanceTarget;
    if (s.attendancePercentage < s.subject.attendanceTarget) {
      riskSubjects.add({
        'id': s.subject.id,
        'name': s.subject.name,
        'status': 'Critical',
        'currentPercentage': s.attendancePercentage,
        'target': s.subject.attendanceTarget,
        'mustAttendConsecutive': s.requiredClasses ?? 0,
      });
    } else if (diff <= 2.5) {
      riskSubjects.add({
        'id': s.subject.id,
        'name': s.subject.name,
        'status': 'Warning',
        'currentPercentage': s.attendancePercentage,
        'target': s.subject.attendanceTarget,
        'safeBunks': s.safeBunks,
      });
    }
  }

  // 5. Upcoming Classes (Today & Tomorrow)
  final List<Map<String, dynamic>> upcomingClasses = [];
  final subjectNames = {for (var s in statsList) s.subject.id: s.subject.name};

  for (final e in todayEvents) {
    upcomingClasses.add({
      'day': 'Today',
      'subjectId': e.subjectId,
      'subjectName': subjectNames[e.subjectId] ?? 'Subject',
      'time': '${e.startTime}-${e.endTime}',
      'status': e.status,
    });
  }

  for (final e in tomorrowEventsLocal) {
    upcomingClasses.add({
      'day': 'Tomorrow',
      'subjectId': e.subjectId,
      'subjectName': subjectNames[e.subjectId] ?? 'Subject',
      'time': '${e.startTime}-${e.endTime}',
      'status': e.status,
    });
  }

  // 6. Recent Trends
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  final recentRecords = isar.attendanceRecordLocals
      .where()
      .isDeletedEqualTo(false)
      .findAll();

  int recentPresent = 0;
  int recentTotal = 0;
  for (final r in recentRecords) {
    if (r.markedAt.isAfter(thirtyDaysAgo)) {
      if (r.status == 'PRESENT' || r.status == 'EXTRA_PRESENT') {
        recentPresent++;
        recentTotal++;
      } else if (r.status == 'ABSENT' || r.status == 'EXTRA_ABSENT') {
        recentTotal++;
      }
    }
  }

  final recentPercentage = recentTotal > 0 ? (recentPresent / recentTotal) * 100.0 : overallPercentage;
  final recentTrends = {
    'recentPercentage': recentPercentage,
    'totalClassesLoggedLast30Days': recentTotal,
    'presentClassesLoggedLast30Days': recentPresent,
  };

  return AttendanceAIContext(
    studentInfo: studentInfo,
    semester: semester,
    attendanceSummary: attendanceSummary,
    subjectStatistics: subjectStatistics,
    riskSubjects: riskSubjects,
    upcomingClasses: upcomingClasses,
    attendanceTarget: semesterLocal.requiredAttendanceRate,
    recentTrends: recentTrends,
  );
}
