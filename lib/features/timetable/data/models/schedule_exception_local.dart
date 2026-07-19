import 'package:isar/isar.dart';

part 'schedule_exception_local.g.dart';

@collection
class ScheduleExceptionLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  @Index()
  late DateTime date;

  @Index()
  int? subjectId;

  late String type; // "HOLIDAY", "CANCELLED_CLASS", "EXAM", "EVENT"

  late String title;
  String? description;

  // Sync Metadata
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
