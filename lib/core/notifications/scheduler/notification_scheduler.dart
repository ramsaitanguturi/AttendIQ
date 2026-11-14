import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import 'notification_database.dart';
import '../../analytics/calculators/analytics_calculator.dart';
import '../../analytics/models/risk_status.dart';
import '../../../features/semester/domain/entities/semester.dart';
import '../../../features/subject/data/models/subject_local.dart';
import '../../../features/subject/domain/entities/subject.dart';
import '../../../features/attendance/data/models/attendance_record_local.dart';
import '../../../features/attendance/domain/entities/attendance_record.dart';
import '../../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../features/timetable/data/models/weekly_schedule_rule_local.dart';
import '../../../features/timetable/data/utils/occurrence_identity.dart';

class DesiredReminder {
  final String relatedKey;
  final String? legacyRelatedKey;
  final int subjectId;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final int offsetMinutes;

  const DesiredReminder({
    required this.relatedKey,
    this.legacyRelatedKey,
    required this.subjectId,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.offsetMinutes,
  });
}

class NotificationScheduler {
  final NotificationDatabase _db;
  final NotificationService _notificationService;

  Future<void>? _activeReschedule;
  bool _hasPendingReschedule = false;
  List<int> _pendingReminderOffsets = const [15];
  DateTime? _pendingCustomNow;
  Completer<void>? _pendingCompleter;
  bool _isDisposed = false;

  NotificationScheduler(this._db, this._notificationService);

  bool get isDisposed => _isDisposed;

  /// Marks the scheduler disposed so no subsequent reschedule passes run after
  /// container shutdown or database closure.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _hasPendingReschedule = false;
    _pendingCustomNow = null;
    final pending = _pendingCompleter;
    _pendingCompleter = null;
    if (pending != null && !pending.isCompleted) {
      pending.complete();
    }
  }

  Subject _mapSubject(SubjectLocal s) {
    return Subject(
      id: s.id,
      semesterId: s.semesterId,
      name: s.name,
      code: s.code,
      faculty: s.faculty,
      credits: s.credits,
      attendanceTarget: s.attendanceTarget,
      color: s.color,
      type: s.type == 'LAB' ? SubjectType.lab : SubjectType.theory,
      updatedAt: s.updatedAt,
    );
  }

  AttendanceRecord _mapRecord(AttendanceRecordLocal r) {
    return AttendanceRecord(
      id: r.id,
      serverId: r.serverId,
      occurrenceId: r.occurrenceId,
      legacyEventId: r.legacyEventId,
      eventId: r.occurrenceId ?? r.eventId,
      subjectId: r.subjectId,
      status: r.status == 'PRESENT'
          ? AttendanceStatus.present
          : (r.status == 'ABSENT'
              ? AttendanceStatus.absent
              : (r.status == 'CANCELLED'
                  ? AttendanceStatus.cancelled
                  : (r.status == 'EXTRA_PRESENT'
                      ? AttendanceStatus.extraPresent
                      : AttendanceStatus.extraAbsent))),
      markedAt: r.markedAt,
      updatedAt: r.updatedAt,
    );
  }

  Future<void> rescheduleAll({
    List<int> reminderOffsets = const [15],
    DateTime? customNow,
  }) {
    if (_isDisposed) {
      return Future<void>.value();
    }

    if (_activeReschedule != null) {
      _hasPendingReschedule = true;
      _pendingReminderOffsets = reminderOffsets;
      _pendingCustomNow = customNow;
      _pendingCompleter ??= Completer<void>();
      return _pendingCompleter!.future;
    }

    late final Future<void> runFuture;
    runFuture = _runRescheduleLoop(
      initialOffsets: reminderOffsets,
      initialCustomNow: customNow,
    ).whenComplete(() {
      if (identical(_activeReschedule, runFuture)) {
        _activeReschedule = null;
      }
    });
    _activeReschedule = runFuture;
    return runFuture;
  }

  Future<void> _runRescheduleLoop({
    required List<int> initialOffsets,
    required DateTime? initialCustomNow,
  }) async {
    var offsets = initialOffsets;
    var customNow = initialCustomNow;
    Completer<void>? currentBatchCompleter;

    try {
      while (!_isDisposed) {
        try {
          await _executeReschedulePass(
            reminderOffsets: offsets,
            customNow: customNow,
          );
          if (currentBatchCompleter != null &&
              !currentBatchCompleter.isCompleted) {
            currentBatchCompleter.complete();
          }
        } catch (error, stackTrace) {
          if (currentBatchCompleter != null &&
              !currentBatchCompleter.isCompleted) {
            currentBatchCompleter.completeError(error, stackTrace);
          } else {
            rethrow;
          }
        } finally {
          currentBatchCompleter = null;
        }

        if (!_hasPendingReschedule || _isDisposed) {
          break;
        }

        offsets = _pendingReminderOffsets;
        customNow = _pendingCustomNow;
        currentBatchCompleter = _pendingCompleter;
        _hasPendingReschedule = false;
        _pendingCompleter = null;
        _pendingCustomNow = null;
      }
    } finally {
      if (currentBatchCompleter != null && !currentBatchCompleter.isCompleted) {
        currentBatchCompleter.complete();
      }
      final remainingPending = _pendingCompleter;
      _pendingCompleter = null;
      _hasPendingReschedule = false;
      _pendingCustomNow = null;
      if (remainingPending != null && !remainingPending.isCompleted) {
        remainingPending.complete();
      }
    }
  }

  Future<void> cancelAllScheduledNotifications() async {
    final now = DateTime.now();
    final allFuture = await _db.getFutureNotifications(now);
    for (final n in allFuture) {
      await _notificationService
          .cancelNotification(n.effectiveAndroidNotificationId);
      await _db.deleteNotification(n.id);
    }
  }

  Future<void> cancelAttendanceWarnings() async {
    final now = DateTime.now();
    final warnings = await _db.getFutureNotificationsByType(
      NotificationType.attendanceWarning.toShortString(),
      now,
    );
    final alerts = await _db.getFutureNotificationsByType(
      NotificationType.lowAttendanceAlert.toShortString(),
      now,
    );
    for (final n in [...warnings, ...alerts]) {
      await _notificationService
          .cancelNotification(n.effectiveAndroidNotificationId);
      await _db.deleteNotification(n.id);
    }
  }

  Future<void> cancelWeeklyReports() async {
    final now = DateTime.now();
    final reports = await _db.getFutureNotificationsByType(
      NotificationType.weeklyReport.toShortString(),
      now,
    );
    for (final r in reports) {
      await _notificationService
          .cancelNotification(r.effectiveAndroidNotificationId);
      await _db.deleteNotification(r.id);
    }
  }

  Future<void> _executeReschedulePass({
    required List<int> reminderOffsets,
    required DateTime? customNow,
  }) async {
    final now = customNow ?? DateTime.now();
    if (_isDisposed) return;

    final prefs = await _db.getUserPreferences();
    final enableNotifications = prefs?.enableNotifications ?? true;
    if (!enableNotifications) {
      await cancelAllScheduledNotifications();
      return;
    }

    final isLateEnabled = prefs?.enableLateAttendance ?? false;
    if (_notificationService is LocalNotificationServiceImpl) {
      (_notificationService).enableLateAttendance = isLateEnabled;
    }

    final effectiveOffsets = (prefs != null && prefs.classReminderOffset > 0)
        ? [prefs.classReminderOffset]
        : reminderOffsets;

    if (_isDisposed) return;
    try {
      await rescheduleRollingWindow(offsets: effectiveOffsets, customNow: now);
    } catch (e, stack) {
      debugPrint('Failed to reschedule rolling window reminders: $e');
      debugPrint(stack.toString());
    }

    if (_isDisposed) return;
    final enableWarnings = prefs?.enableAttendanceWarnings ?? true;
    if (enableWarnings) {
      try {
        await checkAttendanceRisks(customNow: now);
      } catch (e, stack) {
        debugPrint('Failed to check attendance risks: $e');
        debugPrint(stack.toString());
      }
    } else {
      await cancelAttendanceWarnings();
    }

    if (_isDisposed) return;
    final enableWeeklyReport = prefs?.weeklyReportEnabled ?? true;
    if (enableWeeklyReport) {
      try {
        await scheduleWeeklyReport(customNow: now);
      } catch (e, stack) {
        debugPrint('Failed to schedule weekly report: $e');
        debugPrint(stack.toString());
      }
    } else {
      await cancelWeeklyReports();
    }
  }

  Future<void> rescheduleRollingWindow({
    List<int> offsets = const [15],
    DateTime? customNow,
  }) async {
    final now = customNow ?? DateTime.now();
    final rollingEnd = now.add(const Duration(days: 7));

    final startUtc = DateTime.utc(now.year, now.month, now.day);
    final endUtc = DateTime.utc(
      rollingEnd.year,
      rollingEnd.month,
      rollingEnd.day,
      23,
      59,
      59,
    );

    // 1. Fetch canonical occurrences, weekly rules, exceptions, and subjects
    final occurrences = await _db.getOccurrences(startUtc, endUtc);
    final rules = (await _db.getWeeklyRules())
        .where((r) => r.isActive && !r.isDeleted)
        .toList();
    final exceptions = await _db.getScheduleExceptions(startUtc, endUtc);

    final subjects = await _db.getSubjects();
    final subjectMap = {for (final s in subjects) s.id: s};
    final ruleById = {for (final r in rules) r.id: r};

    final holidayDates = <String>{};
    final cancelledSubjectsByDate = <String, Set<int>>{};
    for (final ex in exceptions) {
      final exDateKey = formatUtcDateKey(ex.date);
      final exType = ex.type.trim().toUpperCase();
      if (exType == 'HOLIDAY') {
        holidayDates.add(exDateKey);
      } else if (exType == 'CANCELLED_CLASS' && ex.subjectId != null) {
        cancelledSubjectsByDate
            .putIfAbsent(exDateKey, () => <int>{})
            .add(ex.subjectId!);
      }
    }

    final List<DesiredReminder> desiredReminders = [];
    final Set<String> consumedSlotKeys = <String>{};
    final Set<String> consumedRuleDates = <String>{};

    void appendClassReminders({
      required String relatedKey,
      String? legacyRelatedKey,
      required int subjectId,
      required String displayName,
      required String startTime,
      required String? room,
      required DateTime localClassTime,
      required bool isExtra,
    }) {
      for (final offset in offsets) {
        final triggerTime = localClassTime.subtract(Duration(minutes: offset));
        if (triggerTime.isAfter(now) && !triggerTime.isAfter(rollingEnd)) {
          desiredReminders.add(
            DesiredReminder(
              relatedKey: relatedKey,
              legacyRelatedKey: legacyRelatedKey,
              subjectId: subjectId,
              title: isExtra
                  ? 'Extra $displayName class starts in $offset minutes'
                  : '$displayName class starts in $offset minutes',
              body: isExtra
                  ? 'Extra $displayName class today at $startTime'
                  : 'Starts at $startTime${room != null ? " in $room" : ""}',
              scheduledTime: triggerTime,
              offsetMinutes: offset,
            ),
          );
        }
      }
    }

    // 1a. Materialized canonical DailyScheduleOccurrenceLocal rows
    for (final occ in occurrences) {
      if (occ.isDeleted) continue;

      final occDate = normalizeUtcDate(occ.date);
      final occDateKey = formatUtcDateKey(occDate);
      final matchingRule = _findRuleForOccurrence(occ, rules, ruleById);

      final canonicalSlotKey = (occ.slotKey != null && occ.slotKey!.isNotEmpty)
          ? occ.slotKey!
          : computeCanonicalSlotKey(
              date: occDate,
              subjectId: occ.subjectId,
              ruleId: occ.ruleId ?? matchingRule?.id,
              startTime: occ.startTime,
              endTime: occ.endTime,
              type: occ.type,
              title: occ.title,
              legacyEventId: occ.legacyEventId,
            );
      consumedSlotKeys.add(canonicalSlotKey);
      final effectiveRuleId = occ.ruleId ?? matchingRule?.id;
      if (effectiveRuleId != null) {
        consumedRuleDates.add('${effectiveRuleId}_$occDateKey');
      }

      if (occ.status.toUpperCase() == 'CANCELLED') continue;
      if (holidayDates.contains(occDateKey)) continue;
      if (occ.subjectId != null &&
          (cancelledSubjectsByDate[occDateKey]?.contains(occ.subjectId!) ??
              false)) {
        continue;
      }

      final subject = occ.subjectId != null ? subjectMap[occ.subjectId!] : null;
      if (occ.subjectId != null && (subject == null || subject.isDeleted)) {
        continue;
      }

      final timeParts = normalizeTimeSlotPart(occ.startTime).split(':');
      if (timeParts.length < 2) continue;
      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) continue;

      final localClassTime = DateTime(
        occDate.year,
        occDate.month,
        occDate.day,
        hour,
        minute,
      );

      final room = occ.room ?? matchingRule?.room;
      final isExtra = occ.type.toUpperCase() == 'EXTRA_CLASS';
      final displayName = subject?.name ?? occ.title;
      final relatedKey = NotificationRelatedKeys.forSlotKey(canonicalSlotKey);
      final legacyKey = (occ.legacyEventId ?? occ.id) > 0
          ? (occ.legacyEventId ?? occ.id).toString()
          : null;

      appendClassReminders(
        relatedKey: relatedKey,
        legacyRelatedKey: legacyKey,
        subjectId: occ.subjectId ?? 0,
        displayName: displayName,
        startTime: occ.startTime,
        room: room,
        localClassTime: localClassTime,
        isExtra: isExtra,
      );
    }

    // 1b. Unmaterialized active WeeklyScheduleRuleLocal slots across the 7-day rolling window
    for (var dayOffset = 0; dayOffset <= 7; dayOffset++) {
      final localDay = now.add(Duration(days: dayOffset));
      final dayUtc = DateTime.utc(localDay.year, localDay.month, localDay.day);
      final dayDateKey = formatUtcDateKey(dayUtc);

      if (holidayDates.contains(dayDateKey)) continue;

      for (final rule in rules) {
        if (rule.dayOfWeek != dayUtc.weekday) continue;
        if (cancelledSubjectsByDate[dayDateKey]?.contains(rule.subjectId) ??
            false) {
          continue;
        }
        if (consumedRuleDates.contains('${rule.id}_$dayDateKey')) continue;

        final subject = subjectMap[rule.subjectId];
        if (subject == null || subject.isDeleted) continue;

        final canonicalSlotKey = computeCanonicalSlotKey(
          date: dayUtc,
          subjectId: rule.subjectId,
          ruleId: rule.id,
          startTime: rule.startTime,
          endTime: rule.endTime,
          type: 'REGULAR_CLASS',
          title: subject.name,
        );
        if (consumedSlotKeys.contains(canonicalSlotKey)) continue;

        final timeParts = normalizeTimeSlotPart(rule.startTime).split(':');
        if (timeParts.length < 2) continue;
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour == null || minute == null) continue;

        final localClassTime = DateTime(
          dayUtc.year,
          dayUtc.month,
          dayUtc.day,
          hour,
          minute,
        );

        final relatedKey = NotificationRelatedKeys.forSlotKey(canonicalSlotKey);
        appendClassReminders(
          relatedKey: relatedKey,
          subjectId: rule.subjectId,
          displayName: subject.name,
          startTime: rule.startTime,
          room: rule.room,
          localClassTime: localClassTime,
          isExtra: false,
        );
      }
    }

    // 1c. Fetch academic events for next 14 days (namespaced keys cannot collide with occurrences)
    final academicEvents = await _db.getAcademicEvents(
      startUtc,
      now.add(const Duration(days: 14)),
    );
    for (final ae in academicEvents) {
      final aeDate = normalizeUtcDate(ae.date);
      final eventDate = DateTime(aeDate.year, aeDate.month, aeDate.day, 9, 0);
      final oneDayBefore = eventDate.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now)) {
        desiredReminders.add(
          DesiredReminder(
            relatedKey: NotificationRelatedKeys.forAcademicEventOneDay(ae.id),
            legacyRelatedKey: (ae.id + 100000).toString(),
            subjectId: 0,
            title: 'Tomorrow:',
            body: ae.title,
            scheduledTime: oneDayBefore,
            offsetMinutes: 1440,
          ),
        );
      }

      if (ae.startTime != null && ae.startTime!.contains(':')) {
        final parts = ae.startTime!.split(':');
        final hour = int.tryParse(parts[0]) ?? 9;
        final minute = int.tryParse(parts[1]) ?? 0;
        final startTimeDate =
            DateTime(aeDate.year, aeDate.month, aeDate.day, hour, minute);
        final thirtyMinBefore =
            startTimeDate.subtract(const Duration(minutes: 30));
        if (thirtyMinBefore.isAfter(now)) {
          desiredReminders.add(
            DesiredReminder(
              relatedKey:
                  NotificationRelatedKeys.forAcademicEventThirtyMin(ae.id),
              legacyRelatedKey: (ae.id + 200000).toString(),
              subjectId: 0,
              title: '${ae.title} starts at ${ae.startTime}',
              body: ae.description ?? ae.title,
              scheduledTime: thirtyMinBefore,
              offsetMinutes: 30,
            ),
          );
        }
      }
    }

    // 3. Fetch future scheduled class reminders
    final futureNotifications = await _db.getFutureNotificationsByType(
      NotificationType.classReminder.toShortString(),
      now,
    );

    final List<int> keptIds = [];
    final List<DesiredReminder> toCreate = [];
    final List<NotificationItem> toUpdate = [];
    final Set<String> seenKeys = <String>{};

    for (final desired in desiredReminders) {
      final key =
          '${desired.relatedKey}_${desired.scheduledTime.toUtc().microsecondsSinceEpoch}';
      if (!seenKeys.add(key)) {
        continue;
      }

      final existing = futureNotifications.firstWhereOrNull(
        (n) =>
            (n.relatedId == desired.relatedKey ||
                (desired.legacyRelatedKey != null &&
                    n.relatedId == desired.legacyRelatedKey)) &&
            n.scheduledTime.isAtSameMomentAs(desired.scheduledTime),
      );
      if (existing != null) {
        keptIds.add(existing.id);
        if (existing.title != desired.title ||
            existing.body != desired.body ||
            existing.relatedId != desired.relatedKey) {
          existing
            ..title = desired.title
            ..body = desired.body
            ..relatedId = desired.relatedKey;
          toUpdate.add(existing);
        }
      } else {
        toCreate.add(desired);
      }
    }

    // 4. Cancel and delete stale notifications
    final toDelete =
        futureNotifications.where((n) => !keptIds.contains(n.id)).toList();
    for (final n in toDelete) {
      await _notificationService.cancelNotification(
        n.effectiveAndroidNotificationId,
      );
      await _db.deleteNotification(n.id);
    }

    // 5. Update modified notifications in-place (preserving DB & Android IDs)
    for (final updated in toUpdate) {
      await _db.saveNotification(updated);
      await _notificationService.scheduleNotification(updated);
    }

    // 6. Create and schedule new ones
    for (final desired in toCreate) {
      final item = NotificationItem()
        ..title = desired.title
        ..body = desired.body
        ..type = NotificationType.classReminder.toShortString()
        ..scheduledTime = desired.scheduledTime
        ..relatedId = desired.relatedKey
        ..isRead = false;

      await _db.saveNotification(item);
      await _notificationService.scheduleNotification(item);
    }
  }

  WeeklyScheduleRuleLocal? _findRuleForOccurrence(
    DailyScheduleOccurrenceLocal occ,
    List<WeeklyScheduleRuleLocal> rules,
    Map<int, WeeklyScheduleRuleLocal> ruleById,
  ) {
    if (occ.ruleId != null && ruleById.containsKey(occ.ruleId)) {
      return ruleById[occ.ruleId];
    }
    final occDate = normalizeUtcDate(occ.date);
    final normStart = normalizeTimeSlotPart(occ.startTime);
    return rules.firstWhereOrNull(
      (r) =>
          r.subjectId == occ.subjectId &&
          r.dayOfWeek == occDate.weekday &&
          normalizeTimeSlotPart(r.startTime) == normStart,
    );
  }

  Future<void> checkAttendanceRisks({DateTime? customNow}) async {
    final now = customNow ?? DateTime.now();

    final semesterLocal = await _db.getActiveSemester();
    if (semesterLocal == null) return;

    final subjects = await _db.getSubjects();
    final semesterSubjects =
        subjects.where((s) => s.semesterId == semesterLocal.id).toList();

    for (final subject in semesterSubjects) {
      final recordsLocal = await _db.getAttendanceRecordsForSubject(subject.id);

      if (recordsLocal.isEmpty) continue;

      final records = recordsLocal.map(_mapRecord).toList();
      final subjectEntity = _mapSubject(subject);

      final analytics = AnalyticsCalculator.calculateSubjectAnalytics(
        subject: subjectEntity,
        records: records,
      );

      final target = subject.attendanceTarget;

      NotificationType? alertType;
      String? title;
      String? body;

      if (analytics.riskStatus == RiskStatus.critical) {
        alertType = NotificationType.lowAttendanceAlert;
        title = 'Low Attendance Alert: ${subject.name}';
        final classesNeeded = analytics.classesNeeded;
        body =
            'Your ${subject.name} attendance is below $target% (${analytics.percentage.toStringAsFixed(1)}%). '
            '${classesNeeded != null && classesNeeded > 0 ? "Attend next $classesNeeded classes to recover." : ""}';
      } else if (analytics.riskStatus == RiskStatus.warning) {
        alertType = NotificationType.attendanceWarning;
        title = 'Attendance Warning: ${subject.name}';
        body =
            'Your ${subject.name} attendance is close to falling below target. Currently at ${analytics.percentage.toStringAsFixed(1)}% (Target: $target%).';
      }

      if (alertType != null && title != null && body != null) {
        // Find latest attendance record marked date
        final sortedRecords = recordsLocal.toList()
          ..sort((a, b) => b.markedAt.compareTo(a.markedAt));
        final latestRecord = sortedRecords.first;

        // Fetch last notification of this type for this subject (namespaced + legacy fallback)
        final subjectKey = NotificationRelatedKeys.forSubjectRisk(subject.id);
        final lastTyped = await _db.getLastNotification(
          alertType.toShortString(),
          subjectKey,
        );
        final lastLegacy = await _db.getLastNotification(
          alertType.toShortString(),
          subject.id.toString(),
        );
        final lastNotification = (lastTyped != null && lastLegacy != null)
            ? (lastTyped.scheduledTime.isAfter(lastLegacy.scheduledTime)
                ? lastTyped
                : lastLegacy)
            : (lastTyped ?? lastLegacy);

        // If no notification was sent, or the latest log occurred after the last warning notification
        if (lastNotification == null ||
            latestRecord.markedAt.isAfter(lastNotification.scheduledTime)) {
          final item = NotificationItem()
            ..title = title
            ..body = body
            ..type = alertType.toShortString()
            ..scheduledTime = now.add(const Duration(seconds: 5))
            ..relatedId = subjectKey
            ..isRead = false;

          await _db.saveNotification(item);
          try {
            await _notificationService.scheduleNotification(item);
          } catch (e, stack) {
            debugPrint(
              'Failed to schedule risk notification with platform service: $e',
            );
            debugPrint(stack.toString());
          }
        }
      }
    }
  }

  Future<void> scheduleWeeklyReport({DateTime? customNow}) async {
    final now = customNow ?? DateTime.now();

    // 1. Find next Sunday at 6:00 PM
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday < 0) {
      daysUntilSunday += 7;
    }
    DateTime nextSunday = DateTime(now.year, now.month, now.day, 18, 0, 0)
        .add(Duration(days: daysUntilSunday));
    if (nextSunday.isBefore(now)) {
      nextSunday = nextSunday.add(const Duration(days: 7));
    }

    final semesterLocal = await _db.getActiveSemester();
    if (semesterLocal == null) return;

    final subjects = await _db.getSubjects();
    final semesterSubjects =
        subjects.where((s) => s.semesterId == semesterLocal.id).toList();
    if (semesterSubjects.isEmpty) return;

    final subjectEntities = semesterSubjects.map(_mapSubject).toList();
    final subjectIds = semesterSubjects.map((s) => s.id).toSet();

    final allRecordsLocal = await _db.getAllAttendanceRecords();
    final semesterRecordsLocal =
        allRecordsLocal.where((r) => subjectIds.contains(r.subjectId)).toList();
    final semesterRecords = semesterRecordsLocal.map(_mapRecord).toList();

    // Fetch canonical occurrences
    final startUtc = DateTime.utc(
      semesterLocal.startDate.year,
      semesterLocal.startDate.month,
      semesterLocal.startDate.day,
    );
    final endUtc = DateTime.utc(
      semesterLocal.endDate.year,
      semesterLocal.endDate.month,
      semesterLocal.endDate.day,
    );
    final allOccurrences = await _db.getOccurrences(startUtc, endUtc);
    final semesterOccurrences = allOccurrences
        .where((o) => o.subjectId != null && subjectIds.contains(o.subjectId))
        .toList();

    // Build occurrences using canonical occurrenceId (or markedAt fallback for unlinked records)
    final occurrences = <LoggedOccurrence>[];
    final occurrenceMap = <int, DailyScheduleOccurrenceLocal>{
      for (final o in semesterOccurrences) o.id: o,
    };
    for (final rec in semesterRecords) {
      final occId = rec.occurrenceId;
      final occ = (occId != null && occId > 0) ? occurrenceMap[occId] : null;
      if (occ != null) {
        occurrences.add(
          LoggedOccurrence(
            date: occ.date,
            startTime: occ.startTime,
            status: rec.status,
          ),
        );
      } else {
        occurrences.add(
          LoggedOccurrence(
            date: rec.markedAt,
            startTime: '09:00',
            status: rec.status,
          ),
        );
      }
    }

    final semester = Semester(
      id: semesterLocal.serverId ?? semesterLocal.id.toString(),
      name: semesterLocal.name,
      startDate: semesterLocal.startDate,
      endDate: semesterLocal.endDate,
      requiredAttendanceRate: semesterLocal.requiredAttendanceRate,
    );

    final analytics = AnalyticsCalculator.calculateOverallAnalytics(
      semester: semester,
      subjects: subjectEntities,
      records: semesterRecords,
      occurrences: occurrences,
    );

    // Calculate classes logged in last 7 days
    final startOfWeek = now.subtract(const Duration(days: 7));
    final recordsThisWeek = semesterRecordsLocal
        .where((r) => r.markedAt.isAfter(startOfWeek))
        .toList();
    final classesAttendedThisWeek = recordsThisWeek
        .where((r) => r.status == 'PRESENT' || r.status == 'EXTRA_PRESENT')
        .length;
    final totalClassesLoggedThisWeek = recordsThisWeek.length;

    // Calculate subject stats
    final subjectAnalyticsList = semesterSubjects.map((sub) {
      final subRecs =
          semesterRecords.where((r) => r.subjectId == sub.id).toList();
      return AnalyticsCalculator.calculateSubjectAnalytics(
        subject: _mapSubject(sub),
        records: subRecs,
      );
    }).toList();

    final bestSub = analytics.subjectComparison.highestAttendanceSubject;
    final worstSub = analytics.subjectComparison.lowestAttendanceSubject;

    final riskSubjects = subjectAnalyticsList
        .where(
          (s) =>
              s.riskStatus == RiskStatus.warning ||
              s.riskStatus == RiskStatus.critical,
        )
        .map((s) => s.subjectName)
        .toList();
    final riskStr = riskSubjects.isEmpty ? 'None' : riskSubjects.join(', ');

    const title = 'Weekly Attendance Digest';
    final body = 'Overall: ${analytics.overallPercentage.toStringAsFixed(1)}%. '
        'Logged $totalClassesLoggedThisWeek classes ($classesAttendedThisWeek attended). '
        'Best: ${bestSub?.subjectName ?? "N/A"} (${bestSub?.percentage.toStringAsFixed(1) ?? "0"}%). '
        'Worst: ${worstSub?.subjectName ?? "N/A"} (${worstSub?.percentage.toStringAsFixed(1) ?? "0"}%). '
        'Risk: $riskStr.';

    // 2. Fetch future WEEKLY_REPORT scheduled notifications
    final futureReports = await _db.getFutureNotificationsByType(
      NotificationType.weeklyReport.toShortString(),
      now,
    );

    // Cancel all future reports and delete them
    for (final r in futureReports) {
      await _notificationService.cancelNotification(
        r.effectiveAndroidNotificationId,
      );
      await _db.deleteNotification(r.id);
    }

    // 3. Create the new weekly report
    final item = NotificationItem()
      ..title = title
      ..body = body
      ..type = NotificationType.weeklyReport.toShortString()
      ..scheduledTime = nextSunday
      ..isRead = false;

    await _db.saveNotification(item);
    await _notificationService.scheduleNotification(item);
  }
}
