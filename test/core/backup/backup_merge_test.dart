import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/backup/backup_exporter.dart';
import 'package:attend_iq/core/backup/backup_importer.dart';
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
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void _throwBeforeCommit(Isar _) {
  throw StateError('Simulated pre-commit failure for rollback verification');
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

Future<Isar> _openTestIsar(Directory dir, {required String name}) {
  return Isar.openAsync(
    schemas: appIsarSchemas,
    directory: dir.path,
    name: name,
  );
}

SemesterLocal _makeSemester({
  required int id,
  String? serverId,
  String name = 'Fall 2026',
  DateTime? startDate,
  DateTime? endDate,
  bool isActive = true,
  String status = SemesterLocal.statusActive,
  bool isDeleted = false,
  required DateTime ts,
}) {
  return SemesterLocal()
    ..id = id
    ..serverId = serverId
    ..name = name
    ..startDate = startDate ?? DateTime.utc(2026, 8, 1)
    ..endDate = endDate ?? DateTime.utc(2026, 12, 20)
    ..requiredAttendanceRate = 75.0
    ..isActive = isActive
    ..status = status
    ..createdAt = ts
    ..updatedAt = ts
    ..isDeleted = isDeleted;
}

SubjectLocal _makeSubject({
  required int id,
  String? serverId,
  required int semesterId,
  String name = 'Algorithms',
  String code = 'CS301',
  String type = 'THEORY',
  bool isDeleted = false,
  required DateTime ts,
}) {
  return SubjectLocal()
    ..id = id
    ..serverId = serverId
    ..semesterId = semesterId
    ..name = name
    ..code = code
    ..credits = 4
    ..attendanceTarget = 75.0
    ..color = '#2563EB'
    ..type = type
    ..createdAt = ts
    ..updatedAt = ts
    ..isDeleted = isDeleted;
}

Map<String, dynamic> _emptyBackupMap({int version = 2}) {
  final ts = DateTime.utc(2026, 9, 1, 8, 0).toIso8601String();
  return <String, dynamic>{
    'metadata': <String, dynamic>{
      'appVersion': '1.0.0',
      'backupVersion': version,
      'exportedAt': ts,
    },
    'userPreferences': <Map<String, dynamic>>[],
    'semesters': <Map<String, dynamic>>[],
    'subjects': <Map<String, dynamic>>[],
    'timetable': <Map<String, dynamic>>[],
    'events': <Map<String, dynamic>>[],
    'weeklyRules': <Map<String, dynamic>>[],
    'occurrences': <Map<String, dynamic>>[],
    'attendance': <Map<String, dynamic>>[],
    'scheduleExceptions': <Map<String, dynamic>>[],
    'academicEvents': <Map<String, dynamic>>[],
    'tasks': <Map<String, dynamic>>[],
    'notifications': <Map<String, dynamic>>[],
    if (version >= 2) 'migrationAudits': <Map<String, dynamic>>[],
  };
}

void main() {
  setUpAll(() async {
    final nativeLibPath = await _resolveIsarNativeLibraryPath();
    await Isar.initialize(nativeLibPath);
  });

  group('BUG-006: Backup Merge FK Integrity, Deduplication & Safeguards', () {
    test(
      '1. Skips required-parent orphans on Merge with durable audit and zero raw FK leakage',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_skip_req_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_skip_req');
          final ts = DateTime.utc(2026, 9, 1, 9, 0);

          await isar.writeAsync((db) {
            db.semesterLocals.put(
              _makeSemester(id: 1, serverId: 'dest_sem_1', ts: ts),
            );
            db.subjectLocals.put(
              _makeSubject(
                id: 1,
                serverId: 'dest_sub_1',
                semesterId: 1,
                name: 'Existing Subject',
                code: 'EXIST101',
                ts: ts,
              ),
            );
          });

          final backup = _emptyBackupMap();
          // Intentionally omit semesters and subjects in backup -> IDs 888/999 unmapped!
          (backup['subjects'] as List).add(<String, dynamic>{
            'id': 50,
            'serverId': 'orphan_sub_50',
            'semesterId': 999,
            'name': 'Orphan Subject',
            'code': 'ORPH500',
            'credits': 3,
            'attendanceTarget': 75.0,
            'color': '#EF4444',
            'type': 'THEORY',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['timetable'] as List).add(<String, dynamic>{
            'id': 51,
            'serverId': 'orphan_tpl_51',
            'subjectId': 888,
            'weekday': 1,
            'startTime': '09:00',
            'endTime': '10:00',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['events'] as List).add(<String, dynamic>{
            'id': 52,
            'serverId': 'orphan_ev_52',
            'subjectId': 888,
            'date': ts.toIso8601String(),
            'startTime': '09:00',
            'endTime': '10:00',
            'eventType': 'REGULAR_CLASS',
            'status': 'PRESENT',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['weeklyRules'] as List).add(<String, dynamic>{
            'id': 53,
            'serverId': 'orphan_rule_53',
            'subjectId': 888,
            'dayOfWeek': 2,
            'startTime': '10:00',
            'endTime': '11:00',
            'type': 'THEORY',
            'isActive': true,
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['occurrences'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 54,
              'serverId': 'orphan_occ_reg_54',
              'date': DateTime.utc(2026, 9, 2).toIso8601String(),
              'subjectId': 888,
              'title': 'Orphan Regular',
              'startTime': '11:00',
              'endTime': '12:00',
              'type': 'REGULAR_CLASS',
              'status': 'UPCOMING',
              'createdFrom': 'MANUAL',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 55,
              'serverId': 'orphan_occ_extra_55',
              'date': DateTime.utc(2026, 9, 3).toIso8601String(),
              'subjectId': 888,
              'title': 'Orphan Extra',
              'startTime': '13:00',
              'endTime': '14:00',
              'type': 'EXTRA_CLASS',
              'status': 'UPCOMING',
              'createdFrom': 'MANUAL',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);
          (backup['scheduleExceptions'] as List).add(<String, dynamic>{
            'id': 56,
            'serverId': 'orphan_exc_56',
            'date': DateTime.utc(2026, 9, 4).toIso8601String(),
            'subjectId': 888,
            'type': 'CANCELLED_CLASS',
            'title': 'Cancelled Orphan',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['attendance'] as List).add(<String, dynamic>{
            'id': 57,
            'serverId': 'orphan_att_57',
            'occurrenceId': 54,
            'eventId': 54,
            'subjectId': 888,
            'status': 'PRESENT',
            'markedAt': ts.toIso8601String(),
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['notifications'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 60,
              'title': 'Orphan Slot Notif',
              'body': 'Body',
              'type': 'CLASS_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 2, 8, 55).toIso8601String(),
              'relatedId':
                  'slot:20260902|sub:888|REGULAR_CLASS|11:00-12:00|rule:53',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 61,
              'title': 'Orphan Occ Notif',
              'body': 'Body',
              'type': 'CLASS_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 2, 9, 55).toIso8601String(),
              'relatedId': 'occ:54',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 62,
              'title': 'Orphan Sub Notif',
              'body': 'Body',
              'type': 'LOW_ATTENDANCE_ALERT',
              'scheduledTime':
                  DateTime.utc(2026, 9, 2, 10, 0).toIso8601String(),
              'relatedId': 'sub:888',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 63,
              'title': 'Orphan Task Notif',
              'body': 'Body',
              'type': 'ASSIGNMENT_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 2, 11, 0).toIso8601String(),
              'relatedId': 'task:900',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 64,
              'title': 'Orphan AE 1d Notif',
              'body': 'Body',
              'type': 'CLASS_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 2, 12, 0).toIso8601String(),
              'relatedId': 'ae_1d:901',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 65,
              'title': 'Orphan AE 30m Notif',
              'body': 'Body',
              'type': 'CLASS_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 2, 13, 0).toIso8601String(),
              'relatedId': 'ae_30m:901',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 66,
              'title': 'Orphan Legacy Numeric Sub Notif',
              'body': 'Body',
              'type': 'ATTENDANCE_WARNING',
              'scheduledTime':
                  DateTime.utc(2026, 9, 2, 14, 0).toIso8601String(),
              'relatedId': '888',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 67,
              'title': 'Orphan Legacy Numeric Task Notif',
              'body': 'Body',
              'type': 'ASSIGNMENT_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 2, 15, 0).toIso8601String(),
              'relatedId': '900',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 68,
              'title': 'Orphan Legacy Numeric Class Notif',
              'body': 'Body',
              'type': 'CLASS_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 2, 16, 0).toIso8601String(),
              'relatedId': '54',
              'isRead': false,
            },
          ]);

          final importer = BackupImporter(isar);
          final jsonPayload = jsonEncode(backup);
          await importer.importData(
            jsonPayload,
            strategy: ImportStrategy.merge,
          );

          // None of the orphans should be inserted or attached to existing subject 1.
          expect(isar.semesterLocals.count(), equals(1));
          expect(isar.subjectLocals.count(), equals(1));
          expect(isar.subjectLocals.get(1)!.code, equals('EXIST101'));
          expect(isar.timetableTemplateLocals.count(), equals(0));
          expect(isar.eventLocals.count(), equals(0));
          expect(isar.weeklyScheduleRuleLocals.count(), equals(0));
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(0));
          expect(isar.scheduleExceptionLocals.count(), equals(0));
          expect(isar.attendanceRecordLocals.count(), equals(0));
          expect(isar.notificationItems.count(), equals(0));

          final audits = isar.migrationAuditRecordLocals
              .where()
              .findAll()
              .where((a) => a.kind == BackupImporter.skippedMergeAuditKind)
              .toList();
          expect(audits, hasLength(17));
          expect(
            audits.where((a) => a.diagnosticDetails!.contains('888')).length,
            greaterThan(0),
          );
          expect(
            audits.any((a) => a.diagnosticDetails!.contains('999')),
            isTrue,
          );

          // Repeating Merge does not duplicate skipped-record audits.
          await importer.importData(
            jsonPayload,
            strategy: ImportStrategy.merge,
          );
          expect(isar.migrationAuditRecordLocals.count(), equals(17));
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '2. Optional subject FKs follow Safer Alternative: null preserved, unmapped positive ID skipped + audited',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_opt_sub_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_opt_sub');
          final ts = DateTime.utc(2026, 9, 5, 9, 0);

          final backup = _emptyBackupMap();
          (backup['tasks'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'serverId': 'task_null_sub',
              'subjectId': null,
              'title': 'General Study Task',
              'startDate': ts.toIso8601String(),
              'dueDate': ts.add(const Duration(days: 2)).toIso8601String(),
              'priority': 'HIGH',
              'taskType': 'ASSIGNMENT',
              'status': 'PENDING',
              'reminder': 'NONE',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 2,
              'serverId': 'task_unmapped_sub',
              'subjectId': 777,
              'title': 'Linked Subject Task',
              'startDate': ts.toIso8601String(),
              'dueDate': ts.add(const Duration(days: 3)).toIso8601String(),
              'priority': 'MEDIUM',
              'taskType': 'ASSIGNMENT',
              'status': 'PENDING',
              'reminder': 'NONE',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);

          (backup['scheduleExceptions'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'serverId': 'exc_holiday_null',
              'date': DateTime.utc(2026, 9, 10).toIso8601String(),
              'subjectId': null,
              'type': 'HOLIDAY',
              'title': 'Campus Holiday',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 2,
              'serverId': 'exc_exam_unmapped',
              'date': DateTime.utc(2026, 9, 11).toIso8601String(),
              'subjectId': 777,
              'type': 'EXAM',
              'title': 'Unmapped Midterm Exception',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 3,
              'serverId': 'exc_event_unmapped',
              'date': DateTime.utc(2026, 9, 12).toIso8601String(),
              'subjectId': 777,
              'type': 'EVENT',
              'title': 'Unmapped Lab Symposium Exception',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);

          (backup['occurrences'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'serverId': 'occ_exam_null',
              'date': DateTime.utc(2026, 9, 14).toIso8601String(),
              'subjectId': null,
              'title': 'General Convocation',
              'startTime': '10:00',
              'endTime': '12:00',
              'type': 'EVENT',
              'status': 'UPCOMING',
              'createdFrom': 'MANUAL',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 2,
              'serverId': 'occ_exam_unmapped',
              'date': DateTime.utc(2026, 9, 15).toIso8601String(),
              'subjectId': 777,
              'title': 'Subject Exam',
              'startTime': '09:00',
              'endTime': '11:00',
              'type': 'EXAM',
              'status': 'UPCOMING',
              'createdFrom': 'MANUAL',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 3,
              'serverId': 'occ_event_unmapped',
              'date': DateTime.utc(2026, 9, 16).toIso8601String(),
              'subjectId': 777,
              'title': 'Subject Workshop',
              'startTime': '14:00',
              'endTime': '16:00',
              'type': 'EVENT',
              'status': 'UPCOMING',
              'createdFrom': 'MANUAL',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);

          await BackupImporter(isar).importData(
            jsonEncode(backup),
            strategy: ImportStrategy.merge,
          );

          final tasks = isar.academicTaskLocals.where().findAll();
          expect(tasks, hasLength(1));
          expect(tasks.single.title, equals('General Study Task'));
          expect(tasks.single.subjectId, isNull);

          final exceptions = isar.scheduleExceptionLocals.where().findAll();
          expect(exceptions, hasLength(1));
          expect(exceptions.single.title, equals('Campus Holiday'));
          expect(exceptions.single.subjectId, isNull);

          final occs = isar.dailyScheduleOccurrenceLocals.where().findAll();
          expect(occs, hasLength(1));
          expect(occs.single.title, equals('General Convocation'));
          expect(occs.single.subjectId, isNull);

          final skipAudits = isar.migrationAuditRecordLocals
              .where()
              .findAll()
              .where((a) => a.kind == BackupImporter.skippedMergeAuditKind)
              .toList();
          expect(skipAudits, hasLength(5));
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '3. Attendance with valid subject and unmapped occurrenceId sets occurrenceId=null, eventId=destLegacyEventId??0, and audits cleanly',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_att_unmap_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_att_unmap');
          final ts = DateTime.utc(2026, 9, 1, 9, 0);

          // Pre-seed destination with padding IDs so imported subject/event get offset PKs.
          await isar.writeAsync((db) {
            db.semesterLocals.putAll(<SemesterLocal>[
              _makeSemester(
                id: 1,
                serverId: 'pad_sem',
                name: 'Pad Sem',
                startDate: DateTime.utc(2025, 1, 1),
                endDate: DateTime.utc(2025, 5, 1),
                isActive: false,
                status: SemesterLocal.statusArchived,
                ts: ts,
              ),
              _makeSemester(
                id: 2,
                serverId: 'pad_sem_2',
                name: 'Pad 2',
                isActive: false,
                status: SemesterLocal.statusDraft,
                startDate: DateTime.utc(2025, 6, 1),
                endDate: DateTime.utc(2025, 10, 1),
                ts: ts,
              ),
            ]);
            db.eventLocals.put(
              EventLocal()
                ..id = 10
                ..serverId = 'pad_ev_10'
                ..subjectId = 1
                ..date = DateTime.utc(2025, 2, 1)
                ..startTime = '08:00'
                ..endTime = '09:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });

          final backup = _emptyBackupMap();
          (backup['semesters'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'src_sem_1',
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
          });
          (backup['subjects'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'src_sub_1',
            'semesterId': 1,
            'name': 'Systems',
            'code': 'SYS201',
            'credits': 4,
            'attendanceTarget': 75.0,
            'color': '#2563EB',
            'type': 'THEORY',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          // Mapped legacy event srcId=5 (will get dest id > 10)
          (backup['events'] as List).add(<String, dynamic>{
            'id': 5,
            'serverId': 'src_ev_5',
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
          });
          // Attendance A: explicit unmapped occurrenceId 999, no legacy event -> eventId=0
          // Attendance B: explicit unmapped occurrenceId 998, mapped legacyEventId 5 -> eventId=destLegacyEvId
          (backup['attendance'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'serverId': 'att_unmapped_no_leg',
              'occurrenceId': 999,
              'legacyEventId': null,
              'eventId': 999,
              'subjectId': 1,
              'status': 'PRESENT',
              'markedAt': DateTime.utc(2026, 9, 6).toIso8601String(),
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 2,
              'serverId': 'att_unmapped_with_leg',
              'occurrenceId': 998,
              'legacyEventId': 5,
              'eventId': 998,
              'subjectId': 1,
              'status': 'ABSENT',
              'markedAt': DateTime.utc(2026, 9, 7).toIso8601String(),
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);

          final importer = BackupImporter(isar);
          final jsonPayload = jsonEncode(backup);
          await importer.importData(
            jsonPayload,
            strategy: ImportStrategy.merge,
          );

          final destSub =
              isar.subjectLocals.where().codeEqualTo('SYS201').findFirst()!;
          final destEv =
              isar.eventLocals.where().serverIdEqualTo('src_ev_5').findFirst()!;
          expect(destEv.id, greaterThan(5));

          final attA = isar.attendanceRecordLocals
              .where()
              .serverIdEqualTo('att_unmapped_no_leg')
              .findFirst()!;
          expect(attA.subjectId, equals(destSub.id));
          expect(attA.occurrenceId, isNull);
          expect(attA.legacyEventId, isNull);
          expect(attA.eventId, equals(0));

          final attB = isar.attendanceRecordLocals
              .where()
              .serverIdEqualTo('att_unmapped_with_leg')
              .findFirst()!;
          expect(attB.subjectId, equals(destSub.id));
          expect(attB.occurrenceId, isNull);
          expect(attB.legacyEventId, equals(destEv.id));
          expect(attB.eventId, equals(destEv.id));

          final audits = isar.migrationAuditRecordLocals.where().findAll();
          final auditA = audits.firstWhere(
            (a) => a.attendanceRecordId == attA.id,
          );
          expect(
            auditA.kind,
            equals(MigrationAuditKind.missingOccurrenceTarget.name),
          );
          expect(auditA.sourceOccurrenceId, isNull);
          expect(
            auditA.diagnosticDetails,
            contains('"sourceOccurrenceId":999'),
          );
          expect(auditA.diagnosticDetails, contains('"sourceEventId":999'));

          final auditB = audits.firstWhere(
            (a) => a.attendanceRecordId == attB.id,
          );
          expect(
            auditB.kind,
            equals(MigrationAuditKind.missingOccurrenceTarget.name),
          );
          expect(auditB.legacyEventId, equals(destEv.id));
          expect(
            auditB.diagnosticDetails,
            contains('"sourceOccurrenceId":998'),
          );
          expect(auditB.diagnosticDetails, contains('"sourceLegacyEventId":5'));

          // Repeated Merge and startup migration keep counts and unresolved state intact.
          final attCount = isar.attendanceRecordLocals.count();
          final auditCount = isar.migrationAuditRecordLocals.count();
          await importer.importData(
            jsonPayload,
            strategy: ImportStrategy.merge,
          );
          await migrateLegacyTimetableAndEvents(isar);
          expect(isar.attendanceRecordLocals.count(), equals(attCount));
          expect(isar.migrationAuditRecordLocals.count(), equals(auditCount));
          expect(
            isar.attendanceRecordLocals
                .where()
                .serverIdEqualTo('att_unmapped_no_leg')
                .findFirst()!
                .occurrenceId,
            isNull,
          );
          expect(
            isar.attendanceRecordLocals
                .where()
                .serverIdEqualTo('att_unmapped_with_leg')
                .findFirst()!
                .occurrenceId,
            isNull,
          );
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '4. Repeated Merge across ALL 13 collections is strictly idempotent with valid remapped FKs',
      () async {
        final dirSrc =
            await Directory.systemTemp.createTemp('bug006_all13_src_');
        final dirDest =
            await Directory.systemTemp.createTemp('bug006_all13_dest_');
        Isar? srcIsar;
        Isar? destIsar;
        try {
          srcIsar = await _openTestIsar(dirSrc, name: 'src_all13');
          destIsar = await _openTestIsar(dirDest, name: 'dest_all13');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);
          final monday = DateTime.utc(2026, 9, 7);

          await srcIsar.writeAsync((db) {
            db.userPreferencesLocals.put(
              UserPreferencesLocal()
                ..id = 1
                ..serverId = 'src_pref'
                ..themeMode = 'dark'
                ..defaultAttendanceTarget = 80.0
                ..classReminderOffset = 10
                ..enableNotifications = true
                ..enableAttendanceWarnings = true
                ..weeklyReportEnabled = false
                ..updatedAt = ts,
            );
            db.semesterLocals.put(
              _makeSemester(
                id: 1,
                serverId: 'src_sem',
                name: 'Sem Src',
                ts: ts,
              ),
            );
            db.subjectLocals.put(
              _makeSubject(
                id: 1,
                serverId: 'src_sub',
                semesterId: 1,
                name: 'Distributed Systems',
                code: 'DS401',
                ts: ts,
              ),
            );
            db.timetableTemplateLocals.put(
              TimetableTemplateLocal()
                ..id = 1
                ..serverId = 'src_tpl'
                ..subjectId = 1
                ..weekday = monday.weekday
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.eventLocals.put(
              EventLocal()
                ..id = 1
                ..serverId = 'src_ev'
                ..subjectId = 1
                ..date = monday
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.weeklyScheduleRuleLocals.put(
              WeeklyScheduleRuleLocal()
                ..id = 1
                ..serverId = 'src_rule'
                ..subjectId = 1
                ..legacyTemplateId = 1
                ..dayOfWeek = monday.weekday
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..type = 'THEORY'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            final slotKey = computeCanonicalSlotKey(
              date: monday,
              subjectId: 1,
              ruleId: 1,
              startTime: '09:00',
              endTime: '10:00',
              type: 'REGULAR_CLASS',
            );
            db.dailyScheduleOccurrenceLocals.put(
              DailyScheduleOccurrenceLocal()
                ..id = 1
                ..serverId = 'src_occ'
                ..date = monday
                ..subjectId = 1
                ..ruleId = 1
                ..legacyEventId = 1
                ..slotKey = slotKey
                ..title = 'Distributed Systems'
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..type = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdFrom = 'WEEKLY_RULE'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.attendanceRecordLocals.put(
              AttendanceRecordLocal()
                ..id = 1
                ..serverId = 'src_att'
                ..occurrenceId = 1
                ..legacyEventId = 1
                ..eventId = 1
                ..subjectId = 1
                ..status = 'PRESENT'
                ..markedAt = monday
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.scheduleExceptionLocals.put(
              ScheduleExceptionLocal()
                ..id = 1
                ..serverId = 'src_exc'
                ..date = DateTime.utc(2026, 9, 10)
                ..subjectId = 1
                ..type = 'CANCELLED_CLASS'
                ..title = 'Guest Seminar'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.academicEventLocals.put(
              AcademicEventLocal()
                ..id = 1
                ..serverId = 'src_ae'
                ..title = 'DS Midterm'
                ..date = DateTime.utc(2026, 9, 20)
                ..startTime = '14:00'
                ..endTime = '16:00'
                ..type = 'EXAM'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.academicTaskLocals.put(
              AcademicTaskLocal()
                ..id = 1
                ..serverId = 'src_task'
                ..subjectId = 1
                ..title = 'Raft Lab'
                ..startDate = ts
                ..dueDate = DateTime.utc(2026, 9, 25, 17, 0)
                ..priority = 'HIGH'
                ..taskType = 'LAB_RECORD'
                ..status = 'PENDING'
                ..reminder = 'ONE_DAY'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.notificationItems.putAll(<NotificationItem>[
              NotificationItem()
                ..id = 1
                ..title = 'Class Reminder'
                ..body = 'DS at 9:00'
                ..type = 'CLASS_REMINDER'
                ..scheduledTime = DateTime.utc(2026, 9, 7, 8, 50)
                ..relatedId = NotificationRelatedKeys.forSlotKey(slotKey)
                ..isRead = false,
              NotificationItem()
                ..id = 2
                ..title = 'Midterm 1d'
                ..body = 'Tomorrow'
                ..type = 'CLASS_REMINDER'
                ..scheduledTime = DateTime.utc(2026, 9, 19, 14, 0)
                ..relatedId = NotificationRelatedKeys.forAcademicEventOneDay(1)
                ..isRead = false,
              NotificationItem()
                ..id = 3
                ..title = 'Raft Due'
                ..body = 'Submit Raft Lab'
                ..type = 'ASSIGNMENT_REMINDER'
                ..scheduledTime = DateTime.utc(2026, 9, 24, 17, 0)
                ..relatedId = NotificationRelatedKeys.forTask(1)
                ..isRead = true,
              NotificationItem()
                ..id = 4
                ..title = 'Global Alert'
                ..body = 'Welcome'
                ..type = 'GENERAL'
                ..scheduledTime = DateTime.utc(2026, 9, 2, 9, 0)
                ..relatedId = null
                ..isRead = false,
            ]);
            db.migrationAuditRecordLocals.put(
              MigrationAuditRecordLocal()
                ..id = 1
                ..serverId = 'src_audit'
                ..auditKey = 'recoveredAttendance|legacy_ev:1'
                ..kind = MigrationAuditKind.recoveredAttendance.name
                ..attendanceRecordId = 1
                ..legacyEventId = 1
                ..sourceEventId = 1
                ..occurrenceId = 1
                ..subjectId = 1
                ..slotKey = slotKey
                ..status = 'PRESENT'
                ..eventDate = monday
                ..reason = 'Recovered'
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });

          // Pre-populate destination with higher offset records so all PKs shift!
          await destIsar.writeAsync((db) {
            for (var i = 1; i <= 3; i++) {
              db.semesterLocals.put(
                _makeSemester(
                  id: i,
                  serverId: 'dest_pad_sem_$i',
                  name: 'Dest Sem $i',
                  startDate: DateTime.utc(2024, i, 1),
                  endDate: DateTime.utc(2024, i, 28),
                  isActive: i == 1,
                  status: i == 1
                      ? SemesterLocal.statusActive
                      : SemesterLocal.statusArchived,
                  ts: ts,
                ),
              );
              db.subjectLocals.put(
                _makeSubject(
                  id: i,
                  serverId: 'dest_pad_sub_$i',
                  semesterId: i,
                  name: 'Dest Sub $i',
                  code: 'DST$i',
                  ts: ts,
                ),
              );
              db.academicEventLocals.put(
                AcademicEventLocal()
                  ..id = i
                  ..serverId = 'dest_pad_ae_$i'
                  ..title = 'Dest AE $i'
                  ..date = DateTime.utc(2024, i, 15)
                  ..type = 'EVENT'
                  ..createdAt = ts
                  ..updatedAt = ts,
              );
              db.academicTaskLocals.put(
                AcademicTaskLocal()
                  ..id = i
                  ..serverId = 'dest_pad_tk_$i'
                  ..subjectId = i
                  ..title = 'Dest Task $i'
                  ..startDate = ts
                  ..dueDate = DateTime.utc(2024, i, 20)
                  ..priority = 'LOW'
                  ..taskType = 'ASSIGNMENT'
                  ..status = 'COMPLETED'
                  ..reminder = 'NONE'
                  ..createdAt = ts
                  ..updatedAt = ts,
              );
            }
          });

          final backupJson = jsonEncode(
            (await BackupExporter(srcIsar).exportData()).toJson(),
          );
          final importer = BackupImporter(destIsar);

          await importer.importData(backupJson, strategy: ImportStrategy.merge);

          final countsAfterFirst = <String, int>{
            'prefs': destIsar.userPreferencesLocals.count(),
            'sem': destIsar.semesterLocals.count(),
            'sub': destIsar.subjectLocals.count(),
            'tpl': destIsar.timetableTemplateLocals.count(),
            'ev': destIsar.eventLocals.count(),
            'rule': destIsar.weeklyScheduleRuleLocals.count(),
            'occ': destIsar.dailyScheduleOccurrenceLocals.count(),
            'att': destIsar.attendanceRecordLocals.count(),
            'exc': destIsar.scheduleExceptionLocals.count(),
            'ae': destIsar.academicEventLocals.count(),
            'task': destIsar.academicTaskLocals.count(),
            'notif': destIsar.notificationItems.count(),
            'audit': destIsar.migrationAuditRecordLocals.count(),
          };
          expect(countsAfterFirst['prefs'], equals(1));
          expect(countsAfterFirst['sem'], equals(4));
          expect(countsAfterFirst['sub'], equals(4));
          expect(countsAfterFirst['tpl'], equals(1));
          expect(countsAfterFirst['ev'], equals(1));
          expect(countsAfterFirst['rule'], equals(1));
          expect(countsAfterFirst['occ'], equals(1));
          expect(countsAfterFirst['att'], equals(1));
          expect(countsAfterFirst['exc'], equals(1));
          expect(countsAfterFirst['ae'], equals(4));
          expect(countsAfterFirst['task'], equals(4));
          expect(countsAfterFirst['notif'], equals(4));
          expect(countsAfterFirst['audit'], equals(1));

          // Verify shifted PKs and accurate FKs!
          final impSem = destIsar.semesterLocals
              .where()
              .serverIdEqualTo('src_sem')
              .findFirst()!;
          final impSub = destIsar.subjectLocals
              .where()
              .serverIdEqualTo('src_sub')
              .findFirst()!;
          final impRule = destIsar.weeklyScheduleRuleLocals
              .where()
              .serverIdEqualTo('src_rule')
              .findFirst()!;
          final impOcc = destIsar.dailyScheduleOccurrenceLocals
              .where()
              .serverIdEqualTo('src_occ')
              .findFirst()!;
          final impAtt = destIsar.attendanceRecordLocals
              .where()
              .serverIdEqualTo('src_att')
              .findFirst()!;
          final impExc = destIsar.scheduleExceptionLocals
              .where()
              .serverIdEqualTo('src_exc')
              .findFirst()!;
          final impAe = destIsar.academicEventLocals
              .where()
              .serverIdEqualTo('src_ae')
              .findFirst()!;
          final impTask = destIsar.academicTaskLocals
              .where()
              .serverIdEqualTo('src_task')
              .findFirst()!;
          expect(impSub.semesterId, equals(impSem.id));
          expect(impRule.subjectId, equals(impSub.id));
          expect(impOcc.subjectId, equals(impSub.id));
          expect(impOcc.ruleId, equals(impRule.id));
          expect(impAtt.subjectId, equals(impSub.id));
          expect(impAtt.occurrenceId, equals(impOcc.id));
          expect(impExc.subjectId, equals(impSub.id));
          expect(impTask.subjectId, equals(impSub.id));

          final aeNotif = destIsar.notificationItems
              .where()
              .titleContains('Midterm 1d')
              .findFirst()!;
          expect(
            aeNotif.relatedId,
            equals(NotificationRelatedKeys.forAcademicEventOneDay(impAe.id)),
          );
          final taskNotif = destIsar.notificationItems
              .where()
              .titleContains('Raft Due')
              .findFirst()!;
          expect(
            taskNotif.relatedId,
            equals(NotificationRelatedKeys.forTask(impTask.id)),
          );

          // Repeat Merge 2x -> exact zero duplicates across ALL 13 collections!
          await importer.importData(backupJson, strategy: ImportStrategy.merge);
          await importer.importData(backupJson, strategy: ImportStrategy.merge);

          expect(
            destIsar.userPreferencesLocals.count(),
            countsAfterFirst['prefs'],
          );
          expect(destIsar.semesterLocals.count(), countsAfterFirst['sem']);
          expect(destIsar.subjectLocals.count(), countsAfterFirst['sub']);
          expect(
            destIsar.timetableTemplateLocals.count(),
            countsAfterFirst['tpl'],
          );
          expect(destIsar.eventLocals.count(), countsAfterFirst['ev']);
          expect(
            destIsar.weeklyScheduleRuleLocals.count(),
            countsAfterFirst['rule'],
          );
          expect(
            destIsar.dailyScheduleOccurrenceLocals.count(),
            countsAfterFirst['occ'],
          );
          expect(
            destIsar.attendanceRecordLocals.count(),
            countsAfterFirst['att'],
          );
          expect(
            destIsar.scheduleExceptionLocals.count(),
            countsAfterFirst['exc'],
          );
          expect(destIsar.academicEventLocals.count(), countsAfterFirst['ae']);
          expect(destIsar.academicTaskLocals.count(), countsAfterFirst['task']);
          expect(destIsar.notificationItems.count(), countsAfterFirst['notif']);
          expect(
            destIsar.migrationAuditRecordLocals.count(),
            countsAfterFirst['audit'],
          );
        } finally {
          srcIsar?.close();
          destIsar?.close();
          if (dirSrc.existsSync()) await dirSrc.delete(recursive: true);
          if (dirDest.existsSync()) await dirDest.delete(recursive: true);
        }
      },
    );

    test(
      '5. Legitimate distinct records are NOT falsely merged (same-title events at different times, tasks with different subjects/dueDates)',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_distinct_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_distinct');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);

          final backup = _emptyBackupMap();
          (backup['semesters'] as List).add(<String, dynamic>{
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
          });
          (backup['subjects'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'serverId': 'sub_1',
              'semesterId': 1,
              'name': 'Physics',
              'code': 'PHY101',
              'credits': 3,
              'attendanceTarget': 75.0,
              'color': '#2563EB',
              'type': 'THEORY',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 2,
              'serverId': 'sub_2',
              'semesterId': 1,
              'name': 'Chemistry',
              'code': 'CHM101',
              'credits': 3,
              'attendanceTarget': 75.0,
              'color': '#10B981',
              'type': 'THEORY',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);

          // Three same-title AcademicEvents: two different times same day + one different date.
          (backup['academicEvents'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'serverId': null,
              'title': 'Seminar',
              'date': DateTime.utc(2026, 9, 15).toIso8601String(),
              'startTime': '09:00',
              'endTime': '10:00',
              'type': 'EVENT',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 2,
              'serverId': null,
              'title': 'Seminar',
              'date': DateTime.utc(2026, 9, 15).toIso8601String(),
              'startTime': '14:00',
              'endTime': '15:00',
              'type': 'EVENT',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 3,
              'serverId': null,
              'title': 'Seminar',
              'date': DateTime.utc(2026, 9, 16).toIso8601String(),
              'startTime': '09:00',
              'endTime': '10:00',
              'type': 'EVENT',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);

          // Four same-title AcademicTasks differing by subjectId, dueDate, or taskType.
          (backup['tasks'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'serverId': null,
              'subjectId': 1,
              'title': 'Lab Report',
              'startDate': ts.toIso8601String(),
              'dueDate': DateTime.utc(2026, 9, 20, 17, 0).toIso8601String(),
              'priority': 'HIGH',
              'taskType': 'LAB_RECORD',
              'status': 'PENDING',
              'reminder': 'NONE',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 2,
              'serverId': null,
              'subjectId': 2,
              'title': 'Lab Report',
              'startDate': ts.toIso8601String(),
              'dueDate': DateTime.utc(2026, 9, 20, 17, 0).toIso8601String(),
              'priority': 'HIGH',
              'taskType': 'LAB_RECORD',
              'status': 'PENDING',
              'reminder': 'NONE',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 3,
              'serverId': null,
              'subjectId': 1,
              'title': 'Lab Report',
              'startDate': ts.toIso8601String(),
              'dueDate': DateTime.utc(2026, 9, 27, 17, 0).toIso8601String(),
              'priority': 'HIGH',
              'taskType': 'LAB_RECORD',
              'status': 'PENDING',
              'reminder': 'NONE',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 4,
              'serverId': null,
              'subjectId': null,
              'title': 'Lab Report',
              'startDate': ts.toIso8601String(),
              'dueDate': DateTime.utc(2026, 9, 20, 17, 0).toIso8601String(),
              'priority': 'HIGH',
              'taskType': 'ASSIGNMENT',
              'status': 'PENDING',
              'reminder': 'NONE',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);

          // Same-date exceptions with distinct types/titles/subjects.
          (backup['scheduleExceptions'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'serverId': null,
              'date': DateTime.utc(2026, 9, 18).toIso8601String(),
              'subjectId': 1,
              'type': 'EXAM',
              'title': 'Quiz 1',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 2,
              'serverId': null,
              'date': DateTime.utc(2026, 9, 18).toIso8601String(),
              'subjectId': 1,
              'type': 'EXAM',
              'title': 'Quiz 2',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);

          // Distinct templates and legacy events on same weekday/day.
          (backup['timetable'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'serverId': null,
              'subjectId': 1,
              'weekday': 1,
              'startTime': '09:00',
              'endTime': '10:00',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            <String, dynamic>{
              'id': 2,
              'serverId': null,
              'subjectId': 1,
              'weekday': 1,
              'startTime': '11:00',
              'endTime': '12:00',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);

          (backup['notifications'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'title': 'Global Notice A',
              'body': 'A',
              'type': 'GENERAL',
              'scheduledTime':
                  DateTime.utc(2026, 9, 15, 8, 0).toIso8601String(),
              'relatedId': null,
              'isRead': false,
            },
            <String, dynamic>{
              'id': 2,
              'title': 'Global Notice B',
              'body': 'B',
              'type': 'GENERAL',
              'scheduledTime':
                  DateTime.utc(2026, 9, 15, 8, 0).toIso8601String(),
              'relatedId': null,
              'isRead': false,
            },
            <String, dynamic>{
              'id': 3,
              'title': 'Task Morning',
              'body': 'Morning',
              'type': 'ASSIGNMENT_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 19, 9, 0).toIso8601String(),
              'relatedId': 'task:1',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 4,
              'title': 'Task Evening',
              'body': 'Evening',
              'type': 'ASSIGNMENT_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 19, 18, 0).toIso8601String(),
              'relatedId': 'task:1',
              'isRead': false,
            },
          ]);

          final jsonPayload = jsonEncode(backup);
          final importer = BackupImporter(isar);
          await importer.importData(
            jsonPayload,
            strategy: ImportStrategy.merge,
          );

          expect(isar.academicEventLocals.count(), equals(3));
          expect(isar.academicTaskLocals.count(), equals(4));
          expect(isar.scheduleExceptionLocals.count(), equals(2));
          expect(isar.timetableTemplateLocals.count(), equals(2));
          expect(isar.notificationItems.count(), equals(4));

          // Re-merging null-serverId backup deduplicates identically!
          await importer.importData(
            jsonPayload,
            strategy: ImportStrategy.merge,
          );
          expect(isar.academicEventLocals.count(), equals(3));
          expect(isar.academicTaskLocals.count(), equals(4));
          expect(isar.scheduleExceptionLocals.count(), equals(2));
          expect(isar.timetableTemplateLocals.count(), equals(2));
          expect(isar.notificationItems.count(), equals(4));
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '6. Null serverId records across userPrefs/events/attendance/rules/occurrences deduplicate cleanly on repeated Merge',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_null_srv_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_null_srv');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);
          final monday = DateTime.utc(2026, 9, 7);

          final backup = _emptyBackupMap();
          (backup['userPreferences'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': null,
            'themeMode': 'light',
            'defaultAttendanceTarget': 75.0,
            'classReminderOffset': 5,
            'enableNotifications': true,
            'enableAttendanceWarnings': true,
            'weeklyReportEnabled': true,
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['semesters'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': null,
            'name': 'NullSrv Sem',
            'startDate': DateTime.utc(2026, 8, 1).toIso8601String(),
            'endDate': DateTime.utc(2026, 12, 20).toIso8601String(),
            'requiredAttendanceRate': 75.0,
            'isActive': true,
            'status': SemesterLocal.statusActive,
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['subjects'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': null,
            'semesterId': 1,
            'name': 'Linear Algebra',
            'code': 'MTH201',
            'credits': 4,
            'attendanceTarget': 75.0,
            'color': '#2563EB',
            'type': 'THEORY',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['events'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': null,
            'subjectId': 1,
            'date': monday.toIso8601String(),
            'startTime': '09:00',
            'endTime': '10:00',
            'eventType': 'REGULAR_CLASS',
            'status': 'PRESENT',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['weeklyRules'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': null,
            'subjectId': 1,
            'dayOfWeek': monday.weekday,
            'startTime': '09:00',
            'endTime': '10:00',
            'type': 'THEORY',
            'isActive': true,
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['occurrences'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': null,
            'date': monday.toIso8601String(),
            'subjectId': 1,
            'ruleId': 1,
            'legacyEventId': 1,
            'title': 'Linear Algebra',
            'startTime': '09:00',
            'endTime': '10:00',
            'type': 'REGULAR_CLASS',
            'status': 'PRESENT',
            'createdFrom': 'WEEKLY_RULE',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['attendance'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': null,
            'occurrenceId': 1,
            'legacyEventId': 1,
            'eventId': 1,
            'subjectId': 1,
            'status': 'PRESENT',
            'markedAt': monday.toIso8601String(),
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });

          final payload = jsonEncode(backup);
          final importer = BackupImporter(isar);
          await importer.importData(payload, strategy: ImportStrategy.merge);
          await importer.importData(payload, strategy: ImportStrategy.merge);

          expect(isar.userPreferencesLocals.count(), equals(1));
          expect(isar.semesterLocals.count(), equals(1));
          expect(isar.subjectLocals.count(), equals(1));
          expect(isar.eventLocals.count(), equals(1));
          expect(isar.weeklyScheduleRuleLocals.count(), equals(1));
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(1));
          expect(isar.attendanceRecordLocals.count(), equals(1));
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '7. serverId collisions on distinct logical records re-allocate UUIDs without overwriting destination data',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_srv_col_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_srv_col');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);

          await isar.writeAsync((db) {
            db.semesterLocals.put(
              _makeSemester(
                id: 1,
                serverId: 'shared_srv',
                name: 'Existing Sem',
                startDate: DateTime.utc(2026, 1, 1),
                endDate: DateTime.utc(2026, 5, 1),
                isActive: false,
                status: SemesterLocal.statusArchived,
                ts: ts,
              ),
            );
            db.subjectLocals.put(
              _makeSubject(
                id: 1,
                serverId: 'shared_srv',
                semesterId: 1,
                name: 'Existing Subject',
                code: 'EX101',
                ts: ts,
              ),
            );
            db.academicEventLocals.put(
              AcademicEventLocal()
                ..id = 1
                ..serverId = 'shared_srv'
                ..title = 'Workshop'
                ..date = DateTime.utc(2026, 9, 10)
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..type = 'EVENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.academicTaskLocals.put(
              AcademicTaskLocal()
                ..id = 1
                ..serverId = 'shared_srv'
                ..subjectId = 1
                ..title = 'Essay'
                ..startDate = ts
                ..dueDate = DateTime.utc(2026, 9, 12)
                ..priority = 'MEDIUM'
                ..taskType = 'ASSIGNMENT'
                ..status = 'PENDING'
                ..reminder = 'NONE'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.scheduleExceptionLocals.put(
              ScheduleExceptionLocal()
                ..id = 1
                ..serverId = 'shared_srv'
                ..date = DateTime.utc(2026, 9, 14)
                ..subjectId = null
                ..type = 'HOLIDAY'
                ..title = 'Founder Day'
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });

          final backup = _emptyBackupMap();
          (backup['semesters'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'shared_srv',
            'name': 'Incoming Sem',
            'startDate': DateTime.utc(2026, 8, 1).toIso8601String(),
            'endDate': DateTime.utc(2026, 12, 20).toIso8601String(),
            'requiredAttendanceRate': 75.0,
            'isActive': true,
            'status': SemesterLocal.statusActive,
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['subjects'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'shared_srv',
            'semesterId': 1,
            'name': 'Incoming Subject',
            'code': 'IN202',
            'credits': 3,
            'attendanceTarget': 75.0,
            'color': '#10B981',
            'type': 'LAB',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          // Same-title event/task at different time/dueDate sharing collided serverId!
          (backup['academicEvents'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'shared_srv',
            'title': 'Workshop',
            'date': DateTime.utc(2026, 9, 10).toIso8601String(),
            'startTime': '14:00',
            'endTime': '15:00',
            'type': 'EVENT',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['tasks'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'shared_srv',
            'subjectId': 1,
            'title': 'Essay',
            'startDate': ts.toIso8601String(),
            'dueDate': DateTime.utc(2026, 9, 28).toIso8601String(),
            'priority': 'HIGH',
            'taskType': 'ASSIGNMENT',
            'status': 'PENDING',
            'reminder': 'NONE',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['scheduleExceptions'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'shared_srv',
            'date': DateTime.utc(2026, 9, 14).toIso8601String(),
            'subjectId': null,
            'type': 'HOLIDAY',
            'title': 'Regional Holiday',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });

          await BackupImporter(isar).importData(
            jsonEncode(backup),
            strategy: ImportStrategy.merge,
          );

          expect(isar.semesterLocals.count(), equals(2));
          expect(isar.subjectLocals.count(), equals(2));
          expect(isar.academicEventLocals.count(), equals(2));
          expect(isar.academicTaskLocals.count(), equals(2));
          expect(isar.scheduleExceptionLocals.count(), equals(2));

          // Existing holders retained 'shared_srv'; incoming copies received fresh UUIDs.
          expect(isar.semesterLocals.get(1)!.name, equals('Existing Sem'));
          expect(isar.semesterLocals.get(1)!.serverId, equals('shared_srv'));
          expect(
            isar.subjectLocals.get(1)!.code,
            equals('EX101'),
          );
          final incomingSub =
              isar.subjectLocals.where().codeEqualTo('IN202').findFirst()!;
          expect(incomingSub.serverId, isNot(equals('shared_srv')));
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '8. SubjectLocal 4-state soft-delete conflict matrix preserves active data and avoids resurrection',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_sub_matrix_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_sub_matrix');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);

          await isar.writeAsync((db) {
            db.semesterLocals.put(
              _makeSemester(id: 1, serverId: 'sem_1', ts: ts),
            );
            db.subjectLocals.putAll(<SubjectLocal>[
              // 1: Active dest (matched by active incoming)
              _makeSubject(
                id: 1,
                serverId: 'sub_act_act',
                semesterId: 1,
                name: 'Original AA',
                code: 'AA101',
                ts: ts,
              ),
              // 2: Active dest (must NOT be deleted by deleted incoming!)
              _makeSubject(
                id: 2,
                serverId: 'sub_del_act',
                semesterId: 1,
                name: 'Protected Active DA',
                code: 'DA102',
                ts: ts,
              ),
              // 3: Deleted dest (must NOT be overwritten by active incoming!)
              _makeSubject(
                id: 3,
                serverId: 'sub_act_del',
                semesterId: 1,
                name: 'Archived Deleted AD',
                code: 'AD103',
                isDeleted: true,
                ts: ts,
              ),
              // 4: Deleted dest (matched by identical deleted incoming)
              _makeSubject(
                id: 4,
                serverId: 'sub_del_del',
                semesterId: 1,
                name: 'Deleted DD',
                code: 'DD104',
                isDeleted: true,
                ts: ts,
              ),
            ]);
          });

          final backup = _emptyBackupMap();
          (backup['semesters'] as List).add(<String, dynamic>{
            'id': 10,
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
          });
          (backup['subjects'] as List).addAll(<Map<String, dynamic>>[
            // Case A: active + active -> merges into id=1
            <String, dynamic>{
              'id': 1,
              'serverId': 'sub_act_act',
              'semesterId': 10,
              'name': 'Updated AA',
              'code': 'AA101',
              'credits': 4,
              'attendanceTarget': 80.0,
              'color': '#2563EB',
              'type': 'THEORY',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            // Case B: deleted incoming + active dest (same serverId & code, no delete overwrite!)
            <String, dynamic>{
              'id': 2,
              'serverId': 'sub_del_act',
              'semesterId': 10,
              'name': 'Protected Active DA',
              'code': 'DA102',
              'credits': 4,
              'attendanceTarget': 75.0,
              'color': '#2563EB',
              'type': 'THEORY',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': true,
            },
            // Case C: active incoming + deleted dest -> creates separate active subject
            <String, dynamic>{
              'id': 3,
              'serverId': 'sub_act_del',
              'semesterId': 10,
              'name': 'Reborn Active AD',
              'code': 'AD103',
              'credits': 4,
              'attendanceTarget': 75.0,
              'color': '#2563EB',
              'type': 'THEORY',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
            // Case D: deleted incoming + deleted dest -> merges idempotently into id=4
            <String, dynamic>{
              'id': 4,
              'serverId': 'sub_del_del',
              'semesterId': 10,
              'name': 'Deleted DD',
              'code': 'DD104',
              'credits': 4,
              'attendanceTarget': 75.0,
              'color': '#2563EB',
              'type': 'THEORY',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': true,
            },
          ]);

          final payload = jsonEncode(backup);
          final importer = BackupImporter(isar);
          await importer.importData(payload, strategy: ImportStrategy.merge);

          expect(isar.subjectLocals.get(1)!.isDeleted, isFalse);
          expect(isar.subjectLocals.get(1)!.name, equals('Updated AA'));

          expect(isar.subjectLocals.get(2)!.isDeleted, isFalse);
          expect(
            isar.subjectLocals.get(2)!.name,
            equals('Protected Active DA'),
          );

          expect(isar.subjectLocals.get(3)!.isDeleted, isTrue);
          expect(
            isar.subjectLocals.get(3)!.name,
            equals('Archived Deleted AD'),
          );

          final activeAd = isar.subjectLocals
              .where()
              .codeEqualTo('AD103')
              .findAll()
              .where((s) => !s.isDeleted)
              .toList();
          expect(activeAd, hasLength(1));
          expect(activeAd.single.name, equals('Reborn Active AD'));
          expect(activeAd.single.id, isNot(equals(3)));

          final allDd =
              isar.subjectLocals.where().codeEqualTo('DD104').findAll();
          expect(allDd, hasLength(1));
          expect(allDd.single.id, equals(4));
          expect(allDd.single.isDeleted, isTrue);

          final countAfterFirst = isar.subjectLocals.count();
          await importer.importData(payload, strategy: ImportStrategy.merge);
          expect(isar.subjectLocals.count(), equals(countAfterFirst));
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '9. Preserves unresolved ambiguous/mismatch/missing audits across Merge, repeated Merge, and DB reopen',
      () async {
        final dirSrc =
            await Directory.systemTemp.createTemp('bug006_ambig_src_');
        final dirDest =
            await Directory.systemTemp.createTemp('bug006_ambig_dest_');
        Isar? srcIsar;
        Isar? destIsar;
        try {
          srcIsar = await _openTestIsar(dirSrc, name: 'src_ambig');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);

          await srcIsar.writeAsync((db) {
            db.semesterLocals.put(
              _makeSemester(id: 1, serverId: 'sem_1', ts: ts),
            );
            db.subjectLocals.putAll(<SubjectLocal>[
              _makeSubject(
                id: 1,
                serverId: 'sub_1',
                semesterId: 1,
                code: 'AMB101',
                ts: ts,
              ),
              _makeSubject(
                id: 2,
                serverId: 'sub_2',
                semesterId: 1,
                code: 'OTH102',
                ts: ts,
              ),
            ]);
            db.dailyScheduleOccurrenceLocals.put(
              DailyScheduleOccurrenceLocal()
                ..id = 40
                ..serverId = 'amb_occ_1'
                ..date = DateTime.utc(2026, 9, 4)
                ..subjectId = 1
                ..title = 'Slot 1'
                ..startTime = '15:00'
                ..endTime = '16:00'
                ..type = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdFrom = 'MANUAL'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.eventLocals.put(
              EventLocal()
                ..id = 40
                ..serverId = 'amb_ev_40'
                ..subjectId = 1
                ..date = DateTime.utc(2026, 9, 4)
                ..startTime = '13:00'
                ..endTime = '14:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            db.attendanceRecordLocals.put(
              AttendanceRecordLocal()
                ..id = 1
                ..serverId = 'amb_att_1'
                ..eventId = 40
                ..subjectId = 1
                ..status = 'PRESENT'
                ..markedAt = DateTime.utc(2026, 9, 4)
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });

          await migrateLegacyTimetableAndEvents(srcIsar);
          final backupJson = jsonEncode(
            (await BackupExporter(srcIsar).exportData()).toJson(),
          );

          destIsar = await _openTestIsar(dirDest, name: 'dest_ambig');
          await destIsar.writeAsync((db) {
            db.semesterLocals.put(
              _makeSemester(
                id: 1,
                serverId: 'dest_sem',
                name: 'Pad',
                startDate: DateTime.utc(2025, 1, 1),
                endDate: DateTime.utc(2025, 5, 1),
                isActive: false,
                status: SemesterLocal.statusArchived,
                ts: ts,
              ),
            );
          });

          final importer = BackupImporter(destIsar);
          await importer.importData(backupJson, strategy: ImportStrategy.merge);
          await importer.importData(backupJson, strategy: ImportStrategy.merge);

          // Simulate restart reopen + startup unification.
          destIsar.close();
          destIsar = await _openTestIsar(dirDest, name: 'dest_ambig');
          await migrateLegacyTimetableAndEvents(destIsar);

          final destAtt = destIsar.attendanceRecordLocals
              .where()
              .serverIdEqualTo('amb_att_1')
              .findFirst()!;
          expect(destAtt.occurrenceId, isNull);
          final destOcc1 = destIsar.dailyScheduleOccurrenceLocals
              .where()
              .serverIdEqualTo('amb_occ_1')
              .findFirst()!;
          final destEv40 = destIsar.eventLocals
              .where()
              .serverIdEqualTo('amb_ev_40')
              .findFirst()!;
          final destOccEv = destIsar.dailyScheduleOccurrenceLocals
              .where()
              .legacyEventIdEqualTo(destEv40.id)
              .findFirst()!;
          final ambAudit =
              destIsar.migrationAuditRecordLocals.where().findAll().firstWhere(
                    (a) =>
                        a.kind ==
                        MigrationAuditKind.ambiguousAttendanceCollision.name,
                  );
          expect(ambAudit.attendanceRecordId, equals(destAtt.id));
          expect(
            ambAudit.parsedCandidateOccurrenceIds.toSet(),
            equals(<int>{destOcc1.id, destOccEv.id}),
          );
          expect(destIsar.migrationAuditRecordLocals.count(), equals(1));
        } finally {
          srcIsar?.close();
          destIsar?.close();
          if (dirSrc.existsSync()) await dirSrc.delete(recursive: true);
          if (dirDest.existsSync()) await dirDest.delete(recursive: true);
        }
      },
    );

    test(
      '10. Preserves valid existing AttendanceRecordLocal.occurrenceId/eventId on v1 2x Merge and partial v2 Merge',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_keep_occ_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_keep_occ');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);
          final day = DateTime.utc(2026, 9, 8);

          // Pre-existing resolved record in destination + legacy event.
          await isar.writeAsync((db) {
            db.semesterLocals.put(
              _makeSemester(id: 1, serverId: 'sem_1', ts: ts),
            );
            db.subjectLocals.put(
              _makeSubject(
                id: 1,
                serverId: 'sub_1',
                semesterId: 1,
                code: 'CS101',
                ts: ts,
              ),
            );
            db.eventLocals.put(
              EventLocal()
                ..id = 1
                ..serverId = 'ev_1'
                ..subjectId = 1
                ..date = day
                ..startTime = '09:00'
                ..endTime = '10:00'
                ..eventType = 'REGULAR_CLASS'
                ..status = 'PRESENT'
                ..createdAt = ts
                ..updatedAt = ts,
            );
            final occ = DailyScheduleOccurrenceLocal()
              ..id = 5
              ..serverId = 'occ_5'
              ..date = day
              ..subjectId = 1
              ..legacyEventId = 1
              ..slotKey = computeCanonicalSlotKey(
                date: day,
                subjectId: 1,
                startTime: '09:00',
                endTime: '10:00',
                type: 'REGULAR_CLASS',
                legacyEventId: 1,
              )
              ..title = 'Algorithms'
              ..startTime = '09:00'
              ..endTime = '10:00'
              ..type = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdFrom = 'LEGACY_MIGRATION'
              ..createdAt = ts
              ..updatedAt = ts;
            db.dailyScheduleOccurrenceLocals.put(occ);
            db.attendanceRecordLocals.put(
              AttendanceRecordLocal()
                ..id = 20
                ..serverId = 'att_srv_preserve'
                ..occurrenceId = 5
                ..legacyEventId = 1
                ..eventId = 5
                ..subjectId = 1
                ..status = 'PRESENT'
                ..markedAt = day
                ..createdAt = ts
                ..updatedAt = ts,
            );
          });

          // Partial v2 backup with matched serverId='att_srv_preserve' and occurrenceId: null.
          final partialV2 = _emptyBackupMap(version: 2);
          (partialV2['semesters'] as List).add(<String, dynamic>{
            'id': 9,
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
          });
          (partialV2['subjects'] as List).add(<String, dynamic>{
            'id': 9,
            'serverId': 'sub_1',
            'semesterId': 9,
            'name': 'Algorithms',
            'code': 'CS101',
            'credits': 4,
            'attendanceTarget': 75.0,
            'color': '#2563EB',
            'type': 'THEORY',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (partialV2['attendance'] as List).add(<String, dynamic>{
            'id': 99,
            'serverId': 'att_srv_preserve',
            'occurrenceId': null,
            'legacyEventId': null,
            'eventId': 0,
            'subjectId': 9,
            'status': 'ABSENT',
            'markedAt': day.toIso8601String(),
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.add(const Duration(minutes: 5)).toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });

          final importer = BackupImporter(isar);
          await importer.importData(
            jsonEncode(partialV2),
            strategy: ImportStrategy.merge,
          );

          final preservedAfterV2 = isar.attendanceRecordLocals.get(20)!;
          expect(preservedAfterV2.occurrenceId, equals(5));
          expect(preservedAfterV2.eventId, equals(5));
          expect(preservedAfterV2.status, equals('ABSENT'));
          expect(isar.attendanceRecordLocals.count(), equals(1));

          // Now verify v1 backup repeated Merge twice also preserves resolution!
          final v1Backup = _emptyBackupMap(version: 1);
          (v1Backup['semesters'] as List).add(<String, dynamic>{
            'id': 2,
            'serverId': 'sem_v1',
            'name': 'V1 Sem',
            'startDate': DateTime.utc(2027, 1, 1).toIso8601String(),
            'endDate': DateTime.utc(2027, 5, 1).toIso8601String(),
            'requiredAttendanceRate': 75.0,
            'isActive': false,
            'status': SemesterLocal.statusArchived,
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (v1Backup['subjects'] as List).add(<String, dynamic>{
            'id': 3,
            'serverId': 'sub_v1',
            'semesterId': 2,
            'name': 'V1 Sub',
            'code': 'V101',
            'credits': 3,
            'attendanceTarget': 75.0,
            'color': '#2563EB',
            'type': 'THEORY',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (v1Backup['events'] as List).add(<String, dynamic>{
            'id': 12,
            'serverId': 'ev_v1',
            'subjectId': 3,
            'date': DateTime.utc(2027, 2, 10).toIso8601String(),
            'startTime': '10:00',
            'endTime': '11:00',
            'eventType': 'REGULAR_CLASS',
            'status': 'PRESENT',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (v1Backup['attendance'] as List).add(<String, dynamic>{
            'id': 40,
            'serverId': 'att_v1_res',
            'eventId': 12,
            'subjectId': 3,
            'status': 'PRESENT',
            'markedAt': DateTime.utc(2027, 2, 10).toIso8601String(),
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });

          final v1Payload = jsonEncode(v1Backup);
          await importer.importData(v1Payload, strategy: ImportStrategy.merge);
          final v1Att1 = isar.attendanceRecordLocals
              .where()
              .serverIdEqualTo('att_v1_res')
              .findFirst()!;
          expect(v1Att1.occurrenceId, isNotNull);
          final resolvedOccId = v1Att1.occurrenceId!;

          // Second Merge of exact v1 backup keeps occurrenceId intact!
          await importer.importData(v1Payload, strategy: ImportStrategy.merge);
          final v1Att2 = isar.attendanceRecordLocals
              .where()
              .serverIdEqualTo('att_v1_res')
              .findFirst()!;
          expect(v1Att2.id, equals(v1Att1.id));
          expect(v1Att2.occurrenceId, equals(resolvedOccId));
          expect(v1Att2.eventId, equals(resolvedOccId));
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '11. Notifications update title/body, preserve isRead|=incoming, preserve PK/androidId, and assign unique valid 32-bit IDs across all relatedId formats',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_notif_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_notif');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);
          final globalTime = DateTime.utc(2026, 9, 5, 9, 0);
          final schedOccTime = DateTime.utc(2026, 9, 7, 8, 50);

          await isar.writeAsync((db) {
            db.semesterLocals.put(
              _makeSemester(id: 1, serverId: 'sem_1', ts: ts),
            );
            db.subjectLocals.put(
              _makeSubject(
                id: 1,
                serverId: 'sub_1',
                semesterId: 1,
                code: 'NOTIF101',
                ts: ts,
              ),
            );
            db.notificationItems.putAll(<NotificationItem>[
              NotificationItem()
                ..id = 42
                ..androidNotificationId = 123456789
                ..title = 'Old Read Global'
                ..body = 'Old Body'
                ..type = 'GENERAL'
                ..scheduledTime = globalTime
                ..relatedId = null
                ..isRead = true,
              NotificationItem()
                ..id = 43
                ..androidNotificationId =
                    123456789 // deliberate collision on disk
                ..title = 'Old Unread Subject'
                ..body = 'Old Risk'
                ..type = 'LOW_ATTENDANCE_ALERT'
                ..scheduledTime = schedOccTime
                ..relatedId = 'sub:1'
                ..isRead = false,
            ]);
          });

          final backup = _emptyBackupMap();
          (backup['semesters'] as List).add(<String, dynamic>{
            'id': 10,
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
          });
          (backup['subjects'] as List).add(<String, dynamic>{
            'id': 10,
            'serverId': 'sub_1',
            'semesterId': 10,
            'name': 'Algorithms',
            'code': 'NOTIF101',
            'credits': 4,
            'attendanceTarget': 75.0,
            'color': '#2563EB',
            'type': 'THEORY',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['academicEvents'] as List).add(<String, dynamic>{
            'id': 7,
            'serverId': 'ae_7',
            'title': 'Exam Day',
            'date': DateTime.utc(2026, 9, 20).toIso8601String(),
            'startTime': '09:00',
            'endTime': '11:00',
            'type': 'EXAM',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['tasks'] as List).add(<String, dynamic>{
            'id': 8,
            'serverId': 'tk_8',
            'subjectId': 10,
            'title': 'Problem Set',
            'startDate': ts.toIso8601String(),
            'dueDate': DateTime.utc(2026, 9, 22).toIso8601String(),
            'priority': 'HIGH',
            'taskType': 'ASSIGNMENT',
            'status': 'PENDING',
            'reminder': 'NONE',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['occurrences'] as List).add(<String, dynamic>{
            'id': 9,
            'serverId': 'occ_9',
            'date': DateTime.utc(2026, 9, 7).toIso8601String(),
            'subjectId': 10,
            'title': 'Algorithms',
            'startTime': '09:00',
            'endTime': '10:00',
            'type': 'REGULAR_CLASS',
            'status': 'UPCOMING',
            'createdFrom': 'MANUAL',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });

          (backup['notifications'] as List).addAll(<Map<String, dynamic>>[
            // Matches #42 globally (same title/type/schedTime/null relatedId): preserves isRead=true, updates body
            <String, dynamic>{
              'id': 1,
              'title': 'Old Read Global',
              'body': 'Updated Body',
              'type': 'GENERAL',
              'scheduledTime': globalTime.toIso8601String(),
              'relatedId': '   ',
              'isRead': false,
            },
            // Matches #43 (sub:10 -> sub:1): marks read (false || true) and updates title/body
            <String, dynamic>{
              'id': 2,
              'title': 'Updated Risk Title',
              'body': 'Updated Risk Body',
              'type': 'LOW_ATTENDANCE_ALERT',
              'scheduledTime': schedOccTime.toIso8601String(),
              'relatedId': 'sub:10',
              'isRead': true,
            },
            // Additional format notifications
            <String, dynamic>{
              'id': 3,
              'title': 'Occ Notif',
              'body': 'B',
              'type': 'CLASS_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 7, 8, 45).toIso8601String(),
              'relatedId': 'occ:9',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 4,
              'title': 'AE 30m Notif',
              'body': 'B',
              'type': 'CLASS_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 20, 8, 30).toIso8601String(),
              'relatedId': 'ae_30m:7',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 5,
              'title': 'Legacy AE 1d',
              'body': 'B',
              'type': 'CLASS_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 19, 9, 0).toIso8601String(),
              'relatedId': '${100000 + 7}',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 6,
              'title': 'Legacy AE 30m',
              'body': 'B',
              'type': 'CLASS_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 20, 8, 30, 1).toIso8601String(),
              'relatedId': '${200000 + 7}',
              'isRead': false,
            },
            <String, dynamic>{
              'id': 7,
              'title': 'Legacy Task',
              'body': 'B',
              'type': 'ASSIGNMENT_REMINDER',
              'scheduledTime':
                  DateTime.utc(2026, 9, 21, 9, 0).toIso8601String(),
              'relatedId': '8',
              'isRead': false,
            },
          ]);

          await BackupImporter(isar).importData(
            jsonEncode(backup),
            strategy: ImportStrategy.merge,
          );

          final global42 = isar.notificationItems.get(42)!;
          expect(global42.body, equals('Updated Body'));
          expect(global42.isRead, isTrue);
          expect(global42.relatedId, isNull);
          expect(global42.androidNotificationId, equals(123456789));

          final risk43 = isar.notificationItems.get(43)!;
          expect(risk43.title, equals('Updated Risk Title'));
          expect(risk43.body, equals('Updated Risk Body'));
          expect(risk43.isRead, isTrue);
          expect(risk43.relatedId, equals('sub:1'));

          final destAe = isar.academicEventLocals
              .where()
              .serverIdEqualTo('ae_7')
              .findFirst()!;
          final destTask = isar.academicTaskLocals
              .where()
              .serverIdEqualTo('tk_8')
              .findFirst()!;
          final destOcc = isar.dailyScheduleOccurrenceLocals
              .where()
              .serverIdEqualTo('occ_9')
              .findFirst()!;

          final allNotifs = isar.notificationItems.where().findAll();
          expect(allNotifs, hasLength(7));
          expect(
            allNotifs.firstWhere((n) => n.title == 'Occ Notif').relatedId,
            equals('occ:${destOcc.id}'),
          );
          expect(
            allNotifs.firstWhere((n) => n.title == 'AE 30m Notif').relatedId,
            equals(
              NotificationRelatedKeys.forAcademicEventThirtyMin(destAe.id),
            ),
          );
          expect(
            allNotifs.firstWhere((n) => n.title == 'Legacy AE 1d').relatedId,
            equals(NotificationRelatedKeys.forAcademicEventOneDay(destAe.id)),
          );
          expect(
            allNotifs.firstWhere((n) => n.title == 'Legacy AE 30m').relatedId,
            equals(
              NotificationRelatedKeys.forAcademicEventThirtyMin(destAe.id),
            ),
          );
          expect(
            allNotifs.firstWhere((n) => n.title == 'Legacy Task').relatedId,
            equals(NotificationRelatedKeys.forTask(destTask.id)),
          );

          final androidIds = allNotifs
              .map((n) => n.androidNotificationId)
              .whereType<int>()
              .toList();
          expect(androidIds, hasLength(7));
          expect(androidIds.toSet(), hasLength(7));
          for (final aid in androidIds) {
            expect(NotificationItem.isValidPersistedAndroidId(aid), isTrue);
          }
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '12. Atomic transaction rollback via onBeforeCommit leaves ALL 13 collections untouched (including notification ID migration) on Merge and Replace',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_rollback_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_rollback');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);

          // Pre-seed baseline including legacy null androidNotificationId so we prove Step 14 rolls back too.
          await isar.writeAsync((db) {
            db.semesterLocals.put(
              _makeSemester(
                id: 1,
                serverId: 'base_sem',
                name: 'Base Sem',
                ts: ts,
              ),
            );
            db.subjectLocals.put(
              _makeSubject(
                id: 1,
                serverId: 'base_sub',
                semesterId: 1,
                name: 'Base Subject',
                code: 'BASE1',
                ts: ts,
              ),
            );
            db.notificationItems.put(
              NotificationItem()
                ..id = 1
                ..androidNotificationId = null
                ..title = 'Base Legacy Notif'
                ..body = 'Body'
                ..type = 'GENERAL'
                ..scheduledTime = ts
                ..isRead = false,
            );
          });

          final backup = _emptyBackupMap();
          (backup['semesters'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'new_sem',
            'name': 'Should Rollback',
            'startDate': DateTime.utc(2027, 1, 1).toIso8601String(),
            'endDate': DateTime.utc(2027, 5, 1).toIso8601String(),
            'requiredAttendanceRate': 75.0,
            'isActive': true,
            'status': SemesterLocal.statusActive,
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['subjects'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'new_sub',
            'semesterId': 1,
            'name': 'Rollback Sub',
            'code': 'RB999',
            'credits': 3,
            'attendanceTarget': 75.0,
            'color': '#2563EB',
            'type': 'THEORY',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['tasks'] as List).add(<String, dynamic>{
            'id': 1,
            'serverId': 'new_task',
            'subjectId': 999, // triggers skipped-merge audit inside tx too
            'title': 'Rollback Task',
            'startDate': ts.toIso8601String(),
            'dueDate': ts.toIso8601String(),
            'priority': 'MEDIUM',
            'taskType': 'ASSIGNMENT',
            'status': 'PENDING',
            'reminder': 'NONE',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (backup['notifications'] as List).add(<String, dynamic>{
            'id': 2,
            'title': 'New Notif',
            'body': 'New',
            'type': 'GENERAL',
            'scheduledTime': ts.toIso8601String(),
            'isRead': false,
          });

          final importer = BackupImporter(isar);
          final payload = jsonEncode(backup);

          await expectLater(
            importer.importData(
              payload,
              strategy: ImportStrategy.merge,
              onBeforeCommit: _throwBeforeCommit,
            ),
            throwsA(isA<StateError>()),
          );

          expect(isar.semesterLocals.count(), equals(1));
          expect(isar.semesterLocals.get(1)!.name, equals('Base Sem'));
          expect(isar.subjectLocals.count(), equals(1));
          expect(isar.subjectLocals.get(1)!.code, equals('BASE1'));
          expect(isar.academicTaskLocals.count(), equals(0));
          expect(isar.migrationAuditRecordLocals.count(), equals(0));
          expect(isar.notificationItems.count(), equals(1));
          // Even Step 14 legacy Android ID allocation rolled back!
          expect(isar.notificationItems.get(1)!.androidNotificationId, isNull);

          // Same guarantee for ImportStrategy.replace!
          await expectLater(
            importer.importData(
              payload,
              strategy: ImportStrategy.replace,
              onBeforeCommit: _throwBeforeCommit,
            ),
            throwsA(isA<StateError>()),
          );

          expect(isar.semesterLocals.count(), equals(1));
          expect(isar.semesterLocals.get(1)!.name, equals('Base Sem'));
          expect(isar.subjectLocals.count(), equals(1));
          expect(isar.notificationItems.count(), equals(1));
          expect(isar.notificationItems.get(1)!.androidNotificationId, isNull);
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );

    test(
      '13. ImportStrategy.replace preserves exact legacy v1 and canonical v2 restore behavior',
      () async {
        final dir = await Directory.systemTemp.createTemp('bug006_replace_');
        Isar? isar;
        try {
          isar = await _openTestIsar(dir, name: 'dest_replace');
          final ts = DateTime.utc(2026, 9, 1, 8, 0);

          await isar.writeAsync((db) {
            db.semesterLocals.put(
              _makeSemester(id: 99, serverId: 'old_sem', name: 'Old', ts: ts),
            );
          });

          final v1 = _emptyBackupMap(version: 1);
          (v1['semesters'] as List).add(<String, dynamic>{
            'id': 3,
            'serverId': 'rep_sem_3',
            'name': 'Replace V1 Sem',
            'startDate': DateTime.utc(2026, 8, 1).toIso8601String(),
            'endDate': DateTime.utc(2026, 12, 20).toIso8601String(),
            'requiredAttendanceRate': 75.0,
            'isActive': true,
            'status': SemesterLocal.statusActive,
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (v1['subjects'] as List).add(<String, dynamic>{
            'id': 4,
            'serverId': 'rep_sub_4',
            'semesterId': 3,
            'name': 'Compilers',
            'code': 'CS410',
            'credits': 4,
            'attendanceTarget': 75.0,
            'color': '#2563EB',
            'type': 'THEORY',
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });
          (v1['events'] as List).addAll(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 5,
              'serverId': 'rep_ev_5',
              'subjectId': 4,
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
            <String, dynamic>{
              'id': 6,
              'serverId': 'rep_ev_6',
              'subjectId': 4,
              'date': DateTime.utc(2026, 9, 8).toIso8601String(),
              'startTime': '11:00',
              'endTime': '12:00',
              'eventType': 'REGULAR_CLASS',
              'status': 'ABSENT',
              'createdAt': ts.toIso8601String(),
              'updatedAt': ts.toIso8601String(),
              'isDirty': false,
              'isDeleted': false,
            },
          ]);
          (v1['attendance'] as List).add(<String, dynamic>{
            'id': 6,
            'serverId': 'rep_att_6',
            'eventId': 5,
            'subjectId': 4,
            'status': 'PRESENT',
            'markedAt': DateTime.utc(2026, 9, 7).toIso8601String(),
            'createdAt': ts.toIso8601String(),
            'updatedAt': ts.toIso8601String(),
            'isDirty': false,
            'isDeleted': false,
          });

          final importer = BackupImporter(isar);
          await importer.importData(
            jsonEncode(v1),
            strategy: ImportStrategy.replace,
          );

          expect(isar.semesterLocals.get(99), isNull);
          expect(isar.semesterLocals.count(), equals(1));
          expect(isar.semesterLocals.get(3)!.name, equals('Replace V1 Sem'));
          expect(isar.subjectLocals.get(4)!.semesterId, equals(3));
          final repAtt = isar.attendanceRecordLocals.get(6)!;
          expect(repAtt.occurrenceId, isNotNull);
          expect(repAtt.eventId, equals(repAtt.occurrenceId));
          expect(isar.migrationAuditRecordLocals.count(), equals(1));
        } finally {
          isar?.close();
          if (dir.existsSync()) await dir.delete(recursive: true);
        }
      },
    );
  });
}
