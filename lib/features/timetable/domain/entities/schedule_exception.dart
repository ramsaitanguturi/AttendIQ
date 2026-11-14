enum ScheduleExceptionType {
  holiday,
  cancelledClass,
  exam,
  event;

  String toShortString() {
    switch (this) {
      case ScheduleExceptionType.holiday:
        return 'HOLIDAY';
      case ScheduleExceptionType.cancelledClass:
        return 'CANCELLED_CLASS';
      case ScheduleExceptionType.exam:
        return 'EXAM';
      case ScheduleExceptionType.event:
        return 'EVENT';
    }
  }

  static ScheduleExceptionType fromString(String val) {
    final norm = val.trim().toUpperCase();
    for (final type in ScheduleExceptionType.values) {
      if (type.toShortString() == norm ||
          type.name.toUpperCase() == norm ||
          type.name == val) {
        return type;
      }
    }
    return ScheduleExceptionType.event;
  }
}

class ScheduleException {
  final int? id;
  final String? serverId;
  final DateTime date;
  final int? subjectId; // Optional; null applies to all subjects (e.g. HOLIDAY)
  final ScheduleExceptionType type;
  final String title;
  final String? description;

  // Sync Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  const ScheduleException({
    this.id,
    this.serverId,
    required this.date,
    this.subjectId,
    required this.type,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  ScheduleException copyWith({
    int? id,
    String? serverId,
    DateTime? date,
    int? subjectId,
    ScheduleExceptionType? type,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return ScheduleException(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      date: date ?? this.date,
      subjectId: subjectId ?? this.subjectId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleException &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          date == other.date &&
          subjectId == other.subjectId &&
          type == other.type &&
          title == other.title &&
          description == other.description &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isDirty == other.isDirty &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      serverId.hashCode ^
      date.hashCode ^
      subjectId.hashCode ^
      type.hashCode ^
      title.hashCode ^
      description.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'ScheduleException(id: $id, date: $date, subjectId: $subjectId, type: $type, title: $title, description: $description)';
  }
}
