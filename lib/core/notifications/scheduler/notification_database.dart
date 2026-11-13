import 'dart:async';
import 'dart:developer' as developer;

import 'package:isar/isar.dart';
import '../../../features/semester/data/models/semester_local.dart';
import '../../../features/semester/data/repositories/semester_repository_impl.dart';
import '../../../features/subject/data/models/subject_local.dart';
import '../../../features/attendance/data/models/attendance_record_local.dart';
import '../../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../features/timetable/data/models/schedule_exception_local.dart';
import '../../../features/timetable/data/models/weekly_schedule_rule_local.dart';
import '../../../features/timetable/data/models/academic_event_local.dart';
import '../../../features/settings/data/models/user_preferences_local.dart';
import '../models/notification_item.dart';

/// Summary of legacy notification migration work performed on an [Isar] box.
class NotificationMigrationResult {
  final int migratedZeroIdCount;
  final int backfilledAndroidIdCount;

  const NotificationMigrationResult({
    required this.migratedZeroIdCount,
    required this.backfilledAndroidIdCount,
  });

  bool get didMigrate =>
      migratedZeroIdCount > 0 || backfilledAndroidIdCount > 0;
}

/// Idempotently migrates legacy [NotificationItem] rows so every persisted
/// record has a positive unique Isar [NotificationItem.id] (`>= 1`) and a
/// unique, valid 32-bit [NotificationItem.androidNotificationId].
///
/// Legacy rows created before BUG-009 stored `id == 0` and/or omitted
/// `androidNotificationId`. Migrating `id <= 0` rows moves each record to a
/// fresh `autoIncrement()` ID while preserving its content and removing the
/// old non-positive row key.
Future<NotificationMigrationResult> migrateLegacyNotificationItems(
  Isar isar,
) async {
  if (!isar.isOpen) {
    return const NotificationMigrationResult(
      migratedZeroIdCount: 0,
      backfilledAndroidIdCount: 0,
    );
  }

  final existingItems = isar.notificationItems.where().findAll();
  if (existingItems.isEmpty) {
    return const NotificationMigrationResult(
      migratedZeroIdCount: 0,
      backfilledAndroidIdCount: 0,
    );
  }

  final seenAndroidIds = <int>{};
  var needsMigration = false;
  for (final item in existingItems) {
    final androidId = item.androidNotificationId;
    if (item.id <= 0 ||
        androidId == null ||
        !NotificationItem.isValidPersistedAndroidId(androidId) ||
        !seenAndroidIds.add(androidId)) {
      needsMigration = true;
      break;
    }
  }

  if (!needsMigration) {
    return const NotificationMigrationResult(
      migratedZeroIdCount: 0,
      backfilledAndroidIdCount: 0,
    );
  }

  return isar.writeAsync<NotificationMigrationResult>(
    migrateLegacyNotificationItemsInWriteTx,
  );
}

/// Runs legacy [NotificationItem] primary-key (`<= 0`) and 32-bit
/// [NotificationItem.androidNotificationId] migration synchronously inside an
/// already-open Isar write transaction.
NotificationMigrationResult migrateLegacyNotificationItemsInWriteTx(
  Isar isarDb,
) {
  final items = isarDb.notificationItems.where().findAll();
  if (items.isEmpty) {
    return const NotificationMigrationResult(
      migratedZeroIdCount: 0,
      backfilledAndroidIdCount: 0,
    );
  }

  final usedAndroidIds = <int>{};
  final itemsNeedingAndroidId = <NotificationItem>[];
  final nonPositiveItems = <NotificationItem>[];

  for (final item in items) {
    if (item.id <= 0) {
      nonPositiveItems.add(item);
      continue;
    }

    final existingAndroidId = item.androidNotificationId;
    if (existingAndroidId != null &&
        NotificationItem.isValidPersistedAndroidId(existingAndroidId) &&
        usedAndroidIds.add(existingAndroidId)) {
      continue;
    }
    itemsNeedingAndroidId.add(item);
  }

  var backfilledCount = 0;
  for (final item in itemsNeedingAndroidId) {
    final assignedAndroidId = allocateNotificationAndroidIdFromUsedSet(
      dbId: item.id,
      usedAndroidIds: usedAndroidIds,
    );
    item.androidNotificationId = assignedAndroidId;
    usedAndroidIds.add(assignedAndroidId);
    isarDb.notificationItems.put(item);
    backfilledCount++;
  }

  var migratedZeroCount = 0;
  for (final legacyItem in nonPositiveItems) {
    final oldId = legacyItem.id;
    final newId = isarDb.notificationItems.autoIncrement();
    final assignedAndroidId = allocateNotificationAndroidIdFromUsedSet(
      dbId: newId,
      usedAndroidIds: usedAndroidIds,
    );

    final migratedItem = NotificationItem()
      ..id = newId
      ..androidNotificationId = assignedAndroidId
      ..title = legacyItem.title
      ..body = legacyItem.body
      ..type = legacyItem.type
      ..scheduledTime = legacyItem.scheduledTime
      ..relatedId = legacyItem.relatedId
      ..isRead = legacyItem.isRead;

    usedAndroidIds.add(assignedAndroidId);
    isarDb.notificationItems.put(migratedItem);
    isarDb.notificationItems.delete(oldId);
    migratedZeroCount++;
  }

  return NotificationMigrationResult(
    migratedZeroIdCount: migratedZeroCount,
    backfilledAndroidIdCount: backfilledCount,
  );
}

/// Allocates a unique 32-bit Android notification ID in the persisted
/// namespace `[NotificationItem.minPersistedAndroidId, NotificationItem.maxPersistedAndroidId]`
/// avoiding any ID already present in [usedAndroidIds].
int allocateNotificationAndroidIdFromUsedSet({
  required int dbId,
  required Set<int> usedAndroidIds,
}) {
  var candidate = NotificationItem.deriveAndroidNotificationId(dbId);
  var attempts = 0;
  while (usedAndroidIds.contains(candidate)) {
    attempts++;
    if (attempts >= NotificationItem.persistedAndroidIdSpan) {
      throw StateError('Exhausted persisted Android notification ID space.');
    }
    candidate = NotificationItem.nextPersistedAndroidId(candidate);
  }
  return candidate;
}

abstract class NotificationDatabase {
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrences(
      DateTime start, DateTime end);
  Future<List<WeeklyScheduleRuleLocal>> getWeeklyRules();
  Future<List<ScheduleExceptionLocal>> getScheduleExceptions(
      DateTime start, DateTime end);
  Future<List<AcademicEventLocal>> getAcademicEvents(
      DateTime start, DateTime end);
  Future<List<SubjectLocal>> getSubjects();
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(
      int subjectId);
  Future<List<AttendanceRecordLocal>> getAllAttendanceRecords();
  Future<SemesterLocal?> getActiveSemester();
  Future<UserPreferencesLocal?> getUserPreferences();

  Future<List<NotificationItem>> getFutureNotifications(DateTime now);
  Future<List<NotificationItem>> getFutureNotificationsByType(
      String type, DateTime now);
  Future<NotificationItem?> getLastNotification(String type, String relatedId);

  Future<void> deleteNotification(int id);
  Future<void> saveNotification(NotificationItem item);
}

class IsarNotificationDatabaseImpl implements NotificationDatabase {
  final Isar _isar;
  Future<void>? _inFlightMigration;
  bool _migrationChecked = false;

  IsarNotificationDatabaseImpl(this._isar);

  Future<void> _ensureLegacyRecordsMigrated() {
    if (_migrationChecked) {
      return Future<void>.value();
    }
    final inFlight = _inFlightMigration;
    if (inFlight != null) {
      return inFlight;
    }

    late final Future<void> run;
    run = () async {
      try {
        await migrateLegacyNotificationItems(_isar);
        _migrationChecked = true;
      } catch (error, stackTrace) {
        developer.log(
          'Legacy notification migration failed: $error',
          name: 'NotificationDatabase',
          error: error,
          stackTrace: stackTrace,
        );
      } finally {
        if (identical(_inFlightMigration, run)) {
          _inFlightMigration = null;
        }
      }
    }();
    _inFlightMigration = run;
    return run;
  }

  /// Explicitly triggers idempotent migration of legacy notification records
  /// (`id <= 0` or missing/invalid `androidNotificationId`).
  Future<NotificationMigrationResult> migrateLegacyRecords() async {
    final result = await migrateLegacyNotificationItems(_isar);
    _migrationChecked = true;
    return result;
  }

  Future<NotificationItem?> getNotificationById(int id) async {
    await _ensureLegacyRecordsMigrated();
    return _isar.notificationItems.get(id);
  }

  Future<List<NotificationItem>> getAllNotifications() async {
    await _ensureLegacyRecordsMigrated();
    return _isar.notificationItems.where().findAll();
  }

  @override
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrences(
      DateTime start, DateTime end) async {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day, 23, 59, 59);
    return _isar.dailyScheduleOccurrenceLocals
        .where()
        .dateBetween(startUtc, endUtc)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<WeeklyScheduleRuleLocal>> getWeeklyRules() async {
    return _isar.weeklyScheduleRuleLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<ScheduleExceptionLocal>> getScheduleExceptions(
      DateTime start, DateTime end) async {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day, 23, 59, 59);
    return _isar.scheduleExceptionLocals
        .where()
        .dateBetween(startUtc, endUtc)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<AcademicEventLocal>> getAcademicEvents(
      DateTime start, DateTime end) async {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day, 23, 59, 59);
    return _isar.academicEventLocals
        .where()
        .dateBetween(startUtc, endUtc)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<SubjectLocal>> getSubjects() async {
    return _isar.subjectLocals.where().isDeletedEqualTo(false).findAll();
  }

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(
      int subjectId) async {
    return _isar.attendanceRecordLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<AttendanceRecordLocal>> getAllAttendanceRecords() async {
    return _isar.attendanceRecordLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<SemesterLocal?> getActiveSemester() async {
    return resolveActiveSemesterLocal(_isar);
  }

  @override
  Future<UserPreferencesLocal?> getUserPreferences() async {
    if (!_isar.isOpen) return null;
    return _isar.userPreferencesLocals.where().findFirst();
  }

  @override
  Future<List<NotificationItem>> getFutureNotifications(DateTime now) async {
    await _ensureLegacyRecordsMigrated();
    return _isar.notificationItems
        .where()
        .scheduledTimeGreaterThan(now)
        .findAll();
  }

  @override
  Future<List<NotificationItem>> getFutureNotificationsByType(
    String type,
    DateTime now,
  ) async {
    await _ensureLegacyRecordsMigrated();
    return _isar.notificationItems
        .where()
        .typeEqualTo(type)
        .scheduledTimeGreaterThan(now)
        .findAll();
  }

  @override
  Future<NotificationItem?> getLastNotification(
    String type,
    String relatedId,
  ) async {
    await _ensureLegacyRecordsMigrated();
    return _isar.notificationItems
        .where()
        .typeEqualTo(type)
        .relatedIdEqualTo(relatedId)
        .sortByScheduledTimeDesc()
        .findFirst();
  }

  @override
  Future<void> deleteNotification(int id) async {
    await _ensureLegacyRecordsMigrated();
    await _isar.writeAsync((isar) => isar.notificationItems.delete(id));
  }

  @override
  Future<void> saveNotification(NotificationItem item) async {
    await _ensureLegacyRecordsMigrated();

    final (savedId, savedAndroidId) = await _isar.writeAsync<(int, int)>(
      (isar) {
        final isNew = item.id <= 0;
        if (isNew) {
          item.id = isar.notificationItems.autoIncrement();
        }

        int? resolvedAndroidId = item.androidNotificationId;
        if (!isNew &&
            (resolvedAndroidId == null ||
                !NotificationItem.isValidPersistedAndroidId(
                  resolvedAndroidId,
                ))) {
          final existing = isar.notificationItems.get(item.id);
          if (existing != null &&
              existing.androidNotificationId != null &&
              NotificationItem.isValidPersistedAndroidId(
                existing.androidNotificationId!,
              )) {
            resolvedAndroidId = existing.androidNotificationId;
          }
        }

        if (resolvedAndroidId == null ||
            !NotificationItem.isValidPersistedAndroidId(resolvedAndroidId) ||
            _hasAndroidIdConflict(
              isar,
              resolvedAndroidId,
              excludingDbId: item.id,
            )) {
          resolvedAndroidId = _allocateUniqueAndroidIdInIsar(
            isar,
            dbId: item.id,
          );
        }

        item.androidNotificationId = resolvedAndroidId;
        isar.notificationItems.put(item);
        return (item.id, resolvedAndroidId);
      },
    );

    item.id = savedId;
    item.androidNotificationId = savedAndroidId;
  }

  static bool _hasAndroidIdConflict(
    Isar isar,
    int candidate, {
    required int excludingDbId,
  }) {
    final matches = isar.notificationItems
        .where()
        .androidNotificationIdEqualTo(candidate)
        .findAll();
    return matches.any((match) => match.id != excludingDbId);
  }

  static int _allocateUniqueAndroidIdInIsar(
    Isar isar, {
    required int dbId,
  }) {
    var candidate = NotificationItem.deriveAndroidNotificationId(dbId);
    var attempts = 0;
    while (_hasAndroidIdConflict(isar, candidate, excludingDbId: dbId)) {
      attempts++;
      if (attempts >= NotificationItem.persistedAndroidIdSpan) {
        throw StateError('Exhausted persisted Android notification ID space.');
      }
      candidate = NotificationItem.nextPersistedAndroidId(candidate);
    }
    return candidate;
  }
}
