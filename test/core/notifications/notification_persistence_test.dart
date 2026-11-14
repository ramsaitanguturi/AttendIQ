import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/constants/app_constants.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_scheduler.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/task_enums.dart';
import 'package:attend_iq/features/academic_planner/services/task_notification_scheduler.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/models/academic_event_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/utils/occurrence_identity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

class _LegacyNotificationItem {
  int id = 0;
  late String title;
  late String body;
  late String type;
  late DateTime scheduledTime;
  String? relatedId;
  bool isRead = false;
}

@isarProtected
int _serializeLegacyNotificationItem(
  IsarWriter writer,
  _LegacyNotificationItem object,
) {
  IsarCore.writeString(writer, 1, object.title);
  IsarCore.writeString(writer, 2, object.body);
  IsarCore.writeString(writer, 3, object.type);
  IsarCore.writeLong(
    writer,
    4,
    object.scheduledTime.toUtc().microsecondsSinceEpoch,
  );
  final relatedId = object.relatedId;
  if (relatedId == null) {
    IsarCore.writeNull(writer, 5);
  } else {
    IsarCore.writeString(writer, 5, relatedId);
  }
  IsarCore.writeBool(writer, 6, object.isRead);
  return object.id;
}

@isarProtected
_LegacyNotificationItem _deserializeLegacyNotificationItem(
  IsarReader reader,
) {
  final object = _LegacyNotificationItem();
  object.id = IsarCore.readId(reader);
  object.title = IsarCore.readString(reader, 1) ?? '';
  object.body = IsarCore.readString(reader, 2) ?? '';
  object.type = IsarCore.readString(reader, 3) ?? '';
  final value = IsarCore.readLong(reader, 4);
  if (value == -9223372036854775808) {
    object.scheduledTime =
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
  } else {
    object.scheduledTime =
        DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
  }
  object.relatedId = IsarCore.readString(reader, 5);
  object.isRead = IsarCore.readBool(reader, 6);
  return object;
}

const _legacyNotificationItemSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'NotificationItem',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'title', type: IsarType.string),
      IsarPropertySchema(name: 'body', type: IsarType.string),
      IsarPropertySchema(name: 'type', type: IsarType.string),
      IsarPropertySchema(name: 'scheduledTime', type: IsarType.dateTime),
      IsarPropertySchema(name: 'relatedId', type: IsarType.string),
      IsarPropertySchema(name: 'isRead', type: IsarType.bool),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'type',
        properties: ['type'],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, _LegacyNotificationItem>(
    serialize: _serializeLegacyNotificationItem,
    deserialize: _deserializeLegacyNotificationItem,
  ),
  embeddedSchemas: [],
);

class _MethodChannelSpy {
  static const MethodChannel _channel =
      MethodChannel('dexterous.com/flutter/local_notifications');

  final List<int> scheduledIds = <int>[];
  final List<Map<String, dynamic>> scheduledPayloads = <Map<String, dynamic>>[];
  final List<int> cancelledIds = <int>[];
  int cancelAllCalls = 0;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      switch (call.method) {
        case 'initialize':
          return true;
        case 'requestNotificationsPermission':
          return true;
        case 'createNotificationChannel':
          return null;
        case 'zonedSchedule':
          final args = Map<String, dynamic>.from(call.arguments as Map);
          scheduledIds.add(args['id'] as int);
          scheduledPayloads.add(args);
          return null;
        case 'cancel':
          final args = call.arguments;
          if (args is Map) {
            cancelledIds.add(args['id'] as int);
          } else if (args is int) {
            cancelledIds.add(args);
          }
          return null;
        case 'cancelAll':
          cancelAllCalls++;
          return null;
        default:
          return null;
      }
    });
  }

  void clearRecorded() {
    scheduledIds.clear();
    scheduledPayloads.clear();
    cancelledIds.clear();
    cancelAllCalls = 0;
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}

Future<String?> _resolveIsarNativeLibraryPath() async {
  final packageConfigFile = File('.dart_tool/package_config.json').absolute;
  if (!packageConfigFile.existsSync()) return null;

  final decoded = jsonDecode(await packageConfigFile.readAsString());
  if (decoded is! Map<String, dynamic>) return null;
  final packages = decoded['packages'];
  if (packages is! List<dynamic>) return null;

  String? rawRootUri;
  for (final pkg in packages) {
    if (pkg is Map<String, dynamic> && pkg['name'] == 'isar_flutter_libs') {
      rawRootUri = pkg['rootUri'] as String?;
      break;
    }
  }
  if (rawRootUri == null) return null;

  final rootDir = Directory.fromUri(packageConfigFile.uri.resolve(rawRootUri));
  final String relativePath;
  if (Platform.isWindows) {
    relativePath = 'windows${Platform.pathSeparator}isar.dll';
  } else if (Platform.isLinux) {
    relativePath = 'linux${Platform.pathSeparator}libisar.so';
  } else if (Platform.isMacOS) {
    relativePath = 'macos${Platform.pathSeparator}libisar.dylib';
  } else {
    return null;
  }

  final file = File('${rootDir.path}${Platform.pathSeparator}$relativePath');
  return file.existsSync() ? file.path : null;
}

NotificationItem _buildItem({
  required String title,
  required String body,
  required NotificationType type,
  required DateTime scheduledTime,
  String? relatedId,
  bool isRead = false,
}) {
  return NotificationItem()
    ..title = title
    ..body = body
    ..type = type.toShortString()
    ..scheduledTime = scheduledTime
    ..relatedId = relatedId
    ..isRead = isRead;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? nativeLibPath;
  var dbSequence = 0;

  setUpAll(() async {
    nativeLibPath = await _resolveIsarNativeLibraryPath();
    if (nativeLibPath != null) {
      await Isar.initialize(nativeLibPath);
    }
  });

  Isar openTempIsar(Directory tempDir, {String? customName}) {
    final name = customName ??
        'attendiq_notif_bug009_${DateTime.now().microsecondsSinceEpoch}_${dbSequence++}';
    return Isar.open(
      schemas: appIsarSchemas,
      name: name,
      directory: tempDir.path,
    );
  }

  group('BUG-009: Notification ID collision and real Isar persistence', () {
    test(
        '1. Creating multiple notifications assigns unique autoIncrement DB IDs and unique 32-bit Android IDs without overwriting row 0',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug009_multi_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final db = IsarNotificationDatabaseImpl(isar);
        final baseTime = DateTime.now().add(const Duration(hours: 3));

        final items = List<NotificationItem>.generate(
          5,
          (i) => _buildItem(
            title: 'Reminder ${i + 1}',
            body: 'Body ${i + 1}',
            type: NotificationType.classReminder,
            scheduledTime: baseTime.add(Duration(minutes: i * 15)),
            relatedId: '${100 + i}',
          ),
        );

        for (final item in items) {
          await db.saveNotification(item);
        }

        // Caller objects receive assigned DB IDs and Android IDs immediately.
        final dbIds = items.map((e) => e.id).toList();
        final androidIds = items.map((e) => e.androidNotificationId!).toList();

        expect(dbIds, equals(<int>[1, 2, 3, 4, 5]));
        expect(dbIds.toSet(), hasLength(5));
        expect(androidIds.toSet(), hasLength(5));
        for (var i = 0; i < items.length; i++) {
          expect(items[i].id, greaterThan(0));
          expect(
            NotificationItem.isValidPersistedAndroidId(androidIds[i]),
            isTrue,
          );
          expect(androidIds[i], isNot(equals(items[i].id)));
        }

        // Real Isar count matches all 5 records and row 0 does not exist.
        expect(isar.notificationItems.count(), equals(5));
        expect(isar.notificationItems.get(0), isNull);

        final persisted = await db.getAllNotifications();
        expect(persisted, hasLength(5));
        expect(persisted.map((e) => e.id).toSet(), equals(dbIds.toSet()));
        expect(
          persisted.map((e) => e.androidNotificationId).toSet(),
          equals(androidIds.toSet()),
        );
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '2. Updating an existing notification modifies only the intended record and preserves both DB ID and Android ID',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug009_update_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final db = IsarNotificationDatabaseImpl(isar);
        final baseTime = DateTime.now().add(const Duration(hours: 2));

        final first = _buildItem(
          title: 'First Class',
          body: 'Room 101',
          type: NotificationType.classReminder,
          scheduledTime: baseTime,
          relatedId: '1',
        );
        final second = _buildItem(
          title: 'Second Class',
          body: 'Room 202',
          type: NotificationType.classReminder,
          scheduledTime: baseTime.add(const Duration(hours: 1)),
          relatedId: '2',
        );
        final third = _buildItem(
          title: 'Third Class',
          body: 'Room 303',
          type: NotificationType.classReminder,
          scheduledTime: baseTime.add(const Duration(hours: 2)),
          relatedId: '3',
        );

        await db.saveNotification(first);
        await db.saveNotification(second);
        await db.saveNotification(third);

        final originalSecondId = second.id;
        final originalSecondAndroidId = second.androidNotificationId;

        // Direct mutation update on loaded object.
        second
          ..title = 'Second Class (Room Changed)'
          ..body = 'Room 205'
          ..isRead = true;
        await db.saveNotification(second);

        expect(second.id, equals(originalSecondId));
        expect(second.androidNotificationId, equals(originalSecondAndroidId));
        expect(isar.notificationItems.count(), equals(3));

        // Update via fresh DTO carrying only DB ID preserves existing Android ID.
        final dtoUpdate = NotificationItem()
          ..id = originalSecondId
          ..title = 'Second Class Final'
          ..body = 'Lab B'
          ..type = NotificationType.classReminder.toShortString()
          ..scheduledTime = baseTime.add(const Duration(hours: 1))
          ..relatedId = '2'
          ..isRead = false;
        await db.saveNotification(dtoUpdate);

        expect(dtoUpdate.id, equals(originalSecondId));
        expect(
          dtoUpdate.androidNotificationId,
          equals(originalSecondAndroidId),
        );

        final loadedFirst = await db.getNotificationById(first.id);
        final loadedSecond = await db.getNotificationById(originalSecondId);
        final loadedThird = await db.getNotificationById(third.id);

        expect(loadedFirst?.title, equals('First Class'));
        expect(loadedSecond?.title, equals('Second Class Final'));
        expect(loadedSecond?.body, equals('Lab B'));
        expect(
          loadedSecond?.androidNotificationId,
          equals(originalSecondAndroidId),
        );
        expect(loadedThird?.title, equals('Third Class'));
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '3. Deleting an existing notification removes only the intended record',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug009_delete_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final db = IsarNotificationDatabaseImpl(isar);
        final future = DateTime.now().add(const Duration(hours: 4));

        final a = _buildItem(
          title: 'A',
          body: 'Body A',
          type: NotificationType.classReminder,
          scheduledTime: future,
          relatedId: '10',
        );
        final b = _buildItem(
          title: 'B',
          body: 'Body B',
          type: NotificationType.classReminder,
          scheduledTime: future.add(const Duration(minutes: 30)),
          relatedId: '11',
        );
        final c = _buildItem(
          title: 'C',
          body: 'Body C',
          type: NotificationType.weeklyReport,
          scheduledTime: future.add(const Duration(days: 2)),
        );

        await db.saveNotification(a);
        await db.saveNotification(b);
        await db.saveNotification(c);

        await db.deleteNotification(b.id);

        expect(await db.getNotificationById(b.id), isNull);
        expect((await db.getNotificationById(a.id))?.title, equals('A'));
        expect((await db.getNotificationById(c.id))?.title, equals('C'));
        expect(isar.notificationItems.count(), equals(2));
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '4. NotificationScheduler + LocalNotificationServiceImpl schedule distinct Android IDs and cancel the exact targeted notification',
        () async {
      if (nativeLibPath == null) return;

      final spy = _MethodChannelSpy()..install();
      addTearDown(spy.uninstall);

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug009_cancel_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final now = DateTime.now();
        final class1Start = now.add(const Duration(hours: 3));
        final class2Start = now.add(const Duration(hours: 5));

        String formatHm(DateTime dt) =>
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

        late int event1Id;
        late int event2Id;

        isar.write((db) {
          final semester = SemesterLocal()
            ..id = db.semesterLocals.autoIncrement()
            ..name = 'Spring 2026'
            ..startDate = DateTime.utc(now.year, now.month, now.day)
                .subtract(const Duration(days: 15))
            ..endDate = DateTime.utc(now.year, now.month, now.day)
                .add(const Duration(days: 90))
            ..requiredAttendanceRate = 75.0
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          db.semesterLocals.put(semester);

          final subject = SubjectLocal()
            ..id = db.subjectLocals.autoIncrement()
            ..semesterId = semester.id
            ..name = 'Computer Networks'
            ..code = 'CS402'
            ..credits = 4
            ..attendanceTarget = 75.0
            ..color = '#2563EB'
            ..type = 'THEORY'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          db.subjectLocals.put(subject);

          final rule = WeeklyScheduleRuleLocal()
            ..id = db.weeklyScheduleRuleLocals.autoIncrement()
            ..subjectId = subject.id
            ..dayOfWeek = class1Start.weekday
            ..startTime = formatHm(class1Start)
            ..endTime = formatHm(class1Start.add(const Duration(hours: 1)))
            ..room = 'Room 501'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          db.weeklyScheduleRuleLocals.put(rule);

          final e1 = DailyScheduleOccurrenceLocal()
            ..id = db.dailyScheduleOccurrenceLocals.autoIncrement()
            ..subjectId = subject.id
            ..ruleId = rule.id
            ..date = DateTime.utc(
              class1Start.year,
              class1Start.month,
              class1Start.day,
            )
            ..title = subject.name
            ..startTime = formatHm(class1Start)
            ..endTime = formatHm(class1Start.add(const Duration(hours: 1)))
            ..type = 'REGULAR_CLASS'
            ..status = 'UPCOMING'
            ..createdFrom = 'WEEKLY_RULE'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          e1.slotKey = computeSlotKeyForLocal(e1);
          db.dailyScheduleOccurrenceLocals.put(e1);
          event1Id = e1.id;

          final e2 = DailyScheduleOccurrenceLocal()
            ..id = db.dailyScheduleOccurrenceLocals.autoIncrement()
            ..subjectId = subject.id
            ..date = DateTime.utc(
              class2Start.year,
              class2Start.month,
              class2Start.day,
            )
            ..title = subject.name
            ..startTime = formatHm(class2Start)
            ..endTime = formatHm(class2Start.add(const Duration(hours: 1)))
            ..type = 'REGULAR_CLASS'
            ..status = 'UPCOMING'
            ..createdFrom = 'WEEKLY_RULE'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          e2.slotKey = computeSlotKeyForLocal(e2);
          db.dailyScheduleOccurrenceLocals.put(e2);
          event2Id = e2.id;
        });

        final db = IsarNotificationDatabaseImpl(isar);
        final service = LocalNotificationServiceImpl();
        await service.initialize();
        final scheduler = NotificationScheduler(db, service);

        await scheduler
            .rescheduleAll(reminderOffsets: const [15], customNow: now);

        final allNotifs = await db.getAllNotifications();
        expect(allNotifs, hasLength(3)); // 2 class reminders + 1 weekly report
        expect(allNotifs.map((n) => n.id).toSet(), hasLength(3));
        expect(
          allNotifs.map((n) => n.androidNotificationId).toSet(),
          hasLength(3),
        );
        expect(spy.scheduledIds, hasLength(3));
        expect(spy.scheduledIds.toSet(), hasLength(3));

        final occ1 = isar.dailyScheduleOccurrenceLocals.get(event1Id)!;
        final occ2 = isar.dailyScheduleOccurrenceLocals.get(event2Id)!;
        final key1 = NotificationRelatedKeys.forSlotKey(occ1.slotKey!);
        final key2 = NotificationRelatedKeys.forSlotKey(occ2.slotKey!);

        final event1Item = allNotifs.firstWhere((n) => n.relatedId == key1);
        final event2Item = allNotifs.firstWhere((n) => n.relatedId == key2);

        // Cancel occ1 in Isar and re-run rolling window.
        spy.clearRecorded();
        isar.write((dbWrite) {
          final e1 = dbWrite.dailyScheduleOccurrenceLocals.get(event1Id)!;
          e1.status = 'CANCELLED';
          dbWrite.dailyScheduleOccurrenceLocals.put(e1);
        });

        await scheduler.rescheduleRollingWindow(
          offsets: const [15],
          customNow: now,
        );

        expect(
          spy.cancelledIds,
          equals(<int>[event1Item.effectiveAndroidNotificationId]),
        );
        expect(spy.scheduledIds, isEmpty);
        expect(await db.getNotificationById(event1Item.id), isNull);
        expect(await db.getNotificationById(event2Item.id), isNotNull);
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '5. Persisted DB IDs, Android notification IDs, and duplicate suppression survive Isar close and reopen',
        () async {
      if (nativeLibPath == null) return;

      final spy = _MethodChannelSpy()..install();
      addTearDown(spy.uninstall);

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug009_reopen_');
      final dbName = 'attendiq_reopen_${DateTime.now().microsecondsSinceEpoch}';
      Isar? isar;
      try {
        final now = DateTime.now();
        final classStart = now.add(const Duration(hours: 4));
        final startHm =
            '${classStart.hour.toString().padLeft(2, '0')}:${classStart.minute.toString().padLeft(2, '0')}';
        final endHm =
            '${classStart.add(const Duration(hours: 1)).hour.toString().padLeft(2, '0')}:${classStart.add(const Duration(hours: 1)).minute.toString().padLeft(2, '0')}';

        isar = openTempIsar(tempDir, customName: dbName);
        late int eventId;
        isar.write((dbWrite) {
          final sem = SemesterLocal()
            ..id = dbWrite.semesterLocals.autoIncrement()
            ..name = 'Fall 2026'
            ..startDate = DateTime.utc(now.year, now.month, now.day)
                .subtract(const Duration(days: 10))
            ..endDate = DateTime.utc(now.year, now.month, now.day)
                .add(const Duration(days: 90))
            ..requiredAttendanceRate = 75.0
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          dbWrite.semesterLocals.put(sem);

          final sub = SubjectLocal()
            ..id = dbWrite.subjectLocals.autoIncrement()
            ..semesterId = sem.id
            ..name = 'Distributed Systems'
            ..code = 'CS501'
            ..credits = 4
            ..attendanceTarget = 75.0
            ..color = '#10B981'
            ..type = 'THEORY'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          dbWrite.subjectLocals.put(sub);

          final occ = DailyScheduleOccurrenceLocal()
            ..id = dbWrite.dailyScheduleOccurrenceLocals.autoIncrement()
            ..subjectId = sub.id
            ..date = DateTime.utc(
              classStart.year,
              classStart.month,
              classStart.day,
            )
            ..title = sub.name
            ..startTime = startHm
            ..endTime = endHm
            ..type = 'REGULAR_CLASS'
            ..status = 'UPCOMING'
            ..createdFrom = 'WEEKLY_RULE'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          occ.slotKey = computeSlotKeyForLocal(occ);
          dbWrite.dailyScheduleOccurrenceLocals.put(occ);
          eventId = occ.id;
        });

        final service = LocalNotificationServiceImpl();
        await service.initialize();

        final dbBeforeRestart = IsarNotificationDatabaseImpl(isar);
        final schedulerBefore = NotificationScheduler(dbBeforeRestart, service);
        await schedulerBefore.rescheduleRollingWindow(
          offsets: const [15, 30],
          customNow: now,
        );

        final savedBefore = await dbBeforeRestart.getAllNotifications();
        expect(savedBefore, hasLength(2));
        final savedIdsBefore = savedBefore.map((n) => n.id).toList()..sort();
        final savedAndroidIdsBefore =
            savedBefore.map((n) => n.androidNotificationId!).toList()..sort();

        // Simulate application restart: close and reopen Isar from disk.
        isar.close();
        isar = openTempIsar(tempDir, customName: dbName);
        spy.clearRecorded();

        final dbAfterRestart = IsarNotificationDatabaseImpl(isar);
        final loadedAfter = await dbAfterRestart.getAllNotifications();
        expect(loadedAfter, hasLength(2));
        expect(
          loadedAfter.map((n) => n.id).toList()..sort(),
          equals(savedIdsBefore),
        );
        expect(
          loadedAfter.map((n) => n.androidNotificationId!).toList()..sort(),
          equals(savedAndroidIdsBefore),
        );

        // Saving a brand-new item post-restart must continue autoIncrement cleanly.
        final postRestartItem = _buildItem(
          title: 'Post Restart',
          body: 'Alert',
          type: NotificationType.attendanceWarning,
          scheduledTime: now.add(const Duration(minutes: 5)),
          relatedId: '1',
        );
        await dbAfterRestart.saveNotification(postRestartItem);
        expect(postRestartItem.id, equals(savedIdsBefore.last + 1));
        expect(
          savedAndroidIdsBefore,
          isNot(contains(postRestartItem.androidNotificationId)),
        );

        // Re-running rolling window post-restart must NOT duplicate-schedule existing reminders.
        final schedulerAfter = NotificationScheduler(dbAfterRestart, service);
        await schedulerAfter.rescheduleRollingWindow(
          offsets: const [15, 30],
          customNow: now,
        );
        expect(spy.scheduledIds, isEmpty);
        expect(spy.cancelledIds, isEmpty);

        // Cancelling the occurrence post-restart cancels both persisted Android IDs.
        isar.write((dbWrite) {
          final occ = dbWrite.dailyScheduleOccurrenceLocals.get(eventId)!;
          occ.status = 'CANCELLED';
          dbWrite.dailyScheduleOccurrenceLocals.put(occ);
        });
        await schedulerAfter.rescheduleRollingWindow(
          offsets: const [15, 30],
          customNow: now,
        );
        expect(
          spy.cancelledIds.toSet(),
          equals(savedAndroidIdsBefore.toSet()),
        );
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '6. Migrates legacy pre-BUG-009 on-disk Isar schema (including id == 0 and null androidNotificationId) cleanly via isarProvider',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug009_migrate_');
      Isar? isar;
      try {
        final future1 = DateTime.now().add(const Duration(hours: 6));
        final future2 = DateTime.now().add(const Duration(hours: 8));

        // 1. Seed a legacy Isar DB using the original 7-property schema (no androidNotificationId).
        final legacyIsar = Isar.open(
          schemas: <IsarGeneratedSchema>[_legacyNotificationItemSchema],
          name: AppConstants.isarDbName,
          directory: tempDir.path,
        );
        legacyIsar.write((db) {
          final legacyZero = _LegacyNotificationItem()
            ..id = 0
            ..title = 'Legacy Zero Record'
            ..body = 'Overwritten pre-fix slot'
            ..type = NotificationType.classReminder.toShortString()
            ..scheduledTime = future1
            ..relatedId = '77'
            ..isRead = false;

          final legacyRestored = _LegacyNotificationItem()
            ..id = 4
            ..title = 'Legacy Restored Record'
            ..body = 'Imported before fix'
            ..type = NotificationType.lowAttendanceAlert.toShortString()
            ..scheduledTime = future2
            ..relatedId = '9'
            ..isRead = true;

          db.collection<int, _LegacyNotificationItem>().putAll(
            <_LegacyNotificationItem>[legacyZero, legacyRestored],
          );
        });
        legacyIsar.close();

        // 2. Reopen the same on-disk DB through isarProvider with updated schema + startup migration.
        final container = ProviderContainer(
          overrides: [
            databaseDirectoryResolverProvider.overrideWithValue(
              () async => tempDir.path,
            ),
          ],
        );
        addTearDown(container.dispose);

        final migratedIsar = await container.read(isarProvider.future);
        isar = migratedIsar;
        expect(migratedIsar.isOpen, isTrue);

        // Row 0 must be migrated to a positive ID (> 4) and row 0 removed.
        expect(migratedIsar.notificationItems.get(0), isNull);
        final allMigrated = migratedIsar.notificationItems.where().findAll();
        expect(allMigrated, hasLength(2));

        final migratedRestored =
            allMigrated.firstWhere((n) => n.title == 'Legacy Restored Record');
        final migratedZero =
            allMigrated.firstWhere((n) => n.title == 'Legacy Zero Record');

        expect(migratedRestored.id, equals(4));
        expect(migratedRestored.relatedId, equals('9'));
        expect(migratedRestored.isRead, isTrue);

        expect(migratedZero.id, greaterThan(4));
        expect(migratedZero.relatedId, equals('77'));
        expect(migratedZero.isRead, isFalse);

        expect(
          NotificationItem.isValidPersistedAndroidId(
            migratedRestored.androidNotificationId!,
          ),
          isTrue,
        );
        expect(
          NotificationItem.isValidPersistedAndroidId(
            migratedZero.androidNotificationId!,
          ),
          isTrue,
        );
        expect(
          migratedRestored.androidNotificationId,
          isNot(equals(migratedZero.androidNotificationId)),
        );

        // Migration must be idempotent when invoked again.
        final secondPass = await migrateLegacyNotificationItems(migratedIsar);
        expect(secondPass.didMigrate, isFalse);

        // Subsequent saves must increment beyond migrated IDs without collision.
        final db = IsarNotificationDatabaseImpl(migratedIsar);
        final nextItem = _buildItem(
          title: 'Post Migration',
          body: 'Fresh notification',
          type: NotificationType.classReminder,
          scheduledTime: future2.add(const Duration(hours: 1)),
          relatedId: '88',
        );
        await db.saveNotification(nextItem);
        expect(nextItem.id, equals(migratedZero.id + 1));
        expect(
          nextItem.androidNotificationId,
          isNot(equals(migratedZero.androidNotificationId)),
        );
        expect(
          nextItem.androidNotificationId,
          isNot(equals(migratedRestored.androidNotificationId)),
        );
      } finally {
        if (isar != null && isar.isOpen) {
          isar.close();
        }
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '7. Deduplicates colliding legacy androidNotificationIds and prevents integer overflow or task-ID collisions',
        () async {
      if (nativeLibPath == null) return;

      final spy = _MethodChannelSpy()..install();
      addTearDown(spy.uninstall);

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug009_overflow_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final future = DateTime.now().add(const Duration(hours: 3));

        // Seed colliding/invalid androidNotificationId rows + a DB row at id = 800001
        // (same numeric value as TaskNotificationScheduler taskId = 1!).
        isar.write((dbWrite) {
          final rowA = _buildItem(
            title: 'Row A',
            body: 'Body A',
            type: NotificationType.classReminder,
            scheduledTime: future,
          )
            ..id = 1
            ..androidNotificationId = 100000050;
          final rowB = _buildItem(
            title: 'Row B',
            body: 'Body B',
            type: NotificationType.classReminder,
            scheduledTime: future.add(const Duration(minutes: 10)),
          )
            ..id = 2
            ..androidNotificationId = 100000050; // duplicate!
          final rowTaskIdOverlap = _buildItem(
            title: 'High DB ID Row',
            body: 'Collides with 800001 if DB ID == Android ID',
            type: NotificationType.classReminder,
            scheduledTime: future.add(const Duration(minutes: 20)),
          )
            ..id = 800001
            ..androidNotificationId = 800001; // invalid task-range ID!
          final rowOverflow = _buildItem(
            title: 'Overflow DB ID Row',
            body: '64-bit ID > INT32_MAX',
            type: NotificationType.weeklyReport,
            scheduledTime: future.add(const Duration(minutes: 30)),
          )
            ..id = 5000000000
            ..androidNotificationId = 5000000000; // 64-bit overflow!

          dbWrite.notificationItems.putAll(
            <NotificationItem>[rowA, rowB, rowTaskIdOverlap, rowOverflow],
          );
        });

        final db = IsarNotificationDatabaseImpl(isar);
        final migratedAll = await db.getAllNotifications();
        expect(migratedAll, hasLength(4));

        final androidIds =
            migratedAll.map((n) => n.androidNotificationId!).toList();
        expect(androidIds.toSet(), hasLength(4));
        for (final androidId in androidIds) {
          expect(
            NotificationItem.isValidPersistedAndroidId(androidId),
            isTrue,
          );
          expect(
            NotificationItem.isValidAndroidInt32(androidId),
            isTrue,
          );
        }

        // Schedule both persisted DB notifications and a TaskNotificationScheduler task(1) (ID 800001).
        final service = LocalNotificationServiceImpl();
        await service.initialize();
        for (final item in migratedAll) {
          await service.scheduleNotification(item);
        }

        final taskScheduler = TaskNotificationScheduler(service);
        await taskScheduler.scheduleTaskNotification(
          AcademicTask(
            id: 1,
            title: 'Assignment 1',
            taskType: TaskType.assignment,
            startDate: DateTime.now(),
            dueDate: DateTime.now().add(const Duration(days: 2)),
            priority: TaskPriority.high,
            status: TaskStatus.pending,
            reminder: TaskReminder.hours1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Task 1 uses 800001, completely disjoint from all 4 persisted notifications.
        expect(spy.scheduledIds, hasLength(5));
        expect(spy.scheduledIds.toSet(), hasLength(5));
        expect(spy.scheduledIds, contains(800001));

        // Direct overflow guards on NotificationItem helpers and cancelNotification.
        expect(
          NotificationItem.isValidAndroidInt32(
            NotificationItem.deriveAndroidNotificationId(-0x8000000000000000),
          ),
          isTrue,
        );
        expect(
          NotificationItem.isValidAndroidInt32(
            NotificationItem.deriveAndroidNotificationId(0x7FFFFFFFFFFFFFFF),
          ),
          isTrue,
        );
        await service.cancelNotification(5000000000);
        expect(
          NotificationItem.isValidAndroidInt32(spy.cancelledIds.last),
          isTrue,
        );
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '8. Multiple critical subjects and weekly report persist independently without wiping risk alert deduplication',
        () async {
      if (nativeLibPath == null) return;

      final spy = _MethodChannelSpy()..install();
      addTearDown(spy.uninstall);

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug009_risk_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final now = DateTime.now();

        isar.write((dbWrite) {
          final sem = SemesterLocal()
            ..id = dbWrite.semesterLocals.autoIncrement()
            ..name = 'Fall 2026'
            ..startDate = DateTime.utc(now.year, now.month, now.day)
                .subtract(const Duration(days: 20))
            ..endDate = DateTime.utc(now.year, now.month, now.day)
                .add(const Duration(days: 90))
            ..requiredAttendanceRate = 75.0
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          dbWrite.semesterLocals.put(sem);

          final sub1 = SubjectLocal()
            ..id = dbWrite.subjectLocals.autoIncrement()
            ..semesterId = sem.id
            ..name = 'Physics'
            ..code = 'PHY101'
            ..credits = 3
            ..attendanceTarget = 75.0
            ..color = '#EF4444'
            ..type = 'THEORY'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          final sub2 = SubjectLocal()
            ..id = dbWrite.subjectLocals.autoIncrement()
            ..semesterId = sem.id
            ..name = 'Calculus'
            ..code = 'MTH101'
            ..credits = 4
            ..attendanceTarget = 75.0
            ..color = '#F59E0B'
            ..type = 'THEORY'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          dbWrite.subjectLocals.putAll(<SubjectLocal>[sub1, sub2]);

          // Both subjects at 0% attendance (CRITICAL).
          dbWrite.attendanceRecordLocals.putAll(<AttendanceRecordLocal>[
            AttendanceRecordLocal()
              ..id = dbWrite.attendanceRecordLocals.autoIncrement()
              ..eventId = 1
              ..subjectId = sub1.id
              ..status = 'ABSENT'
              ..markedAt = now.subtract(const Duration(hours: 2))
              ..createdAt = now.toUtc()
              ..updatedAt = now.toUtc(),
            AttendanceRecordLocal()
              ..id = dbWrite.attendanceRecordLocals.autoIncrement()
              ..eventId = 2
              ..subjectId = sub2.id
              ..status = 'ABSENT'
              ..markedAt = now.subtract(const Duration(hours: 1))
              ..createdAt = now.toUtc()
              ..updatedAt = now.toUtc(),
          ]);

          // Also an academic event 3 days out.
          final eventDate = now.add(const Duration(days: 3));
          dbWrite.academicEventLocals.put(
            AcademicEventLocal()
              ..id = dbWrite.academicEventLocals.autoIncrement()
              ..title = 'Algorithms Quiz'
              ..date =
                  DateTime.utc(eventDate.year, eventDate.month, eventDate.day)
              ..startTime = '11:00'
              ..endTime = '12:00'
              ..type = 'EXAM'
              ..createdAt = now.toUtc()
              ..updatedAt = now.toUtc(),
          );
        });

        final db = IsarNotificationDatabaseImpl(isar);
        final service = LocalNotificationServiceImpl();
        await service.initialize();
        final scheduler = NotificationScheduler(db, service);
        final schedulerNow = now.add(const Duration(seconds: 30));

        await scheduler.rescheduleAll(
          reminderOffsets: const [15],
          customNow: schedulerNow,
        );

        // 2 academic event reminders + 2 risk alerts + 1 weekly report = 5 distinct records!
        final afterFirstRun = await db.getAllNotifications();
        expect(afterFirstRun, hasLength(5));
        expect(afterFirstRun.map((n) => n.id).toSet(), hasLength(5));
        expect(
          afterFirstRun.map((n) => n.androidNotificationId).toSet(),
          hasLength(5),
        );
        expect(spy.scheduledIds, hasLength(5));
        expect(spy.scheduledIds.toSet(), hasLength(5));

        // Second run must not duplicate either risk alert or class/exam reminders.
        spy.clearRecorded();
        await scheduler.rescheduleAll(
          reminderOffsets: const [15],
          customNow: schedulerNow,
        );

        final afterSecondRun = await db.getAllNotifications();
        expect(afterSecondRun, hasLength(5));
        // Only the weekly report is replaced during rescheduleAll.
        expect(spy.scheduledIds, hasLength(1));
        expect(spy.cancelledIds, hasLength(1));
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '9. Rescheduling after room/template change updates the existing notification record in place with same DB & Android ID',
        () async {
      if (nativeLibPath == null) return;

      final spy = _MethodChannelSpy()..install();
      addTearDown(spy.uninstall);

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug009_room_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final now = DateTime.now();
        final classStart = now.add(const Duration(hours: 4));
        final startHm =
            '${classStart.hour.toString().padLeft(2, '0')}:${classStart.minute.toString().padLeft(2, '0')}';
        final endHm =
            '${classStart.add(const Duration(hours: 1)).hour.toString().padLeft(2, '0')}:${classStart.add(const Duration(hours: 1)).minute.toString().padLeft(2, '0')}';

        late int subjectId;
        isar.write((dbWrite) {
          final sub = SubjectLocal()
            ..id = dbWrite.subjectLocals.autoIncrement()
            ..semesterId = 1
            ..name = 'Compilers'
            ..code = 'CS410'
            ..credits = 4
            ..attendanceTarget = 75.0
            ..color = '#2563EB'
            ..type = 'THEORY'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          dbWrite.subjectLocals.put(sub);
          subjectId = sub.id;

          final occ = DailyScheduleOccurrenceLocal()
            ..id = dbWrite.dailyScheduleOccurrenceLocals.autoIncrement()
            ..subjectId = subjectId
            ..date = DateTime.utc(
              classStart.year,
              classStart.month,
              classStart.day,
            )
            ..title = sub.name
            ..startTime = startHm
            ..endTime = endHm
            ..type = 'REGULAR_CLASS'
            ..status = 'UPCOMING'
            ..createdFrom = 'WEEKLY_RULE'
            ..createdAt = now.toUtc()
            ..updatedAt = now.toUtc();
          occ.slotKey = computeSlotKeyForLocal(occ);
          dbWrite.dailyScheduleOccurrenceLocals.put(occ);
        });

        final db = IsarNotificationDatabaseImpl(isar);
        final service = LocalNotificationServiceImpl();
        await service.initialize();
        final scheduler = NotificationScheduler(db, service);

        await scheduler.rescheduleRollingWindow(
          offsets: const [15],
          customNow: now,
        );
        final initial = (await db.getAllNotifications()).single;
        expect(initial.body, isNot(contains('Hall B')));

        // Add room info via WeeklyScheduleRuleLocal and reschedule.
        spy.clearRecorded();
        isar.write((dbWrite) {
          dbWrite.weeklyScheduleRuleLocals.put(
            WeeklyScheduleRuleLocal()
              ..id = dbWrite.weeklyScheduleRuleLocals.autoIncrement()
              ..subjectId = subjectId
              ..dayOfWeek = classStart.weekday
              ..startTime = startHm
              ..endTime = endHm
              ..room = 'Hall B'
              ..createdAt = now.toUtc()
              ..updatedAt = now.toUtc(),
          );
        });

        await scheduler.rescheduleRollingWindow(
          offsets: const [15],
          customNow: now,
        );

        final updatedList = await db.getAllNotifications();
        expect(updatedList, hasLength(1));
        final updated = updatedList.single;
        expect(updated.id, equals(initial.id));
        expect(
          updated.androidNotificationId,
          equals(initial.androidNotificationId),
        );
        expect(updated.body, contains('Hall B'));
        expect(spy.cancelledIds, isEmpty);
        expect(spy.scheduledIds, equals(<int>[initial.androidNotificationId!]));
        expect(spy.scheduledPayloads.single['body'], contains('Hall B'));
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });
}
