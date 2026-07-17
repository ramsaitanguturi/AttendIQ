class AttendanceAIContext {
  final Map<String, dynamic> studentInfo;
  final Map<String, dynamic> semester;
  final Map<String, dynamic> attendanceSummary;
  final List<Map<String, dynamic>> subjectStatistics;
  final List<Map<String, dynamic>> riskSubjects;
  final List<Map<String, dynamic>> upcomingClasses;
  final double attendanceTarget;
  final Map<String, dynamic> recentTrends;

  const AttendanceAIContext({
    required this.studentInfo,
    required this.semester,
    required this.attendanceSummary,
    required this.subjectStatistics,
    required this.riskSubjects,
    required this.upcomingClasses,
    required this.attendanceTarget,
    required this.recentTrends,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentInfo': studentInfo,
      'semester': semester,
      'attendanceSummary': attendanceSummary,
      'subjectStatistics': subjectStatistics,
      'riskSubjects': riskSubjects,
      'upcomingClasses': upcomingClasses,
      'attendanceTarget': attendanceTarget,
      'recentTrends': recentTrends,
    };
  }
}
