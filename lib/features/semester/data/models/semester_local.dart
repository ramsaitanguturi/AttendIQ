import 'package:isar/isar.dart';

part 'semester_local.g.dart';

@collection
class SemesterLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  late String name;
  late DateTime startDate;
  late DateTime endDate;
  late double requiredAttendanceRate; // e.g. 75.0

  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;

  SemesterLocal();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serverId': serverId,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'requiredAttendanceRate': requiredAttendanceRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  factory SemesterLocal.fromJson(Map<String, dynamic> json) {
    return SemesterLocal()
      ..id = json['id'] as int? ?? 0
      ..serverId = json['serverId'] as String?
      ..name = json['name'] as String? ?? ''
      ..startDate = DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now()
      ..endDate = DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now()
      ..requiredAttendanceRate = (json['requiredAttendanceRate'] as num?)?.toDouble() ?? 75.0
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now()
      ..updatedAt = DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now()
      ..isDirty = json['isDirty'] as bool? ?? false
      ..isDeleted = json['isDeleted'] as bool? ?? false;
  }
}
