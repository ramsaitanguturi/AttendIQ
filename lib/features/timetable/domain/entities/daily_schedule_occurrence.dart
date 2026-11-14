enum OccurrenceType {
  regularClass,
  extraClass,
  exam,
  event;

  String toShortString() {
    switch (this) {
      case OccurrenceType.regularClass:
        return 'REGULAR_CLASS';
      case OccurrenceType.extraClass:
        return 'EXTRA_CLASS';
      case OccurrenceType.exam:
        return 'EXAM';
      case OccurrenceType.event:
        return 'EVENT';
    }
  }

  static OccurrenceType fromString(String value) {
    final norm = value.trim().toUpperCase();
    for (final type in OccurrenceType.values) {
      if (type.toShortString() == norm ||
          type.name.toUpperCase() == norm ||
          type.name == value) {
        return type;
      }
    }
    return OccurrenceType.regularClass;
  }
}

enum OccurrenceStatus {
  upcoming,
  present,
  absent,
  cancelled,
  late;

  String toShortString() {
    switch (this) {
      case OccurrenceStatus.upcoming:
        return 'UPCOMING';
      case OccurrenceStatus.present:
        return 'PRESENT';
      case OccurrenceStatus.absent:
        return 'ABSENT';
      case OccurrenceStatus.cancelled:
        return 'CANCELLED';
      case OccurrenceStatus.late:
        return 'LATE';
    }
  }

  static OccurrenceStatus fromString(String value) {
    final norm = value.trim().toUpperCase();
    for (final status in OccurrenceStatus.values) {
      if (status.toShortString() == norm ||
          status.name.toUpperCase() == norm ||
          status.name == value) {
        return status;
      }
    }
    return OccurrenceStatus.upcoming;
  }
}

enum OccurrenceCreatedFrom {
  weeklyRule,
  manual;

  String toShortString() {
    switch (this) {
      case OccurrenceCreatedFrom.weeklyRule:
        return 'WEEKLY_RULE';
      case OccurrenceCreatedFrom.manual:
        return 'MANUAL';
    }
  }

  static OccurrenceCreatedFrom fromString(String value) {
    final norm = value.trim().toUpperCase();
    for (final source in OccurrenceCreatedFrom.values) {
      if (source.toShortString() == norm ||
          source.name.toUpperCase() == norm ||
          source.name == value) {
        return source;
      }
    }
    return OccurrenceCreatedFrom.weeklyRule;
  }
}

class DailyScheduleOccurrence {
  final int? id;
  final String? serverId;
  final DateTime date;
  final int? subjectId;
  final int? ruleId;
  final int? legacyEventId;
  final String? slotKey;
  final String title;
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
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
    this.ruleId,
    this.legacyEventId,
    this.slotKey,
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
    int? ruleId,
    int? legacyEventId,
    String? slotKey,
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
      ruleId: ruleId ?? this.ruleId,
      legacyEventId: legacyEventId ?? this.legacyEventId,
      slotKey: slotKey ?? this.slotKey,
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
          ruleId == other.ruleId &&
          legacyEventId == other.legacyEventId &&
          slotKey == other.slotKey &&
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
      ruleId.hashCode ^
      legacyEventId.hashCode ^
      slotKey.hashCode ^
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
