import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/academic_planner/data/models/academic_task_local.dart';
import '../../features/attendance/data/models/attendance_record_local.dart';
import '../../features/semester/data/models/semester_local.dart';
import '../../features/semester/data/repositories/semester_repository_impl.dart';
import '../../features/settings/data/models/user_preferences_local.dart';
import '../../features/subject/data/models/subject_local.dart';
import '../../features/timetable/data/models/academic_event_local.dart';
import '../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../features/timetable/data/models/schedule_exception_local.dart';
import '../../features/timetable/data/models/timetable_template_local.dart';
import '../../features/timetable/data/models/weekly_schedule_rule_local.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../event_generator/data/models/event_local.dart';
import '../notifications/models/notification_item.dart';
import '../notifications/scheduler/notification_database.dart';

part 'isar_provider.g.dart';

const List<IsarGeneratedSchema> appIsarSchemas = <IsarGeneratedSchema>[
  SemesterLocalSchema,
  SubjectLocalSchema,
  TimetableTemplateLocalSchema,
  WeeklyScheduleRuleLocalSchema,
  ScheduleExceptionLocalSchema,
  DailyScheduleOccurrenceLocalSchema,
  AcademicEventLocalSchema,
  AcademicTaskLocalSchema,
  EventLocalSchema,
  AttendanceRecordLocalSchema,
  NotificationItemSchema,
  UserPreferencesLocalSchema,
];

const Duration defaultDatabaseInitTimeout = Duration(seconds: 5);

typedef DatabaseDirectoryResolver = Future<String> Function();

typedef IsarOpener = FutureOr<Isar> Function({
  required List<IsarGeneratedSchema> schemas,
  required String name,
  required String directory,
});

typedef IsarMigrationRunner = Future<void> Function(Isar isar);

/// Resolves the persistent database directory without falling back to an
/// arbitrary relative directory on native platforms.
Future<String> defaultDatabaseDirectoryResolver() async {
  if (kIsWeb) {
    return '';
  }

  final String path;
  try {
    final appDir = await getApplicationDocumentsDirectory();
    path = appDir.path.trim();
  } catch (error, stackTrace) {
    developer.log(
      'Failed to locate application documents directory: $error',
      name: 'IsarDatabase',
      error: error,
      stackTrace: stackTrace,
    );
    Error.throwWithStackTrace(
      DatabaseException(
        'Unable to locate the application documents directory: $error',
        'DB_DIRECTORY_LOOKUP_FAILED',
      ),
      stackTrace,
    );
  }

  if (path.isEmpty) {
    throw const DatabaseException(
      'Application documents directory path is empty.',
      'DB_DIRECTORY_EMPTY',
    );
  }

  return path;
}

/// Returns an already-open Isar instance if present, otherwise opens one.
FutureOr<Isar> defaultIsarOpener({
  required List<IsarGeneratedSchema> schemas,
  required String name,
  required String directory,
}) {
  try {
    final existing = Isar.get(schemas: schemas, name: name);
    if (existing.isOpen) {
      return existing;
    }
  } on IsarNotReadyError {
    // Instance is not opened yet; open below.
  }

  return Isar.open(
    schemas: schemas,
    name: name,
    directory: directory,
  );
}

/// Manages single-flight Isar initialization, retention, and disposal per
/// application container lifecycle.
class IsarDatabaseManager {
  Isar? _activeInstance;
  Future<Isar>? _inFlightInit;
  Timer? _activeTimer;
  bool _isDisposed = false;

  Isar? get activeInstance => _activeInstance;
  bool get isDisposed => _isDisposed;

  Future<Isar> initialize({
    required DatabaseDirectoryResolver resolveDirectory,
    required IsarOpener openIsar,
    required IsarMigrationRunner runMigration,
    Duration timeout = defaultDatabaseInitTimeout,
  }) {
    if (_isDisposed) {
      return Future<Isar>.error(
        const DatabaseException(
          'Database manager has been disposed.',
          'DB_MANAGER_DISPOSED',
        ),
      );
    }

    final existing = _activeInstance;
    if (existing != null && existing.isOpen) {
      return Future<Isar>.value(existing);
    }

    final inFlight = _inFlightInit;
    if (inFlight != null) {
      return inFlight;
    }

    final completer = Completer<Isar>();
    final timer = Timer(timeout, () {
      if (identical(_activeTimer, null) && completer.isCompleted) {
        return;
      }
      if (!completer.isCompleted) {
        _activeTimer = null;
        _inFlightInit = null;
        final error = DatabaseException(
          'Database initialization timed out after ${timeout.inSeconds}s.',
          'DB_INIT_TIMEOUT',
        );
        developer.log(
          error.message,
          name: 'IsarDatabase',
          error: error,
        );
        completer.completeError(error, StackTrace.current);
      }
    });
    _activeTimer = timer;

    final future = completer.future;
    _inFlightInit = future;

    _runInitialization(
      resolveDirectory: resolveDirectory,
      openIsar: openIsar,
      runMigration: runMigration,
      completer: completer,
      timer: timer,
      expectedFuture: future,
    );

    return future;
  }

  Future<void> _runInitialization({
    required DatabaseDirectoryResolver resolveDirectory,
    required IsarOpener openIsar,
    required IsarMigrationRunner runMigration,
    required Completer<Isar> completer,
    required Timer timer,
    required Future<Isar> expectedFuture,
  }) async {
    try {
      final directory = await resolveDirectory();
      if (_isDisposed || completer.isCompleted) {
        return;
      }

      final isarInstance = await openIsar(
        schemas: appIsarSchemas,
        name: AppConstants.isarDbName,
        directory: directory,
      );

      if (_isDisposed) {
        _safeClose(isarInstance);
        return;
      }

      if (completer.isCompleted) {
        if (_activeInstance == null) {
          _safeClose(isarInstance);
        }
        return;
      }

      await runMigration(isarInstance);
      if (_isDisposed) {
        _safeClose(isarInstance);
        return;
      }

      if (completer.isCompleted) {
        if (_activeInstance == null) {
          _safeClose(isarInstance);
        }
        return;
      }

      timer.cancel();
      if (identical(_activeTimer, timer)) {
        _activeTimer = null;
      }
      if (identical(_inFlightInit, expectedFuture)) {
        _inFlightInit = null;
      }
      _activeInstance = isarInstance;
      completer.complete(isarInstance);
    } catch (error, stackTrace) {
      timer.cancel();
      if (identical(_activeTimer, timer)) {
        _activeTimer = null;
      }
      if (identical(_inFlightInit, expectedFuture)) {
        _inFlightInit = null;
      }
      if (_isDisposed || completer.isCompleted) {
        return;
      }
      developer.log(
        'Isar database initialization failed: $error',
        name: 'IsarDatabase',
        error: error,
        stackTrace: stackTrace,
      );
      completer.completeError(error, stackTrace);
    }
  }

  void _safeClose(Isar instance) {
    try {
      if (instance.isOpen) {
        instance.close();
      }
    } catch (error, stackTrace) {
      developer.log(
        'Failed to close Isar instance cleanly: $error',
        name: 'IsarDatabase',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _activeTimer?.cancel();
    _activeTimer = null;
    _inFlightInit = null;

    final instance = _activeInstance;
    _activeInstance = null;
    if (instance != null) {
      _safeClose(instance);
    }
  }
}

@Riverpod(keepAlive: true)
DatabaseDirectoryResolver databaseDirectoryResolver(
  DatabaseDirectoryResolverRef ref,
) {
  return defaultDatabaseDirectoryResolver;
}

@Riverpod(keepAlive: true)
IsarOpener isarOpener(IsarOpenerRef ref) {
  return defaultIsarOpener;
}

@Riverpod(keepAlive: true)
IsarMigrationRunner isarMigrationRunner(IsarMigrationRunnerRef ref) {
  return migrateLegacyDatabaseRecords;
}

@Riverpod(keepAlive: true)
Duration databaseInitTimeout(DatabaseInitTimeoutRef ref) {
  return defaultDatabaseInitTimeout;
}

@Riverpod(keepAlive: true)
IsarDatabaseManager isarDatabaseManager(IsarDatabaseManagerRef ref) {
  final manager = IsarDatabaseManager();
  ref.onDispose(manager.dispose);
  return manager;
}

@Riverpod(keepAlive: true)
class DatabaseStartupFailure extends _$DatabaseStartupFailure {
  @override
  Object? build() => null;

  void reportFailure(Object error) {
    state = error;
  }

  void clear() {
    state = null;
  }
}

@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) {
  final manager = ref.watch(isarDatabaseManagerProvider);
  final resolveDirectory = ref.watch(databaseDirectoryResolverProvider);
  final openIsar = ref.watch(isarOpenerProvider);
  final runMigration = ref.watch(isarMigrationRunnerProvider);
  final timeout = ref.watch(databaseInitTimeoutProvider);

  return manager.initialize(
    resolveDirectory: resolveDirectory,
    openIsar: openIsar,
    runMigration: runMigration,
    timeout: timeout,
  );
}

/// Runs all idempotent startup migrations for legacy Isar records.
Future<void> migrateLegacyDatabaseRecords(Isar isar) async {
  try {
    await migrateLegacySemesters(isar);
  } catch (error, stackTrace) {
    developer.log(
      'Error migrating legacy semesters: $error',
      name: 'IsarDatabase',
      error: error,
      stackTrace: stackTrace,
    );
  }
  await migrateLegacyTimetableTemplates(isar);
  try {
    await migrateLegacyNotificationItems(isar);
  } catch (error, stackTrace) {
    developer.log(
      'Error migrating legacy notification items: $error',
      name: 'IsarDatabase',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Idempotently migrates legacy [TimetableTemplateLocal] records into
/// [WeeklyScheduleRuleLocal] records without modifying existing data.
Future<void> migrateLegacyTimetableTemplates(Isar isar) async {
  try {
    final templates = isar.timetableTemplateLocals.where().findAll();
    if (templates.isEmpty) return;

    final existingRules = isar.weeklyScheduleRuleLocals.where().findAll();

    await isar.writeAsync((isarDb) {
      for (final template in templates) {
        if (template.isDeleted) continue;
        final alreadyExists = existingRules.any(
          (r) =>
              r.subjectId == template.subjectId &&
              r.dayOfWeek == template.weekday &&
              r.startTime == template.startTime &&
              r.endTime == template.endTime &&
              !r.isDeleted,
        );
        if (!alreadyExists) {
          final rule = WeeklyScheduleRuleLocal()
            ..id = isarDb.weeklyScheduleRuleLocals.autoIncrement()
            ..serverId = template.serverId
            ..subjectId = template.subjectId
            ..dayOfWeek = template.weekday
            ..startTime = template.startTime
            ..endTime = template.endTime
            ..room = template.room
            ..faculty = template.faculty
            ..isActive = true
            ..createdAt = template.createdAt
            ..updatedAt = DateTime.now().toUtc();
          isarDb.weeklyScheduleRuleLocals.put(rule);
        }
      }
    });
  } catch (error, stackTrace) {
    developer.log(
      'Error migrating legacy timetable templates: $error',
      name: 'IsarDatabase',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
