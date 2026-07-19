// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationServiceHash() =>
    r'5718cd1d5e484c21bc789d32a9bf4cd45eb95c6f';

/// See also [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider =
    AutoDisposeProvider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationServiceRef = AutoDisposeProviderRef<NotificationService>;
String _$notificationSchedulerHash() =>
    r'bdc49a3e9c77eaf2de1df48f3e5c9e71fc6c533a';

/// See also [notificationScheduler].
@ProviderFor(notificationScheduler)
final notificationSchedulerProvider =
    AutoDisposeProvider<NotificationScheduler>.internal(
  notificationScheduler,
  name: r'notificationSchedulerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSchedulerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationSchedulerRef
    = AutoDisposeProviderRef<NotificationScheduler>;
String _$notificationInitializerHash() =>
    r'0f12aaa8be5e747c6e2bc545daff89d8afec74e5';

/// See also [notificationInitializer].
@ProviderFor(notificationInitializer)
final notificationInitializerProvider =
    AutoDisposeFutureProvider<void>.internal(
  notificationInitializer,
  name: r'notificationInitializerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationInitializerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationInitializerRef = AutoDisposeFutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
