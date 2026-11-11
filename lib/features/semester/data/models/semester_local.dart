import 'package:isar/isar.dart';

import '../../../../core/backup/backup_json_reader.dart';

part 'semester_local.g.dart';

@collection
class SemesterLocal {
  static const String statusDraft = 'draft';
  static const String statusActive = 'active';
  static const String statusArchived = 'archived';

  static const Set<String> validStatuses = <String>{
    statusDraft,
    statusActive,
    statusArchived,
  };

  int id = 0;

  @Index(unique: true)
  String? serverId;

  late String name;
  late DateTime startDate;
  late DateTime endDate;
  late double requiredAttendanceRate; // e.g. 75.0

  @Index()
  bool isActive = true;

  @Index()
  String status = statusActive; // 'draft', 'active', 'archived'

  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;

  SemesterLocal();

  static String normalizeStatusValue(String? rawStatus, {bool? isActive}) {
    final normalized = rawStatus?.trim().toLowerCase();
    if (normalized != null && validStatuses.contains(normalized)) {
      return normalized;
    }
    if (isActive != null) {
      return isActive ? statusActive : statusArchived;
    }
    return statusActive;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serverId': serverId,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'requiredAttendanceRate': requiredAttendanceRate,
      'isActive': isActive,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  factory SemesterLocal.fromJson(
    Map<String, dynamic> json, {
    String path = 'semester',
  }) {
    final rawStatus = BackupJsonReader.optionalNonNullStringField(
      json,
      'status',
      path,
      allowEmpty: false,
    );
    if (rawStatus != null &&
        !validStatuses.contains(rawStatus.trim().toLowerCase())) {
      throw FormatException(
        '$path.status: Invalid semester status "$rawStatus". Expected one of ${validStatuses.join(', ')}.',
      );
    }
    final isActiveFlag = BackupJsonReader.optionalNonNullBoolField(
      json,
      'isActive',
      path,
    );
    final resolvedStatus = normalizeStatusValue(
      rawStatus,
      isActive: isActiveFlag,
    );

    final startDate = BackupJsonReader.requireIsoDateTimeField(
      json,
      'startDate',
      path,
    );
    final endDate = BackupJsonReader.requireIsoDateTimeField(
      json,
      'endDate',
      path,
    );
    final normStart =
        DateTime.utc(startDate.year, startDate.month, startDate.day);
    final normEnd = DateTime.utc(endDate.year, endDate.month, endDate.day);
    if (!normStart.isBefore(normEnd)) {
      throw FormatException(
        '$path: startDate must be strictly before endDate.',
      );
    }

    final nowUtc = DateTime.now().toUtc();
    return SemesterLocal()
      ..id = BackupJsonReader.optionalNonNullIntField(
            json,
            'id',
            path,
            min: 0,
          ) ??
          0
      ..serverId = BackupJsonReader.nullableStringField(json, 'serverId', path)
      ..name = BackupJsonReader.requireNonEmptyStringField(json, 'name', path)
      ..startDate = startDate
      ..endDate = endDate
      ..requiredAttendanceRate = BackupJsonReader.optionalNonNullDoubleField(
            json,
            'requiredAttendanceRate',
            path,
            min: 0.0,
            max: 100.0,
          ) ??
          75.0
      ..status = resolvedStatus
      ..isActive = resolvedStatus == statusActive
      ..createdAt = BackupJsonReader.optionalNonNullIsoDateTimeField(
            json,
            'createdAt',
            path,
          ) ??
          nowUtc
      ..updatedAt = BackupJsonReader.optionalNonNullIsoDateTimeField(
            json,
            'updatedAt',
            path,
          ) ??
          nowUtc
      ..isDirty = BackupJsonReader.optionalNonNullBoolField(
            json,
            'isDirty',
            path,
          ) ??
          false
      ..isDeleted = BackupJsonReader.optionalNonNullBoolField(
            json,
            'isDeleted',
            path,
          ) ??
          false;
  }
}
