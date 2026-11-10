import 'package:isar/isar.dart';

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

  factory SemesterLocal.fromJson(Map<String, dynamic> json) {
    final resolvedStatus = normalizeStatusValue(
      json['status'] as String?,
      isActive: json['isActive'] as bool?,
    );
    return SemesterLocal()
      ..id = json['id'] as int? ?? 0
      ..serverId = json['serverId'] as String?
      ..name = json['name'] as String? ?? ''
      ..startDate = DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.now()
      ..endDate =
          DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now()
      ..requiredAttendanceRate =
          (json['requiredAttendanceRate'] as num?)?.toDouble() ?? 75.0
      ..status = resolvedStatus
      ..isActive = resolvedStatus == statusActive
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now()
      ..updatedAt = DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now()
      ..isDirty = json['isDirty'] as bool? ?? false
      ..isDeleted = json['isDeleted'] as bool? ?? false;
  }
}
