enum AcademicEventType {
  EVENT,
  EXAM,
  ASSIGNMENT,
  DEADLINE;

  String toShortString() => name;

  static AcademicEventType fromString(String value) {
    return AcademicEventType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => AcademicEventType.EVENT,
    );
  }
}

class AcademicEvent {
  final int? id;
  final String? serverId;
  final String title;
  final String? description;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final AcademicEventType type;

  // Sync Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  const AcademicEvent({
    this.id,
    this.serverId,
    required this.title,
    this.description,
    required this.date,
    this.startTime,
    this.endTime,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  AcademicEvent copyWith({
    int? id,
    String? serverId,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    AcademicEventType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return AcademicEvent(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicEvent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          title == other.title &&
          description == other.description &&
          date == other.date &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          type == other.type &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isDirty == other.isDirty &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      serverId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      date.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      type.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'AcademicEvent(id: $id, title: $title, date: $date, type: $type, startTime: $startTime, endTime: $endTime)';
  }
}
