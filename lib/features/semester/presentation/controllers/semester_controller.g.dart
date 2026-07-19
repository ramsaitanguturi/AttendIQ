// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$semesterRepositoryHash() =>
    r'8a99aef26ad83c17ab545ff393917ab91d46e339';

/// See also [semesterRepository].
@ProviderFor(semesterRepository)
final semesterRepositoryProvider =
    AutoDisposeProvider<SemesterRepository>.internal(
  semesterRepository,
  name: r'semesterRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$semesterRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SemesterRepositoryRef = AutoDisposeProviderRef<SemesterRepository>;
String _$createSemesterUseCaseHash() =>
    r'c4c10add26bf1bb2ede2ffbfba678bade77fd836';

/// See also [createSemesterUseCase].
@ProviderFor(createSemesterUseCase)
final createSemesterUseCaseProvider =
    AutoDisposeProvider<CreateSemesterUseCase>.internal(
  createSemesterUseCase,
  name: r'createSemesterUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createSemesterUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CreateSemesterUseCaseRef
    = AutoDisposeProviderRef<CreateSemesterUseCase>;
String _$hasActiveSemesterHash() => r'7acc1f24ba11e6cc162d16cf58fc956a76c9e3a2';

/// See also [hasActiveSemester].
@ProviderFor(hasActiveSemester)
final hasActiveSemesterProvider = AutoDisposeFutureProvider<bool>.internal(
  hasActiveSemester,
  name: r'hasActiveSemesterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasActiveSemesterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasActiveSemesterRef = AutoDisposeFutureProviderRef<bool>;
String _$activeSemesterHash() => r'a160227feecf947b26d9b45d0bf65d086c5de93b';

/// See also [activeSemester].
@ProviderFor(activeSemester)
final activeSemesterProvider = AutoDisposeFutureProvider<Semester?>.internal(
  activeSemester,
  name: r'activeSemesterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSemesterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveSemesterRef = AutoDisposeFutureProviderRef<Semester?>;
String _$allSemestersHash() => r'26ab9b9ee30c6efde401049e7490e00085cf4ff4';

/// See also [allSemesters].
@ProviderFor(allSemesters)
final allSemestersProvider = AutoDisposeFutureProvider<List<Semester>>.internal(
  allSemesters,
  name: r'allSemestersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allSemestersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllSemestersRef = AutoDisposeFutureProviderRef<List<Semester>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
