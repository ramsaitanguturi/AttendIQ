import 'package:isar/isar.dart';

part 'academic_task_local.g.dart';

@collection
class AcademicTaskLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  late String title;
  String? description;

  @Index()
  late String taskType; // Enum string

  @Index()
  int? subjectId;

  @Index()
  late DateTime startDate;

  @Index()
  late DateTime dueDate;

  @Index()
  late String priority; // Enum string

  @Index()
  late String status; // Enum string

  late String reminder; // Enum string

  // Sync Metadata
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
