// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationCollectionStreamsBuilderHash() =>
    r'e7686f1d697fbbefd227065fd7aa87c99e55952a';

/// Stateless stream factory for the five watched Isar collections.
///
/// Kept auto-dispose because it holds no runtime state and is only needed when
/// registering or testing collection observers.
///
/// Copied from [notificationCollectionStreamsBuilder].
@ProviderFor(notificationCollectionStreamsBuilder)
final notificationCollectionStreamsBuilderProvider =
    AutoDisposeProvider<NotificationCollectionStreamsBuilder>.internal(
  notificationCollectionStreamsBuilder,
  name: r'notificationCollectionStreamsBuilderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationCollectionStreamsBuilderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationCollectionStreamsBuilderRef
    = AutoDisposeProviderRef<NotificationCollectionStreamsBuilder>;
String _$notificationServiceHash() =>
    r'f96ce641477bca4d8361a4f584c37143c81cd4fa';

/// App-wide local notification service singleton retained for the container
/// lifetime so initialization state and plugin bindings persist across routes.
///
/// Copied from [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationServiceRef = ProviderRef<NotificationService>;
String _$notificationSchedulerHash() =>
    r'7b252e206c76e7283af4187d65de7b52a3d7e023';

/// App-wide notification scheduler scoped to the active [Isar] instance.
///
/// Retained with `keepAlive: true` so single-flight scheduling serialization
/// persists across controller calls and database listeners, while rebuilding
/// cleanly if [isarProvider] is invalidated or retried.
///
/// Copied from [notificationScheduler].
@ProviderFor(notificationScheduler)
final notificationSchedulerProvider = Provider<NotificationScheduler>.internal(
  notificationScheduler,
  name: r'notificationSchedulerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSchedulerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationSchedulerRef = ProviderRef<NotificationScheduler>;
String _$notificationLifecycleManagerHash() =>
    r'd2e5014c0631a5a06e9009b1910edcd0b3a3ce35';

/// Retains the active database observer subscriptions for the app container
/// lifetime and cancels them on disposal.
///
/// Copied from [notificationLifecycleManager].
@ProviderFor(notificationLifecycleManager)
final notificationLifecycleManagerProvider =
    Provider<NotificationLifecycleManager>.internal(
  notificationLifecycleManager,
  name: r'notificationLifecycleManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationLifecycleManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationLifecycleManagerRef
    = ProviderRef<NotificationLifecycleManager>;
String _$notificationInitializerHash() =>
    r'7c7f34f97a6659dba4f0369e9ae44d62525f1cc5';

/// Initializes local notifications, registers all five Isar `watchLazy`
/// listeners, and triggers initial scheduling once [isarProvider] is ready.
///
/// Marked `keepAlive: true` because it is triggered via one-shot reads during
/// startup and database recovery without permanent UI watchers.
///
/// Copied from [notificationInitializer].
@ProviderFor(notificationInitializer)
final notificationInitializerProvider = FutureProvider<void>.internal(
  notificationInitializer,
  name: r'notificationInitializerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationInitializerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationInitializerRef = FutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
