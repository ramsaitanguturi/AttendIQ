import 'package:isar/isar.dart';

part 'timetable_template_local.g.dart';

@collection
class TimetableTemplateLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  @Index()
  late int subjectId;

  @Index()
  late int weekday; // 1 = Monday, 7 = Sunday

  late String startTime; // "HH:mm"
  late String endTime; // "HH:mm"
  
  String? room;
  String? faculty;
  String? notes;

  // Sync Metadata
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDirty;
  late bool isDeleted;
}
