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
  }) {
    return UserPreferences(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      defaultAttendanceTarget: defaultAttendanceTarget ?? this.defaultAttendanceTarget,
      classReminderOffset: classReminderOffset ?? this.classReminderOffset,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableAttendanceWarnings: enableAttendanceWarnings ?? this.enableAttendanceWarnings,
      weeklyReportEnabled: weeklyReportEnabled ?? this.weeklyReportEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      autoBackupDay: autoBackupDay ?? this.autoBackupDay,
      autoBackupHour: autoBackupHour ?? this.autoBackupHour,
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
          autoBackupHour == other.autoBackupHour;

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
      autoBackupHour.hashCode;

  @override
  String toString() {
    return 'UserPreferences(id: $id, themeMode: $themeMode, defaultAttendanceTarget: $defaultAttendanceTarget, classReminderOffset: $classReminderOffset, enableNotifications: $enableNotifications, enableAttendanceWarnings: $enableAttendanceWarnings, weeklyReportEnabled: $weeklyReportEnabled, lastSyncTime: $lastSyncTime, enableAutoBackup: $enableAutoBackup, lastBackupDate: $lastBackupDate, autoBackupDay: $autoBackupDay, autoBackupHour: $autoBackupHour)';
  }
}
