// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attendanceLocalDataSourceHash() =>
    r'4cf50f20ffecfddc665bda734a32d9e3bb2e9698';

/// See also [attendanceLocalDataSource].
@ProviderFor(attendanceLocalDataSource)
final attendanceLocalDataSourceProvider =
    AutoDisposeProvider<AttendanceLocalDataSource>.internal(
  attendanceLocalDataSource,
  name: r'attendanceLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attendanceLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AttendanceLocalDataSourceRef
    = AutoDisposeProviderRef<AttendanceLocalDataSource>;
String _$attendanceRepositoryHash() =>
    r'4a30883a80655e0f1a3f3c309bc9b429a6939e30';

/// See also [attendanceRepository].
@ProviderFor(attendanceRepository)
final attendanceRepositoryProvider =
    AutoDisposeProvider<AttendanceRepository>.internal(
  attendanceRepository,
  name: r'attendanceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attendanceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AttendanceRepositoryRef = AutoDisposeProviderRef<AttendanceRepository>;
String _$attendanceControllerHash() =>
    r'be6ac67c50e7e0e7ad4122dad3c384265fc4b580';

/// See also [AttendanceController].
@ProviderFor(AttendanceController)
final attendanceControllerProvider =
    AutoDisposeAsyncNotifierProvider<AttendanceController, void>.internal(
  AttendanceController.new,
  name: r'attendanceControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attendanceControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AttendanceController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
