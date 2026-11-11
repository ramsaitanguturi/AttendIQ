import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/backup/backup_exporter.dart';
import 'package:attend_iq/core/backup/backup_importer.dart';
import 'package:attend_iq/core/backup/backup_models.dart';
import 'package:attend_iq/core/backup/backup_path_helper.dart';
import 'package:attend_iq/core/backup/backup_providers.dart';
import 'package:attend_iq/core/backup/backup_service.dart';
import 'package:attend_iq/core/backup/backup_validator.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/event_generator/data/models/event_local.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/features/academic_planner/data/models/academic_task_local.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/backup/presentation/pages/backup_page.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/settings/data/models/user_preferences_local.dart';
import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';
import 'package:attend_iq/features/settings/domain/repositories/settings_repository.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/models/academic_event_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/schedule_exception_local.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/utils/occurrence_identity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

Isar _openTestIsar(Directory dir, {required String name}) {
  return Isar.open(
    schemas: appIsarSchemas,
    directory: dir.path,
    name: name,
  );
}

void _failIfWriteTxEntered(Isar _) {
  throw StateError(
    'Isar write transaction must not be reached on invalid input',
  );
}

Map<String, dynamic> _validV2BackupMap({
  DateTime? timestamp,
}) {
  final ts = timestamp ?? DateTime.utc(2026, 9, 1, 8, 0);
  final slotKey = computeCanonicalSlotKey(
    date: DateTime.utc(2026, 9, 7),
    subjectId: 1,
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
        'defaultAttendanceTarget': 80.0,
        'classReminderOffset': 10,
        'enableNotifications': true,
        'enableAttendanceWarnings': true,
        'weeklyReportEnabled': true,
        'lastSyncTime': null,
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'semesters': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'sem_1',
        'name': 'Fall 2026',
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
        'id': 1,
        'serverId': 'sub_1',
        'semesterId': 1,
        'name': 'Algorithms',
        'code': 'CS301',
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
    'timetable': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'tpl_1',
        'subjectId': 1,
        'weekday': 1,
        'startTime': '09:00',
        'endTime': '10:00',
        'room': 'R101',
        'faculty': 'Dr. Ada',
        'notes': null,
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'events': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'ev_1',
        'subjectId': 1,
        'date': DateTime.utc(2026, 9, 7).toIso8601String(),
        'startTime': '09:00',
        'endTime': '10:00',
        'eventType': 'REGULAR_CLASS',
        'status': 'PRESENT',
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'weeklyRules': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'rule_1',
        'subjectId': 1,
        'legacyTemplateId': 1,
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
        'serverId': 'occ_1',
        'date': DateTime.utc(2026, 9, 7).toIso8601String(),
        'subjectId': 1,
        'ruleId': 1,
        'legacyEventId': 1,
        'slotKey': slotKey,
        'title': 'Algorithms',
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
        'serverId': 'att_1',
        'occurrenceId': 1,
        'legacyEventId': 1,
        'eventId': 1,
        'subjectId': 1,
        'status': 'PRESENT',
        'markedAt': DateTime.utc(2026, 9, 7, 9, 5).toIso8601String(),
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'scheduleExceptions': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'exc_1',
        'date': DateTime.utc(2026, 9, 14).toIso8601String(),
        'subjectId': null,
        'type': 'HOLIDAY',
        'title': 'Founders Day',
        'description': null,
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'academicEvents': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'ae_1',
        'title': 'Midterm Exam',
        'description': 'Chapters 1-4',
        'date': DateTime.utc(2026, 10, 1).toIso8601String(),
        'startTime': '10:00',
        'endTime': '12:00',
        'type': 'EXAM',
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'tasks': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'task_1',
        'subjectId': 1,
        'title': 'Homework 1',
        'description': null,
        'startDate': ts.toIso8601String(),
        'dueDate': DateTime.utc(2026, 9, 20).toIso8601String(),
        'priority': 'HIGH',
        'taskType': 'ASSIGNMENT',
        'status': 'PENDING',
        'reminder': 'DAYS_1',
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'notifications': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'title': 'Algorithms Reminder',
        'body': 'Starts at 09:00',
        'type': 'CLASS_REMINDER',
        'scheduledTime': DateTime.utc(2026, 9, 7, 8, 50).toIso8601String(),
        'relatedId': 'slot:$slotKey',
        'isRead': false,
      },
    ],
    'migrationAudits': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 1,
        'serverId': 'audit_1',
        'auditKey': 'recoveredAttendance|legacy_ev:1',
        'kind': 'recoveredAttendance',
        'attendanceRecordId': 1,
        'legacyEventId': 1,
        'sourceEventId': 1,
        'occurrenceId': 1,
        'sourceOccurrenceId': null,
        'subjectId': 1,
        'slotKey': slotKey,
        'candidateOccurrenceIds': null,
        'status': 'PRESENT',
        'eventDate': DateTime.utc(2026, 9, 7).toIso8601String(),
        'reason': 'Recovered cleanly',
        'diagnosticDetails': <String, dynamic>{'source': 'legacy'},
        'createdAt': ts.toIso8601String(),
        'updatedAt': ts.toIso8601String(),
        'isDirty': false,
        'isDeleted': false,
      },
    ],
    'reportsMetadata': <String, dynamic>{},
  };
}

void _seedAll13Collections(Isar isar) {
  final ts = DateTime.utc(2026, 8, 15, 10, 0);
  final slotKey = computeCanonicalSlotKey(
    date: DateTime.utc(2026, 8, 17),
    subjectId: 10,
    ruleId: 10,
    startTime: '14:00',
    endTime: '15:00',
    type: 'REGULAR_CLASS',
  );

  isar.write((db) {
    db.userPreferencesLocals.put(
      UserPreferencesLocal()
        ..id = 10
        ..serverId = 'seed_pref'
        ..themeMode = 'light'
        ..defaultAttendanceTarget = 85.0
        ..classReminderOffset = 15
        ..enableNotifications = true
        ..enableAttendanceWarnings = true
        ..weeklyReportEnabled = false
        ..updatedAt = ts,
    );
    db.semesterLocals.put(
      SemesterLocal()
        ..id = 10
        ..serverId = 'seed_sem'
        ..name = 'Seed Sentinel Semester'
        ..startDate = DateTime.utc(2026, 8, 1)
        ..endDate = DateTime.utc(2026, 12, 31)
        ..requiredAttendanceRate = 85.0
        ..isActive = true
        ..status = SemesterLocal.statusActive
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.subjectLocals.put(
      SubjectLocal()
        ..id = 10
        ..serverId = 'seed_sub'
        ..semesterId = 10
        ..name = 'Sentinel Subject'
        ..code = 'SENT101'
        ..credits = 3
        ..attendanceTarget = 85.0
        ..color = '#10B981'
        ..type = 'THEORY'
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.timetableTemplateLocals.put(
      TimetableTemplateLocal()
        ..id = 10
        ..serverId = 'seed_tpl'
        ..subjectId = 10
        ..weekday = 1
        ..startTime = '14:00'
        ..endTime = '15:00'
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.eventLocals.put(
      EventLocal()
        ..id = 10
        ..serverId = 'seed_ev'
        ..subjectId = 10
        ..date = DateTime.utc(2026, 8, 17)
        ..startTime = '14:00'
        ..endTime = '15:00'
        ..eventType = 'REGULAR_CLASS'
        ..status = 'PRESENT'
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.weeklyScheduleRuleLocals.put(
      WeeklyScheduleRuleLocal()
        ..id = 10
        ..serverId = 'seed_rule'
        ..subjectId = 10
        ..legacyTemplateId = 10
        ..dayOfWeek = 1
        ..startTime = '14:00'
        ..endTime = '15:00'
        ..type = 'THEORY'
        ..isActive = true
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.dailyScheduleOccurrenceLocals.put(
      DailyScheduleOccurrenceLocal()
        ..id = 10
        ..serverId = 'seed_occ'
        ..date = DateTime.utc(2026, 8, 17)
        ..subjectId = 10
        ..ruleId = 10
        ..legacyEventId = 10
        ..slotKey = slotKey
        ..title = 'Sentinel Subject'
        ..startTime = '14:00'
        ..endTime = '15:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'PRESENT'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.attendanceRecordLocals.put(
      AttendanceRecordLocal()
        ..id = 10
        ..serverId = 'seed_att'
        ..occurrenceId = 10
        ..legacyEventId = 10
        ..eventId = 10
        ..subjectId = 10
        ..status = 'PRESENT'
        ..markedAt = ts
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.scheduleExceptionLocals.put(
      ScheduleExceptionLocal()
        ..id = 10
        ..serverId = 'seed_exc'
        ..date = DateTime.utc(2026, 9, 1)
        ..type = 'HOLIDAY'
        ..title = 'Sentinel Holiday'
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.academicEventLocals.put(
      AcademicEventLocal()
        ..id = 10
        ..serverId = 'seed_ae'
        ..title = 'Sentinel Event'
        ..date = DateTime.utc(2026, 9, 10)
        ..type = 'EVENT'
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.academicTaskLocals.put(
      AcademicTaskLocal()
        ..id = 10
        ..serverId = 'seed_task'
        ..subjectId = 10
        ..title = 'Sentinel Task'
        ..startDate = ts
        ..dueDate = DateTime.utc(2026, 9, 15)
        ..priority = 'MEDIUM'
        ..taskType = 'ASSIGNMENT'
        ..status = 'PENDING'
        ..reminder = 'NONE'
        ..createdAt = ts
        ..updatedAt = ts,
    );
    db.notificationItems.put(
      NotificationItem()
        ..id = 10
        ..androidNotificationId = 100000010
        ..title = 'Sentinel Notification'
        ..body = 'Preserved'
        ..type = 'WEEKLY_REPORT'
        ..scheduledTime = ts
        ..isRead = false,
    );
    db.migrationAuditRecordLocals.put(
      MigrationAuditRecordLocal()
        ..id = 10
        ..serverId = 'seed_audit'
        ..auditKey = 'recoveredAttendance|legacy_ev:10'
        ..kind = 'recoveredAttendance'
        ..attendanceRecordId = 10
        ..legacyEventId = 10
        ..occurrenceId = 10
        ..subjectId = 10
        ..reason = 'Sentinel Audit'
        ..createdAt = ts
        ..updatedAt = ts,
    );
  });
}

void _expectSeedSentinelIntact(Isar isar) {
  expect(isar.userPreferencesLocals.count(), equals(1));
  expect(isar.userPreferencesLocals.get(10)?.serverId, equals('seed_pref'));
  expect(isar.semesterLocals.count(), equals(1));
  expect(
    isar.semesterLocals.get(10)?.name,
    equals('Seed Sentinel Semester'),
  );
  expect(isar.subjectLocals.count(), equals(1));
  expect(isar.subjectLocals.get(10)?.code, equals('SENT101'));
  expect(isar.timetableTemplateLocals.count(), equals(1));
  expect(isar.eventLocals.count(), equals(1));
  expect(isar.weeklyScheduleRuleLocals.count(), equals(1));
  expect(isar.dailyScheduleOccurrenceLocals.count(), equals(1));
  expect(isar.attendanceRecordLocals.count(), equals(1));
  expect(isar.scheduleExceptionLocals.count(), equals(1));
  expect(isar.academicEventLocals.count(), equals(1));
  expect(isar.academicTaskLocals.count(), equals(1));
  expect(isar.notificationItems.count(), equals(1));
  expect(
    isar.notificationItems.get(10)?.title,
    equals('Sentinel Notification'),
  );
  expect(isar.migrationAuditRecordLocals.count(), equals(1));
}

Future<void> _expectRejectedBeforeTx(
  Isar isar,
  String rawJson, {
  Matcher? messageMatcher,
}) async {
  final importer = BackupImporter(isar);
  for (final strategy in ImportStrategy.values) {
    await expectLater(
      importer.importData(
        rawJson,
        strategy: strategy,
        onBeforeCommit: _failIfWriteTxEntered,
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          messageMatcher ?? isNotEmpty,
        ),
      ),
    );
    _expectSeedSentinelIntact(isar);
  }
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

class _StubBackupService extends BackupService {
  final List<BackupFileItem> _files;

  _StubBackupService(
    super.isar, {
    super.pickFileOverride,
    List<BackupFileItem> files = const <BackupFileItem>[],
  }) : _files = files;

  @override
  Future<List<BackupFileItem>> listBackups() async => _files;
}

void main() {
  setUpAll(() async {
    final nativeLibPath = await _resolveIsarNativeLibraryPath();
    await Isar.initialize(nativeLibPath);
  });

  group('BUG-007: Backup JSON Validation & DB Preservation', () {
    test(
      '1-4. Rejects empty, non-object, {}, unrelated JSON, missing metadata/core keys, wrong metadata types, and invalid versions before DB transaction',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug007_envelope_');
        Isar? isar;
        try {
          isar = _openTestIsar(dir, name: 'bug007_env');
          _seedAll13Collections(isar);

          final invalidPayloads = <String>[
            '',
            '   \n\t  ',
            'invalid-json{{',
            '{"metadata": {"backupVersion": 2',
            'null',
            '[]',
            '"hello"',
            '123',
            'true',
            '{}',
            '{"hello": "world"}',
            '{"metadata": null}',
            '{"metadata": []}',
            '{"metadata": "bad"}',
            '{"metadata": {}}',
            '{"metadata": {"backupVersion": null}}',
            '{"metadata": {"backupVersion": "2"}}',
            '{"metadata": {"backupVersion": 2.5}}',
            '{"metadata": {"backupVersion": true}}',
            '{"metadata": {"backupVersion": 0}}',
            '{"metadata": {"backupVersion": -1}}',
            '{"metadata": {"backupVersion": 3}}',
            '{"metadata": {"backupVersion": 99}}',
            '{"metadata": {"backupVersion": 2, "appVersion": 123}}',
            '{"metadata": {"backupVersion": 2, "appVersion": ""}}',
            '{"metadata": {"backupVersion": 2, "createdAt": 1700000000}}',
            '{"metadata": {"backupVersion": 2, "createdAt": "not-a-date"}}',
            '{"metadata": {"backupVersion": 2, "devicePlatform": 42}}',
            '{"metadata": {"backupVersion": 2, "devicePlatform": "   "}}',
            '{"metadata": {"backupVersion": 2}}',
            // Missing each required v1 core key one by one:
            ...requiredCoreBackupKeys.map((missingKey) {
              final map = _validV2BackupMap()..remove(missingKey);
              return jsonEncode(map);
            }),
            // Wrong type or explicit null for core & optional collection keys:
            ...allBackupCollectionKeys.expand((key) {
              final nullMap = _validV2BackupMap()..[key] = null;
              final objMap = _validV2BackupMap()..[key] = <String, dynamic>{};
              return <String>[jsonEncode(nullMap), jsonEncode(objMap)];
            }),
            // Wrong type for reportsMetadata:
            jsonEncode(_validV2BackupMap()..['reportsMetadata'] = <dynamic>[]),
            jsonEncode(_validV2BackupMap()..['reportsMetadata'] = null),
          ];

          for (final payload in invalidPayloads) {
            await _expectRejectedBeforeTx(isar, payload);
          }
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '5. Rejects non-object list items and wrong row-field types across all 13 collections with path context and zero TypeError escapes',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug007_types_');
        Isar? isar;
        try {
          isar = _openTestIsar(dir, name: 'bug007_types');
          _seedAll13Collections(isar);

          // Non-object list items across all 13 collections
          for (final key in allBackupCollectionKeys) {
            for (final badItem in <dynamic>[
              123,
              null,
              'str',
              true,
              <dynamic>[],
            ]) {
              final map = _validV2BackupMap()..[key] = <dynamic>[badItem];
              await _expectRejectedBeforeTx(
                isar,
                jsonEncode(map),
                messageMatcher: contains('$key[0]'),
              );
            }
          }

          // Wrong field types inside row objects across all 13 collections
          final rowTypeMutations =
              <({String col, String field, dynamic badVal})>[
            (col: 'userPreferences', field: 'id', badVal: '1'),
            (col: 'userPreferences', field: 'themeMode', badVal: 123),
            (
              col: 'userPreferences',
              field: 'defaultAttendanceTarget',
              badVal: '80'
            ),
            (col: 'userPreferences', field: 'classReminderOffset', badVal: 5.5),
            (
              col: 'userPreferences',
              field: 'enableNotifications',
              badVal: 'true'
            ),
            (col: 'userPreferences', field: 'autoBackupDay', badVal: '7'),
            (col: 'userPreferences', field: 'autoBackupHour', badVal: false),
            (col: 'semesters', field: 'id', badVal: '1'),
            (col: 'semesters', field: 'name', badVal: 42),
            (col: 'semesters', field: 'requiredAttendanceRate', badVal: '75'),
            (col: 'semesters', field: 'isActive', badVal: 1),
            (col: 'semesters', field: 'isDeleted', badVal: 'false'),
            (col: 'subjects', field: 'semesterId', badVal: '1'),
            (col: 'subjects', field: 'name', badVal: false),
            (col: 'subjects', field: 'code', badVal: 101),
            (col: 'subjects', field: 'credits', badVal: 4.5),
            (col: 'subjects', field: 'attendanceTarget', badVal: '75'),
            (col: 'timetable', field: 'subjectId', badVal: '1'),
            (col: 'timetable', field: 'weekday', badVal: '1'),
            (col: 'timetable', field: 'startTime', badVal: 900),
            (col: 'events', field: 'subjectId', badVal: 1.0),
            (col: 'events', field: 'date', badVal: 1700000000),
            (col: 'weeklyRules', field: 'dayOfWeek', badVal: 1.2),
            (col: 'weeklyRules', field: 'isActive', badVal: 'yes'),
            (col: 'occurrences', field: 'subjectId', badVal: '1'),
            (col: 'occurrences', field: 'ruleId', badVal: '1'),
            (col: 'occurrences', field: 'title', badVal: <String>[]),
            (col: 'attendance', field: 'occurrenceId', badVal: '1'),
            (col: 'attendance', field: 'eventId', badVal: true),
            (col: 'attendance', field: 'subjectId', badVal: '1'),
            (col: 'attendance', field: 'markedAt', badVal: 123456),
            (col: 'scheduleExceptions', field: 'date', badVal: false),
            (col: 'scheduleExceptions', field: 'subjectId', badVal: '1'),
            (col: 'academicEvents', field: 'title', badVal: 99),
            (col: 'academicEvents', field: 'startTime', badVal: 1000),
            (col: 'tasks', field: 'subjectId', badVal: '1'),
            (col: 'tasks', field: 'dueDate', badVal: 999999),
            (col: 'notifications', field: 'id', badVal: '1'),
            (
              col: 'notifications',
              field: 'androidNotificationId',
              badVal: '100'
            ),
            (col: 'notifications', field: 'isRead', badVal: 0),
            (col: 'migrationAudits', field: 'auditKey', badVal: 123),
            (col: 'migrationAudits', field: 'attendanceRecordId', badVal: '1'),
            (
              col: 'migrationAudits',
              field: 'candidateOccurrenceIds',
              badVal: true
            ),
            (
              col: 'migrationAudits',
              field: 'candidateOccurrenceIds',
              badVal: <dynamic>['bad']
            ),
            (
              col: 'migrationAudits',
              field: 'diagnosticDetails',
              badVal: <dynamic>[1, 2]
            ),
          ];

          for (final m in rowTypeMutations) {
            final map = _validV2BackupMap();
            final list = map[m.col] as List<Map<String, dynamic>>;
            list[0][m.field] = m.badVal;
            await _expectRejectedBeforeTx(
              isar,
              jsonEncode(map),
              messageMatcher: contains('${m.col}[0].${m.field}'),
            );
          }
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '6-9. Rejects malformed dates, invalid HH:mm/reversed times, out-of-range numbers/weekdays, and non-production enum/status strings while keeping valid case-insensitive & legacy EventLocal enums',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug007_domain_');
        Isar? isar;
        try {
          isar = _openTestIsar(dir, name: 'bug007_domain');
          _seedAll13Collections(isar);

          // 6. Malformed non-null dates (must never fall back to DateTime.now())
          final badDates = <({String col, String field, dynamic val})>[
            (col: 'userPreferences', field: 'lastSyncTime', val: 'not-a-date'),
            (col: 'userPreferences', field: 'updatedAt', val: '2026-02-30'),
            (col: 'semesters', field: 'startDate', val: 'bad-date'),
            (col: 'semesters', field: 'endDate', val: '2026-13-01'),
            (col: 'semesters', field: 'createdAt', val: ''),
            (col: 'subjects', field: 'updatedAt', val: 'yesterday'),
            (col: 'events', field: 'date', val: '2026-04-31T00:00:00Z'),
            (col: 'occurrences', field: 'date', val: 'invalid'),
            (col: 'attendance', field: 'markedAt', val: '2026-99-99'),
            (col: 'scheduleExceptions', field: 'date', val: 'nope'),
            (col: 'academicEvents', field: 'date', val: ''),
            (col: 'tasks', field: 'startDate', val: 'bad'),
            (col: 'tasks', field: 'dueDate', val: 'bad'),
            (col: 'notifications', field: 'scheduledTime', val: 'bad'),
            (col: 'migrationAudits', field: 'eventDate', val: 'bad'),
          ];
          for (final d in badDates) {
            final map = _validV2BackupMap();
            (map[d.col] as List<Map<String, dynamic>>)[0][d.field] = d.val;
            await _expectRejectedBeforeTx(isar, jsonEncode(map));
          }

          // 7. Invalid HH:mm strings and reversed/equal intervals
          for (final col in <String>[
            'timetable',
            'events',
            'weeklyRules',
            'occurrences',
            'academicEvents',
          ]) {
            for (final badTime in <String>[
              '9:00',
              '25:00',
              '12:60',
              'abc',
              '',
            ]) {
              final map = _validV2BackupMap();
              (map[col] as List<Map<String, dynamic>>)[0]['startTime'] =
                  badTime;
              await _expectRejectedBeforeTx(isar, jsonEncode(map));
            }
            // Equal interval
            final eqMap = _validV2BackupMap();
            final eqRow = (eqMap[col] as List<Map<String, dynamic>>)[0];
            eqRow['startTime'] = '10:00';
            eqRow['endTime'] = '10:00';
            await _expectRejectedBeforeTx(isar, jsonEncode(eqMap));
            // Reversed interval
            final revMap = _validV2BackupMap();
            final revRow = (revMap[col] as List<Map<String, dynamic>>)[0];
            revRow['startTime'] = '11:00';
            revRow['endTime'] = '10:00';
            await _expectRejectedBeforeTx(isar, jsonEncode(revMap));
          }

          // 8. Invalid numeric ranges, weekday values, date ordering, empty strings, invalid IDs
          final domainInvalidMutations = <void Function(Map<String, dynamic>)>[
            (m) => m['userPreferences'][0]['defaultAttendanceTarget'] = -1,
            (m) => m['userPreferences'][0]['defaultAttendanceTarget'] = 100.1,
            (m) => m['userPreferences'][0]['classReminderOffset'] = -5,
            (m) => m['userPreferences'][0]['autoBackupDay'] = 0,
            (m) => m['userPreferences'][0]['autoBackupDay'] = 8,
            (m) => m['userPreferences'][0]['autoBackupHour'] = -1,
            (m) => m['userPreferences'][0]['autoBackupHour'] = 24,
            (m) => m['semesters'][0]['name'] = '   ',
            (m) => m['semesters'][0]['requiredAttendanceRate'] = -0.1,
            (m) => m['semesters'][0]['requiredAttendanceRate'] = 101,
            (m) {
              m['semesters'][0]['startDate'] = '2026-12-20T00:00:00.000Z';
              m['semesters'][0]['endDate'] = '2026-12-20T00:00:00.000Z';
            },
            (m) {
              m['semesters'][0]['startDate'] = '2026-12-21T00:00:00.000Z';
              m['semesters'][0]['endDate'] = '2026-12-20T00:00:00.000Z';
            },
            (m) => m['subjects'][0]['id'] = -1,
            (m) => m['subjects'][0]['semesterId'] = 0,
            (m) => m['subjects'][0]['name'] = '',
            (m) => m['subjects'][0]['code'] = '  ',
            (m) => m['subjects'][0]['credits'] = -1,
            (m) => m['subjects'][0]['attendanceTarget'] = 120,
            (m) => m['timetable'][0]['weekday'] = 0,
            (m) => m['timetable'][0]['weekday'] = 8,
            (m) => m['weeklyRules'][0]['dayOfWeek'] = 0,
            (m) => m['weeklyRules'][0]['dayOfWeek'] = 8,
            (m) => m['occurrences'][0]['subjectId'] =
                null, // REGULAR_CLASS requires subjectId
            (m) => m['occurrences'][0]['subjectId'] = 0,
            (m) => m['occurrences'][0]['title'] = ' ',
            (m) => m['attendance'][0]['subjectId'] = 0,
            (m) => m['attendance'][0]['eventId'] = -1,
            (m) {
              m['scheduleExceptions'][0]['type'] = 'CANCELLED_CLASS';
              m['scheduleExceptions'][0]['subjectId'] = null;
            },
            (m) => m['scheduleExceptions'][0]['title'] = '',
            (m) => m['academicEvents'][0]['title'] = '',
            (m) => m['tasks'][0]['title'] = '',
            (m) {
              m['tasks'][0]['startDate'] = '2026-09-25T00:00:00.000Z';
              m['tasks'][0]['dueDate'] = '2026-09-24T00:00:00.000Z';
            },
            (m) => m['notifications'][0]['title'] = '',
            (m) => m['migrationAudits'][0]['auditKey'] = ' ',
          ];
          for (final mutate in domainInvalidMutations) {
            final map = _validV2BackupMap();
            mutate(map);
            await _expectRejectedBeforeTx(isar, jsonEncode(map));
          }

          // 9. Invalid enum/status values (including non-production GENERAL/LAB_RECORD)
          final badEnums = <({String col, String field, String val})>[
            (col: 'userPreferences', field: 'themeMode', val: 'neon'),
            (col: 'semesters', field: 'status', val: 'deleted'),
            (col: 'subjects', field: 'type', val: 'WORKSHOP'),
            (col: 'events', field: 'eventType', val: 'SEMINAR'),
            (col: 'events', field: 'status', val: 'BOGUS'),
            (col: 'weeklyRules', field: 'type', val: 'WORKSHOP'),
            (col: 'occurrences', field: 'type', val: 'SEMINAR'),
            (col: 'occurrences', field: 'status', val: 'DONE'),
            (col: 'occurrences', field: 'createdFrom', val: 'SYNC'),
            (col: 'attendance', field: 'status', val: 'BOGUS'),
            (col: 'scheduleExceptions', field: 'type', val: 'SICK_DAY'),
            (col: 'academicEvents', field: 'type', val: 'FESTIVAL'),
            (col: 'tasks', field: 'taskType', val: 'LAB_RECORD'),
            (col: 'tasks', field: 'priority', val: 'URGENT'),
            (col: 'tasks', field: 'status', val: 'ARCHIVED'),
            (col: 'tasks', field: 'reminder', val: 'ONE_DAY'),
            (col: 'notifications', field: 'type', val: 'GENERAL'),
            (col: 'migrationAudits', field: 'kind', val: 'unknownAuditKind'),
          ];
          for (final e in badEnums) {
            final map = _validV2BackupMap();
            (map[e.col] as List<Map<String, dynamic>>)[0][e.field] = e.val;
            await _expectRejectedBeforeTx(isar, jsonEncode(map));
          }

          // Valid case-insensitive production enums & documented EventLocal legacy types pass
          final validAltMap = _validV2BackupMap();
          validAltMap['subjects'][0]['type'] = 'lab';
          validAltMap['events'][0]['eventType'] = 'TUTORIAL';
          validAltMap['events'][0]['status'] = 'UNMARKED';
          validAltMap['unknownTopLevelExtension'] = <String, dynamic>{
            'futureKey': true,
          };
          expect(
            () => BackupImporter(isar!).parseAndValidateJson(
              jsonEncode(validAltMap),
              strategy: ImportStrategy.replace,
            ),
            returnsNormally,
          );
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '10-11. Accepts valid legacy v1, early-v2 (without migrationAudits/reportsMetadata/unknown keys), and full current v2 exports',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug007_compat_');
        Isar? isar;
        try {
          isar = _openTestIsar(dir, name: 'bug007_compat');
          final importer = BackupImporter(isar);

          // Valid v1 backup omitting v2 collections, status/isActive, occurrenceId, timestamps
          final v1Payload = jsonEncode(<String, dynamic>{
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
                'serverId': 'v1_sem',
                'name': 'V1 Sem',
                'startDate': '2026-01-10T00:00:00.000Z',
                'endDate': '2026-05-20T00:00:00.000Z',
                'requiredAttendanceRate': 75.0,
              },
            ],
            'subjects': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 1,
                'serverId': 'v1_sub',
                'semesterId': 1,
                'name': 'OS',
                'code': 'CS302',
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
                'id': 0, // legacy pre-BUG-009 zero PK
                'title': 'Legacy Reminder',
                'body': 'Body',
                'type': 'CLASS_REMINDER',
                'scheduledTime': '2026-02-03T09:50:00.000Z',
                'relatedId': '1',
                'isRead': false,
              },
            ],
          });

          await importer.importData(
            v1Payload,
            strategy: ImportStrategy.replace,
          );
          expect(isar.semesterLocals.count(), equals(1));
          expect(isar.weeklyScheduleRuleLocals.count(), equals(1));
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(1));
          expect(isar.attendanceRecordLocals.count(), equals(1));
          expect(isar.notificationItems.count(), equals(1));
          expect(
            isar.notificationItems.where().findAll().single.id,
            greaterThan(0),
          );

          // Early v2 backup omitting migrationAudits & reportsMetadata + unknown forward key
          final earlyV2 = _validV2BackupMap()
            ..remove('migrationAudits')
            ..remove('reportsMetadata')
            ..['futureSection'] = <String, dynamic>{'v': 3};
          await importer.importData(
            jsonEncode(earlyV2),
            strategy: ImportStrategy.replace,
          );
          expect(isar.academicTaskLocals.count(), equals(1));

          // Full current v2 export roundtrip
          final exported = await BackupExporter(isar).exportToJsonString();
          await importer.importData(exported, strategy: ImportStrategy.replace);
          expect(isar.semesterLocals.count(), equals(1));
          expect(isar.subjectLocals.count(), equals(1));
          expect(isar.weeklyScheduleRuleLocals.count(), equals(1));
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(1));
          expect(isar.attendanceRecordLocals.count(), equals(1));
          expect(isar.scheduleExceptionLocals.count(), equals(1));
          expect(isar.academicEventLocals.count(), equals(1));
          expect(isar.academicTaskLocals.count(), equals(1));
          expect(isar.notificationItems.count(), equals(1));
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '12-15. Strategy-aware FK/duplicate validation: Merge preserves BUG-006 orphan skip+audit, while Replace rejects dangling FKs and duplicate positive IDs pre-transaction with DB intact',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug007_strategy_');
        Isar? isar;
        try {
          isar = _openTestIsar(dir, name: 'bug007_strategy');
          _seedAll13Collections(isar);
          final importer = BackupImporter(isar);

          // 12. Merge allows valid JSON with unmapped parent references (BUG-006 skip + audit)
          final mergeOrphanMap = _validV2BackupMap();
          mergeOrphanMap['userPreferences'] = <Map<String, dynamic>>[];
          mergeOrphanMap['semesters'] = <Map<String, dynamic>>[];
          mergeOrphanMap['subjects'] = <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 50,
              'serverId': 'orphan_sub_50',
              'semesterId': 999,
              'name': 'Orphan Sub',
              'code': 'ORP50',
              'credits': 3,
              'attendanceTarget': 75.0,
              'color': '#2563EB',
              'type': 'THEORY',
              'createdAt': DateTime.utc(2026, 9, 1).toIso8601String(),
              'updatedAt': DateTime.utc(2026, 9, 1).toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ];
          mergeOrphanMap['timetable'] = <Map<String, dynamic>>[];
          mergeOrphanMap['events'] = <Map<String, dynamic>>[];
          mergeOrphanMap['weeklyRules'] = <Map<String, dynamic>>[];
          mergeOrphanMap['occurrences'] = <Map<String, dynamic>>[];
          mergeOrphanMap['attendance'] = <Map<String, dynamic>>[];
          mergeOrphanMap['scheduleExceptions'] = <Map<String, dynamic>>[];
          mergeOrphanMap['academicEvents'] = <Map<String, dynamic>>[];
          mergeOrphanMap['tasks'] = <Map<String, dynamic>>[];
          mergeOrphanMap['notifications'] = <Map<String, dynamic>>[];
          mergeOrphanMap['migrationAudits'] = <Map<String, dynamic>>[];

          await importer.importData(
            jsonEncode(mergeOrphanMap),
            strategy: ImportStrategy.merge,
          );
          expect(isar.subjectLocals.count(), equals(1)); // seed untouched
          expect(
            isar.migrationAuditRecordLocals
                .where()
                .kindEqualTo(BackupImporter.skippedMergeAuditKind)
                .count(),
            equals(1),
          );

          // Re-seed cleanly before testing Replace pre-transaction rejections
          isar.write(
            (db) => db.migrationAuditRecordLocals.delete(
              db.migrationAuditRecordLocals
                  .where()
                  .kindEqualTo(BackupImporter.skippedMergeAuditKind)
                  .findFirst()!
                  .id,
            ),
          );
          _expectSeedSentinelIntact(isar);

          // 13. Replace rejects dangling required & optional FKs before transaction
          final replaceFkFailures = <void Function(Map<String, dynamic>)>[
            (m) => m['subjects'][0]['semesterId'] = 999,
            (m) => m['timetable'][0]['subjectId'] = 999,
            (m) => m['events'][0]['subjectId'] = 999,
            (m) => m['weeklyRules'][0]['subjectId'] = 999,
            (m) => m['weeklyRules'][0]['legacyTemplateId'] = 999,
            (m) => m['occurrences'][0]['subjectId'] = 999,
            (m) => m['occurrences'][0]['ruleId'] = 999,
            (m) => m['occurrences'][0]['legacyEventId'] = 999,
            (m) => m['attendance'][0]['subjectId'] = 999,
            (m) => m['attendance'][0]['occurrenceId'] = 999,
            (m) {
              m['scheduleExceptions'][0]['type'] = 'CANCELLED_CLASS';
              m['scheduleExceptions'][0]['subjectId'] = 999;
            },
            (m) => m['scheduleExceptions'][0]['subjectId'] = 999,
            (m) => m['tasks'][0]['subjectId'] = 999,
            (m) => m['notifications'][0]['relatedId'] = 'sub:999',
            (m) => m['notifications'][0]['relatedId'] = 'task:999',
            (m) => m['notifications'][0]['relatedId'] = 'occ:999',
            (m) => m['notifications'][0]['relatedId'] = 'ae_1d:999',
            (m) => m['notifications'][0]['relatedId'] = 'ae_30m:999',
            (m) => m['notifications'][0]['relatedId'] =
                'slot:REGULAR|rule:999|sub:1|20260907|09:00-10:00',
            (m) {
              m['notifications'][0]['type'] = 'LOW_ATTENDANCE_ALERT';
              m['notifications'][0]['relatedId'] = '999';
            },
          ];
          for (final mutate in replaceFkFailures) {
            final map = _validV2BackupMap();
            mutate(map);
            await expectLater(
              importer.importData(
                jsonEncode(map),
                strategy: ImportStrategy.replace,
                onBeforeCommit: _failIfWriteTxEntered,
              ),
              throwsA(isA<FormatException>()),
            );
            _expectSeedSentinelIntact(isar);
          }

          // 14. Replace rejects duplicate positive IDs within the same collection
          for (final key in allBackupCollectionKeys) {
            final map = _validV2BackupMap();
            final list = map[key] as List<Map<String, dynamic>>;
            final dup = Map<String, dynamic>.from(list[0]);
            if (dup['serverId'] != null) {
              dup['serverId'] = '${dup['serverId']}_dup';
            }
            list.add(dup);
            await expectLater(
              importer.importData(
                jsonEncode(map),
                strategy: ImportStrategy.replace,
                onBeforeCommit: _failIfWriteTxEntered,
              ),
              throwsA(
                isA<FormatException>().having(
                  (e) => e.message,
                  'message',
                  contains('Duplicate positive ID'),
                ),
              ),
            );
            _expectSeedSentinelIntact(isar);
          }
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '16-17. BackupService rejects empty, non-UTF-8, missing, and oversized (>20 MB) files across importFromFile, validateBackupPayload, and pickImportFile',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug007_files_');
        Isar? isar;
        try {
          isar = _openTestIsar(dir, name: 'bug007_files');
          _seedAll13Collections(isar);

          final emptyFile = File('${dir.path}/empty.attendiq')
            ..writeAsStringSync('');
          final badUtf8File = File('${dir.path}/binary.attendiq')
            ..writeAsBytesSync(<int>[0xFF, 0xFE, 0xFD, 0x80]);
          final oversizedFile = File('${dir.path}/huge.attendiq')
            ..writeAsBytesSync(
              List<int>.filled(maxBackupPayloadBytes + 1, 0x20),
            );
          final missingPath = '${dir.path}/does_not_exist.attendiq';

          final service = BackupService(isar);

          await expectLater(
            service.importFromFile(emptyFile.path),
            throwsA(isA<FormatException>()),
          );
          await expectLater(
            service.importFromFile(badUtf8File.path),
            throwsA(isA<FormatException>()),
          );
          await expectLater(
            service.importFromFile(oversizedFile.path),
            throwsA(isA<FormatException>()),
          );
          await expectLater(
            service.importFromFile(missingPath),
            throwsA(isA<FileSystemException>()),
          );
          await expectLater(
            service.validateBackupPayload(' ' * (maxBackupPayloadBytes + 1)),
            throwsA(isA<FormatException>()),
          );

          // pickImportFile propagates empty, non-UTF-8, and oversized files instead of returning null
          final emptyPickService = BackupService(
            isar,
            pickFileOverride: () async => PlatformFile(
              name: 'empty.attendiq',
              size: 0,
              path: emptyFile.path,
            ),
          );
          await expectLater(
            emptyPickService.pickImportFile(),
            throwsA(isA<FormatException>()),
          );

          final badUtf8PickService = BackupService(
            isar,
            pickFileOverride: () async => PlatformFile(
              name: 'binary.attendiq',
              size: 4,
              path: badUtf8File.path,
            ),
          );
          await expectLater(
            badUtf8PickService.pickImportFile(),
            throwsA(isA<FormatException>()),
          );

          final oversizedPickService = BackupService(
            isar,
            pickFileOverride: () async => PlatformFile(
              name: 'huge.attendiq',
              size: maxBackupPayloadBytes + 1,
              path: oversizedFile.path,
            ),
          );
          await expectLater(
            oversizedPickService.pickImportFile(),
            throwsA(isA<FormatException>()),
          );

          // User cancellation still returns null cleanly
          final cancelPickService = BackupService(
            isar,
            pickFileOverride: () async => null,
          );
          expect(await cancelPickService.pickImportFile(), isNull);

          _expectSeedSentinelIntact(isar);
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '18. Direct BackupData.fromJson, BackupMetadata.fromJson, SemesterLocal.fromJson, and MigrationAuditRecordLocal.fromJson throw FormatException with path context (never TypeError)',
      () async {
        expect(
          () => BackupData.fromJson(<String, dynamic>{}),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => BackupData.fromJson(<String, dynamic>{
            'metadata': <String, dynamic>{'backupVersion': 2},
            'userPreferences': <dynamic>[],
            'semesters': <dynamic>[123],
            'subjects': <dynamic>[],
            'attendance': <dynamic>[],
            'timetable': <dynamic>[],
            'events': <dynamic>[],
            'notifications': <dynamic>[],
          }),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('semesters[0]'),
            ),
          ),
        );
        expect(
          () => BackupMetadata.fromJson(<String, dynamic>{
            'backupVersion': '2',
          }),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('metadata.backupVersion'),
            ),
          ),
        );
        expect(
          () => BackupMetadata.fromJson(<String, dynamic>{
            'backupVersion': 99,
          }),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('Unsupported backup version 99'),
            ),
          ),
        );

        // Direct BackupData.fromJson must enforce full validator (rows, domain bounds, Replace FKs),
        // not merely outer envelope/type shapes.
        final missingVersionMap = _validV2BackupMap();
        (missingVersionMap['metadata'] as Map<String, dynamic>)
            .remove('backupVersion');
        expect(
          () => BackupData.fromJson(missingVersionMap),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('metadata.backupVersion'),
            ),
          ),
        );

        final badSemDateMap = _validV2BackupMap();
        (badSemDateMap['semesters'] as List<Map<String, dynamic>>)[0]
            ['startDate'] = 'not-a-date';
        expect(
          () => BackupData.fromJson(badSemDateMap),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('semesters[0].startDate'),
            ),
          ),
        );

        final reversedSemDateMap = _validV2BackupMap();
        (reversedSemDateMap['semesters'] as List<Map<String, dynamic>>)[0]
            ['startDate'] = '2026-12-20T00:00:00.000Z';
        (reversedSemDateMap['semesters'] as List<Map<String, dynamic>>)[0]
            ['endDate'] = '2026-08-01T00:00:00.000Z';
        expect(
          () => BackupData.fromJson(reversedSemDateMap),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('semesters[0]'),
            ),
          ),
        );

        final badAttendanceStatusMap = _validV2BackupMap();
        (badAttendanceStatusMap['attendance'] as List<Map<String, dynamic>>)[0]
            ['status'] = 'BOGUS_STATUS';
        expect(
          () => BackupData.fromJson(badAttendanceStatusMap),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('attendance[0].status'),
            ),
          ),
        );

        final badTimetableTimeMap = _validV2BackupMap();
        (badTimetableTimeMap['timetable'] as List<Map<String, dynamic>>)[0]
            ['startTime'] = '25:99';
        expect(
          () => BackupData.fromJson(badTimetableTimeMap),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('timetable[0].startTime'),
            ),
          ),
        );

        final danglingSubjectMap = _validV2BackupMap();
        (danglingSubjectMap['subjects'] as List<Map<String, dynamic>>)[0]
            ['semesterId'] = 999;
        expect(
          () => BackupData.fromJson(danglingSubjectMap),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('subjects[0].semesterId'),
            ),
          ),
        );
        // Merge opt-in preserves BUG-006 orphan tolerance while keeping full row validation.
        final mergeParsed = BackupData.fromJson(
          danglingSubjectMap,
          strategy: ImportStrategy.merge,
        );
        expect(mergeParsed.subjects.first['semesterId'], equals(999));

        expect(
          () => SemesterLocal.fromJson(<String, dynamic>{
            'name': 'Bad Sem',
            'startDate': 'not-a-date',
            'endDate': '2026-12-01T00:00:00.000Z',
          }),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('semester.startDate'),
            ),
          ),
        );
        expect(
          () => MigrationAuditRecordLocal.fromJson(<String, dynamic>{
            'auditKey': 'k1',
            'kind': 'recoveredAttendance',
            'reason': 'r',
            'eventDate': 'bad-date',
          }),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains('migrationAudit.eventDate'),
            ),
          ),
        );

        // Verify all public BackupService & BackupImporter entry points reject Replace
        // FK violations by default while accepting them when Merge is requested.
        final dir = Directory.systemTemp.createTempSync('bug007_entry_pts_');
        Isar? isar;
        try {
          isar = _openTestIsar(dir, name: 'bug007_entry_pts');
          final importer = BackupImporter(isar);
          final service = BackupService(isar);
          final danglingJson = jsonEncode(danglingSubjectMap);
          final danglingFile = File('${dir.path}/dangling.attendiq')
            ..writeAsStringSync(danglingJson);

          expect(
            () => importer.parseAndValidateJson(danglingJson),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'message',
                contains('subjects[0].semesterId'),
              ),
            ),
          );
          expect(
            () => service.validateBackup(danglingJson),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'message',
                contains('subjects[0].semesterId'),
              ),
            ),
          );
          await expectLater(
            service.validateBackupPayload(danglingJson),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'message',
                contains('subjects[0].semesterId'),
              ),
            ),
          );
          await expectLater(
            service.validateBackupFile(danglingFile.path),
            throwsA(
              isA<FormatException>().having(
                (e) => e.message,
                'message',
                contains('subjects[0].semesterId'),
              ),
            ),
          );

          expect(
            importer
                .parseAndValidateJson(
                  danglingJson,
                  strategy: ImportStrategy.merge,
                )
                .subjects
                .length,
            equals(1),
          );
          expect(
            service
                .validateBackup(danglingJson, strategy: ImportStrategy.merge)
                .subjects
                .length,
            equals(1),
          );
          expect(
            (await service.validateBackupPayload(
              danglingJson,
              strategy: ImportStrategy.merge,
            ))
                .subjects
                .length,
            equals(1),
          );
          expect(
            (await service.validateBackupFile(
              danglingFile.path,
              strategy: ImportStrategy.merge,
            ))
                .subjects
                .length,
            equals(1),
          );
        } finally {
          isar?.close();
          if (dir.existsSync()) dir.deleteSync(recursive: true);
        }
      },
    );

    testWidgets(
      '19. BackupPage propagates validation and file-read errors cleanly across pasted JSON, picked files, and Backup Manager files without mutating DB',
      timeout: const Timeout(Duration(minutes: 2)),
      (tester) async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/package_info'),
          (call) async => <String, dynamic>{
            'appName': 'AttendIQ',
            'packageName': 'com.ramsa.attendiq',
            'version': '1.1.0',
            'buildNumber': '1',
          },
        );
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => Directory.systemTemp.path,
        );

        final dir = Directory.systemTemp.createTempSync('bug007_ui_');
        Isar? isar;
        try {
          isar = _openTestIsar(dir, name: 'bug007_ui');
          _seedAll13Collections(isar);

          final invalidBackupFile = File('${dir.path}/corrupt.attendiq')
            ..writeAsStringSync('{}');
          final emptyFile = File('${dir.path}/empty.attendiq')
            ..writeAsStringSync('');

          final stubService = _StubBackupService(
            isar,
            pickFileOverride: () async => PlatformFile(
              name: 'empty.attendiq',
              size: 0,
              path: emptyFile.path,
            ),
            files: <BackupFileItem>[
              BackupFileItem(
                fileName: 'corrupt.attendiq',
                filePath: invalidBackupFile.path,
                modifiedDate: DateTime(2026, 9, 1),
                sizeBytes: 2,
              ),
            ],
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                settingsRepositoryProvider
                    .overrideWithValue(_FakeSettingsRepository()),
                semesterRepositoryProvider
                    .overrideWithValue(_FakeSemesterRepository()),
                backupServiceProvider.overrideWithValue(stubService),
              ],
              child: const MaterialApp(home: BackupPage()),
            ),
          );
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)),
          );
          await tester.pumpAndSettle();

          // A. Paste `{}` into raw JSON dialog -> validation error SnackBar & no Replace dialog
          await tester.ensureVisible(
            find.text('Paste raw JSON string instead'),
          );
          await tester.tap(find.text('Paste raw JSON string instead'));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField), '{}');
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();

          expect(find.text('Select Restore Mode'), findsNothing);
          expect(find.textContaining('Backup validation error:'), findsWidgets);
          _expectSeedSentinelIntact(isar);

          // B. Pick empty file -> explicit error SnackBar instead of silent no-op
          ScaffoldMessenger.of(
            tester.element(find.byType(BackupPage)),
          ).clearSnackBars();
          await tester.pumpAndSettle();

          final importButton = find.text(
            'Import Backup / Data File (Drive, Downloads, Documents)',
          );
          await tester.ensureVisible(importButton);
          await tester.tap(importButton);
          await tester.pump();
          for (var i = 0; i < 10; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 25)),
            );
            await tester.pump();
          }
          await tester.pumpAndSettle();

          expect(
            find.textContaining('Failed to read selected file:'),
            findsWidgets,
          );
          _expectSeedSentinelIntact(isar);

          // C. Tap Restore on corrupt.attendiq in Backup Manager -> blocked BEFORE Replace dialog!
          ScaffoldMessenger.of(
            tester.element(find.byType(BackupPage)),
          ).clearSnackBars();
          await tester.pumpAndSettle();

          final moreMenu = find.byIcon(Icons.more_vert).first;
          await tester.ensureVisible(moreMenu);
          await tester.tap(moreMenu);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Restore'));
          await tester.pump();
          for (var i = 0; i < 10; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 25)),
            );
            await tester.pump();
          }
          await tester.pumpAndSettle();

          expect(find.text('Restore Backup'), findsNothing);
          expect(find.textContaining('Backup validation error:'), findsWidgets);
          _expectSeedSentinelIntact(isar);

          // D. BUG-006 orphan-merge JSON still reaches Select Restore Mode in BackupPage,
          // and choosing Replace rejects pre-tx with DB intact.
          ScaffoldMessenger.of(
            tester.element(find.byType(BackupPage)),
          ).clearSnackBars();
          await tester.pumpAndSettle();

          final orphanMergeMap = _validV2BackupMap();
          (orphanMergeMap['subjects'] as List<Map<String, dynamic>>)[0]
              ['semesterId'] = 999;

          await tester.ensureVisible(
            find.text('Paste raw JSON string instead'),
          );
          await tester.tap(find.text('Paste raw JSON string instead'));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byType(TextField),
            jsonEncode(orphanMergeMap),
          );
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();

          expect(find.text('Select Restore Mode'), findsOneWidget);
          await tester.tap(find.text('Replace Existing Data'));
          await tester.pumpAndSettle();

          expect(find.textContaining('Import failed:'), findsWidgets);
          _expectSeedSentinelIntact(isar);
        } finally {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/package_info'),
            null,
          );
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
          isar?.close();
          if (dir.existsSync()) dir.deleteSync(recursive: true);
        }
      },
    );
  });
}
