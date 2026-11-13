import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attend_iq/core/constants/app_constants.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';
import 'package:attend_iq/features/settings/domain/repositories/settings_repository.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';

class FakeSettingsRepository implements SettingsRepository {
  final Map<String, UserPreferences> _store = {};
  final StreamController<UserPreferences?> _controller =
      StreamController<UserPreferences?>.broadcast();
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
  group('ACEDRA Transformation & Feature Integrity Tests', () {
    test('1. Application name is ACEDRA and branding metadata is verified', () {
      expect(AppConstants.appName, 'ACEDRA');
      expect(AppConstants.isarDbName, 'attendiq_isar'); // Preserves DB name
    });

    test('2. Late Attendance is OFF by default and toggleable', () async {
      final repo = FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final prefs = await container.read(settingsControllerProvider.future);
      // Verify OFF by default
      expect(prefs.enableLateAttendance, isFalse);
      expect(container.read(isLateAttendanceEnabledProvider), isFalse);

      // Verify toggle ON
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.updateEnableLateAttendance(true);

      final updatedPrefs =
          await container.read(settingsControllerProvider.future);
      expect(updatedPrefs.enableLateAttendance, isTrue);
      expect(container.read(isLateAttendanceEnabledProvider), isTrue);

      // Verify toggle back OFF
      await notifier.updateEnableLateAttendance(false);
      expect(container.read(isLateAttendanceEnabledProvider), isFalse);
    });

    test('3. Glassy Interface is OFF by default and toggleable', () async {
      final repo = FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final prefs = await container.read(settingsControllerProvider.future);
      // Verify OFF by default
      expect(prefs.enableGlassyTheme, isFalse);
      expect(container.read(isGlassyThemeEnabledProvider), isFalse);

      // Verify toggle ON
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.updateEnableGlassyTheme(true);

      final updatedPrefs =
          await container.read(settingsControllerProvider.future);
      expect(updatedPrefs.enableGlassyTheme, isTrue);
      expect(container.read(isGlassyThemeEnabledProvider), isTrue);
    });

    test('4. AI Advisor is ON by default and toggleable', () async {
      final repo = FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final prefs = await container.read(settingsControllerProvider.future);
      // Verify ON by default
      expect(prefs.enableAiAdvisor, isTrue);
      expect(container.read(isAiAdvisorEnabledProvider), isTrue);

      // Verify toggle OFF
      final notifier = container.read(settingsControllerProvider.notifier);
      await notifier.updateEnableAiAdvisor(false);

      final updatedPrefs =
          await container.read(settingsControllerProvider.future);
      expect(updatedPrefs.enableAiAdvisor, isFalse);
      expect(container.read(isAiAdvisorEnabledProvider), isFalse);
    });

    test('5. LocalNotificationServiceImpl respects enableLateAttendance state',
        () {
      final service = LocalNotificationServiceImpl();

      // By default enableLateAttendance is false
      expect(service.enableLateAttendance, isFalse);

      // Toggle enableLateAttendance
      service.enableLateAttendance = true;
      expect(service.enableLateAttendance, isTrue);

      service.enableLateAttendance = false;
      expect(service.enableLateAttendance, isFalse);
    });
  });
}
