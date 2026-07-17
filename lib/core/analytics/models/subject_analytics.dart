import 'risk_status.dart';

class SubjectAnalytics {
  final int subjectId;
  final String subjectName;
  final double percentage;
  final int present;
  final int absent;
  final int totalClasses;
  final int safeBunks;
  final int? classesNeeded;
  final RiskStatus riskStatus;

  const SubjectAnalytics({
    required this.subjectId,
    required this.subjectName,
    required this.percentage,
    required this.present,
    required this.absent,
    required this.totalClasses,
    required this.safeBunks,
    this.classesNeeded,
    required this.riskStatus,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAnalytics &&
          runtimeType == other.runtimeType &&
          subjectId == other.subjectId &&
          subjectName == other.subjectName &&
          percentage == other.percentage &&
          present == other.present &&
          absent == other.absent &&
          totalClasses == other.totalClasses &&
          safeBunks == other.safeBunks &&
          classesNeeded == other.classesNeeded &&
          riskStatus == other.riskStatus;

  @override
  int get hashCode =>
      subjectId.hashCode ^
      subjectName.hashCode ^
      percentage.hashCode ^
      present.hashCode ^
      absent.hashCode ^
      totalClasses.hashCode ^
      safeBunks.hashCode ^
      classesNeeded.hashCode ^
      riskStatus.hashCode;

  @override
  String toString() {
    return 'SubjectAnalytics(subjectId: $subjectId, subjectName: $subjectName, percentage: $percentage, present: $present, absent: $absent, totalClasses: $totalClasses, safeBunks: $safeBunks, classesNeeded: $classesNeeded, riskStatus: $riskStatus)';
  }
}
