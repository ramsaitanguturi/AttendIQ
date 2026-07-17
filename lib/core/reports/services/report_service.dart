import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/repositories/semester_repository.dart';
import '../../../features/subject/domain/repositories/subject_repository.dart';
import '../../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../features/attendance/presentation/controllers/attendance_controller.dart';
import '../../../features/subject/presentation/controllers/subject_controller.dart';
import '../../../features/attendance/domain/entities/attendance_record.dart';
import '../../database/isar_provider.dart';
import '../../analytics/models/risk_status.dart';
import '../../attendance_engine/calculator.dart';
import '../models/attendance_report.dart';
import '../models/subject_report.dart';
import '../../../features/auth/data/models/semester_local.dart';

part 'report_service.g.dart';

class ReportService {
  final Isar _isar;
  final AuthRepository _authRepository;
  final SemesterRepository _semesterRepository;
  final SubjectRepository _subjectRepository;
  final AttendanceRepository _attendanceRepository;

  ReportService({
    required Isar isar,
    required AuthRepository authRepository,
    required SemesterRepository semesterRepository,
    required SubjectRepository subjectRepository,
    required AttendanceRepository attendanceRepository,
  })  : _isar = isar,
        _authRepository = authRepository,
        _semesterRepository = semesterRepository,
        _subjectRepository = subjectRepository,
        _attendanceRepository = attendanceRepository;

  Future<int?> getActiveSemesterLocalId() async {
    final semesterLocal = _isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
    return semesterLocal?.id;
  }

  Future<AttendanceReport?> generateSemesterReport() async {
    // 1. Fetch active semester
    final semester = await _semesterRepository.getActiveSemester();
    if (semester == null) return null;

    // We need the local id of the semester to fetch subjects.
    final semesterId = await getActiveSemesterLocalId();
    if (semesterId == null) return null;

    // 2. Fetch student profile details
    final user = await _authRepository.getCurrentUser();
    final studentName = user?.name ?? 'Student';

    // 3. Fetch subjects
    final subjects = await _subjectRepository.getSubjectsBySemester(semesterId);

    final List<SubjectReport> subjectReports = [];
    int totalPresent = 0;
    int totalAbsent = 0;

    for (final subject in subjects) {
      if (subject.id == null) continue;
      final records = await _attendanceRepository.getAttendanceForSubject(subject.id!);

      int present = 0;
      int absent = 0;
      for (final r in records) {
        if (r.status == AttendanceStatus.PRESENT || r.status == AttendanceStatus.EXTRA_PRESENT) {
          present++;
        } else if (r.status == AttendanceStatus.ABSENT || r.status == AttendanceStatus.EXTRA_ABSENT) {
          absent++;
        }
      }

      final totalClasses = present + absent;
      final percentage = AttendanceCalculator.calculatePercentage(attended: present, total: totalClasses);

      final target = subject.attendanceTarget;
      RiskStatus riskStatus;
      if (percentage < target) {
        riskStatus = RiskStatus.CRITICAL;
      } else if (percentage - target <= 2.5) {
        riskStatus = RiskStatus.WARNING;
      } else {
        riskStatus = RiskStatus.SAFE;
      }

      subjectReports.add(SubjectReport(
        subjectName: subject.name,
        faculty: subject.faculty,
        percentage: percentage,
        present: present,
        absent: absent,
        totalClasses: totalClasses,
        riskStatus: riskStatus,
      ));

      totalPresent += present;
      totalAbsent += absent;
    }

    final totalClasses = totalPresent + totalAbsent;
    final overallPercentage = AttendanceCalculator.calculatePercentage(
      attended: totalPresent,
      total: totalClasses,
    );

    return AttendanceReport(
      studentName: studentName,
      semesterName: semester.name,
      generatedDate: DateTime.now(),
      overallPercentage: overallPercentage,
      totalClasses: totalClasses,
      totalPresent: totalPresent,
      totalAbsent: totalAbsent,
      subjectReports: subjectReports,
    );
  }
}

@riverpod
ReportService reportService(ReportServiceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  final authRepository = ref.watch(authRepositoryProvider);
  final semesterRepository = ref.watch(semesterRepositoryProvider);
  final subjectRepository = ref.watch(subjectRepositoryProvider);
  final attendanceRepository = ref.watch(attendanceRepositoryProvider);

  return ReportService(
    isar: isar,
    authRepository: authRepository,
    semesterRepository: semesterRepository,
    subjectRepository: subjectRepository,
    attendanceRepository: attendanceRepository,
  );
}
