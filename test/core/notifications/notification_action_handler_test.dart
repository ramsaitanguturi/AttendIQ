import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/core/notifications/handlers/notification_action_handler.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../test_helpers/test_isar_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestIsarInstance testDb;
  late Isar isar;

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  setUp(() {
    testDb = openTestIsar(prefix: 'notif_action');
    isar = testDb.isar;
  });

  tearDown(() async {
    await testDb.dispose();
  });

  group('NotificationActionHandler Tests', () {
    test('ACTION_PRESENT materializes occurrence and records attendance', () async {
      final date = DateTime.utc(2026, 11, 15);
      final payload = NotificationActionPayload(
        date: date,
        subjectId: 101,
        startTime: '10:00',
        endTime: '11:00',
        title: 'Compiler Design',
        room: 'Lab 3',
      );

      final result = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionPresent,
        payload: payload.encode(),
        isarInstance: isar,
      );

      expect(result.success, isTrue);
      expect(result.appliedStatus, equals(OccurrenceStatus.PRESENT));

      // Verify occurrence was created/updated in Isar
      final occurrences = isar.dailyScheduleOccurrenceLocals.where().findAll();
      expect(occurrences.length, equals(1));
      expect(occurrences.first.status, equals('PRESENT'));
      expect(occurrences.first.subjectId, equals(101));
      expect(occurrences.first.room, equals('Lab 3'));

      // Verify attendance record was inserted
      final records = isar.attendanceRecordLocals.where().findAll();
      expect(records.length, equals(1));
      expect(records.first.status, equals('PRESENT'));
      expect(records.first.subjectId, equals(101));
      expect(records.first.occurrenceId, equals(occurrences.first.id));
    });

    test('ACTION_ABSENT records absent attendance correctly', () async {
      final date = DateTime.utc(2026, 11, 15);
      final payload = NotificationActionPayload(
        date: date,
        subjectId: 102,
        startTime: '11:00',
        endTime: '12:00',
        title: 'Computer Networks',
      );

      final result = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionAbsent,
        payload: payload.encode(),
        isarInstance: isar,
      );

      expect(result.success, isTrue);
      expect(result.appliedStatus, equals(OccurrenceStatus.ABSENT));

      final occurrences = isar.dailyScheduleOccurrenceLocals.where().findAll();
      expect(occurrences.first.status, equals('ABSENT'));

      final records = isar.attendanceRecordLocals.where().findAll();
      expect(records.first.status, equals('ABSENT'));
    });

    test('ACTION_LATE records late attendance correctly', () async {
      final date = DateTime.utc(2026, 11, 15);
      final payload = NotificationActionPayload(
        date: date,
        subjectId: 103,
        startTime: '14:00',
        endTime: '15:00',
        title: 'Operating Systems',
      );

      final result = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionLate,
        payload: payload.encode(),
        isarInstance: isar,
      );

      expect(result.success, isTrue);
      expect(result.appliedStatus, equals(OccurrenceStatus.LATE));

      final occurrences = isar.dailyScheduleOccurrenceLocals.where().findAll();
      expect(occurrences.first.status, equals('LATE'));

      final records = isar.attendanceRecordLocals.where().findAll();
      expect(records.first.status, equals('LATE'));
    });

    test('ACTION_CANCELLED updates occurrence and soft-deletes attendance record', () async {
      final date = DateTime.utc(2026, 11, 15);
      final payload = NotificationActionPayload(
        date: date,
        subjectId: 104,
        startTime: '15:00',
        endTime: '16:00',
        title: 'Software Engineering',
      );

      // First mark present
      await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionPresent,
        payload: payload.encode(),
        isarInstance: isar,
      );

      expect(isar.attendanceRecordLocals.where().isDeletedEqualTo(false).count(), equals(1));

      // Now cancel
      final cancelResult = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionCancelled,
        payload: payload.encode(),
        isarInstance: isar,
      );

      expect(cancelResult.success, isTrue);
      expect(cancelResult.appliedStatus, equals(OccurrenceStatus.CANCELLED));

      final occurrences = isar.dailyScheduleOccurrenceLocals.where().findAll();
      expect(occurrences.first.status, equals('CANCELLED'));

      // Active attendance records should be 0
      final activeRecords = isar.attendanceRecordLocals.where().isDeletedEqualTo(false).findAll();
      expect(activeRecords.isEmpty, isTrue);
    });

    test('Decodes canonical slot: string payload correctly', () {
      const slotKeyPayload = 'slot:2026-11-15_105_1_09:00_10:00_REGULAR_CLASS_AI_Lab';
      final decoded = NotificationActionPayload.decode(slotKeyPayload);

      expect(decoded, isNotNull);
      expect(decoded!.subjectId, equals(105));
      expect(decoded.startTime, equals('09:00'));
      expect(decoded.endTime, equals('10:00'));
      expect(decoded.title, equals('AI_Lab'));
    });
  });
}
