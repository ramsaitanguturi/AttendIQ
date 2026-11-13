import 'package:isar/isar.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/user_preferences_local.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Isar _isar;

  SettingsRepositoryImpl({
    required Isar isar,
  }) : _isar = isar;

  UserPreferences _toEntity(UserPreferencesLocal local) {
    return UserPreferences(
      id: local.serverId ?? 'local_user',
      themeMode: local.themeMode,
      defaultAttendanceTarget: local.defaultAttendanceTarget,
      classReminderOffset: local.classReminderOffset,
      enableNotifications: local.enableNotifications,
      enableAttendanceWarnings: local.enableAttendanceWarnings,
      weeklyReportEnabled: local.weeklyReportEnabled,
      enableAutoBackup: local.enableAutoBackup,
      lastBackupDate: local.lastBackupDate,
      autoBackupDay: local.autoBackupDay,
      autoBackupHour: local.autoBackupHour,
      enableLateAttendance: local.enableLateAttendance,
      lateAttendanceWeight: local.lateAttendanceWeight,
      lateAttendancePolicy: local.lateAttendancePolicy,
      enableGlassyTheme: local.enableGlassyTheme,
      enableAiAdvisor: local.enableAiAdvisor,
      quietHoursEnabled: local.quietHoursEnabled,
      quietHoursStartHour: local.quietHoursStartHour,
      quietHoursEndHour: local.quietHoursEndHour,
      notificationSound: local.notificationSound,
      notificationVibration: local.notificationVibration,
      missedAttendanceReminderEnabled: local.missedAttendanceReminderEnabled,
      missedAttendanceReminderOffset: local.missedAttendanceReminderOffset,
      enableCloudSync: local.enableCloudSync,
      cloudSyncConsentGiven: local.cloudSyncConsentGiven,
    );
  }

  UserPreferencesLocal _toLocal(UserPreferences preferences) {
    final local = UserPreferencesLocal()
      ..serverId = preferences.id.isEmpty ? 'local_user' : preferences.id
      ..themeMode = preferences.themeMode
      ..defaultAttendanceTarget = preferences.defaultAttendanceTarget
      ..classReminderOffset = preferences.classReminderOffset
      ..enableNotifications = preferences.enableNotifications
      ..enableAttendanceWarnings = preferences.enableAttendanceWarnings
      ..weeklyReportEnabled = preferences.weeklyReportEnabled
      ..enableAutoBackup = preferences.enableAutoBackup
      ..lastBackupDate = preferences.lastBackupDate
      ..autoBackupDay = preferences.autoBackupDay
      ..autoBackupHour = preferences.autoBackupHour
      ..enableLateAttendance = preferences.enableLateAttendance
      ..lateAttendanceWeight = preferences.lateAttendanceWeight
      ..lateAttendancePolicy = preferences.lateAttendancePolicy
      ..enableGlassyTheme = preferences.enableGlassyTheme
      ..enableAiAdvisor = preferences.enableAiAdvisor
      ..quietHoursEnabled = preferences.quietHoursEnabled
      ..quietHoursStartHour = preferences.quietHoursStartHour
      ..quietHoursEndHour = preferences.quietHoursEndHour
      ..notificationSound = preferences.notificationSound
      ..notificationVibration = preferences.notificationVibration
      ..missedAttendanceReminderEnabled =
          preferences.missedAttendanceReminderEnabled
      ..missedAttendanceReminderOffset =
          preferences.missedAttendanceReminderOffset
      ..enableCloudSync = preferences.enableCloudSync
      ..cloudSyncConsentGiven = preferences.cloudSyncConsentGiven;
    return local;
  }

  @override
  Future<UserPreferences?> getPreferences(String userId) async {
    final list = _isar.userPreferencesLocals.where().findAll();
    if (list.isNotEmpty) {
      return _toEntity(list.first);
    }
    return null;
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    final now = DateTime.now().toUtc();
    final localPref = _toLocal(preferences)
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;

    final existingList = _isar.userPreferencesLocals.where().findAll();
    if (existingList.isNotEmpty) {
      localPref.id = existingList.first.id;
    }

    await _isar.writeAsync((isar) {
      if (localPref.id == 0) {
        localPref.id = isar.userPreferencesLocals.autoIncrement();
      }
      isar.userPreferencesLocals.put(localPref);
    });
  }

  @override
  Stream<UserPreferences?> watchPreferences(String userId) {
    return _isar.userPreferencesLocals
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.isNotEmpty ? _toEntity(list.first) : null);
  }
}
