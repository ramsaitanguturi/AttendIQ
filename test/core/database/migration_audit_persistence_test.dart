import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/backup/backup_exporter.dart';
import 'package:attend_iq/core/backup/backup_importer.dart';
import 'package:attend_iq/core/constants/app_constants.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/event_generator/data/models/event_local.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/features/academic_planner/data/models/academic_task_local.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/settings/data/models/user_preferences_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/models/academic_event_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/schedule_exception_local.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/utils/occurrence_identity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void _failBeforeCommitInWriteTx(Isar _) {
  throw StateError('Simulated migration crash before commit');
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

  String? nativeLibPath;
  var dbSequence = 0;

  setUpAll(() async {
    nativeLibPath = await _resolveIsarNativeLibraryPath();
    if (nativeLibPath != null) {
      await Isar.initialize(nativeLibPath);
    }
  });

  Isar openTempIsar(
    Directory tempDir, {
    String? customName,
    List<IsarGeneratedSchema>? schemas,
  }) {
    final name = customName ??
        'attendiq_audit_${DateTime.now().microsecondsSinceEpoch}_${dbSequence++}';
    return Isar.open(
      schemas: schemas ?? appIsarSchemas,
      name: name,
      directory: tempDir.path,
    );
  }

  group('BUG-004 Follow-up: Durable Migration Audit Persistence', () {
    test(
      '1. Recovered attendance audit record survives close and reopen without duplication while preserving MigrationAuditReport behavior',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_audit_recovered_');
        final dbName =
            'audit_recovered_${DateTime.now().microsecondsSinceEpoch}';
        Isar? isar;
        try {
          final classDate = DateTime.utc(2026, 6, 10);
          final ts = DateTime.utc(2026, 6, 10, 10, 0);

          isar = openTempIsar(tempDir, customName: dbName);
          isar.write((db) {
            db.subjectLocals.put(
              SubjectLocal()
                ..id = 10
                ..serverId = 'sub_10'
                ..semesterId = 1
                ..name = 'Operating Systems'
                ..code = 'CS302'
                ..credits = 4
                ..attendanceTarget = 75.0
                ..color = '#2563EB'
                ..type = 'THEORY'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.eventLocals.put(
              EventLocal()
                ..id = 4
                ..serverId = 'ev_overwritten_4'
                ..subjectId = 10
                ..date = classDate
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'ABSENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });

          final report1 = await migrateLegacyTimetableAndEvents(isar);
          expect(report1.attendanceRecovered, equals(1));
          expect(
            report1.entriesOfKind(MigrationAuditKind.recoveredAttendance),
            hasLength(1),
          );

          final auditsAfterRun1 =
              isar.migrationAuditRecordLocals.where().findAll();
          expect(auditsAfterRun1, hasLength(1));
          final firstAudit = auditsAfterRun1.single;
          expect(
            firstAudit.kind,
            equals(MigrationAuditKind.recoveredAttendance.name),
          );
          expect(firstAudit.legacyEventId, equals(4));
          expect(firstAudit.sourceEventId, equals(4));
          expect(firstAudit.subjectId, equals(10));
          expect(firstAudit.status, equals('ABSENT'));
          expect(firstAudit.attendanceRecordId, isNotNull);
          expect(firstAudit.occurrenceId, isNotNull);
          expect(firstAudit.slotKey, isNotNull);
          expect(
            normalizeUtcDate(firstAudit.eventDate!),
            equals(classDate),
          );
          expect(firstAudit.reason, contains('EventLocal 4'));
          expect(firstAudit.diagnosticDetails, isNotNull);
          final parsedDetails =
              jsonDecode(firstAudit.diagnosticDetails!) as Map<String, dynamic>;
          expect(parsedDetails['resolutionState'], equals('RECOVERED'));
          expect(
            parsedDetails['legacyEventServerId'],
            equals('ev_overwritten_4'),
          );

          final firstCreatedAt = firstAudit.createdAt.toUtc();
          final firstUpdatedAt = firstAudit.updatedAt.toUtc();
          final firstAuditKey = firstAudit.auditKey;

          // Close and reopen DB and re-run full startup migration twice.
          isar.close();
          isar = openTempIsar(tempDir, customName: dbName);
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await migrateLegacyDatabaseRecords(isar);
          final report2 = await migrateLegacyTimetableAndEvents(isar);

          // In-memory report stays unchanged (0 new recoveries on subsequent runs).
          expect(report2.attendanceRecovered, equals(0));
          expect(
            report2.entriesOfKind(MigrationAuditKind.recoveredAttendance),
            isEmpty,
          );

          // Durable persisted audit record survives close/reopen without duplication.
          final auditsAfterReopen =
              isar.migrationAuditRecordLocals.where().findAll();
          expect(auditsAfterReopen, hasLength(1));
          final survived = auditsAfterReopen.single;
          expect(survived.id, equals(firstAudit.id));
          expect(survived.auditKey, equals(firstAuditKey));
          expect(survived.createdAt.toUtc(), equals(firstCreatedAt));
          expect(survived.updatedAt.toUtc(), equals(firstUpdatedAt));
          expect(
            survived.attendanceRecordId,
            equals(firstAudit.attendanceRecordId),
          );
          expect(survived.occurrenceId, equals(firstAudit.occurrenceId));
          expect(survived.legacyEventId, equals(4));
        } finally {
          if (isar != null && isar.isOpen) {
            isar.close();
          }
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );

    test(
      '2. Ambiguous collision, subject mismatch, and missing occurrence target audit records survive close/reopen conservatively without duplication',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_audit_anomalies_');
        final dbName =
            'audit_anomalies_${DateTime.now().microsecondsSinceEpoch}';
        Isar? isar;
        try {
          final date = DateTime.utc(2026, 8, 12);
          final ts = DateTime.utc(2026, 8, 12, 10, 0);

          isar = openTempIsar(tempDir, customName: dbName);
          isar.write((db) {
            db.subjectLocals.putAll(<SubjectLocal>[
              SubjectLocal()
                ..id = 10
                ..serverId = 'sub_10'
                ..semesterId = 1
                ..name = 'Compilers'
                ..code = 'CS401'
                ..credits = 4
                ..attendanceTarget = 75.0
                ..color = '#2563EB'
                ..type = 'THEORY'
                ..createdAt = ts
                ..updatedAt = ts,
              SubjectLocal()
                ..id = 20
                ..serverId = 'sub_20'
                ..semesterId = 1
                ..name = 'Graphics'
                ..code = 'CS402'
                ..credits = 3
                ..attendanceTarget = 75.0
                ..color = '#10B981'
                ..type = 'THEORY'
                ..createdAt = ts
                ..updatedAt = ts,
            ]);

            // Occ #1 (sub 10) collides with EventLocal #1 (sub 10) for att #1 -> ambiguous tie.
            final occ1 = DailyScheduleOccurrenceLocal()
              ..id = 1
              ..serverId = 'native_occ_1'
              ..date = date
              ..subjectId = 10
              ..title = 'Compilers'
              ..startTime = '15:00'
              ..endTime = '16:00'
              ..type = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdFrom = 'MANUAL'
              ..createdAt = ts
              ..updatedAt = ts;
            occ1.slotKey = computeSlotKeyForLocal(occ1);

            // Occ #5 (sub 20) mismatches att #2 (sub 10, eventId=5) -> subject mismatch.
            final occ5 = DailyScheduleOccurrenceLocal()
              ..id = 5
              ..serverId = 'occ_sub_20'
              ..date = date
              ..subjectId = 20
              ..title = 'Graphics'
              ..startTime = '11:00'
              ..endTime = '12:00'
              ..type = 'REGULAR_CLASS'
              ..status = 'ABSENT'
              ..createdFrom = 'MANUAL'
              ..createdAt = ts
              ..updatedAt = ts;
            occ5.slotKey = computeSlotKeyForLocal(occ5);

            db.dailyScheduleOccurrenceLocals
                .putAll(<DailyScheduleOccurrenceLocal>[occ1, occ5]);

            db.eventLocals.put(
              EventLocal()
                ..id = 1
                ..serverId = 'ev_1'
                ..subjectId = 10
                ..date = date
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );

            db.attendanceRecordLocals.putAll(<AttendanceRecordLocal>[
              // att #1: ambiguous collision between occ #1 and migrated ev #1.
              AttendanceRecordLocal()
                ..id = 1
                ..serverId = 'att_tie'
                ..eventId = 1
                ..subjectId = 10
                ..status = 'PRESENT'
                ..markedAt = ts
                ..createdAt = ts
                ..updatedAt = ts,
              // att #2: subject mismatch against occ #5 (subject 20 vs 10).
              AttendanceRecordLocal()
                ..id = 2
                ..serverId = 'att_mismatch'
                ..eventId = 5
                ..subjectId = 10
                ..status = 'ABSENT'
                ..markedAt = ts
                ..createdAt = ts
                ..updatedAt = ts,
              // att #3: missing target (eventId = 999).
              AttendanceRecordLocal()
                ..id = 3
                ..serverId = 'att_missing'
                ..eventId = 999
                ..subjectId = 10
                ..status = 'ABSENT'
                ..markedAt = ts
                ..createdAt = ts
                ..updatedAt = ts,
              // att #4: non-positive eventId (eventId = 0).
              AttendanceRecordLocal()
                ..id = 4
                ..serverId = 'att_zero'
                ..eventId = 0
                ..subjectId = 10
                ..status = 'PRESENT'
                ..markedAt = ts
                ..createdAt = ts
                ..updatedAt = ts,
            ]);
          });

          final report1 = await migrateLegacyTimetableAndEvents(isar);
          expect(
            report1.entriesOfKind(
              MigrationAuditKind.ambiguousAttendanceCollision,
            ),
            hasLength(1),
          );
          expect(
            report1.entriesOfKind(MigrationAuditKind.subjectMismatch),
            hasLength(1),
          );
          expect(
            report1.entriesOfKind(MigrationAuditKind.missingOccurrenceTarget),
            hasLength(2),
          );

          final audits1 = isar.migrationAuditRecordLocals.where().findAll();
          expect(audits1, hasLength(4));

          final ambigAudit = audits1.firstWhere(
            (a) =>
                a.kind == MigrationAuditKind.ambiguousAttendanceCollision.name,
          );
          expect(ambigAudit.attendanceRecordId, equals(1));
          expect(ambigAudit.legacyEventId, equals(1));
          expect(ambigAudit.occurrenceId, isNull);
          expect(ambigAudit.subjectId, equals(10));
          expect(ambigAudit.parsedCandidateOccurrenceIds, hasLength(2));
          expect(ambigAudit.reason, contains('Ambiguous collision'));

          final mismatchAudit = audits1.firstWhere(
            (a) => a.kind == MigrationAuditKind.subjectMismatch.name,
          );
          expect(mismatchAudit.attendanceRecordId, equals(2));
          expect(mismatchAudit.legacyEventId, equals(5));
          expect(mismatchAudit.parsedCandidateOccurrenceIds, equals(<int>[5]));

          final missing999Audit = audits1.firstWhere(
            (a) =>
                a.kind == MigrationAuditKind.missingOccurrenceTarget.name &&
                a.attendanceRecordId == 3,
          );
          expect(missing999Audit.legacyEventId, equals(999));

          final missingZeroAudit = audits1.firstWhere(
            (a) =>
                a.kind == MigrationAuditKind.missingOccurrenceTarget.name &&
                a.attendanceRecordId == 4,
          );
          expect(missingZeroAudit.sourceEventId, equals(0));

          final initialTimestamps = <String, DateTime>{
            for (final a in audits1) a.auditKey: a.createdAt.toUtc(),
          };
          final initialUpdated = <String, DateTime>{
            for (final a in audits1) a.auditKey: a.updatedAt.toUtc(),
          };

          // Close, reopen, and run startup migrations multiple times.
          isar.close();
          isar = openTempIsar(tempDir, customName: dbName);
          await Future<void>.delayed(const Duration(milliseconds: 20));
          await migrateLegacyDatabaseRecords(isar);
          final report2 = await migrateLegacyTimetableAndEvents(isar);
          final report3 = await migrateLegacyTimetableAndEvents(isar);

          // Conservative behavior: unresolved attendance records remain unlinked.
          for (final attId in <int>[1, 2, 3, 4]) {
            expect(
              isar.attendanceRecordLocals.get(attId)!.occurrenceId,
              isNull,
            );
          }

          // Report still surfaces unresolved conditions on re-evaluation.
          expect(
            report2.entriesOfKind(
              MigrationAuditKind.ambiguousAttendanceCollision,
            ),
            hasLength(1),
          );
          expect(
            report3.entriesOfKind(MigrationAuditKind.subjectMismatch),
            hasLength(1),
          );

          // Durable records are NOT duplicated and preserve original timestamps!
          final auditsAfter = isar.migrationAuditRecordLocals.where().findAll();
          expect(auditsAfter, hasLength(4));
          for (final a in auditsAfter) {
            expect(
              a.createdAt.toUtc(),
              equals(initialTimestamps[a.auditKey]),
            );
            expect(
              a.updatedAt.toUtc(),
              equals(initialUpdated[a.auditKey]),
            );
          }
        } finally {
          if (isar != null && isar.isOpen) {
            isar.close();
          }
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );

    test(
      '3. Duplicate occurrence merge audit records (including multiple duplicates in one slot) are persisted and survive reopen without duplication',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_audit_dup_');
        final dbName = 'audit_dup_${DateTime.now().microsecondsSinceEpoch}';
        Isar? isar;
        try {
          final day = DateTime.utc(2026, 9, 5);
          final ts = DateTime.utc(2026, 9, 5, 8, 0);
          final slotKey = computeCanonicalSlotKey(
            date: day,
            subjectId: 10,
            ruleId: 7,
            startTime: '09:00',
            endTime: '10:00',
            type: 'REGULAR_CLASS',
          );

          isar = openTempIsar(tempDir, customName: dbName);
          isar.write((db) {
            // Winner: id = 10 (status PRESENT, claimed by att #1).
            // Two duplicates sharing identical canonical slotKey: id = 11 & id = 12.
            db.dailyScheduleOccurrenceLocals
                .putAll(<DailyScheduleOccurrenceLocal>[
              DailyScheduleOccurrenceLocal()
                ..id = 10
                ..serverId = 'occ_winner'
                ..date = day
                ..subjectId = 10
                ..ruleId = 7
                ..slotKey = slotKey
                ..title = 'Networks'
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..type = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdFrom = 'WEEKLY_RULE'
                ..createdAt = ts
                ..updatedAt = ts,
              DailyScheduleOccurrenceLocal()
                ..id = 11
                ..serverId = 'occ_dup_1'
                ..date = day
                ..subjectId = 10
                ..ruleId = 7
                ..legacyEventId = 101
                ..slotKey = slotKey
                ..title = 'Networks'
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..type = 'REGULAR_CLASS'
                ..status = 'UPCOMING'
                ..createdFrom = 'WEEKLY_RULE'
                ..createdAt = ts
                ..updatedAt = ts,
              DailyScheduleOccurrenceLocal()
                ..id = 12
                ..serverId = 'occ_dup_2'
                ..date = day
                ..subjectId = 10
                ..ruleId = 7
                ..legacyEventId = 102
                ..slotKey = slotKey
                ..title = 'Networks'
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..type = 'REGULAR_CLASS'
                ..status = 'UPCOMING'
                ..createdFrom = 'WEEKLY_RULE'
                ..createdAt = ts
                ..updatedAt = ts,
            ]);
            db.attendanceRecordLocals.put(
              AttendanceRecordLocal()
                ..id = 1
                ..serverId = 'att_winner'
                ..occurrenceId = 10
                ..eventId = 10
                ..subjectId = 10
                ..status = 'PRESENT'
                ..markedAt = ts
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });

          final report1 = await migrateLegacyTimetableAndEvents(isar);
          expect(report1.duplicateOccurrencesMerged, equals(2));
          expect(
            report1.entriesOfKind(MigrationAuditKind.duplicateOccurrenceMerged),
            hasLength(2),
          );

          final audits1 = isar.migrationAuditRecordLocals
              .where()
              .kindEqualTo(MigrationAuditKind.duplicateOccurrenceMerged.name)
              .findAll();
          expect(audits1, hasLength(2));
          expect(
            audits1.map((a) => a.sourceOccurrenceId).toSet(),
            equals(<int?>{11, 12}),
          );
          for (final a in audits1) {
            expect(a.occurrenceId, equals(10));
            expect(a.slotKey, equals(slotKey));
            expect(a.subjectId, equals(10));
            expect(a.reason, contains('canonical occurrence 10'));
          }

          // Reopen and re-run migration: historical merge records survive without duplicating.
          isar.close();
          isar = openTempIsar(tempDir, customName: dbName);
          final report2 = await migrateLegacyTimetableAndEvents(isar);
          expect(report2.duplicateOccurrencesMerged, equals(0));
          expect(
            isar.migrationAuditRecordLocals
                .where()
                .kindEqualTo(
                  MigrationAuditKind.duplicateOccurrenceMerged.name,
                )
                .findAll(),
            hasLength(2),
          );
        } finally {
          if (isar != null && isar.isOpen) {
            isar.close();
          }
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );

    test(
      '4. A failed migration transaction rolls back atomically and leaves zero partial audit records or partial migration changes',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_audit_rollback_');
        Isar? isar;
        try {
          final ts = DateTime.utc(2026, 6, 15, 9, 0);
          isar = openTempIsar(tempDir);

          isar.write((db) {
            db.subjectLocals.put(
              SubjectLocal()
                ..id = 1
                ..serverId = 'sub_1'
                ..semesterId = 1
                ..name = 'Databases'
                ..code = 'CS305'
                ..credits = 4
                ..attendanceTarget = 75.0
                ..color = '#2563EB'
                ..type = 'THEORY'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.timetableTemplateLocals.put(
              TimetableTemplateLocal()
                ..id = 1
                ..serverId = 'tpl_1'
                ..subjectId = 1
                ..weekday = ts.weekday
                ..startTime = '10:00'
                ..endTime = '11:00'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.eventLocals.put(
              EventLocal()
                ..id = 4
                ..serverId = 'ev_4'
                ..subjectId = 1
                ..date = DateTime.utc(2026, 6, 15)
                ..startTime = '10:00'
                ..endTime = '11:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.attendanceRecordLocals.put(
              AttendanceRecordLocal()
                ..id = 1
                ..serverId = 'att_orphan'
                ..eventId = 999
                ..subjectId = 1
                ..status = 'ABSENT'
                ..markedAt = ts
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });

          // 4a. Fail inside migrateLegacyTimetableAndEvents right before commit
          // (after rules, occurrences, recovered attendance, and audit puts ran).
          await expectLater(
            () => migrateLegacyTimetableAndEvents(
              isar!,
              onBeforeCommit: _failBeforeCommitInWriteTx,
            ),
            throwsA(isA<StateError>()),
          );

          expect(isar.weeklyScheduleRuleLocals.count(), equals(0));
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(0));
          expect(isar.attendanceRecordLocals.count(), equals(1));
          expect(isar.attendanceRecordLocals.get(1)!.legacyEventId, isNull);
          expect(isar.migrationAuditRecordLocals.count(), equals(0));

          // 4b. Fail inside an outer writeAsync transaction calling runTimetableUnificationInWriteTx.
          await expectLater(
            () => isar!.writeAsync<void>((db) {
              runTimetableUnificationInWriteTx(db);
              throw StateError('Outer transaction aborted');
            }),
            throwsA(isA<StateError>()),
          );

          expect(isar.weeklyScheduleRuleLocals.count(), equals(0));
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(0));
          expect(isar.attendanceRecordLocals.count(), equals(1));
          expect(isar.migrationAuditRecordLocals.count(), equals(0));

          // 4c. Subsequent successful migration commits both changes and audit records together.
          final report = await migrateLegacyTimetableAndEvents(isar);
          expect(report.rulesMigrated, equals(1));
          expect(report.attendanceRecovered, equals(1));
          expect(isar.weeklyScheduleRuleLocals.count(), equals(1));
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(1));
          expect(isar.attendanceRecordLocals.count(), equals(2));
          expect(isar.migrationAuditRecordLocals.count(), equals(2));
        } finally {
          if (isar != null && isar.isOpen) {
            isar.close();
          }
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );

    test(
      '5. Existing 12-schema BUG-004 database upgrades cleanly via isarProvider to 13 schemas without losing data or duplicating audits',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_audit_upgrade_');
        Isar? legacyOpenedIsar;
        ProviderContainer? container1;
        ProviderContainer? container2;

        try {
          final ts = DateTime.utc(2026, 7, 1, 9, 0);
          final legacySchemas12 = <IsarGeneratedSchema>[
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

          // Open with the previous 12-schema set (before MigrationAuditRecordLocalSchema existed).
          legacyOpenedIsar = openTempIsar(
            tempDir,
            customName: AppConstants.isarDbName,
            schemas: legacySchemas12,
          );
          legacyOpenedIsar.write((db) {
            db.semesterLocals.put(
              SemesterLocal()
                ..id = 1
                ..serverId = 'sem_1'
                ..name = 'Fall 2026'
                ..startDate = DateTime.utc(2026, 6, 1)
                ..endDate = DateTime.utc(2026, 11, 1)
                ..requiredAttendanceRate = 75.0
                ..status = SemesterLocal.statusActive
                ..isActive = true
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.subjectLocals.put(
              SubjectLocal()
                ..id = 1
                ..serverId = 'sub_1'
                ..semesterId = 1
                ..name = 'Algorithms'
                ..code = 'CS301'
                ..credits = 4
                ..attendanceTarget = 75.0
                ..color = '#2563EB'
                ..type = 'THEORY'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.eventLocals.put(
              EventLocal()
                ..id = 7
                ..serverId = 'ev_7'
                ..subjectId = 1
                ..date = DateTime.utc(2026, 7, 1)
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });
          legacyOpenedIsar.close();
          legacyOpenedIsar = null;

          // Reopen through production isarProvider (13 schemas + startup migration).
          container1 = ProviderContainer(
            overrides: [
              databaseDirectoryResolverProvider
                  .overrideWithValue(() async => tempDir.path),
            ],
          );
          final upgradedIsar1 = await container1.read(isarProvider.future);
          expect(upgradedIsar1.semesterLocals.count(), equals(1));
          expect(upgradedIsar1.subjectLocals.count(), equals(1));
          expect(upgradedIsar1.attendanceRecordLocals.count(), equals(1));
          expect(upgradedIsar1.migrationAuditRecordLocals.count(), equals(1));
          expect(
            upgradedIsar1.migrationAuditRecordLocals
                .where()
                .findAll()
                .single
                .kind,
            equals(MigrationAuditKind.recoveredAttendance.name),
          );
          container1.dispose();
          container1 = null;

          // Reopen a second time through isarProvider -> zero duplicates.
          container2 = ProviderContainer(
            overrides: [
              databaseDirectoryResolverProvider
                  .overrideWithValue(() async => tempDir.path),
            ],
          );
          final upgradedIsar2 = await container2.read(isarProvider.future);
          expect(upgradedIsar2.semesterLocals.count(), equals(1));
          expect(upgradedIsar2.attendanceRecordLocals.count(), equals(1));
          expect(upgradedIsar2.migrationAuditRecordLocals.count(), equals(1));
        } finally {
          container1?.dispose();
          container2?.dispose();
          if (legacyOpenedIsar != null && legacyOpenedIsar.isOpen) {
            legacyOpenedIsar.close();
          }
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );

    test(
      '6. BackupExporter & BackupImporter (Merge and Replace) preserve all migration audit records, remap IDs/auditKeys cleanly, and remain backward-compatible with pre-audit backups',
      () async {
        if (nativeLibPath == null) return;

        final dirSrc =
            await Directory.systemTemp.createTemp('attendiq_audit_bkp_src_');
        final dirDest =
            await Directory.systemTemp.createTemp('attendiq_audit_bkp_dest_');
        Isar? srcIsar;
        Isar? destIsar;

        try {
          final ts = DateTime.utc(2026, 8, 1, 9, 0);
          final slotKey = computeCanonicalSlotKey(
            date: DateTime.utc(2026, 8, 2),
            subjectId: 1,
            ruleId: 1,
            startTime: '09:00',
            endTime: '10:00',
            type: 'REGULAR_CLASS',
          );

          // 6a. Source DB produces recoveredAttendance, duplicateOccurrenceMerged,
          //     ambiguousAttendanceCollision, subjectMismatch, missingOccurrenceTarget.
          srcIsar = openTempIsar(dirSrc);
          srcIsar.write((db) {
            db.semesterLocals.put(
              SemesterLocal()
                ..id = 1
                ..serverId = 'src_sem_1'
                ..name = 'Source Sem'
                ..startDate = DateTime.utc(2026, 8, 1)
                ..endDate = DateTime.utc(2026, 12, 1)
                ..requiredAttendanceRate = 75.0
                ..status = SemesterLocal.statusActive
                ..isActive = true
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.subjectLocals.putAll(<SubjectLocal>[
              SubjectLocal()
                ..id = 1
                ..serverId = 'src_sub_1'
                ..semesterId = 1
                ..name = 'Source Subject 1'
                ..code = 'SRC101'
                ..credits = 3
                ..attendanceTarget = 75.0
                ..color = '#2563EB'
                ..type = 'THEORY'
                ..createdAt = ts
                ..updatedAt = ts,
              SubjectLocal()
                ..id = 2
                ..serverId = 'src_sub_2'
                ..semesterId = 1
                ..name = 'Source Subject 2'
                ..code = 'SRC102'
                ..credits = 3
                ..attendanceTarget = 75.0
                ..color = '#10B981'
                ..type = 'THEORY'
                ..createdAt = ts
                ..updatedAt = ts,
            ]);
            db.weeklyScheduleRuleLocals.put(
              WeeklyScheduleRuleLocal()
                ..id = 1
                ..serverId = 'src_rule_1'
                ..subjectId = 1
                ..dayOfWeek = DateTime.utc(2026, 8, 2).weekday
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..type = 'THEORY'
                ..isActive = true
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.dailyScheduleOccurrenceLocals
                .putAll(<DailyScheduleOccurrenceLocal>[
              // id=1 & id=2 share slotKey -> duplicateOccurrenceMerged.
              DailyScheduleOccurrenceLocal()
                ..id = 1
                ..serverId = 'src_occ_1'
                ..date = DateTime.utc(2026, 8, 2)
                ..subjectId = 1
                ..ruleId = 1
                ..slotKey = slotKey
                ..title = 'Source Subject 1'
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..type = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdFrom = 'WEEKLY_RULE'
                ..createdAt = ts
                ..updatedAt = ts,
              DailyScheduleOccurrenceLocal()
                ..id = 2
                ..serverId = 'src_occ_2'
                ..date = DateTime.utc(2026, 8, 2)
                ..subjectId = 1
                ..ruleId = 1
                ..slotKey = slotKey
                ..title = 'Source Subject 1'
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..type = 'REGULAR_CLASS'
                ..status = 'UPCOMING'
                ..createdFrom = 'WEEKLY_RULE'
                ..createdAt = ts
                ..updatedAt = ts,
              // id=3 belongs to sub=2 -> subjectMismatch with att #2 (sub=1).
              DailyScheduleOccurrenceLocal()
                ..id = 3
                ..serverId = 'src_occ_3'
                ..date = DateTime.utc(2026, 8, 3)
                ..subjectId = 2
                ..title = 'Source Subject 2'
                ..startTime = '11:00'
                ..endTime = '12:00'
                ..type = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdFrom = 'MANUAL'
                ..createdAt = ts
                ..updatedAt = ts,
              // id=4 collides with EventLocal #4 on att #4 -> ambiguous tie.
              DailyScheduleOccurrenceLocal()
                ..id = 4
                ..serverId = 'src_occ_4'
                ..date = DateTime.utc(2026, 8, 4)
                ..subjectId = 1
                ..title = 'Source Subject 1'
                ..startTime = '15:00'
                ..endTime = '16:00'
                ..type = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdFrom = 'MANUAL'
                ..createdAt = ts
                ..updatedAt = ts,
            ]);
            db.eventLocals.putAll(<EventLocal>[
              // ev #4 collides with occ #4 for att #4.
              EventLocal()
                ..id = 4
                ..serverId = 'src_ev_4'
                ..subjectId = 1
                ..date = DateTime.utc(2026, 8, 4)
                ..startTime = '13:00'
                ..endTime = '14:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdAt = ts
                ..updatedAt = ts,
              // ev #5 triggers recoveredAttendance.
              EventLocal()
                ..id = 5
                ..serverId = 'src_ev_5'
                ..subjectId = 1
                ..date = DateTime.utc(2026, 8, 5)
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'ABSENT'
                ..createdAt = ts
                ..updatedAt = ts,
            ]);
            db.attendanceRecordLocals.putAll(<AttendanceRecordLocal>[
              AttendanceRecordLocal()
                ..id = 1
                ..serverId = 'src_att_winner'
                ..occurrenceId = 1
                ..eventId = 1
                ..subjectId = 1
                ..status = 'PRESENT'
                ..markedAt = ts
                ..createdAt = ts
                ..updatedAt = ts,
              AttendanceRecordLocal()
                ..id = 2
                ..serverId = 'src_att_mismatch'
                ..eventId = 3
                ..subjectId = 1
                ..status = 'PRESENT'
                ..markedAt = DateTime.utc(2026, 8, 3)
                ..createdAt = ts
                ..updatedAt = ts,
              AttendanceRecordLocal()
                ..id = 3
                ..serverId = 'src_att_missing'
                ..eventId = 999
                ..subjectId = 1
                ..status = 'ABSENT'
                ..markedAt = DateTime.utc(2026, 8, 6)
                ..createdAt = ts
                ..updatedAt = ts,
              AttendanceRecordLocal()
                ..id = 4
                ..serverId = 'src_att_ambig'
                ..eventId = 4
                ..subjectId = 1
                ..status = 'PRESENT'
                ..markedAt = DateTime.utc(2026, 8, 4)
                ..createdAt = ts
                ..updatedAt = ts,
            ]);
          });

          await migrateLegacyTimetableAndEvents(srcIsar);
          final srcAudits =
              srcIsar.migrationAuditRecordLocals.where().findAll();
          expect(srcAudits, hasLength(5));
          expect(
            srcAudits.map((a) => a.kind).toSet(),
            equals(<String>{
              MigrationAuditKind.duplicateOccurrenceMerged.name,
              MigrationAuditKind.subjectMismatch.name,
              MigrationAuditKind.missingOccurrenceTarget.name,
              MigrationAuditKind.ambiguousAttendanceCollision.name,
              MigrationAuditKind.recoveredAttendance.name,
            }),
          );

          final backupJson = await BackupExporter(srcIsar).exportToJsonString();

          // 6b. Destination DB already has conflicting PKs (id = 1 everywhere)
          //     AND its own existing recoveredAttendance audit record!
          destIsar = openTempIsar(dirDest);
          destIsar.write((db) {
            db.semesterLocals.put(
              SemesterLocal()
                ..id = 1
                ..serverId = 'dest_sem_1'
                ..name = 'Dest Sem'
                ..startDate = DateTime.utc(2026, 1, 1)
                ..endDate = DateTime.utc(2026, 5, 1)
                ..requiredAttendanceRate = 75.0
                ..status = SemesterLocal.statusActive
                ..isActive = true
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.subjectLocals.put(
              SubjectLocal()
                ..id = 1
                ..serverId = 'dest_sub_1'
                ..semesterId = 1
                ..name = 'Dest History'
                ..code = 'DST101'
                ..credits = 3
                ..attendanceTarget = 75.0
                ..color = '#64748B'
                ..type = 'THEORY'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.eventLocals.put(
              EventLocal()
                ..id = 5
                ..serverId = 'dest_ev_5'
                ..subjectId = 1
                ..date = DateTime.utc(2026, 2, 10)
                ..startTime = '08:00'
                ..endTime = '09:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });
          await migrateLegacyTimetableAndEvents(destIsar);
          final destInitialAudits =
              destIsar.migrationAuditRecordLocals.where().findAll();
          expect(destInitialAudits, hasLength(1));
          final destOwnAuditKey = destInitialAudits.single.auditKey;

          // Merge import!
          final importer = BackupImporter(destIsar);
          await importer.importData(backupJson, strategy: ImportStrategy.merge);

          final mergedAudits =
              destIsar.migrationAuditRecordLocals.where().findAll();
          // 1 existing Dest audit + 5 imported Source audits = 6 total!
          expect(mergedAudits, hasLength(6));
          expect(
            mergedAudits.any((a) => a.auditKey == destOwnAuditKey),
            isTrue,
          );

          // Imported recoveredAttendance for src_ev_5 must have remapped legacyEventId != 5
          // so it did NOT overwrite dest_ev_5!
          final destEv5 = destIsar.eventLocals
              .where()
              .serverIdEqualTo('src_ev_5')
              .findFirst()!;
          final importedRecAudit = mergedAudits.firstWhere(
            (a) =>
                a.kind == MigrationAuditKind.recoveredAttendance.name &&
                a.legacyEventId == destEv5.id,
          );
          expect(importedRecAudit.legacyEventId, isNot(equals(5)));
          expect(importedRecAudit.attendanceRecordId, isNotNull);
          expect(importedRecAudit.occurrenceId, isNotNull);

          // Imported duplicateOccurrenceMerged has remapped source & destination IDs.
          final importedDupAudit = mergedAudits.firstWhere(
            (a) => a.kind == MigrationAuditKind.duplicateOccurrenceMerged.name,
          );
          final srcOcc1InDest = destIsar.dailyScheduleOccurrenceLocals
              .where()
              .serverIdEqualTo('src_occ_1')
              .findFirst()!;
          final srcOcc2InDest = destIsar.dailyScheduleOccurrenceLocals
              .where()
              .serverIdEqualTo('src_occ_2')
              .findFirst()!;
          expect(importedDupAudit.occurrenceId, equals(srcOcc1InDest.id));
          expect(importedDupAudit.sourceOccurrenceId, equals(srcOcc2InDest.id));
          final srcSub1InDest =
              destIsar.subjectLocals.where().codeEqualTo('SRC101').findFirst()!;
          expect(
            importedDupAudit.slotKey,
            contains('sub:${srcSub1InDest.id}|'),
          );

          // Imported missingOccurrenceTarget preserves original legacyEventId=999
          // even though step 13 re-ran in the same transaction.
          final srcAttMissingInDest = destIsar.attendanceRecordLocals
              .where()
              .serverIdEqualTo('src_att_missing')
              .findFirst()!;
          final importedMissingAudit = mergedAudits.firstWhere(
            (a) =>
                a.kind == MigrationAuditKind.missingOccurrenceTarget.name &&
                a.attendanceRecordId == srcAttMissingInDest.id,
          );
          expect(importedMissingAudit.legacyEventId, equals(999));

          // Imported subjectMismatch & ambiguousAttendanceCollision remap
          // attendanceRecordId, legacyEventId, subjectId, and candidateOccurrenceIds.
          final srcAttMismatchInDest = destIsar.attendanceRecordLocals
              .where()
              .serverIdEqualTo('src_att_mismatch')
              .findFirst()!;
          final srcOcc3InDest = destIsar.dailyScheduleOccurrenceLocals
              .where()
              .serverIdEqualTo('src_occ_3')
              .findFirst()!;
          final importedMismatchAudit = mergedAudits.firstWhere(
            (a) =>
                a.kind == MigrationAuditKind.subjectMismatch.name &&
                a.attendanceRecordId == srcAttMismatchInDest.id,
          );
          expect(
            importedMismatchAudit.parsedCandidateOccurrenceIds,
            equals(<int>[srcOcc3InDest.id]),
          );

          final srcAttAmbigInDest = destIsar.attendanceRecordLocals
              .where()
              .serverIdEqualTo('src_att_ambig')
              .findFirst()!;
          final srcEv4InDest = destIsar.eventLocals
              .where()
              .serverIdEqualTo('src_ev_4')
              .findFirst()!;
          final importedAmbigAudit = mergedAudits.firstWhere(
            (a) =>
                a.kind ==
                    MigrationAuditKind.ambiguousAttendanceCollision.name &&
                a.attendanceRecordId == srcAttAmbigInDest.id,
          );
          expect(srcAttAmbigInDest.occurrenceId, isNull);
          expect(srcAttMismatchInDest.occurrenceId, isNull);
          expect(srcAttMissingInDest.occurrenceId, isNull);
          expect(importedAmbigAudit.legacyEventId, equals(srcEv4InDest.id));
          expect(
            importedAmbigAudit.parsedCandidateOccurrenceIds,
            hasLength(2),
          );

          // Re-merging identical backup does NOT duplicate audit records and
          // preserves unresolved attendance ambiguity (occurrenceId == null).
          await importer.importData(backupJson, strategy: ImportStrategy.merge);
          expect(destIsar.migrationAuditRecordLocals.count(), equals(6));
          expect(
            destIsar.attendanceRecordLocals
                .where()
                .serverIdEqualTo('src_att_ambig')
                .findFirst()!
                .occurrenceId,
            isNull,
          );
          expect(
            destIsar.attendanceRecordLocals
                .where()
                .serverIdEqualTo('src_att_mismatch')
                .findFirst()!
                .occurrenceId,
            isNull,
          );
          expect(
            destIsar.attendanceRecordLocals
                .where()
                .serverIdEqualTo('src_att_missing')
                .findFirst()!
                .occurrenceId,
            isNull,
          );

          // Simulating app restart migration also preserves unresolved
          // attendance ambiguity without silently auto-resolving it.
          await migrateLegacyTimetableAndEvents(destIsar);
          expect(destIsar.migrationAuditRecordLocals.count(), equals(6));
          expect(
            destIsar.attendanceRecordLocals
                .where()
                .serverIdEqualTo('src_att_ambig')
                .findFirst()!
                .occurrenceId,
            isNull,
          );
          expect(
            destIsar.attendanceRecordLocals
                .where()
                .serverIdEqualTo('src_att_mismatch')
                .findFirst()!
                .occurrenceId,
            isNull,
          );
          expect(
            destIsar.attendanceRecordLocals
                .where()
                .serverIdEqualTo('src_att_missing')
                .findFirst()!
                .occurrenceId,
            isNull,
          );

          // Replace import clears old audits and restores exact 5 Source audits.
          await importer.importData(
            backupJson,
            strategy: ImportStrategy.replace,
          );
          final replacedAudits =
              destIsar.migrationAuditRecordLocals.where().findAll();
          expect(replacedAudits, hasLength(5));
          expect(
            replacedAudits.map((a) => a.kind).toSet(),
            equals(<String>{
              MigrationAuditKind.duplicateOccurrenceMerged.name,
              MigrationAuditKind.subjectMismatch.name,
              MigrationAuditKind.missingOccurrenceTarget.name,
              MigrationAuditKind.ambiguousAttendanceCollision.name,
              MigrationAuditKind.recoveredAttendance.name,
            }),
          );

          // Pre-audit backup (no migrationAudits field) imports cleanly and
          // persists audit records produced by post-import unification.
          final legacyMap = jsonDecode(backupJson) as Map<String, dynamic>;
          legacyMap.remove('migrationAudits');
          legacyMap['attendance'] = (legacyMap['attendance'] as List<dynamic>)
              .where(
                (item) => (item as Map)['serverId'] != 'recovered_att_ev_5',
              )
              .toList();
          await importer.importData(
            jsonEncode(legacyMap),
            strategy: ImportStrategy.replace,
          );
          final postLegacyAudits =
              destIsar.migrationAuditRecordLocals.where().findAll();
          expect(
            postLegacyAudits.any(
              (a) => a.kind == MigrationAuditKind.recoveredAttendance.name,
            ),
            isTrue,
          );
          expect(
            postLegacyAudits.any(
              (a) =>
                  a.kind ==
                  MigrationAuditKind.ambiguousAttendanceCollision.name,
            ),
            isTrue,
          );
        } finally {
          srcIsar?.close();
          destIsar?.close();
          if (dirSrc.existsSync()) await dirSrc.delete(recursive: true);
          if (dirDest.existsSync()) await dirDest.delete(recursive: true);
        }
      },
    );
  });
}
