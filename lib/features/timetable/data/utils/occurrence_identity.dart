import 'package:isar/isar.dart';

import '../../../../core/utils/uuid_generator.dart';
import '../models/daily_schedule_occurrence_local.dart';
import '../../domain/entities/daily_schedule_occurrence.dart';

/// Normalizes [date] to midnight UTC preserving its intended calendar day
/// whether [date] is UTC, local, or an Isar-deserialized local timestamp
/// originally saved as midnight UTC.
DateTime normalizeUtcDate(DateTime date) {
  if (date.isUtc) {
    return DateTime.utc(date.year, date.month, date.day);
  }
  final utc = date.toUtc();
  if (utc.hour == 0 &&
      utc.minute == 0 &&
      utc.second == 0 &&
      utc.millisecond == 0 &&
      utc.microsecond == 0) {
    return DateTime.utc(utc.year, utc.month, utc.day);
  }
  return DateTime.utc(date.year, date.month, date.day);
}

/// Formats [date] as `yyyyMMdd` in normalized UTC calendar space.
String formatUtcDateKey(DateTime date) {
  final d = normalizeUtcDate(date);
  final year = d.year.toString().padLeft(4, '0');
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$year$month$day';
}

/// Normalizes an `HH:mm` time string (trimming and zero-padding hours).
String normalizeTimeSlotPart(String raw) {
  final trimmed = raw.trim();
  final parts = trimmed.split(':');
  if (parts.length < 2) {
    return trimmed;
  }
  final hour = int.tryParse(parts[0].trim());
  final minute = int.tryParse(parts[1].trim());
  if (hour == null || minute == null) {
    return trimmed;
  }
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Normalizes an event/exam title for deterministic key generation.
String normalizeTitleForKey(String raw) {
  return raw
      .trim()
      .toLowerCase()
      .replaceAll('|', '_')
      .replaceAll(RegExp(r'\s+'), ' ');
}

/// Computes the deterministic type-scoped canonical slot identity key for an
/// occurrence or unmaterialized weekly rule slot.
String computeCanonicalSlotKey({
  required DateTime date,
  int? subjectId,
  int? ruleId,
  required String startTime,
  required String endTime,
  required String type,
  String? title,
  int? legacyEventId,
  bool forceLegacyDisambiguation = false,
}) {
  if (forceLegacyDisambiguation && legacyEventId != null && legacyEventId > 0) {
    return 'LEGACY_EV:$legacyEventId';
  }

  final dateKey = formatUtcDateKey(date);
  final start = normalizeTimeSlotPart(startTime);
  final end = normalizeTimeSlotPart(endTime);
  final sub = subjectId ?? 0;
  final normalizedType = type.trim().toUpperCase();

  switch (normalizedType) {
    case 'REGULAR_CLASS':
    case 'WEEKLY_RULE':
      if (ruleId != null && ruleId > 0) {
        return 'REGULAR|rule:$ruleId|sub:$sub|$dateKey|$start-$end';
      }
      return 'REGULAR|sub:$sub|$dateKey|$start-$end';
    case 'EXTRA_CLASS':
      return 'EXTRA|sub:$sub|$dateKey|$start-$end';
    case 'EXAM':
      final normTitle = normalizeTitleForKey(
        (title == null || title.trim().isEmpty) ? 'exam' : title,
      );
      return 'EXAM|sub:$sub|$dateKey|$start-$end|$normTitle';
    case 'EVENT':
    default:
      final normTitle = normalizeTitleForKey(
        (title == null || title.trim().isEmpty) ? 'event' : title,
      );
      return 'EVENT|sub:$sub|$dateKey|$start-$end|$normTitle';
  }
}

/// Computes canonical `slotKey` directly from a [DailyScheduleOccurrenceLocal].
String computeSlotKeyForLocal(
  DailyScheduleOccurrenceLocal occurrence, {
  bool forceLegacyDisambiguation = false,
}) {
  return computeCanonicalSlotKey(
    date: occurrence.date,
    subjectId: occurrence.subjectId,
    ruleId: occurrence.ruleId,
    startTime: occurrence.startTime,
    endTime: occurrence.endTime,
    type: occurrence.type,
    title: occurrence.title,
    legacyEventId: occurrence.legacyEventId,
    forceLegacyDisambiguation: forceLegacyDisambiguation,
  );
}

/// Computes canonical `slotKey` directly from a domain [DailyScheduleOccurrence].
String computeSlotKeyForEntity(DailyScheduleOccurrence occurrence) {
  return computeCanonicalSlotKey(
    date: occurrence.date,
    subjectId: occurrence.subjectId,
    ruleId: occurrence.ruleId,
    startTime: occurrence.startTime,
    endTime: occurrence.endTime,
    type: occurrence.type.toShortString(),
    title: occurrence.title,
    legacyEventId: occurrence.legacyEventId,
  );
}

/// Rewrites integer `rule:<id>`, `sub:<id>`, and `LEGACY_EV:<id>` components
/// inside a canonical `slot:...` notification `relatedId` or raw `slotKey`.
///
/// When [requireAllPositiveIdsMapped] is `true` (used during `ImportStrategy.merge`),
/// returns `null` if any referenced positive `rule:<id>`, `sub:<id>`, or
/// `LEGACY_EV:<id>` cannot be resolved in the translation maps, or if a
/// `REGULAR`/`EXTRA` slot references `sub:0`.
String? tryRemapCanonicalSlotKey(
  String? rawSlotKey, {
  required Map<int, int> subjectIdMap,
  required Map<int, int> ruleIdMap,
  required Map<int, int> legacyEventIdMap,
  bool requireAllPositiveIdsMapped = false,
}) {
  if (rawSlotKey == null || rawSlotKey.trim().isEmpty) {
    return rawSlotKey;
  }
  final trimmed = rawSlotKey.trim();
  if (trimmed.startsWith('LEGACY_EV:')) {
    final oldEvId = int.tryParse(trimmed.substring('LEGACY_EV:'.length));
    if (oldEvId != null && legacyEventIdMap.containsKey(oldEvId)) {
      return 'LEGACY_EV:${legacyEventIdMap[oldEvId]}';
    }
    return requireAllPositiveIdsMapped ? null : trimmed;
  }

  final parts = trimmed.split('|');
  final slotType = parts.first.trim().toUpperCase();
  final allowsZeroSubject = slotType == 'EXAM' || slotType == 'EVENT';

  final rewritten = <String>[];
  for (final segment in parts) {
    if (segment.startsWith('rule:')) {
      final oldRuleId = int.tryParse(segment.substring('rule:'.length));
      if (oldRuleId != null &&
          oldRuleId > 0 &&
          ruleIdMap.containsKey(oldRuleId)) {
        rewritten.add('rule:${ruleIdMap[oldRuleId]}');
        continue;
      }
      if (requireAllPositiveIdsMapped) {
        return null;
      }
    } else if (segment.startsWith('sub:')) {
      final oldSubId = int.tryParse(segment.substring('sub:'.length));
      if (oldSubId != null &&
          oldSubId > 0 &&
          subjectIdMap.containsKey(oldSubId)) {
        rewritten.add('sub:${subjectIdMap[oldSubId]}');
        continue;
      }
      if (oldSubId == 0 && allowsZeroSubject) {
        rewritten.add('sub:0');
        continue;
      }
      if (requireAllPositiveIdsMapped) {
        return null;
      }
    }
    rewritten.add(segment);
  }
  return rewritten.join('|');
}

/// Rewrites integer `rule:<id>` and `sub:<id>` components inside a canonical
/// `slot:...` notification `relatedId` or raw `slotKey` during backup merge.
String? remapCanonicalSlotKey(
  String? rawSlotKey, {
  required Map<int, int> subjectIdMap,
  required Map<int, int> ruleIdMap,
  required Map<int, int> legacyEventIdMap,
}) {
  return tryRemapCanonicalSlotKey(
    rawSlotKey,
    subjectIdMap: subjectIdMap,
    ruleIdMap: ruleIdMap,
    legacyEventIdMap: legacyEventIdMap,
    requireAllPositiveIdsMapped: false,
  );
}

/// Namespace-safe notification `relatedId` helpers preventing cross-entity ID
/// collisions (`occurrence` vs `academic_event` vs `subject` vs `task`).
class NotificationRelatedKeys {
  static String forSlotKey(String slotKey) => 'slot:$slotKey';

  static String forAcademicEventOneDay(int academicEventId) =>
      'ae_1d:$academicEventId';

  static String forAcademicEventThirtyMin(int academicEventId) =>
      'ae_30m:$academicEventId';

  static String forSubjectRisk(int subjectId) => 'sub:$subjectId';

  static String forTask(int taskId) => 'task:$taskId';
}

/// Ensures [serverId] is unique within [DailyScheduleOccurrenceLocal] collection
/// in the active write transaction.
String resolveUniqueOccurrenceServerId(
  Isar isar,
  String? candidate, {
  int? excludingId,
  String Function()? fallbackGenerator,
}) {
  final gen = fallbackGenerator ?? generateUuid;
  final trimmed = candidate?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    final existing = isar.dailyScheduleOccurrenceLocals
        .where()
        .serverIdEqualTo(trimmed)
        .findFirst();
    if (existing == null || existing.id == excludingId) {
      return trimmed;
    }
  }
  while (true) {
    final generated = gen();
    final collision = isar.dailyScheduleOccurrenceLocals
        .where()
        .serverIdEqualTo(generated)
        .findFirst();
    if (collision == null || collision.id == excludingId) {
      return generated;
    }
  }
}

/// Finds an active (`!isDeleted`) [DailyScheduleOccurrenceLocal] matching
/// [incoming] using canonical slot identity priority inside a write tx:
/// 1) `legacyEventId` (when positive)
/// 2) `slotKey`
/// 3) semantic slot tuple `(date, subjectId, startTime, endTime, type, [ruleId/title])`
DailyScheduleOccurrenceLocal? findActiveCanonicalOccurrenceInTx(
  Isar isar,
  DailyScheduleOccurrenceLocal incoming,
) {
  if (incoming.legacyEventId != null && incoming.legacyEventId! > 0) {
    final byLegacy = isar.dailyScheduleOccurrenceLocals
        .where()
        .legacyEventIdEqualTo(incoming.legacyEventId)
        .isDeletedEqualTo(false)
        .findFirst();
    if (byLegacy != null) {
      return byLegacy;
    }
  }

  final key = incoming.slotKey?.trim();
  if (key != null && key.isNotEmpty) {
    final byKey = isar.dailyScheduleOccurrenceLocals
        .where()
        .slotKeyEqualTo(key)
        .isDeletedEqualTo(false)
        .findFirst();
    if (byKey != null) {
      return byKey;
    }
  }

  final normalizedDate = normalizeUtcDate(incoming.date);
  final dayStart = normalizedDate;
  final dayEnd = DateTime.utc(
    normalizedDate.year,
    normalizedDate.month,
    normalizedDate.day,
    23,
    59,
    59,
  );
  final candidates = isar.dailyScheduleOccurrenceLocals
      .where()
      .dateBetween(dayStart, dayEnd)
      .isDeletedEqualTo(false)
      .findAll();

  final targetStart = normalizeTimeSlotPart(incoming.startTime);
  final targetEnd = normalizeTimeSlotPart(incoming.endTime);
  final targetType = incoming.type.trim().toUpperCase();
  final targetTitle = normalizeTitleForKey(incoming.title);

  for (final existing in candidates) {
    if (existing.subjectId != incoming.subjectId) continue;
    if (normalizeTimeSlotPart(existing.startTime) != targetStart) continue;
    if (normalizeTimeSlotPart(existing.endTime) != targetEnd) continue;
    if (existing.type.trim().toUpperCase() != targetType) continue;

    if (targetType == 'EXAM' || targetType == 'EVENT') {
      if (normalizeTitleForKey(existing.title) != targetTitle) continue;
    } else if (targetType == 'REGULAR_CLASS') {
      final exRule = existing.ruleId;
      final inRule = incoming.ruleId;
      if (exRule != null &&
          exRule > 0 &&
          inRule != null &&
          inRule > 0 &&
          exRule != inRule) {
        continue;
      }
    }
    return existing;
  }

  return null;
}

/// Inserts or updates [incoming] inside an active Isar write transaction
/// without creating duplicate active logical slots.
DailyScheduleOccurrenceLocal upsertCanonicalOccurrenceInWriteTx(
  Isar isar,
  DailyScheduleOccurrenceLocal incoming, {
  bool preferIncomingStatusOnMatch = true,
  bool preserveExistingCreatedAt = true,
  String Function()? serverIdGenerator,
}) {
  final normalizedDate = normalizeUtcDate(incoming.date);
  final normalizedStart = normalizeTimeSlotPart(incoming.startTime);
  final normalizedEnd = normalizeTimeSlotPart(incoming.endTime);
  final normalizedType = incoming.type.trim().toUpperCase();

  incoming
    ..date = normalizedDate
    ..startTime = normalizedStart
    ..endTime = normalizedEnd
    ..type = normalizedType;

  final computedKey =
      (incoming.slotKey != null && incoming.slotKey!.trim().isNotEmpty)
          ? incoming.slotKey!.trim()
          : computeSlotKeyForLocal(incoming);
  incoming.slotKey = computedKey;

  DailyScheduleOccurrenceLocal? existing;
  if (incoming.id > 0) {
    existing = isar.dailyScheduleOccurrenceLocals.get(incoming.id);
  }
  if (existing == null && !incoming.isDeleted) {
    existing = findActiveCanonicalOccurrenceInTx(isar, incoming);
  }

  if (existing != null) {
    existing
      ..date = normalizedDate
      ..subjectId = incoming.subjectId
      ..ruleId = incoming.ruleId ?? existing.ruleId
      ..legacyEventId = incoming.legacyEventId ?? existing.legacyEventId
      ..title = incoming.title
      ..startTime = normalizedStart
      ..endTime = normalizedEnd
      ..type = normalizedType
      ..status = preferIncomingStatusOnMatch
          ? incoming.status
          : (existing.status.toUpperCase() == 'UPCOMING'
              ? incoming.status
              : existing.status)
      ..createdFrom =
          existing.createdFrom.isNotEmpty && !preferIncomingStatusOnMatch
              ? existing.createdFrom
              : incoming.createdFrom
      ..room = incoming.room ?? existing.room
      ..faculty = incoming.faculty ?? existing.faculty
      ..reason = incoming.reason ?? existing.reason
      ..slotKey = (existing.slotKey != null &&
              existing.slotKey!.startsWith('LEGACY_EV:'))
          ? existing.slotKey
          : computeCanonicalSlotKey(
              date: normalizedDate,
              subjectId: incoming.subjectId,
              ruleId: incoming.ruleId ?? existing.ruleId,
              startTime: normalizedStart,
              endTime: normalizedEnd,
              type: normalizedType,
              title: incoming.title,
              legacyEventId: incoming.legacyEventId ?? existing.legacyEventId,
              forceLegacyDisambiguation: computedKey.startsWith('LEGACY_EV:'),
            )
      ..updatedAt = incoming.updatedAt
      ..isDirty = incoming.isDirty
      ..isDeleted = incoming.isDeleted;

    if (!preserveExistingCreatedAt) {
      existing.createdAt = incoming.createdAt;
    }
    existing.serverId = resolveUniqueOccurrenceServerId(
      isar,
      existing.serverId ?? incoming.serverId,
      excludingId: existing.id,
      fallbackGenerator: serverIdGenerator,
    );

    isar.dailyScheduleOccurrenceLocals.put(existing);
    return existing;
  }

  final newId = incoming.id > 0
      ? incoming.id
      : isar.dailyScheduleOccurrenceLocals.autoIncrement();
  incoming
    ..id = newId
    ..serverId = resolveUniqueOccurrenceServerId(
      isar,
      incoming.serverId,
      excludingId: newId,
      fallbackGenerator: serverIdGenerator,
    );
  isar.dailyScheduleOccurrenceLocals.put(incoming);
  return incoming;
}
