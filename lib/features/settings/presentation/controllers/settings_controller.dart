import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/isar_provider.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/notifications/providers/notification_providers.dart';
import '../../../../core/backup/backup_scheduler.dart';

part 'settings_controller.g.dart';

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return SettingsRepositoryImpl(isar: isar);
}

@riverpod
class SettingsController extends _$SettingsController {
  @override
  FutureOr<UserPreferences> build() async {
    final repo = ref.watch(settingsRepositoryProvider);
    final prefs = await repo.getPreferences('local_user');
    if (prefs != null) {
      return prefs;
    }

    const defaultPrefs = UserPreferences(
      id: 'local_user',
      themeMode: 'system',
      defaultAttendanceTarget: 75.0,
      classReminderOffset: 5,
      enableNotifications: true,
      enableAttendanceWarnings: true,
      weeklyReportEnabled: true,
    );

    await repo.savePreferences(defaultPrefs);
    return defaultPrefs;
  }

  Future<void> updateThemeMode(String mode) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(themeMode: mode);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateDefaultAttendanceTarget(double target) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(defaultAttendanceTarget: target);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateClassReminderOffset(int offset) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(classReminderOffset: offset);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);

    try {
      await ref.read(notificationSchedulerProvider).rescheduleAll();
    } catch (_) {}
  }

  Future<void> updateEnableNotifications(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(enableNotifications: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);

    try {
      await ref.read(notificationSchedulerProvider).rescheduleAll();
    } catch (_) {}
  }

  Future<void> updateEnableAttendanceWarnings(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(enableAttendanceWarnings: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);

    try {
      await ref.read(notificationSchedulerProvider).rescheduleAll();
    } catch (_) {}
  }

  Future<void> updateWeeklyReportEnabled(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(weeklyReportEnabled: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);

    try {
      await ref.read(notificationSchedulerProvider).rescheduleAll();
    } catch (_) {}
  }

  Future<void> updateEnableAutoBackup(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(enableAutoBackup: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);

    try {
      await BackupScheduler.scheduleOrCancelAutoBackup(enabled);
    } catch (_) {}
  }

  Future<void> updateLastBackupDate(DateTime date) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(lastBackupDate: date);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateLateAttendanceSettings({
    required double weight,
    required String policy,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(
      lateAttendanceWeight: weight.clamp(0.0, 1.0),
      lateAttendancePolicy: policy,
    );
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateQuietHours({
    required bool enabled,
    required int startHour,
    required int endHour,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(
      quietHoursEnabled: enabled,
      quietHoursStartHour: startHour,
      quietHoursEndHour: endHour,
    );
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateNotificationAudioVibration({
    required bool sound,
    required bool vibration,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(
      notificationSound: sound,
      notificationVibration: vibration,
    );
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateMissedAttendanceReminder({
    required bool enabled,
    required int offsetMinutes,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(
      missedAttendanceReminderEnabled: enabled,
      missedAttendanceReminderOffset: offsetMinutes,
    );
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateCloudSyncSettings({
    required bool enabled,
    required bool consentGiven,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(
      enableCloudSync: enabled,
      cloudSyncConsentGiven: consentGiven,
    );
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateLastSyncTime(DateTime time) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(lastSyncTime: time);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateEnableLateAttendance(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(enableLateAttendance: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);

    try {
      await ref.read(notificationSchedulerProvider).rescheduleAll();
    } catch (_) {}
  }

  Future<void> updateEnableGlassyTheme(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(enableGlassyTheme: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateEnableAiAdvisor(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(enableAiAdvisor: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }
}

@riverpod
bool isGlassyThemeEnabled(IsGlassyThemeEnabledRef ref) {
  final settingsAsync = ref.watch(settingsControllerProvider);
  return settingsAsync.maybeWhen(
    data: (prefs) => prefs.enableGlassyTheme,
    orElse: () => false,
  );
}

@riverpod
bool isLateAttendanceEnabled(IsLateAttendanceEnabledRef ref) {
  final settingsAsync = ref.watch(settingsControllerProvider);
  return settingsAsync.maybeWhen(
    data: (prefs) => prefs.enableLateAttendance,
    orElse: () => false,
  );
}

@riverpod
bool isAiAdvisorEnabled(IsAiAdvisorEnabledRef ref) {
  final settingsAsync = ref.watch(settingsControllerProvider);
  return settingsAsync.maybeWhen(
    data: (prefs) => prefs.enableAiAdvisor,
    orElse: () => true,
  );
}

@riverpod
ThemeMode appThemeMode(AppThemeModeRef ref) {
  final settingsAsync = ref.watch(settingsControllerProvider);
  return settingsAsync.when(
    data: (prefs) {
      switch (prefs.themeMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
        default:
          return ThemeMode.system;
      }
    },
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
}
