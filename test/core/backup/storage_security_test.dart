import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/backup/backup_path_helper.dart';
import 'package:attend_iq/core/backup/backup_providers.dart';
import 'package:attend_iq/core/backup/backup_service.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/widgets/export_success_dialog.dart';
import 'package:attend_iq/features/backup/presentation/pages/backup_page.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';
import 'package:attend_iq/features/settings/domain/repositories/settings_repository.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:share_plus/share_plus.dart';

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

class _FakeSettingsRepository implements SettingsRepository {
  UserPreferences _prefs = const UserPreferences(
    id: 'local_user',
    themeMode: 'dark',
    defaultAttendanceTarget: 75.0,
    classReminderOffset: 15,
    enableNotifications: true,
    enableAttendanceWarnings: true,
    weeklyReportEnabled: true,
  );

  @override
  Future<UserPreferences?> getPreferences(String userId) async => _prefs;

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    _prefs = preferences;
  }

  @override
  Stream<UserPreferences?> watchPreferences(String userId) =>
      Stream<UserPreferences?>.value(_prefs);
}

class _FakeSemesterRepository implements SemesterRepository {
  @override
  Future<void> createSemester(Semester semester) async {}

  @override
  Future<Semester?> getActiveSemester() async => null;

  @override
  Future<List<Semester>> getAllSemesters() async => <Semester>[];

  @override
  Future<Semester?> getSemesterById(int id) async => null;

  @override
  Future<bool> hasActiveSemester() async => false;

  @override
  Future<void> setActiveSemester(int id) async {}

  @override
  Future<void> archiveSemester(int id) async {}

  @override
  Future<void> updateSemester(Semester semester) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel storageChannel =
      MethodChannel('com.ramsa.attendiq/storage');
  const MethodChannel packageInfoChannel =
      MethodChannel('dev.fluttercommunity.plus/package_info');

  setUpAll(() async {
    final nativeLibPath = await _resolveIsarNativeLibraryPath();
    await Isar.initialize(nativeLibPath);
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(packageInfoChannel, (call) async {
      return <String, dynamic>{
        'appName': 'AttendIQ',
        'packageName': 'com.ramsa.attendiq.attend_iq',
        'version': '1.1.0',
        'buildNumber': '1',
      };
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(packageInfoChannel, null);
  });

  group('BUG-008: Manifest, FileProvider & Native Hardening', () {
    test(
      'source AndroidManifest.xml and res/xml remove prohibited storage permissions, legacy flag, and custom FileProvider',
      () {
        final manifestFile = File('android/app/src/main/AndroidManifest.xml');
        expect(manifestFile.existsSync(), isTrue);
        final manifest = manifestFile.readAsStringSync();

        expect(manifest, isNot(contains('MANAGE_EXTERNAL_STORAGE')));
        expect(manifest, isNot(contains('READ_EXTERNAL_STORAGE')));
        expect(manifest, isNot(contains('WRITE_EXTERNAL_STORAGE')));
        expect(manifest, isNot(contains('requestLegacyExternalStorage')));
        expect(manifest, isNot(contains('androidx.core.content.FileProvider')));
        expect(manifest, isNot(contains('@xml/file_paths')));

        expect(
          File('android/app/src/main/res/xml/file_paths.xml').existsSync(),
          isFalse,
        );
      },
    );

    test(
      'MainActivity.kt uses hardened MediaStore IS_PENDING + SAF ACTION_CREATE_DOCUMENT without FileProvider or /storage/emulated/0',
      () {
        final ktFile = File(
          'android/app/src/main/kotlin/com/ramsa/attendiq/attend_iq/MainActivity.kt',
        );
        expect(ktFile.existsSync(), isTrue);
        final kt = ktFile.readAsStringSync();

        expect(kt, isNot(contains('FileProvider')));
        expect(kt, isNot(contains('"openFile"')));
        expect(kt, isNot(contains('"openFolder"')));
        expect(kt, isNot(contains('/storage/emulated/0')));
        expect(kt, isNot(contains('getExternalStoragePublicDirectory')));

        expect(kt, contains('IS_PENDING'));
        expect(kt, contains('resolver.delete(uri, null, null)'));
        expect(kt, contains('ACTION_CREATE_DOCUMENT'));
        expect(kt, contains('DocumentsContract.deleteDocument'));
        expect(kt, contains('CREATE_DOCUMENT_REQUEST_CODE'));
        expect(kt, contains('"openExportUri"'));
      },
    );
  });

  group('BUG-008: ExportSaveResult, MediaStore, SAF, Sharing & Containment',
      () {
    test(
      'exportToFileResult populates both localFilePath and contentUri on API 29+ MediaStore copy while preserving exportToFile compatibility',
      () async {
        final tempRoot = await Directory.systemTemp.createTemp('bug008_dual_');
        final backupsDir =
            Directory('${tempRoot.path}${Platform.pathSeparator}backups');
        Isar? isar;
        try {
          isar = Isar.open(
            schemas: appIsarSchemas,
            directory: tempRoot.path,
            name: 'bug008_dual_db',
          );

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            if (call.method == 'saveToPublicStorage') {
              final args = call.arguments as Map<dynamic, dynamic>;
              expect(args['allowDocumentPicker'], isFalse);
              return <String, dynamic>{
                'contentUri': 'content://media/external/file/1042',
                'displayName': 'AttendIQ_Backup_Sem5_2026-11-11 (1).attendiq',
                'relativePath': 'Documents/AttendIQ/Backups',
                'cancelled': false,
                'unsupportedSaf': false,
              };
            }
            return null;
          });

          final service = BackupService(
            isar,
            backupsDirOverride: backupsDir,
            tempDirOverride: tempRoot,
            isAndroidOverride: true,
          );

          final result = await service.exportToFileResult(
            semesterName: 'Semester 5',
          );

          expect(result.hasLocalFile, isTrue);
          expect(result.hasContentUri, isTrue);
          expect(
            result.contentUri,
            'content://media/external/file/1042',
          );
          expect(File(result.localFilePath!).existsSync(), isTrue);
          expect(result.effectiveSharePath, result.localFilePath);
          expect(
            result.displayPath,
            'Internal Storage/Documents/AttendIQ/Backups/AttendIQ_Backup_Sem5_2026-11-11 (1).attendiq',
          );

          // Existing Future<String> compatibility returns app-private path.
          final compatPath = await service.exportToFile(
            customFileName: 'compat_backup.attendiq',
          );
          expect(
            compatPath,
            startsWith(await backupsDir.resolveSymbolicLinks()),
          );
          expect(File(compatPath).existsSync(), isTrue);
        } finally {
          isar?.close();
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        }
      },
    );

    test(
      'public MediaStore copy failure does NOT invalidate or delete the verified app-private backup',
      () async {
        final tempRoot =
            await Directory.systemTemp.createTemp('bug008_msfail_');
        final backupsDir =
            Directory('${tempRoot.path}${Platform.pathSeparator}backups');
        Isar? isar;
        try {
          isar = Isar.open(
            schemas: appIsarSchemas,
            directory: tempRoot.path,
            name: 'bug008_msfail_db',
          );

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            if (call.method == 'saveToPublicStorage') {
              throw PlatformException(
                code: 'SAVE_FAILED',
                message: 'Simulated MediaStore disk full',
              );
            }
            return null;
          });

          final service = BackupService(
            isar,
            backupsDirOverride: backupsDir,
            tempDirOverride: tempRoot,
            isAndroidOverride: true,
          );

          final result = await service.exportToFileResult(
            customFileName: 'resilient.attendiq',
          );

          expect(result.hasLocalFile, isTrue);
          expect(result.hasContentUri, isFalse);
          expect(File(result.localFilePath!).existsSync(), isTrue);
          final listed = await service.listBackups();
          expect(listed.map((e) => e.fileName), contains('resilient.attendiq'));
        } finally {
          isar?.close();
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        }
      },
    );

    test(
      'public MediaStore export handles contentUri, stages cache share path, and propagates MediaStore errors cleanly',
      () async {
        final tempRoot = await Directory.systemTemp.createTemp('bug008_pub_');
        try {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            if (call.method == 'saveToPublicStorage') {
              return <String, dynamic>{
                'contentUri': 'content://media/external/file/501',
                'displayName': 'Report (1).pdf',
                'relativePath': 'Documents/AttendIQ/Reports',
                'cancelled': false,
                'unsupportedSaf': false,
              };
            }
            return null;
          });

          final result = await BackupPathHelper.savePublicExportFile(
            fileName: 'Report.pdf',
            bytes: utf8.encode('%PDF-1.4 test'),
            subFolder: 'Reports',
            mimeType: 'application/pdf',
            isAndroidOverride: true,
            tempDirectoryOverride: tempRoot,
          );

          expect(result.hasLocalFile, isFalse);
          expect(result.hasContentUri, isTrue);
          expect(result.contentUri, 'content://media/external/file/501');
          expect(result.fileName, 'Report (1).pdf');
          expect(result.displayPath, isNot(contains('/storage/emulated/0')));
          expect(result.shareableFilePath, isNotNull);
          expect(File(result.shareableFilePath!).existsSync(), isTrue);

          // MediaStore write error surfaces as PlatformException.
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            throw PlatformException(
              code: 'SAVE_FAILED',
              message: 'MediaStore OutputStream null',
            );
          });

          expect(
            () => BackupPathHelper.savePublicExportFile(
              fileName: 'Fail.pdf',
              bytes: const [1, 2, 3],
              subFolder: 'Reports',
              mimeType: 'application/pdf',
              isAndroidOverride: true,
              tempDirectoryOverride: tempRoot,
            ),
            throwsA(isA<PlatformException>()),
          );
        } finally {
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        }
      },
    );

    test(
      'SAF ACTION_CREATE_DOCUMENT handles cancellation, explicit public backup copy, and unsupported-SAF app-private fallback',
      () async {
        final tempRoot = await Directory.systemTemp.createTemp('bug008_saf_');
        final backupsDir =
            Directory('${tempRoot.path}${Platform.pathSeparator}backups');
        final privateBaseDir =
            Directory('${tempRoot.path}${Platform.pathSeparator}priv_exports');
        Isar? isar;
        try {
          isar = Isar.open(
            schemas: appIsarSchemas,
            directory: tempRoot.path,
            name: 'bug008_saf_db',
          );

          final service = BackupService(
            isar,
            backupsDirOverride: backupsDir,
            privateExportBaseDirOverride: privateBaseDir,
            tempDirOverride: tempRoot,
            isAndroidOverride: true,
          );

          // 1. Prompt-free API 23-28 backup creation (skippedDocumentPicker: true).
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            return <String, dynamic>{
              'cancelled': false,
              'unsupportedSaf': false,
              'skippedDocumentPicker': true,
            };
          });

          final created = await service.exportToFileResult(
            customFileName: 'api28_backup.attendiq',
          );
          expect(created.hasLocalFile, isTrue);
          expect(created.hasContentUri, isFalse);

          // 2. Explicit "Save Copy to Device" SAF cancellation keeps private backup intact.
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            final args = call.arguments as Map<dynamic, dynamic>;
            expect(args['allowDocumentPicker'], isTrue);
            return <String, dynamic>{
              'cancelled': true,
              'unsupportedSaf': false,
            };
          });

          final cancelledCopy = await service.saveBackupCopyToPublicStorage(
            created.localFilePath!,
          );
          expect(cancelledCopy.wasCancelled, isTrue);
          expect(File(created.localFilePath!).existsSync(), isTrue);

          // 3. Explicit SAF success returns both localFilePath and contentUri.
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            return <String, dynamic>{
              'contentUri':
                  'content://com.android.externalstorage.documents/document/primary%3ADownload%2Fapi28_backup.attendiq',
              'displayName': 'api28_backup.attendiq',
              'relativePath': null,
              'cancelled': false,
              'unsupportedSaf': false,
            };
          });

          final savedCopy = await service.saveBackupCopyToPublicStorage(
            created.localFilePath!,
          );
          expect(savedCopy.wasCancelled, isFalse);
          expect(savedCopy.localFilePath, created.localFilePath);
          expect(savedCopy.hasContentUri, isTrue);

          // 4. Device lacking SAF activity falls back to documented app-private exports/.
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            return <String, dynamic>{
              'cancelled': false,
              'unsupportedSaf': true,
            };
          });

          final fallbackExport = await BackupPathHelper.savePublicExportFile(
            fileName: 'Fallback.csv',
            bytes: utf8.encode('a,b\n1,2\n'),
            subFolder: 'Exports',
            mimeType: 'text/csv',
            isAndroidOverride: true,
            privateExportBaseDirOverride: privateBaseDir,
            tempDirectoryOverride: tempRoot,
          );
          expect(fallbackExport.hasLocalFile, isTrue);
          expect(fallbackExport.hasContentUri, isFalse);
          expect(fallbackExport.displayPath, startsWith('App Storage/'));
          expect(File(fallbackExport.localFilePath!).existsSync(), isTrue);
        } finally {
          isar?.close();
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        }
      },
    );

    test(
      'managed backup read, share, delete, and public-copy enforce canonical containment and reject traversal/symlinks',
      () async {
        final tempRoot = await Directory.systemTemp.createTemp('bug008_sec_');
        final backupsDir =
            Directory('${tempRoot.path}${Platform.pathSeparator}backups');
        final outsideFile = File(
          '${tempRoot.path}${Platform.pathSeparator}attendiq_isar.isar',
        )..writeAsStringSync('sensitive-db');
        final siblingDir = Directory(
          '${tempRoot.path}${Platform.pathSeparator}backups_evil',
        )..createSync();
        final siblingFile = File(
          '${siblingDir.path}${Platform.pathSeparator}evil.attendiq',
        )..writeAsStringSync('{}');

        Isar? isar;
        try {
          isar = Isar.open(
            schemas: appIsarSchemas,
            directory: tempRoot.path,
            name: 'bug008_sec_db',
          );

          final service = BackupService(
            isar,
            backupsDirOverride: backupsDir,
            isAndroidOverride: false,
            shareFilesOverride: (files, {text, subject}) async {},
          );

          final localPath = await service.exportToFile(
            customFileName: 'safe.attendiq',
            saveToAppPrivateOnly: true,
          );
          expect(File(localPath).existsSync(), isTrue);

          final traversalPath =
              '${backupsDir.path}${Platform.pathSeparator}..${Platform.pathSeparator}attendiq_isar.isar';

          // Delete rejects traversal, sibling prefix tricks, and content:// URIs.
          expect(await service.deleteBackupFile(traversalPath), isFalse);
          expect(await service.deleteBackupFile(outsideFile.path), isFalse);
          expect(await service.deleteBackupFile(siblingFile.path), isFalse);
          expect(
            await service.deleteBackupFile('content://media/external/file/1'),
            isFalse,
          );
          expect(outsideFile.existsSync(), isTrue);
          expect(siblingFile.existsSync(), isTrue);

          // Share, read/restore, and public-copy reject outside paths.
          await expectLater(
            service.shareBackupFile(outsideFile.path),
            throwsA(isA<FileSystemException>()),
          );
          await expectLater(
            service.shareBackupFile('content://media/external/file/1'),
            throwsA(isA<FileSystemException>()),
          );
          await expectLater(
            service.validateManagedBackupFile(outsideFile.path),
            throwsA(isA<FileSystemException>()),
          );
          await expectLater(
            service.importManagedBackupFile(siblingFile.path),
            throwsA(isA<FileSystemException>()),
          );
          await expectLater(
            service.saveBackupCopyToPublicStorage(outsideFile.path),
            throwsA(isA<FileSystemException>()),
          );

          // Symlink escape guard (if OS allows symlink creation without elevated prompt).
          final symlinkDir = Directory(
            '${tempRoot.path}${Platform.pathSeparator}sym_root',
          );
          var symlinkSupported = true;
          try {
            await Link(symlinkDir.path).create(siblingDir.path);
          } on FileSystemException {
            symlinkSupported = false;
          }
          if (symlinkSupported) {
            await expectLater(
              BackupPathHelper.getAppBackupsDirectory(
                backupsDirOverride: symlinkDir,
              ),
              throwsA(isA<FileSystemException>()),
            );

            final linkInBackups = Link(
              '${backupsDir.path}${Platform.pathSeparator}escape.attendiq',
            );
            try {
              await linkInBackups.create(outsideFile.path);
              expect(
                await service.deleteBackupFile(linkInBackups.path),
                isFalse,
              );
              await expectLater(
                service.shareBackupFile(linkInBackups.path),
                throwsA(isA<FileSystemException>()),
              );
              // listBackups skips symlink entries cleanly.
              final listed = await service.listBackups();
              expect(
                listed.where((e) => e.fileName == 'escape.attendiq'),
                isEmpty,
              );
            } on FileSystemException {
              // Ignore if file-level symlink creation is restricted on host.
            }
          }

          // Valid in-root delete succeeds.
          expect(await service.deleteBackupFile(localPath), isTrue);
          expect(File(localPath).existsSync(), isFalse);
        } finally {
          isar?.close();
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        }
      },
    );

    test(
      'sharing when both localFilePath and contentUri exist shares local file path (never content://) and supports bytes SAF fallback',
      () async {
        final tempRoot = await Directory.systemTemp.createTemp('bug008_share_');
        final backupsDir =
            Directory('${tempRoot.path}${Platform.pathSeparator}backups');
        Isar? isar;
        try {
          isar = Isar.open(
            schemas: appIsarSchemas,
            directory: tempRoot.path,
            name: 'bug008_share_db',
          );

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            if (call.method == 'saveToPublicStorage') {
              return <String, dynamic>{
                'contentUri': 'content://media/external/file/777',
                'displayName': 'share_test.attendiq',
                'relativePath': 'Documents/AttendIQ/Backups',
                'cancelled': false,
                'unsupportedSaf': false,
              };
            }
            return null;
          });

          List<XFile>? sharedFiles;
          final service = BackupService(
            isar,
            backupsDirOverride: backupsDir,
            tempDirOverride: tempRoot,
            isAndroidOverride: true,
            shareFilesOverride: (files, {text, subject}) async {
              sharedFiles = files;
            },
            pickFileOverride: () async => PlatformFile(
              name: 'cloud.attendiq',
              size: 2,
              bytes: utf8.encode('{}'),
            ),
          );

          final exportResult = await service.exportToFileResult(
            customFileName: 'share_test.attendiq',
          );
          expect(exportResult.hasLocalFile, isTrue);
          expect(exportResult.hasContentUri, isTrue);

          await service.shareBackupFile(exportResult.localFilePath!);
          expect(sharedFiles, isNotNull);
          expect(sharedFiles!.single.path, exportResult.localFilePath);
          expect(sharedFiles!.single.path, isNot(startsWith('content://')));

          final picked = await service.pickImportFile();
          expect(picked, isNotNull);
          expect(picked!.content, '{}');
        } finally {
          isar?.close();
          if (await tempRoot.exists()) {
            await tempRoot.delete(recursive: true);
          }
        }
      },
    );

    testWidgets(
      'ExportSuccessDialog shares local/staged file when contentUri is present and triggers openExportUri',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        final tempRoot = Directory.systemTemp.createTempSync('bug008_dlg_');
        try {
          final staged = File(
            '${tempRoot.path}${Platform.pathSeparator}Report.pdf',
          )..writeAsBytesSync(const [1, 2, 3, 4]);

          final result = ExportSaveResult(
            localFilePath: null,
            contentUri: 'content://media/external/file/888',
            shareableFilePath: staged.path,
            displayPath:
                'Internal Storage/Documents/AttendIQ/Reports/Report.pdf',
            fileName: 'Report.pdf',
            subFolder: 'Reports',
          );

          String? openedUri;
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(storageChannel, (call) async {
            if (call.method == 'openExportUri') {
              final args = call.arguments as Map<dynamic, dynamic>;
              openedUri = args['contentUri'] as String?;
              return true;
            }
            return null;
          });

          List<XFile>? sharedFiles;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ExportSuccessDialog(
                  title: 'PDF Report exported successfully',
                  exportResult: result,
                  mimeType: 'application/pdf',
                  isAndroidOverride: true,
                  shareFilesOverride: (files, {text, subject}) async {
                    sharedFiles = files;
                  },
                ),
              ),
            ),
          );

          expect(find.text('Open File'), findsOneWidget);
          expect(find.text('Share File'), findsOneWidget);

          await tester.tap(find.text('Share File'));
          for (var i = 0; i < 10 && sharedFiles == null; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 25)),
            );
            await tester.pump();
          }
          expect(sharedFiles, isNotNull);
          expect(sharedFiles!.single.path, staged.path);
          expect(sharedFiles!.single.path, isNot(startsWith('content://')));

          await tester.tap(find.text('Open File'));
          for (var i = 0; i < 10 && openedUri == null; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 25)),
            );
            await tester.pump();
          }
          expect(openedUri, 'content://media/external/file/888');
        } finally {
          if (tempRoot.existsSync()) {
            tempRoot.deleteSync(recursive: true);
          }
        }
      },
    );

    testWidgets(
      'ExportSuccessDialog Save Copy to Device invokes SAF copy callback and updates to Open File',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        final tempRoot = Directory.systemTemp.createTempSync('bug008_copy_');
        try {
          final privateFile = File(
            '${tempRoot.path}${Platform.pathSeparator}backup.attendiq',
          )..writeAsStringSync('{}');

          final initialResult = ExportSaveResult(
            localFilePath: privateFile.path,
            contentUri: null,
            shareableFilePath: privateFile.path,
            displayPath: 'App Storage/Backups/backup.attendiq',
            fileName: 'backup.attendiq',
            subFolder: 'Backups',
          );

          var copyRequested = false;
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ExportSuccessDialog(
                  title: 'Backup exported successfully',
                  exportResult: initialResult,
                  mimeType: 'application/octet-stream',
                  onSavePublicCopy: () async {
                    copyRequested = true;
                    return initialResult.copyWith(
                      contentUri:
                          'content://com.android.externalstorage.documents/document/1',
                      displayPath: 'backup.attendiq',
                    );
                  },
                ),
              ),
            ),
          );

          expect(find.text('Save Copy to Device'), findsOneWidget);
          expect(find.text('Open File'), findsNothing);

          await tester.tap(find.text('Save Copy to Device'));
          await tester.pumpAndSettle();

          expect(copyRequested, isTrue);
          expect(find.text('Open File'), findsOneWidget);
          expect(find.text('Save Copy to Device'), findsNothing);
        } finally {
          if (tempRoot.existsSync()) {
            tempRoot.deleteSync(recursive: true);
          }
        }
      },
    );

    testWidgets(
      'BackupPage surfaces explicit error SnackBar when deleteBackupFile returns false',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        final tempRoot = Directory.systemTemp.createTempSync('bug008_delui_');
        final backupsDir =
            Directory('${tempRoot.path}${Platform.pathSeparator}backups')
              ..createSync();
        final backupFile = File(
          '${backupsDir.path}${Platform.pathSeparator}missing.attendiq',
        )..writeAsStringSync('{}');
        Isar? isar;
        try {
          isar = Isar.open(
            schemas: appIsarSchemas,
            directory: tempRoot.path,
            name: 'bug008_delui_db',
          );

          final service = BackupService(
            isar,
            backupsDirOverride: backupsDir,
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                settingsRepositoryProvider
                    .overrideWithValue(_FakeSettingsRepository()),
                semesterRepositoryProvider
                    .overrideWithValue(_FakeSemesterRepository()),
                backupServiceProvider.overrideWithValue(service),
              ],
              child: const MaterialApp(home: BackupPage()),
            ),
          );
          for (var i = 0; i < 10; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 25)),
            );
            await tester.pump();
          }
          await tester.pumpAndSettle();

          // Remove the file externally before confirming delete to force false.
          backupFile.deleteSync();

          final moreMenu = find.byIcon(Icons.more_vert).first;
          await tester.ensureVisible(moreMenu);
          await tester.tap(moreMenu);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
          for (var i = 0; i < 10; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 25)),
            );
            await tester.pump();
          }
          await tester.pumpAndSettle();

          expect(find.text('Failed to delete backup file.'), findsOneWidget);
        } finally {
          isar?.close();
          if (tempRoot.existsSync()) {
            tempRoot.deleteSync(recursive: true);
          }
        }
      },
    );
  });
}
