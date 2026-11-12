import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../academic_planner/data/models/academic_task_local.dart';
import '../../attendance/data/models/attendance_record_local.dart';
import '../../semester/data/models/semester_local.dart';
import '../../subject/data/models/subject_local.dart';
import '../../timetable/data/models/academic_event_local.dart';
import '../../timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../timetable/data/models/schedule_exception_local.dart';
import '../../timetable/data/models/weekly_schedule_rule_local.dart';
import '../data/widget_data_service.dart';

final widgetRefreshServiceProvider = Provider<WidgetRefreshService>((ref) {
  final dataService = ref.watch(widgetDataServiceProvider);
  return WidgetRefreshService(dataService);
});

final widgetSyncCoordinatorProvider = Provider<WidgetSyncCoordinator>((ref) {
  final refreshService = ref.watch(widgetRefreshServiceProvider);
  final coordinator = WidgetSyncCoordinator(
    onRefresh: refreshService.refreshAllWidgets,
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

class WidgetRefreshService {
  final WidgetDataService _dataService;

  WidgetRefreshService(this._dataService);

  /// Trigger full widget refresh across all home screen widgets
  Future<void> refreshAllWidgets() async {
    if (kDebugMode) {
      developer.log(
        'Triggering Widget Refresh Service...',
        name: 'WidgetRefreshService',
      );
    }
    await _dataService.updateAllWidgets();
  }

  /// Notify Android widget providers to re-render from current SharedPreferences
  Future<void> notifyProvidersUpdated() async {
    try {
      await _dataService.notifyProvidersUpdated();
    } catch (_) {}
  }
}

/// Coalesces Isar collection writes and lifecycle resume triggers into
/// debounced, single-flight home screen widget refreshes.
class WidgetSyncCoordinator {
  final Future<void> Function() _onRefresh;
  final Duration debounceDuration;

  final List<StreamSubscription<void>> _subscriptions =
      <StreamSubscription<void>>[];
  Timer? _debounceTimer;
  Future<void>? _inFlight;
  bool _pendingAfterFlight = false;
  bool _disposed = false;

  WidgetSyncCoordinator({
    required Future<void> Function() onRefresh,
    this.debounceDuration = const Duration(milliseconds: 150),
  }) : _onRefresh = onRefresh;

  bool get isWatching => _subscriptions.isNotEmpty;

  /// Subscribes to widget-relevant Isar collections using [watchLazy].
  void watchIsar(Isar isar) {
    if (_disposed) {
      return;
    }
    _cancelSubscriptions();
    final streams = <Stream<void>>[
      isar.semesterLocals.watchLazy(),
      isar.subjectLocals.watchLazy(),
      isar.weeklyScheduleRuleLocals.watchLazy(),
      isar.scheduleExceptionLocals.watchLazy(),
      isar.dailyScheduleOccurrenceLocals.watchLazy(),
      isar.academicEventLocals.watchLazy(),
      isar.academicTaskLocals.watchLazy(),
      isar.attendanceRecordLocals.watchLazy(),
    ];
    for (final stream in streams) {
      _subscriptions.add(stream.listen((_) => scheduleRefresh()));
    }
  }

  /// Schedules a debounced widget refresh, coalescing rapid bursts.
  void scheduleRefresh() {
    if (_disposed) {
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      unawaited(refreshNow());
    });
  }

  /// Executes or coalesces a single-flight refresh immediately.
  Future<void> refreshNow() async {
    if (_disposed) {
      return;
    }
    _debounceTimer?.cancel();
    if (_inFlight != null) {
      _pendingAfterFlight = true;
      await _inFlight;
      return;
    }
    final future = _runLoop();
    _inFlight = future;
    try {
      await future;
    } finally {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    }
  }

  Future<void> _runLoop() async {
    do {
      _pendingAfterFlight = false;
      if (_disposed) {
        return;
      }
      try {
        await _onRefresh();
      } catch (e, st) {
        developer.log(
          'Coalesced widget refresh failed: $e',
          name: 'WidgetSyncCoordinator',
          error: e,
          stackTrace: st,
        );
      }
    } while (_pendingAfterFlight && !_disposed);
  }

  void _cancelSubscriptions() {
    for (final sub in _subscriptions) {
      unawaited(sub.cancel());
    }
    _subscriptions.clear();
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pendingAfterFlight = false;
    _cancelSubscriptions();
  }
}
