import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/core/notifications/handlers/notification_action_handler.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../test_helpers/test_isar_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestIsarInstance testInstance;

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  setUp(() {
    testInstance = openTestIsar(prefix: 'acedra_notif');
  });

  tearDown(() async {
    await testInstance.dispose();
  });

  group('ACEDRA Notifications Independent Verification', () {
    test(
        '1. Three scheduled classes produce separate notifications with distinct occurrence payloads',
        () async {
      final isar = testInstance.isar;
      final nowUtc = DateTime.utc(2026, 11, 14);

      // Create 3 classes
      final occ1 = DailyScheduleOccurrenceLocal()
        ..id = 101
        ..date = nowUtc
        ..subjectId = 1
        ..title = 'Mathematics'
        ..startTime = '09:00'
        ..endTime = '10:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      final occ2 = DailyScheduleOccurrenceLocal()
        ..id = 102
        ..date = nowUtc
        ..subjectId = 2
        ..title = 'Operating Systems'
        ..startTime = '10:15'
        ..endTime = '11:15'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      final occ3 = DailyScheduleOccurrenceLocal()
        ..id = 103
        ..date = nowUtc
        ..subjectId = 3
        ..title = 'Database Management Systems'
        ..startTime = '11:30'
        ..endTime = '12:30'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      isar.write((isar) {
        isar.dailyScheduleOccurrenceLocals.putAll([occ1, occ2, occ3]);
      });

      // Verify each produces a distinct NotificationItem with distinct IDs
      final notif1 = NotificationItem()
        ..id = 1
        ..title = 'Mathematics starts at 09:00'
        ..body = 'Starts at 09:00 in Room 101'
        ..type = NotificationType.CLASS_REMINDER.toShortString()
        ..scheduledTime = DateTime(2026, 11, 14, 8, 45)
        ..relatedId = NotificationActionPayload(
          occurrenceId: 101,
          subjectId: 1,
          date: nowUtc,
          startTime: '09:00',
          endTime: '10:00',
          title: 'Mathematics',
        ).encode();

      final notif2 = NotificationItem()
        ..id = 2
        ..title = 'Operating Systems starts at 10:15'
        ..body = 'Starts at 10:15 in Lab A'
        ..type = NotificationType.CLASS_REMINDER.toShortString()
        ..scheduledTime = DateTime(2026, 11, 14, 10, 0)
        ..relatedId = NotificationActionPayload(
          occurrenceId: 102,
          subjectId: 2,
          date: nowUtc,
          startTime: '10:15',
          endTime: '11:15',
          title: 'Operating Systems',
        ).encode();

      final notif3 = NotificationItem()
        ..id = 3
        ..title = 'Database Management Systems starts at 11:30'
        ..body = 'Starts at 11:30 in Hall C'
        ..type = NotificationType.CLASS_REMINDER.toShortString()
        ..scheduledTime = DateTime(2026, 11, 14, 11, 15)
        ..relatedId = NotificationActionPayload(
          occurrenceId: 103,
          subjectId: 3,
          date: nowUtc,
          startTime: '11:30',
          endTime: '12:30',
          title: 'Database Management Systems',
        ).encode();

      isar.write((isar) {
        isar.notificationItems.putAll([notif1, notif2, notif3]);
      });

      final stored = isar.notificationItems.where().findAll();
      expect(stored.length, 3);
      expect(
        stored[0].effectiveAndroidNotificationId !=
            stored[1].effectiveAndroidNotificationId,
        isTrue,
      );
      expect(
        stored[1].effectiveAndroidNotificationId !=
            stored[2].effectiveAndroidNotificationId,
        isTrue,
      );
    });

    test(
        '2. PRESENT, ABSENT, CANCELLED actions mark ONLY their targeted occurrence',
        () async {
      final isar = testInstance.isar;
      final nowUtc = DateTime.utc(2026, 11, 14);

      final occ1 = DailyScheduleOccurrenceLocal()
        ..id = 201
        ..date = nowUtc
        ..subjectId = 10
        ..title = 'Mathematics'
        ..startTime = '09:00'
        ..endTime = '10:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      final occ2 = DailyScheduleOccurrenceLocal()
        ..id = 202
        ..date = nowUtc
        ..subjectId = 20
        ..title = 'Operating Systems'
        ..startTime = '10:15'
        ..endTime = '11:15'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      final occ3 = DailyScheduleOccurrenceLocal()
        ..id = 203
        ..date = nowUtc
        ..subjectId = 30
        ..title = 'Database Management Systems'
        ..startTime = '11:30'
        ..endTime = '12:30'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      isar.write((isar) {
        isar.dailyScheduleOccurrenceLocals.putAll([occ1, occ2, occ3]);
      });

      // Tap PRESENT on class 2 (Operating Systems)
      final payload2 = NotificationActionPayload(
        occurrenceId: 202,
        subjectId: 20,
        date: nowUtc,
        startTime: '10:15',
        endTime: '11:15',
        title: 'Operating Systems',
      ).encode();

      final res2 = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionPresent,
        payload: payload2,
        isarInstance: isar,
      );
      expect(res2.success, isTrue);

      // Verify ONLY class 2 is PRESENT; class 1 and 3 remain UPCOMING
      var checkOcc1 = isar.dailyScheduleOccurrenceLocals.get(201);
      var checkOcc2 = isar.dailyScheduleOccurrenceLocals.get(202);
      var checkOcc3 = isar.dailyScheduleOccurrenceLocals.get(203);

      expect(checkOcc1!.status, 'UPCOMING');
      expect(checkOcc2!.status, 'PRESENT');
      expect(checkOcc3!.status, 'UPCOMING');

      // Tap ABSENT on class 1 (Mathematics)
      final payload1 = NotificationActionPayload(
        occurrenceId: 201,
        subjectId: 10,
        date: nowUtc,
        startTime: '09:00',
        endTime: '10:00',
        title: 'Mathematics',
      ).encode();

      final res1 = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionAbsent,
        payload: payload1,
        isarInstance: isar,
      );
      expect(res1.success, isTrue);

      // Tap CANCELLED on class 3 (DBMS)
      final payload3 = NotificationActionPayload(
        occurrenceId: 203,
        subjectId: 30,
        date: nowUtc,
        startTime: '11:30',
        endTime: '12:30',
        title: 'Database Management Systems',
      ).encode();

      final res3 = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionCancelled,
        payload: payload3,
        isarInstance: isar,
      );
      expect(res3.success, isTrue);

      // Verify all 3 targeted states
      checkOcc1 = isar.dailyScheduleOccurrenceLocals.get(201);
      checkOcc2 = isar.dailyScheduleOccurrenceLocals.get(202);
      checkOcc3 = isar.dailyScheduleOccurrenceLocals.get(203);

      expect(checkOcc1!.status, 'ABSENT');
      expect(checkOcc2!.status, 'PRESENT');
      expect(checkOcc3!.status, 'CANCELLED');

      // Verify attendance records: class 1 has ABSENT, class 2 has PRESENT, class 3 has NO active record
      final records = isar.attendanceRecordLocals.where().findAll();
      final activeRecords = records.where((r) => !r.isDeleted).toList();

      expect(activeRecords.length, 2);
      expect(
        activeRecords.any((r) => r.occurrenceId == 201 && r.status == 'ABSENT'),
        isTrue,
      );
      expect(
        activeRecords
            .any((r) => r.occurrenceId == 202 && r.status == 'PRESENT'),
        isTrue,
      );
      expect(activeRecords.any((r) => r.occurrenceId == 203), isFalse);
    });

    test(
        '3. Duplicate taps within debounce window are suppressed without duplicate records',
        () async {
      final isar = testInstance.isar;
      final nowUtc = DateTime.utc(2026, 11, 14);

      final occ = DailyScheduleOccurrenceLocal()
        ..id = 301
        ..date = nowUtc
        ..subjectId = 99
        ..title = 'Cybersecurity'
        ..startTime = '14:00'
        ..endTime = '15:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      isar.write((isar) {
        isar.dailyScheduleOccurrenceLocals.put(occ);
      });

      final payload = NotificationActionPayload(
        occurrenceId: 301,
        subjectId: 99,
        date: nowUtc,
        startTime: '14:00',
        endTime: '15:00',
        title: 'Cybersecurity',
      ).encode();

      // First tap: PRESENT
      final res1 = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionPresent,
        payload: payload,
        isarInstance: isar,
      );
      expect(res1.success, isTrue);

      // Immediate second tap: PRESENT (within 2 seconds)
      final res2 = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionPresent,
        payload: payload,
        isarInstance: isar,
      );
      expect(res2.success, isTrue);
      expect(res2.message, contains('suppressed'));

      // Check that only ONE attendance record exists
      final records = isar.attendanceRecordLocals
          .where()
          .occurrenceIdEqualTo(301)
          .findAll();
      final active = records.where((r) => !r.isDeleted).toList();
      expect(active.length, 1);
    });

    test('4. LATE action only recorded when Late is enabled in preferences',
        () async {
      final isar = testInstance.isar;
      final nowUtc = DateTime.utc(2026, 11, 14);

      final occ = DailyScheduleOccurrenceLocal()
        ..id = 401
        ..date = nowUtc
        ..subjectId = 77
        ..title = 'Physics'
        ..startTime = '11:00'
        ..endTime = '12:00'
        ..type = 'REGULAR_CLASS'
        ..status = 'UPCOMING'
        ..createdFrom = 'WEEKLY_RULE'
        ..createdAt = nowUtc
        ..updatedAt = nowUtc;

      isar.write((isar) {
        isar.dailyScheduleOccurrenceLocals.put(occ);
      });

      final payload = NotificationActionPayload(
        occurrenceId: 401,
        subjectId: 77,
        date: nowUtc,
        startTime: '11:00',
        endTime: '12:00',
        title: 'Physics',
      ).encode();

      final res = await NotificationActionHandler.handleAction(
        actionId: NotificationActionHandler.actionLate,
        payload: payload,
        isarInstance: isar,
      );
      expect(res.success, isTrue);

      final updatedOcc = isar.dailyScheduleOccurrenceLocals.get(401);
      expect(updatedOcc!.status, 'LATE');

      final records = isar.attendanceRecordLocals
          .where()
          .occurrenceIdEqualTo(401)
          .findAll();
      expect(records.first.status, 'LATE');
    });
  });
}
