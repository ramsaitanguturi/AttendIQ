enum AttendanceStatus {
  PRESENT,
  ABSENT,
  CANCELLED,
  EXTRA_PRESENT,
  EXTRA_ABSENT;

  String toShortString() => name;
  
  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.name == value || e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AttendanceStatus.PRESENT,
    );
  }
}

class AttendanceRecord {
  final int? id;
  final String? serverId;
  final int eventId;
  final int subjectId;
  final AttendanceStatus status;
  final DateTime markedAt;

  // Sync Metadata
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  const AttendanceRecord({
    this.id,
    this.serverId,
    required this.eventId,
    required this.subjectId,
    required this.status,
    required this.markedAt,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  AttendanceRecord copyWith({
    int? id,
    String? serverId,
    int? eventId,
    int? subjectId,
    AttendanceStatus? status,
    DateTime? markedAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      eventId: eventId ?? this.eventId,
      subjectId: subjectId ?? this.subjectId,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          eventId == other.eventId &&
          subjectId == other.subjectId &&
          status == other.status &&
          markedAt == other.markedAt &&
          updatedAt == other.updatedAt &&
          isDirty == other.isDirty &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      serverId.hashCode ^
      eventId.hashCode ^
      subjectId.hashCode ^
      status.hashCode ^
      markedAt.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, serverId: $serverId, eventId: $eventId, subjectId: $subjectId, status: $status, markedAt: $markedAt, updatedAt: $updatedAt, isDirty: $isDirty, isDeleted: $isDeleted)';
  }
}
