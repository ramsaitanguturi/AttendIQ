import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/backup/backup_importer.dart';
import 'package:attend_iq/core/backup/backup_providers.dart';
import 'package:attend_iq/core/backup/backup_service.dart';
import 'package:attend_iq/core/backup/backup_validator.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/backup/presentation/pages/backup_page.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';
import 'package:attend_iq/features/settings/domain/repositories/settings_repository.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/utils/occurrence_identity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

class _PickCall {
  final FileType type;
  final List<String>? allowedExtensions;
  final bool withData;
  final bool allowMultiple;

  const _PickCall({
    required this.type,
    required this.allowedExtensions,
    required this.withData,
    required this.allowMultiple,
  });
}

class _FakeFilePicker extends FilePicker {
  final Future<FilePickerResult?> Function(_PickCall call) handler;
  final List<_PickCall> calls = <_PickCall>[];

  _FakeFilePicker(this.handler);

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    void Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) {
    final call = _PickCall(
      type: type,
      allowedExtensions: allowedExtensions,
      withData: withData,
      allowMultiple: allowMultiple,
    );
    calls.add(call);
    return handler(call);
  }
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

Isar _openTestIsar(Directory dir, {required String name}) {
  return Isar.open(
    schemas: appIsarSchemas,
    directory: dir.path,
    name: name,
  );
}

class _FakeSettingsRepository implements SettingsRepository {
  UserPreferences _prefs = const UserPreferences(
    id: 'local_user',
    themeMode: 'system',
    defaultAttendanceTarget: 75.0,
    classReminderOffset: 5,
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
  Future<void> archiveSemester(int localId) async {}

  @override
  Future<void> createSemester(Semester semester) async {}

  @override
  Future<Semester?> getActiveSemester() async => null;

  @override
  Future<List<Semester>> getAllSemesters() async => <Semester>[];

  @override
  Future<Semester?> getSemesterById(int localId) async => null;

  @override
  Future<bool> hasActiveSemester() async => false;

  @override
  Future<void> setActiveSemester(int localId) async {}

  @override
  Future<void> updateSemester(Semester semester) async {}
}

Map<String, dynamic> _buildV2BackupMap({
  int semesterId = 1,
  String semesterServerId = 'sem_v2_1',
  String semesterName = 'Fall 2026',
  int subjectId = 1,
  String subjectServerId = 'sub_v2_1',
  String subjectName = 'Algorithms',
  String subjectCode = 'CS301',
}) {
  final ts = DateTime.utc(2026, 9, 1, 8, 0);
  final slotKey = computeCanonicalSlotKey(
    date: DateTime.utc(2026, 9, 7),
    subjectId: subjectId,
    ruleId: 1,
    startTime: '09:00',
    endTime: '10:00',
    type: 'REGULAR_CLASS',
  );
  return <String, dynamic>{
    'metadata': <String, dynamic>{
      'appVersion': '1.1.0',
      'backupVersion': 2,
      'createdAt': ts.toIso8601String(),
      'devicePlatform': 'android',
    },
    'userPreferences': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'pref_1',
        'themeMode': 'dark',
        'defaultAttendanceTarget': 75.0,
        'classReminderOffset': 10,
        'enableNotifications': true,
        'enableAttendanceWarnings': true,
        'weeklyReportEnabled': true,
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'semesters': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': semesterId,
        'serverId': semesterServerId,
        'name': semesterName,
        'startDate': DateTime.utc(2026, 8, 1).toIso8601String(),
        'endDate': DateTime.utc(2026, 12, 20).toIso8601String(),
        'requiredAttendanceRate': 75.0,
        'isActive': true,
        'status': SemesterLocal.statusActive,
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'subjects': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': subjectId,
        'serverId': subjectServerId,
        'semesterId': semesterId,
        'name': subjectName,
        'code': subjectCode,
        'faculty': 'Dr. Ada',
        'credits': 4,
        'attendanceTarget': 75.0,
        'color': '#2563EB',
        'type': 'THEORY',
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'timetable': <Map<String, dynamic>>[],
    'events': <Map<String, dynamic>>[],
    'weeklyRules': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'rule_${subjectServerId}_1',
        'subjectId': subjectId,
        'legacyTemplateId': null,
        'dayOfWeek': 1,
        'startTime': '09:00',
        'endTime': '10:00',
        'room': 'R101',
        'faculty': 'Dr. Ada',
        'type': 'THEORY',
        'isActive': true,
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'occurrences': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'occ_${subjectServerId}_1',
        'date': DateTime.utc(2026, 9, 7).toIso8601String(),
        'subjectId': subjectId,
        'ruleId': 1,
        'legacyEventId': null,
        'slotKey': slotKey,
        'title': subjectName,
        'startTime': '09:00',
        'endTime': '10:00',
        'type': 'REGULAR_CLASS',
        'status': 'PRESENT',
        'createdFrom': 'WEEKLY_RULE',
        'room': 'R101',
        'faculty': 'Dr. Ada',
        'reason': null,
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'attendance': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'att_${subjectServerId}_1',
        'occurrenceId': 1,
        'legacyEventId': null,
        'eventId': 1,
        'subjectId': subjectId,
        'status': 'PRESENT',
        'markedAt': DateTime.utc(2026, 9, 7, 9, 5).toIso8601String(),
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'scheduleExceptions': <Map<String, dynamic>>[],
    'academicEvents': <Map<String, dynamic>>[],
    'tasks': <Map<String, dynamic>>[],
    'notifications': <Map<String, dynamic>>[],
    'migrationAudits': <Map<String, dynamic>>[],
    'reportsMetadata': <String, dynamic>{},
  };
}

Map<String, dynamic> _buildLegacyV1BackupMap() {
  return <String, dynamic>{
    'metadata': <String, dynamic>{
      'appVersion': '1.0.0',
      'backupVersion': 1,
    },
    'userPreferences': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'themeMode': 'system',
        'defaultAttendanceTarget': 75.0,
        'classReminderOffset': 5,
        'enableNotifications': true,
        'enableAttendanceWarnings': true,
        'weeklyReportEnabled': true,
      },
    ],
    'semesters': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'v1_sem_1',
        'name': 'Legacy V1 Sem',
        'startDate': '2026-01-10T00:00:00.000Z',
        'endDate': '2026-05-20T00:00:00.000Z',
        'requiredAttendanceRate': 75.0,
      },
    ],
    'subjects': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'v1_sub_1',
        'semesterId': 1,
        'name': 'Legacy Algorithms',
        'code': 'CS101',
        'credits': 4,
        'attendanceTarget': 75.0,
        'color': '#10B981',
        'type': 'THEORY',
      },
    ],
    'timetable': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'subjectId': 1,
        'weekday': 2,
        'startTime': '10:00',
        'endTime': '11:00',
      },
    ],
    'events': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'subjectId': 1,
        'date': '2026-02-03T00:00:00.000Z',
        'startTime': '10:00',
        'endTime': '11:00',
        'eventType': 'REGULAR_CLASS',
        'status': 'PRESENT',
      },
    ],
    'attendance': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'eventId': 1,
        'subjectId': 1,
        'status': 'PRESENT',
        'markedAt': '2026-02-03T10:05:00.000Z',
      },
    ],
    'notifications': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 0,
        'title': 'Legacy Reminder',
        'body': 'Starts at 10:00',
        'type': 'CLASS_REMINDER',
        'scheduledTime': '2026-02-03T09:50:00.000Z',
        'relatedId': '1',
        'isRead': false,
      },
    ],
  };
}

void _seedDestinationDb(Isar isar) {
  final ts = DateTime.utc(2026, 7, 1, 8, 0);
  isar.write((db) {
    db.semesterLocals.put(
      SemesterLocal()
        ..id = 10
        ..serverId = 'seed_sem_10'
        ..name = 'Existing Seed Semester'
        ..startDate = DateTime.utc(2026, 7, 1)
        ..endDate = DateTime.utc(2026, 11, 30)
        ..requiredAttendanceRate = 75.0
        ..isActive = true
        ..status = SemesterLocal.statusActive
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.subjectLocals.put(
      SubjectLocal()
        ..id = 10
        ..serverId = 'seed_sub_10'
        ..semesterId = 10
        ..name = 'Existing Seed Subject'
        ..code = 'SEED100'
        ..credits = 3
        ..attendanceTarget = 75.0
        ..color = '#10B981'
        ..type = 'THEORY'
        ..createdAt = ts
        ..updatedAt = ts,
    );
  });
}

Future<void> _pumpBackupPage(
  WidgetTester tester,
  BackupService service,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        settingsRepositoryProvider.overrideWithValue(_FakeSettingsRepository()),
        semesterRepositoryProvider.overrideWithValue(_FakeSemesterRepository()),
        backupServiceProvider.overrideWithValue(service),
      ],
      child: const MaterialApp(home: BackupPage()),
    ),
  );
  await tester.pump();
  await _drainAsyncAndSettle(
    tester,
    waitUntilAbsent: find.byType(CircularProgressIndicator),
  );
}

Future<void> _drainAsyncAndSettle(
  WidgetTester tester, {
  Finder? waitUntilAbsent,
}) async {
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    if (waitUntilAbsent != null &&
        waitUntilAbsent.evaluate().isEmpty &&
        find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      break;
    }
  }
  if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
    await tester.pumpAndSettle();
  }
}

Future<void> _tapImportButton(WidgetTester tester) async {
  final importButton = find.text(
    'Import Backup / Data File (Drive, Downloads, Documents)',
  );
  await tester.ensureVisible(importButton);
  await tester.tap(importButton);
  await tester.pump();
  await _drainAsyncAndSettle(
    tester,
    waitUntilAbsent: find.byType(CircularProgressIndicator),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const packageInfoChannel =
      MethodChannel('dev.fluttercommunity.plus/package_info');
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  late FilePicker originalFilePicker;

  setUpAll(() async {
    final nativeLibPath = await _resolveIsarNativeLibraryPath();
    await Isar.initialize(nativeLibPath);
    try {
      originalFilePicker = FilePicker.platform;
    } catch (_) {
      FilePickerIO.registerWith();
      originalFilePicker = FilePicker.platform;
    }
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      packageInfoChannel,
      (call) async => <String, dynamic>{
        'appName': 'AttendIQ',
        'packageName': 'com.ramsa.attendiq.attend_iq',
        'version': '1.1.0',
        'buildNumber': '1',
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      pathProviderChannel,
      (call) async => Directory.systemTemp.path,
    );
  });

  tearDown(() {
    FilePicker.platform = originalFilePicker;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(packageInfoChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  group('SUSP-001: Android Backup Import Picker & Validation', () {
    test(
      '1. Selecting a valid .attendiq backup uses FileType.any on Android and imports cleanly',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('susp001_att_');
        Isar? isar;
        try {
          isar = _openTestIsar(tempDir, name: 'susp001_att_db');
          final rawJson = jsonEncode(_buildV2BackupMap());
          final cachedFile = File(
            '${tempDir.path}${Platform.pathSeparator}AttendIQ_Backup_Fall_2026_2026-11-12.attendiq',
          )..writeAsStringSync(rawJson);

          final fakePicker = _FakeFilePicker((call) async {
            return FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'AttendIQ_Backup_Fall_2026_2026-11-12.attendiq',
                path: cachedFile.path,
                size: cachedFile.lengthSync(),
                identifier:
                    'content://com.android.providers.downloads.documents/document/msf%3A101',
              ),
            ]);
          });
          FilePicker.platform = fakePicker;

          final service = BackupService(
            isar,
            backupsDirOverride: tempDir,
            isAndroidOverride: true,
          );

          final picked = await service.pickImportFile();
          expect(picked, isNotNull);
          expect(
            picked!.fileName,
            'AttendIQ_Backup_Fall_2026_2026-11-12.attendiq',
          );
          expect(picked.filePath, cachedFile.path);
          expect(picked.content, rawJson);

          expect(fakePicker.calls, hasLength(1));
          expect(fakePicker.calls.single.type, FileType.any);
          expect(fakePicker.calls.single.allowedExtensions, isNull);
          expect(fakePicker.calls.single.withData, isFalse);

          await service.validateBackupPayload(picked.content, strategy: null);
          await service.importFromBackupString(
            picked.content,
            strategy: ImportStrategy.replace,
          );
          expect(isar.semesterLocals.count(), 1);
          expect(isar.subjectLocals.where().findAll().single.code, 'CS301');

          // Case-insensitive .ATTENDIQ extension is also accepted.
          final upperFile = File(
            '${tempDir.path}${Platform.pathSeparator}BACKUP.ATTENDIQ',
          )..writeAsStringSync(rawJson);
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'BACKUP.ATTENDIQ',
                path: upperFile.path,
                size: upperFile.lengthSync(),
              ),
            ]),
          );
          final pickedUpper = await service.pickImportFile();
          expect(pickedUpper, isNotNull);
          expect(pickedUpper!.fileName, 'BACKUP.ATTENDIQ');

          // Non-Android platforms preserve FileType.custom filter.
          final desktopPicker = _FakeFilePicker((_) async => null);
          FilePicker.platform = desktopPicker;
          final desktopService = BackupService(
            isar,
            backupsDirOverride: tempDir,
            isAndroidOverride: false,
          );
          expect(await desktopService.pickImportFile(), isNull);
          expect(desktopPicker.calls.single.type, FileType.custom);
          expect(
            desktopPicker.calls.single.allowedExtensions,
            const <String>['attendiq', 'json'],
          );
        } finally {
          isar?.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        }
      },
    );

    test(
      '2. Selecting a valid .json backup uses FileType.any on Android and validates cleanly',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('susp001_json_');
        Isar? isar;
        try {
          isar = _openTestIsar(tempDir, name: 'susp001_json_db');
          final rawJson = jsonEncode(_buildV2BackupMap());
          final cachedFile = File(
            '${tempDir.path}${Platform.pathSeparator}AttendIQ_Data_Fall_2026_2026-11-12 (1).json',
          )..writeAsStringSync(rawJson);

          final fakePicker = _FakeFilePicker((call) async {
            return FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'AttendIQ_Data_Fall_2026_2026-11-12 (1).json',
                path: cachedFile.path,
                size: cachedFile.lengthSync(),
                identifier: 'content://media/external/file/202',
              ),
            ]);
          });
          FilePicker.platform = fakePicker;

          final service = BackupService(
            isar,
            backupsDirOverride: tempDir,
            isAndroidOverride: true,
          );

          final picked = await service.pickImportFile();
          expect(picked, isNotNull);
          expect(
            picked!.fileName,
            'AttendIQ_Data_Fall_2026_2026-11-12 (1).json',
          );
          expect(fakePicker.calls.single.type, FileType.any);
          expect(fakePicker.calls.single.allowedExtensions, isNull);

          final validated = await service.validateBackupPayload(
            picked.content,
            strategy: null,
          );
          expect(validated.metadata.backupVersion, 2);
          expect(validated.semesters.single['name'], 'Fall 2026');
        } finally {
          isar?.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        }
      },
    );

    test(
      '3. Importing a legacy v1 backup succeeds across file selection and Isar restore',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('susp001_v1_');
        Isar? isar;
        try {
          isar = _openTestIsar(tempDir, name: 'susp001_v1_db');
          final v1Json = jsonEncode(_buildLegacyV1BackupMap());
          final v1File = File(
            '${tempDir.path}${Platform.pathSeparator}legacy_v1_backup.json',
          )..writeAsStringSync(v1Json);

          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'legacy_v1_backup.json',
                path: v1File.path,
                size: v1File.lengthSync(),
                identifier:
                    'content://com.android.providers.downloads.documents/document/303',
              ),
            ]),
          );

          final service = BackupService(
            isar,
            backupsDirOverride: tempDir,
            isAndroidOverride: true,
          );

          final picked = await service.pickImportFile();
          expect(picked, isNotNull);
          final validated = await service.validateBackupPayload(
            picked!.content,
            strategy: null,
          );
          expect(validated.metadata.backupVersion, 1);

          await service.importFromBackupString(
            picked.content,
            strategy: ImportStrategy.replace,
          );

          expect(isar.semesterLocals.count(), 1);
          expect(
            isar.semesterLocals.where().findAll().single.name,
            'Legacy V1 Sem',
          );
          expect(
            isar.subjectLocals.where().findAll().single.name,
            'Legacy Algorithms',
          );
          expect(isar.weeklyScheduleRuleLocals.count(), 1);
          expect(isar.dailyScheduleOccurrenceLocals.count(), 1);
          expect(isar.attendanceRecordLocals.count(), 1);
          expect(
            isar.notificationItems.where().findAll().single.id,
            greaterThan(0),
          );
        } finally {
          isar?.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        }
      },
    );

    test(
      '4. Rejects malformed JSON from both .attendiq and .json selections without mutating DB',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('susp001_badj_');
        Isar? isar;
        try {
          isar = _openTestIsar(tempDir, name: 'susp001_badj_db');
          _seedDestinationDb(isar);

          for (final fileName in <String>['broken.attendiq', 'broken.json']) {
            final badFile = File(
              '${tempDir.path}${Platform.pathSeparator}$fileName',
            )..writeAsStringSync('{"metadata": {"backupVersion": 2');

            FilePicker.platform = _FakeFilePicker(
              (_) async => FilePickerResult(<PlatformFile>[
                PlatformFile(
                  name: fileName,
                  path: badFile.path,
                  size: badFile.lengthSync(),
                ),
              ]),
            );

            final service = BackupService(
              isar,
              backupsDirOverride: tempDir,
              isAndroidOverride: true,
            );

            await expectLater(
              service.pickImportFile(),
              throwsA(isA<FormatException>()),
            );
          }

          expect(isar.semesterLocals.count(), 1);
          expect(
            isar.semesterLocals.get(10)?.name,
            'Existing Seed Semester',
          );
        } finally {
          isar?.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        }
      },
    );

    test(
      '5. Rejects unsupported file extensions, binary/non-UTF-8 payloads, non-object JSON, and invalid backup schemas',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('susp001_unsup_');
        Isar? isar;
        try {
          isar = _openTestIsar(tempDir, name: 'susp001_unsup_db');
          _seedDestinationDb(isar);

          final service = BackupService(
            isar,
            backupsDirOverride: tempDir,
            isAndroidOverride: true,
          );

          // Unsupported extensions must be rejected after FileType.any pick.
          for (final badName in <String>[
            'notes.txt',
            'photo.png',
            'report.pdf',
            'backup.attendiq.txt',
            'attendiq',
            '.attendiq',
            'backup.',
          ]) {
            final file = File(
              '${tempDir.path}${Platform.pathSeparator}${badName == '.attendiq' ? 'dot_attendiq' : badName}',
            )..writeAsStringSync(jsonEncode(_buildV2BackupMap()));

            FilePicker.platform = _FakeFilePicker(
              (_) async => FilePickerResult(<PlatformFile>[
                PlatformFile(
                  name: badName,
                  path: file.path,
                  size: file.lengthSync(),
                ),
              ]),
            );

            await expectLater(
              service.pickImportFile(),
              throwsA(
                isA<FormatException>().having(
                  (e) => e.message,
                  'message',
                  contains('.attendiq or .json'),
                ),
              ),
            );
          }

          // Non-UTF-8 binary content disguised as .attendiq.
          final binaryFile = File(
            '${tempDir.path}${Platform.pathSeparator}image.attendiq',
          )..writeAsBytesSync(<int>[0x89, 0x50, 0x4E, 0x47, 0xFF, 0xFE]);
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'image.attendiq',
                path: binaryFile.path,
                size: binaryFile.lengthSync(),
              ),
            ]),
          );
          await expectLater(
            service.pickImportFile(),
            throwsA(isA<FormatException>()),
          );

          // Plain text or JSON array disguised as .json.
          for (final badContent in <String>[
            '<html>not a backup</html>',
            '[1, 2, 3]',
            '"just a string"',
            '   ',
          ]) {
            final fakeJson = File(
              '${tempDir.path}${Platform.pathSeparator}wrong_content.json',
            )..writeAsStringSync(badContent);
            FilePicker.platform = _FakeFilePicker(
              (_) async => FilePickerResult(<PlatformFile>[
                PlatformFile(
                  name: 'wrong_content.json',
                  path: fakeJson.path,
                  size: fakeJson.lengthSync(),
                ),
              ]),
            );
            await expectLater(
              service.pickImportFile(),
              throwsA(isA<FormatException>()),
            );
          }

          // Valid JSON object without AttendIQ backup schema is rejected by validation.
          final nonBackupJson = File(
            '${tempDir.path}${Platform.pathSeparator}unrelated.json',
          )..writeAsStringSync('{"hello":"world"}');
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'unrelated.json',
                path: nonBackupJson.path,
                size: nonBackupJson.lengthSync(),
              ),
            ]),
          );
          final pickedUnrelated = await service.pickImportFile();
          expect(pickedUnrelated, isNotNull);
          await expectLater(
            service.validateBackupPayload(pickedUnrelated!.content),
            throwsA(isA<FormatException>()),
          );

          // Oversized (>20 MB) file is rejected.
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'huge.attendiq',
                path: '${tempDir.path}${Platform.pathSeparator}huge.attendiq',
                size: maxBackupPayloadBytes + 1,
              ),
            ]),
          );
          await expectLater(
            service.pickImportFile(),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'message',
                contains('20 MB'),
              ),
            ),
          );

          expect(isar.semesterLocals.count(), 1);
          expect(
            isar.semesterLocals.get(10)?.name,
            'Existing Seed Semester',
          );
        } finally {
          isar?.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        }
      },
    );

    test(
      '6. Handles user cancellation cleanly across null result and empty files list',
      () async {
        final tempDir =
            await Directory.systemTemp.createTemp('susp001_cancel_');
        Isar? isar;
        try {
          isar = _openTestIsar(tempDir, name: 'susp001_cancel_db');
          final service = BackupService(
            isar,
            backupsDirOverride: tempDir,
            isAndroidOverride: true,
          );

          FilePicker.platform = _FakeFilePicker((_) async => null);
          expect(await service.pickImportFile(), isNull);

          FilePicker.platform = _FakeFilePicker(
            (_) async => const FilePickerResult(<PlatformFile>[]),
          );
          expect(await service.pickImportFile(), isNull);
        } finally {
          isar?.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        }
      },
    );

    test(
      '7. Handles unavailable file paths and never passes content:// URIs to dart:io File',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('susp001_path_');
        Isar? isar;
        try {
          isar = _openTestIsar(tempDir, name: 'susp001_path_db');
          final service = BackupService(
            isar,
            backupsDirOverride: tempDir,
            isAndroidOverride: true,
          );

          final unavailableFiles = <PlatformFile>[
            PlatformFile(name: 'missing_path.attendiq', path: null, size: 64),
            PlatformFile(name: 'empty_path.json', path: '   ', size: 64),
            PlatformFile(
              name: 'content_uri.attendiq',
              path:
                  'content://com.android.providers.downloads.documents/document/999',
              size: 64,
            ),
            PlatformFile(
              name: 'file_uri.json',
              path: 'file:///storage/emulated/0/Download/backup.json',
              size: 64,
            ),
            PlatformFile(
              name: 'nonexistent.attendiq',
              path:
                  '${tempDir.path}${Platform.pathSeparator}does_not_exist.attendiq',
              size: 64,
            ),
          ];

          for (final platformFile in unavailableFiles) {
            FilePicker.platform = _FakeFilePicker(
              (_) async => FilePickerResult(<PlatformFile>[platformFile]),
            );
            await expectLater(
              service.pickImportFile(),
              throwsA(isA<FileSystemException>()),
            );
          }

          // When path is a content:// URI but bytes are provided, bytes fallback
          // succeeds without touching dart:io File or leaking content://.
          final rawJson = jsonEncode(_buildV2BackupMap());
          final bytes = Uint8List.fromList(utf8.encode(rawJson));
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'drive_backup.attendiq',
                path: 'content://com.google.android.apps.docs.storage/file/77',
                size: bytes.length,
                bytes: bytes,
              ),
            ]),
          );
          final pickedFromBytes = await service.pickImportFile();
          expect(pickedFromBytes, isNotNull);
          expect(pickedFromBytes!.filePath, 'drive_backup.attendiq');
          expect(pickedFromBytes.filePath, isNot(startsWith('content://')));
          expect(pickedFromBytes.content, rawJson);
        } finally {
          isar?.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        }
      },
    );

    test(
      '8. Handles null file bytes safely when reading from cached file path or failing cleanly when unreadable',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('susp001_bytes_');
        Isar? isar;
        try {
          isar = _openTestIsar(tempDir, name: 'susp001_bytes_db');
          final rawJson = jsonEncode(_buildV2BackupMap());
          final cachedFile = File(
            '${tempDir.path}${Platform.pathSeparator}cached_android.attendiq',
          )..writeAsStringSync(rawJson);

          final service = BackupService(
            isar,
            backupsDirOverride: tempDir,
            isAndroidOverride: true,
          );

          // Standard Android file_picker result: withData=false -> bytes is null,
          // cached path is valid.
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'cached_android.attendiq',
                path: cachedFile.path,
                size: cachedFile.lengthSync(),
                bytes: null,
                identifier: 'content://media/external/file/555',
              ),
            ]),
          );
          final picked = await service.pickImportFile();
          expect(picked, isNotNull);
          expect(picked!.content, rawJson);

          // Both path and bytes unavailable -> explicit FileSystemException.
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'no_bytes_no_path.json',
                path: null,
                size: 128,
                bytes: null,
              ),
            ]),
          );
          await expectLater(
            service.pickImportFile(),
            throwsA(isA<FileSystemException>()),
          );
        } finally {
          isar?.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        }
      },
    );

    testWidgets(
      '9-10. BackupPage preserves Merge and Replace semantics, cancellation, and error rejection end-to-end',
      timeout: const Timeout(Duration(seconds: 30)),
      (tester) async {
        final tempDir = Directory.systemTemp.createTempSync('susp001_ui_');
        Isar? isar;
        try {
          isar = _openTestIsar(tempDir, name: 'susp001_ui_db');
          _seedDestinationDb(isar);

          final service = BackupService(
            isar,
            backupsDirOverride: tempDir,
            isAndroidOverride: true,
          );

          await _pumpBackupPage(tester, service);

          // A. Cancellation leaves UI idle and DB untouched.
          FilePicker.platform = _FakeFilePicker((_) async => null);
          await _tapImportButton(tester);
          expect(find.text('Select Restore Mode'), findsNothing);
          expect(
            find.textContaining('Failed to read selected file:'),
            findsNothing,
          );
          expect(isar.semesterLocals.count(), 1);

          // B. Unsupported extension displays error SnackBar and keeps DB intact.
          final txtFile = File(
            '${tempDir.path}${Platform.pathSeparator}notes.txt',
          )..writeAsStringSync(jsonEncode(_buildV2BackupMap()));
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'notes.txt',
                path: txtFile.path,
                size: txtFile.lengthSync(),
              ),
            ]),
          );
          await _tapImportButton(tester);
          expect(find.text('Select Restore Mode'), findsNothing);
          expect(
            find.textContaining('Failed to read selected file:'),
            findsWidgets,
          );
          expect(isar.semesterLocals.count(), 1);

          ScaffoldMessenger.of(
            tester.element(find.byType(BackupPage)),
          ).clearSnackBars();
          await tester.pumpAndSettle();

          // C. Malformed JSON displays error SnackBar and keeps DB intact.
          final badJsonFile = File(
            '${tempDir.path}${Platform.pathSeparator}bad.json',
          )..writeAsStringSync('{not valid json');
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'bad.json',
                path: badJsonFile.path,
                size: badJsonFile.lengthSync(),
              ),
            ]),
          );
          await _tapImportButton(tester);
          expect(find.text('Select Restore Mode'), findsNothing);
          expect(
            find.textContaining('Failed to read selected file:'),
            findsWidgets,
          );
          expect(isar.semesterLocals.count(), 1);

          ScaffoldMessenger.of(
            tester.element(find.byType(BackupPage)),
          ).clearSnackBars();
          await tester.pumpAndSettle();

          // D. Merge behavior via .attendiq file combines records & audits unmapped orphans.
          final mergeMap = _buildV2BackupMap(
            semesterId: 2,
            semesterServerId: 'sem_merge_2',
            semesterName: 'Merged Spring 2027',
            subjectId: 2,
            subjectServerId: 'sub_merge_2',
            subjectName: 'Compilers',
            subjectCode: 'CS401',
          );
          (mergeMap['subjects'] as List<Map<String, dynamic>>).add(
            <String, dynamic>{
              'id': 99,
              'serverId': 'orphan_sub_99',
              'semesterId': 999,
              'name': 'Orphan Subject',
              'code': 'ORP999',
              'credits': 3,
              'attendanceTarget': 75.0,
              'color': '#EF4444',
              'type': 'THEORY',
              'createdAt': DateTime.utc(2026, 9, 1).toIso8601String(),
              'updatedAt': DateTime.utc(2026, 9, 1).toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          );
          final mergeFile = File(
            '${tempDir.path}${Platform.pathSeparator}merge_backup.attendiq',
          )..writeAsStringSync(jsonEncode(mergeMap));
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'merge_backup.attendiq',
                path: mergeFile.path,
                size: mergeFile.lengthSync(),
              ),
            ]),
          );

          await _tapImportButton(tester);
          expect(find.text('Select Restore Mode'), findsOneWidget);
          await tester.tap(find.text('Merge Data'));
          await tester.pump();
          await _drainAsyncAndSettle(
            tester,
            waitUntilAbsent: find.byType(CircularProgressIndicator),
          );

          expect(find.text('Database restored successfully!'), findsOneWidget);
          expect(isar.semesterLocals.count(), 2);
          expect(isar.subjectLocals.count(), 2);
          expect(
            isar.subjectLocals.where().findAll().map((s) => s.code),
            containsAll(<String>['SEED100', 'CS401']),
          );
          expect(
            isar.migrationAuditRecordLocals
                .where()
                .kindEqualTo(BackupImporter.skippedMergeAuditKind)
                .count(),
            1,
          );

          ScaffoldMessenger.of(
            tester.element(find.byType(BackupPage)),
          ).clearSnackBars();
          await tester.pumpAndSettle();

          // E. Replace behavior via .json file overwrites existing data cleanly.
          final replaceMap = _buildV2BackupMap(
            semesterId: 3,
            semesterServerId: 'sem_replace_3',
            semesterName: 'Replaced Winter 2027',
            subjectId: 3,
            subjectServerId: 'sub_replace_3',
            subjectName: 'Operating Systems',
            subjectCode: 'CS501',
          );
          final replaceFile = File(
            '${tempDir.path}${Platform.pathSeparator}replace_backup.json',
          )..writeAsStringSync(jsonEncode(replaceMap));
          FilePicker.platform = _FakeFilePicker(
            (_) async => FilePickerResult(<PlatformFile>[
              PlatformFile(
                name: 'replace_backup.json',
                path: replaceFile.path,
                size: replaceFile.lengthSync(),
              ),
            ]),
          );

          await _tapImportButton(tester);
          expect(find.text('Select Restore Mode'), findsOneWidget);
          await tester.tap(find.text('Replace Existing Data'));
          await tester.pump();
          await _drainAsyncAndSettle(
            tester,
            waitUntilAbsent: find.byType(CircularProgressIndicator),
          );

          expect(find.text('Database restored successfully!'), findsOneWidget);
          expect(isar.semesterLocals.count(), 1);
          expect(
            isar.semesterLocals.where().findAll().single.name,
            'Replaced Winter 2027',
          );
          expect(isar.subjectLocals.count(), 1);
          expect(isar.subjectLocals.where().findAll().single.code, 'CS501');
        } finally {
          isar?.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        }
      },
    );
  });
}
