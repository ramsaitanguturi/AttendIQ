import 'dart:convert';
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
        UserPreferencesLocal? matched;
        if (strategy == ImportStrategy.merge && srcServerId != null) {
          matched = isar.userPreferencesLocals
              .where()
              .serverIdEqualTo(srcServerId)
              .findFirst();
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
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

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
            if (existing != null && existing.name == sem.name) {
              matched = existing;
            }
          }
          if (matched == null && !sem.isDeleted) {
            final normName = sem.name.trim().toLowerCase();
            final normStart = normalizeUtcDate(sem.startDate);
            final normEnd = normalizeUtcDate(sem.endDate);
            matched = _firstOrNull(
              destSemesters.where(
                (s) =>
                    !s.isDeleted &&
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
        destSemesters.add(sem);
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
        final destSemesterId = semesterIdMap[srcSemesterId] ?? srcSemesterId;
        final code = map['code'] as String? ?? '';
        final type = map['type'] as String? ?? 'THEORY';

        SubjectLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final byServer = isar.subjectLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.semesterId == destSemesterId &&
                byServer.code == code) {
              matched = byServer;
            }
          }
          matched ??= _firstOrNull(
            destSubjects.where(
              (s) =>
                  !s.isDeleted &&
                  s.semesterId == destSemesterId &&
                  s.code.trim().toUpperCase() == code.trim().toUpperCase() &&
                  s.type.trim().toUpperCase() == type.trim().toUpperCase(),
            ),
          );
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
          ..name = map['name'] as String? ?? ''
          ..code = code
          ..faculty = map['faculty'] as String?
          ..credits = map['credits'] as int? ?? 3
          ..attendanceTarget =
              (map['attendanceTarget'] as num?)?.toDouble() ?? 75.0
          ..color = map['color'] as String? ?? '0xFF10B981'
          ..type = type
          ..createdAt = DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        isar.subjectLocals.put(sub);
        destSubjects.add(sub);
        if (srcId > 0) {
          subjectIdMap[srcId] = sub.id;
        }
      }

      // 4. Legacy Timetable Templates
      for (final map in data.timetable) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int? ?? 0;
        final destSubId = subjectIdMap[srcSubId] ?? srcSubId;
        final weekday = map['weekday'] as int? ?? 1;
        final startTime = map['startTime'] as String? ?? '09:00';
        final endTime = map['endTime'] as String? ?? '10:00';

        TimetableTemplateLocal? matched;
        if (strategy == ImportStrategy.merge && srcServerId != null) {
          final existing = isar.timetableTemplateLocals
              .where()
              .serverIdEqualTo(srcServerId)
              .findFirst();
          if (existing != null &&
              existing.subjectId == destSubId &&
              existing.weekday == weekday &&
              existing.startTime == startTime &&
              existing.endTime == endTime) {
            matched = existing;
          }
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
          ..createdAt = DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        isar.timetableTemplateLocals.put(tt);
        if (srcId > 0) {
          templateIdMap[srcId] = tt.id;
        }
      }

      // 5. Legacy Events
      for (final map in data.events) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int? ?? 0;
        final destSubId = subjectIdMap[srcSubId] ?? srcSubId;
        final date = normalizeUtcDate(
          DateTime.tryParse(map['date'] as String? ?? '') ??
              DateTime.now().toUtc(),
        );
        final startTime = map['startTime'] as String? ?? '09:00';
        final endTime = map['endTime'] as String? ?? '10:00';
        final eventType = map['eventType'] as String? ?? 'REGULAR_CLASS';

        EventLocal? matched;
        if (strategy == ImportStrategy.merge && srcServerId != null) {
          final existing =
              isar.eventLocals.where().serverIdEqualTo(srcServerId).findFirst();
          if (existing != null &&
              existing.subjectId == destSubId &&
              normalizeUtcDate(existing.date).isAtSameMomentAs(date) &&
              existing.startTime == startTime &&
              existing.endTime == endTime) {
            matched = existing;
          }
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
          ..status = map['status'] as String? ?? 'UNMARKED'
          ..createdAt = DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        isar.eventLocals.put(ev);
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
        final destSubId = subjectIdMap[srcSubId] ?? srcSubId;
        final srcLegacyTplId = map['legacyTemplateId'] as int?;
        final destLegacyTplId = srcLegacyTplId != null
            ? (templateIdMap[srcLegacyTplId] ??
                (strategy == ImportStrategy.replace ? srcLegacyTplId : null))
            : null;

        final dayOfWeek = map['dayOfWeek'] as int? ?? 1;
        final startTime = normalizeTimeSlotPart(
          map['startTime'] as String? ?? '09:00',
        );
        final endTime = normalizeTimeSlotPart(
          map['endTime'] as String? ?? '10:00',
        );
        final inferredType = (map['type'] as String?) ??
            destSubjectById[destSubId]?.type ??
            'THEORY';
        final normType =
            inferredType.trim().toUpperCase() == 'LAB' ? 'LAB' : 'THEORY';
        final isDeleted = map['isDeleted'] as bool? ?? false;

        WeeklyScheduleRuleLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (srcServerId != null) {
            final byServer = isar.weeklyScheduleRuleLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.subjectId == destSubId &&
                byServer.dayOfWeek == dayOfWeek &&
                normalizeTimeSlotPart(byServer.startTime) == startTime &&
                normalizeTimeSlotPart(byServer.endTime) == endTime) {
              matched = byServer;
            }
          }
          if (matched == null && !isDeleted) {
            matched = _firstOrNull(
              destRules.where(
                (r) =>
                    !r.isDeleted &&
                    r.subjectId == destSubId &&
                    r.dayOfWeek == dayOfWeek &&
                    normalizeTimeSlotPart(r.startTime) == startTime &&
                    normalizeTimeSlotPart(r.endTime) == endTime &&
                    r.type.toUpperCase() == normType,
              ),
            );
          }
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
              DateTime.now().toUtc()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = isDeleted;

        isar.weeklyScheduleRuleLocals.put(rule);
        destRules.add(rule);
        if (srcId > 0) {
          ruleIdMap[srcId] = rule.id;
        }
        if (srcServerId != null) {
          ruleBySrcServerId[srcServerId] = rule;
        }
      }

      // 7. Daily Schedule Occurrences (remapping subjectId, ruleId, legacyEventId & slotKey)
      for (final map in data.occurrences) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int?;
        final destSubId =
            srcSubId != null ? (subjectIdMap[srcSubId] ?? srcSubId) : null;

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

        final occDate = normalizeUtcDate(
          DateTime.tryParse(map['date'] as String? ?? '') ??
              DateTime.now().toUtc(),
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
        final srcSlotKey = _trimOrNull(map['slotKey'] as String?);
        final isLegacyDisambiguated =
            srcSlotKey != null && srcSlotKey.startsWith('LEGACY_EV:');
        final isDeleted = map['isDeleted'] as bool? ?? false;

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
        if (strategy == ImportStrategy.merge && srcServerId != null) {
          final byServer = isar.dailyScheduleOccurrenceLocals
              .where()
              .serverIdEqualTo(srcServerId)
              .findFirst();
          if (byServer != null &&
              byServer.subjectId == destSubId &&
              normalizeUtcDate(byServer.date).isAtSameMomentAs(occDate) &&
              normalizeTimeSlotPart(byServer.startTime) == startTime &&
              normalizeTimeSlotPart(byServer.endTime) == endTime &&
              byServer.type.toUpperCase() == type) {
            matched = byServer;
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
          ..status = map['status'] as String? ?? 'UPCOMING'
          ..createdFrom = map['createdFrom'] as String? ?? 'WEEKLY_RULE'
          ..room = map['room'] as String?
          ..faculty = map['faculty'] as String?
          ..reason = map['reason'] as String?
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
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

        if (destOccurrenceId != null && destOccurrenceId > 0) {
          destCompatibilityEventId = destOccurrenceId;
        } else if (destLegacyEventId != null && destLegacyEventId > 0) {
          destCompatibilityEventId = destLegacyEventId;
        } else if (strategy == ImportStrategy.replace) {
          destCompatibilityEventId = srcEventId;
        } else {
          // Do not leave a raw source eventId pointing at an unrelated
          // destination occurrence during Merge when no legacy event or
          // occurrence was mapped from the backup.
          destCompatibilityEventId = 0;
        }

        AttendanceRecordLocal? matched;
        if (strategy == ImportStrategy.merge) {
          if (destOccurrenceId != null && destOccurrenceId > 0) {
            matched = isar.attendanceRecordLocals
                .where()
                .occurrenceIdEqualTo(destOccurrenceId)
                .findFirst();
          }
          if (matched == null && srcServerId != null) {
            final byServer = isar.attendanceRecordLocals
                .where()
                .serverIdEqualTo(srcServerId)
                .findFirst();
            if (byServer != null &&
                byServer.subjectId == destSubId &&
                (byServer.occurrenceId == destOccurrenceId ||
                    destOccurrenceId == null)) {
              matched = byServer;
            }
          }
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
          ..occurrenceId = destOccurrenceId
          ..legacyEventId = destLegacyEventId
          ..eventId = destCompatibilityEventId
          ..subjectId = destSubId
          ..status = map['status'] as String? ?? 'PRESENT'
          ..markedAt = DateTime.tryParse(map['markedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        isar.attendanceRecordLocals.put(att);
        if (srcId > 0) {
          attendanceIdMap[srcId] = att.id;
        }
      }

      // 9. Schedule Exceptions (remapping subjectId)
      for (final map in data.scheduleExceptions) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int?;
        final destSubId =
            srcSubId != null ? (subjectIdMap[srcSubId] ?? srcSubId) : null;
        final exDate = normalizeUtcDate(
          DateTime.tryParse(map['date'] as String? ?? '') ??
              DateTime.now().toUtc(),
        );
        final exType = map['type'] as String? ?? 'HOLIDAY';
        final title = map['title'] as String? ?? '';

        ScheduleExceptionLocal? matched;
        if (strategy == ImportStrategy.merge && srcServerId != null) {
          final byServer = isar.scheduleExceptionLocals
              .where()
              .serverIdEqualTo(srcServerId)
              .findFirst();
          if (byServer != null &&
              byServer.subjectId == destSubId &&
              normalizeUtcDate(byServer.date).isAtSameMomentAs(exDate) &&
              byServer.type == exType) {
            matched = byServer;
          }
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
          ..type = exType
          ..title = title
          ..description = map['description'] as String?
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        isar.scheduleExceptionLocals.put(ex);
      }

      // 10. Academic Events
      for (final map in data.academicEvents) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final aeDate = normalizeUtcDate(
          DateTime.tryParse(map['date'] as String? ?? '') ??
              DateTime.now().toUtc(),
        );
        final title = map['title'] as String? ?? '';

        AcademicEventLocal? matched;
        if (strategy == ImportStrategy.merge && srcServerId != null) {
          final byServer = isar.academicEventLocals
              .where()
              .serverIdEqualTo(srcServerId)
              .findFirst();
          if (byServer != null &&
              byServer.title == title &&
              normalizeUtcDate(byServer.date).isAtSameMomentAs(aeDate)) {
            matched = byServer;
          }
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
          ..startTime = map['startTime'] as String?
          ..endTime = map['endTime'] as String?
          ..type = map['type'] as String? ?? 'EVENT'
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        isar.academicEventLocals.put(ae);
        if (srcId > 0) {
          academicEventIdMap[srcId] = ae.id;
        }
      }

      // 11. Tasks (remapping subjectId)
      for (final map in data.tasks) {
        final srcId = map['id'] as int? ?? 0;
        final srcServerId = _trimOrNull(map['serverId'] as String?);
        final srcSubId = map['subjectId'] as int?;
        final destSubId =
            srcSubId != null ? (subjectIdMap[srcSubId] ?? srcSubId) : null;
        final title = map['title'] as String? ?? '';

        AcademicTaskLocal? matched;
        if (strategy == ImportStrategy.merge && srcServerId != null) {
          final byServer = isar.academicTaskLocals
              .where()
              .serverIdEqualTo(srcServerId)
              .findFirst();
          if (byServer != null &&
              byServer.subjectId == destSubId &&
              byServer.title == title) {
            matched = byServer;
          }
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
          ..startDate = DateTime.tryParse(map['startDate'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..dueDate = DateTime.tryParse(map['dueDate'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..priority = map['priority'] as String? ?? 'MEDIUM'
          ..taskType = map['taskType'] as String? ?? 'ASSIGNMENT'
          ..status = map['status'] as String? ?? 'PENDING'
          ..reminder = map['reminder'] as String? ?? 'NONE'
          ..createdAt = matched?.createdAt ??
              DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..updatedAt = DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
              DateTime.now().toUtc()
          ..isDirty = map['isDirty'] as bool? ?? false
          ..isDeleted = map['isDeleted'] as bool? ?? false;

        isar.academicTaskLocals.put(tk);
        if (srcId > 0) {
          taskIdMap[srcId] = tk.id;
        }
      }

      // 12. Notifications (remapping typed/legacy relatedId after all parents)
      for (final map in data.notifications) {
        final srcId = map['id'] as int? ?? 0;
        final notifType = map['type'] as String? ?? 'CLASS_REMINDER';
        final rawRelatedId = map['relatedId'] as String?;
        final remappedRelatedId = _remapNotificationRelatedId(
          rawRelatedId: rawRelatedId,
          type: notifType,
          strategy: strategy,
          subjectIdMap: subjectIdMap,
          ruleIdMap: ruleIdMap,
          occurrenceIdMap: occurrenceIdMap,
          legacyEventIdMap: legacyEventIdMap,
          slotKeyMap: slotKeyMap,
          academicEventIdMap: academicEventIdMap,
          taskIdMap: taskIdMap,
        );

        final targetId = (strategy == ImportStrategy.replace && srcId > 0)
            ? srcId
            : isar.notificationItems.autoIncrement();

        final notif = NotificationItem()
          ..id = targetId
          ..title = map['title'] as String? ?? ''
          ..body = map['body'] as String? ?? ''
          ..type = notifType
          ..scheduledTime =
              DateTime.tryParse(map['scheduledTime'] as String? ?? '') ??
                  DateTime.now().toUtc()
          ..relatedId = remappedRelatedId
          ..isRead = map['isRead'] as bool? ?? false;

        isar.notificationItems.put(notif);
      }

      // 12.5. Migration Audit Records (remapping parent IDs & stable auditKeys)
      _importMigrationAuditsInTx(
        isar,
        auditMaps: data.migrationAudits,
        strategy: strategy,
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
    });

    // Ensure NotificationItem persisted Android IDs remain unique and valid 32-bit.
    await migrateLegacyNotificationItems(_isar);
  }
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
  required Map<int, int> subjectIdMap,
  required Map<int, int> ruleIdMap,
  required Map<int, int> legacyEventIdMap,
  required Map<int, int> occurrenceIdMap,
  required Map<int, int> attendanceIdMap,
  required Map<String, String> slotKeyMap,
}) {
  if (auditMaps.isEmpty) return;

  final existingAudits = strategy == ImportStrategy.merge
      ? isar.migrationAuditRecordLocals.where().findAll()
      : <MigrationAuditRecordLocal>[];
  final usedAuditServerIds = _collectServerIds(
    existingAudits.map((e) => e.serverId),
  );
  final existingAuditsByKey = <String, MigrationAuditRecordLocal>{
    for (final a in existingAudits) a.auditKey: a,
  };

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
            remapCanonicalSlotKey(
              srcSlotKey,
              subjectIdMap: subjectIdMap,
              ruleIdMap: ruleIdMap,
              legacyEventIdMap: legacyEventIdMap,
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
    if (kindEnum != null) {
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
      ..sourceEventId = parsed.sourceEventId ?? srcLegacyEvId
      ..occurrenceId = destOccId
      ..sourceOccurrenceId = destSourceOccId
      ..subjectId = destSubId
      ..slotKey = destSlotKey
      ..candidateOccurrenceIds = destCandidatesStr
      ..status = parsed.status
      ..eventDate = parsed.eventDate
      ..reason = parsed.reason
      ..diagnosticDetails = parsed.diagnosticDetails
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

String? _remapNotificationRelatedId({
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
    return rawRelatedId;
  }
  final raw = rawRelatedId.trim();

  if (raw.startsWith('slot:')) {
    final rawKey = raw.substring('slot:'.length);
    final remappedKey = slotKeyMap[rawKey] ??
        remapCanonicalSlotKey(
          rawKey,
          subjectIdMap: subjectIdMap,
          ruleIdMap: ruleIdMap,
          legacyEventIdMap: legacyEventIdMap,
        );
    return 'slot:$remappedKey';
  }
  if (raw.startsWith('occ:')) {
    final oldId = int.tryParse(raw.substring('occ:'.length));
    if (oldId != null && occurrenceIdMap.containsKey(oldId)) {
      return 'occ:${occurrenceIdMap[oldId]}';
    }
    return raw;
  }
  if (raw.startsWith('ae_1d:')) {
    final oldId = int.tryParse(raw.substring('ae_1d:'.length));
    if (oldId != null && academicEventIdMap.containsKey(oldId)) {
      return NotificationRelatedKeys.forAcademicEventOneDay(
        academicEventIdMap[oldId]!,
      );
    }
    return raw;
  }
  if (raw.startsWith('ae_30m:')) {
    final oldId = int.tryParse(raw.substring('ae_30m:'.length));
    if (oldId != null && academicEventIdMap.containsKey(oldId)) {
      return NotificationRelatedKeys.forAcademicEventThirtyMin(
        academicEventIdMap[oldId]!,
      );
    }
    return raw;
  }
  if (raw.startsWith('sub:')) {
    final oldId = int.tryParse(raw.substring('sub:'.length));
    if (oldId != null && subjectIdMap.containsKey(oldId)) {
      return NotificationRelatedKeys.forSubjectRisk(subjectIdMap[oldId]!);
    }
    return raw;
  }
  if (raw.startsWith('task:')) {
    final oldId = int.tryParse(raw.substring('task:'.length));
    if (oldId != null && taskIdMap.containsKey(oldId)) {
      return NotificationRelatedKeys.forTask(taskIdMap[oldId]!);
    }
    return raw;
  }

  final numeric = int.tryParse(raw);
  if (numeric == null) return raw;

  if (type == 'LOW_ATTENDANCE_ALERT' || type == 'ATTENDANCE_WARNING') {
    final mapped = subjectIdMap[numeric];
    if (mapped != null) {
      return NotificationRelatedKeys.forSubjectRisk(mapped);
    }
    return raw;
  }
  if (type == 'ASSIGNMENT_REMINDER') {
    final mapped = taskIdMap[numeric];
    if (mapped != null) {
      return NotificationRelatedKeys.forTask(mapped);
    }
    return raw;
  }
  if (type == 'CLASS_REMINDER') {
    if (numeric > 200000 && academicEventIdMap.containsKey(numeric - 200000)) {
      return NotificationRelatedKeys.forAcademicEventThirtyMin(
        academicEventIdMap[numeric - 200000]!,
      );
    }
    if (numeric > 100000 && academicEventIdMap.containsKey(numeric - 100000)) {
      return NotificationRelatedKeys.forAcademicEventOneDay(
        academicEventIdMap[numeric - 100000]!,
      );
    }
    if (occurrenceIdMap.containsKey(numeric)) {
      return '${occurrenceIdMap[numeric]}';
    }
    if (legacyEventIdMap.containsKey(numeric)) {
      return '${legacyEventIdMap[numeric]}';
    }
    if (strategy == ImportStrategy.merge) {
      return null;
    }
  }
  return raw;
}
