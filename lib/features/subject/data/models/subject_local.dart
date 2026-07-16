import 'package:isar/isar.dart';

part 'subject_local.g.dart';

@collection
class SubjectLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  @Index()
  late int semesterId;

  late String name;
  late String code;
  String? faculty;
  late int credits;
  late double attendanceTarget;
  late String color;

  late String type; // THEORY or LAB

  // Sync Metadata
  late DateTime updatedAt;
  late bool isDirty;
  late bool isDeleted;
}
