import 'dart:developer' as developer;

import 'package:isar/isar.dart';

import '../../features/attendance/data/models/attendance_record_local.dart';
import '../../features/subject/data/models/subject_local.dart';
import '../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../features/timetable/data/models/timetable_template_local.dart';
import '../../features/timetable/data/models/weekly_schedule_rule_local.dart';
import '../../features/timetable/data/utils/occurrence_identity.dart';
import '../event_generator/data/models/event_local.dart';
import '../utils/uuid_generator.dart';

enum MigrationAuditKind {
  duplicateOccurrenceMerged,
  missingOccurrenceTarget,
  subjectMismatch,
  ambiguousAttendanceCollision,
  recoveredAttendance,
}

class MigrationAuditEntry {
  final MigrationAuditKind kind;
  final int? attendanceRecordId;
  final int? legacyEventId;
  final int? occurrenceId;
  final int? subjectId;
  final String? status;
  final DateTime? date;
  final String reason;

  const MigrationAuditEntry({
    required this.kind,
    this.attendanceRecordId,
    this.legacyEventId,
    this.occurrenceId,
    this.subjectId,
    this.status,
    this.date,
    required this.reason,
  });

  @override
  String toString() {
    return 'MigrationAuditEntry($kind, att=$attendanceRecordId, '
        'legacyEv=$legacyEventId, occ=$occurrenceId, sub=$subjectId, '
        'status=$status, date=$date, reason=$reason)';
  }
}

class MigrationAuditReport {
  final int rulesMigrated;
  final int occurrencesBackfilled;
  final int occurrencesMigratedFromLegacy;
  final int duplicateOccurrencesMerged;
  final int attendanceLinked;
  final int attendanceRecovered;
  final List<MigrationAuditEntry> entries;

  const MigrationAuditReport({
    this.rulesMigrated = 0,
    this.occurrencesBackfilled = 0,
    this.occurrencesMigratedFromLegacy = 0,
    this.duplicateOccurrencesMerged = 0,
    this.attendanceLinked = 0,
    this.attendanceRecovered = 0,
    this.entries = const <MigrationAuditEntry>[],
  });

  List<MigrationAuditEntry> entriesOfKind(MigrationAuditKind kind) =>
      entries.where((e) => e.kind == kind).toList(growable: false);
}

/// Runs the full additive, idempotent BUG-004 timetable/event/attendance
/// unification inside a single exclusive Isar write transaction.
Future<MigrationAuditReport> migrateLegacyTimetableAndEvents(Isar isar) async {
  if (!isar.isOpen) {
    return const MigrationAuditReport();
  }
  return isar.writeAsync<MigrationAuditReport>(
    runTimetableUnificationInWriteTx,
  );
}

/// Executes BUG-004 rule, occurrence, slotKey, deduplication, and conservative
/// attendance recovery phases inside an active Isar write transaction.
///
/// Safe to execute repeatedly (startup, post-backup import, DB reopen) without
/// creating duplicate rules, occurrences, or attendance rows.
MigrationAuditReport runTimetableUnificationInWriteTx(Isar isar) {
  final entries = <MigrationAuditEntry>[];
  final now = DateTime.now().toUtc();

  final rulesMigrated = _migrateTemplatesToRulesInTx(isar, now: now);
  final activeRules =
      isar.weeklyScheduleRuleLocals.where().isDeletedEqualTo(false).findAll();

  final backfillResult = _backfillAndDeduplicateOccurrencesInTx(
    isar,
    activeRules: activeRules,
    entries: entries,
    now: now,
  );

  final legacyEventsMigrated = _migrateLegacyEventsToOccurrencesInTx(
    isar,
    activeRules: activeRules,
    now: now,
  );

  final attendanceResult = _reconcileAttendanceInTx(
    isar,
    entries: entries,
    now: now,
  );

  final report = MigrationAuditReport(
    rulesMigrated: rulesMigrated,
    occurrencesBackfilled: backfillResult.backfilledCount,
    occurrencesMigratedFromLegacy: legacyEventsMigrated,
    duplicateOccurrencesMerged: backfillResult.mergedDuplicatesCount,
    attendanceLinked: attendanceResult.linkedCount,
    attendanceRecovered: attendanceResult.recoveredCount,
    entries: List<MigrationAuditEntry>.unmodifiable(entries),
  );

  for (final entry in entries) {
    if (entry.kind == MigrationAuditKind.ambiguousAttendanceCollision ||
        entry.kind == MigrationAuditKind.subjectMismatch ||
        entry.kind == MigrationAuditKind.missingOccurrenceTarget) {
      developer.log(
        entry.toString(),
        name: 'TimetableMigrationAudit',
      );
    }
  }

  return report;
}

int _migrateTemplatesToRulesInTx(
  Isar isar, {
  required DateTime now,
}) {
  final templates = isar.timetableTemplateLocals.where().findAll();
  if (templates.isEmpty) return 0;

  final existingRules = isar.weeklyScheduleRuleLocals.where().findAll();
  final subjects = isar.subjectLocals.where().findAll();
  final subjectById = <int, SubjectLocal>{for (final s in subjects) s.id: s};
  final usedServerIds = existingRules
      .map((r) => r.serverId)
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .toSet();

  var migratedCount = 0;

  for (final template in templates) {
    final alreadyLinkedById =
        existingRules.any((r) => r.legacyTemplateId == template.id);
    if (alreadyLinkedById) continue;

    final start = normalizeTimeSlotPart(template.startTime);
    final end = normalizeTimeSlotPart(template.endTime);
    final expectedType =
        subjectById[template.subjectId]?.type.trim().toUpperCase() == 'LAB'
            ? 'LAB'
            : 'THEORY';

    WeeklyScheduleRuleLocal? matchingRule;
    for (final r in existingRules) {
      if (!r.isDeleted &&
          r.subjectId == template.subjectId &&
          r.dayOfWeek == template.weekday &&
          normalizeTimeSlotPart(r.startTime) == start &&
          normalizeTimeSlotPart(r.endTime) == end) {
        matchingRule = r;
        break;
      }
    }

    if (matchingRule != null) {
      var changed = false;
      if (matchingRule.legacyTemplateId == null) {
        matchingRule.legacyTemplateId = template.id;
        changed = true;
      }
      if (matchingRule.type.toUpperCase() != expectedType &&
          expectedType == 'LAB') {
        matchingRule.type = expectedType;
        changed = true;
      }
      if (changed) {
        matchingRule.updatedAt = now;
        isar.weeklyScheduleRuleLocals.put(matchingRule);
      }
      continue;
    }

    if (template.isDeleted) continue;

    final serverId = _resolveUniqueRuleServerId(
      isar,
      candidate: template.serverId,
      fallback: 'legacy_tpl_${template.id}',
      usedServerIds: usedServerIds,
    );
    usedServerIds.add(serverId);

    final rule = WeeklyScheduleRuleLocal()
      ..id = isar.weeklyScheduleRuleLocals.autoIncrement()
      ..serverId = serverId
      ..subjectId = template.subjectId
      ..legacyTemplateId = template.id
      ..dayOfWeek = template.weekday
      ..startTime = start
      ..endTime = end
      ..room = template.room
      ..faculty = template.faculty
      ..type = expectedType
      ..isActive = true
      ..createdAt = template.createdAt
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;

    isar.weeklyScheduleRuleLocals.put(rule);
    existingRules.add(rule);
    migratedCount++;
  }

  return migratedCount;
}

String _resolveUniqueRuleServerId(
  Isar isar, {
  required String? candidate,
  required String fallback,
  required Set<String> usedServerIds,
}) {
  final trimmed = candidate?.trim();
  if (trimmed != null &&
      trimmed.isNotEmpty &&
      !usedServerIds.contains(trimmed) &&
      isar.weeklyScheduleRuleLocals
              .where()
              .serverIdEqualTo(trimmed)
              .findFirst() ==
          null) {
    return trimmed;
  }
  if (!usedServerIds.contains(fallback) &&
      isar.weeklyScheduleRuleLocals
              .where()
              .serverIdEqualTo(fallback)
              .findFirst() ==
          null) {
    return fallback;
  }
  while (true) {
    final generated = generateUuid();
    if (!usedServerIds.contains(generated) &&
        isar.weeklyScheduleRuleLocals
                .where()
                .serverIdEqualTo(generated)
                .findFirst() ==
            null) {
      return generated;
    }
  }
}

class _BackfillResult {
  final int backfilledCount;
  final int mergedDuplicatesCount;
  const _BackfillResult(this.backfilledCount, this.mergedDuplicatesCount);
}

_BackfillResult _backfillAndDeduplicateOccurrencesInTx(
  Isar isar, {
  required List<WeeklyScheduleRuleLocal> activeRules,
  required List<MigrationAuditEntry> entries,
  required DateTime now,
}) {
  final occurrences = isar.dailyScheduleOccurrenceLocals
      .where()
      .isDeletedEqualTo(false)
      .findAll();
  if (occurrences.isEmpty) {
    return const _BackfillResult(0, 0);
  }

  var backfilledCount = 0;

  for (final occ in occurrences) {
    final normalizedDate = normalizeUtcDate(occ.date);
    final normalizedStart = normalizeTimeSlotPart(occ.startTime);
    final normalizedEnd = normalizeTimeSlotPart(occ.endTime);

    var changed = false;
    if (!occ.date.isAtSameMomentAs(normalizedDate)) {
      occ.date = normalizedDate;
      changed = true;
    }
    if (occ.startTime != normalizedStart) {
      occ.startTime = normalizedStart;
      changed = true;
    }
    if (occ.endTime != normalizedEnd) {
      occ.endTime = normalizedEnd;
      changed = true;
    }

    if ((occ.type.toUpperCase() == 'REGULAR_CLASS' ||
            occ.createdFrom.toUpperCase() == 'WEEKLY_RULE') &&
        occ.ruleId == null &&
        occ.subjectId != null) {
      final matches = activeRules.where((r) {
        return r.isActive &&
            r.subjectId == occ.subjectId &&
            r.dayOfWeek == normalizedDate.weekday &&
            normalizeTimeSlotPart(r.startTime) == normalizedStart &&
            normalizeTimeSlotPart(r.endTime) == normalizedEnd;
      }).toList();
      if (matches.length == 1) {
        occ.ruleId = matches.single.id;
        changed = true;
      }
    }

    final preserveLegacyKey =
        occ.slotKey != null && occ.slotKey!.startsWith('LEGACY_EV:');
    if (!preserveLegacyKey) {
      final expectedKey = computeSlotKeyForLocal(occ);
      if (occ.slotKey != expectedKey) {
        occ.slotKey = expectedKey;
        changed = true;
      }
    }

    if (changed) {
      isar.dailyScheduleOccurrenceLocals.put(occ);
      backfilledCount++;
    }
  }

  // Group active occurrences by canonical slotKey to eliminate any pre-existing duplicates.
  final grouped = <String, List<DailyScheduleOccurrenceLocal>>{};
  for (final occ in occurrences) {
    final key = occ.slotKey;
    if (key == null || key.isEmpty) continue;
    grouped.putIfAbsent(key, () => <DailyScheduleOccurrenceLocal>[]).add(occ);
  }

  var mergedDuplicatesCount = 0;
  final duplicateGroups =
      grouped.values.where((group) => group.length > 1).toList();
  if (duplicateGroups.isNotEmpty) {
    final attendanceRecords = isar.attendanceRecordLocals.where().findAll();
    final claimedIds = <int>{
      for (final a in attendanceRecords)
        if (!a.isDeleted && a.occurrenceId != null) a.occurrenceId!,
    };

    for (final group in duplicateGroups) {
      group.sort(
        (a, b) => _compareOccurrenceSurvivorPriority(
          a,
          b,
          claimedOccurrenceIds: claimedIds,
          attendanceRecords: attendanceRecords,
        ),
      );
      final winner = group.first;

      for (final dup in group.skip(1)) {
        for (final a in attendanceRecords) {
          if (a.occurrenceId == dup.id) {
            a
              ..occurrenceId = winner.id
              ..eventId = winner.id
              ..updatedAt = now;
            isar.attendanceRecordLocals.put(a);
          }
        }
        dup
          ..isDeleted = true
          ..updatedAt = now;
        isar.dailyScheduleOccurrenceLocals.put(dup);
        mergedDuplicatesCount++;

        entries.add(
          MigrationAuditEntry(
            kind: MigrationAuditKind.duplicateOccurrenceMerged,
            occurrenceId: winner.id,
            legacyEventId: dup.legacyEventId ?? winner.legacyEventId,
            subjectId: winner.subjectId,
            status: winner.status,
            date: winner.date,
            reason:
                'Merged duplicate active occurrence ${dup.id} into canonical occurrence ${winner.id} for slotKey "${winner.slotKey}".',
          ),
        );
      }
    }
  }

  return _BackfillResult(backfilledCount, mergedDuplicatesCount);
}

int _compareOccurrenceSurvivorPriority(
  DailyScheduleOccurrenceLocal a,
  DailyScheduleOccurrenceLocal b, {
  required Set<int> claimedOccurrenceIds,
  required List<AttendanceRecordLocal> attendanceRecords,
}) {
  final aHasClaim = claimedOccurrenceIds.contains(a.id) ||
      attendanceRecords.any(
        (r) =>
            !r.isDeleted &&
            r.occurrenceId == null &&
            r.eventId == a.id &&
            r.subjectId == a.subjectId,
      );
  final bHasClaim = claimedOccurrenceIds.contains(b.id) ||
      attendanceRecords.any(
        (r) =>
            !r.isDeleted &&
            r.occurrenceId == null &&
            r.eventId == b.id &&
            r.subjectId == b.subjectId,
      );
  if (aHasClaim != bHasClaim) return aHasClaim ? -1 : 1;

  final aMarked = a.status.toUpperCase() != 'UPCOMING';
  final bMarked = b.status.toUpperCase() != 'UPCOMING';
  if (aMarked != bMarked) return aMarked ? -1 : 1;

  final updatedCmp = b.updatedAt.compareTo(a.updatedAt);
  if (updatedCmp != 0) return updatedCmp;

  return a.id.compareTo(b.id);
}

int _migrateLegacyEventsToOccurrencesInTx(
  Isar isar, {
  required List<WeeklyScheduleRuleLocal> activeRules,
  required DateTime now,
}) {
  final legacyEvents = isar.eventLocals.where().findAll();
  if (legacyEvents.isEmpty) return 0;

  final subjects = isar.subjectLocals.where().findAll();
  final subjectById = <int, SubjectLocal>{for (final s in subjects) s.id: s};

  final allAttendance = isar.attendanceRecordLocals.where().findAll();
  final activeOccurrences = isar.dailyScheduleOccurrenceLocals
      .where()
      .isDeletedEqualTo(false)
      .findAll();

  var migratedCount = 0;

  for (final ev in legacyEvents) {
    if (ev.isDeleted) continue;

    final alreadyLinked = activeOccurrences.any(
      (o) => o.legacyEventId == ev.id,
    );
    if (alreadyLinked) continue;

    final evDate = normalizeUtcDate(ev.date);
    final evStart = normalizeTimeSlotPart(ev.startTime);
    final evEnd = normalizeTimeSlotPart(ev.endTime);

    final matchingAttendanceForEv = allAttendance
        .where(
          (a) =>
              !a.isDeleted &&
              a.occurrenceId == null &&
              a.eventId == ev.id &&
              a.subjectId == ev.subjectId,
        )
        .toList();
    final isExtraFromAttendance = matchingAttendanceForEv.any(
      (a) => a.status == 'EXTRA_PRESENT' || a.status == 'EXTRA_ABSENT',
    );

    final rawEvType = ev.eventType.trim().toUpperCase();
    late final String occType;
    late final String createdFrom;
    int? resolvedRuleId;

    if (isExtraFromAttendance || rawEvType == 'EXTRA_CLASS') {
      occType = 'EXTRA_CLASS';
      createdFrom = 'MANUAL';
    } else if (rawEvType == 'EXAM') {
      occType = 'EXAM';
      createdFrom = 'MANUAL';
    } else if (rawEvType == 'EVENT') {
      occType = 'EVENT';
      createdFrom = 'MANUAL';
    } else {
      occType = 'REGULAR_CLASS';
      final ruleMatches = activeRules.where((r) {
        return r.subjectId == ev.subjectId &&
            r.dayOfWeek == evDate.weekday &&
            normalizeTimeSlotPart(r.startTime) == evStart &&
            normalizeTimeSlotPart(r.endTime) == evEnd;
      }).toList();
      if (ruleMatches.length == 1) {
        resolvedRuleId = ruleMatches.single.id;
        createdFrom = 'WEEKLY_RULE';
      } else {
        createdFrom = 'MANUAL';
      }
    }

    final occStatus = _mapLegacyEventStatusToOccurrenceStatus(ev.status);
    final subject = subjectById[ev.subjectId];
    final title = subject?.name ?? 'Subject ${ev.subjectId}';

    final naturalSlotKey = computeCanonicalSlotKey(
      date: evDate,
      subjectId: ev.subjectId,
      ruleId: resolvedRuleId,
      startTime: evStart,
      endTime: evEnd,
      type: occType,
      title: title,
      legacyEventId: ev.id,
    );

    final existingForNaturalSlot = isar.dailyScheduleOccurrenceLocals
        .where()
        .slotKeyEqualTo(naturalSlotKey)
        .isDeletedEqualTo(false)
        .findFirst();

    var useLegacyDisambiguation = false;
    var reuseExisting = false;

    if (existingForNaturalSlot != null) {
      final hasNativeAttendance = allAttendance.any(
        (a) => !a.isDeleted && a.occurrenceId == existingForNaturalSlot.id,
      );
      final statusesConflict =
          existingForNaturalSlot.status.toUpperCase() != 'UPCOMING' &&
              occStatus != 'UPCOMING' &&
              existingForNaturalSlot.status.toUpperCase() != occStatus;

      if (existingForNaturalSlot.legacyEventId == null &&
          !hasNativeAttendance &&
          !statusesConflict) {
        reuseExisting = true;
      } else {
        useLegacyDisambiguation = true;
      }
    }

    if (reuseExisting && existingForNaturalSlot != null) {
      existingForNaturalSlot
        ..legacyEventId = ev.id
        ..ruleId ??= resolvedRuleId
        ..status = existingForNaturalSlot.status.toUpperCase() == 'UPCOMING'
            ? occStatus
            : existingForNaturalSlot.status
        ..updatedAt = ev.updatedAt.isAfter(existingForNaturalSlot.updatedAt)
            ? ev.updatedAt
            : existingForNaturalSlot.updatedAt;
      isar.dailyScheduleOccurrenceLocals.put(existingForNaturalSlot);
      migratedCount++;
      continue;
    }

    final incoming = DailyScheduleOccurrenceLocal()
      ..serverId =
          ev.serverId != null ? 'legacy_ev_${ev.id}_${ev.serverId}' : null
      ..date = evDate
      ..subjectId = ev.subjectId
      ..ruleId = resolvedRuleId
      ..legacyEventId = ev.id
      ..slotKey = useLegacyDisambiguation
          ? computeCanonicalSlotKey(
              date: evDate,
              subjectId: ev.subjectId,
              ruleId: resolvedRuleId,
              startTime: evStart,
              endTime: evEnd,
              type: occType,
              title: title,
              legacyEventId: ev.id,
              forceLegacyDisambiguation: true,
            )
          : naturalSlotKey
      ..title = title
      ..startTime = evStart
      ..endTime = evEnd
      ..type = occType
      ..status = occStatus
      ..createdFrom = createdFrom
      ..faculty = subject?.faculty
      ..createdAt = ev.createdAt
      ..updatedAt = ev.updatedAt
      ..isDirty = ev.isDirty
      ..isDeleted = false;

    final saved = upsertCanonicalOccurrenceInWriteTx(
      isar,
      incoming,
      preferIncomingStatusOnMatch: false,
      preserveExistingCreatedAt: true,
    );
    activeOccurrences.add(saved);
    migratedCount++;
  }

  return migratedCount;
}

String _mapLegacyEventStatusToOccurrenceStatus(String legacyStatus) {
  switch (legacyStatus.trim().toUpperCase()) {
    case 'PRESENT':
    case 'EXTRA_PRESENT':
      return 'PRESENT';
    case 'ABSENT':
    case 'EXTRA_ABSENT':
      return 'ABSENT';
    case 'CANCELLED':
      return 'CANCELLED';
    case 'UNMARKED':
    case 'UPCOMING':
    default:
      return 'UPCOMING';
  }
}

class _AttendanceReconcileResult {
  final int linkedCount;
  final int recoveredCount;
  const _AttendanceReconcileResult(this.linkedCount, this.recoveredCount);
}

class _ScoredOccurrenceCandidate {
  final DailyScheduleOccurrenceLocal occurrence;
  final int score;
  final bool cameFromLegacyEvent;
  const _ScoredOccurrenceCandidate(
    this.occurrence,
    this.score, {
    required this.cameFromLegacyEvent,
  });
}

_AttendanceReconcileResult _reconcileAttendanceInTx(
  Isar isar, {
  required List<MigrationAuditEntry> entries,
  required DateTime now,
}) {
  final allAttendance = isar.attendanceRecordLocals.where().findAll();
  final allOccurrences = isar.dailyScheduleOccurrenceLocals.where().findAll();
  final legacyEvents = isar.eventLocals.where().findAll();

  final occById = <int, DailyScheduleOccurrenceLocal>{
    for (final o in allOccurrences) o.id: o,
  };
  final occByLegacyEventId = <int, DailyScheduleOccurrenceLocal>{
    for (final o in allOccurrences)
      if (!o.isDeleted && o.legacyEventId != null && o.legacyEventId! > 0)
        o.legacyEventId!: o,
  };
  final legacyEventById = <int, EventLocal>{
    for (final e in legacyEvents) e.id: e,
  };

  final claimedOccurrenceIds = <int>{
    for (final a in allAttendance)
      if (!a.isDeleted && a.occurrenceId != null && a.occurrenceId! > 0)
        a.occurrenceId!,
  };
  final unresolvedCollisionLegacyEventIds = <int>{};

  var linkedCount = 0;

  // Pass 1: Resolve canonical occurrenceId on legacy AttendanceRecordLocal rows
  // using multi-factor evidence rather than raw integer eventId equality.
  for (final record in allAttendance) {
    if (record.occurrenceId != null && record.occurrenceId! > 0) {
      continue;
    }

    if (record.eventId <= 0) {
      entries.add(
        MigrationAuditEntry(
          kind: MigrationAuditKind.missingOccurrenceTarget,
          attendanceRecordId: record.id,
          legacyEventId: record.legacyEventId,
          subjectId: record.subjectId,
          status: record.status,
          date: record.markedAt,
          reason:
              'Attendance record ${record.id} has non-positive eventId (${record.eventId}); kept unlinked without fabricating an occurrence.',
        ),
      );
      continue;
    }

    final rawCandidates = <DailyScheduleOccurrenceLocal>[];
    final fromDirectId = occById[record.eventId];
    if (fromDirectId != null && (!fromDirectId.isDeleted || record.isDeleted)) {
      rawCandidates.add(fromDirectId);
    }
    final fromLegacyEvent = occByLegacyEventId[record.eventId];
    if (fromLegacyEvent != null &&
        !rawCandidates.any((c) => c.id == fromLegacyEvent.id)) {
      rawCandidates.add(fromLegacyEvent);
    }

    if (rawCandidates.isEmpty) {
      record.legacyEventId ??= record.eventId;
      isar.attendanceRecordLocals.put(record);
      unresolvedCollisionLegacyEventIds.add(record.eventId);
      entries.add(
        MigrationAuditEntry(
          kind: MigrationAuditKind.missingOccurrenceTarget,
          attendanceRecordId: record.id,
          legacyEventId: record.eventId,
          subjectId: record.subjectId,
          status: record.status,
          date: record.markedAt,
          reason:
              'No occurrence or legacy event matches eventId=${record.eventId} for attendance record ${record.id}; kept unlinked for audit.',
        ),
      );
      continue;
    }

    var sawSubjectMismatch = false;
    final subjectValidCandidates = rawCandidates.where((cand) {
      if (cand.subjectId != record.subjectId) {
        sawSubjectMismatch = true;
        return false;
      }
      return true;
    }).toList();

    final scored = <_ScoredOccurrenceCandidate>[];
    for (final cand in subjectValidCandidates) {
      final score = _scoreAttendanceCandidate(
        record: record,
        candidate: cand,
        legacyEvent: cand.legacyEventId != null
            ? legacyEventById[cand.legacyEventId!]
            : null,
        claimedOccurrenceIds: claimedOccurrenceIds,
        hasMultipleCandidates: subjectValidCandidates.length > 1,
      );
      if (score != null) {
        scored.add(
          _ScoredOccurrenceCandidate(
            cand,
            score,
            cameFromLegacyEvent: cand.legacyEventId == record.eventId,
          ),
        );
      }
    }

    if (scored.isEmpty) {
      record.legacyEventId ??= record.eventId;
      isar.attendanceRecordLocals.put(record);
      unresolvedCollisionLegacyEventIds.add(record.eventId);
      entries.add(
        MigrationAuditEntry(
          kind: sawSubjectMismatch
              ? MigrationAuditKind.subjectMismatch
              : MigrationAuditKind.missingOccurrenceTarget,
          attendanceRecordId: record.id,
          legacyEventId: record.eventId,
          subjectId: record.subjectId,
          status: record.status,
          date: record.markedAt,
          reason: sawSubjectMismatch
              ? 'Candidate(s) for eventId=${record.eventId} failed mandatory subjectId (${record.subjectId}) alignment on attendance record ${record.id}.'
              : 'Candidate(s) for eventId=${record.eventId} failed plausibility validation on attendance record ${record.id}; kept unlinked.',
        ),
      );
      continue;
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final best = scored.first;

    final isAmbiguousTie =
        scored.length > 1 && (best.score - scored[1].score) < 15;
    if (isAmbiguousTie || best.score <= 0) {
      record.legacyEventId ??= record.eventId;
      isar.attendanceRecordLocals.put(record);
      unresolvedCollisionLegacyEventIds.add(record.eventId);
      entries.add(
        MigrationAuditEntry(
          kind: MigrationAuditKind.ambiguousAttendanceCollision,
          attendanceRecordId: record.id,
          legacyEventId: record.eventId,
          subjectId: record.subjectId,
          status: record.status,
          date: record.markedAt,
          reason:
              'Ambiguous collision across ${scored.length} occurrences (${scored.map((s) => s.occurrence.id).join(", ")}) for eventId=${record.eventId} on attendance record ${record.id}; left occurrenceId=null for audit.',
        ),
      );
      continue;
    }

    final winner = best.occurrence;
    record
      ..occurrenceId = winner.id
      ..eventId = winner.id
      ..legacyEventId ??= best.cameFromLegacyEvent
          ? winner.legacyEventId
          : (rawCandidates.any((c) => c.legacyEventId == record.eventId)
              ? record.eventId
              : null)
      ..updatedAt = record.updatedAt;
    isar.attendanceRecordLocals.put(record);
    if (!record.isDeleted) {
      claimedOccurrenceIds.add(winner.id);
    }
    linkedCount++;
  }

  // Pass 2: Conservative overwritten-record recovery for migrated EventLocals
  // that hold logged PRESENT/ABSENT attendance but have zero attendance records
  // (active or soft-deleted) bound to their canonical occurrence.
  var recoveredCount = 0;
  final refreshedAttendance = isar.attendanceRecordLocals.where().findAll();
  final existingOccurrenceAttendanceIds = <int>{
    for (final a in refreshedAttendance)
      if (a.occurrenceId != null) a.occurrenceId!,
  };
  final existingLegacyEventAttendanceIds = <int>{
    for (final a in refreshedAttendance)
      if (a.legacyEventId != null) a.legacyEventId!,
  };
  final existingRecoveryServerIds = <String>{
    for (final a in refreshedAttendance)
      if (a.serverId != null) a.serverId!,
  };

  for (final ev in legacyEvents) {
    if (ev.isDeleted) continue;
    final normEvStatus = ev.status.trim().toUpperCase();
    if (normEvStatus != 'PRESENT' && normEvStatus != 'ABSENT') {
      continue;
    }
    if (unresolvedCollisionLegacyEventIds.contains(ev.id)) {
      continue;
    }

    final targetOcc = occByLegacyEventId[ev.id];
    if (targetOcc == null || targetOcc.isDeleted) {
      continue;
    }

    final alreadyHasAttendance =
        existingOccurrenceAttendanceIds.contains(targetOcc.id) ||
            existingLegacyEventAttendanceIds.contains(ev.id) ||
            existingRecoveryServerIds.contains('recovered_att_ev_${ev.id}');
    if (alreadyHasAttendance) {
      continue;
    }

    // Do not auto-recover if any unresolved unlinked record already carries the
    // exact same subject, date, and legacy eventId waiting for manual audit.
    final hasUnresolvedPeer = refreshedAttendance.any(
      (a) =>
          a.occurrenceId == null &&
          a.subjectId == ev.subjectId &&
          (a.legacyEventId == ev.id || a.eventId == ev.id),
    );
    if (hasUnresolvedPeer) {
      continue;
    }

    final recoveredStatus = targetOcc.type.toUpperCase() == 'EXTRA_CLASS'
        ? (normEvStatus == 'PRESENT' ? 'EXTRA_PRESENT' : 'EXTRA_ABSENT')
        : normEvStatus;
    final recoveredDate = normalizeUtcDate(ev.date);
    final deterministicServerId = _resolveUniqueAttendanceServerId(
      isar,
      candidate: 'recovered_att_ev_${ev.id}',
      usedServerIds: existingRecoveryServerIds,
    );
    existingRecoveryServerIds.add(deterministicServerId);

    final recovered = AttendanceRecordLocal()
      ..id = isar.attendanceRecordLocals.autoIncrement()
      ..serverId = deterministicServerId
      ..occurrenceId = targetOcc.id
      ..legacyEventId = ev.id
      ..eventId = targetOcc.id
      ..subjectId = targetOcc.subjectId ?? ev.subjectId
      ..status = recoveredStatus
      ..markedAt = recoveredDate
      ..createdAt = ev.createdAt
      ..updatedAt = ev.updatedAt
      ..isDirty = false
      ..isDeleted = false;

    isar.attendanceRecordLocals.put(recovered);
    existingOccurrenceAttendanceIds.add(targetOcc.id);
    existingLegacyEventAttendanceIds.add(ev.id);
    recoveredCount++;

    entries.add(
      MigrationAuditEntry(
        kind: MigrationAuditKind.recoveredAttendance,
        attendanceRecordId: recovered.id,
        legacyEventId: ev.id,
        occurrenceId: targetOcc.id,
        subjectId: recovered.subjectId,
        status: recovered.status,
        date: recovered.markedAt,
        reason:
            'Recovered missing AttendanceRecordLocal from legacy EventLocal ${ev.id} (${ev.status} on ${formatUtcDateKey(recoveredDate)}) onto occurrence ${targetOcc.id}.',
      ),
    );
  }

  return _AttendanceReconcileResult(linkedCount, recoveredCount);
}

/// Scores how strongly [candidate] matches [record]. Returns `null` when the
/// candidate violates a hard plausibility rule (wrong date provenance on collision).
int? _scoreAttendanceCandidate({
  required AttendanceRecordLocal record,
  required DailyScheduleOccurrenceLocal candidate,
  required EventLocal? legacyEvent,
  required Set<int> claimedOccurrenceIds,
  required bool hasMultipleCandidates,
}) {
  final candDate = normalizeUtcDate(candidate.date);
  final markedDate = normalizeUtcDate(record.markedAt);
  final dateDiffDays = candDate.difference(markedDate).inDays;

  // An occurrence scheduled days AFTER the attendance was marked cannot be the
  // record's historical class slot when competing against another candidate (or
  // when clearly future-dated due to ID collision).
  if (dateDiffDays > 1 && hasMultipleCandidates) {
    return null;
  }

  var score = 0;

  // 1. Date evidence
  final absDiff = dateDiffDays.abs();
  if (absDiff == 0) {
    score += 40;
  } else if (absDiff == 1) {
    score += 20;
  } else if (candDate.isBefore(markedDate) && legacyEvent != null) {
    // Legacy flow allowed marking an earlier event later via EventLocal;
    // still positive score if came from legacy EventLocal, slight penalty vs exact match.
    score += 5;
  } else if (hasMultipleCandidates) {
    score -= 15;
  }

  // 2. Status compatibility
  final recStatus = _normalizeComparableStatus(record.status);
  final candStatus = _normalizeComparableStatus(candidate.status);
  if (record.isDeleted && candidate.isDeleted) {
    score += 30;
  } else if (!record.isDeleted && !candidate.isDeleted) {
    if (candStatus == recStatus) {
      score += 30;
    } else if (candStatus == 'UPCOMING') {
      score += 10;
    } else if (candStatus.isNotEmpty) {
      score -= 30;
    }
  } else {
    score -= 10;
  }

  if (record.status.toUpperCase().startsWith('EXTRA_') &&
      candidate.type.toUpperCase() == 'EXTRA_CLASS') {
    score += 10;
  }

  // 3. Timestamp proximity (markedAt / updatedAt vs candidate updatedAt / createdAt)
  final updatedDiffMinutes =
      record.updatedAt.difference(candidate.updatedAt).inMinutes.abs();
  final markedDiffMinutes =
      record.markedAt.difference(candidate.updatedAt).inMinutes.abs();
  final minDiff = updatedDiffMinutes < markedDiffMinutes
      ? updatedDiffMinutes
      : markedDiffMinutes;
  if (minDiff <= 5) {
    score += 20;
  } else if (minDiff <= 24 * 60) {
    score += 10;
  } else if (minDiff <= 7 * 24 * 60) {
    score += 3;
  }

  // 4. serverId & unclaimed status
  final recServerId = record.serverId?.trim();
  final candServerId = candidate.serverId?.trim();
  if (recServerId != null &&
      candServerId != null &&
      recServerId.isNotEmpty &&
      candServerId.isNotEmpty &&
      candServerId.contains(recServerId)) {
    score += 15;
  }

  if (!record.isDeleted) {
    if (claimedOccurrenceIds.contains(candidate.id)) {
      score -= 25;
    } else {
      score += 15;
    }
  }

  // Preserve unambiguous single non-conflicting legacy binding even when marked
  // days after the class date, while still rejecting genuine multi-candidate ties.
  if (!hasMultipleCandidates &&
      score <= 0 &&
      absDiff <= 30 &&
      dateDiffDays <= 1) {
    return 10;
  }

  return score;
}

String _normalizeComparableStatus(String raw) {
  switch (raw.trim().toUpperCase()) {
    case 'PRESENT':
    case 'EXTRA_PRESENT':
      return 'PRESENT';
    case 'ABSENT':
    case 'EXTRA_ABSENT':
      return 'ABSENT';
    case 'CANCELLED':
      return 'CANCELLED';
    case 'UPCOMING':
    case 'UNMARKED':
      return 'UPCOMING';
    default:
      return raw.trim().toUpperCase();
  }
}

String _resolveUniqueAttendanceServerId(
  Isar isar, {
  required String candidate,
  required Set<String> usedServerIds,
}) {
  if (!usedServerIds.contains(candidate) &&
      isar.attendanceRecordLocals
              .where()
              .serverIdEqualTo(candidate)
              .findFirst() ==
          null) {
    return candidate;
  }
  while (true) {
    final generated = generateUuid();
    if (!usedServerIds.contains(generated) &&
        isar.attendanceRecordLocals
                .where()
                .serverIdEqualTo(generated)
                .findFirst() ==
            null) {
      return generated;
    }
  }
}
