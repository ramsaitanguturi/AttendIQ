// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayScheduleHash() => r'bf314721c544f91e82c467745bf7720ffc554f71';

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

/// See also [todaySchedule].
@ProviderFor(todaySchedule)
const todayScheduleProvider = TodayScheduleFamily();

/// See also [todaySchedule].
class TodayScheduleFamily extends Family<AsyncValue<TodayScheduleState>> {
  /// See also [todaySchedule].
  const TodayScheduleFamily();

  /// See also [todaySchedule].
  TodayScheduleProvider call({
    DateTime? customDate,
  }) {
    return TodayScheduleProvider(
      customDate: customDate,
    );
  }

  @override
  TodayScheduleProvider getProviderOverride(
    covariant TodayScheduleProvider provider,
  ) {
    return call(
      customDate: provider.customDate,
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
  String? get name => r'todayScheduleProvider';
}

/// See also [todaySchedule].
class TodayScheduleProvider
    extends AutoDisposeFutureProvider<TodayScheduleState> {
  /// See also [todaySchedule].
  TodayScheduleProvider({
    DateTime? customDate,
  }) : this._internal(
          (ref) => todaySchedule(
            ref as TodayScheduleRef,
            customDate: customDate,
          ),
          from: todayScheduleProvider,
          name: r'todayScheduleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$todayScheduleHash,
          dependencies: TodayScheduleFamily._dependencies,
          allTransitiveDependencies:
              TodayScheduleFamily._allTransitiveDependencies,
          customDate: customDate,
        );

  TodayScheduleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customDate,
  }) : super.internal();

  final DateTime? customDate;

  @override
  Override overrideWith(
    FutureOr<TodayScheduleState> Function(TodayScheduleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TodayScheduleProvider._internal(
        (ref) => create(ref as TodayScheduleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customDate: customDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TodayScheduleState> createElement() {
    return _TodayScheduleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodayScheduleProvider && other.customDate == customDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TodayScheduleRef on AutoDisposeFutureProviderRef<TodayScheduleState> {
  /// The parameter `customDate` of this provider.
  DateTime? get customDate;
}

class _TodayScheduleProviderElement
    extends AutoDisposeFutureProviderElement<TodayScheduleState>
    with TodayScheduleRef {
  _TodayScheduleProviderElement(super.provider);

  @override
  DateTime? get customDate => (origin as TodayScheduleProvider).customDate;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
