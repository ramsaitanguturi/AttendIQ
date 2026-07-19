import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
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

class DesiredReminder {
  final int eventId;
  final int subjectId;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final int offsetMinutes;

  const DesiredReminder({
    required this.eventId,
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

  NotificationScheduler(this._db, this._notificationService);

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
      type: s.type == 'LAB' ? SubjectType.LAB : SubjectType.THEORY,
      updatedAt: s.updatedAt,
    );
  }

  AttendanceRecord _mapRecord(AttendanceRecordLocal r) {
    return AttendanceRecord(
      id: r.id,
      serverId: r.serverId,
      eventId: r.eventId,
      subjectId: r.subjectId,
      status: r.status == 'PRESENT'
          ? AttendanceStatus.PRESENT
          : (r.status == 'ABSENT'
              ? AttendanceStatus.ABSENT
              : (r.status == 'CANCELLED'
                  ? AttendanceStatus.CANCELLED
                  : (r.status == 'EXTRA_PRESENT'
                      ? AttendanceStatus.EXTRA_PRESENT
                      : AttendanceStatus.EXTRA_ABSENT))),
      markedAt: r.markedAt,
      updatedAt: r.updatedAt,
    );
  }

  Future<void> rescheduleAll({List<int> reminderOffsets = const [15], DateTime? customNow}) async {
    final now = customNow ?? DateTime.now();
    try {
      await rescheduleRollingWindow(offsets: reminderOffsets, customNow: now);
    } catch (e, stack) {
      debugPrint('Failed to reschedule rolling window reminders: $e');
      debugPrint(stack.toString());
    }
    try {
      await checkAttendanceRisks(customNow: now);
    } catch (e, stack) {
      debugPrint('Failed to check attendance risks: $e');
      debugPrint(stack.toString());
    }
    try {
      await scheduleWeeklyReport(customNow: now);
    } catch (e, stack) {
      debugPrint('Failed to schedule weekly report: $e');
      debugPrint(stack.toString());
    }
  }

  Future<void> rescheduleRollingWindow({List<int> offsets = const [15], DateTime? customNow}) async {
    final now = customNow ?? DateTime.now();
    final rollingEnd = now.add(const Duration(days: 7));

    final startUtc = DateTime.utc(now.year, now.month, now.day);
    final endUtc = DateTime.utc(rollingEnd.year, rollingEnd.month, rollingEnd.day);

    // 1. Fetch events in the next 7 days
    final events = await _db.getEvents(startUtc, endUtc);

    // 2. Fetch subjects and templates
    final subjects = await _db.getSubjects();
    final subjectMap = {for (final s in subjects) s.id: s};

    final templates = await _db.getTemplates();

    final List<DesiredReminder> desiredReminders = [];

    for (final event in events) {
      if (event.status == 'CANCELLED') continue;

      final subject = subjectMap[event.subjectId];
      if (subject == null || subject.isDeleted) continue;

      final timeParts = event.startTime.split(':');
      if (timeParts.length < 2) continue;
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final localClassTime = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        hour,
        minute,
      );

      final template = templates.firstWhereOrNull((t) =>
          t.subjectId == event.subjectId &&
          t.weekday == event.date.weekday &&
          t.startTime == event.startTime);
      final room = template?.room;

      final isExtra = event.eventType == 'EXTRA_CLASS';

      for (final offset in offsets) {
        final triggerTime = localClassTime.subtract(Duration(minutes: offset));
        if (triggerTime.isAfter(now)) {
          desiredReminders.add(DesiredReminder(
            eventId: event.id,
            subjectId: event.subjectId,
            title: isExtra
                ? 'Extra ${subject.name} class starts in $offset minutes'
                : '${subject.name} class starts in $offset minutes',
            body: isExtra
                ? 'Extra ${subject.name} class today at ${event.startTime}'
                : 'Starts at ${event.startTime}${room != null ? " in $room" : ""}',
            scheduledTime: triggerTime,
            offsetMinutes: offset,
          ));
        }
      }
    }

    // 1b. Fetch academic events for next 14 days and schedule 1-day-before & 30-min-before reminders
    final academicEvents = await _db.getAcademicEvents(startUtc, now.add(const Duration(days: 14)));
    for (final ae in academicEvents) {
      final eventDate = DateTime(ae.date.year, ae.date.month, ae.date.day, 9, 0);
      final oneDayBefore = eventDate.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(now)) {
        desiredReminders.add(DesiredReminder(
          eventId: ae.id + 100000,
          subjectId: 0,
          title: 'Tomorrow:',
          body: '${ae.title}',
          scheduledTime: oneDayBefore,
          offsetMinutes: 1440,
        ));
      }

      if (ae.startTime != null && ae.startTime!.contains(':')) {
        final parts = ae.startTime!.split(':');
        final hour = int.tryParse(parts[0]) ?? 9;
        final minute = int.tryParse(parts[1]) ?? 0;
        final startTimeDate = DateTime(ae.date.year, ae.date.month, ae.date.day, hour, minute);
        final thirtyMinBefore = startTimeDate.subtract(const Duration(minutes: 30));
        if (thirtyMinBefore.isAfter(now)) {
          desiredReminders.add(DesiredReminder(
            eventId: ae.id + 200000,
            subjectId: 0,
            title: '${ae.title} starts at ${ae.startTime}',
            body: ae.description ?? ae.title,
            scheduledTime: thirtyMinBefore,
            offsetMinutes: 30,
          ));
        }
      }
    }

    // 3. Fetch future scheduled class reminders
    final futureNotifications = await _db.getFutureNotificationsByType(
      NotificationType.CLASS_REMINDER.toShortString(),
      now,
    );

    final List<int> keptIds = [];
    final List<DesiredReminder> toCreate = [];

    for (final desired in desiredReminders) {
      final existing = futureNotifications.firstWhereOrNull((n) =>
          n.relatedId == desired.eventId.toString() &&
          n.scheduledTime.isAtSameMomentAs(desired.scheduledTime));
      if (existing != null) {
        keptIds.add(existing.id);
      } else {
        toCreate.add(desired);
      }
    }

    // 4. Cancel and delete stale notifications
    final toDelete = futureNotifications.where((n) => !keptIds.contains(n.id)).toList();
    for (final n in toDelete) {
      await _notificationService.cancelNotification(n.id);
      await _db.deleteNotification(n.id);
    }

    // 5. Create and schedule new ones
    for (final desired in toCreate) {
      final item = NotificationItem()
        ..title = desired.title
        ..body = desired.body
        ..type = NotificationType.CLASS_REMINDER.toShortString()
        ..scheduledTime = desired.scheduledTime
        ..relatedId = desired.eventId.toString()
        ..isRead = false;

      await _db.saveNotification(item);
      await _notificationService.scheduleNotification(item);
    }
  }

  Future<void> checkAttendanceRisks({DateTime? customNow}) async {
    final now = customNow ?? DateTime.now();

    final semesterLocal = await _db.getActiveSemester();
    if (semesterLocal == null) return;

    final subjects = await _db.getSubjects();
    final semesterSubjects = subjects.where((s) => s.semesterId == semesterLocal.id).toList();

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

      if (analytics.riskStatus == RiskStatus.CRITICAL) {
        alertType = NotificationType.LOW_ATTENDANCE_ALERT;
        title = 'Low Attendance Alert: ${subject.name}';
        final classesNeeded = analytics.classesNeeded;
        body = 'Your ${subject.name} attendance is below $target% (${analytics.percentage.toStringAsFixed(1)}%). '
            '${classesNeeded != null && classesNeeded > 0 ? "Attend next $classesNeeded classes to recover." : ""}';
      } else if (analytics.riskStatus == RiskStatus.WARNING) {
        alertType = NotificationType.ATTENDANCE_WARNING;
        title = 'Attendance Warning: ${subject.name}';
        body = 'Your ${subject.name} attendance is close to falling below target. Currently at ${analytics.percentage.toStringAsFixed(1)}% (Target: $target%).';
      }

      if (alertType != null && title != null && body != null) {
        // Find latest attendance record marked date
        final sortedRecords = recordsLocal.toList()..sort((a, b) => b.markedAt.compareTo(a.markedAt));
        final latestRecord = sortedRecords.first;

        // Fetch last notification of this type for this subject
        final lastNotification = await _db.getLastNotification(
          alertType.toShortString(),
          subject.id.toString(),
        );

        // If no notification was sent, or the latest log occurred after the last warning notification
        if (lastNotification == null || latestRecord.markedAt.isAfter(lastNotification.scheduledTime)) {
          final item = NotificationItem()
            ..title = title
            ..body = body
            ..type = alertType.toShortString()
            ..scheduledTime = now
            ..relatedId = subject.id.toString()
            ..isRead = false;

          await _db.saveNotification(item);
          await _notificationService.scheduleNotification(item);
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
    final semesterSubjects = subjects.where((s) => s.semesterId == semesterLocal.id).toList();
    if (semesterSubjects.isEmpty) return;

    final subjectEntities = semesterSubjects.map(_mapSubject).toList();
    final subjectIds = semesterSubjects.map((s) => s.id).toSet();

    final allRecordsLocal = await _db.getAllAttendanceRecords();
    final semesterRecordsLocal = allRecordsLocal.where((r) => subjectIds.contains(r.subjectId)).toList();
    final semesterRecords = semesterRecordsLocal.map(_mapRecord).toList();

    // Fetch events
    final startUtc = DateTime.utc(semesterLocal.startDate.year, semesterLocal.startDate.month, semesterLocal.startDate.day);
    final endUtc = DateTime.utc(semesterLocal.endDate.year, semesterLocal.endDate.month, semesterLocal.endDate.day);
    final allEvents = await _db.getEvents(startUtc, endUtc);
    final semesterEvents = allEvents.where((e) => subjectIds.contains(e.subjectId)).toList();

    // Build occurrences
    final occurrences = <LoggedOccurrence>[];
    final eventMap = {for (final e in semesterEvents) e.id: e};
    for (final rec in semesterRecords) {
      final event = eventMap[rec.eventId];
      if (event != null) {
        occurrences.add(LoggedOccurrence(
          date: event.date,
          startTime: event.startTime,
          status: rec.status,
        ));
      } else {
        occurrences.add(LoggedOccurrence(
          date: rec.markedAt,
          startTime: '09:00',
          status: rec.status,
        ));
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
    final recordsThisWeek = semesterRecordsLocal.where((r) => r.markedAt.isAfter(startOfWeek)).toList();
    final classesAttendedThisWeek = recordsThisWeek
        .where((r) => r.status == 'PRESENT' || r.status == 'EXTRA_PRESENT')
        .length;
    final totalClassesLoggedThisWeek = recordsThisWeek.length;

    // Calculate subject stats
    final subjectAnalyticsList = semesterSubjects.map((sub) {
      final subRecs = semesterRecords.where((r) => r.subjectId == sub.id).toList();
      return AnalyticsCalculator.calculateSubjectAnalytics(
        subject: _mapSubject(sub),
        records: subRecs,
      );
    }).toList();

    final bestSub = analytics.subjectComparison.highestAttendanceSubject;
    final worstSub = analytics.subjectComparison.lowestAttendanceSubject;

    final riskSubjects = subjectAnalyticsList
        .where((s) => s.riskStatus == RiskStatus.WARNING || s.riskStatus == RiskStatus.CRITICAL)
        .map((s) => s.subjectName)
        .toList();
    final riskStr = riskSubjects.isEmpty ? 'None' : riskSubjects.join(', ');

    final title = 'Weekly Attendance Digest';
    final body = 'Overall: ${analytics.overallPercentage.toStringAsFixed(1)}%. '
        'Logged $totalClassesLoggedThisWeek classes ($classesAttendedThisWeek attended). '
        'Best: ${bestSub?.subjectName ?? "N/A"} (${bestSub?.percentage.toStringAsFixed(1) ?? "0"}%). '
        'Worst: ${worstSub?.subjectName ?? "N/A"} (${worstSub?.percentage.toStringAsFixed(1) ?? "0"}%). '
        'Risk: $riskStr.';

    // 2. Fetch future WEEKLY_REPORT scheduled notifications
    final futureReports = await _db.getFutureNotificationsByType(
      NotificationType.WEEKLY_REPORT.toShortString(),
      now,
    );

    // Cancel all future reports and delete them
    for (final r in futureReports) {
      await _notificationService.cancelNotification(r.id);
      await _db.deleteNotification(r.id);
    }

    // 3. Create the new weekly report
    final item = NotificationItem()
      ..title = title
      ..body = body
      ..type = NotificationType.WEEKLY_REPORT.toShortString()
      ..scheduledTime = nextSunday
      ..isRead = false;

    await _db.saveNotification(item);
    await _notificationService.scheduleNotification(item);
  }
}
