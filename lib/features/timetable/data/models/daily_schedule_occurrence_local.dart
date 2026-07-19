import 'package:isar/isar.dart';

part 'daily_schedule_occurrence_local.g.dart';

@collection
class DailyScheduleOccurrenceLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  @Index()
  late DateTime date;

  @Index()
  int? subjectId;

  late String title;
  late String startTime; // "HH:mm"
  late String endTime;   // "HH:mm"

  late String type;        // "REGULAR_CLASS", "EXTRA_CLASS", "EXAM", "EVENT"
  late String status;      // "UPCOMING", "PRESENT", "ABSENT", "CANCELLED"
  late String createdFrom; // "WEEKLY_RULE", "MANUAL"

  String? room;
  String? faculty;
  String? reason;

  // Sync Metadata
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
