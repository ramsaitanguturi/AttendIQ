import '../../../subject/domain/entities/subject.dart';

class WeeklyScheduleRule {
  final int? id;
  final String? serverId;
  final int subjectId;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final String? room;
  final String? faculty;
  final SubjectType type;
  final bool isActive;

  // Sync Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  const WeeklyScheduleRule({
    this.id,
    this.serverId,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.faculty,
    this.type = SubjectType.THEORY,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  WeeklyScheduleRule copyWith({
    int? id,
    String? serverId,
    int? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? faculty,
    SubjectType? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return WeeklyScheduleRule(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      subjectId: subjectId ?? this.subjectId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      faculty: faculty ?? this.faculty,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyScheduleRule &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          subjectId == other.subjectId &&
          dayOfWeek == other.dayOfWeek &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          room == other.room &&
          faculty == other.faculty &&
          type == other.type &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isDirty == other.isDirty &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      serverId.hashCode ^
      subjectId.hashCode ^
      dayOfWeek.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      room.hashCode ^
      faculty.hashCode ^
      type.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'WeeklyScheduleRule(id: $id, subjectId: $subjectId, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, room: $room, faculty: $faculty, type: $type, isActive: $isActive)';
  }
}

