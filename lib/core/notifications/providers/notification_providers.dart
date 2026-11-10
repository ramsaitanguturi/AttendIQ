import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/attendance/data/models/attendance_record_local.dart';
import '../../../features/timetable/data/models/academic_event_local.dart';
import '../../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../features/timetable/data/models/schedule_exception_local.dart';
import '../../../features/timetable/data/models/weekly_schedule_rule_local.dart';
import '../../database/isar_provider.dart';
import '../../errors/app_exception.dart';
import '../scheduler/notification_database.dart';
import '../scheduler/notification_scheduler.dart';
import '../services/notification_service.dart';

part 'notification_providers.g.dart';

/// Canonical list of the five Isar collections monitored for notification
/// rescheduling.
const List<String> watchedNotificationCollections = <String>[
  'weeklyScheduleRuleLocals',
  'dailyScheduleOccurrenceLocals',
  'attendanceRecordLocals',
  'scheduleExceptionLocals',
  'academicEventLocals',
];

typedef NotificationCollectionStreamsBuilder = Map<String, Stream<void>>
    Function(Isar isar);

/// Builds lazy Isar change streams for all five notification-relevant
/// collections.
Map<String, Stream<void>> defaultNotificationCollectionStreamsBuilder(
  Isar isar,
) {
  return <String, Stream<void>>{
    'weeklyScheduleRuleLocals':
        isar.weeklyScheduleRuleLocals.where().watchLazy(),
    'dailyScheduleOccurrenceLocals':
        isar.dailyScheduleOccurrenceLocals.where().watchLazy(),
    'attendanceRecordLocals': isar.attendanceRecordLocals.where().watchLazy(),
    'scheduleExceptionLocals': isar.scheduleExceptionLocals.where().watchLazy(),
    'academicEventLocals': isar.academicEventLocals.where().watchLazy(),
  };
}

/// Coordinates single-flight notification startup, the five Isar `watchLazy`
/// subscriptions, microtask-coalesced rescheduling, and safe shutdown cleanup.
class NotificationLifecycleManager {
  final Map<String, StreamSubscription<void>> _subscriptions =
      <String, StreamSubscription<void>>{};

  Isar? _boundIsar;
  Future<void>? _inFlightInit;
  Object? _inFlightToken;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _rescheduleMicrotaskQueued = false;
  Object? _lastError;
  int _initializationCount = 0;
  int _rescheduleTriggerCount = 0;

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _inFlightInit != null;
  bool get isDisposed => _isDisposed;
  int get activeListenerCount => _subscriptions.length;
  List<String> get activeListenerCollections =>
      List<String>.unmodifiable(_subscriptions.keys);
  Object? get lastError => _lastError;
  int get initializationCount => _initializationCount;
  int get rescheduleTriggerCount => _rescheduleTriggerCount;

  Future<void> initialize({
    required Isar isar,
    required NotificationService service,
    required NotificationScheduler scheduler,
    NotificationCollectionStreamsBuilder buildStreams =
        defaultNotificationCollectionStreamsBuilder,
    bool Function()? isCancelled,
    Object? sessionToken,
  }) async {
    if (_isDisposed) {
      throw StateError('NotificationLifecycleManager has been disposed.');
    }
    if (!isar.isOpen) {
      throw const DatabaseException(
        'Cannot initialize notifications when Isar database is closed.',
        'DB_NOT_OPEN',
      );
    }

    while (_inFlightInit != null) {
      if (sessionToken != null && identical(_inFlightToken, sessionToken)) {
        return _inFlightInit!;
      }
      final existingInFlight = _inFlightInit!;
      try {
        await existingInFlight;
      } catch (_) {
        if (sessionToken == null) {
          rethrow;
        }
      }
      if (_isDisposed || (isCancelled?.call() ?? false)) {
        return;
      }
      if (!isar.isOpen) {
        throw const DatabaseException(
          'Cannot initialize notifications when Isar database is closed.',
          'DB_NOT_OPEN',
        );
      }
      if (_isInitialized &&
          identical(_boundIsar, isar) &&
          _subscriptions.length == watchedNotificationCollections.length) {
        return;
      }
    }

    if (_isInitialized &&
        identical(_boundIsar, isar) &&
        _subscriptions.length == watchedNotificationCollections.length) {
      return;
    }

    late final Future<void> runFuture;
    runFuture = _performInitialize(
      isar: isar,
      service: service,
      scheduler: scheduler,
      buildStreams: buildStreams,
      isCancelled: isCancelled,
    ).whenComplete(() {
      if (identical(_inFlightInit, runFuture)) {
        _inFlightInit = null;
        _inFlightToken = null;
      }
    });
    _inFlightInit = runFuture;
    _inFlightToken = sessionToken;
    return runFuture;
  }

  Future<void> _performInitialize({
    required Isar isar,
    required NotificationService service,
    required NotificationScheduler scheduler,
    required NotificationCollectionStreamsBuilder buildStreams,
    required bool Function()? isCancelled,
  }) async {
    await resetListeners();

    if (_isDisposed || (isCancelled?.call() ?? false)) {
      return;
    }
    if (!isar.isOpen) {
      throw const DatabaseException(
        'Cannot initialize notifications when Isar database is closed.',
        'DB_NOT_OPEN',
      );
    }

    try {
      await service.initialize();
      if (_isDisposed || (isCancelled?.call() ?? false)) {
        return;
      }
      if (!isar.isOpen) {
        throw const DatabaseException(
          'Isar database closed during notification service initialization.',
          'DB_NOT_OPEN',
        );
      }

      // Request permissions asynchronously so it doesn't block app boot.
      unawaited(
        service.requestPermissions().catchError((
          Object error,
          StackTrace stackTrace,
        ) {
          debugPrint(
            'Asynchronous notification permission request failed: $error',
          );
          return false;
        }),
      );

      final streams = buildStreams(isar);
      _boundIsar = isar;

      for (final collectionName in watchedNotificationCollections) {
        final stream = streams[collectionName];
        if (stream == null) {
          throw StateError(
            'Missing watchLazy stream for notification collection: '
            '$collectionName',
          );
        }
        final sub = stream.listen(
          (_) => _onCollectionChanged(
            collectionName: collectionName,
            isar: isar,
            scheduler: scheduler,
          ),
          onError: (Object error, StackTrace stackTrace) {
            developer.log(
              'Notification DB listener error on $collectionName: $error',
              name: 'NotificationLifecycle',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );
        _subscriptions[collectionName] = sub;
      }

      if (_isDisposed || (isCancelled?.call() ?? false)) {
        await resetListeners();
        return;
      }

      await scheduler.rescheduleAll();
      if (_isDisposed || (isCancelled?.call() ?? false)) {
        await resetListeners();
        return;
      }

      _isInitialized = true;
      _lastError = null;
      _initializationCount++;
    } catch (error, stackTrace) {
      await resetListeners();
      _lastError = error;
      _isInitialized = false;
      developer.log(
        'Notification initialization failed: $error',
        name: 'NotificationLifecycle',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _onCollectionChanged({
    required String collectionName,
    required Isar isar,
    required NotificationScheduler scheduler,
  }) {
    if (_isDisposed ||
        _subscriptions.isEmpty ||
        !identical(_boundIsar, isar) ||
        !isar.isOpen ||
        scheduler.isDisposed) {
      return;
    }

    if (_rescheduleMicrotaskQueued) {
      return;
    }
    _rescheduleMicrotaskQueued = true;

    scheduleMicrotask(() {
      _rescheduleMicrotaskQueued = false;
      if (_isDisposed ||
          _subscriptions.isEmpty ||
          !identical(_boundIsar, isar) ||
          !isar.isOpen ||
          scheduler.isDisposed) {
        return;
      }

      _rescheduleTriggerCount++;
      unawaited(
        scheduler.rescheduleAll().catchError((
          Object error,
          StackTrace stackTrace,
        ) {
          developer.log(
            'Notification reschedule failed after DB change '
            '($collectionName): $error',
            name: 'NotificationLifecycle',
            error: error,
            stackTrace: stackTrace,
          );
        }),
      );
    });
  }

  Future<void> resetListeners() async {
    _isInitialized = false;
    _rescheduleMicrotaskQueued = false;
    _boundIsar = null;

    if (_subscriptions.isEmpty) {
      return;
    }

    final activeSubscriptions = _subscriptions.entries.toList(growable: false);
    _subscriptions.clear();

    final cancelFutures = <Future<void>>[];
    for (final entry in activeSubscriptions) {
      try {
        cancelFutures.add(
          entry.value.cancel().catchError((
            Object error,
            StackTrace stackTrace,
          ) {
            developer.log(
              'Failed to cancel notification listener for ${entry.key}: $error',
              name: 'NotificationLifecycle',
              error: error,
              stackTrace: stackTrace,
            );
          }),
        );
      } catch (error, stackTrace) {
        developer.log(
          'Failed to cancel notification listener for ${entry.key}: $error',
          name: 'NotificationLifecycle',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cancelFutures.isNotEmpty) {
      await Future.wait<void>(cancelFutures);
    }
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    await resetListeners();
  }
}

/// Stateless stream factory for the five watched Isar collections.
///
/// Kept auto-dispose because it holds no runtime state and is only needed when
/// registering or testing collection observers.
@riverpod
NotificationCollectionStreamsBuilder notificationCollectionStreamsBuilder(
  NotificationCollectionStreamsBuilderRef ref,
) {
  return defaultNotificationCollectionStreamsBuilder;
}

/// App-wide local notification service singleton retained for the container
/// lifetime so initialization state and plugin bindings persist across routes.
@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return LocalNotificationServiceImpl();
}

/// App-wide notification scheduler scoped to the active [Isar] instance.
///
/// Retained with `keepAlive: true` so single-flight scheduling serialization
/// persists across controller calls and database listeners, while rebuilding
/// cleanly if [isarProvider] is invalidated or retried.
@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(NotificationSchedulerRef ref) {
  final isarAsync = ref.watch(isarProvider);
  final isar = isarAsync.valueOrNull;
  if (isar == null || !isar.isOpen) {
    if (isarAsync.hasError) {
      Error.throwWithStackTrace(
        isarAsync.error!,
        isarAsync.stackTrace ?? StackTrace.current,
      );
    }
    throw StateError(
      'Cannot access NotificationScheduler before Isar database is initialized and open.',
    );
  }
  final service = ref.watch(notificationServiceProvider);
  final db = IsarNotificationDatabaseImpl(isar);
  final scheduler = NotificationScheduler(db, service);
  ref.onDispose(scheduler.dispose);
  return scheduler;
}

/// Retains the active database observer subscriptions for the app container
/// lifetime and cancels them on disposal.
@Riverpod(keepAlive: true)
NotificationLifecycleManager notificationLifecycleManager(
  NotificationLifecycleManagerRef ref,
) {
  final manager = NotificationLifecycleManager();
  ref.onDispose(() {
    unawaited(manager.dispose());
  });
  return manager;
}

/// Initializes local notifications, registers all five Isar `watchLazy`
/// listeners, and triggers initial scheduling once [isarProvider] is ready.
///
/// Marked `keepAlive: true` because it is triggered via one-shot reads during
/// startup and database recovery without permanent UI watchers.
@Riverpod(keepAlive: true)
Future<void> notificationInitializer(NotificationInitializerRef ref) async {
  final startupFailure = ref.watch(databaseStartupFailureProvider);
  if (startupFailure != null) {
    Error.throwWithStackTrace(startupFailure, StackTrace.current);
  }

  final isarFuture = ref.watch(isarProvider.future);
  final service = ref.watch(notificationServiceProvider);
  final manager = ref.watch(notificationLifecycleManagerProvider);
  final buildStreams = ref.watch(notificationCollectionStreamsBuilderProvider);

  final sessionToken = Object();
  var buildDisposed = false;
  ref.onDispose(() {
    buildDisposed = true;
    unawaited(manager.resetListeners());
  });

  final isar = await isarFuture;
  if (buildDisposed || manager.isDisposed) {
    return;
  }

  final latestStartupFailure = ref.read(databaseStartupFailureProvider);
  if (latestStartupFailure != null) {
    Error.throwWithStackTrace(latestStartupFailure, StackTrace.current);
  }

  if (!isar.isOpen) {
    throw const DatabaseException(
      'Cannot initialize notifications when Isar database is closed.',
      'DB_NOT_OPEN',
    );
  }

  final scheduler = ref.read(notificationSchedulerProvider);
  await manager.initialize(
    isar: isar,
    service: service,
    scheduler: scheduler,
    buildStreams: buildStreams,
    isCancelled: () => buildDisposed,
    sessionToken: sessionToken,
  );
}
