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
      ..autoBackupHour = preferences.autoBackupHour;
    return local;
  }

  @override
  Future<UserPreferences?> getPreferences(String userId) async {
    final list = await _isar.userPreferencesLocals.where().findAll();
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

    final existingList = await _isar.userPreferencesLocals.where().findAll();
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
