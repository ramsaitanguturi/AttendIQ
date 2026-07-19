import 'package:isar/isar.dart';

part 'weekly_schedule_rule_local.g.dart';

@collection
class WeeklyScheduleRuleLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  @Index()
  late int subjectId;

  @Index()
  late int dayOfWeek; // 1 = Monday, 7 = Sunday

  late String startTime; // "HH:mm"
  late String endTime; // "HH:mm"

  String? room;
  String? faculty;
  String type = 'THEORY'; // THEORY or LAB
  bool isActive = true;

  // Sync Metadata
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
