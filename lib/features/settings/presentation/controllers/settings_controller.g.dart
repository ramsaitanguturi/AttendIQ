// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsRepositoryHash() =>
    r'2ae5046c39d7db593eea17ee3e2b48821d06c098';

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
String _$pendingOperationsCountHash() =>
    r'4273e4b7f21d876aba037c28901be3fbfdc9a9d4';

/// See also [pendingOperationsCount].
@ProviderFor(pendingOperationsCount)
final pendingOperationsCountProvider = AutoDisposeStreamProvider<int>.internal(
  pendingOperationsCount,
  name: r'pendingOperationsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingOperationsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PendingOperationsCountRef = AutoDisposeStreamProviderRef<int>;
String _$settingsControllerHash() =>
    r'2cada5a808cd577ceb4b95535e45226ffc09811e';

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
