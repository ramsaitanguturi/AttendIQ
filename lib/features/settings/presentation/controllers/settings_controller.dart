import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/isar_provider.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

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
  }

  Future<void> updateEnableNotifications(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(enableNotifications: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateEnableAttendanceWarnings(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(enableAttendanceWarnings: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }

  Future<void> updateWeeklyReportEnabled(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(weeklyReportEnabled: enabled);
    state = AsyncValue.data(updated);

    final repo = ref.read(settingsRepositoryProvider);
    await repo.savePreferences(updated);
  }
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
