// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authLocalDataSourceHash() =>
    r'b3ea0592c63a9836564f2b66a62bb524302ded1b';

/// See also [authLocalDataSource].
@ProviderFor(authLocalDataSource)
final authLocalDataSourceProvider =
    AutoDisposeProvider<AuthLocalDataSource>.internal(
  authLocalDataSource,
  name: r'authLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthLocalDataSourceRef = AutoDisposeProviderRef<AuthLocalDataSource>;
String _$authRemoteDataSourceHash() =>
    r'81623d7edccdf752d906b3ed575e7d500a107f64';

/// See also [authRemoteDataSource].
@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider =
    AutoDisposeProvider<AuthRemoteDataSource>.internal(
  authRemoteDataSource,
  name: r'authRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRemoteDataSourceRef = AutoDisposeProviderRef<AuthRemoteDataSource>;
String _$authRepositoryHash() => r'19e916715c674bfdf690df1173242737ecdc0acb';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$semesterRepositoryHash() =>
    r'de6a404fed9773106c62efb9eb96e588aea33295';

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
String _$loginUseCaseHash() => r'e5d70fa1e5543d7d6609678d0835d0c67d436c2d';

/// See also [loginUseCase].
@ProviderFor(loginUseCase)
final loginUseCaseProvider = AutoDisposeProvider<LoginUseCase>.internal(
  loginUseCase,
  name: r'loginUseCaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loginUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LoginUseCaseRef = AutoDisposeProviderRef<LoginUseCase>;
String _$registerUseCaseHash() => r'40b32ebe481f7183de4ac3eaac00f8473d98eaeb';

/// See also [registerUseCase].
@ProviderFor(registerUseCase)
final registerUseCaseProvider = AutoDisposeProvider<RegisterUseCase>.internal(
  registerUseCase,
  name: r'registerUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$registerUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RegisterUseCaseRef = AutoDisposeProviderRef<RegisterUseCase>;
String _$logoutUseCaseHash() => r'1fca1b81dfb37219a50c22eae4fcd06bbc34f80d';

/// See also [logoutUseCase].
@ProviderFor(logoutUseCase)
final logoutUseCaseProvider = AutoDisposeProvider<LogoutUseCase>.internal(
  logoutUseCase,
  name: r'logoutUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$logoutUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LogoutUseCaseRef = AutoDisposeProviderRef<LogoutUseCase>;
String _$forgotPasswordUseCaseHash() =>
    r'3bb9830c4a9571fc05db9c9b6a6610ae3811f1f7';

/// See also [forgotPasswordUseCase].
@ProviderFor(forgotPasswordUseCase)
final forgotPasswordUseCaseProvider =
    AutoDisposeProvider<ForgotPasswordUseCase>.internal(
  forgotPasswordUseCase,
  name: r'forgotPasswordUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$forgotPasswordUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ForgotPasswordUseCaseRef
    = AutoDisposeProviderRef<ForgotPasswordUseCase>;
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
String _$authControllerHash() => r'1838fe47d0ebec42070eb964ff0560a11907921a';

/// See also [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, User?>.internal(
  AuthController.new,
  name: r'authControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthController = AutoDisposeAsyncNotifier<User?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
