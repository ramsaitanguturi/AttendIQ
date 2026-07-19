import 'package:isar/isar.dart';

part 'user_preferences_local.g.dart';

@collection
class UserPreferencesLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId; // Remote Firestore ID/UID

  late String themeMode; // 'light', 'dark', 'system'
  late double defaultAttendanceTarget;
  late int classReminderOffset;
  late bool enableNotifications;
  late bool enableAttendanceWarnings;
  late bool weeklyReportEnabled;
  DateTime? lastSyncTime;

  // Sync Metadata
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
