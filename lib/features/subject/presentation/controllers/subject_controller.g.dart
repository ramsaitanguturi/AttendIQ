// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subjectLocalDataSourceHash() =>
    r'5c5ca32b63827364aba6f9a02cc7254620737731';

/// See also [subjectLocalDataSource].
@ProviderFor(subjectLocalDataSource)
final subjectLocalDataSourceProvider =
    AutoDisposeProvider<SubjectLocalDataSource>.internal(
  subjectLocalDataSource,
  name: r'subjectLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subjectLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubjectLocalDataSourceRef
    = AutoDisposeProviderRef<SubjectLocalDataSource>;
String _$subjectRemoteDataSourceHash() =>
    r'14ef7255dfe8263ce79ffd68a0c891fafe010f4e';

/// See also [subjectRemoteDataSource].
@ProviderFor(subjectRemoteDataSource)
final subjectRemoteDataSourceProvider =
    AutoDisposeProvider<SubjectRemoteDataSource>.internal(
  subjectRemoteDataSource,
  name: r'subjectRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subjectRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubjectRemoteDataSourceRef
    = AutoDisposeProviderRef<SubjectRemoteDataSource>;
String _$subjectRepositoryHash() => r'e15b871228b4570fc787e3685408d4ee205ca818';

/// See also [subjectRepository].
@ProviderFor(subjectRepository)
final subjectRepositoryProvider =
    AutoDisposeProvider<SubjectRepository>.internal(
  subjectRepository,
  name: r'subjectRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subjectRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubjectRepositoryRef = AutoDisposeProviderRef<SubjectRepository>;
String _$subjectListControllerHash() =>
    r'5b5fc6c8169885da690bbff06003b017926e1222';

/// See also [SubjectListController].
@ProviderFor(SubjectListController)
final subjectListControllerProvider = AutoDisposeAsyncNotifierProvider<
    SubjectListController, List<Subject>>.internal(
  SubjectListController.new,
  name: r'subjectListControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subjectListControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SubjectListController = AutoDisposeAsyncNotifier<List<Subject>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
