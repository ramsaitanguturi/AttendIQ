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
  final int? occurrenceId;
  final int? legacyEventId;
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
    this.occurrenceId,
    this.legacyEventId,
    int? eventId,
    required this.subjectId,
    required this.status,
    required this.markedAt,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  }) : eventId = eventId ?? occurrenceId ?? 0;

  int get effectiveOccurrenceId => occurrenceId ?? eventId;

  AttendanceRecord copyWith({
    int? id,
    String? serverId,
    int? occurrenceId,
    int? legacyEventId,
    int? eventId,
    int? subjectId,
    AttendanceStatus? status,
    DateTime? markedAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    final nextOccurrenceId = occurrenceId ?? this.occurrenceId;
    return AttendanceRecord(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      occurrenceId: nextOccurrenceId,
      legacyEventId: legacyEventId ?? this.legacyEventId,
      eventId: eventId ?? (occurrenceId ?? this.eventId),
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
          occurrenceId == other.occurrenceId &&
          legacyEventId == other.legacyEventId &&
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
      occurrenceId.hashCode ^
      legacyEventId.hashCode ^
      eventId.hashCode ^
      subjectId.hashCode ^
      status.hashCode ^
      markedAt.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, serverId: $serverId, occurrenceId: $occurrenceId, legacyEventId: $legacyEventId, eventId: $eventId, subjectId: $subjectId, status: $status, markedAt: $markedAt, updatedAt: $updatedAt, isDirty: $isDirty, isDeleted: $isDeleted)';
  }
}
