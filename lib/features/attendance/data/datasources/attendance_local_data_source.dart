import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../models/attendance_record_local.dart';
import '../../../semester/data/models/semester_local.dart';
import '../../../semester/data/repositories/semester_repository_impl.dart';
import '../../../subject/data/models/subject_local.dart';
import '../../../timetable/data/models/academic_event_local.dart';
import '../../../timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../timetable/data/models/weekly_schedule_rule_local.dart';
import '../../../timetable/data/utils/occurrence_identity.dart';

abstract class AttendanceLocalDataSource {
  Future<List<AttendanceRecordLocal>> getAttendanceForSubject(int subjectId);
  Future<AttendanceRecordLocal?> getAttendanceForOccurrence(int occurrenceId);
  Future<AttendanceRecordLocal?> getAttendanceForOccurrenceAnyStatus(
    int occurrenceId,
  );
  Future<AttendanceRecordLocal?> getAttendanceForEvent(int eventId);
  Future<AttendanceRecordLocal?> getAttendanceForEventAnyStatus(int eventId);
  Future<AttendanceRecordLocal?> getAttendanceRecordById(int id);
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record);
  Future<void> deleteAttendanceRecord(int id);
  Stream<void> watchAttendance(int subjectId);
  Future<void> updateEventStatus(int occurrenceId, String status);
  Future<DailyScheduleOccurrenceLocal> saveExtraClassWithAttendance({
    int? occurrenceId,
    required int subjectId,
    required DateTime date,
    String? subjectTitle,
    String? startTime,
    String? endTime,
    String? reason,
    String? attendanceStatus,
    bool autoAllocateSlot = false,
  });
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final Isar _isar;

  AttendanceLocalDataSourceImpl(this._isar);

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceForSubject(
    int subjectId,
  ) async {
    return _isar.attendanceRecordLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForOccurrence(
    int occurrenceId,
  ) async {
    if (occurrenceId <= 0) return null;
    final byOccurrence = _isar.attendanceRecordLocals
        .where()
        .occurrenceIdEqualTo(occurrenceId)
        .isDeletedEqualTo(false)
        .findFirst();
    if (byOccurrence != null) return byOccurrence;

    return _isar.attendanceRecordLocals
        .where()
        .eventIdEqualTo(occurrenceId)
        .isDeletedEqualTo(false)
        .findFirst();
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForOccurrenceAnyStatus(
    int occurrenceId,
  ) async {
    if (occurrenceId <= 0) return null;
    final byOccurrence = _isar.attendanceRecordLocals
        .where()
        .occurrenceIdEqualTo(occurrenceId)
        .findFirst();
    if (byOccurrence != null) return byOccurrence;

    return _isar.attendanceRecordLocals
        .where()
        .eventIdEqualTo(occurrenceId)
        .findFirst();
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForEvent(int eventId) =>
      getAttendanceForOccurrence(eventId);

  @override
  Future<AttendanceRecordLocal?> getAttendanceForEventAnyStatus(int eventId) =>
      getAttendanceForOccurrenceAnyStatus(eventId);

  @override
  Future<AttendanceRecordLocal?> getAttendanceRecordById(int id) async {
    return _isar.attendanceRecordLocals.get(id);
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record) async {
    final assignedId = await _isar.writeAsync((isar) {
      final occId = record.occurrenceId;
      if (occId != null && occId > 0) {
        record.eventId = occId;
      }

      if (record.id == 0) {
        if (occId != null && occId > 0) {
          final existing = isar.attendanceRecordLocals
              .where()
              .occurrenceIdEqualTo(occId)
              .findFirst();
          if (existing != null) {
            record.id = existing.id;
          } else {
            record.id = isar.attendanceRecordLocals.autoIncrement();
          }
        } else {
          record.id = isar.attendanceRecordLocals.autoIncrement();
        }
      }
      isar.attendanceRecordLocals.put(record);
      return record.id;
    });
    record.id = assignedId;
  }

  @override
  Future<void> deleteAttendanceRecord(int id) async {
    await _isar.writeAsync((isar) {
      final record = isar.attendanceRecordLocals.get(id);
      if (record != null) {
        record.isDeleted = true;
        record.isDirty = true;
        record.updatedAt = DateTime.now().toUtc();
        isar.attendanceRecordLocals.put(record);
      }
    });
  }

  @override
  Stream<void> watchAttendance(int subjectId) {
    return _isar.attendanceRecordLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .watch();
  }

  @override
  Future<void> updateEventStatus(int occurrenceId, String status) async {
    if (occurrenceId <= 0) return;
    final mappedStatus = _mapAttendanceStatusToOccurrenceStatus(status);
    final now = DateTime.now().toUtc();
    await _isar.writeAsync((isar) {
      final occurrence = isar.dailyScheduleOccurrenceLocals.get(occurrenceId);
      if (occurrence != null && !occurrence.isDeleted) {
        occurrence
          ..status = mappedStatus
          ..updatedAt = now
          ..isDirty = true;
        isar.dailyScheduleOccurrenceLocals.put(occurrence);
      }
    });
  }

  @override
  Future<DailyScheduleOccurrenceLocal> saveExtraClassWithAttendance({
    int? occurrenceId,
    required int subjectId,
    required DateTime date,
    String? subjectTitle,
    String? startTime,
    String? endTime,
    String? reason,
    String? attendanceStatus,
    bool autoAllocateSlot = false,
    @visibleForTesting void Function(Isar isar)? onBeforeOccurrencePut,
    @visibleForTesting void Function(Isar isar)? onBeforeAttendancePut,
    @visibleForTesting void Function(Isar isar)? onBeforeCommit,
  }) {
    final nowUtc = DateTime.now().toUtc();
    return _isar.writeAsync<DailyScheduleOccurrenceLocal>((isar) {
      return saveExtraClassWithAttendanceInWriteTx(
        isar,
        occurrenceId: occurrenceId,
        subjectId: subjectId,
        date: date,
        subjectTitle: subjectTitle,
        startTime: startTime,
        endTime: endTime,
        reason: reason,
        attendanceStatus: attendanceStatus,
        autoAllocateSlot: autoAllocateSlot,
        nowUtc: nowUtc,
        onBeforeOccurrencePut: onBeforeOccurrencePut,
        onBeforeAttendancePut: onBeforeAttendancePut,
        onBeforeCommit: onBeforeCommit,
      );
    });
  }

  static String _mapAttendanceStatusToOccurrenceStatus(String status) {
    switch (status.trim().toUpperCase()) {
      case 'PRESENT':
      case 'EXTRA_PRESENT':
        return 'PRESENT';
      case 'ABSENT':
      case 'EXTRA_ABSENT':
        return 'ABSENT';
      case 'CANCELLED':
        return 'CANCELLED';
      default:
        return 'UPCOMING';
    }
  }
}

class _MinuteInterval {
  final int start;
  final int end;

  const _MinuteInterval(this.start, this.end);
}

int? _parseHhMmToMinutes(
  String raw, {
  bool allow2400 = false,
}) {
  final trimmed = raw.trim();
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
  if (match == null) return null;
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  if (hour == null || minute == null) return null;
  if (allow2400 && hour == 24 && minute == 0) {
    return 1440;
  }
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return hour * 60 + minute;
}

String _formatMinutesToHhMm(int totalMinutes) {
  final h = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final m = (totalMinutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

({String occStatus, String? attStatus}) _resolveExtraClassStatusPair(
  String? rawStatus,
) {
  final normalized = rawStatus?.trim().toUpperCase();
  if (normalized == null || normalized.isEmpty || normalized == 'UPCOMING') {
    return (occStatus: 'UPCOMING', attStatus: null);
  }
  switch (normalized) {
    case 'PRESENT':
    case 'EXTRA_PRESENT':
    case 'EXTRAPRESENT':
      return (occStatus: 'PRESENT', attStatus: 'EXTRA_PRESENT');
    case 'ABSENT':
    case 'EXTRA_ABSENT':
    case 'EXTRAABSENT':
      return (occStatus: 'ABSENT', attStatus: 'EXTRA_ABSENT');
    case 'CANCELLED':
      return (occStatus: 'CANCELLED', attStatus: 'CANCELLED');
    default:
      throw ValidationException(
        'Unsupported extra-class attendance status: $rawStatus',
        'INVALID_ATTENDANCE_STATUS',
      );
  }
}

String _resolveUniqueAttendanceServerId(
  Isar isar,
  String? candidate, {
  int? excludingId,
}) {
  final trimmed = candidate?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    final existing = isar.attendanceRecordLocals
        .where()
        .serverIdEqualTo(trimmed)
        .findFirst();
    if (existing == null || existing.id == excludingId) {
      return trimmed;
    }
  }
  while (true) {
    final generated = generateUuid();
    final collision = isar.attendanceRecordLocals
        .where()
        .serverIdEqualTo(generated)
        .findFirst();
    if (collision == null || collision.id == excludingId) {
      return generated;
    }
  }
}

({String startTime, String endTime}) _allocateExtraClassSlotInTx(
  Isar isar, {
  required DateTime normDate,
  required int subjectId,
  required int semesterId,
  required String resolvedTitle,
  required List<DailyScheduleOccurrenceLocal> activeDayOccurrences,
}) {
  final occupiedIntervals = <_MinuteInterval>[];
  final existingSlotKeys = <String>{};

  void addOccupied(String? startRaw, String? endRaw) {
    if (startRaw == null || endRaw == null) return;
    final startMin = _parseHhMmToMinutes(startRaw, allow2400: true);
    final endMin = _parseHhMmToMinutes(endRaw, allow2400: true);
    if (startMin != null && endMin != null && startMin < endMin) {
      occupiedIntervals.add(_MinuteInterval(startMin, endMin));
    }
  }

  for (final occ in activeDayOccurrences) {
    addOccupied(occ.startTime, occ.endTime);
    final key = occ.slotKey?.trim();
    if (key != null && key.isNotEmpty) {
      existingSlotKeys.add(key);
    } else {
      existingSlotKeys.add(computeSlotKeyForLocal(occ));
    }
  }

  final semesterSubjectIds = isar.subjectLocals
      .where()
      .semesterIdEqualTo(semesterId)
      .isDeletedEqualTo(false)
      .findAll()
      .map((s) => s.id)
      .toSet();
  final activeRules =
      isar.weeklyScheduleRuleLocals.where().isDeletedEqualTo(false).findAll();
  for (final rule in activeRules) {
    if (!rule.isActive) continue;
    if (rule.dayOfWeek != normDate.weekday) continue;
    if (!semesterSubjectIds.contains(rule.subjectId)) continue;
    addOccupied(rule.startTime, rule.endTime);
  }

  final dayStart = normDate;
  final dayEnd = DateTime.utc(
    normDate.year,
    normDate.month,
    normDate.day,
    23,
    59,
    59,
  );
  final academicEvents = isar.academicEventLocals
      .where()
      .dateBetween(dayStart, dayEnd)
      .isDeletedEqualTo(false)
      .findAll();
  for (final ae in academicEvents) {
    addOccupied(ae.startTime, ae.endTime);
  }

  bool isSlotFree(int startMin, int endMin) {
    if (startMin < 0 || startMin >= endMin || endMin > 1439) {
      return false;
    }
    for (final iv in occupiedIntervals) {
      if (startMin < iv.end && endMin > iv.start) {
        return false;
      }
    }
    final startStr = _formatMinutesToHhMm(startMin);
    final endStr = _formatMinutesToHhMm(endMin);
    final candidateKey = computeCanonicalSlotKey(
      date: normDate,
      subjectId: subjectId,
      startTime: startStr,
      endTime: endStr,
      type: 'EXTRA_CLASS',
      title: resolvedTitle,
    );
    return !existingSlotKeys.contains(candidateKey);
  }

  // Tier 1: Preferred 60-minute daytime slots (09:00-10:00 .. 22:00-23:00).
  for (var hour = 9; hour <= 22; hour++) {
    final s = hour * 60;
    final e = (hour + 1) * 60;
    if (isSlotFree(s, e)) {
      return (
        startTime: _formatMinutesToHhMm(s),
        endTime: _formatMinutesToHhMm(e),
      );
    }
  }

  // Tier 2: Remaining 60-minute slots across the day (08:00..00:00 and 23:00-23:59).
  for (var hour = 8; hour >= 0; hour--) {
    final s = hour * 60;
    final e = (hour + 1) * 60;
    if (isSlotFree(s, e)) {
      return (
        startTime: _formatMinutesToHhMm(s),
        endTime: _formatMinutesToHhMm(e),
      );
    }
  }
  if (isSlotFree(23 * 60, 23 * 60 + 59)) {
    return (startTime: '23:00', endTime: '23:59');
  }

  // Tier 3: Finer non-overlapping intervals (30m -> 15m -> 1m) starting from 09:00.
  for (final duration in const <int>[30, 15, 1]) {
    final step = duration == 1 ? 1 : duration;
    for (var start = 9 * 60; start + duration <= 1439; start += step) {
      if (isSlotFree(start, start + duration)) {
        return (
          startTime: _formatMinutesToHhMm(start),
          endTime: _formatMinutesToHhMm(start + duration),
        );
      }
    }
    for (var start = 0; start + duration <= 9 * 60; start += step) {
      if (isSlotFree(start, start + duration)) {
        return (
          startTime: _formatMinutesToHhMm(start),
          endTime: _formatMinutesToHhMm(start + duration),
        );
      }
    }
  }

  throw ValidationException(
    'No available time slot remains on ${formatUtcDateKey(normDate)} for an extra class.',
    'NO_AVAILABLE_EXTRA_CLASS_SLOT',
  );
}

/// Atomically persists or updates an extra-class [DailyScheduleOccurrenceLocal]
/// and its [AttendanceRecordLocal] inside the caller's active Isar write
/// transaction.
DailyScheduleOccurrenceLocal saveExtraClassWithAttendanceInWriteTx(
  Isar isar, {
  int? occurrenceId,
  required int subjectId,
  required DateTime date,
  String? subjectTitle,
  String? startTime,
  String? endTime,
  String? reason,
  String? attendanceStatus,
  bool autoAllocateSlot = false,
  DateTime? nowUtc,
  @visibleForTesting void Function(Isar isar)? onBeforeOccurrencePut,
  @visibleForTesting void Function(Isar isar)? onBeforeAttendancePut,
  @visibleForTesting void Function(Isar isar)? onBeforeCommit,
}) {
  if (subjectId <= 0) {
    throw const ValidationException(
      'Invalid subject ID for extra class.',
      'INVALID_SUBJECT_ID',
    );
  }

  final subject = isar.subjectLocals.get(subjectId);
  if (subject == null || subject.isDeleted) {
    throw const ValidationException(
      'Cannot log extra class: subject was not found or has been deleted.',
      'SUBJECT_NOT_FOUND',
    );
  }

  final semester = isar.semesterLocals.get(subject.semesterId);
  if (semester == null || semester.isDeleted) {
    throw const ValidationException(
      'Cannot log extra class: subject semester was not found or has been deleted.',
      'SEMESTER_NOT_FOUND',
    );
  }

  final activeSemester = resolveActiveSemesterLocal(isar);
  if (semester.status != SemesterLocal.statusActive ||
      !semester.isActive ||
      activeSemester == null ||
      activeSemester.id != semester.id) {
    throw ValidationException(
      'Extra classes can only be added or updated in an active semester (current status: ${semester.status}).',
      'SEMESTER_NOT_ACTIVE',
    );
  }

  final normSemStart = normalizeUtcDate(semester.startDate);
  final normSemEnd = normalizeUtcDate(semester.endDate);
  if (!normSemStart.isBefore(normSemEnd)) {
    throw const ValidationException(
      'Cannot log extra class: subject semester has an invalid date range.',
      'SEMESTER_INVALID_DATE_RANGE',
    );
  }

  final normDate = normalizeUtcDate(date);
  if (normDate.isBefore(normSemStart) || normDate.isAfter(normSemEnd)) {
    throw const ValidationException(
      'Selected date must fall within the subject\'s semester date range.',
      'EXTRA_CLASS_OUT_OF_SEMESTER_RANGE',
    );
  }

  final statusPair = _resolveExtraClassStatusPair(attendanceStatus);
  final now = (nowUtc ?? DateTime.now()).toUtc();
  final trimmedTitle = subjectTitle?.trim();
  final resolvedTitle = (trimmedTitle != null && trimmedTitle.isNotEmpty)
      ? trimmedTitle
      : subject.name;

  final dayStart = normDate;
  final dayEnd = DateTime.utc(
    normDate.year,
    normDate.month,
    normDate.day,
    23,
    59,
    59,
  );
  DailyScheduleOccurrenceLocal? existingOcc;
  if (occurrenceId != null) {
    if (occurrenceId <= 0) {
      throw const ValidationException(
        'Invalid occurrence ID for extra class update.',
        'INVALID_EXTRA_CLASS_OCCURRENCE',
      );
    }
    existingOcc = isar.dailyScheduleOccurrenceLocals.get(occurrenceId);
    if (existingOcc == null ||
        existingOcc.isDeleted ||
        existingOcc.type.trim().toUpperCase() != 'EXTRA_CLASS' ||
        existingOcc.subjectId != subjectId) {
      throw const ValidationException(
        'Extra class occurrence not found or does not belong to the requested subject.',
        'INVALID_EXTRA_CLASS_OCCURRENCE',
      );
    }
  }

  final activeDayOccurrences = isar.dailyScheduleOccurrenceLocals
      .where()
      .dateBetween(dayStart, dayEnd)
      .isDeletedEqualTo(false)
      .findAll();

  late final String resolvedStart;
  late final String resolvedEnd;

  if (existingOcc == null && autoAllocateSlot) {
    if (startTime != null || endTime != null) {
      throw const ValidationException(
        'Cannot combine autoAllocateSlot with explicit startTime/endTime.',
        'INVALID_TIME_RANGE',
      );
    }
    final allocated = _allocateExtraClassSlotInTx(
      isar,
      normDate: normDate,
      subjectId: subjectId,
      semesterId: subject.semesterId,
      resolvedTitle: resolvedTitle,
      activeDayOccurrences: activeDayOccurrences,
    );
    resolvedStart = allocated.startTime;
    resolvedEnd = allocated.endTime;
  } else if (existingOcc != null &&
      !autoAllocateSlot &&
      startTime == null &&
      endTime == null) {
    final startMin = _parseHhMmToMinutes(existingOcc.startTime);
    final endMin = _parseHhMmToMinutes(existingOcc.endTime);
    if (startMin == null || endMin == null || endMin <= startMin) {
      throw const ValidationException(
        'Existing extra class has an invalid time range; supply startTime and endTime.',
        'INVALID_TIME_RANGE',
      );
    }
    resolvedStart = _formatMinutesToHhMm(startMin);
    resolvedEnd = _formatMinutesToHhMm(endMin);
  } else {
    if (autoAllocateSlot) {
      throw const ValidationException(
        'autoAllocateSlot cannot be used when updating an existing extra class.',
        'INVALID_TIME_RANGE',
      );
    }
    if (startTime == null || endTime == null) {
      throw const ValidationException(
        'Both startTime and endTime are required.',
        'INVALID_TIME_RANGE',
      );
    }
    final startMin = _parseHhMmToMinutes(startTime);
    final endMin = _parseHhMmToMinutes(endTime);
    if (startMin == null || endMin == null) {
      throw const ValidationException(
        'Start and end times must use valid HH:mm format.',
        'INVALID_TIME_RANGE',
      );
    }
    if (endMin <= startMin) {
      throw const ValidationException(
        'End time must be strictly after start time.',
        'INVALID_TIME_RANGE',
      );
    }
    resolvedStart = _formatMinutesToHhMm(startMin);
    resolvedEnd = _formatMinutesToHhMm(endMin);
  }

  final normalizedReason = reason == null
      ? existingOcc?.reason
      : (reason.trim().isEmpty ? null : reason.trim());

  final targetSlotKey = computeCanonicalSlotKey(
    date: normDate,
    subjectId: subjectId,
    startTime: resolvedStart,
    endTime: resolvedEnd,
    type: 'EXTRA_CLASS',
    title: resolvedTitle,
  );

  late final DailyScheduleOccurrenceLocal savedOccurrence;

  if (existingOcc != null) {
    final existingOccId = existingOcc.id;
    final slotConflictByKey = isar.dailyScheduleOccurrenceLocals
        .where()
        .slotKeyEqualTo(targetSlotKey)
        .isDeletedEqualTo(false)
        .findAll()
        .where((o) => o.id != existingOccId)
        .firstOrNull;
    final slotConflictByTuple = activeDayOccurrences.where((o) {
      return o.id != existingOccId &&
          o.subjectId == subjectId &&
          o.type.trim().toUpperCase() == 'EXTRA_CLASS' &&
          normalizeTimeSlotPart(o.startTime) == resolvedStart &&
          normalizeTimeSlotPart(o.endTime) == resolvedEnd;
    }).firstOrNull;

    if (slotConflictByKey != null || slotConflictByTuple != null) {
      throw ValidationException(
        'Another extra class already occupies $resolvedStart - $resolvedEnd on ${formatUtcDateKey(normDate)}.',
        'DUPLICATE_EXTRA_CLASS_SLOT',
      );
    }

    existingOcc
      ..date = normDate
      ..subjectId = subjectId
      ..title = resolvedTitle
      ..startTime = resolvedStart
      ..endTime = resolvedEnd
      ..type = 'EXTRA_CLASS'
      ..status = statusPair.occStatus
      ..createdFrom = 'MANUAL'
      ..faculty = existingOcc.faculty ?? subject.faculty
      ..reason = normalizedReason
      ..slotKey = targetSlotKey
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;
    existingOcc.serverId = resolveUniqueOccurrenceServerId(
      isar,
      existingOcc.serverId,
      excludingId: existingOccId,
    );

    onBeforeOccurrencePut?.call(isar);
    isar.dailyScheduleOccurrenceLocals.put(existingOcc);
    savedOccurrence = existingOcc;
  } else {
    final slotConflictByKey = isar.dailyScheduleOccurrenceLocals
        .where()
        .slotKeyEqualTo(targetSlotKey)
        .isDeletedEqualTo(false)
        .findFirst();
    final slotConflictByTuple = activeDayOccurrences.where((o) {
      return o.subjectId == subjectId &&
          o.type.trim().toUpperCase() == 'EXTRA_CLASS' &&
          normalizeTimeSlotPart(o.startTime) == resolvedStart &&
          normalizeTimeSlotPart(o.endTime) == resolvedEnd;
    }).firstOrNull;

    if (slotConflictByKey != null || slotConflictByTuple != null) {
      throw ValidationException(
        'An extra class already exists for ${subject.name} at $resolvedStart - $resolvedEnd on ${formatUtcDateKey(normDate)}.',
        'DUPLICATE_EXTRA_CLASS_SLOT',
      );
    }

    final newOccId = isar.dailyScheduleOccurrenceLocals.autoIncrement();
    final newOccServerId = resolveUniqueOccurrenceServerId(
      isar,
      null,
      excludingId: newOccId,
    );
    final newOcc = DailyScheduleOccurrenceLocal()
      ..id = newOccId
      ..serverId = newOccServerId
      ..date = normDate
      ..subjectId = subjectId
      ..slotKey = targetSlotKey
      ..title = resolvedTitle
      ..startTime = resolvedStart
      ..endTime = resolvedEnd
      ..type = 'EXTRA_CLASS'
      ..status = statusPair.occStatus
      ..createdFrom = 'MANUAL'
      ..faculty = subject.faculty
      ..reason = normalizedReason
      ..createdAt = now
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;

    onBeforeOccurrencePut?.call(isar);
    isar.dailyScheduleOccurrenceLocals.put(newOcc);
    savedOccurrence = newOcc;
  }

  if (savedOccurrence.id <= 0 ||
      savedOccurrence.subjectId != subjectId ||
      savedOccurrence.type.trim().toUpperCase() != 'EXTRA_CLASS') {
    throw const DatabaseException(
      'Persisted extra-class occurrence failed identity verification.',
      'EXTRA_CLASS_IDENTITY_ERROR',
    );
  }

  final attendanceRows = isar.attendanceRecordLocals
      .where()
      .occurrenceIdEqualTo(savedOccurrence.id)
      .findAll();
  for (final row in attendanceRows) {
    if (row.subjectId != subjectId || row.occurrenceId != savedOccurrence.id) {
      throw ValidationException(
        'Attendance record identity mismatch on occurrence ${savedOccurrence.id}.',
        'ATTENDANCE_IDENTITY_MISMATCH',
      );
    }
  }
  if (occurrenceId == null && attendanceRows.isNotEmpty) {
    throw DatabaseException(
      'Newly allocated occurrence ${savedOccurrence.id} already has existing attendance rows.',
      'ATTENDANCE_IDENTITY_MISMATCH',
    );
  }

  final existingAtt = attendanceRows.where((r) => !r.isDeleted).firstOrNull ??
      attendanceRows.firstOrNull;

  onBeforeAttendancePut?.call(isar);

  final targetAttStatus = statusPair.attStatus;
  if (targetAttStatus == null || targetAttStatus == 'CANCELLED') {
    for (final row in attendanceRows) {
      if (!row.isDeleted) {
        row
          ..isDeleted = true
          ..isDirty = false
          ..updatedAt = now;
        isar.attendanceRecordLocals.put(row);
      }
    }
  } else {
    if (existingAtt != null) {
      existingAtt
        ..serverId = _resolveUniqueAttendanceServerId(
          isar,
          existingAtt.serverId,
          excludingId: existingAtt.id,
        )
        ..occurrenceId = savedOccurrence.id
        ..eventId = savedOccurrence.id
        ..subjectId = subjectId
        ..status = targetAttStatus
        ..markedAt = savedOccurrence.date
        ..updatedAt = now
        ..isDirty = false
        ..isDeleted = false;
      isar.attendanceRecordLocals.put(existingAtt);
    } else {
      final newAttId = isar.attendanceRecordLocals.autoIncrement();
      final newAttServerId = _resolveUniqueAttendanceServerId(
        isar,
        null,
        excludingId: newAttId,
      );
      final newAtt = AttendanceRecordLocal()
        ..id = newAttId
        ..serverId = newAttServerId
        ..occurrenceId = savedOccurrence.id
        ..eventId = savedOccurrence.id
        ..subjectId = subjectId
        ..status = targetAttStatus
        ..markedAt = savedOccurrence.date
        ..createdAt = now
        ..updatedAt = now
        ..isDirty = false
        ..isDeleted = false;
      isar.attendanceRecordLocals.put(newAtt);
    }
  }

  onBeforeCommit?.call(isar);
  return savedOccurrence;
}
