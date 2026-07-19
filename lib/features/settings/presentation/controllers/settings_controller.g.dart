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
String _$appThemeModeHash() => r'45af4f038c23474e0aad5778ee55d8aba013ef53';

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
    r'c8e2d9d0cf073b9bf6c26912a516bc2849f3390d';

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
