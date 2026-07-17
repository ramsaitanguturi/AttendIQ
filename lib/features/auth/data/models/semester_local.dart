import 'package:isar/isar.dart';

part 'semester_local.g.dart';

@collection
class SemesterLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId; // Remote Firestore ID

  late String name;
  late DateTime startDate;
  late DateTime endDate;
  late double requiredAttendanceRate; // e.g. 75.0

  // Sync Metadata
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDirty;
  late bool isDeleted;
}
