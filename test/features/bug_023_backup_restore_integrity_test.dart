import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/backup/backup_exporter.dart';
import 'package:attend_iq/core/backup/backup_importer.dart';
import 'package:attend_iq/core/backup/backup_scheduler.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/settings/data/models/user_preferences_local.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

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

UserPreferencesLocal _createTestPref({
  int id = 1,
  String themeMode = 'system',
  double defaultAttendanceTarget = 75.0,
  int classReminderOffset = 15,
  bool enableNotifications = true,
  bool enableAttendanceWarnings = true,
  bool weeklyReportEnabled = true,
  bool enableAutoBackup = false,
  int autoBackupDay = 7,
  int autoBackupHour = 2,
  DateTime? lastBackupDate,
  DateTime? updatedAt,
}) {
  return UserPreferencesLocal()
    ..id = id
    ..themeMode = themeMode
    ..defaultAttendanceTarget = defaultAttendanceTarget
    ..classReminderOffset = classReminderOffset
    ..enableNotifications = enableNotifications
    ..enableAttendanceWarnings = enableAttendanceWarnings
    ..weeklyReportEnabled = weeklyReportEnabled
    ..enableAutoBackup = enableAutoBackup
    ..autoBackupDay = autoBackupDay
    ..autoBackupHour = autoBackupHour
    ..lastBackupDate = lastBackupDate
    ..updatedAt = updatedAt ?? DateTime.now().toUtc();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final nativeLibPath = await _resolveIsarNativeLibraryPath();
    await Isar.initialize(nativeLibPath);
  });

  group('BUG-023: Backup & Restore Integrity Regression Tests', () {
    late Directory tempDir;
    late Isar isar;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('bug023_test_');
      isar = Isar.open(
        schemas: appIsarSchemas,
        directory: tempDir.path,
        name: 'bug023_db',
      );
    });

    tearDown(() async {
      if (isar.isOpen) {
        isar.close();
      }
      if (tempDir.existsSync()) {
        try {
          await tempDir.delete(recursive: true);
        } catch (_) {}
      }
    });

    test(
        '1. Auto-backup preference preservation: export serializes auto-backup preferences',
        () async {
      final now = DateTime.utc(2026, 7, 20, 10, 0);

      isar.write((db) {
        final pref = _createTestPref(
          id: 1,
          themeMode: 'dark',
          defaultAttendanceTarget: 85.0,
          classReminderOffset: 20,
          enableAutoBackup: true,
          autoBackupDay: DateTime.wednesday, // 3
          autoBackupHour: 4,
          lastBackupDate: now,
          updatedAt: now,
        );
        db.userPreferencesLocals.put(pref);
      });

      final exporter = BackupExporter(isar);
      final backupData = await exporter.exportData();
      final decoded = backupData.toJson();

      final userPrefsList = decoded['userPreferences'] as List<dynamic>;
      expect(userPrefsList, isNotEmpty);
      final exportedPref = userPrefsList.first as Map<String, dynamic>;

      expect(exportedPref['enableAutoBackup'], isTrue);
      expect(exportedPref['autoBackupDay'], equals(3));
      expect(exportedPref['autoBackupHour'], equals(4));
      expect(exportedPref['lastBackupDate'], isNotNull);
      expect(
        DateTime.parse(exportedPref['lastBackupDate'] as String).toUtc(),
        equals(now),
      );
    });

    test(
        '2. Auto-backup preference preservation: Replace restore restores enabled settings',
        () async {
      final lastBackup = DateTime.utc(2026, 7, 20, 10, 0);

      // Current DB has auto-backup disabled
      isar.write((db) {
        final currentPref = _createTestPref(
          id: 1,
          themeMode: 'system',
          enableAutoBackup: false,
          autoBackupDay: 7,
          autoBackupHour: 2,
        );
        db.userPreferencesLocals.put(currentPref);
      });

      // Incoming backup payload with enabled auto backup
      final backupPayload = jsonEncode({
        'metadata': {
          'appVersion': '1.0.0',
          'backupVersion': 2,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'devicePlatform': 'android',
        },
        'userPreferences': [
          {
            'id': 1,
            'themeMode': 'dark',
            'defaultAttendanceTarget': 80.0,
            'classReminderOffset': 15,
            'enableNotifications': true,
            'enableAttendanceWarnings': true,
            'weeklyReportEnabled': true,
            'enableAutoBackup': true,
            'autoBackupDay': 2, // Tuesday
            'autoBackupHour': 5,
            'lastBackupDate': lastBackup.toIso8601String(),
          }
        ],
        'semesters': <Map<String, dynamic>>[],
        'subjects': <Map<String, dynamic>>[],
        'attendance': <Map<String, dynamic>>[],
        'timetable': <Map<String, dynamic>>[],
        'events': <Map<String, dynamic>>[],
        'notifications': <Map<String, dynamic>>[],
      });

      final importer = BackupImporter(isar);
      await importer.importData(
        backupPayload,
        strategy: ImportStrategy.replace,
      );

      final restoredPrefs = await isar.userPreferencesLocals.getAsync(1);
      expect(restoredPrefs, isNotNull);
      expect(restoredPrefs!.enableAutoBackup, isTrue);
      expect(restoredPrefs.autoBackupDay, equals(2));
      expect(restoredPrefs.autoBackupHour, equals(5));
      expect(restoredPrefs.lastBackupDate, isNotNull);
      expect(restoredPrefs.themeMode, equals('dark'));
    });

    test(
        '3. Older backup compatibility on Merge: preserves existing auto-backup configuration',
        () async {
      final existingDate = DateTime.utc(2026, 7, 15, 8, 30);

      // Target DB has user's configured auto-backup
      isar.write((db) {
        final existingPref = _createTestPref(
          id: 1,
          themeMode: 'light',
          enableAutoBackup: true,
          autoBackupDay: 1, // Monday
          autoBackupHour: 6,
          lastBackupDate: existingDate,
          updatedAt: existingDate,
        );
        db.userPreferencesLocals.put(existingPref);
      });

      // Older backup WITHOUT enableAutoBackup / autoBackupDay / autoBackupHour
      final legacyBackupPayload = jsonEncode({
        'metadata': {
          'appVersion': '1.0.0',
          'backupVersion': 1,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'devicePlatform': 'android',
        },
        'userPreferences': [
          {
            'id': 1,
            'themeMode': 'dark',
            'defaultAttendanceTarget': 75.0,
            'classReminderOffset': 10,
            'enableNotifications': true,
            'enableAttendanceWarnings': true,
            'weeklyReportEnabled': true,
          }
        ],
        'semesters': <Map<String, dynamic>>[],
        'subjects': <Map<String, dynamic>>[],
        'attendance': <Map<String, dynamic>>[],
        'timetable': <Map<String, dynamic>>[],
        'events': <Map<String, dynamic>>[],
        'notifications': <Map<String, dynamic>>[],
      });

      final importer = BackupImporter(isar);
      await importer.importData(
        legacyBackupPayload,
        strategy: ImportStrategy.merge,
      );

      final mergedPrefs = await isar.userPreferencesLocals.getAsync(1);
      expect(mergedPrefs, isNotNull);
      // Existing auto backup settings MUST be preserved on Merge!
      expect(mergedPrefs!.enableAutoBackup, isTrue);
      expect(mergedPrefs.autoBackupDay, equals(1));
      expect(mergedPrefs.autoBackupHour, equals(6));
      expect(
        mergedPrefs.lastBackupDate!.isAtSameMomentAs(existingDate),
        isTrue,
      );
    });

    test(
        '4. Older backup compatibility on Replace: safely uses fallback defaults',
        () async {
      isar.write((db) {
        final existingPref = _createTestPref(
          id: 1,
          themeMode: 'light',
          enableAutoBackup: true,
          autoBackupDay: 3,
          autoBackupHour: 4,
        );
        db.userPreferencesLocals.put(existingPref);
      });

      // Older backup WITHOUT auto-backup fields
      final legacyBackupPayload = jsonEncode({
        'metadata': {
          'appVersion': '1.0.0',
          'backupVersion': 1,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'devicePlatform': 'android',
        },
        'userPreferences': [
          {
            'id': 1,
            'themeMode': 'dark',
            'defaultAttendanceTarget': 75.0,
            'classReminderOffset': 10,
            'enableNotifications': true,
            'enableAttendanceWarnings': true,
            'weeklyReportEnabled': true,
          }
        ],
        'semesters': <Map<String, dynamic>>[],
        'subjects': <Map<String, dynamic>>[],
        'attendance': <Map<String, dynamic>>[],
        'timetable': <Map<String, dynamic>>[],
        'events': <Map<String, dynamic>>[],
        'notifications': <Map<String, dynamic>>[],
      });

      final importer = BackupImporter(isar);
      await importer.importData(
        legacyBackupPayload,
        strategy: ImportStrategy.replace,
      );

      final replacedPrefs = await isar.userPreferencesLocals.getAsync(1);
      expect(replacedPrefs, isNotNull);
      // Safe defaults: false, Sunday (7), 2 AM, null date
      expect(replacedPrefs!.enableAutoBackup, isFalse);
      expect(replacedPrefs.autoBackupDay, equals(7));
      expect(replacedPrefs.autoBackupHour, equals(2));
      expect(replacedPrefs.lastBackupDate, isNull);
    });

    test(
        '5. Malformed restore safety: corrupt JSON throws and database remains unchanged',
        () async {
      // Put initial data
      isar.write((db) {
        final sem = SemesterLocal()
          ..id = 100
          ..name = 'Spring 2026'
          ..startDate = DateTime.utc(2026, 1, 10)
          ..endDate = DateTime.utc(2026, 5, 20)
          ..requiredAttendanceRate = 75.0
          ..isActive = true
          ..createdAt = DateTime.now().toUtc()
          ..updatedAt = DateTime.now().toUtc();
        db.semesterLocals.put(sem);
      });

      final importer = BackupImporter(isar);

      // Attempt importing corrupted JSON string
      expect(
        () => importer.importData(
          '{"invalid_json": true, "corrupted": [',
          strategy: ImportStrategy.replace,
        ),
        throwsA(isA<FormatException>()),
      );

      // Verify database still has original semester untouched
      final preservedSem = await isar.semesterLocals.getAsync(100);
      expect(preservedSem, isNotNull);
      expect(preservedSem!.name, equals('Spring 2026'));
    });

    test(
        '6. Scheduled backup behavior: getNextScheduledBackup and scheduleOrCancelAutoBackup',
        () async {
      final mondayMorning = DateTime(2026, 7, 20, 9, 0);

      // Next scheduled Sunday 2 AM from Monday
      final next = BackupScheduler.getNextScheduledBackup(
        fromDate: mondayMorning,
        targetWeekday: DateTime.sunday,
        targetHour: 2,
      );
      expect(next.weekday, equals(DateTime.sunday));
      expect(next.hour, equals(2));
      expect(next.isAfter(mondayMorning), isTrue);

      // Calling scheduleOrCancelAutoBackup does not throw
      await expectLater(
        BackupScheduler.scheduleOrCancelAutoBackup(true),
        completes,
      );
      await expectLater(
        BackupScheduler.scheduleOrCancelAutoBackup(false),
        completes,
      );
    });

    test(
        '7. Restore provider invalidation: active providers reflect restored database state',
        () async {
      final now = DateTime.utc(2026, 7, 20, 10, 0);

      // Setup initial data in DB
      isar.write((db) {
        final sem = SemesterLocal()
          ..id = 1
          ..name = 'Semester 1'
          ..startDate = DateTime.utc(2026, 1, 1)
          ..endDate = DateTime.utc(2026, 6, 30)
          ..requiredAttendanceRate = 75.0
          ..isActive = true
          ..status = SemesterLocal.statusActive
          ..createdAt = now
          ..updatedAt = now;
        db.semesterLocals.put(sem);

        final pref = _createTestPref(
          id: 1,
          themeMode: 'light',
          enableAutoBackup: false,
        );
        db.userPreferencesLocals.put(pref);

        final sub = SubjectLocal()
          ..id = 1
          ..name = 'Initial Physics'
          ..code = 'PHY101'
          ..credits = 3
          ..attendanceTarget = 75.0
          ..color = '#2563EB'
          ..type = 'THEORY'
          ..semesterId = 1
          ..createdAt = now
          ..updatedAt = now;
        db.subjectLocals.put(sub);
      });

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) => isar),
        ],
      );
      addTearDown(container.dispose);

      final sub1 = container.listen(settingsControllerProvider, (_, __) {});
      final sub2 = container.listen(subjectListControllerProvider, (_, __) {});
      addTearDown(sub1.close);
      addTearDown(sub2.close);

      // Verify initial read
      final initialPrefs =
          await container.read(settingsControllerProvider.future);
      expect(initialPrefs.themeMode, equals('light'));

      final initialSubjects =
          await container.read(subjectListControllerProvider.future);
      expect(initialSubjects, hasLength(1));
      expect(initialSubjects.first.name, equals('Initial Physics'));

      // Restore new backup via Replace
      final backupPayload = jsonEncode({
        'metadata': {
          'appVersion': '1.0.0',
          'backupVersion': 2,
          'createdAt': now.toIso8601String(),
          'devicePlatform': 'android',
        },
        'userPreferences': [
          {
            'id': 1,
            'themeMode': 'dark',
            'defaultAttendanceTarget': 80.0,
            'classReminderOffset': 15,
            'enableNotifications': true,
            'enableAttendanceWarnings': true,
            'weeklyReportEnabled': true,
            'enableAutoBackup': true,
            'autoBackupDay': 7,
            'autoBackupHour': 2,
          }
        ],
        'semesters': [
          {
            'id': 1,
            'name': 'Semester 1',
            'startDate': DateTime.utc(2026, 1, 1).toIso8601String(),
            'endDate': DateTime.utc(2026, 6, 30).toIso8601String(),
            'requiredAttendanceRate': 75.0,
            'isActive': true,
            'status': 'ACTIVE',
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          }
        ],
        'subjects': [
          {
            'id': 2,
            'name': 'Restored Chemistry',
            'code': 'CHEM201',
            'credits': 4,
            'attendanceTarget': 80.0,
            'color': '#10B981',
            'type': 'THEORY',
            'semesterId': 1,
            'isDeleted': false,
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          }
        ],
        'attendance': <Map<String, dynamic>>[],
        'timetable': <Map<String, dynamic>>[],
        'events': <Map<String, dynamic>>[],
        'notifications': <Map<String, dynamic>>[],
      });

      final importer = BackupImporter(isar);
      await importer.importData(
        backupPayload,
        strategy: ImportStrategy.replace,
      );

      // Invalidate providers as done in _handlePostRestoreSuccess
      container.invalidate(activeSemesterProvider);
      container.invalidate(settingsControllerProvider);
      container.invalidate(subjectListControllerProvider);

      // Re-read providers
      final restoredSettings =
          await container.read(settingsControllerProvider.future);
      expect(restoredSettings.themeMode, equals('dark'));
      expect(restoredSettings.enableAutoBackup, isTrue);

      final restoredSubjects =
          await container.read(subjectListControllerProvider.future);
      expect(restoredSubjects, hasLength(1));
      expect(restoredSubjects.first.name, equals('Restored Chemistry'));
      expect(restoredSubjects.first.code, equals('CHEM201'));
    });
  });
}
