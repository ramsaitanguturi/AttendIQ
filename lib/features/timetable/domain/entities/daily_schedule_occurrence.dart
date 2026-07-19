enum OccurrenceType {
  REGULAR_CLASS,
  EXTRA_CLASS,
  EXAM,
  EVENT;

  String toShortString() => name;

  static OccurrenceType fromString(String value) {
    return OccurrenceType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => OccurrenceType.REGULAR_CLASS,
    );
  }
}

enum OccurrenceStatus {
  UPCOMING,
  PRESENT,
  ABSENT,
  CANCELLED;

  String toShortString() => name;

  static OccurrenceStatus fromString(String value) {
    return OccurrenceStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => OccurrenceStatus.UPCOMING,
    );
  }
}

enum OccurrenceCreatedFrom {
  WEEKLY_RULE,
  MANUAL;

  String toShortString() => name;

  static OccurrenceCreatedFrom fromString(String value) {
    return OccurrenceCreatedFrom.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => OccurrenceCreatedFrom.WEEKLY_RULE,
    );
  }
}

class DailyScheduleOccurrence {
  final int? id;
  final String? serverId;
  final DateTime date;
  final int? subjectId;
  final String title;
  final String startTime; // "HH:mm"
  final String endTime;   // "HH:mm"
  final OccurrenceType type;
  final OccurrenceStatus status;
  final OccurrenceCreatedFrom createdFrom;
  final String? room;
  final String? faculty;
  final String? reason;

  // Sync Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  const DailyScheduleOccurrence({
    this.id,
    this.serverId,
    required this.date,
    this.subjectId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.status,
    required this.createdFrom,
    this.room,
    this.faculty,
    this.reason,
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  DailyScheduleOccurrence copyWith({
    int? id,
    String? serverId,
    DateTime? date,
    int? subjectId,
    String? title,
    String? startTime,
    String? endTime,
    OccurrenceType? type,
    OccurrenceStatus? status,
    OccurrenceCreatedFrom? createdFrom,
    String? room,
    String? faculty,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return DailyScheduleOccurrence(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      date: date ?? this.date,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      status: status ?? this.status,
      createdFrom: createdFrom ?? this.createdFrom,
      room: room ?? this.room,
      faculty: faculty ?? this.faculty,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyScheduleOccurrence &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          date == other.date &&
          subjectId == other.subjectId &&
          title == other.title &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          type == other.type &&
          status == other.status &&
          createdFrom == other.createdFrom &&
          room == other.room &&
          faculty == other.faculty &&
          reason == other.reason &&
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
      title.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      type.hashCode ^
      status.hashCode ^
      createdFrom.hashCode ^
      room.hashCode ^
      faculty.hashCode ^
      reason.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;

  @override
  String toString() {
    return 'DailyScheduleOccurrence(id: $id, date: $date, subjectId: $subjectId, title: $title, startTime: $startTime, endTime: $endTime, type: $type, status: $status, createdFrom: $createdFrom)';
  }
}
