import 'package:isar/isar.dart';

part 'attendance_record_local.g.dart';

@collection
class AttendanceRecordLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  @Index()
  late int eventId;

  @Index()
  late int subjectId;

  late String status; // PRESENT, ABSENT, CANCELLED, EXTRA_PRESENT, EXTRA_ABSENT

  late DateTime markedAt;

  // Sync Metadata
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
