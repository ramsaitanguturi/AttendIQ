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
    r'e0fc730fce77dcabc705e5c4ed5e703f0e3f0a0d';

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
    r'457c5fbcd27c97af62b323e51da59626728c9211';

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
