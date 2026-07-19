import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../features/semester/domain/repositories/semester_repository.dart';
import '../../../features/subject/domain/repositories/subject_repository.dart';
import '../../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../../features/semester/presentation/controllers/semester_controller.dart';
import '../../../features/attendance/presentation/controllers/attendance_controller.dart';
import '../../../features/subject/presentation/controllers/subject_controller.dart';
import '../../../features/attendance/domain/entities/attendance_record.dart';
import '../../database/isar_provider.dart';
import '../../analytics/models/risk_status.dart';
import '../../attendance_engine/calculator.dart';
import '../models/attendance_report.dart';
import '../models/subject_report.dart';
import '../../../features/semester/data/models/semester_local.dart';

part 'report_service.g.dart';

class ReportService {
  final Isar _isar;
  final SemesterRepository _semesterRepository;
  final SubjectRepository _subjectRepository;
  final AttendanceRepository _attendanceRepository;

  ReportService({
    required Isar isar,
    required SemesterRepository semesterRepository,
    required SubjectRepository subjectRepository,
    required AttendanceRepository attendanceRepository,
  })  : _isar = isar,
        _semesterRepository = semesterRepository,
        _subjectRepository = subjectRepository,
        _attendanceRepository = attendanceRepository;

  Future<int?> getActiveSemesterLocalId() async {
    final semesterLocal = _isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
    return semesterLocal?.id;
  }

  Future<AttendanceReport?> generateSemesterReport() async {
    final semester = await _semesterRepository.getActiveSemester();
    if (semester == null) return null;

    final semesterId = await getActiveSemesterLocalId();
    if (semesterId == null) return null;

    const studentName = 'Student';

    final subjects = await _subjectRepository.getSubjectsBySemester(semesterId);

    int totalClassesOverall = 0;
    int totalAttendedOverall = 0;
    final List<SubjectReport> subjectReports = [];

    for (final subject in subjects) {
      if (subject.id == null) continue;
      final records = await _attendanceRepository.getAttendanceForSubject(subject.id!);

      int attended = 0;
      int total = 0;

      for (final record in records) {
        if (record.isDeleted) continue;
        if (record.status == AttendanceStatus.PRESENT || record.status == AttendanceStatus.EXTRA_PRESENT) {
          attended++;
          total++;
        } else if (record.status == AttendanceStatus.ABSENT || record.status == AttendanceStatus.EXTRA_ABSENT) {
          total++;
        }
      }

      totalClassesOverall += total;
      totalAttendedOverall += attended;

      final currentRate = AttendanceCalculator.calculatePercentage(attended: attended, total: total);
      final target = subject.attendanceTarget;

      RiskStatus risk;
      if (currentRate < target) {
        risk = RiskStatus.CRITICAL;
      } else if (currentRate - target <= 2.5) {
        risk = RiskStatus.WARNING;
      } else {
        risk = RiskStatus.SAFE;
      }

      subjectReports.add(
        SubjectReport(
          subjectName: subject.name,
          faculty: subject.faculty,
          percentage: currentRate,
          present: attended,
          absent: total - attended,
          totalClasses: total,
          riskStatus: risk,
        ),
      );
    }

    final overallPercentage = AttendanceCalculator.calculatePercentage(
      attended: totalAttendedOverall,
      total: totalClassesOverall,
    );

    return AttendanceReport(
      studentName: studentName,
      semesterName: semester.name,
      generatedDate: DateTime.now(),
      overallPercentage: overallPercentage,
      totalClasses: totalClassesOverall,
      totalPresent: totalAttendedOverall,
      totalAbsent: totalClassesOverall - totalAttendedOverall,
      subjectReports: subjectReports,
    );
  }
}

@riverpod
ReportService reportService(ReportServiceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  final semesterRepo = ref.watch(semesterRepositoryProvider);
  final subjectRepo = ref.watch(subjectRepositoryProvider);
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);

  return ReportService(
    isar: isar,
    semesterRepository: semesterRepo,
    subjectRepository: subjectRepo,
    attendanceRepository: attendanceRepo,
  );
}
