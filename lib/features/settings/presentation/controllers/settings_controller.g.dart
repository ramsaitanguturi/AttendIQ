// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsRepositoryHash() =>
    r'e26839cc4714f70017021042427fff0e6fa80d38';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider =
    AutoDisposeProvider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettingsRepositoryRef = AutoDisposeProviderRef<SettingsRepository>;
String _$isGlassyThemeEnabledHash() =>
    r'4acfad924a6f0e0c1c0fcc6f5fc491ec399e7f71';

/// See also [isGlassyThemeEnabled].
@ProviderFor(isGlassyThemeEnabled)
final isGlassyThemeEnabledProvider = AutoDisposeProvider<bool>.internal(
  isGlassyThemeEnabled,
  name: r'isGlassyThemeEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isGlassyThemeEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsGlassyThemeEnabledRef = AutoDisposeProviderRef<bool>;
String _$isLateAttendanceEnabledHash() =>
    r'53b82baedc9b76bbd24f78e047f2218e19533ed7';

/// See also [isLateAttendanceEnabled].
@ProviderFor(isLateAttendanceEnabled)
final isLateAttendanceEnabledProvider = AutoDisposeProvider<bool>.internal(
  isLateAttendanceEnabled,
  name: r'isLateAttendanceEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isLateAttendanceEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsLateAttendanceEnabledRef = AutoDisposeProviderRef<bool>;
String _$isAiAdvisorEnabledHash() =>
    r'd355b9487f29aa41ee49881ddf12d2797da5c8ab';

/// See also [isAiAdvisorEnabled].
@ProviderFor(isAiAdvisorEnabled)
final isAiAdvisorEnabledProvider = AutoDisposeProvider<bool>.internal(
  isAiAdvisorEnabled,
  name: r'isAiAdvisorEnabledProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAiAdvisorEnabledHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAiAdvisorEnabledRef = AutoDisposeProviderRef<bool>;
String _$appThemeModeHash() => r'1da25f4924e94d4dc2930fe962974bc9b4792f8f';

/// See also [appThemeMode].
@ProviderFor(appThemeMode)
final appThemeModeProvider = AutoDisposeProvider<ThemeMode>.internal(
  appThemeMode,
  name: r'appThemeModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appThemeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppThemeModeRef = AutoDisposeProviderRef<ThemeMode>;
String _$settingsControllerHash() =>
    r'97f317cc39a4990b217936a3b1d66d063a5014c3';

/// See also [SettingsController].
@ProviderFor(SettingsController)
final settingsControllerProvider = AutoDisposeAsyncNotifierProvider<
    SettingsController, UserPreferences>.internal(
  SettingsController.new,
  name: r'settingsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SettingsController = AutoDisposeAsyncNotifier<UserPreferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
