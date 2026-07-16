enum SubjectType {
  THEORY,
  LAB;

  String toShortString() => name;
}

class Subject {
  final int? id;
  final String? serverId;
  final int semesterId;
  final String name;
  final String code;
  final String? faculty;
  final int credits;
  final double attendanceTarget;
  final String color; // Hex string e.g. '#FF5733'
  final SubjectType type;
  
  // Sync metadata
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  const Subject({
    this.id,
    this.serverId,
    required this.semesterId,
    required this.name,
    required this.code,
    this.faculty,
    required this.credits,
    required this.attendanceTarget,
    required this.color,
    required this.type,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  Subject copyWith({
    int? id,
    String? serverId,
    int? semesterId,
    String? name,
    String? code,
    String? faculty,
    int? credits,
    double? attendanceTarget,
    String? color,
    SubjectType? type,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return Subject(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      semesterId: semesterId ?? this.semesterId,
      name: name ?? this.name,
      code: code ?? this.code,
      faculty: faculty ?? this.faculty,
      credits: credits ?? this.credits,
      attendanceTarget: attendanceTarget ?? this.attendanceTarget,
      color: color ?? this.color,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          semesterId == other.semesterId &&
          name == other.name &&
          code == other.code &&
          faculty == other.faculty &&
          credits == other.credits &&
          attendanceTarget == other.attendanceTarget &&
          color == other.color &&
          type == other.type &&
          updatedAt == other.updatedAt &&
          isDirty == other.isDirty &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      serverId.hashCode ^
      semesterId.hashCode ^
      name.hashCode ^
      code.hashCode ^
      faculty.hashCode ^
      credits.hashCode ^
      attendanceTarget.hashCode ^
      color.hashCode ^
      type.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'Subject(id: $id, serverId: $serverId, semesterId: $semesterId, name: $name, code: $code, faculty: $faculty, credits: $credits, attendanceTarget: $attendanceTarget, color: $color, type: $type, updatedAt: $updatedAt, isDirty: $isDirty, isDeleted: $isDeleted)';
  }
}
