// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_attendance_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subjectAttendanceStatsHash() =>
    r'41df00a25b71b6daafca4e9621fd2ff493bdb687';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [subjectAttendanceStats].
@ProviderFor(subjectAttendanceStats)
const subjectAttendanceStatsProvider = SubjectAttendanceStatsFamily();

/// See also [subjectAttendanceStats].
class SubjectAttendanceStatsFamily
    extends Family<AsyncValue<SubjectAttendanceStats?>> {
  /// See also [subjectAttendanceStats].
  const SubjectAttendanceStatsFamily();

  /// See also [subjectAttendanceStats].
  SubjectAttendanceStatsProvider call(
    int subjectId,
  ) {
    return SubjectAttendanceStatsProvider(
      subjectId,
    );
  }

  @override
  SubjectAttendanceStatsProvider getProviderOverride(
    covariant SubjectAttendanceStatsProvider provider,
  ) {
    return call(
      provider.subjectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subjectAttendanceStatsProvider';
}

/// See also [subjectAttendanceStats].
class SubjectAttendanceStatsProvider
    extends AutoDisposeFutureProvider<SubjectAttendanceStats?> {
  /// See also [subjectAttendanceStats].
  SubjectAttendanceStatsProvider(
    int subjectId,
  ) : this._internal(
          (ref) => subjectAttendanceStats(
            ref as SubjectAttendanceStatsRef,
            subjectId,
          ),
          from: subjectAttendanceStatsProvider,
          name: r'subjectAttendanceStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subjectAttendanceStatsHash,
          dependencies: SubjectAttendanceStatsFamily._dependencies,
          allTransitiveDependencies:
              SubjectAttendanceStatsFamily._allTransitiveDependencies,
          subjectId: subjectId,
        );

  SubjectAttendanceStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final int subjectId;

  @override
  Override overrideWith(
    FutureOr<SubjectAttendanceStats?> Function(
            SubjectAttendanceStatsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectAttendanceStatsProvider._internal(
        (ref) => create(ref as SubjectAttendanceStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SubjectAttendanceStats?> createElement() {
    return _SubjectAttendanceStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectAttendanceStatsProvider &&
        other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SubjectAttendanceStatsRef
    on AutoDisposeFutureProviderRef<SubjectAttendanceStats?> {
  /// The parameter `subjectId` of this provider.
  int get subjectId;
}

class _SubjectAttendanceStatsProviderElement
    extends AutoDisposeFutureProviderElement<SubjectAttendanceStats?>
    with SubjectAttendanceStatsRef {
  _SubjectAttendanceStatsProviderElement(super.provider);

  @override
  int get subjectId => (origin as SubjectAttendanceStatsProvider).subjectId;
}

String _$allSubjectAttendanceStatsHash() =>
    r'10314b4f5956ba1199dddd8450f12955e08350ce';

/// See also [allSubjectAttendanceStats].
@ProviderFor(allSubjectAttendanceStats)
final allSubjectAttendanceStatsProvider =
    AutoDisposeFutureProvider<List<SubjectAttendanceStats>>.internal(
  allSubjectAttendanceStats,
  name: r'allSubjectAttendanceStatsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allSubjectAttendanceStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllSubjectAttendanceStatsRef
    = AutoDisposeFutureProviderRef<List<SubjectAttendanceStats>>;
String _$overallAttendancePercentageHash() =>
    r'1f27353b421892ca27d62e825fc5880ff99a4c66';

/// See also [overallAttendancePercentage].
@ProviderFor(overallAttendancePercentage)
final overallAttendancePercentageProvider =
    AutoDisposeFutureProvider<double>.internal(
  overallAttendancePercentage,
  name: r'overallAttendancePercentageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$overallAttendancePercentageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OverallAttendancePercentageRef = AutoDisposeFutureProviderRef<double>;
String _$subjectEventsHash() => r'ae6d0b1d920ea5c4bddc0a102f50cfdcde2f2f73';

/// See also [subjectEvents].
@ProviderFor(subjectEvents)
const subjectEventsProvider = SubjectEventsFamily();

/// See also [subjectEvents].
class SubjectEventsFamily extends Family<AsyncValue<List<EventLocal>>> {
  /// See also [subjectEvents].
  const SubjectEventsFamily();

  /// See also [subjectEvents].
  SubjectEventsProvider call(
    int subjectId,
  ) {
    return SubjectEventsProvider(
      subjectId,
    );
  }

  @override
  SubjectEventsProvider getProviderOverride(
    covariant SubjectEventsProvider provider,
  ) {
    return call(
      provider.subjectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subjectEventsProvider';
}

/// See also [subjectEvents].
class SubjectEventsProvider
    extends AutoDisposeFutureProvider<List<EventLocal>> {
  /// See also [subjectEvents].
  SubjectEventsProvider(
    int subjectId,
  ) : this._internal(
          (ref) => subjectEvents(
            ref as SubjectEventsRef,
            subjectId,
          ),
          from: subjectEventsProvider,
          name: r'subjectEventsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subjectEventsHash,
          dependencies: SubjectEventsFamily._dependencies,
          allTransitiveDependencies:
              SubjectEventsFamily._allTransitiveDependencies,
          subjectId: subjectId,
        );

  SubjectEventsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final int subjectId;

  @override
  Override overrideWith(
    FutureOr<List<EventLocal>> Function(SubjectEventsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectEventsProvider._internal(
        (ref) => create(ref as SubjectEventsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<EventLocal>> createElement() {
    return _SubjectEventsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectEventsProvider && other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SubjectEventsRef on AutoDisposeFutureProviderRef<List<EventLocal>> {
  /// The parameter `subjectId` of this provider.
  int get subjectId;
}

class _SubjectEventsProviderElement
    extends AutoDisposeFutureProviderElement<List<EventLocal>>
    with SubjectEventsRef {
  _SubjectEventsProviderElement(super.provider);

  @override
  int get subjectId => (origin as SubjectEventsProvider).subjectId;
}

String _$todayEventsHash() => r'de426b24fbf4bbc03826391a566eff85a273c4db';

/// See also [todayEvents].
@ProviderFor(todayEvents)
final todayEventsProvider =
    AutoDisposeFutureProvider<List<EventLocal>>.internal(
  todayEvents,
  name: r'todayEventsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodayEventsRef = AutoDisposeFutureProviderRef<List<EventLocal>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
