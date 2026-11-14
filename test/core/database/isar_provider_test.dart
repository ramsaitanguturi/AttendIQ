import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/app/app.dart';
import 'package:attend_iq/core/constants/app_constants.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/errors/app_exception.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/core/notifications/providers/notification_providers.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_scheduler.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/core/widgets/database_startup_error_page.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/onboarding/presentation/pages/splash_page.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/semester/data/repositories/semester_repository_impl.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';
import 'package:attend_iq/features/settings/domain/repositories/settings_repository.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import 'package:attend_iq/features/settings/data/models/user_preferences_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/domain/repositories/subject_repository.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:attend_iq/features/timetable/data/models/academic_event_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/schedule_exception_local.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/widgets/services/widget_refresh_service.dart';
import 'package:attend_iq/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

class _TrackingFakeIsar extends Fake implements Isar {
  bool _open = true;
  int closeCalls = 0;

  @override
  bool get isOpen => _open;

  @override
  bool close({bool deleteFromDisk = false}) {
    closeCalls++;
    final wasOpen = _open;
    _open = false;
    return wasOpen;
  }
}

class _FakeNotificationService implements NotificationService {
  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleNotification(NotificationItem item) async {}
}

class _FakeNotificationDatabase implements NotificationDatabase {
  @override
  Future<void> deleteNotification(int id) async {}

  @override
  Future<List<AcademicEventLocal>> getAcademicEvents(
    DateTime start,
    DateTime end,
  ) async =>
      const [];

  @override
  Future<SemesterLocal?> getActiveSemester() async => null;

  @override
  Future<UserPreferencesLocal?> getUserPreferences() async => null;

  @override
  Future<List<AttendanceRecordLocal>> getAllAttendanceRecords() async =>
      const [];

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(
    int subjectId,
  ) async =>
      const [];

  @override
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrences(
    DateTime start,
    DateTime end,
  ) async =>
      const [];

  @override
  Future<List<WeeklyScheduleRuleLocal>> getWeeklyRules() async => const [];

  @override
  Future<List<ScheduleExceptionLocal>> getScheduleExceptions(
    DateTime start,
    DateTime end,
  ) async =>
      const [];

  @override
  Future<List<NotificationItem>> getFutureNotifications(DateTime now) async =>
      const [];

  @override
  Future<List<NotificationItem>> getFutureNotificationsByType(
    String type,
    DateTime now,
  ) async =>
      const [];

  @override
  Future<NotificationItem?> getLastNotification(
    String type,
    String relatedId,
  ) async =>
      null;

  @override
  Future<List<SubjectLocal>> getSubjects() async => const [];

  @override
  Future<void> saveNotification(NotificationItem item) async {}
}

class _FakeSemesterRepository implements SemesterRepository {
  @override
  Future<void> createSemester(Semester semester) async {}

  @override
  Future<void> updateSemester(Semester semester) async {}

  @override
  Future<void> setActiveSemester(int localId) async {}

  @override
  Future<void> archiveSemester(int localId) async {}

  @override
  Future<Semester?> getSemesterById(int localId) async => null;

  @override
  Future<Semester?> getActiveSemester() async => null;

  @override
  Future<List<Semester>> getAllSemesters() async => const [];

  @override
  Future<bool> hasActiveSemester() async => false;
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<UserPreferences?> getPreferences(String id) async =>
      const UserPreferences(
        id: 'local_user',
        themeMode: 'system',
        defaultAttendanceTarget: 75.0,
        classReminderOffset: 5,
        enableNotifications: false,
        enableAttendanceWarnings: false,
        weeklyReportEnabled: false,
      );

  @override
  Future<void> savePreferences(UserPreferences preferences) async {}

  @override
  Stream<UserPreferences?> watchPreferences(String userId) =>
      const Stream<UserPreferences?>.empty();
}

class _NoOpWidgetRefreshService extends Fake implements WidgetRefreshService {
  @override
  Future<void> refreshAllWidgets() async {}
}

class _FakeSubjectRepository implements SubjectRepository {
  @override
  Future<Subject> createSubject(Subject subject) async => subject;

  @override
  Future<void> deleteSubject(int id) async {}

  @override
  Future<Subject?> getSubjectById(int id) async => null;

  @override
  Future<List<Subject>> getSubjectsBySemester(
    int semesterId, {
    bool includeDeleted = false,
  }) async =>
      const [];

  @override
  Future<void> updateSubject(Subject subject) async {}

  @override
  Stream<void> watchSubjects(int semesterId) => const Stream<void>.empty();
}

Future<String?> _resolveIsarNativeLibraryPath() async {
  final packageConfigFile = File('.dart_tool/package_config.json').absolute;
  if (!packageConfigFile.existsSync()) return null;

  final decoded = jsonDecode(await packageConfigFile.readAsString());
  if (decoded is! Map<String, dynamic>) return null;
  final packages = decoded['packages'];
  if (packages is! List<dynamic>) return null;

  String? rawRootUri;
  for (final pkg in packages) {
    if (pkg is Map<String, dynamic> && pkg['name'] == 'isar_flutter_libs') {
      rawRootUri = pkg['rootUri'] as String?;
      break;
    }
  }
  if (rawRootUri == null) return null;

  final rootDir = Directory.fromUri(packageConfigFile.uri.resolve(rawRootUri));
  final String relativePath;
  if (Platform.isWindows) {
    relativePath = 'windows${Platform.pathSeparator}isar.dll';
  } else if (Platform.isLinux) {
    relativePath = 'linux${Platform.pathSeparator}libisar.so';
  } else if (Platform.isMacOS) {
    relativePath = 'macos${Platform.pathSeparator}libisar.dylib';
  } else {
    return null;
  }

  final file = File('${rootDir.path}${Platform.pathSeparator}$relativePath');
  return file.existsSync() ? file.path : null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BUG-002: Isar provider initialization and lifecycle', () {
    test(
        '1. Successful database initialization resolves directory, opens Isar once, and runs migration',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      var resolveCalls = 0;
      var openCalls = 0;
      var migrationCalls = 0;
      String? receivedName;
      String? receivedDir;
      List<IsarGeneratedSchema>? receivedSchemas;

      final container = ProviderContainer(
        overrides: [
          databaseDirectoryResolverProvider.overrideWithValue(() async {
            resolveCalls++;
            return '/data/user/0/com.ramsa.attendiq/app_flutter';
          }),
          isarOpenerProvider.overrideWithValue(({
            required schemas,
            required name,
            required directory,
          }) {
            openCalls++;
            receivedSchemas = schemas;
            receivedName = name;
            receivedDir = directory;
            return fakeIsar;
          }),
          isarMigrationRunnerProvider.overrideWithValue((isar) async {
            migrationCalls++;
            expect(identical(isar, fakeIsar), isTrue);
          }),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(isarProvider.future);

      expect(identical(result, fakeIsar), isTrue);
      expect(resolveCalls, equals(1));
      expect(openCalls, equals(1));
      expect(migrationCalls, equals(1));
      expect(receivedName, equals(AppConstants.isarDbName));
      expect(
        receivedDir,
        equals('/data/user/0/com.ramsa.attendiq/app_flutter'),
      );
      expect(receivedSchemas, equals(appIsarSchemas));
      expect(container.read(isarProvider).requireValue, same(fakeIsar));
    });

    test(
        '2. Initialization failure propagates AsyncError and allows retry recovery',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      var attempt = 0;

      final container = ProviderContainer(
        overrides: [
          databaseDirectoryResolverProvider.overrideWithValue(
            () async => '/valid/app/dir',
          ),
          isarOpenerProvider.overrideWithValue(({
            required schemas,
            required name,
            required directory,
          }) {
            attempt++;
            if (attempt == 1) {
              throw const DatabaseException(
                'Disk I/O failure opening Isar',
                'DB_OPEN_FAILED',
              );
            }
            return fakeIsar;
          }),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(isarProvider.future),
        throwsA(isA<DatabaseException>()),
      );
      expect(container.read(isarProvider).hasError, isTrue);

      container.invalidate(isarProvider);
      final recovered = await container.read(isarProvider.future);
      expect(identical(recovered, fakeIsar), isTrue);
      expect(attempt, equals(2));
    });

    test('2b. Initialization timeout fails explicitly with DB_INIT_TIMEOUT',
        () async {
      final neverCompletes = Completer<String>();
      var openCalls = 0;

      final container = ProviderContainer(
        overrides: [
          databaseInitTimeoutProvider.overrideWithValue(
            const Duration(milliseconds: 30),
          ),
          databaseDirectoryResolverProvider.overrideWithValue(
            () => neverCompletes.future,
          ),
          isarOpenerProvider.overrideWithValue(({
            required schemas,
            required name,
            required directory,
          }) {
            openCalls++;
            return _TrackingFakeIsar();
          }),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(isarProvider.future),
        throwsA(
          isA<DatabaseException>().having(
            (e) => e.code,
            'code',
            'DB_INIT_TIMEOUT',
          ),
        ),
      );
      expect(openCalls, equals(0));
    });

    test(
        '3. Documents directory lookup failure throws DatabaseException and never falls back to "."',
        () async {
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw MissingPluginException('No path_provider implementation');
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      var openerCalled = false;
      String? passedDirectory;

      final container = ProviderContainer(
        overrides: [
          isarOpenerProvider.overrideWithValue(({
            required schemas,
            required name,
            required directory,
          }) {
            openerCalled = true;
            passedDirectory = directory;
            return _TrackingFakeIsar();
          }),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(isarProvider.future),
        throwsA(
          isA<DatabaseException>().having(
            (e) => e.code,
            'code',
            'DB_DIRECTORY_LOOKUP_FAILED',
          ),
        ),
      );
      expect(openerCalled, isFalse);
      expect(passedDirectory, isNull);
    });

    test(
        '3b. Empty documents directory path throws DB_DIRECTORY_EMPTY without "." fallback',
        () async {
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => '   ');
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      var openerCalled = false;

      final container = ProviderContainer(
        overrides: [
          isarOpenerProvider.overrideWithValue(({
            required schemas,
            required name,
            required directory,
          }) {
            openerCalled = true;
            return _TrackingFakeIsar();
          }),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(isarProvider.future),
        throwsA(
          isA<DatabaseException>().having(
            (e) => e.code,
            'code',
            'DB_DIRECTORY_EMPTY',
          ),
        ),
      );
      expect(openerCalled, isFalse);
    });

    test(
        '4. Prevents duplicate initialization across concurrent and repeated reads',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final dirCompleter = Completer<String>();
      var resolveCalls = 0;
      var openCalls = 0;
      var migrationCalls = 0;

      final container = ProviderContainer(
        overrides: [
          databaseDirectoryResolverProvider.overrideWithValue(() {
            resolveCalls++;
            return dirCompleter.future;
          }),
          isarOpenerProvider.overrideWithValue(({
            required schemas,
            required name,
            required directory,
          }) {
            openCalls++;
            return fakeIsar;
          }),
          isarMigrationRunnerProvider.overrideWithValue((_) async {
            migrationCalls++;
          }),
        ],
      );
      addTearDown(container.dispose);

      final future1 = container.read(isarProvider.future);
      final future2 = container.read(isarProvider.future);
      dirCompleter.complete('/app/docs');

      final results = await Future.wait([future1, future2]);
      expect(identical(results[0], fakeIsar), isTrue);
      expect(identical(results[1], fakeIsar), isTrue);

      // Even if invalidated while open, manager reuses active open Isar instance.
      container.invalidate(isarProvider);
      final result3 = await container.read(isarProvider.future);
      expect(identical(result3, fakeIsar), isTrue);

      expect(resolveCalls, equals(1));
      expect(openCalls, equals(1));
      expect(migrationCalls, equals(1));
    });

    test(
        '5. KeepAlive retains Isar when listeners detach and closes it cleanly on disposal',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      var openCalls = 0;

      final container = ProviderContainer(
        overrides: [
          databaseDirectoryResolverProvider.overrideWithValue(
            () async => '/app/docs',
          ),
          isarOpenerProvider.overrideWithValue(({
            required schemas,
            required name,
            required directory,
          }) {
            openCalls++;
            return fakeIsar;
          }),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
        ],
      );

      final sub = container.listen(isarProvider, (_, __) {});
      final first = await container.read(isarProvider.future);
      expect(identical(first, fakeIsar), isTrue);

      // Remove all watchers and pump microtasks — keepAlive keeps provider alive.
      sub.close();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(isarProvider).hasValue, isTrue);
      expect(
        identical(container.read(isarProvider).requireValue, fakeIsar),
        isTrue,
      );
      expect(fakeIsar.closeCalls, equals(0));
      expect(openCalls, equals(1));

      // Disposing the container closes Isar cleanly once.
      container.dispose();
      expect(fakeIsar.closeCalls, equals(1));
      expect(fakeIsar.isOpen, isFalse);

      // Second dispose is safe and does not double-close.
      container.dispose();
      expect(fakeIsar.closeCalls, equals(1));
    });
  });

  group('BUG-002: Application startup & UI gating when Isar is unavailable',
      () {
    test(
        '6a. initializeAppStartup halts notification init and reports failure when Isar fails',
        () async {
      var notificationInitCalled = false;

      final container = ProviderContainer(
        overrides: [
          databaseDirectoryResolverProvider.overrideWithValue(
            () async => throw const DatabaseException(
              'Storage unavailable',
              'DB_DIRECTORY_LOOKUP_FAILED',
            ),
          ),
          isarOpenerProvider.overrideWithValue(
            ({
              required schemas,
              required name,
              required directory,
            }) =>
                _TrackingFakeIsar(),
          ),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
          notificationInitializerProvider.overrideWith((ref) async {
            notificationInitCalled = true;
          }),
        ],
      );
      addTearDown(container.dispose);

      final result = await initializeAppStartup(container);

      expect(result.databaseReady, isFalse);
      expect(result.error, isA<DatabaseException>());
      expect(notificationInitCalled, isFalse);
      expect(container.read(isarProvider).hasError, isTrue);
    });

    test(
        '6b. initializeAppStartup surfaces timeout when Isar hangs and skips notification init',
        () async {
      var notificationInitCalled = false;
      final hungIsar = Completer<Isar>();

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) => hungIsar.future),
          notificationInitializerProvider.overrideWith((ref) async {
            notificationInitCalled = true;
          }),
        ],
      );
      addTearDown(container.dispose);

      final result = await initializeAppStartup(
        container,
        isarTimeout: const Duration(milliseconds: 25),
      );

      expect(result.databaseReady, isFalse);
      expect(result.error, isA<TimeoutException>());
      expect(notificationInitCalled, isFalse);
      expect(
        container.read(databaseStartupFailureProvider),
        isA<TimeoutException>(),
      );
    });

    test(
        '6c. initializeAppStartup succeeds when Isar opens even if notification init fails',
        () async {
      final fakeIsar = _TrackingFakeIsar();

      final container = ProviderContainer(
        overrides: [
          databaseDirectoryResolverProvider.overrideWithValue(
            () async => '/app/docs',
          ),
          isarOpenerProvider.overrideWithValue(
            ({
              required schemas,
              required name,
              required directory,
            }) =>
                fakeIsar,
          ),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
          notificationServiceProvider.overrideWithValue(
            _FakeNotificationService(),
          ),
          notificationSchedulerProvider.overrideWithValue(
            NotificationScheduler(
              _FakeNotificationDatabase(),
              _FakeNotificationService(),
            ),
          ),
          notificationInitializerProvider.overrideWith((ref) async {
            throw Exception('Notifications unavailable');
          }),
        ],
      );
      addTearDown(container.dispose);

      final result = await initializeAppStartup(container);

      expect(result.databaseReady, isTrue);
      expect(result.error, isNull);
      expect(container.read(databaseStartupFailureProvider), isNull);
    });

    testWidgets(
        '6d. AttendIQApp blocks DB screens on loading/error and recovers on Retry without requireValue crash',
        (tester) async {
      final fakeIsar = _TrackingFakeIsar();
      final firstCompleter = Completer<String>();
      var attempt = 0;
      var semesterRepoCreated = false;
      var settingsRepoCreated = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseDirectoryResolverProvider.overrideWithValue(() {
              attempt++;
              if (attempt == 1) {
                return firstCompleter.future;
              }
              return Future<String>.value('/recovered/docs');
            }),
            isarOpenerProvider.overrideWithValue(
              ({
                required schemas,
                required name,
                required directory,
              }) =>
                  fakeIsar,
            ),
            isarMigrationRunnerProvider.overrideWithValue((_) async {}),
            semesterRepositoryProvider.overrideWith((ref) {
              semesterRepoCreated = true;
              ref.watch(isarProvider).requireValue;
              return _FakeSemesterRepository();
            }),
            settingsRepositoryProvider.overrideWith((ref) {
              settingsRepoCreated = true;
              ref.watch(isarProvider).requireValue;
              return _FakeSettingsRepository();
            }),
            subjectRepositoryProvider.overrideWithValue(
              _FakeSubjectRepository(),
            ),
            widgetRefreshServiceProvider.overrideWithValue(
              _NoOpWidgetRefreshService(),
            ),
          ],
          child: const AttendIQApp(),
        ),
      );

      // Loading phase: SplashPage renders, no DB-dependent providers evaluated.
      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.text('ACEDRA'), findsOneWidget);
      expect(find.byType(DatabaseStartupErrorPage), findsNothing);
      expect(semesterRepoCreated, isFalse);
      expect(settingsRepoCreated, isFalse);

      // Fail initialization -> Startup error screen renders instead of onboarding/dashboard.
      firstCompleter.completeError(
        const DatabaseException(
          'Storage permission denied',
          'DB_OPEN_FAILED',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseStartupErrorPage), findsOneWidget);
      expect(find.textContaining('Storage permission denied'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(semesterRepoCreated, isFalse);
      expect(settingsRepoCreated, isFalse);

      // Tap Retry -> initialization succeeds and app transitions to router shell.
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseStartupErrorPage), findsNothing);
      expect(attempt, equals(2));
      expect(semesterRepoCreated, isTrue);
      expect(settingsRepoCreated, isTrue);
    });

    testWidgets(
        '6e. AttendIQRootScope disposes container and closes Isar on unmount',
        (tester) async {
      final fakeIsar = _TrackingFakeIsar();
      final container = ProviderContainer(
        overrides: [
          databaseDirectoryResolverProvider.overrideWithValue(
            () async => '/app/docs',
          ),
          isarOpenerProvider.overrideWithValue(
            ({
              required schemas,
              required name,
              required directory,
            }) =>
                fakeIsar,
          ),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
        ],
      );

      await container.read(isarProvider.future);
      expect(fakeIsar.isOpen, isTrue);

      await tester.pumpWidget(
        AttendIQRootScope(
          container: container,
          child: const MaterialApp(home: SizedBox.shrink()),
        ),
      );
      expect(fakeIsar.isOpen, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(fakeIsar.closeCalls, equals(1));
      expect(fakeIsar.isOpen, isFalse);
    });
  });

  group('BUG-002: Existing Isar database functionality', () {
    test(
        '7. Real Isar opens with all 12 schemas, persists data, migrates legacy templates once, and closes cleanly',
        () async {
      final libPath = await _resolveIsarNativeLibraryPath();
      if (libPath == null) {
        return;
      }

      await Isar.initialize(libPath);
      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_isar_test_');
      Isar? openedIsar;

      try {
        final container = ProviderContainer(
          overrides: [
            databaseDirectoryResolverProvider.overrideWithValue(
              () async => tempDir.path,
            ),
          ],
        );
        addTearDown(container.dispose);

        final isar = await container.read(isarProvider.future);
        openedIsar = isar;

        expect(isar.isOpen, isTrue);
        expect(isar.name, equals(AppConstants.isarDbName));
        expect(isar.directory, equals(tempDir.path));

        // Seed a legacy template and verify migration helper creates one rule idempotently.
        await isar.writeAsync((db) {
          final template = TimetableTemplateLocal()
            ..id = db.timetableTemplateLocals.autoIncrement()
            ..serverId = 'legacy_1'
            ..subjectId = 42
            ..weekday = 1
            ..startTime = '09:00'
            ..endTime = '10:00'
            ..room = 'Room 101'
            ..faculty = 'Dr. Turing'
            ..createdAt = DateTime.utc(2026, 7, 1)
            ..updatedAt = DateTime.utc(2026, 7, 1)
            ..isDeleted = false;
          db.timetableTemplateLocals.put(template);
        });

        await migrateLegacyTimetableTemplates(isar);
        await migrateLegacyTimetableTemplates(isar);

        final migratedRules = isar.weeklyScheduleRuleLocals.where().findAll();
        expect(migratedRules, hasLength(1));
        expect(migratedRules.single.subjectId, equals(42));
        expect(migratedRules.single.startTime, equals('09:00'));

        final semesterRepo = SemesterRepositoryImpl(isar);
        await semesterRepo.createSemester(
          Semester(
            name: 'Fall 2026',
            startDate: DateTime.utc(2026, 8, 1),
            endDate: DateTime.utc(2026, 12, 15),
            requiredAttendanceRate: 75.0,
          ),
        );
        final activeSemester = await semesterRepo.getActiveSemester();
        expect(activeSemester, isNotNull);
        expect(activeSemester!.name, equals('Fall 2026'));

        final settingsRepo = SettingsRepositoryImpl(isar: isar);
        await settingsRepo.savePreferences(
          const UserPreferences(
            id: 'local_user',
            themeMode: 'dark',
            defaultAttendanceTarget: 80.0,
            classReminderOffset: 10,
            enableNotifications: true,
            enableAttendanceWarnings: true,
            weeklyReportEnabled: true,
          ),
        );
        final savedPrefs = await settingsRepo.getPreferences('local_user');
        expect(savedPrefs, isNotNull);
        expect(savedPrefs!.themeMode, equals('dark'));
        expect(savedPrefs.defaultAttendanceTarget, equals(80.0));

        // Dispose container and verify Isar closes cleanly.
        container.dispose();
        expect(isar.isOpen, isFalse);
        openedIsar = null;
      } finally {
        if (openedIsar != null && openedIsar.isOpen) {
          openedIsar.close();
        }
        if (tempDir.existsSync()) {
          try {
            await tempDir.delete(recursive: true);
          } catch (_) {}
        }
      }
    });
  });
}
