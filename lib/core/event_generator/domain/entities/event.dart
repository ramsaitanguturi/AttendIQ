enum EventType {
  regularClass,
  lab,
  tutorial;

  String toShortString() {
    switch (this) {
      case EventType.regularClass:
        return 'REGULAR_CLASS';
      case EventType.lab:
        return 'LAB';
      case EventType.tutorial:
        return 'TUTORIAL';
    }
  }

  static EventType fromString(String value) {
    switch (value.trim().toUpperCase()) {
      case 'REGULAR_CLASS':
      case 'REGULARCLASS':
        return EventType.regularClass;
      case 'LAB':
        return EventType.lab;
      case 'TUTORIAL':
        return EventType.tutorial;
      default:
        return EventType.regularClass;
    }
  }
}

enum EventStatus {
  unmarked,
  present,
  absent,
  cancelled;

  String toShortString() {
    switch (this) {
      case EventStatus.unmarked:
        return 'UNMARKED';
      case EventStatus.present:
        return 'PRESENT';
      case EventStatus.absent:
        return 'ABSENT';
      case EventStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static EventStatus fromString(String value) {
    switch (value.trim().toUpperCase()) {
      case 'UNMARKED':
        return EventStatus.unmarked;
      case 'PRESENT':
        return EventStatus.present;
      case 'ABSENT':
        return EventStatus.absent;
      case 'CANCELLED':
        return EventStatus.cancelled;
      default:
        return EventStatus.unmarked;
    }
  }
}

class Event {
  final int? id;
  final String? serverId;
  final int subjectId;
  final DateTime date;
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final EventType eventType;
  final EventStatus status;

  // Sync Metadata
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  const Event({
    this.id,
    this.serverId,
    required this.subjectId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.eventType,
    required this.status,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  Event copyWith({
    int? id,
    String? serverId,
    int? subjectId,
    DateTime? date,
    String? startTime,
    String? endTime,
    EventType? eventType,
    EventStatus? status,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return Event(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      subjectId: subjectId ?? this.subjectId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          subjectId == other.subjectId &&
          date == other.date &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          eventType == other.eventType &&
          status == other.status &&
          updatedAt == other.updatedAt &&
          isDirty == other.isDirty &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      serverId.hashCode ^
      subjectId.hashCode ^
      date.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      eventType.hashCode ^
      status.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'Event(id: $id, serverId: $serverId, subjectId: $subjectId, date: $date, startTime: $startTime, endTime: $endTime, eventType: $eventType, status: $status, updatedAt: $updatedAt, isDirty: $isDirty, isDeleted: $isDeleted)';
  }
}
