import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attend_iq/core/theme/glass/glass_theme_tokens.dart';
import 'package:attend_iq/core/theme/glass/glass_dialog.dart';
import 'package:attend_iq/core/widgets/acedra_logo.dart';
import 'package:attend_iq/core/widgets/acedra_floating_bottom_bar.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ACEDRA Design System & Glass Tokens Verification', () {
    test(
        'GlassTokens glassBoxDecoration adapts to numeric and BorderRadius radius and custom colors',
        () {
      final decNum = GlassTokens.glassBoxDecoration(
        borderRadius: 20.0,
        fillColor: const Color(0xD9141824),
        borderColor: const Color(0x38E2E8F0),
      );
      expect(decNum.borderRadius, BorderRadius.circular(20.0));
      expect(decNum.color, const Color(0xD9141824));
      expect(decNum.border?.top.color, const Color(0x38E2E8F0));

      final decBorderRadius = GlassTokens.glassBoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        isElevated: true,
      );
      expect(decBorderRadius.borderRadius, BorderRadius.circular(16.0));
      expect(decBorderRadius.gradient, GlassTokens.elevatedSurfaceGradient);
    });

    testWidgets(
        'GlassDialog renders with standard surface when Glassy Theme is OFF',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isGlassyThemeEnabledProvider.overrideWith((ref) => false),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: GlassDialog(
                title: Text('Test Dialog'),
                content: Text('Content here'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Content here'), findsOneWidget);
      expect(find.byType(GlassDialog), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets(
        'GlassDialog renders with smoked glass and backdrop blur when Glassy Theme is ON',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isGlassyThemeEnabledProvider.overrideWith((ref) => true),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: GlassDialog(
                title: Text('Glass Dialog'),
                content: Text('Smoked glass content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Glass Dialog'), findsOneWidget);
      expect(find.text('Smoked glass content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('AcedraFloatingBottomBar reflects active tab and glass styling',
        (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isGlassyThemeEnabledProvider.overrideWith((ref) => true),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  const Positioned.fill(child: Center(child: Text('Body'))),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AcedraFloatingBottomBar(
                      currentIndex: 2,
                      onTabSelected: (index) => tappedIndex = index,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Timetable'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);

      await tester.tap(find.text('Timetable'));
      await tester.pump();
      expect(tappedIndex, 1);
    });
  });

  group('ACEDRA Preferences & Feature Gating Verification', () {
    const basePrefs = UserPreferences(
      id: 'local_user',
      themeMode: 'system',
      defaultAttendanceTarget: 75.0,
      classReminderOffset: 5,
      enableNotifications: true,
      enableAttendanceWarnings: true,
      weeklyReportEnabled: true,
    );

    test('Default user preferences have Late OFF, Glass OFF, AI Advisor ON',
        () {
      expect(basePrefs.enableLateAttendance, false);
      expect(basePrefs.enableGlassyTheme, false);
      expect(basePrefs.enableAiAdvisor, true);
    });

    test('isAiAdvisorEnabledProvider correctly reads preference state',
        () async {
      final containerEnabled = ProviderContainer(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsNotifier(
              basePrefs.copyWith(enableAiAdvisor: true),
            ),
          ),
        ],
      );
      addTearDown(containerEnabled.dispose);
      await containerEnabled.read(settingsControllerProvider.future);
      expect(containerEnabled.read(isAiAdvisorEnabledProvider), isTrue);

      final containerDisabled = ProviderContainer(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsNotifier(
              basePrefs.copyWith(enableAiAdvisor: false),
            ),
          ),
        ],
      );
      addTearDown(containerDisabled.dispose);
      await containerDisabled.read(settingsControllerProvider.future);
      expect(containerDisabled.read(isAiAdvisorEnabledProvider), isFalse);
    });

    test('isGlassyThemeEnabledProvider correctly reads preference state',
        () async {
      final containerGlassy = ProviderContainer(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsNotifier(
              basePrefs.copyWith(enableGlassyTheme: true),
            ),
          ),
        ],
      );
      addTearDown(containerGlassy.dispose);
      await containerGlassy.read(settingsControllerProvider.future);
      expect(containerGlassy.read(isGlassyThemeEnabledProvider), isTrue);

      final containerStandard = ProviderContainer(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsNotifier(
              basePrefs.copyWith(enableGlassyTheme: false),
            ),
          ),
        ],
      );
      addTearDown(containerStandard.dispose);
      await containerStandard.read(settingsControllerProvider.future);
      expect(containerStandard.read(isGlassyThemeEnabledProvider), isFalse);
    });

    test('isLateAttendanceEnabledProvider correctly reads preference state',
        () async {
      final containerLateOn = ProviderContainer(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsNotifier(
              basePrefs.copyWith(enableLateAttendance: true),
            ),
          ),
        ],
      );
      addTearDown(containerLateOn.dispose);
      await containerLateOn.read(settingsControllerProvider.future);
      expect(containerLateOn.read(isLateAttendanceEnabledProvider), isTrue);

      final containerLateOff = ProviderContainer(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _FakeSettingsNotifier(
              basePrefs.copyWith(enableLateAttendance: false),
            ),
          ),
        ],
      );
      addTearDown(containerLateOff.dispose);
      await containerLateOff.read(settingsControllerProvider.future);
      expect(containerLateOff.read(isLateAttendanceEnabledProvider), isFalse);
    });
  });

  group('ACEDRA Monogram & Branding Verification', () {
    testWidgets(
        'AcedraLogo widget instantiates and renders with given dimensions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AcedraLogo(size: 48.0, showWordmark: true),
            ),
          ),
        ),
      );

      expect(find.byType(AcedraLogo), findsOneWidget);
      expect(find.text('ACEDRA'), findsOneWidget);
    });
  });
}

class _FakeSettingsNotifier extends SettingsController {
  final UserPreferences _initial;
  _FakeSettingsNotifier(this._initial);

  @override
  Future<UserPreferences> build() async => _initial;
}
