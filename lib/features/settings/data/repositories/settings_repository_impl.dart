import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/user_preferences_local.dart';
import '../../../../core/sync/sync_queue/sync_queue.dart';
import '../../../../core/sync/models/sync_mappers.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Isar _isar;
  final SyncQueue _syncQueue;

  SettingsRepositoryImpl({
    required Isar isar,
    required SyncQueue syncQueue,
  })  : _isar = isar,
        _syncQueue = syncQueue;

  UserPreferences _toEntity(UserPreferencesLocal local) {
    return UserPreferences(
      id: local.serverId ?? '',
      themeMode: local.themeMode,
      defaultAttendanceTarget: local.defaultAttendanceTarget,
      classReminderOffset: local.classReminderOffset,
      enableNotifications: local.enableNotifications,
      enableAttendanceWarnings: local.enableAttendanceWarnings,
      weeklyReportEnabled: local.weeklyReportEnabled,
    );
  }

  UserPreferencesLocal _toLocal(UserPreferences preferences) {
    final local = UserPreferencesLocal()
      ..serverId = preferences.id
      ..themeMode = preferences.themeMode
      ..defaultAttendanceTarget = preferences.defaultAttendanceTarget
      ..classReminderOffset = preferences.classReminderOffset
      ..enableNotifications = preferences.enableNotifications
      ..enableAttendanceWarnings = preferences.enableAttendanceWarnings
      ..weeklyReportEnabled = preferences.weeklyReportEnabled;
    return local;
  }

  @override
  Future<UserPreferences?> getPreferences(String userId) async {
    final local = _isar.userPreferencesLocals.where().serverIdEqualTo(userId).findFirst();
    if (local != null) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    final serverId = preferences.id;
    if (serverId.isEmpty) return;

    final now = DateTime.now().toUtc();
    final localPref = _toLocal(preferences)
      ..updatedAt = now
      ..isDirty = true
      ..isDeleted = false;

    await _isar.writeAsync((isar) {
      final existing = isar.userPreferencesLocals.where().serverIdEqualTo(serverId).findFirst();
      if (existing != null) {
        localPref.id = existing.id;
      }
      isar.userPreferencesLocals.put(localPref);
    });

    await _syncQueue.enqueue(
      collectionName: 'user_preferences',
      documentId: serverId,
      operationType: 'UPDATE',
      payload: jsonEncode(localPref.toMap()),
    );
  }

  @override
  Stream<UserPreferences?> watchPreferences(String userId) {
    return _isar.userPreferencesLocals
        .where()
        .serverIdEqualTo(userId)
        .watch(fireImmediately: true)
        .map((list) => list.isNotEmpty ? _toEntity(list.first) : null);
  }
}
