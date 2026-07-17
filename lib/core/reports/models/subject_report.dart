import '../../analytics/models/risk_status.dart';

class SubjectReport {
  final String subjectName;
  final String? faculty;
  final double percentage;
  final int present;
  final int absent;
  final int totalClasses;
  final RiskStatus riskStatus;

  const SubjectReport({
    required this.subjectName,
    this.faculty,
    required this.percentage,
    required this.present,
    required this.absent,
    required this.totalClasses,
    required this.riskStatus,
  });
}
