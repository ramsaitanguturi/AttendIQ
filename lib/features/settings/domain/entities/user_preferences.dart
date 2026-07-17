class UserPreferences {
  final String id; // User UID
  final String themeMode; // 'light', 'dark', 'system'
  final double defaultAttendanceTarget;
  final int classReminderOffset; // offset in minutes
  final bool enableNotifications;
  final bool enableAttendanceWarnings;
  final bool weeklyReportEnabled;
  final DateTime? lastSyncTime;

  const UserPreferences({
    required this.id,
    required this.themeMode,
    required this.defaultAttendanceTarget,
    required this.classReminderOffset,
    required this.enableNotifications,
    required this.enableAttendanceWarnings,
    required this.weeklyReportEnabled,
    this.lastSyncTime,
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
          lastSyncTime == other.lastSyncTime;

  @override
  int get hashCode =>
      id.hashCode ^
      themeMode.hashCode ^
      defaultAttendanceTarget.hashCode ^
      classReminderOffset.hashCode ^
      enableNotifications.hashCode ^
      enableAttendanceWarnings.hashCode ^
      weeklyReportEnabled.hashCode ^
      lastSyncTime.hashCode;

  @override
  String toString() {
    return 'UserPreferences(id: $id, themeMode: $themeMode, defaultAttendanceTarget: $defaultAttendanceTarget, classReminderOffset: $classReminderOffset, enableNotifications: $enableNotifications, enableAttendanceWarnings: $enableAttendanceWarnings, weeklyReportEnabled: $weeklyReportEnabled, lastSyncTime: $lastSyncTime)';
  }
}
