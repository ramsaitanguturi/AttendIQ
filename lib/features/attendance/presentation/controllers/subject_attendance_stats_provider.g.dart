// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_attendance_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subjectAttendanceStatsHash() =>
    r'12198143888c0b13e311941fc149ac3c257ef264';

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
    r'30a3050268539f18ddfc08ecf026788035971cf6';

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
String _$subjectOccurrencesHash() =>
    r'cba62b864af7bff03298dae3e3f3223ba4a6d1f4';

/// See also [subjectOccurrences].
@ProviderFor(subjectOccurrences)
const subjectOccurrencesProvider = SubjectOccurrencesFamily();

/// See also [subjectOccurrences].
class SubjectOccurrencesFamily
    extends Family<AsyncValue<List<DailyScheduleOccurrence>>> {
  /// See also [subjectOccurrences].
  const SubjectOccurrencesFamily();

  /// See also [subjectOccurrences].
  SubjectOccurrencesProvider call(
    int subjectId,
  ) {
    return SubjectOccurrencesProvider(
      subjectId,
    );
  }

  @override
  SubjectOccurrencesProvider getProviderOverride(
    covariant SubjectOccurrencesProvider provider,
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
  String? get name => r'subjectOccurrencesProvider';
}

/// See also [subjectOccurrences].
class SubjectOccurrencesProvider
    extends AutoDisposeFutureProvider<List<DailyScheduleOccurrence>> {
  /// See also [subjectOccurrences].
  SubjectOccurrencesProvider(
    int subjectId,
  ) : this._internal(
          (ref) => subjectOccurrences(
            ref as SubjectOccurrencesRef,
            subjectId,
          ),
          from: subjectOccurrencesProvider,
          name: r'subjectOccurrencesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subjectOccurrencesHash,
          dependencies: SubjectOccurrencesFamily._dependencies,
          allTransitiveDependencies:
              SubjectOccurrencesFamily._allTransitiveDependencies,
          subjectId: subjectId,
        );

  SubjectOccurrencesProvider._internal(
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
    FutureOr<List<DailyScheduleOccurrence>> Function(
            SubjectOccurrencesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectOccurrencesProvider._internal(
        (ref) => create(ref as SubjectOccurrencesRef),
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
  AutoDisposeFutureProviderElement<List<DailyScheduleOccurrence>>
      createElement() {
    return _SubjectOccurrencesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectOccurrencesProvider && other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SubjectOccurrencesRef
    on AutoDisposeFutureProviderRef<List<DailyScheduleOccurrence>> {
  /// The parameter `subjectId` of this provider.
  int get subjectId;
}

class _SubjectOccurrencesProviderElement
    extends AutoDisposeFutureProviderElement<List<DailyScheduleOccurrence>>
    with SubjectOccurrencesRef {
  _SubjectOccurrencesProviderElement(super.provider);

  @override
  int get subjectId => (origin as SubjectOccurrencesProvider).subjectId;
}

String _$todayOccurrencesHash() => r'0c9d1390184bcbd16d03d15e7841aa950122465e';

/// See also [todayOccurrences].
@ProviderFor(todayOccurrences)
final todayOccurrencesProvider =
    AutoDisposeFutureProvider<List<DailyScheduleOccurrence>>.internal(
  todayOccurrences,
  name: r'todayOccurrencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayOccurrencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodayOccurrencesRef
    = AutoDisposeFutureProviderRef<List<DailyScheduleOccurrence>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
