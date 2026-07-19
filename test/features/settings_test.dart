import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';
import 'package:attend_iq/features/settings/domain/repositories/settings_repository.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';

class FakeSettingsRepository implements SettingsRepository {
  final Map<String, UserPreferences> _store = {};
  final StreamController<UserPreferences?> _controller = StreamController<UserPreferences?>.broadcast();
  int saveCount = 0;

  @override
  Future<UserPreferences?> getPreferences(String userId) async {
    return _store[userId];
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    saveCount++;
    _store[preferences.id] = preferences;
    _controller.add(preferences);
  }

  @override
  Stream<UserPreferences?> watchPreferences(String userId) {
    return _controller.stream;
  }
}

void main() {
  group('UserPreferences Entity tests', () {
    test('Entity should initialize with correct values and support copyWith', () {
      const prefs = UserPreferences(
        id: 'local_user',
        themeMode: 'system',
        defaultAttendanceTarget: 75.0,
        classReminderOffset: 5,
        enableNotifications: true,
        enableAttendanceWarnings: true,
        weeklyReportEnabled: true,
      );

      expect(prefs.id, 'local_user');
      expect(prefs.themeMode, 'system');
      expect(prefs.defaultAttendanceTarget, 75.0);

      final updated = prefs.copyWith(themeMode: 'dark', defaultAttendanceTarget: 80.0);
      expect(updated.themeMode, 'dark');
      expect(updated.defaultAttendanceTarget, 80.0);
      expect(updated.id, 'local_user');
    });
  });

  group('SettingsController & Preferences modification tests', () {
    late FakeSettingsRepository settingsRepository;
    late ProviderContainer container;

    setUp(() {
      settingsRepository = FakeSettingsRepository();
      
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Controller initializes preferences with defaults if none stored in repository', () async {
      final sub = container.listen(settingsControllerProvider, (_, __) {});

      final state = await container.read(settingsControllerProvider.future);
      expect(state.id, 'local_user');
      expect(state.themeMode, 'system');
      expect(state.defaultAttendanceTarget, 75.0);
      expect(state.classReminderOffset, 5);

      expect(settingsRepository.saveCount, 1);
      sub.close();
    });

    test('Updating settings fields updates state and calls repository savePreferences', () async {
      final sub = container.listen(settingsControllerProvider, (_, __) {});

      await container.read(settingsControllerProvider.future);
      settingsRepository.saveCount = 0;

      final notifier = container.read(settingsControllerProvider.notifier);

      await notifier.updateThemeMode('dark');
      var state = container.read(settingsControllerProvider).valueOrNull!;
      expect(state.themeMode, 'dark');
      expect(settingsRepository.saveCount, 1);

      await notifier.updateDefaultAttendanceTarget(85.0);
      state = container.read(settingsControllerProvider).valueOrNull!;
      expect(state.defaultAttendanceTarget, 85.0);
      expect(settingsRepository.saveCount, 2);

      await notifier.updateEnableNotifications(false);
      state = container.read(settingsControllerProvider).valueOrNull!;
      expect(state.enableNotifications, false);
      expect(settingsRepository.saveCount, 3);

      sub.close();
    });
  });
}
