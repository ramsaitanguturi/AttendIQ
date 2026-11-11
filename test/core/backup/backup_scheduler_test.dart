import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/backup/backup_path_helper.dart';
import 'package:attend_iq/core/backup/backup_scheduler.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/features/settings/data/models/user_preferences_local.dart';
import 'package:flutter/services.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final nativeLibPath = await _resolveIsarNativeLibraryPath();
    await Isar.initialize(nativeLibPath);
  });

  group('BackupScheduler Unit Tests', () {
    test('getNextScheduledBackup from Monday returns upcoming Sunday 2 AM', () {
      // Monday 2026-07-20 10:00 AM
      final mondayDate = DateTime(2026, 7, 20, 10, 0);
      final nextScheduled = BackupScheduler.getNextScheduledBackup(
        fromDate: mondayDate,
        targetWeekday: DateTime.sunday,
        targetHour: 2,
      );

      // Should be Sunday 2026-07-26 02:00 AM
      expect(nextScheduled.year, 2026);
      expect(nextScheduled.month, 7);
      expect(nextScheduled.day, 26);
      expect(nextScheduled.hour, 2);
      expect(nextScheduled.weekday, DateTime.sunday);
    });

    test('getNextScheduledBackup from Sunday early morning returns today 2 AM',
        () {
      // Sunday 2026-07-26 01:30 AM
      final sundayEarly = DateTime(2026, 7, 26, 1, 30);
      final nextScheduled = BackupScheduler.getNextScheduledBackup(
        fromDate: sundayEarly,
        targetWeekday: DateTime.sunday,
        targetHour: 2,
      );

      expect(nextScheduled.day, 26);
      expect(nextScheduled.hour, 2);
    });

    test(
        'getNextScheduledBackup from Sunday after 2 AM returns next Sunday 2 AM',
        () {
      // Sunday 2026-07-26 03:00 AM
      final sundayLate = DateTime(2026, 7, 26, 3, 0);
      final nextScheduled = BackupScheduler.getNextScheduledBackup(
        fromDate: sundayLate,
        targetWeekday: DateTime.sunday,
        targetHour: 2,
      );

      // Should be next Sunday Aug 2, 2026
      expect(nextScheduled.year, 2026);
      expect(nextScheduled.month, 8);
      expect(nextScheduled.day, 2);
      expect(nextScheduled.hour, 2);
    });

    test(
      'checkAndRunAutoBackup writes app-private backup without invoking storage MethodChannel',
      () async {
        const storageChannel = MethodChannel('com.ramsa.attendiq/storage');
        var channelInvoked = false;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          channelInvoked = true;
          throw PlatformException(
            code: 'NO_ACTIVITY',
            message: 'Background isolate has no MainActivity.',
          );
        });

        final tempDir = await Directory.systemTemp.createTemp('sched_bg_');
        final backupsDir =
            Directory('${tempDir.path}${Platform.pathSeparator}backups');
        Isar? isar;
        try {
          isar = Isar.open(
            schemas: appIsarSchemas,
            directory: tempDir.path,
            name: 'sched_bg_db',
          );
          await isar.writeAsync((db) {
            final pref = UserPreferencesLocal()
              ..id = 1
              ..themeMode = 'system'
              ..defaultAttendanceTarget = 75.0
              ..classReminderOffset = 15
              ..enableNotifications = true
              ..enableAttendanceWarnings = true
              ..weeklyReportEnabled = true
              ..enableAutoBackup = true
              ..lastBackupDate = null
              ..updatedAt = DateTime.now().toUtc();
            db.userPreferencesLocals.put(pref);
          });

          final ran = await BackupScheduler.checkAndRunAutoBackup(
            isar,
            backupsDirOverride: backupsDir,
          );

          expect(ran, isTrue);
          expect(channelInvoked, isFalse);

          final listed = await BackupPathHelper.listBackupFiles(
            backupsDirOverride: backupsDir,
          );
          expect(listed, hasLength(1));
          expect(listed.first.fileName, startsWith('attendiq_backup_auto_'));
          expect(listed.first.fileName, endsWith('.attendiq'));

          final updatedPref = isar.userPreferencesLocals.where().findFirst();
          expect(updatedPref?.lastBackupDate, isNotNull);
        } finally {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, null);
          isar?.close();
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );
  });

  group('BackupPathHelper Unit Tests', () {
    test('getDisplayFolderPath returns valid display string', () async {
      final pathStr = await BackupPathHelper.getDisplayFolderPath();
      expect(pathStr, contains('Documents/AttendIQ'));
    });

    test('BackupFileItem formattedSize formats bytes correctly', () {
      final itemBytes = BackupFileItem(
        fileName: 'test.attendiq',
        filePath: '/path/test.attendiq',
        modifiedDate: DateTime.now(),
        sizeBytes: 500,
      );
      expect(itemBytes.formattedSize, '500 B');

      final itemKb = BackupFileItem(
        fileName: 'test.attendiq',
        filePath: '/path/test.attendiq',
        modifiedDate: DateTime.now(),
        sizeBytes: 1536, // 1.5 KB
      );
      expect(itemKb.formattedSize, '1.5 KB');

      final itemMb = BackupFileItem(
        fileName: 'test.attendiq',
        filePath: '/path/test.attendiq',
        modifiedDate: DateTime.now(),
        sizeBytes: 2621440, // 2.5 MB
      );
      expect(itemMb.formattedSize, '2.5 MB');
    });
  });
}
