import 'package:isar/isar.dart';

part 'academic_event_local.g.dart';

@collection
class AcademicEventLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  late String title;
  String? description;

  @Index()
  late DateTime date;

  String? startTime;
  String? endTime;

  late String type; // "EVENT", "EXAM", "ASSIGNMENT", "DEADLINE"

  // Sync Metadata
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
