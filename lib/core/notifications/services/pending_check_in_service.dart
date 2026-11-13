import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../features/attendance/data/models/attendance_record_local.dart';
import '../../../features/attendance/domain/services/historical_attendance_service.dart';
import '../../../features/attendance/presentation/controllers/subject_attendance_stats_provider.dart';
import '../../../features/subject/data/models/subject_local.dart';
import '../../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../../features/timetable/data/models/schedule_exception_local.dart';
import '../../../features/timetable/data/models/weekly_schedule_rule_local.dart';
import '../../../features/timetable/data/utils/occurrence_identity.dart';
import '../../../features/timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../../features/timetable/presentation/controllers/academic_calendar_controller.dart';
import '../../../features/timetable/presentation/controllers/today_schedule_provider.dart';
import '../../database/isar_provider.dart';

class PendingCheckInItem {
  final int? occurrenceId;
  final int subjectId;
  final String subjectName;
  final String? subjectCode;
  final int? ruleId;
  final String? slotKey;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? room;
  final String type; // 'REGULAR_CLASS', 'EXTRA_CLASS'

  const PendingCheckInItem({
    this.occurrenceId,
    required this.subjectId,
    required this.subjectName,
    this.subjectCode,
    this.ruleId,
    this.slotKey,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.room,
    this.type = 'REGULAR_CLASS',
  });
}

final Provider<PendingCheckInService> pendingCheckInServiceProvider =
    Provider<PendingCheckInService>((ref) {
  final isar = ref.watch(isarProvider).requireValue;
  final histService = ref.watch(historicalAttendanceServiceProvider);
  return PendingCheckInService(
    isar,
    histService,
    onInvalidate: () {
      ref.invalidate(todayScheduleProvider);
      ref.invalidate(allDailyOccurrencesProvider);
      ref.invalidate(monthlyCalendarDataProvider);
      ref.invalidate(allSubjectAttendanceStatsProvider);
      ref.invalidate(overallAttendancePercentageProvider);
      ref.invalidate(pendingCheckInsProvider);
    },
  );
});

final AutoDisposeStreamProvider<List<PendingCheckInItem>>
    pendingCheckInsProvider =
    StreamProvider.autoDispose<List<PendingCheckInItem>>((ref) {
  final service = ref.watch(pendingCheckInServiceProvider);
  return service.watchPendingCheckIns();
});

class PendingCheckInService {
  final Isar _isar;
  final HistoricalAttendanceService _historicalService;
  final void Function()? onInvalidate;

  PendingCheckInService(
    this._isar,
    this._historicalService, {
    this.onInvalidate,
  });

  /// Streams pending check-ins, auto-refreshing whenever occurrences or
  /// attendance records change in the database.
  Stream<List<PendingCheckInItem>> watchPendingCheckIns({
    int lookbackDays = 7,
  }) async* {
    yield await getPendingCheckIns(lookbackDays: lookbackDays);

    final occStream = _isar.dailyScheduleOccurrenceLocals.where().watchLazy();
    final attStream = _isar.attendanceRecordLocals.where().watchLazy();

    await for (final _ in StreamGroup.merge([occStream, attStream])) {
      yield await getPendingCheckIns(lookbackDays: lookbackDays);
    }
  }

  /// Scans scheduled classes up to [lookbackDays] in the past where the class
  /// has started but attendance has not yet been logged.
  Future<List<PendingCheckInItem>> getPendingCheckIns({
    DateTime? customNow,
    int lookbackDays = 7,
  }) async {
    final now = customNow ?? DateTime.now();
    final startUtc =
        normalizeUtcDate(now.subtract(Duration(days: lookbackDays)));
    final endUtc = normalizeUtcDate(now);

    final subjects =
        await _isar.subjectLocals.where().isDeletedEqualTo(false).findAll();
    final subjectMap = {for (final s in subjects) s.id: s};

    final exceptions = await _isar.scheduleExceptionLocals
        .where()
        .dateBetween(startUtc, endUtc)
        .isDeletedEqualTo(false)
        .findAll();

    final holidayDates = <String>{};
    final cancelledSubjectsByDate = <String, Set<int>>{};
    for (final ex in exceptions) {
      final key = formatUtcDateKey(ex.date);
      if (ex.type == 'HOLIDAY') {
        holidayDates.add(key);
      } else if (ex.type == 'CANCELLED_CLASS' && ex.subjectId != null) {
        cancelledSubjectsByDate
            .putIfAbsent(key, () => <int>{})
            .add(ex.subjectId!);
      }
    }

    final occurrences = await _isar.dailyScheduleOccurrenceLocals
        .where()
        .dateBetween(startUtc, endUtc)
        .isDeletedEqualTo(false)
        .findAll();

    final records = await _isar.attendanceRecordLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();

    final recordedOccurrenceIds = <int>{
      for (final r in records)
        if (r.occurrenceId != null && r.occurrenceId! > 0) r.occurrenceId!,
    };

    final recordedSubjectDates = <String>{
      for (final r in records) '${r.subjectId}_${formatUtcDateKey(r.markedAt)}',
    };

    final pendingList = <PendingCheckInItem>[];
    final consumedSlotKeys = <String>{};

    // 1. Process Materialized Occurrences
    for (final occ in occurrences) {
      if (occ.status.toUpperCase() != 'UPCOMING') continue;
      if (occ.subjectId == null) continue;

      final dateKey = formatUtcDateKey(occ.date);
      if (holidayDates.contains(dateKey)) continue;
      if (cancelledSubjectsByDate[dateKey]?.contains(occ.subjectId!) ?? false) {
        continue;
      }

      if (recordedOccurrenceIds.contains(occ.id)) continue;

      final sub = subjectMap[occ.subjectId!];
      if (sub == null || sub.isDeleted) continue;

      // Check if start time has arrived
      final parts = occ.startTime.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final classDateTime = DateTime(
          occ.date.year,
          occ.date.month,
          occ.date.day,
          h,
          m,
        );
        if (classDateTime.isAfter(now)) {
          // Class is in future today, not yet pending
          continue;
        }
      }

      final canonicalKey = occ.slotKey ??
          computeCanonicalSlotKey(
            date: occ.date,
            subjectId: occ.subjectId,
            ruleId: occ.ruleId,
            startTime: occ.startTime,
            endTime: occ.endTime,
            type: occ.type,
            title: occ.title,
          );
      consumedSlotKeys.add(canonicalKey);

      pendingList.add(PendingCheckInItem(
        occurrenceId: occ.id,
        subjectId: occ.subjectId!,
        subjectName: sub.name,
        subjectCode: sub.code,
        ruleId: occ.ruleId,
        slotKey: canonicalKey,
        date: occ.date,
        startTime: occ.startTime,
        endTime: occ.endTime,
        room: occ.room,
        type: occ.type,
      ));
    }

    // 2. Process Unmaterialized Active Weekly Rules within Lookback Window
    final rules = await _isar.weeklyScheduleRuleLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();

    for (int d = 0; d <= lookbackDays; d++) {
      final curDate = now.subtract(Duration(days: d));
      final dateUtc = normalizeUtcDate(curDate);
      final dateKey = formatUtcDateKey(dateUtc);

      if (holidayDates.contains(dateKey)) continue;

      for (final rule in rules) {
        if (!rule.isActive) continue;
        if (rule.dayOfWeek != dateUtc.weekday) continue;
        if (cancelledSubjectsByDate[dateKey]?.contains(rule.subjectId) ??
            false) {
          continue;
        }

        final sub = subjectMap[rule.subjectId];
        if (sub == null || sub.isDeleted) continue;

        // Check if start time has arrived
        final parts = rule.startTime.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          final classDateTime = DateTime(
            curDate.year,
            curDate.month,
            curDate.day,
            h,
            m,
          );
          if (classDateTime.isAfter(now)) {
            continue;
          }
        }

        final canonicalKey = computeCanonicalSlotKey(
          date: dateUtc,
          subjectId: rule.subjectId,
          ruleId: rule.id,
          startTime: rule.startTime,
          endTime: rule.endTime,
          type: 'REGULAR_CLASS',
          title: sub.name,
        );

        if (consumedSlotKeys.contains(canonicalKey)) continue;
        if (recordedSubjectDates.contains('${rule.subjectId}_$dateKey'))
          continue;

        consumedSlotKeys.add(canonicalKey);
        pendingList.add(PendingCheckInItem(
          subjectId: rule.subjectId,
          subjectName: sub.name,
          subjectCode: sub.code,
          ruleId: rule.id,
          slotKey: canonicalKey,
          date: dateUtc,
          startTime: rule.startTime,
          endTime: rule.endTime,
          room: rule.room,
          type: 'REGULAR_CLASS',
        ));
      }
    }

    // Sort most recent class first
    pendingList.sort((a, b) {
      final cmp = b.date.compareTo(a.date);
      if (cmp != 0) return cmp;
      return b.startTime.compareTo(a.startTime);
    });

    return pendingList;
  }

  /// Resolves an unanswered check-in by mutating its attendance record and occurrence.
  Future<DailyScheduleOccurrence> resolveCheckIn({
    required PendingCheckInItem item,
    required OccurrenceStatus status,
  }) async {
    final occ = await _historicalService.setAttendanceStatus(
      date: item.date,
      subjectId: item.subjectId,
      occurrenceId: item.occurrenceId,
      ruleId: item.ruleId,
      startTime: item.startTime,
      endTime: item.endTime,
      title: item.subjectName,
      room: item.room,
      targetStatus: status,
      type: item.type == 'EXTRA_CLASS'
          ? OccurrenceType.EXTRA_CLASS
          : OccurrenceType.REGULAR_CLASS,
    );

    // Invalidate UI providers
    onInvalidate?.call();

    return occ;
  }

  /// Batch resolves multiple pending check-ins.
  Future<void> resolveAll({
    required List<PendingCheckInItem> items,
    required OccurrenceStatus status,
  }) async {
    for (final item in items) {
      await resolveCheckIn(item: item, status: status);
    }
  }
}

/// Helper stream combiner for Isar watchers
class StreamGroup {
  static Stream<T> merge<T>(Iterable<Stream<T>> streams) {
    final controller = StreamController<T>.broadcast();
    final subscriptions = <StreamSubscription<T>>[];

    void handleDone() {
      if (subscriptions.every((s) => s.isPaused)) {
        controller.close();
      }
    }

    for (final stream in streams) {
      subscriptions.add(
        stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: handleDone,
        ),
      );
    }

    controller.onCancel = () {
      for (final s in subscriptions) {
        s.cancel();
      }
    };

    return controller.stream;
  }
}
