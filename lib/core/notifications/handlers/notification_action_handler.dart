import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../../../features/attendance/data/models/attendance_record_local.dart';
import '../../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../features/timetable/data/utils/occurrence_identity.dart';
import '../../../features/timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../features/widgets/data/widget_data_service.dart';
import '../../background/background_worker.dart';

class NotificationActionResult {
  final bool success;
  final String? message;
  final OccurrenceStatus? appliedStatus;
  final int? occurrenceId;

  const NotificationActionResult({
    required this.success,
    this.message,
    this.appliedStatus,
    this.occurrenceId,
  });
}

class NotificationActionPayload {
  final int? occurrenceId;
  final String? slotKey;
  final int? subjectId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String title;
  final String? room;

  const NotificationActionPayload({
    this.occurrenceId,
    this.slotKey,
    this.subjectId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
    this.room,
  });

  Map<String, dynamic> toJson() {
    return {
      'occurrenceId': occurrenceId,
      'slotKey': slotKey,
      'subjectId': subjectId,
      'date': formatUtcDateKey(date),
      'startTime': startTime,
      'endTime': endTime,
      'title': title,
      if (room != null) 'room': room,
    };
  }

  String encode() => jsonEncode(toJson());

  static NotificationActionPayload? decode(String raw) {
    try {
      if (raw.startsWith('{')) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final dateStr = map['date'] as String? ?? '';
        final parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
        return NotificationActionPayload(
          occurrenceId: map['occurrenceId'] as int?,
          slotKey: map['slotKey'] as String?,
          subjectId: map['subjectId'] as int?,
          date: normalizeUtcDate(parsedDate),
          startTime: map['startTime'] as String? ?? '09:00',
          endTime: map['endTime'] as String? ?? '10:00',
          title: map['title'] as String? ?? 'Class',
          room: map['room'] as String?,
        );
      } else if (raw.startsWith('slot:')) {
        final slotKey = raw.substring(5);
        if (slotKey.contains('|')) {
          final segments = slotKey.split('|');
          int? subId;
          DateTime? date;
          String start = '09:00';
          String end = '10:00';
          String title = 'Class';
          for (final seg in segments) {
            if (seg.startsWith('sub:')) {
              subId = int.tryParse(seg.substring(4));
            } else if (RegExp(r'^\d{8}$').hasMatch(seg)) {
              final y = int.tryParse(seg.substring(0, 4));
              final m = int.tryParse(seg.substring(4, 6));
              final d = int.tryParse(seg.substring(6, 8));
              if (y != null && m != null && d != null) {
                date = DateTime.utc(y, m, d);
              }
            } else if (seg.contains('-') && seg.split('-').length == 2 && seg.contains(':')) {
              final timeParts = seg.split('-');
              start = timeParts[0];
              end = timeParts[1];
            } else if (seg != 'REGULAR' && seg != 'EXTRA' && seg != 'EXAM' && seg != 'EVENT' && !seg.startsWith('rule:')) {
              title = seg;
            }
          }
          return NotificationActionPayload(
            slotKey: slotKey,
            subjectId: subId,
            date: date ?? normalizeUtcDate(DateTime.now()),
            startTime: start,
            endTime: end,
            title: title,
          );
        } else {
          final parts = slotKey.split('_');
          if (parts.length >= 5) {
            final datePart = parts[0];
            final subId = int.tryParse(parts[1]);
            final startTime = parts[3];
            final endTime = parts[4];
            // Remaining parts are type and title
            final remaining = parts.sublist(5).join('_');
            final cleanTitle = remaining.replaceFirst(RegExp(r'^(REGULAR_CLASS|EXTRA_CLASS|EXAM|EVENT)_?'), '');
            final parsedDate = DateTime.tryParse(datePart) ?? DateTime.now();
            return NotificationActionPayload(
              slotKey: slotKey,
              subjectId: subId,
              date: normalizeUtcDate(parsedDate),
              startTime: startTime,
              endTime: endTime,
              title: cleanTitle.isNotEmpty ? cleanTitle : 'Class',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Failed to decode action payload: $raw, error: $e');
      }
    }
    return null;
  }
}

class NotificationActionHandler {
  NotificationActionHandler._();

  static const String actionPresent = 'ACTION_PRESENT';
  static const String actionAbsent = 'ACTION_ABSENT';
  static const String actionCancelled = 'ACTION_CANCELLED';
  static const String actionLate = 'ACTION_LATE';

  /// Maps an action identifier string to [OccurrenceStatus].
  static OccurrenceStatus? parseActionId(String actionId) {
    switch (actionId.toUpperCase().trim()) {
      case actionPresent:
        return OccurrenceStatus.PRESENT;
      case actionAbsent:
        return OccurrenceStatus.ABSENT;
      case actionCancelled:
        return OccurrenceStatus.CANCELLED;
      case actionLate:
        return OccurrenceStatus.LATE;
      default:
        return null;
    }
  }

  /// Entry point for handling notification action clicks across both
  /// foreground and background isolates.
  static Future<NotificationActionResult> handleAction({
    required String actionId,
    required String? payload,
    Isar? isarInstance,
  }) async {
    final status = parseActionId(actionId);
    if (status == null) {
      return const NotificationActionResult(
        success: false,
        message: 'Unknown action identifier',
      );
    }

    if (payload == null || payload.trim().isEmpty) {
      return const NotificationActionResult(
        success: false,
        message: 'Empty notification payload',
      );
    }

    final parsedPayload = NotificationActionPayload.decode(payload);
    if (parsedPayload == null) {
      return const NotificationActionResult(
        success: false,
        message: 'Unable to parse occurrence from payload',
      );
    }

    if (isarInstance != null && isarInstance.isOpen) {
      return await _executeWithIsar(isarInstance, parsedPayload, status);
    }

    // Background execution with isolated Isar instance
    NotificationActionResult? result;
    await runWithBackgroundIsar((isar) async {
      result = await _executeWithIsar(isar, parsedPayload, status);
      return result?.success ?? false;
    });

    return result ??
        const NotificationActionResult(
          success: false,
          message: 'Background database initialization failed',
        );
  }

  static Future<NotificationActionResult> _executeWithIsar(
    Isar isar,
    NotificationActionPayload payload,
    OccurrenceStatus newStatus,
  ) async {
    return await isar.writeAsync((isar) {
      final nowUtc = DateTime.now().toUtc();
      final dateUtc = normalizeUtcDate(payload.date);

      // 1. Locate or create DailyScheduleOccurrenceLocal
      DailyScheduleOccurrenceLocal? occurrence;

      if (payload.occurrenceId != null && payload.occurrenceId! > 0) {
        occurrence = isar.dailyScheduleOccurrenceLocals.get(payload.occurrenceId!);
      }

      if (occurrence == null && payload.slotKey != null && payload.slotKey!.isNotEmpty) {
        final matches = isar.dailyScheduleOccurrenceLocals
            .where()
            .slotKeyEqualTo(payload.slotKey)
            .findAll();
        for (final m in matches) {
          if (!m.isDeleted) {
            occurrence = m;
            break;
          }
        }
      }

      if (occurrence == null && payload.subjectId != null) {
        final dayMatches = isar.dailyScheduleOccurrenceLocals
            .where()
            .dateEqualTo(dateUtc)
            .findAll()
            .where((o) =>
                !o.isDeleted &&
                o.subjectId == payload.subjectId &&
                o.startTime == payload.startTime)
            .toList();
        if (dayMatches.isNotEmpty) {
          occurrence = dayMatches.first;
        }
      }

      // If occurrence does not exist on disk, materialize it now
      if (occurrence == null) {
        final canonicalKey = payload.slotKey ??
            computeCanonicalSlotKey(
              date: dateUtc,
              subjectId: payload.subjectId,
              startTime: payload.startTime,
              endTime: payload.endTime,
              type: 'REGULAR_CLASS',
              title: payload.title,
            );

        occurrence = DailyScheduleOccurrenceLocal()
          ..id = isar.dailyScheduleOccurrenceLocals.autoIncrement()
          ..date = dateUtc
          ..subjectId = payload.subjectId
          ..title = payload.title
          ..startTime = payload.startTime
          ..endTime = payload.endTime
          ..type = 'REGULAR_CLASS'
          ..status = newStatus.toShortString()
          ..createdFrom = 'WEEKLY_RULE'
          ..room = payload.room
          ..slotKey = canonicalKey
          ..createdAt = nowUtc
          ..updatedAt = nowUtc
          ..isDirty = false
          ..isDeleted = false;

        isar.dailyScheduleOccurrenceLocals.put(occurrence);
      } else {
        // Prevent redundant identical mutation within short window
        if (occurrence.status.toUpperCase() == newStatus.toShortString() &&
            occurrence.updatedAt.isAfter(nowUtc.subtract(const Duration(seconds: 2)))) {
          return NotificationActionResult(
            success: true,
            message: 'Duplicate action suppressed (already recorded)',
            appliedStatus: newStatus,
            occurrenceId: occurrence.id,
          );
        }

        occurrence.status = newStatus.toShortString();
        occurrence.updatedAt = nowUtc;
        isar.dailyScheduleOccurrenceLocals.put(occurrence);
      }

      final occId = occurrence.id;

      // 2. Persist or remove AttendanceRecordLocal
      final existingRecords = isar.attendanceRecordLocals
          .where()
          .occurrenceIdEqualTo(occId)
          .findAll();

      if (newStatus == OccurrenceStatus.CANCELLED) {
        for (final r in existingRecords) {
          r.isDeleted = true;
          r.updatedAt = nowUtc;
          isar.attendanceRecordLocals.put(r);
        }
      } else {
        // Status: PRESENT, ABSENT, or LATE
        final statusString = newStatus.toShortString();
        AttendanceRecordLocal record;

        if (existingRecords.isNotEmpty) {
          record = existingRecords.first;
          record.status = statusString;
          record.markedAt = dateUtc;
          record.updatedAt = nowUtc;
          record.isDeleted = false;
        } else {
          record = AttendanceRecordLocal()
            ..id = isar.attendanceRecordLocals.autoIncrement()
            ..occurrenceId = occId
            ..eventId = occId
            ..subjectId = payload.subjectId ?? 0
            ..status = statusString
            ..markedAt = dateUtc
            ..createdAt = nowUtc
            ..updatedAt = nowUtc
            ..isDirty = false
            ..isDeleted = false;
        }
        isar.attendanceRecordLocals.put(record);
      }

      // 3. Update Android Home Screen Widgets
      try {
        final widgetService = WidgetDataService.fromIsar(isar);
        widgetService.updateAllWidgets(respectEnabledSetting: true);
      } catch (widgetError) {
        if (kDebugMode) {
          developer.log('Widget refresh non-fatal error: $widgetError');
        }
      }

      return NotificationActionResult(
        success: true,
        message: 'Attendance successfully marked as ${newStatus.toShortString()}',
        appliedStatus: newStatus,
        occurrenceId: occId,
      );
    });
  }
}
