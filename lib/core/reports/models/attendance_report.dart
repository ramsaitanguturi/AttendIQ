import 'subject_report.dart';

class AttendanceReport {
  final String studentName;
  final String semesterName;
  final DateTime generatedDate;
  final double overallPercentage;
  final double targetPercentage;
  final int totalClasses;
  final int totalPresent;
  final int totalAbsent;
  final List<SubjectReport> subjectReports;

  const AttendanceReport({
    required this.studentName,
    required this.semesterName,
    required this.generatedDate,
    required this.overallPercentage,
    this.targetPercentage = 75.0,
    required this.totalClasses,
    required this.totalPresent,
    required this.totalAbsent,
    required this.subjectReports,
  });
}
