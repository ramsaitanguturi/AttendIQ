class TimetableTemplate {
  final int? id;
  final String? serverId;
  final int subjectId;
  final int weekday; // 1 = Monday, 7 = Sunday
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final String? room;
  final String? faculty;
  final String? notes;

  // Sync Metadata
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  const TimetableTemplate({
    this.id,
    this.serverId,
    required this.subjectId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    this.room,
    this.faculty,
    this.notes,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  TimetableTemplate copyWith({
    int? id,
    String? serverId,
    int? subjectId,
    int? weekday,
    String? startTime,
    String? endTime,
    String? room,
    String? faculty,
    String? notes,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return TimetableTemplate(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      subjectId: subjectId ?? this.subjectId,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      faculty: faculty ?? this.faculty,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          subjectId == other.subjectId &&
          weekday == other.weekday &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          room == other.room &&
          faculty == other.faculty &&
          notes == other.notes &&
          updatedAt == other.updatedAt &&
          isDirty == other.isDirty &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      serverId.hashCode ^
      subjectId.hashCode ^
      weekday.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      room.hashCode ^
      faculty.hashCode ^
      notes.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'TimetableTemplate(id: $id, serverId: $serverId, subjectId: $subjectId, weekday: $weekday, startTime: $startTime, endTime: $endTime, room: $room, faculty: $faculty, notes: $notes, updatedAt: $updatedAt, isDirty: $isDirty, isDeleted: $isDeleted)';
  }
}
