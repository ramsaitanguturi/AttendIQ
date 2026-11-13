class UserPreferences {
  final String id; // User UID
  final String themeMode; // 'light', 'dark', 'system'
  final double defaultAttendanceTarget;
  final int classReminderOffset; // offset in minutes
  final bool enableNotifications;
  final bool enableAttendanceWarnings;
  final bool weeklyReportEnabled;
  final DateTime? lastSyncTime;
  final bool enableAutoBackup;
  final DateTime? lastBackupDate;
  final int autoBackupDay; // 1-7, where 7 = Sunday
  final int autoBackupHour; // 0-23, default 2

  // Late Attendance Configuration
  final double lateAttendanceWeight;
  final String lateAttendancePolicy; // 'present', 'absent', 'weighted'

  // Advanced Notification Preferences
  final bool quietHoursEnabled;
  final int quietHoursStartHour;
  final int quietHoursEndHour;
  final bool notificationSound;
  final bool notificationVibration;
  final bool missedAttendanceReminderEnabled;
  final int missedAttendanceReminderOffset;

  // Cloud Sync Preferences (Opt-in)
  final bool enableCloudSync;
  final bool cloudSyncConsentGiven;

  const UserPreferences({
    required this.id,
    required this.themeMode,
    required this.defaultAttendanceTarget,
    required this.classReminderOffset,
    required this.enableNotifications,
    required this.enableAttendanceWarnings,
    required this.weeklyReportEnabled,
    this.lastSyncTime,
    this.enableAutoBackup = false,
    this.lastBackupDate,
    this.autoBackupDay = 7,
    this.autoBackupHour = 2,
    this.lateAttendanceWeight = 0.5,
    this.lateAttendancePolicy = 'weighted',
    this.quietHoursEnabled = false,
    this.quietHoursStartHour = 22,
    this.quietHoursEndHour = 7,
    this.notificationSound = true,
    this.notificationVibration = true,
    this.missedAttendanceReminderEnabled = true,
    this.missedAttendanceReminderOffset = 30,
    this.enableCloudSync = false,
    this.cloudSyncConsentGiven = false,
  });

  UserPreferences copyWith({
    String? id,
    String? themeMode,
    double? defaultAttendanceTarget,
    int? classReminderOffset,
    bool? enableNotifications,
    bool? enableAttendanceWarnings,
    bool? weeklyReportEnabled,
    DateTime? lastSyncTime,
    bool? enableAutoBackup,
    DateTime? lastBackupDate,
    int? autoBackupDay,
    int? autoBackupHour,
    double? lateAttendanceWeight,
    String? lateAttendancePolicy,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursEndHour,
    bool? notificationSound,
    bool? notificationVibration,
    bool? missedAttendanceReminderEnabled,
    int? missedAttendanceReminderOffset,
    bool? enableCloudSync,
    bool? cloudSyncConsentGiven,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      defaultAttendanceTarget:
          defaultAttendanceTarget ?? this.defaultAttendanceTarget,
      classReminderOffset: classReminderOffset ?? this.classReminderOffset,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableAttendanceWarnings:
          enableAttendanceWarnings ?? this.enableAttendanceWarnings,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      autoBackupDay: autoBackupDay ?? this.autoBackupDay,
      autoBackupHour: autoBackupHour ?? this.autoBackupHour,
      lateAttendanceWeight: lateAttendanceWeight ?? this.lateAttendanceWeight,
      lateAttendancePolicy: lateAttendancePolicy ?? this.lateAttendancePolicy,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
      notificationSound: notificationSound ?? this.notificationSound,
      notificationVibration:
          notificationVibration ?? this.notificationVibration,
      missedAttendanceReminderEnabled:
          missedAttendanceReminderEnabled ?? this.missedAttendanceReminderEnabled,
      missedAttendanceReminderOffset:
          missedAttendanceReminderOffset ?? this.missedAttendanceReminderOffset,
      enableCloudSync: enableCloudSync ?? this.enableCloudSync,
      cloudSyncConsentGiven:
          cloudSyncConsentGiven ?? this.cloudSyncConsentGiven,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferences &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          themeMode == other.themeMode &&
          defaultAttendanceTarget == other.defaultAttendanceTarget &&
          classReminderOffset == other.classReminderOffset &&
          enableNotifications == other.enableNotifications &&
          enableAttendanceWarnings == other.enableAttendanceWarnings &&
          weeklyReportEnabled == other.weeklyReportEnabled &&
          lastSyncTime == other.lastSyncTime &&
          enableAutoBackup == other.enableAutoBackup &&
          lastBackupDate == other.lastBackupDate &&
          autoBackupDay == other.autoBackupDay &&
          autoBackupHour == other.autoBackupHour &&
          lateAttendanceWeight == other.lateAttendanceWeight &&
          lateAttendancePolicy == other.lateAttendancePolicy &&
          quietHoursEnabled == other.quietHoursEnabled &&
          quietHoursStartHour == other.quietHoursStartHour &&
          quietHoursEndHour == other.quietHoursEndHour &&
          notificationSound == other.notificationSound &&
          notificationVibration == other.notificationVibration &&
          missedAttendanceReminderEnabled ==
              other.missedAttendanceReminderEnabled &&
          missedAttendanceReminderOffset ==
              other.missedAttendanceReminderOffset &&
          enableCloudSync == other.enableCloudSync &&
          cloudSyncConsentGiven == other.cloudSyncConsentGiven;

  @override
  int get hashCode =>
      id.hashCode ^
      themeMode.hashCode ^
      defaultAttendanceTarget.hashCode ^
      classReminderOffset.hashCode ^
      enableNotifications.hashCode ^
      enableAttendanceWarnings.hashCode ^
      weeklyReportEnabled.hashCode ^
      lastSyncTime.hashCode ^
      enableAutoBackup.hashCode ^
      lastBackupDate.hashCode ^
      autoBackupDay.hashCode ^
      autoBackupHour.hashCode ^
      lateAttendanceWeight.hashCode ^
      lateAttendancePolicy.hashCode ^
      quietHoursEnabled.hashCode ^
      quietHoursStartHour.hashCode ^
      quietHoursEndHour.hashCode ^
      notificationSound.hashCode ^
      notificationVibration.hashCode ^
      missedAttendanceReminderEnabled.hashCode ^
      missedAttendanceReminderOffset.hashCode ^
      enableCloudSync.hashCode ^
      cloudSyncConsentGiven.hashCode;

  @override
  String toString() {
    return 'UserPreferences(id: $id, themeMode: $themeMode, defaultAttendanceTarget: $defaultAttendanceTarget, classReminderOffset: $classReminderOffset, enableNotifications: $enableNotifications, enableAttendanceWarnings: $enableAttendanceWarnings, weeklyReportEnabled: $weeklyReportEnabled, lastSyncTime: $lastSyncTime, enableAutoBackup: $enableAutoBackup, lastBackupDate: $lastBackupDate, autoBackupDay: $autoBackupDay, autoBackupHour: $autoBackupHour, lateAttendanceWeight: $lateAttendanceWeight, lateAttendancePolicy: $lateAttendancePolicy, quietHoursEnabled: $quietHoursEnabled, quietHoursStartHour: $quietHoursStartHour, quietHoursEndHour: $quietHoursEndHour, notificationSound: $notificationSound, notificationVibration: $notificationVibration, missedAttendanceReminderEnabled: $missedAttendanceReminderEnabled, missedAttendanceReminderOffset: $missedAttendanceReminderOffset, enableCloudSync: $enableCloudSync, cloudSyncConsentGiven: $cloudSyncConsentGiven)';
  }
}
