// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timetableLocalDataSourceHash() =>
    r'47b2346552aef15401a5ccf588ae039d7e055867';

/// See also [timetableLocalDataSource].
@ProviderFor(timetableLocalDataSource)
final timetableLocalDataSourceProvider =
    AutoDisposeProvider<TimetableLocalDataSource>.internal(
  timetableLocalDataSource,
  name: r'timetableLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timetableLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TimetableLocalDataSourceRef
    = AutoDisposeProviderRef<TimetableLocalDataSource>;
String _$timetableRemoteDataSourceHash() =>
    r'f0e6b2072a2f38cdbc65ac4d2697a0f494b348d0';

/// See also [timetableRemoteDataSource].
@ProviderFor(timetableRemoteDataSource)
final timetableRemoteDataSourceProvider =
    AutoDisposeProvider<TimetableRemoteDataSource>.internal(
  timetableRemoteDataSource,
  name: r'timetableRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timetableRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TimetableRemoteDataSourceRef
    = AutoDisposeProviderRef<TimetableRemoteDataSource>;
String _$timetableRepositoryHash() =>
    r'b7512fe3ce1b8670da5115913c0eb4cc62125aae';

/// See also [timetableRepository].
@ProviderFor(timetableRepository)
final timetableRepositoryProvider =
    AutoDisposeProvider<TimetableRepository>.internal(
  timetableRepository,
  name: r'timetableRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timetableRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TimetableRepositoryRef = AutoDisposeProviderRef<TimetableRepository>;
String _$timetableListControllerHash() =>
    r'89d2df2b6779712f9bb4807087043488fe73aaeb';

/// See also [TimetableListController].
@ProviderFor(TimetableListController)
final timetableListControllerProvider = AutoDisposeAsyncNotifierProvider<
    TimetableListController, List<TimetableTemplate>>.internal(
  TimetableListController.new,
  name: r'timetableListControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timetableListControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TimetableListController
    = AutoDisposeAsyncNotifier<List<TimetableTemplate>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
