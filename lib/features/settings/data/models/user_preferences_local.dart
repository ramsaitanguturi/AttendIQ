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

  // Late Attendance Configuration
  bool enableLateAttendance = false;
  double lateAttendanceWeight = 0.5;
  String lateAttendancePolicy = 'weighted'; // 'present', 'absent', 'weighted'

  // Glassy Interface Theme (Default: OFF)
  bool enableGlassyTheme = false;

  // AI Advisor (Default: ON)
  bool enableAiAdvisor = true;

  // Advanced Notification Preferences
  bool quietHoursEnabled = false;
  int quietHoursStartHour = 22;
  int quietHoursEndHour = 7;
  bool notificationSound = true;
  bool notificationVibration = true;
  bool missedAttendanceReminderEnabled = true;
  int missedAttendanceReminderOffset = 30; // minutes after class

  // Cloud Sync Preferences (Opt-in)
  bool enableCloudSync = false;
  bool cloudSyncConsentGiven = false;

  // Backup preferences
  bool enableAutoBackup = false;
  DateTime? lastBackupDate;
  int autoBackupDay = 7;
  int autoBackupHour = 2;

  // Sync Metadata
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}
