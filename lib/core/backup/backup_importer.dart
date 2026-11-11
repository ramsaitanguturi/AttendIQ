import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

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
import '../../features/timetable/data/utils/occurrence_identity.dart';
import '../database/migration_audit_record_local.dart';
import '../database/timetable_migration.dart';
import '../event_generator/data/models/event_local.dart';
import '../notifications/models/notification_item.dart';
import '../notifications/scheduler/notification_database.dart';
import '../utils/uuid_generator.dart';
import 'backup_models.dart';

enum ImportStrategy { replace, merge }

class BackupImporter {
  static const String skippedMergeAuditKind = 'backupMergeSkippedRecord';

  final Isar _isar;
  static const int currentSupportedBackupVersion = 2;

  BackupImporter(this._isar);

  BackupData parseAndValidateJson(String rawJson) {
    dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup payload layout');
    }

    final backupData = BackupData.fromJson(decoded);

    if (backupData.metadata.backupVersion > currentSupportedBackupVersion) {
      throw FormatException(
        'Unsupported backup version ${backupData.metadata.backupVersion}. Current maximum supported version is $currentSupportedBackupVersion.',
      );
    }

    return backupData;
  }

  Future<void> importData(
    String rawJson, {
    ImportStrategy strategy = ImportStrategy.replace,
    @visibleForTesting void Function(Isar isar)? onBeforeCommit,
  }) async {
    final data = parseAndValidateJson(rawJson);

    await _isar.writeAsync((isar) {
      if (strategy == ImportStrategy.replace) {
        isar.userPreferencesLocals.clear();
        isar.semesterLocals.clear();
        isar.subjectLocals.clear();
        isar.timetableTemplateLocals.clear();
        isar.eventLocals.clear();
        isar.attendanceRecordLocals.clear();
        isar.notificationItems.clear();
        isar.scheduleExceptionLocals.clear();
        isar.weeklyScheduleRuleLocals.clear();
        isar.dailyScheduleOccurrenceLocals.clear();
        isar.academicEventLocals.clear();
        isar.academicTaskLocals.clear();
        isar.migrationAuditRecordLocals.clear();
      }

      final nowUtc = DateTime.now().toUtc();
      final semesterIdMap = <int, int>{};
      final subjectIdMap = <int, int>{};
      final templateIdMap = <int, int>{};
      final legacyEventIdMap = <int, int>{};
      final ruleIdMap = <int, int>{};
      final ruleBySrcServerId = <String, WeeklyScheduleRuleLocal>{};
      final occurrenceIdMap = <int, int>{};
      final occurrenceBySrcServerId = <String, DailyScheduleOccurrenceLocal>{};
      final attendanceIdMap = <int, int>{};
      final slotKeyMap = <String, String>{};
      final academicEventIdMap = <int, int>{};
      final taskIdMap = <int, int>{};

      final srcOccurrenceServerIdBySrcId = <int, String>{
        for (final m in data.occurrences)
          if ((m['id'] as int? ?? 0) > 0 &&
              (m['serverId'] as String?) != null &&
              (m['serverId'] as String).trim().isNotEmpty)
            m['id'] as int: (m['serverId'] as String).trim(),
      };

      final existingAudits = strategy == ImportStrategy.merge
          ? isar.migrationAuditRecordLocals.where().findAll()
          : <MigrationAuditRecordLocal>[];
      final usedAuditServerIds = _collectServerIds(
        existingAudits.map((e) => e.serverId),
      );
      final existingAuditsByKey = <String, MigrationAuditRecordLocal>{
        for (final a in existingAudits) a.auditKey: a,
      };
      final auditSourceAttendanceIds = <int>{
        for (final m in data.migrationAudits)
          if ((m['attendanceRecordId'] as int? ?? 0) > 0)
            m['attendanceRecordId'] as int,
      };

      // Track used serverIds in destination collections to guarantee unique-index safety.
      final usedPrefServerIds = _collectServerIds(
        isar.userPreferencesLocals.where().findAll().map((e) => e.serverId),
      );
      final usedSemesterServerIds = _collectServerIds(
        isar.semesterLocals.where().findAll().map((e) => e.serverId),
      );
      final usedSubjectServerIds = _collectServerIds(
        isar.subjectLocals.where().findAll().map((e) => e.serverId),
      );
      final usedTemplateServerIds = _collectServerIds(
        isar.timetableTemplateLocals.where().findAll().map((e) => e.serverId),
      );
      final usedEventServerIds = _collectServerIds(
        isar.eventLocals.where().findAll().map((e) => e.serverId),
      );
      final usedRuleServerIds = _collectServerIds(
        isar.weeklyScheduleRuleLocals.where().findAll().map((e) => e.serverId),
      );
      final usedOccurrenceServerIds = _collectServerIds(
        isar.dailyScheduleOccurrenceLocals
            .where()
            .findAll()
            .map((e) => e.serverId),
      );
      final usedAttendanceServerIds = _collectServerIds(
        isar.attendanceRecordLocals.where().findAll().map((e) => e.serverId),
      );
      final usedExceptionServerIds = _collectServerIds(
        isar.scheduleExceptionLocals.where().findAll().map((e) => e.serverId),
      );
      final usedAcademicEventServerIds = _collectServerIds(
        isar.academicEventLocals.where().findAll().map((e) => e.serverId),
      );
      final usedTaskServerIds = _collectServerIds(
        isar.academicTaskLocals.where().findAll().map((e) => e.serverId),
      );

      // 1. User Preferences
      for (final map in data.userPreferences) {
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final isDeleted = map['isDeleted'] as bool? ?? false;
        UserPreferencesLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final byServer = isar.userPreferencesLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null && byServer.isDeleted == isDeleted) {
              matched = byServer;
            }
          } else if (!isDeleted) {
            matched = _firstOrNull(
              isar.userPreferencesLocals.where().findAll().where(
                    (p) => !p.isDeleted,
                  ),
            );
          }
        }
        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && (map['id'] as int? ?? 0) > 0
                ? map['id'] as int
                : isar.userPreferencesLocals.autoIncrement());

        final pref = UserPreferencesLocal()
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedPrefServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..themeMode = map['themeMode'] as String? ?? 'system'
          ..defaultAttendanceTarget =
              (map['defaultAttendanceTarget'] as num?)?.toDouble() ?? 75.0
          ..classReminderOffset = map['classReminderOffset'] as int? ?? 5
          ..enableNotifications = map['enableNotifications'] as bool? ?? true
          ..enableAttendanceWarnings =
              map['enableAttendanceWarnings'] as bool? ?? true
          ..weeklyReportEnabled = map['weeklyReportEnabled'] as bool? ?? true
          ..lastSyncTime =
              DateTime.tryParse(map['lastSyncTime'] as String? ?? '')
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.userPreferencesLocals.put(pref);
      }

      // 2. Semesters (+ normalize active invariant)
      final destSemesters = strategy == ImportStrategy.merge
          ? isar.semesterLocals.where().findAll()
          : <SemesterLocal>[];
      for (final map in data.semesters) {
        final sem = SemesterLocal.fromJson(map);
        final srcId = sem.id;
        final srcServerId = _trimOrNull(sem.serverId);

        SemesterLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final existing = isar.semesterLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (existing != null &&
                existing.name == sem.name &&
                existing.isDeleted == sem.isDeleted) {
              matched = existing;
            }
          }
          if (matched == null) {
            final normName = sem.name.trim().toLowerCase();
            final normStart = normalizeUtcDate(sem.startDate);
            final normEnd = normalizeUtcDate(sem.endDate);
            matched = _firstOrNull(
              destSemesters.where(
                (s) =>
                    s.isDeleted == sem.isDeleted &&
                    s.name.trim().toLowerCase() == normName &&
                    normalizeUtcDate(s.startDate).isAtSameMomentAs(normStart) &&
                    normalizeUtcDate(s.endDate).isAtSameMomentAs(normEnd),
              ),
            );
          }
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.semesterLocals.autoIncrement());

        sem
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedSemesterServerIds,
            keepExistingOnOwner: matched?.serverId,
          );
        isar.semesterLocals.put(sem);
        _upsertCachedRecord(destSemesters, sem, (s) => s.id == sem.id);
        if (srcId > 0) {
          semesterIdMap[srcId] = sem.id;
        }
      }
      normalizeSemestersInWriteTx(isar);

      // 3. Subjects
      final destSubjects = strategy == ImportStrategy.merge
          ? isar.subjectLocals.where().findAll()
          : <SubjectLocal>[];
      for (final map in data.subjects) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSemesterId = map['semesterId'] as int? ?? 0;
        final code = map['code'] as String? ?? '';
        final type = map['type'] as String? ?? 'THEORY';
        final name = map['name'] as String? ?? '';
        final isDeleted = map['isDeleted'] as bool? ?? false;
        final normCode = code.trim().toUpperCase();
        final normType = type.trim().toUpperCase() == 'LAB' ? 'LAB' : 'THEORY';
        final normName = normalizeTitleForKey(name);

        if (strategy == ImportStrategy.merge &&
            (srcSemesterId <= 0 || !semesterIdMap.containsKey(srcSemesterId))) {
          _recordSkippedMergeAuditInTx(
            isar,
            now: nowUtc,
            existingAuditsByKey: existingAuditsByKey,
            usedAuditServerIds: usedAuditServerIds,
            entityType: 'SubjectLocal',
            srcId: srcId,
            srcServerId: srcServerId,
            missingParentType: 'SemesterLocal',
            missingParentSourceId: srcSemesterId,
            disambiguator: '$normCode|$normType|$normName',
            status: isDeleted ? 'DELETED' : 'ACTIVE',
            details: <String, dynamic>{
              'name': name,
              'code': code,
              'type': normType,
              'isDeleted': isDeleted,
            },
          );
          continue;
        }
        final destSemesterId = semesterIdMap[srcSemesterId] ?? srcSemesterId;

        SubjectLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final byServer = isar.subjectLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.semesterId == destSemesterId &&
                byServer.code.trim().toUpperCase() == normCode &&
                byServer.type.trim().toUpperCase() == normType &&
                byServer.isDeleted == isDeleted) {
              matched = byServer;
            }
          }
          if (matched == null) {
            if (!isDeleted) {
              matched = _firstOrNull(
                destSubjects.where(
                  (s) =>
                      !s.isDeleted &&
                      s.semesterId == destSemesterId &&
                      s.code.trim().toUpperCase() == normCode &&
                      s.type.trim().toUpperCase() == normType,
                ),
              );
            } else {
              matched = _firstOrNull(
                destSubjects.where(
                  (s) =>
                      s.isDeleted &&
                      s.semesterId == destSemesterId &&
                      s.code.trim().toUpperCase() == normCode &&
                      s.type.trim().toUpperCase() == normType &&
                      normalizeTitleForKey(s.name) == normName,
                ),
              );
            }
          }
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.subjectLocals.autoIncrement());

        final sub = SubjectLocal()
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedSubjectServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..semesterId = destSemesterId
          ..name = name
          ..code = code
          ..faculty = map['faculty'] as String?
          ..credits = map['credits'] as int? ?? 3
          ..attendanceTarget =
              (map['attendanceTarget'] as num?)?.toDouble() ?? 75.0
          ..color = map['color'] as String? ?? '0xFF10B981'
          ..type = type
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              nowUtc
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.subjectLocals.put(sub);
        _upsertCachedRecord(destSubjects, sub, (s) => s.id == sub.id);
        if (srcId > 0) {
          subjectIdMap[srcId] = sub.id;
        }
      }

      // 4. Legacy Timetable Templates
      final destTemplates = strategy == ImportStrategy.merge
          ? isar.timetableTemplateLocals.where().findAll()
          : <TimetableTemplateLocal>[];
      for (final map in data.timetable) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int? ?? 0;
        final weekday = map['weekday'] as int? ?? 1;
        final startTime = map['startTime'] as String? ?? '09:00';
        final endTime = map['endTime'] as String? ?? '10:00';
        final normStart = normalizeTimeSlotPart(startTime);
        final normEnd = normalizeTimeSlotPart(endTime);
        final isDeleted = map['isDeleted'] as bool? ?? false;

        if (strategy == ImportStrategy.merge &&
            (srcSubId <= 0 || !subjectIdMap.containsKey(srcSubId))) {
          _recordSkippedMergeAuditInTx(
            isar,
            now: nowUtc,
            existingAuditsByKey: existingAuditsByKey,
            usedAuditServerIds: usedAuditServerIds,
            entityType: 'TimetableTemplateLocal',
            srcId: srcId,
            srcServerId: srcServerId,
            missingParentType: 'SubjectLocal',
            missingParentSourceId: srcSubId,
            disambiguator: '$srcSubId|$weekday|$normStart-$normEnd',
            status: isDeleted ? 'DELETED' : 'ACTIVE',
            details: <String, dynamic>{
              'weekday': weekday,
              'startTime': normStart,
              'endTime': normEnd,
              'isDeleted': isDeleted,
            },
          );
          continue;
        }
        final destSubId = subjectIdMap[srcSubId] ?? srcSubId;

        TimetableTemplateLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final existing = isar.timetableTemplateLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (existing != null &&
                existing.isDeleted == isDeleted &&
                existing.subjectId == destSubId &&
                existing.weekday == weekday &&
                normalizeTimeSlotPart(existing.startTime) == normStart &&
                normalizeTimeSlotPart(existing.endTime) == normEnd) {
              matched = existing;
            }
          }
          matched ??= _firstOrNull(
            destTemplates.where(
              (t) =>
                  t.isDeleted == isDeleted &&
                  t.subjectId == destSubId &&
                  t.weekday == weekday &&
                  normalizeTimeSlotPart(t.startTime) == normStart &&
                  normalizeTimeSlotPart(t.endTime) == normEnd,
            ),
          );
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.timetableTemplateLocals.autoIncrement());

        final tt = TimetableTemplateLocal()
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedTemplateServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..subjectId = destSubId
          ..weekday = weekday
          ..startTime = startTime
          ..endTime = endTime
          ..room = map['room'] as String?
          ..faculty = map['faculty'] as String?
          ..notes = map['notes'] as String?
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              nowUtc
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.timetableTemplateLocals.put(tt);
        _upsertCachedRecord(destTemplates, tt, (t) => t.id == tt.id);
        if (srcId > 0) {
          templateIdMap[srcId] = tt.id;
        }
      }

      // 5. Legacy Events
      final destEvents = strategy == ImportStrategy.merge
          ? isar.eventLocals.where().findAll()
          : <EventLocal>[];
      for (final map in data.events) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int? ?? 0;
        final date = normalizeUtcDate(
          DateTime.tryParse(map['date'] as String? ?? '') ?? nowUtc,
        );
        final startTime = map['startTime'] as String? ?? '09:00';
        final endTime = map['endTime'] as String? ?? '10:00';
        final normStart = normalizeTimeSlotPart(startTime);
        final normEnd = normalizeTimeSlotPart(endTime);
        final eventType = map['eventType'] as String? ?? 'REGULAR_CLASS';
        final normEventType = eventType.trim().toUpperCase();
        final status = map['status'] as String? ?? 'UNMARKED';
        final isDeleted = map['isDeleted'] as bool? ?? false;

        if (strategy == ImportStrategy.merge &&
            (srcSubId <= 0 || !subjectIdMap.containsKey(srcSubId))) {
          _recordSkippedMergeAuditInTx(
            isar,
            now: nowUtc,
            existingAuditsByKey: existingAuditsByKey,
            usedAuditServerIds: usedAuditServerIds,
            entityType: 'EventLocal',
            srcId: srcId,
            srcServerId: srcServerId,
            missingParentType: 'SubjectLocal',
            missingParentSourceId: srcSubId,
            disambiguator:
                '$srcSubId|${formatUtcDateKey(date)}|$normStart-$normEnd|$normEventType',
            status: status,
            eventDate: date,
            details: <String, dynamic>{
              'date': date.toIso8601String(),
              'startTime': normStart,
              'endTime': normEnd,
              'eventType': normEventType,
              'status': status,
              'isDeleted': isDeleted,
            },
          );
          continue;
        }
        final destSubId = subjectIdMap[srcSubId] ?? srcSubId;

        EventLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final existing = isar.eventLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (existing != null &&
                existing.isDeleted == isDeleted &&
                existing.subjectId == destSubId &&
                normalizeUtcDate(existing.date).isAtSameMomentAs(date) &&
                normalizeTimeSlotPart(existing.startTime) == normStart &&
                normalizeTimeSlotPart(existing.endTime) == normEnd) {
              matched = existing;
            }
          }
          matched ??= _firstOrNull(
            destEvents.where(
              (e) =>
                  e.isDeleted == isDeleted &&
                  e.subjectId == destSubId &&
                  normalizeUtcDate(e.date).isAtSameMomentAs(date) &&
                  normalizeTimeSlotPart(e.startTime) == normStart &&
                  normalizeTimeSlotPart(e.endTime) == normEnd &&
                  e.eventType.trim().toUpperCase() == normEventType,
            ),
          );
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.eventLocals.autoIncrement());

        final ev = EventLocal()
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedEventServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..subjectId = destSubId
          ..date = date
          ..startTime = startTime
          ..endTime = endTime
          ..eventType = eventType
          ..status = status
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              nowUtc
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.eventLocals.put(ev);
        _upsertCachedRecord(destEvents, ev, (e) => e.id == ev.id);
        if (srcId > 0) {
          legacyEventIdMap[srcId] = ev.id;
        }
      }

      // 6. Weekly Schedule Rules (before Occurrences so ruleId FK remaps deterministically)
      final destRules = strategy == ImportStrategy.merge
          ? isar.weeklyScheduleRuleLocals.where().findAll()
          : <WeeklyScheduleRuleLocal>[];
      final destSubjectById = <int, SubjectLocal>{
        for (final s in isar.subjectLocals.where().findAll()) s.id: s,
      };

      for (final map in data.weeklyRules) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int? ?? 0;
        final dayOfWeek = map['dayOfWeek'] as int? ?? 1;
        final startTime = normalizeTimeSlotPart(
          map['startTime'] as String? ?? '09:00',
        );
        final endTime = normalizeTimeSlotPart(
          map['endTime'] as String? ?? '10:00',
        );
        final isDeleted = map['isDeleted'] as bool? ?? false;

        if (strategy == ImportStrategy.merge &&
            (srcSubId <= 0 || !subjectIdMap.containsKey(srcSubId))) {
          _recordSkippedMergeAuditInTx(
            isar,
            now: nowUtc,
            existingAuditsByKey: existingAuditsByKey,
            usedAuditServerIds: usedAuditServerIds,
            entityType: 'WeeklyScheduleRuleLocal',
            srcId: srcId,
            srcServerId: srcServerId,
            missingParentType: 'SubjectLocal',
            missingParentSourceId: srcSubId,
            disambiguator: '$srcSubId|$dayOfWeek|$startTime-$endTime',
            status: isDeleted ? 'DELETED' : 'ACTIVE',
            details: <String, dynamic>{
              'dayOfWeek': dayOfWeek,
              'startTime': startTime,
              'endTime': endTime,
              'type': map['type'] as String?,
              'isDeleted': isDeleted,
            },
          );
          continue;
        }

        final destSubId = subjectIdMap[srcSubId] ?? srcSubId;
        final srcLegacyTplId = map['legacyTemplateId'] as int?;
        final destLegacyTplId = srcLegacyTplId != null
            ? (templateIdMap[srcLegacyTplId] ??
                (strategy == ImportStrategy.replace ? srcLegacyTplId : null))
            : null;

        final inferredType = (map['type'] as String?) ??
            destSubjectById[destSubId]?.type ??
            'THEORY';
        final normType =
            inferredType.trim().toUpperCase() == 'LAB' ? 'LAB' : 'THEORY';

        WeeklyScheduleRuleLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final byServer = isar.weeklyScheduleRuleLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.isDeleted == isDeleted &&
                byServer.subjectId == destSubId &&
                byServer.dayOfWeek == dayOfWeek &&
                normalizeTimeSlotPart(byServer.startTime) == startTime &&
                normalizeTimeSlotPart(byServer.endTime) == endTime) {
              matched = byServer;
            }
          }
          matched ??= _firstOrNull(
            destRules.where(
              (r) =>
                  r.isDeleted == isDeleted &&
                  r.subjectId == destSubId &&
                  r.dayOfWeek == dayOfWeek &&
                  normalizeTimeSlotPart(r.startTime) == startTime &&
                  normalizeTimeSlotPart(r.endTime) == endTime &&
                  r.type.toUpperCase() == normType,
            ),
          );
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.weeklyScheduleRuleLocals.autoIncrement());

        final rule = WeeklyScheduleRuleLocal()
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedRuleServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..subjectId = destSubId
          ..legacyTemplateId = destLegacyTplId ?? matched?.legacyTemplateId
          ..dayOfWeek = dayOfWeek
          ..startTime = startTime
          ..endTime = endTime
          ..room = map['room'] as String?
          ..faculty = map['faculty'] as String?
          ..type = normType
          ..isActive = map['isActive'] as bool? ?? true
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              nowUtc
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.weeklyScheduleRuleLocals.put(rule);
        _upsertCachedRecord(destRules, rule, (r) => r.id == rule.id);
        if (srcId > 0) {
          ruleIdMap[srcId] = rule.id;
        }
        if (srcServerId != null) {
          ruleBySrcServerId[srcServerId] = rule;
        }
      }

      // 7. Daily Schedule Occurrences (remapping subjectId, ruleId, legacyEventId & slotKey)
      final destDeletedOccurrences = strategy == ImportStrategy.merge
          ? isar.dailyScheduleOccurrenceLocals
              .where()
              .isDeletedEqualTo(true)
              .findAll()
          : <DailyScheduleOccurrenceLocal>[];
      for (final map in data.occurrences) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int?;
        final occDate = normalizeUtcDate(
          DateTime.tryParse(map['date'] as String? ?? '') ?? nowUtc,
        );
        final startTime = normalizeTimeSlotPart(
          map['startTime'] as String? ?? '09:00',
        );
        final endTime = normalizeTimeSlotPart(
          map['endTime'] as String? ?? '10:00',
        );
        final type =
            (map['type'] as String? ?? 'REGULAR_CLASS').trim().toUpperCase();
        final title = map['title'] as String? ?? '';
        final status = map['status'] as String? ?? 'UPCOMING';
        final isDeleted = map['isDeleted'] as bool? ?? false;

        final bool isSubjectRequiredType =
            type == 'REGULAR_CLASS' || type == 'EXTRA_CLASS';
        final int? destSubId;
        if (strategy == ImportStrategy.merge) {
          if (isSubjectRequiredType) {
            if (srcSubId == null ||
                srcSubId <= 0 ||
                !subjectIdMap.containsKey(srcSubId)) {
              _recordSkippedMergeAuditInTx(
                isar,
                now: nowUtc,
                existingAuditsByKey: existingAuditsByKey,
                usedAuditServerIds: usedAuditServerIds,
                entityType: 'DailyScheduleOccurrenceLocal',
                srcId: srcId,
                srcServerId: srcServerId,
                missingParentType: 'SubjectLocal',
                missingParentSourceId: srcSubId ?? 0,
                disambiguator:
                    '$type|${srcSubId ?? 0}|${formatUtcDateKey(occDate)}|$startTime-$endTime',
                status: status,
                eventDate: occDate,
                details: <String, dynamic>{
                  'date': occDate.toIso8601String(),
                  'startTime': startTime,
                  'endTime': endTime,
                  'type': type,
                  'title': title,
                  'status': status,
                  'ruleId': map['ruleId'] as int?,
                  'isDeleted': isDeleted,
                },
              );
              continue;
            }
            destSubId = subjectIdMap[srcSubId];
          } else {
            // Optional-subject EXAM / EVENT occurrence: preserve null if source was null,
            // otherwise skip & audit if explicit positive subjectId cannot be mapped.
            if (srcSubId == null) {
              destSubId = null;
            } else if (srcSubId <= 0 || !subjectIdMap.containsKey(srcSubId)) {
              _recordSkippedMergeAuditInTx(
                isar,
                now: nowUtc,
                existingAuditsByKey: existingAuditsByKey,
                usedAuditServerIds: usedAuditServerIds,
                entityType: 'DailyScheduleOccurrenceLocal',
                srcId: srcId,
                srcServerId: srcServerId,
                missingParentType: 'SubjectLocal',
                missingParentSourceId: srcSubId,
                disambiguator:
                    '$type|$srcSubId|${formatUtcDateKey(occDate)}|$startTime-$endTime|${normalizeTitleForKey(title)}',
                status: status,
                eventDate: occDate,
                details: <String, dynamic>{
                  'date': occDate.toIso8601String(),
                  'startTime': startTime,
                  'endTime': endTime,
                  'type': type,
                  'title': title,
                  'status': status,
                  'isDeleted': isDeleted,
                },
              );
              continue;
            } else {
              destSubId = subjectIdMap[srcSubId];
            }
          }
        } else {
          destSubId =
              srcSubId != null ? (subjectIdMap[srcSubId] ?? srcSubId) : null;
        }

        final srcRuleId = map['ruleId'] as int?;
        int? destRuleId;
        if (srcRuleId != null && srcRuleId > 0) {
          if (ruleIdMap.containsKey(srcRuleId)) {
            destRuleId = ruleIdMap[srcRuleId];
          } else if (strategy == ImportStrategy.replace) {
            destRuleId = srcRuleId;
          }
        }

        final srcLegacyEvId = map['legacyEventId'] as int?;
        int? destLegacyEvId;
        if (srcLegacyEvId != null && srcLegacyEvId > 0) {
          if (legacyEventIdMap.containsKey(srcLegacyEvId)) {
            destLegacyEvId = legacyEventIdMap[srcLegacyEvId];
          } else if (strategy == ImportStrategy.replace) {
            destLegacyEvId = srcLegacyEvId;
          }
        }

        final srcSlotKey = _trimOrNull(map['slotKey'] as String?);
        final isLegacyDisambiguated =
            srcSlotKey != null && srcSlotKey.startsWith('LEGACY_EV:');

        final destSlotKey = computeCanonicalSlotKey(
          date: occDate,
          subjectId: destSubId,
          ruleId: destRuleId,
          startTime: startTime,
          endTime: endTime,
          type: type,
          title: title,
          legacyEventId: destLegacyEvId,
          forceLegacyDisambiguation:
              isLegacyDisambiguated && (destLegacyEvId ?? 0) > 0,
        );

        DailyScheduleOccurrenceLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final byServer = isar.dailyScheduleOccurrenceLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.isDeleted == isDeleted &&
                byServer.subjectId == destSubId &&
                normalizeUtcDate(byServer.date).isAtSameMomentAs(occDate) &&
                normalizeTimeSlotPart(byServer.startTime) == startTime &&
                normalizeTimeSlotPart(byServer.endTime) == endTime &&
                byServer.type.toUpperCase() == type) {
              matched = byServer;
            }
          }
          if (matched == null && isDeleted) {
            matched = _firstOrNull(
              destDeletedOccurrences.where(
                (o) =>
                    o.isDeleted &&
                    o.slotKey == destSlotKey &&
                    o.subjectId == destSubId,
              ),
            );
          }
        }

        final incoming = DailyScheduleOccurrenceLocal()
          ..id = matched?.id ??
              (strategy == ImportStrategy.replace && srcId > 0 ? srcId : 0)
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedOccurrenceServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..date = occDate
          ..subjectId = destSubId
          ..ruleId = destRuleId
          ..legacyEventId = destLegacyEvId
          ..slotKey = destSlotKey
          ..title = title
          ..startTime = startTime
          ..endTime = endTime
          ..type = type
          ..status = status
          ..createdFrom = map['createdFrom'] as String? ?? 'WEEKLY_RULE'
          ..room = map['room'] as String?
          ..faculty = map['faculty'] as String?
          ..reason = map['reason'] as String?
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              nowUtc
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        final DailyScheduleOccurrenceLocal savedOcc;
        if (isDeleted) {
          final targetId = incoming.id > 0
              ? incoming.id
              : isar.dailyScheduleOccurrenceLocals.autoIncrement();
          incoming.id = targetId;
          isar.dailyScheduleOccurrenceLocals.put(incoming);
          savedOcc = incoming;
          _upsertCachedRecord(
            destDeletedOccurrences,
            savedOcc,
            (o) => o.id == savedOcc.id,
          );
        } else {
          savedOcc = upsertCanonicalOccurrenceInWriteTx(
            isar,
            incoming,
            preferIncomingStatusOnMatch: true,
            preserveExistingCreatedAt: true,
          );
          if (savedOcc.serverId != null) {
            usedOccurrenceServerIds.add(savedOcc.serverId!);
          }
        }

        if (srcId > 0) {
          occurrenceIdMap[srcId] = savedOcc.id;
        }
        if (srcServerId != null) {
          occurrenceBySrcServerId[srcServerId] = savedOcc;
        }
        if (srcSlotKey != null && savedOcc.slotKey != null) {
          slotKeyMap[srcSlotKey] = savedOcc.slotKey!;
        }
      }

      // 8. Attendance Records (after occurrences & events, with full FK + serverId remapping)
      for (final map in data.attendance) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int? ?? 0;
        final status = map['status'] as String? ?? 'PRESENT';
        final markedAtUtc =
            (DateTime.tryParse(map['markedAt'] as String? ?? '') ?? nowUtc)
                .toUtc();
        final isDeleted = map['isDeleted'] as bool? ?? false;

        if (strategy == ImportStrategy.merge &&
            (srcSubId <= 0 || !subjectIdMap.containsKey(srcSubId))) {
          _recordSkippedMergeAuditInTx(
            isar,
            now: nowUtc,
            existingAuditsByKey: existingAuditsByKey,
            usedAuditServerIds: usedAuditServerIds,
            entityType: 'AttendanceRecordLocal',
            srcId: srcId,
            srcServerId: srcServerId,
            missingParentType: 'SubjectLocal',
            missingParentSourceId: srcSubId,
            disambiguator:
                '$srcSubId|${map['occurrenceId'] ?? 0}|${map['legacyEventId'] ?? 0}|${map['eventId'] ?? 0}|${markedAtUtc.millisecondsSinceEpoch}',
            status: status,
            eventDate: normalizeUtcDate(markedAtUtc),
            details: <String, dynamic>{
              'subjectId': srcSubId,
              'occurrenceId': map['occurrenceId'] as int?,
              'legacyEventId': map['legacyEventId'] as int?,
              'eventId': map['eventId'] as int? ?? 0,
              'status': status,
              'markedAt': markedAtUtc.toIso8601String(),
              'isDeleted': isDeleted,
            },
          );
          continue;
        }
        final destSubId = subjectIdMap[srcSubId] ?? srcSubId;

        final srcOccurrenceId = map['occurrenceId'] as int?;
        final srcLegacyEventId = map['legacyEventId'] as int?;
        final srcEventId = map['eventId'] as int? ?? 0;

        int? destOccurrenceId;
        int? destLegacyEventId;
        int destCompatibilityEventId;

        // Priority 1: explicit canonical occurrenceId translation
        if (srcOccurrenceId != null && srcOccurrenceId > 0) {
          if (occurrenceIdMap.containsKey(srcOccurrenceId)) {
            destOccurrenceId = occurrenceIdMap[srcOccurrenceId];
          } else {
            final occServer = srcOccurrenceServerIdBySrcId[srcOccurrenceId];
            if (occServer != null &&
                occurrenceBySrcServerId.containsKey(occServer)) {
              destOccurrenceId = occurrenceBySrcServerId[occServer]!.id;
            } else if (strategy == ImportStrategy.replace) {
              destOccurrenceId = srcOccurrenceId;
            }
          }
        }

        // Priority 2: legacyEventId provenance translation
        if (srcLegacyEventId != null && srcLegacyEventId > 0) {
          if (legacyEventIdMap.containsKey(srcLegacyEventId)) {
            destLegacyEventId = legacyEventIdMap[srcLegacyEventId];
          } else if (strategy == ImportStrategy.replace) {
            destLegacyEventId = srcLegacyEventId;
          }
        }

        // Priority 3: pre-BUG-004 backup (no occurrenceId field in JSON, only eventId)
        final isPreBug004Row =
            !map.containsKey('occurrenceId') && srcLegacyEventId == null;
        if (destOccurrenceId == null && isPreBug004Row && srcEventId > 0) {
          if (occurrenceIdMap.containsKey(srcEventId)) {
            destOccurrenceId = occurrenceIdMap[srcEventId];
          } else if (legacyEventIdMap.containsKey(srcEventId)) {
            destLegacyEventId ??= legacyEventIdMap[srcEventId];
          } else if (strategy == ImportStrategy.replace) {
            // Post-unification Step 13 will conservatively bind or preserve null.
          }
        }

        AttendanceRecordLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (destOccurrenceId != null && destOccurrenceId > 0) {
            final sameOcc = isar.attendanceRecordLocals
                .where()
                .occurrenceIdEqualTo(destOccurrenceId)
                .findAll();
            matched = _firstOrNull(
              sameOcc.where((a) => a.isDeleted == isDeleted),
            );
          }
          if (matched == null && srcServerId != null) {
            final byServer = isar.attendanceRecordLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.isDeleted == isDeleted &&
                byServer.subjectId == destSubId &&
                (destOccurrenceId == null ||
                    byServer.occurrenceId == destOccurrenceId ||
                    byServer.occurrenceId == null)) {
              matched = byServer;
            }
          }
          if (matched == null && srcServerId == null) {
            if (destLegacyEventId != null && destLegacyEventId > 0) {
              final sameLegacy = isar.attendanceRecordLocals
                  .where()
                  .legacyEventIdEqualTo(destLegacyEventId)
                  .findAll();
              matched = _firstOrNull(
                sameLegacy.where(
                  (a) =>
                      a.isDeleted == isDeleted &&
                      a.subjectId == destSubId &&
                      (destOccurrenceId == null ||
                          a.occurrenceId == destOccurrenceId ||
                          a.occurrenceId == null),
                ),
              );
            } else if (destOccurrenceId == null) {
              final sameSub = isar.attendanceRecordLocals
                  .where()
                  .subjectIdEqualTo(destSubId)
                  .findAll();
              matched = _firstOrNull(
                sameSub.where(
                  (a) =>
                      a.isDeleted == isDeleted &&
                      a.occurrenceId == null &&
                      a.legacyEventId == null &&
                      a.status == status &&
                      a.markedAt.toUtc().isAtSameMomentAs(markedAtUtc),
                ),
              );
            }
          }
        }

        // Preserve an existing valid destination occurrenceId when an incoming
        // matched record carries occurrenceId == null (partial/v1 re-merge).
        final int? effectiveOccurrenceId;
        if (destOccurrenceId != null && destOccurrenceId > 0) {
          effectiveOccurrenceId = destOccurrenceId;
        } else if (matched?.occurrenceId != null &&
            matched!.occurrenceId! > 0) {
          effectiveOccurrenceId = matched.occurrenceId;
        } else {
          effectiveOccurrenceId = null;
        }
        final int? effectiveLegacyEventId =
            destLegacyEventId ?? matched?.legacyEventId;

        if (effectiveOccurrenceId != null && effectiveOccurrenceId > 0) {
          destCompatibilityEventId = effectiveOccurrenceId;
        } else if (effectiveLegacyEventId != null &&
            effectiveLegacyEventId > 0) {
          destCompatibilityEventId = effectiveLegacyEventId;
        } else if (strategy == ImportStrategy.replace) {
          destCompatibilityEventId = srcEventId;
        } else {
          // Do not leave a raw source eventId pointing at an unrelated
          // destination occurrence during Merge when no legacy event or
          // occurrence was mapped from the backup.
          destCompatibilityEventId = 0;
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.attendanceRecordLocals.autoIncrement());

        final att = AttendanceRecordLocal()
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedAttendanceServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..occurrenceId = effectiveOccurrenceId
          ..legacyEventId = effectiveLegacyEventId
          ..eventId = destCompatibilityEventId
          ..subjectId = destSubId
          ..status = status
          ..markedAt = markedAtUtc
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              nowUtc
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.attendanceRecordLocals.put(att);
        if (srcId > 0) {
          attendanceIdMap[srcId] = att.id;
        }

        final hasUnmappedExplicitOcc = strategy == ImportStrategy.merge &&
            srcOccurrenceId != null &&
            srcOccurrenceId > 0 &&
            effectiveOccurrenceId == null;
        final hasUnmappedPreBug004Event = strategy == ImportStrategy.merge &&
            isPreBug004Row &&
            srcEventId > 0 &&
            effectiveOccurrenceId == null &&
            effectiveLegacyEventId == null &&
            !auditSourceAttendanceIds.contains(srcId);
        if (hasUnmappedExplicitOcc || hasUnmappedPreBug004Event) {
          _recordUnmappedOccurrenceAuditInTx(
            isar,
            now: nowUtc,
            existingAuditsByKey: existingAuditsByKey,
            usedAuditServerIds: usedAuditServerIds,
            attendanceRecordId: att.id,
            subjectId: destSubId,
            legacyEventId: effectiveLegacyEventId,
            sourceAttendanceId: srcId,
            sourceAttendanceServerId: srcServerId,
            sourceOccurrenceId: srcOccurrenceId,
            sourceLegacyEventId: srcLegacyEventId,
            sourceEventId: srcEventId,
            status: status,
            eventDate: normalizeUtcDate(markedAtUtc),
          );
        }
      }

      // 9. Schedule Exceptions (remapping subjectId + conservative deduplication)
      final destExceptions = strategy == ImportStrategy.merge
          ? isar.scheduleExceptionLocals.where().findAll()
          : <ScheduleExceptionLocal>[];
      for (final map in data.scheduleExceptions) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int?;
        final exDate = normalizeUtcDate(
          DateTime.tryParse(map['date'] as String? ?? '') ?? nowUtc,
        );
        final rawType = _trimOrNull(map['type'] as String?) ?? 'HOLIDAY';
        final normType = rawType.toUpperCase();
        final title = map['title'] as String? ?? '';
        final normTitle = normalizeTitleForKey(title);
        final isDeleted = map['isDeleted'] as bool? ?? false;
        final isSubjectRequiredType = normType == 'CANCELLED_CLASS';

        final int? destSubId;
        if (strategy == ImportStrategy.merge) {
          if (isSubjectRequiredType) {
            if (srcSubId == null ||
                srcSubId <= 0 ||
                !subjectIdMap.containsKey(srcSubId)) {
              _recordSkippedMergeAuditInTx(
                isar,
                now: nowUtc,
                existingAuditsByKey: existingAuditsByKey,
                usedAuditServerIds: usedAuditServerIds,
                entityType: 'ScheduleExceptionLocal',
                srcId: srcId,
                srcServerId: srcServerId,
                missingParentType: 'SubjectLocal',
                missingParentSourceId: srcSubId ?? 0,
                disambiguator:
                    '$normType|${srcSubId ?? 0}|${formatUtcDateKey(exDate)}|$normTitle',
                status: isDeleted ? 'DELETED' : 'ACTIVE',
                eventDate: exDate,
                details: <String, dynamic>{
                  'date': exDate.toIso8601String(),
                  'subjectId': srcSubId,
                  'type': rawType,
                  'title': title,
                  'isDeleted': isDeleted,
                },
              );
              continue;
            }
            destSubId = subjectIdMap[srcSubId];
          } else {
            if (srcSubId == null) {
              destSubId = null;
            } else if (srcSubId <= 0 || !subjectIdMap.containsKey(srcSubId)) {
              _recordSkippedMergeAuditInTx(
                isar,
                now: nowUtc,
                existingAuditsByKey: existingAuditsByKey,
                usedAuditServerIds: usedAuditServerIds,
                entityType: 'ScheduleExceptionLocal',
                srcId: srcId,
                srcServerId: srcServerId,
                missingParentType: 'SubjectLocal',
                missingParentSourceId: srcSubId,
                disambiguator:
                    '$normType|$srcSubId|${formatUtcDateKey(exDate)}|$normTitle',
                status: isDeleted ? 'DELETED' : 'ACTIVE',
                eventDate: exDate,
                details: <String, dynamic>{
                  'date': exDate.toIso8601String(),
                  'subjectId': srcSubId,
                  'type': rawType,
                  'title': title,
                  'isDeleted': isDeleted,
                },
              );
              continue;
            } else {
              destSubId = subjectIdMap[srcSubId];
            }
          }
        } else {
          destSubId =
              srcSubId != null ? (subjectIdMap[srcSubId] ?? srcSubId) : null;
        }

        ScheduleExceptionLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final byServer = isar.scheduleExceptionLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.isDeleted == isDeleted &&
                byServer.subjectId == destSubId &&
                normalizeUtcDate(byServer.date).isAtSameMomentAs(exDate) &&
                byServer.type.trim().toUpperCase() == normType &&
                normalizeTitleForKey(byServer.title) == normTitle) {
              matched = byServer;
            }
          }
          matched ??= _firstOrNull(
            destExceptions.where(
              (e) =>
                  e.isDeleted == isDeleted &&
                  normalizeUtcDate(e.date).isAtSameMomentAs(exDate) &&
                  e.subjectId == destSubId &&
                  e.type.trim().toUpperCase() == normType &&
                  normalizeTitleForKey(e.title) == normTitle,
            ),
          );
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.scheduleExceptionLocals.autoIncrement());

        final ex = ScheduleExceptionLocal()
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedExceptionServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..date = exDate
          ..subjectId = destSubId
          ..type = rawType
          ..title = title
          ..description = map['description'] as String?
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              nowUtc
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.scheduleExceptionLocals.put(ex);
        if (strategy == ImportStrategy.merge) {
          _upsertCachedRecord(destExceptions, ex, (e) => e.id == ex.id);
        }
      }

      // 10. Academic Events (discriminating deduplication across date/type/title/times)
      final destAcademicEvents = strategy == ImportStrategy.merge
          ? isar.academicEventLocals.where().findAll()
          : <AcademicEventLocal>[];
      for (final map in data.academicEvents) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final aeDate = normalizeUtcDate(
          DateTime.tryParse(map['date'] as String? ?? '') ?? nowUtc,
        );
        final title = map['title'] as String? ?? '';
        final normTitle = normalizeTitleForKey(title);
        final rawType = _trimOrNull(map['type'] as String?) ?? 'EVENT';
        final normType = rawType.toUpperCase();
        final rawStartTime = _trimOrNull(map['startTime'] as String?);
        final rawEndTime = _trimOrNull(map['endTime'] as String?);
        final normStartTime = _normalizeOptionalTime(rawStartTime);
        final normEndTime = _normalizeOptionalTime(rawEndTime);
        final isDeleted = map['isDeleted'] as bool? ?? false;

        AcademicEventLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final byServer = isar.academicEventLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.isDeleted == isDeleted &&
                normalizeUtcDate(byServer.date).isAtSameMomentAs(aeDate) &&
                byServer.type.trim().toUpperCase() == normType &&
                normalizeTitleForKey(byServer.title) == normTitle &&
                _normalizeOptionalTime(byServer.startTime) == normStartTime &&
                _normalizeOptionalTime(byServer.endTime) == normEndTime) {
              matched = byServer;
            }
          }
          matched ??= _firstOrNull(
            destAcademicEvents.where(
              (e) =>
                  e.isDeleted == isDeleted &&
                  normalizeUtcDate(e.date).isAtSameMomentAs(aeDate) &&
                  e.type.trim().toUpperCase() == normType &&
                  normalizeTitleForKey(e.title) == normTitle &&
                  _normalizeOptionalTime(e.startTime) == normStartTime &&
                  _normalizeOptionalTime(e.endTime) == normEndTime,
            ),
          );
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.academicEventLocals.autoIncrement());

        final ae = AcademicEventLocal()
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedAcademicEventServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..title = title
          ..description = map['description'] as String?
          ..date = aeDate
          ..startTime = rawStartTime
          ..endTime = rawEndTime
          ..type = rawType
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              nowUtc
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.academicEventLocals.put(ae);
        if (strategy == ImportStrategy.merge) {
          _upsertCachedRecord(destAcademicEvents, ae, (e) => e.id == ae.id);
        }
        if (srcId > 0) {
          academicEventIdMap[srcId] = ae.id;
        }
      }

      // 11. Tasks (remapping optional subjectId + conservative deduplication)
      final destTasks = strategy == ImportStrategy.merge
          ? isar.academicTaskLocals.where().findAll()
          : <AcademicTaskLocal>[];
      for (final map in data.tasks) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int?;
        final title = map['title'] as String? ?? '';
        final normTitle = normalizeTitleForKey(title);
        final startDate =
            (DateTime.tryParse(map['startDate'] as String? ?? '') ?? nowUtc)
                .toUtc();
        final dueDate =
            (DateTime.tryParse(map['dueDate'] as String? ?? '') ?? nowUtc)
                .toUtc();
        final taskType =
            _trimOrNull(map['taskType'] as String?) ?? 'ASSIGNMENT';
        final normTaskType = taskType.toUpperCase();
        final status = map['status'] as String? ?? 'PENDING';
        final isDeleted = map['isDeleted'] as bool? ?? false;

        final int? destSubId;
        if (strategy == ImportStrategy.merge) {
          if (srcSubId == null) {
            destSubId = null;
          } else if (srcSubId <= 0 || !subjectIdMap.containsKey(srcSubId)) {
            _recordSkippedMergeAuditInTx(
              isar,
              now: nowUtc,
              existingAuditsByKey: existingAuditsByKey,
              usedAuditServerIds: usedAuditServerIds,
              entityType: 'AcademicTaskLocal',
              srcId: srcId,
              srcServerId: srcServerId,
              missingParentType: 'SubjectLocal',
              missingParentSourceId: srcSubId,
              disambiguator:
                  '$srcSubId|$normTaskType|$normTitle|${dueDate.millisecondsSinceEpoch}',
              status: status,
              eventDate: normalizeUtcDate(dueDate),
              details: <String, dynamic>{
                'subjectId': srcSubId,
                'title': title,
                'taskType': taskType,
                'dueDate': dueDate.toIso8601String(),
                'status': status,
                'isDeleted': isDeleted,
              },
            );
            continue;
          } else {
            destSubId = subjectIdMap[srcSubId];
          }
        } else {
          destSubId =
              srcSubId != null ? (subjectIdMap[srcSubId] ?? srcSubId) : null;
        }

        AcademicTaskLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final byServer = isar.academicTaskLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.isDeleted == isDeleted &&
                byServer.subjectId == destSubId &&
                byServer.taskType.trim().toUpperCase() == normTaskType &&
                normalizeTitleForKey(byServer.title) == normTitle &&
                byServer.dueDate.toUtc().millisecondsSinceEpoch ==
                    dueDate.millisecondsSinceEpoch) {
              matched = byServer;
            }
          }
          matched ??= _firstOrNull(
            destTasks.where(
              (t) =>
                  t.isDeleted == isDeleted &&
                  t.subjectId == destSubId &&
                  t.taskType.trim().toUpperCase() == normTaskType &&
                  normalizeTitleForKey(t.title) == normTitle &&
                  t.dueDate.toUtc().millisecondsSinceEpoch ==
                      dueDate.millisecondsSinceEpoch,
            ),
          );
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.academicTaskLocals.autoIncrement());

        final tk = AcademicTaskLocal()
          ..id = targetId
          ..serverId = _claimUniqueServerId(
            candidate: matched?.serverId ?? srcServerId,
            used: usedTaskServerIds,
            keepExistingOnOwner: matched?.serverId,
          )
          ..subjectId = destSubId
          ..title = title
          ..description = map['description'] as String?
          ..startDate = startDate
          ..dueDate = dueDate
          ..priority = map['priority'] as String? ?? 'MEDIUM'
          ..taskType = taskType
          ..status = status
          ..reminder = map['reminder'] as String? ?? 'NONE'
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              nowUtc
          ..updatedAt =
              DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? nowUtc
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.academicTaskLocals.put(tk);
        if (strategy == ImportStrategy.merge) {
          _upsertCachedRecord(destTasks, tk, (t) => t.id == tk.id);
        }
        if (srcId > 0) {
          taskIdMap[srcId] = tk.id;
        }
      }

      // 12. Notifications (strict entity FK remapping + deduplication + unique Android IDs)
      final destNotifications = strategy == ImportStrategy.merge
          ? isar.notificationItems.where().findAll()
          : <NotificationItem>[];
      final androidIdOwner = <int, int>{};
      final usedAndroidIds = <int>{};
      for (final existing in destNotifications) {
        final aid = existing.androidNotificationId;
        if (aid != null &&
            NotificationItem.isValidPersistedAndroidId(aid) &&
            !androidIdOwner.containsKey(aid)) {
          androidIdOwner[aid] = existing.id;
          usedAndroidIds.add(aid);
        }
      }

      for (final map in data.notifications) {
        final srcId = map['id'] as int? ?? 0;
        final notifType =
            _trimOrNull(map['type'] as String?) ?? 'CLASS_REMINDER';
        final normType = notifType.toUpperCase();
        final rawRelatedId = map['relatedId'] as String?;
        final title = map['title'] as String? ?? '';
        final body = map['body'] as String? ?? '';
        final normTitle = normalizeTitleForKey(title);
        final schedTime =
            (DateTime.tryParse(map['scheduledTime'] as String? ?? '') ?? nowUtc)
                .toUtc();
        final incomingIsRead = map['isRead'] as bool? ?? false;

        final remap = _remapNotificationRelatedIdStrict(
          rawRelatedId: rawRelatedId,
          type: normType,
          strategy: strategy,
          subjectIdMap: subjectIdMap,
          ruleIdMap: ruleIdMap,
          occurrenceIdMap: occurrenceIdMap,
          legacyEventIdMap: legacyEventIdMap,
          slotKeyMap: slotKeyMap,
          academicEventIdMap: academicEventIdMap,
          taskIdMap: taskIdMap,
        );

        if (strategy == ImportStrategy.merge && remap.shouldSkipOnMerge) {
          _recordSkippedMergeAuditInTx(
            isar,
            now: nowUtc,
            existingAuditsByKey: existingAuditsByKey,
            usedAuditServerIds: usedAuditServerIds,
            entityType: 'NotificationItem',
            srcId: srcId,
            srcServerId: null,
            missingParentType: remap.missingParentType ?? 'EntityRef',
            missingParentSourceId: remap.missingParentSourceId,
            disambiguator:
                '$normType|${rawRelatedId?.trim() ?? ''}|${schedTime.microsecondsSinceEpoch}',
            status: incomingIsRead ? 'READ' : 'UNREAD',
            eventDate: normalizeUtcDate(schedTime),
            details: <String, dynamic>{
              'type': notifType,
              'relatedId': rawRelatedId,
              'title': title,
              'scheduledTime': schedTime.toIso8601String(),
              'isRead': incomingIsRead,
            },
          );
          continue;
        }

        final remappedRelatedId = remap.remappedRelatedId;

        NotificationItem? matched;
        if (strategy == ImportStrategy.merge) {
          matched = _firstOrNull(
            destNotifications.where((n) {
              if (n.type.trim().toUpperCase() != normType) return false;
              if (_trimOrNull(n.relatedId) != remappedRelatedId) return false;
              if (n.scheduledTime.toUtc().microsecondsSinceEpoch !=
                  schedTime.microsecondsSinceEpoch) {
                return false;
              }
              if (remappedRelatedId == null &&
                  normalizeTitleForKey(n.title) != normTitle) {
                return false;
              }
              return true;
            }),
          );
        }

        final targetId = matched?.id ??
            (strategy == ImportStrategy.replace && srcId > 0
                ? srcId
                : isar.notificationItems.autoIncrement());

        final existingAid = matched?.androidNotificationId;
        final incomingAid = map['androidNotificationId'] as int?;
        final int resolvedAid;
        if (existingAid != null &&
            NotificationItem.isValidPersistedAndroidId(existingAid) &&
            (androidIdOwner[existingAid] == null ||
                androidIdOwner[existingAid] == targetId)) {
          resolvedAid = existingAid;
          androidIdOwner[resolvedAid] = targetId;
          usedAndroidIds.add(resolvedAid);
        } else if (incomingAid != null &&
            NotificationItem.isValidPersistedAndroidId(incomingAid) &&
            !androidIdOwner.containsKey(incomingAid)) {
          resolvedAid = incomingAid;
          androidIdOwner[resolvedAid] = targetId;
          usedAndroidIds.add(resolvedAid);
        } else {
          resolvedAid = allocateNotificationAndroidIdFromUsedSet(
            dbId: targetId,
            usedAndroidIds: usedAndroidIds,
          );
          androidIdOwner[resolvedAid] = targetId;
          usedAndroidIds.add(resolvedAid);
        }

        final notif = NotificationItem()
          ..id = targetId
          ..androidNotificationId = resolvedAid
          ..title = title
          ..body = body
          ..type = notifType
          ..scheduledTime = schedTime
          ..relatedId = remappedRelatedId
          ..isRead = (matched?.isRead ?? false) || incomingIsRead;

        isar.notificationItems.put(notif);
        if (strategy == ImportStrategy.merge) {
          _upsertCachedRecord(
            destNotifications,
            notif,
            (n) => n.id == notif.id,
          );
        }
      }

      // 12.5. Migration Audit Records (remapping parent IDs & stable auditKeys)
      _importMigrationAuditsInTx(
        isar,
        auditMaps: data.migrationAudits,
        strategy: strategy,
        existingAuditsByKey: existingAuditsByKey,
        usedAuditServerIds: usedAuditServerIds,
        subjectIdMap: subjectIdMap,
        ruleIdMap: ruleIdMap,
        legacyEventIdMap: legacyEventIdMap,
        occurrenceIdMap: occurrenceIdMap,
        attendanceIdMap: attendanceIdMap,
        slotKeyMap: slotKeyMap,
      );

      // 13. Post-import unification pass (upgrades pre-BUG-004 backups and
      //     reconciles attendance/slotKey invariants atomically).
      runTimetableUnificationInWriteTx(isar);

      // 14. Normalize/repair persisted NotificationItem Android IDs inside the
      //     same transaction so the entire import commits or rolls back together.
      migrateLegacyNotificationItemsInWriteTx(isar);

      // 15. Optional test hook fired strictly before transaction commit to
      //     prove atomic rollback across all collections.
      onBeforeCommit?.call(isar);
    });
  }
}

void _upsertCachedRecord<T>(
  List<T> list,
  T item,
  bool Function(T existing) predicate,
) {
  final idx = list.indexWhere(predicate);
  if (idx >= 0) {
    list[idx] = item;
  } else {
    list.add(item);
  }
}

String? _normalizeOptionalTime(String? raw) {
  final trimmed = _trimOrNull(raw);
  if (trimmed == null) return null;
  return normalizeTimeSlotPart(trimmed);
}

void _recordSkippedMergeAuditInTx(
  Isar isar, {
  required DateTime now,
  required Map<String, MigrationAuditRecordLocal> existingAuditsByKey,
  required Set<String> usedAuditServerIds,
  required String entityType,
  required int srcId,
  String? srcServerId,
  required String missingParentType,
  required int missingParentSourceId,
  required String disambiguator,
  String? status,
  DateTime? eventDate,
  required Map<String, dynamic> details,
}) {
  final idOrServer = srcId > 0
      ? 'id:$srcId'
      : (srcServerId != null ? 'srv:$srcServerId' : 'anon');
  final auditKey =
      '${BackupImporter.skippedMergeAuditKind}|$entityType|$idOrServer|$missingParentType:$missingParentSourceId|$disambiguator';

  final encodedDetails = jsonEncode(<String, dynamic>{
    'entityType': entityType,
    'sourceId': srcId,
    if (srcServerId != null) 'sourceServerId': srcServerId,
    'missingParentType': missingParentType,
    'missingParentSourceId': missingParentSourceId,
    ...details,
  });
  final reason =
      'Skipped $entityType (srcId=$srcId) during Merge because referenced '
      '$missingParentType ($missingParentSourceId) was not mapped.';

  final existing = existingAuditsByKey[auditKey];
  if (existing != null &&
      !existing.isDeleted &&
      existing.kind == BackupImporter.skippedMergeAuditKind &&
      existing.reason == reason &&
      existing.diagnosticDetails == encodedDetails &&
      existing.status == status) {
    return;
  }

  final MigrationAuditRecordLocal record;
  if (existing != null) {
    record = existing
      ..kind = BackupImporter.skippedMergeAuditKind
      ..status = status
      ..eventDate = eventDate ?? existing.eventDate
      ..reason = reason
      ..diagnosticDetails = encodedDetails
      ..updatedAt = now
      ..isDeleted = false;
  } else {
    record = MigrationAuditRecordLocal()
      ..id = isar.migrationAuditRecordLocals.autoIncrement()
      ..serverId = _claimUniqueServerId(
        candidate: 'audit_$auditKey',
        used: usedAuditServerIds,
      )
      ..auditKey = auditKey
      ..kind = BackupImporter.skippedMergeAuditKind
      ..status = status
      ..eventDate = eventDate
      ..reason = reason
      ..diagnosticDetails = encodedDetails
      ..createdAt = now
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;
  }

  isar.migrationAuditRecordLocals.put(record);
  existingAuditsByKey[auditKey] = record;
}

void _recordUnmappedOccurrenceAuditInTx(
  Isar isar, {
  required DateTime now,
  required Map<String, MigrationAuditRecordLocal> existingAuditsByKey,
  required Set<String> usedAuditServerIds,
  required int attendanceRecordId,
  required int subjectId,
  required int? legacyEventId,
  required int sourceAttendanceId,
  String? sourceAttendanceServerId,
  int? sourceOccurrenceId,
  int? sourceLegacyEventId,
  required int sourceEventId,
  required String status,
  required DateTime eventDate,
}) {
  final auditKey = computeMigrationAuditKey(
    kind: MigrationAuditKind.missingOccurrenceTarget,
    attendanceRecordId: attendanceRecordId,
  );

  final encodedDetails = jsonEncode(<String, dynamic>{
    'origin': 'backupMergeUnmappedOccurrence',
    'sourceAttendanceId': sourceAttendanceId,
    if (sourceAttendanceServerId != null)
      'sourceAttendanceServerId': sourceAttendanceServerId,
    if (sourceOccurrenceId != null) 'sourceOccurrenceId': sourceOccurrenceId,
    if (sourceLegacyEventId != null) 'sourceLegacyEventId': sourceLegacyEventId,
    'sourceEventId': sourceEventId,
  });
  final reason = 'Preserved AttendanceRecordLocal ($attendanceRecordId) with '
      'occurrenceId=null during Merge because source occurrenceId='
      '${sourceOccurrenceId ?? 'null'} / eventId=$sourceEventId could not be mapped.';

  final existing = existingAuditsByKey[auditKey];
  if (existing != null &&
      !existing.isDeleted &&
      existing.kind == MigrationAuditKind.missingOccurrenceTarget.name &&
      existing.attendanceRecordId == attendanceRecordId &&
      existing.subjectId == subjectId &&
      existing.legacyEventId == legacyEventId &&
      existing.sourceEventId == (sourceEventId > 0 ? sourceEventId : null) &&
      existing.diagnosticDetails == encodedDetails &&
      existing.reason == reason) {
    return;
  }

  final resolvedSourceEventId = sourceEventId > 0 ? sourceEventId : null;
  final MigrationAuditRecordLocal record;
  if (existing != null) {
    record = existing
      ..kind = MigrationAuditKind.missingOccurrenceTarget.name
      ..attendanceRecordId = attendanceRecordId
      ..legacyEventId = legacyEventId
      ..sourceEventId = resolvedSourceEventId ?? existing.sourceEventId
      ..occurrenceId = null
      ..sourceOccurrenceId = null
      ..subjectId = subjectId
      ..status = status
      ..eventDate = eventDate
      ..reason = reason
      ..diagnosticDetails = encodedDetails
      ..updatedAt = now
      ..isDeleted = false;
  } else {
    record = MigrationAuditRecordLocal()
      ..id = isar.migrationAuditRecordLocals.autoIncrement()
      ..serverId = _claimUniqueServerId(
        candidate: 'audit_$auditKey',
        used: usedAuditServerIds,
      )
      ..auditKey = auditKey
      ..kind = MigrationAuditKind.missingOccurrenceTarget.name
      ..attendanceRecordId = attendanceRecordId
      ..legacyEventId = legacyEventId
      ..sourceEventId = resolvedSourceEventId
      ..occurrenceId = null
      ..sourceOccurrenceId = null
      ..subjectId = subjectId
      ..status = status
      ..eventDate = eventDate
      ..reason = reason
      ..diagnosticDetails = encodedDetails
      ..createdAt = now
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;
  }

  isar.migrationAuditRecordLocals.put(record);
  existingAuditsByKey[auditKey] = record;
}

int? _remapPositiveId(
  int? srcId,
  Map<int, int> idMap,
  ImportStrategy strategy,
) {
  if (srcId == null || srcId <= 0) return null;
  return idMap[srcId] ?? (strategy == ImportStrategy.replace ? srcId : null);
}

void _importMigrationAuditsInTx(
  Isar isar, {
  required List<Map<String, dynamic>> auditMaps,
  required ImportStrategy strategy,
  required Map<String, MigrationAuditRecordLocal> existingAuditsByKey,
  required Set<String> usedAuditServerIds,
  required Map<int, int> subjectIdMap,
  required Map<int, int> ruleIdMap,
  required Map<int, int> legacyEventIdMap,
  required Map<int, int> occurrenceIdMap,
  required Map<int, int> attendanceIdMap,
  required Map<String, String> slotKeyMap,
}) {
  if (auditMaps.isEmpty) return;

  for (final map in auditMaps) {
    final parsed = MigrationAuditRecordLocal.fromJson(map);
    final srcId = parsed.id;
    final srcServerId = _trimOrNull(parsed.serverId);
    final kindEnum = parseMigrationAuditKind(parsed.kind);
    final normalizedKind = kindEnum?.name ?? parsed.kind.trim();

    final destAttId =
        _remapPositiveId(parsed.attendanceRecordId, attendanceIdMap, strategy);
    final srcLegacyEvId = parsed.legacyEventId;
    final mappedLegacyEvId = (srcLegacyEvId != null && srcLegacyEvId > 0)
        ? legacyEventIdMap[srcLegacyEvId]
        : null;
    final destLegacyEvId = mappedLegacyEvId ??
        (strategy == ImportStrategy.replace
            ? srcLegacyEvId
            : (kindEnum == MigrationAuditKind.recoveredAttendance
                ? null
                : srcLegacyEvId));

    final destOccId =
        _remapPositiveId(parsed.occurrenceId, occurrenceIdMap, strategy);
    final destSourceOccId = _remapPositiveId(
      parsed.sourceOccurrenceId,
      occurrenceIdMap,
      strategy,
    );
    final destSubId =
        _remapPositiveId(parsed.subjectId, subjectIdMap, strategy);

    final srcSlotKey = _trimOrNull(parsed.slotKey);
    final destSlotKey = srcSlotKey != null
        ? (slotKeyMap[srcSlotKey] ??
            tryRemapCanonicalSlotKey(
              srcSlotKey,
              subjectIdMap: subjectIdMap,
              ruleIdMap: ruleIdMap,
              legacyEventIdMap: legacyEventIdMap,
              requireAllPositiveIdsMapped: strategy == ImportStrategy.merge,
            ))
        : null;

    final remappedCandidates = parsed.parsedCandidateOccurrenceIds
        .map((cId) => _remapPositiveId(cId, occurrenceIdMap, strategy))
        .whereType<int>()
        .toList(growable: false);
    final destCandidatesStr =
        MigrationAuditRecordLocal.formatCandidateOccurrenceIds(
      remappedCandidates,
    );

    final String destAuditKey;
    if (strategy == ImportStrategy.merge &&
        kindEnum != null &&
        parsed.attendanceRecordId != null &&
        parsed.attendanceRecordId! > 0 &&
        destAttId == null) {
      destAuditKey =
          '${kindEnum.name}|raw_att:${parsed.attendanceRecordId}|ev:${destLegacyEvId ?? parsed.sourceEventId ?? 0}';
    } else if (kindEnum != null) {
      destAuditKey = computeMigrationAuditKey(
        kind: kindEnum,
        attendanceRecordId: destAttId,
        legacyEventId: destLegacyEvId,
        sourceEventId: parsed.sourceEventId,
        occurrenceId: destOccId,
        sourceOccurrenceId: destSourceOccId,
        slotKey: destSlotKey,
        fallbackRawSourceOccurrenceId: parsed.sourceOccurrenceId,
      );
    } else if (parsed.auditKey.trim().isNotEmpty) {
      destAuditKey = parsed.auditKey.trim();
    } else {
      destAuditKey = 'audit_${srcServerId ?? generateUuid()}';
    }

    final matched = existingAuditsByKey[destAuditKey];
    final targetId = matched?.id ??
        (strategy == ImportStrategy.replace && srcId > 0
            ? srcId
            : isar.migrationAuditRecordLocals.autoIncrement());

    final preferredServerId = matched?.serverId ??
        ((destAuditKey != parsed.auditKey.trim() || srcServerId == null)
            ? 'audit_$destAuditKey'
            : srcServerId);

    final auditRecord = MigrationAuditRecordLocal()
      ..id = targetId
      ..serverId = _claimUniqueServerId(
        candidate: preferredServerId,
        used: usedAuditServerIds,
        keepExistingOnOwner: matched?.serverId,
      )
      ..auditKey = destAuditKey
      ..kind = normalizedKind
      ..attendanceRecordId = destAttId
      ..legacyEventId = destLegacyEvId
      ..sourceEventId =
          parsed.sourceEventId ?? srcLegacyEvId ?? matched?.sourceEventId
      ..occurrenceId = destOccId
      ..sourceOccurrenceId = destSourceOccId
      ..subjectId = destSubId
      ..slotKey = destSlotKey
      ..candidateOccurrenceIds = destCandidatesStr
      ..status = parsed.status
      ..eventDate = parsed.eventDate
      ..reason = (parsed.reason.trim().isEmpty && matched != null)
          ? matched.reason
          : parsed.reason
      ..diagnosticDetails =
          parsed.diagnosticDetails ?? matched?.diagnosticDetails
      ..createdAt = matched?.createdAt ?? parsed.createdAt
      ..updatedAt = parsed.updatedAt
      ..isDirty = parsed.isDirty
      ..isDeleted = parsed.isDeleted;

    isar.migrationAuditRecordLocals.put(auditRecord);
    existingAuditsByKey[destAuditKey] = auditRecord;
  }
}

Set<String> _collectServerIds(Iterable<String?> raw) {
  final set = <String>{};
  for (final s in raw) {
    final t = s?.trim();
    if (t != null && t.isNotEmpty) {
      set.add(t);
    }
  }
  return set;
}

String? _trimOrNull(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

String _claimUniqueServerId({
  required String? candidate,
  required Set<String> used,
  String? keepExistingOnOwner,
}) {
  if (keepExistingOnOwner != null && keepExistingOnOwner.trim().isNotEmpty) {
    final ownerKey = keepExistingOnOwner.trim();
    used.add(ownerKey);
    return ownerKey;
  }
  final trimmed = _trimOrNull(candidate);
  if (trimmed != null && !used.contains(trimmed)) {
    used.add(trimmed);
    return trimmed;
  }
  while (true) {
    final fresh = generateUuid();
    if (!used.contains(fresh)) {
      used.add(fresh);
      return fresh;
    }
  }
}

T? _firstOrNull<T>(Iterable<T> iterable) {
  final it = iterable.iterator;
  return it.moveNext() ? it.current : null;
}

class _NotificationRemapResult {
  final String? remappedRelatedId;
  final bool shouldSkipOnMerge;
  final String? missingParentType;
  final int missingParentSourceId;

  const _NotificationRemapResult({
    this.remappedRelatedId,
    this.shouldSkipOnMerge = false,
    this.missingParentType,
    this.missingParentSourceId = 0,
  });
}

_NotificationRemapResult _remapNotificationRelatedIdStrict({
  required String? rawRelatedId,
  required String type,
  required ImportStrategy strategy,
  required Map<int, int> subjectIdMap,
  required Map<int, int> ruleIdMap,
  required Map<int, int> occurrenceIdMap,
  required Map<int, int> legacyEventIdMap,
  required Map<String, String> slotKeyMap,
  required Map<int, int> academicEventIdMap,
  required Map<int, int> taskIdMap,
}) {
  if (rawRelatedId == null || rawRelatedId.trim().isEmpty) {
    return const _NotificationRemapResult(remappedRelatedId: null);
  }
  final raw = rawRelatedId.trim();

  if (raw.startsWith('slot:')) {
    final rawKey = raw.substring('slot:'.length);
    final cachedKey = slotKeyMap[rawKey];
    if (cachedKey != null) {
      return _NotificationRemapResult(remappedRelatedId: 'slot:$cachedKey');
    }
    final remappedKey = tryRemapCanonicalSlotKey(
      rawKey,
      subjectIdMap: subjectIdMap,
      ruleIdMap: ruleIdMap,
      legacyEventIdMap: legacyEventIdMap,
      requireAllPositiveIdsMapped: strategy == ImportStrategy.merge,
    );
    if (remappedKey != null) {
      return _NotificationRemapResult(remappedRelatedId: 'slot:$remappedKey');
    }
    return const _NotificationRemapResult(
      shouldSkipOnMerge: true,
      missingParentType: 'CanonicalSlot',
    );
  }
  if (raw.startsWith('occ:')) {
    final oldId = int.tryParse(raw.substring('occ:'.length));
    if (oldId != null && oldId > 0 && occurrenceIdMap.containsKey(oldId)) {
      return _NotificationRemapResult(
        remappedRelatedId: 'occ:${occurrenceIdMap[oldId]}',
      );
    }
    if (strategy == ImportStrategy.merge) {
      return _NotificationRemapResult(
        shouldSkipOnMerge: true,
        missingParentType: 'DailyScheduleOccurrenceLocal',
        missingParentSourceId: oldId ?? 0,
      );
    }
    return _NotificationRemapResult(remappedRelatedId: raw);
  }
  if (raw.startsWith('ae_1d:')) {
    final oldId = int.tryParse(raw.substring('ae_1d:'.length));
    if (oldId != null && oldId > 0 && academicEventIdMap.containsKey(oldId)) {
      return _NotificationRemapResult(
        remappedRelatedId: NotificationRelatedKeys.forAcademicEventOneDay(
          academicEventIdMap[oldId]!,
        ),
      );
    }
    if (strategy == ImportStrategy.merge) {
      return _NotificationRemapResult(
        shouldSkipOnMerge: true,
        missingParentType: 'AcademicEventLocal',
        missingParentSourceId: oldId ?? 0,
      );
    }
    return _NotificationRemapResult(remappedRelatedId: raw);
  }
  if (raw.startsWith('ae_30m:')) {
    final oldId = int.tryParse(raw.substring('ae_30m:'.length));
    if (oldId != null && oldId > 0 && academicEventIdMap.containsKey(oldId)) {
      return _NotificationRemapResult(
        remappedRelatedId: NotificationRelatedKeys.forAcademicEventThirtyMin(
          academicEventIdMap[oldId]!,
        ),
      );
    }
    if (strategy == ImportStrategy.merge) {
      return _NotificationRemapResult(
        shouldSkipOnMerge: true,
        missingParentType: 'AcademicEventLocal',
        missingParentSourceId: oldId ?? 0,
      );
    }
    return _NotificationRemapResult(remappedRelatedId: raw);
  }
  if (raw.startsWith('sub:')) {
    final oldId = int.tryParse(raw.substring('sub:'.length));
    if (oldId != null && oldId > 0 && subjectIdMap.containsKey(oldId)) {
      return _NotificationRemapResult(
        remappedRelatedId: NotificationRelatedKeys.forSubjectRisk(
          subjectIdMap[oldId]!,
        ),
      );
    }
    if (strategy == ImportStrategy.merge) {
      return _NotificationRemapResult(
        shouldSkipOnMerge: true,
        missingParentType: 'SubjectLocal',
        missingParentSourceId: oldId ?? 0,
      );
    }
    return _NotificationRemapResult(remappedRelatedId: raw);
  }
  if (raw.startsWith('task:')) {
    final oldId = int.tryParse(raw.substring('task:'.length));
    if (oldId != null && oldId > 0 && taskIdMap.containsKey(oldId)) {
      return _NotificationRemapResult(
        remappedRelatedId: NotificationRelatedKeys.forTask(taskIdMap[oldId]!),
      );
    }
    if (strategy == ImportStrategy.merge) {
      return _NotificationRemapResult(
        shouldSkipOnMerge: true,
        missingParentType: 'AcademicTaskLocal',
        missingParentSourceId: oldId ?? 0,
      );
    }
    return _NotificationRemapResult(remappedRelatedId: raw);
  }

  final numeric = int.tryParse(raw);
  if (numeric == null) {
    if (strategy == ImportStrategy.merge) {
      return const _NotificationRemapResult(
        shouldSkipOnMerge: true,
        missingParentType: 'EntityRef',
      );
    }
    return _NotificationRemapResult(remappedRelatedId: raw);
  }

  if (type == 'LOW_ATTENDANCE_ALERT' || type == 'ATTENDANCE_WARNING') {
    final mapped = subjectIdMap[numeric];
    if (mapped != null) {
      return _NotificationRemapResult(
        remappedRelatedId: NotificationRelatedKeys.forSubjectRisk(mapped),
      );
    }
    if (strategy == ImportStrategy.merge) {
      return _NotificationRemapResult(
        shouldSkipOnMerge: true,
        missingParentType: 'SubjectLocal',
        missingParentSourceId: numeric,
      );
    }
    return _NotificationRemapResult(remappedRelatedId: raw);
  }
  if (type == 'ASSIGNMENT_REMINDER') {
    final mapped = taskIdMap[numeric];
    if (mapped != null) {
      return _NotificationRemapResult(
        remappedRelatedId: NotificationRelatedKeys.forTask(mapped),
      );
    }
    if (strategy == ImportStrategy.merge) {
      return _NotificationRemapResult(
        shouldSkipOnMerge: true,
        missingParentType: 'AcademicTaskLocal',
        missingParentSourceId: numeric,
      );
    }
    return _NotificationRemapResult(remappedRelatedId: raw);
  }
  if (type == 'CLASS_REMINDER') {
    if (numeric > 200000 && academicEventIdMap.containsKey(numeric - 200000)) {
      return _NotificationRemapResult(
        remappedRelatedId: NotificationRelatedKeys.forAcademicEventThirtyMin(
          academicEventIdMap[numeric - 200000]!,
        ),
      );
    }
    if (numeric > 100000 && academicEventIdMap.containsKey(numeric - 100000)) {
      return _NotificationRemapResult(
        remappedRelatedId: NotificationRelatedKeys.forAcademicEventOneDay(
          academicEventIdMap[numeric - 100000]!,
        ),
      );
    }
    if (occurrenceIdMap.containsKey(numeric)) {
      return _NotificationRemapResult(
        remappedRelatedId: '${occurrenceIdMap[numeric]}',
      );
    }
    if (legacyEventIdMap.containsKey(numeric)) {
      return _NotificationRemapResult(
        remappedRelatedId: '${legacyEventIdMap[numeric]}',
      );
    }
    if (strategy == ImportStrategy.merge) {
      return _NotificationRemapResult(
        shouldSkipOnMerge: true,
        missingParentType: 'DailyScheduleOccurrenceLocal',
        missingParentSourceId: numeric,
      );
    }
    return _NotificationRemapResult(remappedRelatedId: raw);
  }

  if (strategy == ImportStrategy.merge) {
    return _NotificationRemapResult(
      shouldSkipOnMerge: true,
      missingParentType: 'EntityRef',
      missingParentSourceId: numeric,
    );
  }
  return _NotificationRemapResult(remappedRelatedId: raw);
}
