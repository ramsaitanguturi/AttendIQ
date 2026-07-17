import 'package:isar/isar.dart';

part 'event_local.g.dart';

@collection
class EventLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  @Index()
  late int subjectId;

  @Index()
  late DateTime date;

  late String startTime; // "HH:mm"
  late String endTime; // "HH:mm"
  
  late String eventType; // REGULAR_CLASS, LAB, TUTORIAL
  late String status; // UNMARKED, PRESENT, ABSENT, CANCELLED

  // Sync Metadata
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDirty;
  late bool isDeleted;
}
