class Semester {
  final String? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double requiredAttendanceRate;

  const Semester({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.requiredAttendanceRate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Semester &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          requiredAttendanceRate == other.requiredAttendanceRate;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      requiredAttendanceRate.hashCode;

  @override
  String toString() {
    return 'Semester(id: $id, name: $name, startDate: $startDate, endDate: $endDate, requiredAttendanceRate: $requiredAttendanceRate)';
  }
}
