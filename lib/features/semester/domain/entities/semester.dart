enum SemesterStatus {
  draft,
  active,
  archived;

  String toShortString() => name;

  String get displayName {
    switch (this) {
      case SemesterStatus.draft:
        return 'Draft';
      case SemesterStatus.active:
        return 'Active';
      case SemesterStatus.archived:
        return 'Archived';
    }
  }

  static SemesterStatus? tryParse(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    for (final status in SemesterStatus.values) {
      if (status.name == normalized) {
        return status;
      }
    }
    return null;
  }

  static SemesterStatus fromString(String? value) {
    return tryParse(value) ?? SemesterStatus.active;
  }
}

class Semester {
  final String? id;
  final int? localId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final double requiredAttendanceRate;
  final SemesterStatus status;

  const Semester({
    this.id,
    this.localId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.requiredAttendanceRate,
    this.status = SemesterStatus.active,
  });

  bool get isActive => status == SemesterStatus.active;
  bool get isArchived => status == SemesterStatus.archived;
  bool get isDraft => status == SemesterStatus.draft;

  Semester copyWith({
    String? id,
    int? localId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    double? requiredAttendanceRate,
    SemesterStatus? status,
  }) {
    return Semester(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      requiredAttendanceRate:
          requiredAttendanceRate ?? this.requiredAttendanceRate,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Semester &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          localId == other.localId &&
          name == other.name &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          requiredAttendanceRate == other.requiredAttendanceRate &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      localId.hashCode ^
      name.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      requiredAttendanceRate.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'Semester(id: $id, localId: $localId, name: $name, '
        'startDate: $startDate, endDate: $endDate, '
        'requiredAttendanceRate: $requiredAttendanceRate, status: ${status.name})';
  }
}
