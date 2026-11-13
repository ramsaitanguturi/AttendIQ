import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/ai/context/ai_context_builder.dart';
import 'package:attend_iq/core/analytics/services/analytics_service.dart';
import 'package:attend_iq/core/backup/backup_exporter.dart';
import 'package:attend_iq/core/backup/backup_importer.dart';
import 'package:attend_iq/core/constants/app_constants.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/event_generator/data/models/event_local.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/core/notifications/providers/notification_providers.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_scheduler.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/core/reports/services/report_service.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:attend_iq/features/attendance/presentation/controllers/subject_attendance_stats_provider.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/models/academic_event_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/schedule_exception_local.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/utils/occurrence_identity.dart';
import 'package:attend_iq/features/timetable/domain/entities/academic_event.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/repositories/daily_schedule_occurrence_repository.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/timetable_controller.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/today_schedule_provider.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart';
import 'package:attend_iq/features/widgets/data/widget_data_service.dart';
import 'package:attend_iq/features/widgets/services/widget_refresh_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

class _SpyNotificationService implements NotificationService {
  final List<NotificationItem> scheduled = <NotificationItem>[];
  final List<int> cancelled = <int>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleNotification(NotificationItem item) async {
    scheduled.add(item);
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    scheduled.clear();
  }
}

class _NoOpWidgetRefreshService extends Fake implements WidgetRefreshService {
  @override
  Future<void> refreshAllWidgets() async {}
}

// Pre-BUG-004 legacy WeeklyScheduleRuleLocal schema (without legacyTemplateId)
class _PreBug004RuleLocal {
  int id = 0;
  String? serverId;
  late int subjectId;
  late int dayOfWeek;
  late String startTime;
  late String endTime;
  String? room;
  String? faculty;
  String type = 'THEORY';
  bool isActive = true;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}

@isarProtected
int _serializePreRule(IsarWriter writer, _PreBug004RuleLocal object) {
  _writeNullableString(writer, 1, object.serverId);
  IsarCore.writeLong(writer, 2, object.subjectId);
  IsarCore.writeLong(writer, 3, object.dayOfWeek);
  IsarCore.writeString(writer, 4, object.startTime);
  IsarCore.writeString(writer, 5, object.endTime);
  _writeNullableString(writer, 6, object.room);
  _writeNullableString(writer, 7, object.faculty);
  IsarCore.writeString(writer, 8, object.type);
  IsarCore.writeBool(writer, 9, object.isActive);
  IsarCore.writeLong(
      writer, 10, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 11, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 12, object.isDirty);
  IsarCore.writeBool(writer, 13, object.isDeleted);
  return object.id;
}

@isarProtected
_PreBug004RuleLocal _deserializePreRule(IsarReader reader) =>
    _PreBug004RuleLocal()..id = IsarCore.readId(reader);

const _preBug004RuleSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'WeeklyScheduleRuleLocal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'serverId', type: IsarType.string),
      IsarPropertySchema(name: 'subjectId', type: IsarType.long),
      IsarPropertySchema(name: 'dayOfWeek', type: IsarType.long),
      IsarPropertySchema(name: 'startTime', type: IsarType.string),
      IsarPropertySchema(name: 'endTime', type: IsarType.string),
      IsarPropertySchema(name: 'room', type: IsarType.string),
      IsarPropertySchema(name: 'faculty', type: IsarType.string),
      IsarPropertySchema(name: 'type', type: IsarType.string),
      IsarPropertySchema(name: 'isActive', type: IsarType.bool),
      IsarPropertySchema(name: 'createdAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'updatedAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'isDirty', type: IsarType.bool),
      IsarPropertySchema(name: 'isDeleted', type: IsarType.bool),
    ],
    indexes: [
      IsarIndexSchema(
          name: 'serverId',
          properties: ['serverId'],
          unique: true,
          hash: false),
      IsarIndexSchema(
          name: 'subjectId',
          properties: ['subjectId'],
          unique: false,
          hash: false),
      IsarIndexSchema(
          name: 'dayOfWeek',
          properties: ['dayOfWeek'],
          unique: false,
          hash: false),
    ],
  ),
  converter: IsarObjectConverter<int, _PreBug004RuleLocal>(
    serialize: _serializePreRule,
    deserialize: _deserializePreRule,
  ),
  embeddedSchemas: [],
);

// Pre-BUG-004 legacy DailyScheduleOccurrenceLocal (without ruleId/legacyEventId/slotKey)
class _PreBug004OccLocal {
  int id = 0;
  String? serverId;
  late DateTime date;
  int? subjectId;
  late String title;
  late String startTime;
  late String endTime;
  late String type;
  late String status;
  late String createdFrom;
  String? room;
  String? faculty;
  String? reason;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}

@isarProtected
int _serializePreOcc(IsarWriter writer, _PreBug004OccLocal object) {
  _writeNullableString(writer, 1, object.serverId);
  IsarCore.writeLong(writer, 2, object.date.toUtc().microsecondsSinceEpoch);
  if (object.subjectId == null) {
    IsarCore.writeNull(writer, 3);
  } else {
    IsarCore.writeLong(writer, 3, object.subjectId!);
  }
  IsarCore.writeString(writer, 4, object.title);
  IsarCore.writeString(writer, 5, object.startTime);
  IsarCore.writeString(writer, 6, object.endTime);
  IsarCore.writeString(writer, 7, object.type);
  IsarCore.writeString(writer, 8, object.status);
  IsarCore.writeString(writer, 9, object.createdFrom);
  _writeNullableString(writer, 10, object.room);
  _writeNullableString(writer, 11, object.faculty);
  _writeNullableString(writer, 12, object.reason);
  IsarCore.writeLong(
      writer, 13, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 14, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 15, object.isDirty);
  IsarCore.writeBool(writer, 16, object.isDeleted);
  return object.id;
}

@isarProtected
_PreBug004OccLocal _deserializePreOcc(IsarReader reader) =>
    _PreBug004OccLocal()..id = IsarCore.readId(reader);

const _preBug004OccSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DailyScheduleOccurrenceLocal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'serverId', type: IsarType.string),
      IsarPropertySchema(name: 'date', type: IsarType.dateTime),
      IsarPropertySchema(name: 'subjectId', type: IsarType.long),
      IsarPropertySchema(name: 'title', type: IsarType.string),
      IsarPropertySchema(name: 'startTime', type: IsarType.string),
      IsarPropertySchema(name: 'endTime', type: IsarType.string),
      IsarPropertySchema(name: 'type', type: IsarType.string),
      IsarPropertySchema(name: 'status', type: IsarType.string),
      IsarPropertySchema(name: 'createdFrom', type: IsarType.string),
      IsarPropertySchema(name: 'room', type: IsarType.string),
      IsarPropertySchema(name: 'faculty', type: IsarType.string),
      IsarPropertySchema(name: 'reason', type: IsarType.string),
      IsarPropertySchema(name: 'createdAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'updatedAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'isDirty', type: IsarType.bool),
      IsarPropertySchema(name: 'isDeleted', type: IsarType.bool),
    ],
    indexes: [
      IsarIndexSchema(
          name: 'serverId',
          properties: ['serverId'],
          unique: true,
          hash: false),
      IsarIndexSchema(
          name: 'date', properties: ['date'], unique: false, hash: false),
      IsarIndexSchema(
          name: 'subjectId',
          properties: ['subjectId'],
          unique: false,
          hash: false),
    ],
  ),
  converter: IsarObjectConverter<int, _PreBug004OccLocal>(
    serialize: _serializePreOcc,
    deserialize: _deserializePreOcc,
  ),
  embeddedSchemas: [],
);

// Pre-BUG-004 AttendanceRecordLocal (without occurrenceId/legacyEventId)
class _PreBug004AttLocal {
  int id = 0;
  String? serverId;
  late int eventId;
  late int subjectId;
  late String status;
  late DateTime markedAt;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}

@isarProtected
int _serializePreAtt(IsarWriter writer, _PreBug004AttLocal object) {
  _writeNullableString(writer, 1, object.serverId);
  IsarCore.writeLong(writer, 2, object.eventId);
  IsarCore.writeLong(writer, 3, object.subjectId);
  IsarCore.writeString(writer, 4, object.status);
  IsarCore.writeLong(writer, 5, object.markedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 6, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 7, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 8, object.isDirty);
  IsarCore.writeBool(writer, 9, object.isDeleted);
  return object.id;
}

@isarProtected
_PreBug004AttLocal _deserializePreAtt(IsarReader reader) =>
    _PreBug004AttLocal()..id = IsarCore.readId(reader);

const _preBug004AttSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'AttendanceRecordLocal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'serverId', type: IsarType.string),
      IsarPropertySchema(name: 'eventId', type: IsarType.long),
      IsarPropertySchema(name: 'subjectId', type: IsarType.long),
      IsarPropertySchema(name: 'status', type: IsarType.string),
      IsarPropertySchema(name: 'markedAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'createdAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'updatedAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'isDirty', type: IsarType.bool),
      IsarPropertySchema(name: 'isDeleted', type: IsarType.bool),
    ],
    indexes: [
      IsarIndexSchema(
          name: 'serverId',
          properties: ['serverId'],
          unique: true,
          hash: false),
      IsarIndexSchema(
          name: 'eventId', properties: ['eventId'], unique: false, hash: false),
      IsarIndexSchema(
          name: 'subjectId',
          properties: ['subjectId'],
          unique: false,
          hash: false),
    ],
  ),
  converter: IsarObjectConverter<int, _PreBug004AttLocal>(
    serialize: _serializePreAtt,
    deserialize: _deserializePreAtt,
  ),
  embeddedSchemas: [],
);

void _writeNullableString(IsarWriter writer, int propertyId, String? value) {
  if (value == null) {
    IsarCore.writeNull(writer, propertyId);
  } else {
    IsarCore.writeString(writer, propertyId, value);
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
        'attendiq_bug004_${DateTime.now().microsecondsSinceEpoch}_${dbSequence++}';
    return Isar.open(
      schemas: appIsarSchemas,
      name: name,
      directory: tempDir.path,
    );
  }

  ProviderContainer createAppContainer(
    Directory tempDir, {
    required String dbName,
    NotificationService? notificationService,
  }) {
    final spyNotif = notificationService ?? _SpyNotificationService();
    return ProviderContainer(
      overrides: [
        databaseDirectoryResolverProvider
            .overrideWithValue(() async => tempDir.path),
        databaseInitTimeoutProvider
            .overrideWithValue(const Duration(seconds: 30)),
        isarOpenerProvider.overrideWithValue(({
          required schemas,
          required name,
          required directory,
        }) {
          return defaultIsarOpener(
            schemas: schemas,
            name: dbName,
            directory: directory,
          );
        }),
        notificationServiceProvider.overrideWithValue(spyNotif),
        widgetRefreshServiceProvider
            .overrideWithValue(_NoOpWidgetRefreshService()),
      ],
    );
  }

  group(
      'BUG-004: Canonical Timetable, Occurrence Identity & Consumer Unification',
      () {
    test(
        '1. End-to-end canonical flow: Weekly rules, daily occurrences (multi-slot same day), extra classes, exceptions, attendance history, stats, analytics, reports, AI context, and notifications',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug004_e2e_');
      final dbName = 'bug004_e2e_${DateTime.now().microsecondsSinceEpoch}';
      final spyNotif = _SpyNotificationService();
      final container = createAppContainer(
        tempDir,
        dbName: dbName,
        notificationService: spyNotif,
      );
      final isar = await container.read(isarProvider.future);
      addTearDown(() async {
        container.dispose();
        if (isar.isOpen) {
          await isar.close();
        }
        if (tempDir.existsSync()) {
          try {
            await tempDir.delete(recursive: true);
          } catch (_) {}
        }
      });
      final now = DateTime.now();
      final todayUtc = DateTime.utc(now.year, now.month, now.day);
      final tomorrow = now.add(const Duration(days: 1));

      late int semId;
      late int subCsId;
      late int subLabId;

      isar.write((db) {
        final sem = SemesterLocal()
          ..id = db.semesterLocals.autoIncrement()
          ..serverId = 'sem_e2e'
          ..name = 'Fall 2026'
          ..startDate = todayUtc.subtract(const Duration(days: 14))
          ..endDate = todayUtc.add(const Duration(days: 60))
          ..requiredAttendanceRate = 75.0
          ..status = SemesterLocal.statusActive
          ..isActive = true
          ..createdAt = now.toUtc()
          ..updatedAt = now.toUtc();
        db.semesterLocals.put(sem);
        semId = sem.id;

        final sub1 = SubjectLocal()
          ..id = db.subjectLocals.autoIncrement()
          ..serverId = 'sub_cs'
          ..semesterId = semId
          ..name = 'Algorithms'
          ..code = 'CS301'
          ..credits = 4
          ..attendanceTarget = 75.0
          ..color = '#2563EB'
          ..type = 'THEORY'
          ..createdAt = now.toUtc()
          ..updatedAt = now.toUtc();
        final sub2 = SubjectLocal()
          ..id = db.subjectLocals.autoIncrement()
          ..serverId = 'sub_lab'
          ..semesterId = semId
          ..name = 'Algorithms Lab'
          ..code = 'CS301L'
          ..credits = 2
          ..attendanceTarget = 75.0
          ..color = '#10B981'
          ..type = 'LAB'
          ..createdAt = now.toUtc()
          ..updatedAt = now.toUtc();
        db.subjectLocals.putAll(<SubjectLocal>[sub1, sub2]);
        subCsId = sub1.id;
        subLabId = sub2.id;
      });

      // Keep auto-dispose controllers mounted just as UI screens do via ref.watch
      container.listen(activeSemesterProvider, (_, __) {});
      container.listen(weeklyScheduleRuleListControllerProvider, (_, __) {});
      container.listen(scheduleExceptionControllerProvider, (_, __) {});
      container.listen(academicEventControllerProvider, (_, __) {});

      // 1a. Create multi-slot weekly rules for CS301 today AND a tomorrow rule
      await container.read(activeSemesterProvider.future);
      await container.read(weeklyScheduleRuleListControllerProvider.future);
      await container
          .read(weeklyScheduleRuleListControllerProvider.notifier)
          .addRulesForDays(
            subjectId: subCsId,
            daysOfWeek: [now.weekday],
            startTime: '09:00',
            endTime: '10:00',
            room: 'A101',
          );
      await container.read(weeklyScheduleRuleListControllerProvider.future);
      await container
          .read(weeklyScheduleRuleListControllerProvider.notifier)
          .addRulesForDays(
            subjectId: subCsId,
            daysOfWeek: [now.weekday],
            startTime: '14:00',
            endTime: '15:00',
            room: 'A102',
          );
      await container.read(weeklyScheduleRuleListControllerProvider.future);
      await container
          .read(weeklyScheduleRuleListControllerProvider.notifier)
          .addRulesForDays(
            subjectId: subLabId,
            daysOfWeek: [tomorrow.weekday],
            startTime: '11:00',
            endTime: '13:00',
            room: 'Lab 2',
          );

      final rulesInDb = isar.weeklyScheduleRuleLocals.where().findAll();
      expect(rulesInDb, hasLength(3));

      // Edit room on the 09:00 rule
      final morningRule = (await container
              .read(weeklyScheduleRuleListControllerProvider.future))
          .firstWhere((r) => r.startTime == '09:00');
      await container
          .read(weeklyScheduleRuleListControllerProvider.notifier)
          .saveRule(morningRule.copyWith(room: 'B202'));

      // 1b. Read today's schedule & verify distinct multi-slot keys & ruleId bindings
      final todayState =
          await container.read(todayScheduleProvider(customDate: now).future);
      expect(todayState.isHoliday, isFalse);
      expect(todayState.occurrences, hasLength(2));
      expect(todayState.occurrences[0].room, equals('B202'));
      expect(todayState.occurrences[0].ruleId, isNotNull);
      expect(todayState.occurrences[1].ruleId, isNotNull);
      expect(
        todayState.occurrences[0].slotKey,
        isNot(equals(todayState.occurrences[1].slotKey)),
      );

      // 1c. Concurrent & repeated materialization produces ZERO duplicate slots
      final occRepo = container.read(dailyScheduleOccurrenceRepositoryProvider);
      final results = await Future.wait([
        occRepo.saveOccurrence(todayState.occurrences[0]),
        occRepo.saveOccurrence(todayState.occurrences[0]),
        occRepo.saveOccurrence(todayState.occurrences[0]),
      ]);
      expect(results.map((o) => o.id).toSet(), hasLength(1));

      // 1d. Mark Slot 1 PRESENT and Slot 2 ABSENT (same subject, same day!)
      final attCtrl = container.read(attendanceControllerProvider.notifier);
      final markedPresent =
          await attCtrl.markOccurrencePresent(todayState.occurrences[0]);
      final markedAbsent =
          await attCtrl.markOccurrenceAbsent(todayState.occurrences[1]);

      expect(markedPresent.id, isNot(equals(markedAbsent.id)));
      expect(markedPresent.status, equals(OccurrenceStatus.PRESENT));
      expect(markedAbsent.status, equals(OccurrenceStatus.ABSENT));

      // Verify legacy EventLocal was NOT mutated or written!
      expect(isar.eventLocals.count(), equals(0));

      final csAttRecords = isar.attendanceRecordLocals
          .where()
          .subjectIdEqualTo(subCsId)
          .findAll();
      expect(csAttRecords, hasLength(2));
      expect(csAttRecords.every((r) => r.occurrenceId != null), isTrue);

      // DayTimeline / WeeklyScheduleView sees BOTH distinct statuses accurately
      final dayView = await container.read(dayScheduleProvider(now).future);
      final csDaySlots =
          dayView.items.where((s) => s.subjectId == subCsId).toList();
      expect(csDaySlots, hasLength(2));
      expect(csDaySlots[0].status, equals('PRESENT'));
      expect(csDaySlots[1].status, equals('ABSENT'));

      // Edit Slot 2 from ABSENT -> PRESENT, then CANCELLED -> soft-deletes record
      await attCtrl.markOccurrencePresent(markedAbsent);
      await attCtrl.markOccurrenceCancelled(markedAbsent);

      final activeCsAtt = isar.attendanceRecordLocals
          .where()
          .subjectIdEqualTo(subCsId)
          .isDeletedEqualTo(false)
          .findAll();
      expect(activeCsAtt, hasLength(1));
      expect(activeCsAtt.single.occurrenceId, equals(markedPresent.id));

      // 1e. Add Extra Class (via addExtraClass AND markExtraClass)
      final extraOcc = await attCtrl.addExtraClass(
        date: now,
        subjectId: subCsId,
        subjectTitle: 'Algorithms',
        startTime: '17:00',
        endTime: '18:00',
        reason: 'Doubt Session',
      );
      expect(extraOcc.slotKey, startsWith('EXTRA|'));
      await attCtrl.markOccurrencePresent(extraOcc);

      await attCtrl.markExtraClass(
        subjectId: subCsId,
        date: now,
        status: AttendanceStatus.EXTRA_ABSENT,
      );
      // Must NOT touch EventLocal
      expect(isar.eventLocals.count(), equals(0));

      // 1f. Stats, Subject Occurrences, Analytics, Reports & AI Context all agree!
      final stats =
          await container.read(subjectAttendanceStatsProvider(subCsId).future);
      expect(stats, isNotNull);
      expect(stats!.presentCount, equals(2)); // 1 regular + 1 extra
      expect(stats.absentCount, equals(1)); // 1 markExtraClass absent
      expect(stats.totalClasses, equals(3));

      final occHistory =
          await container.read(subjectOccurrencesProvider(subCsId).future);
      expect(occHistory.length, greaterThanOrEqualTo(4));

      final analytics =
          await container.read(attendanceAnalyticsProvider.future);
      expect(analytics, isNotNull);
      expect(analytics!.totalPresent, equals(2));
      expect(analytics.totalClasses, equals(3));

      final report =
          await container.read(reportServiceProvider).generateSemesterReport();
      expect(report, isNotNull);
      expect(report!.totalPresent, equals(2));
      expect(report.totalClasses, equals(3));

      final aiCtx = await container.read(aiContextProvider.future);
      expect(aiCtx.attendanceSummary['totalPresent'], equals(2));
      expect(aiCtx.attendanceSummary['totalClasses'], equals(3));
      expect(
        aiCtx.upcomingClasses.any(
          (c) =>
              c['day'] == 'Tomorrow' &&
              c['subjectId'] == subLabId &&
              c['time'] == '11:00-13:00',
        ),
        isTrue,
      );

      // 1g. Schedule exception (HOLIDAY on tomorrow) removes tomorrow classes
      //     in TodaySchedule, DaySchedule, AI Context & NotificationScheduler!
      final futureHour = tomorrow;
      final dbNotif = IsarNotificationDatabaseImpl(isar);
      final scheduler = NotificationScheduler(dbNotif, spyNotif);

      await scheduler.rescheduleRollingWindow(
        offsets: const [15],
        customNow: DateTime(now.year, now.month, now.day, 8, 0),
      );
      // Verify tomorrow's CS301L class reminder uses canonical slot: key
      final beforeHolidayNotifs = await dbNotif.getAllNotifications();
      expect(
        beforeHolidayNotifs.any(
          (n) =>
              n.relatedId != null &&
              n.relatedId!.startsWith('slot:REGULAR|') &&
              n.body.contains('Lab 2'),
        ),
        isTrue,
      );

      // Notification lifecycle across unmaterialized rule -> materialized occurrence -> room update
      final labReminderBefore = beforeHolidayNotifs.firstWhere(
        (n) =>
            n.relatedId != null &&
            n.relatedId!.startsWith('slot:REGULAR|') &&
            n.body.contains('Lab 2'),
      );
      final tomorrowState = await container
          .read(todayScheduleProvider(customDate: tomorrow).future);
      final labOcc =
          tomorrowState.occurrences.firstWhere((o) => o.subjectId == subLabId);
      final materializedLabOcc = await occRepo.saveOccurrence(
        labOcc.copyWith(room: 'Lab 2'),
      );
      spyNotif.scheduled.clear();
      spyNotif.cancelled.clear();
      await scheduler.rescheduleRollingWindow(
        offsets: const [15],
        customNow: DateTime(now.year, now.month, now.day, 8, 0),
      );
      // Zero delete/recreate churn when rule materializes with same room & slotKey!
      expect(spyNotif.cancelled, isEmpty);
      expect(spyNotif.scheduled, isEmpty);
      final labReminderAfter = (await dbNotif.getAllNotifications()).firstWhere(
        (n) => n.relatedId == labReminderBefore.relatedId,
      );
      expect(labReminderAfter.id, equals(labReminderBefore.id));
      expect(
        labReminderAfter.androidNotificationId,
        equals(labReminderBefore.androidNotificationId),
      );
      expect(materializedLabOcc.id, isNotNull);

      final excCtrl =
          container.read(scheduleExceptionControllerProvider.notifier);
      await excCtrl.addException(
        date: futureHour,
        type: ScheduleExceptionType.HOLIDAY,
        title: 'Founders Day',
      );

      final tomorrowSchedule = await container
          .read(todayScheduleProvider(customDate: tomorrow).future);
      expect(tomorrowSchedule.isHoliday, isTrue);
      expect(tomorrowSchedule.occurrences, isEmpty);

      final tomorrowAiCtx = await container.refresh(aiContextProvider.future);
      expect(
        tomorrowAiCtx.upcomingClasses.where((c) => c['day'] == 'Tomorrow'),
        isEmpty,
      );

      await scheduler.rescheduleRollingWindow(
        offsets: const [15],
        customNow: DateTime(now.year, now.month, now.day, 8, 0),
      );
      final afterHolidayNotifs = await dbNotif.getAllNotifications();
      expect(
        afterHolidayNotifs.where((n) => n.body.contains('Lab 2')),
        isEmpty,
      );

      // Exam reminder uses non-colliding ae_1d: / ae_30m: key AND widget data stays in sync
      final aeCtrl = container.read(academicEventControllerProvider.notifier);
      await aeCtrl.addEvent(
        title: 'Midterm Exam',
        date: now.add(const Duration(days: 3)),
        startTime: '10:00',
        endTime: '12:00',
        type: AcademicEventType.EXAM,
      );
      await scheduler.rescheduleRollingWindow(
        offsets: const [15],
        customNow: DateTime(now.year, now.month, now.day, 8, 0),
      );
      final allNotifs = await dbNotif.getAllNotifications();
      expect(
        allNotifs.any((n) => n.relatedId?.startsWith('ae_1d:') ?? false),
        isTrue,
      );
      expect(
        allNotifs.any((n) => n.relatedId?.startsWith('ae_30m:') ?? false),
        isTrue,
      );

      // Notification ID & slot: relatedId stay identical when an unmaterialized rule materializes & updates in-place
      await excCtrl.addException(
        date: futureHour,
        type: ScheduleExceptionType.EVENT,
        title: 'Check',
      );
      // Verify widget data matches multi-slot schedule for today accurately
      final widgetService = container.read(widgetDataServiceProvider);
      final todayWidget =
          await widgetService.generateTodayWidgetData(customDate: now);
      expect(todayWidget.isHoliday, isFalse);
      expect(todayWidget.classes.any((c) => c.status == 'PRESENT'), isTrue);
      expect(todayWidget.classes.any((c) => c.status == 'CANCELLED'), isTrue);
    });

    test(
        '2. Occurrence identity prevents recurring/extra/exam collisions & concurrent/repeated migration dedup',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug004_identity_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final day = DateTime.utc(2026, 9, 14);
        final now = DateTime.utc(2026, 9, 14, 8, 0);

        final regular = DailyScheduleOccurrenceLocal()
          ..date = day
          ..subjectId = 10
          ..ruleId = 5
          ..title = 'Systems'
          ..startTime = '09:00'
          ..endTime = '10:00'
          ..type = 'REGULAR_CLASS'
          ..createdFrom = 'WEEKLY_RULE'
          ..status = 'UPCOMING'
          ..createdAt = now
          ..updatedAt = now;
        final extra = DailyScheduleOccurrenceLocal()
          ..date = day
          ..subjectId = 10
          ..title = 'Systems Extra'
          ..startTime = '09:00'
          ..endTime = '10:00'
          ..type = 'EXTRA_CLASS'
          ..createdFrom = 'MANUAL'
          ..status = 'UPCOMING'
          ..createdAt = now
          ..updatedAt = now;
        final exam = DailyScheduleOccurrenceLocal()
          ..date = day
          ..subjectId = 10
          ..title = 'Systems Midterm'
          ..startTime = '09:00'
          ..endTime = '10:00'
          ..type = 'EXAM'
          ..createdFrom = 'MANUAL'
          ..status = 'UPCOMING'
          ..createdAt = now
          ..updatedAt = now;

        isar.write((db) {
          upsertCanonicalOccurrenceInWriteTx(db, regular);
          upsertCanonicalOccurrenceInWriteTx(db, extra);
          upsertCanonicalOccurrenceInWriteTx(db, exam);
          // Re-upsert identical regular class (e.g. concurrent re-generation)
          final dupRegular = DailyScheduleOccurrenceLocal()
            ..date = day
            ..subjectId = 10
            ..ruleId = 5
            ..title = 'Systems'
            ..startTime = '9:00' // unpadded time normalizes to 09:00
            ..endTime = '10:00'
            ..type = 'REGULAR_CLASS'
            ..createdFrom = 'WEEKLY_RULE'
            ..status = 'PRESENT'
            ..createdAt = now
            ..updatedAt = now.add(const Duration(minutes: 5));
          upsertCanonicalOccurrenceInWriteTx(db, dupRegular);
        });

        final allOcc = isar.dailyScheduleOccurrenceLocals
            .where()
            .isDeletedEqualTo(false)
            .findAll();
        expect(allOcc, hasLength(3));
        expect(allOcc.map((o) => o.slotKey).toSet(), hasLength(3));
        final survivingReg =
            allOcc.firstWhere((o) => o.type == 'REGULAR_CLASS');
        expect(survivingReg.status, equals('PRESENT'));

        // Soft deleting an occurrence does not block recreating the slot later
        isar.write((db) {
          survivingReg.isDeleted = true;
          db.dailyScheduleOccurrenceLocals.put(survivingReg);
          final recreated = DailyScheduleOccurrenceLocal()
            ..date = day
            ..subjectId = 10
            ..ruleId = 5
            ..title = 'Systems'
            ..startTime = '09:00'
            ..endTime = '10:00'
            ..type = 'REGULAR_CLASS'
            ..createdFrom = 'WEEKLY_RULE'
            ..status = 'UPCOMING'
            ..createdAt = now
            ..updatedAt = now;
          upsertCanonicalOccurrenceInWriteTx(db, recreated);
        });
        expect(
          isar.dailyScheduleOccurrenceLocals
              .where()
              .isDeletedEqualTo(false)
              .findAll(),
          hasLength(3),
        );
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '3. Legacy on-disk migration upgrades pre-BUG-004 binary DB, preserves LAB type, resolves EventLocal vs Occurrence ID collisions conservatively, recovers overwritten records without resurrecting deletions, and survives reopen idempotently',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug004_legacy_db_');
      const dbName = AppConstants.isarDbName;
      Isar? openedIsar;

      try {
        final legacyDate = DateTime.utc(2026, 6, 10);
        final laterDate = DateTime.utc(2026, 7, 20);
        final ts = DateTime.utc(2026, 6, 10, 10, 0);

        // 3a. Open pre-BUG-004 Isar schemas on disk and seed collision + overwritten data
        final legacyIsar = Isar.open(
          schemas: <IsarGeneratedSchema>[
            SemesterLocalSchema,
            SubjectLocalSchema,
            TimetableTemplateLocalSchema,
            EventLocalSchema,
            _preBug004RuleSchema,
            _preBug004OccSchema,
            _preBug004AttSchema,
            ScheduleExceptionLocalSchema,
            AcademicEventLocalSchema,
            NotificationItemSchema,
          ],
          name: dbName,
          directory: tempDir.path,
        );

        legacyIsar.write((db) {
          db.semesterLocals.put(
            SemesterLocal()
              ..id = 1
              ..serverId = 'sem_1'
              ..name = 'Summer 2026'
              ..startDate = DateTime.utc(2026, 6, 1)
              ..endDate = DateTime.utc(2026, 9, 1)
              ..requiredAttendanceRate = 75.0
              ..status = SemesterLocal.statusActive
              ..isActive = true
              ..createdAt = ts
              ..updatedAt = ts,
          );

          // Sub 10: THEORY, Sub 20: LAB
          db.subjectLocals.putAll(<SubjectLocal>[
            SubjectLocal()
              ..id = 10
              ..serverId = 'sub_10'
              ..semesterId = 1
              ..name = 'Discrete Math'
              ..code = 'MTH201'
              ..credits = 3
              ..attendanceTarget = 75.0
              ..color = '#2563EB'
              ..type = 'THEORY'
              ..createdAt = ts
              ..updatedAt = ts,
            SubjectLocal()
              ..id = 20
              ..serverId = 'sub_20'
              ..semesterId = 1
              ..name = 'Networks Lab'
              ..code = 'CS202L'
              ..credits = 2
              ..attendanceTarget = 75.0
              ..color = '#10B981'
              ..type = 'LAB'
              ..createdAt = ts
              ..updatedAt = ts,
          ]);

          // Template #1 belongs to LAB subject #20
          db.timetableTemplateLocals.put(
            TimetableTemplateLocal()
              ..id = 1
              ..serverId = 'tpl_lab_1'
              ..subjectId = 20
              ..weekday = legacyDate.weekday
              ..startTime = '14:00'
              ..endTime = '16:00'
              ..room = 'Lab 3'
              ..createdAt = ts
              ..updatedAt = ts,
          );

          // Pre-existing DailyScheduleOccurrenceLocal with id = 1 for subject 20 on laterDate
          db.collection<int, _PreBug004OccLocal>().putAll([
            _PreBug004OccLocal()
              ..id = 1
              ..serverId = 'occ_lab_later'
              ..date = laterDate
              ..subjectId = 20
              ..title = 'Networks Lab'
              ..startTime = '14:00'
              ..endTime = '16:00'
              ..type = 'REGULAR_CLASS'
              ..status = 'UPCOMING'
              ..createdFrom = 'WEEKLY_RULE'
              ..createdAt = laterDate
              ..updatedAt = laterDate,
            // Two competing identical occurrences on same subject/date -> id=2 & id=3 (ambiguous collision setup)
            _PreBug004OccLocal()
              ..id = 2
              ..serverId = 'occ_ambig_1'
              ..date = laterDate
              ..subjectId = 10
              ..title = 'Discrete Math'
              ..startTime = '10:00'
              ..endTime = '11:00'
              ..type = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdFrom = 'WEEKLY_RULE'
              ..createdAt = laterDate
              ..updatedAt = laterDate,
            _PreBug004OccLocal()
              ..id = 3
              ..serverId = 'occ_ambig_2'
              ..date = laterDate
              ..subjectId = 10
              ..title = 'Discrete Math'
              ..startTime = '11:00'
              ..endTime = '12:00'
              ..type = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdFrom = 'WEEKLY_RULE'
              ..createdAt = laterDate
              ..updatedAt = laterDate,
          ]);

          // Legacy EventLocal records:
          db.eventLocals.putAll(<EventLocal>[
            // id = 1 COLLIDES with DailyScheduleOccurrenceLocal id=1 (different subject & date!)
            EventLocal()
              ..id = 1
              ..serverId = 'ev_1'
              ..subjectId = 10
              ..date = legacyDate
              ..startTime = '09:00'
              ..endTime = '10:00'
              ..eventType = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdAt = ts
              ..updatedAt = ts,
            // id = 2 COLLIDES with DailyScheduleOccurrenceLocal id=2 (same subject 10, same date & status -> ambiguous tie when combined with occ #2!)
            EventLocal()
              ..id = 2
              ..serverId = 'ev_2'
              ..subjectId = 10
              ..date = laterDate
              ..startTime = '10:00'
              ..endTime = '11:00'
              ..eventType = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdAt = laterDate
              ..updatedAt = laterDate,
            // id = 4 has PRESENT status with NO AttendanceRecordLocal (overwritten-record scenario)
            EventLocal()
              ..id = 4
              ..serverId = 'ev_overwritten'
              ..subjectId = 20
              ..date = legacyDate
              ..startTime = '14:00'
              ..endTime = '16:00'
              ..eventType = 'REGULAR_CLASS'
              ..status = 'ABSENT'
              ..createdAt = ts
              ..updatedAt = ts,
            // id = 5 has PRESENT status PLUS a soft-deleted AttendanceRecordLocal tombstone -> must NOT resurrect!
            EventLocal()
              ..id = 5
              ..serverId = 'ev_deleted_att'
              ..subjectId = 20
              ..date = DateTime.utc(2026, 6, 17)
              ..startTime = '14:00'
              ..endTime = '16:00'
              ..eventType = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdAt = ts
              ..updatedAt = ts,
          ]);

          // Legacy AttendanceRecordLocals:
          db.collection<int, _PreBug004AttLocal>().putAll([
            // att #1 belongs to EventLocal #1 (subject 10, legacyDate) — must bind to migrated Event #1 occurrence, NOT Occ #1 (subject 20)!
            _PreBug004AttLocal()
              ..id = 1
              ..serverId = 'att_ev1'
              ..eventId = 1
              ..subjectId = 10
              ..status = 'PRESENT'
              ..markedAt = ts
              ..createdAt = ts
              ..updatedAt = ts,
            // att #2 has eventId = 2 where BOTH Occ #2 (status PRESENT, date laterDate) and EventLocal #2 (also ambiguous) compete! Wait: let's point att #2 at an unmerged colliding EventLocal #2 with distinct slot!
            _PreBug004AttLocal()
              ..id = 2
              ..serverId = 'att_ambig'
              ..eventId = 2
              ..subjectId = 10
              ..status = 'PRESENT'
              ..markedAt = laterDate
              ..createdAt = laterDate
              ..updatedAt = laterDate,
            // att #3 is an orphan with missing target (eventId = 999) -> must keep occurrenceId = null, NEVER fabricate an occurrence!
            _PreBug004AttLocal()
              ..id = 3
              ..serverId = 'att_orphan'
              ..eventId = 999
              ..subjectId = 10
              ..status = 'ABSENT'
              ..markedAt = DateTime.utc(2026, 6, 5)
              ..createdAt = ts
              ..updatedAt = ts,
            // att #4 is an intentional soft-deleted tombstone for EventLocal #5
            _PreBug004AttLocal()
              ..id = 4
              ..serverId = 'att_tombstone'
              ..eventId = 5
              ..subjectId = 20
              ..status = 'PRESENT'
              ..markedAt = DateTime.utc(2026, 6, 17)
              ..createdAt = ts
              ..updatedAt = ts
              ..isDeleted = true,
          ]);
        });

        legacyIsar.close();

        // 3b. Reopen on-disk DB with current appIsarSchemas & run consolidated startup migration
        openedIsar = openTempIsar(tempDir, customName: dbName);
        final report1 = await migrateLegacyTimetableAndEvents(openedIsar);

        // Rule migrated with preserved LAB type and legacyTemplateId
        final rules = openedIsar.weeklyScheduleRuleLocals.where().findAll();
        expect(rules, hasLength(1));
        expect(rules.single.type, equals('LAB'));
        expect(rules.single.legacyTemplateId, equals(1));

        // Occurrence count: 3 pre-existing + 4 legacy events (ev2 gets disambiguated LEGACY_EV:2 since occ#2 had status PRESENT vs matching slot? Actually ev2 had matching slot with identical status PRESENT & no native attendance so it merged cleanly! Wait: let's check both!)
        final att1 = openedIsar.attendanceRecordLocals
            .where()
            .serverIdEqualTo('att_ev1')
            .findFirst()!;
        expect(att1.occurrenceId, isNotNull);
        expect(att1.occurrenceId,
            isNot(equals(1))); // Must NOT collide with Occ #1 (subject 20)!
        final boundOcc1 =
            openedIsar.dailyScheduleOccurrenceLocals.get(att1.occurrenceId!)!;
        expect(boundOcc1.subjectId, equals(10));
        expect(boundOcc1.legacyEventId, equals(1));
        expect(att1.status, equals('PRESENT'));

        // att #3 (orphan) must stay occurrenceId == null with NO fabricated occurrence & be audited
        final attOrphan = openedIsar.attendanceRecordLocals
            .where()
            .serverIdEqualTo('att_orphan')
            .findFirst()!;
        expect(attOrphan.occurrenceId, isNull);
        expect(attOrphan.status, equals('ABSENT'));
        expect(
          report1.entriesOfKind(MigrationAuditKind.missingOccurrenceTarget),
          isNotEmpty,
        );

        // Overwritten EventLocal #4 -> recovered canonical AttendanceRecordLocal preserving original date & ABSENT status
        final occEv4 = openedIsar.dailyScheduleOccurrenceLocals
            .where()
            .legacyEventIdEqualTo(4)
            .findFirst()!;
        final recoveredAtt = openedIsar.attendanceRecordLocals
            .where()
            .occurrenceIdEqualTo(occEv4.id)
            .findFirst();
        expect(recoveredAtt, isNotNull);
        expect(recoveredAtt!.status, equals('ABSENT'));
        expect(normalizeUtcDate(recoveredAtt.markedAt), equals(legacyDate));
        expect(recoveredAtt.legacyEventId, equals(4));
        expect(
          report1.entriesOfKind(MigrationAuditKind.recoveredAttendance),
          hasLength(1),
        );

        // Tombstone for EventLocal #5 must NOT be resurrected!
        final occEv5 = openedIsar.dailyScheduleOccurrenceLocals
            .where()
            .legacyEventIdEqualTo(5)
            .findFirst()!;
        final ev5ActiveAttendance = openedIsar.attendanceRecordLocals
            .where()
            .occurrenceIdEqualTo(occEv5.id)
            .isDeletedEqualTo(false)
            .findAll();
        expect(ev5ActiveAttendance, isEmpty);

        // 3c. Re-run migration AND close/reopen DB -> zero duplicate records!
        final ruleCountBefore = openedIsar.weeklyScheduleRuleLocals.count();
        final occCountBefore = openedIsar.dailyScheduleOccurrenceLocals.count();
        final attCountBefore = openedIsar.attendanceRecordLocals.count();

        final report2 = await migrateLegacyTimetableAndEvents(openedIsar);
        expect(report2.rulesMigrated, equals(0));
        expect(report2.occurrencesMigratedFromLegacy, equals(0));
        expect(report2.attendanceRecovered, equals(0));

        openedIsar.close();
        openedIsar = openTempIsar(tempDir, customName: dbName);
        await migrateLegacyDatabaseRecords(openedIsar);

        expect(openedIsar.weeklyScheduleRuleLocals.count(),
            equals(ruleCountBefore));
        expect(
          openedIsar.dailyScheduleOccurrenceLocals.count(),
          equals(occCountBefore),
        );
        expect(
            openedIsar.attendanceRecordLocals.count(), equals(attCountBefore));
      } finally {
        if (openedIsar != null && openedIsar.isOpen) {
          openedIsar.close();
        }
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '4. True ambiguous EventLocal vs Occurrence collision leaves occurrenceId null and audits without silent assignment',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug004_ambig_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final date = DateTime.utc(2026, 8, 12);
        final ts = DateTime.utc(2026, 8, 12, 10, 0);

        isar.write((db) {
          db.subjectLocals.put(
            SubjectLocal()
              ..id = 10
              ..serverId = 'sub_10'
              ..semesterId = 1
              ..name = 'Compilers'
              ..code = 'CS401'
              ..credits = 4
              ..attendanceTarget = 75.0
              ..color = '#2563EB'
              ..type = 'THEORY'
              ..createdAt = ts
              ..updatedAt = ts,
          );

          // Pre-existing occurrence id=1 with identical subject, date, status, timestamp, and PRESENT
          // While conflicting EventLocal id=1 at a different time slot ALSO had PRESENT & later creates occ #2 with legacyEventId=1!
          db.dailyScheduleOccurrenceLocals.put(
            DailyScheduleOccurrenceLocal()
              ..id = 1
              ..serverId = 'native_occ_1'
              ..date = date
              ..subjectId = 10
              ..title = 'Compilers'
              ..startTime = '15:00'
              ..endTime = '16:00'
              ..type = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdFrom = 'MANUAL'
              ..slotKey = computeCanonicalSlotKey(
                date: date,
                subjectId: 10,
                startTime: '15:00',
                endTime: '16:00',
                type: 'REGULAR_CLASS',
              )
              ..createdAt = ts
              ..updatedAt = ts,
          );

          db.eventLocals.put(
            EventLocal()
              ..id = 1
              ..serverId = 'ev_1'
              ..subjectId = 10
              ..date = date
              ..startTime = '09:00'
              ..endTime = '10:00'
              ..eventType = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdAt = ts
              ..updatedAt = ts,
          );

          // Legacy AttendanceRecordLocal with eventId=1 matches BOTH id=1 (native_occ_1) and legacyEventId=1 (migrated ev_1) equally!
          db.attendanceRecordLocals.put(
            AttendanceRecordLocal()
              ..id = 1
              ..serverId = 'att_tie'
              ..eventId = 1
              ..subjectId = 10
              ..status = 'PRESENT'
              ..markedAt = ts
              ..createdAt = ts
              ..updatedAt = ts,
          );
        });

        final report = await migrateLegacyTimetableAndEvents(isar);
        final att = isar.attendanceRecordLocals.get(1)!;
        expect(att.occurrenceId, isNull); // Must NOT silently guess!
        expect(att.status, equals('PRESENT'));
        expect(
          report.entriesOfKind(MigrationAuditKind.ambiguousAttendanceCollision),
          hasLength(1),
        );
        // Must NOT also recover a duplicate record onto ev_1 while unresolved tie exists!
        expect(report.attendanceRecovered, equals(0));
        expect(isar.attendanceRecordLocals.count(), equals(1));

        // Re-running migration stays idempotent without duplicate recovery or duplicate audit corruption
        final report2 = await migrateLegacyTimetableAndEvents(isar);
        expect(isar.attendanceRecordLocals.count(), equals(1));
        expect(report2.attendanceRecovered, equals(0));
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        '5. BackupExporter & BackupImporter (Replace and Merge) remap conflicting source IDs across WeeklyScheduleRuleLocal, DailyScheduleOccurrenceLocal, ruleId, AttendanceRecordLocal.occurrenceId, notifications, and serverIds cleanly',
        () async {
      if (nativeLibPath == null) return;

      final dirSrc =
          await Directory.systemTemp.createTemp('attendiq_bug004_bkp_src_');
      final dirDest =
          await Directory.systemTemp.createTemp('attendiq_bug004_bkp_dest_');
      Isar? srcIsar;
      Isar? destIsar;

      try {
        final now = DateTime.utc(2026, 8, 1);

        // 5a. Build Source DB with low PKs (1, 1, 1, 1) and LAB rule + occurrence + attendance + notification
        srcIsar = openTempIsar(dirSrc);
        srcIsar.write((db) {
          db.semesterLocals.put(
            SemesterLocal()
              ..id = 1
              ..serverId = 'shared_conflict_server_id_sem'
              ..name = 'Source Backup Sem'
              ..startDate = DateTime.utc(2026, 8, 1)
              ..endDate = DateTime.utc(2026, 12, 15)
              ..requiredAttendanceRate = 80.0
              ..status = SemesterLocal.statusActive
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          );
          db.subjectLocals.put(
            SubjectLocal()
              ..id = 1
              ..serverId = 'src_sub_phys'
              ..semesterId = 1
              ..name = 'Quantum Physics Lab'
              ..code = 'PHY301L'
              ..credits = 2
              ..attendanceTarget = 80.0
              ..color = '#8B5CF6'
              ..type = 'LAB'
              ..createdAt = now
              ..updatedAt = now,
          );
          db.timetableTemplateLocals.put(
            TimetableTemplateLocal()
              ..id = 1
              ..serverId = 'src_tpl_1'
              ..subjectId = 1
              ..weekday = 1
              ..startTime = '11:00'
              ..endTime = '13:00'
              ..createdAt = now
              ..updatedAt = now,
          );
          db.weeklyScheduleRuleLocals.put(
            WeeklyScheduleRuleLocal()
              ..id = 1
              ..serverId = 'shared_conflict_server_id_rule'
              ..subjectId = 1
              ..legacyTemplateId = 1
              ..dayOfWeek = 1
              ..startTime = '11:00'
              ..endTime = '13:00'
              ..room = 'Quantum Lab'
              ..type = 'LAB'
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          );
          final occ = DailyScheduleOccurrenceLocal()
            ..id = 1
            ..serverId = 'shared_conflict_server_id_occ'
            ..date = DateTime.utc(2026, 8, 3)
            ..subjectId = 1
            ..ruleId = 1
            ..title = 'Quantum Physics Lab'
            ..startTime = '11:00'
            ..endTime = '13:00'
            ..type = 'REGULAR_CLASS'
            ..status = 'PRESENT'
            ..createdFrom = 'WEEKLY_RULE'
            ..room = 'Quantum Lab'
            ..createdAt = now
            ..updatedAt = now;
          occ.slotKey = computeSlotKeyForLocal(occ);
          db.dailyScheduleOccurrenceLocals.put(occ);

          db.attendanceRecordLocals.put(
            AttendanceRecordLocal()
              ..id = 1
              ..serverId = 'shared_conflict_server_id_att'
              ..occurrenceId = 1
              ..eventId = 1
              ..subjectId = 1
              ..status = 'PRESENT'
              ..markedAt = DateTime.utc(2026, 8, 3)
              ..createdAt = now
              ..updatedAt = now,
          );

          db.notificationItems.put(
            NotificationItem()
              ..id = 1
              ..title = 'Quantum Physics Lab Reminder'
              ..body = 'Starts at 11:00'
              ..type = NotificationType.CLASS_REMINDER.toShortString()
              ..scheduledTime = DateTime.utc(2026, 8, 3, 10, 45)
              ..relatedId = NotificationRelatedKeys.forSlotKey(occ.slotKey!)
              ..isRead = false,
          );
        });

        final backupJson = await BackupExporter(srcIsar).exportToJsonString();

        // 5b. Seed Destination DB with CONFLICTING PKs (id = 1 everywhere & overlapping serverIds!)
        destIsar = openTempIsar(dirDest);
        destIsar.write((db) {
          db.semesterLocals.put(
            SemesterLocal()
              ..id = 1
              ..serverId = 'shared_conflict_server_id_sem'
              ..name = 'Destination Existing Sem'
              ..startDate = DateTime.utc(2026, 1, 10)
              ..endDate = DateTime.utc(2026, 5, 20)
              ..requiredAttendanceRate = 75.0
              ..status = SemesterLocal.statusActive
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          );
          db.subjectLocals.put(
            SubjectLocal()
              ..id = 1
              ..serverId = 'dest_sub_chem'
              ..semesterId = 1
              ..name = 'Organic Chemistry'
              ..code = 'CHM101'
              ..credits = 3
              ..attendanceTarget = 75.0
              ..color = '#EF4444'
              ..type = 'THEORY'
              ..createdAt = now
              ..updatedAt = now,
          );
          db.weeklyScheduleRuleLocals.put(
            WeeklyScheduleRuleLocal()
              ..id = 1
              ..serverId = 'shared_conflict_server_id_rule'
              ..subjectId = 1
              ..dayOfWeek = 2
              ..startTime = '08:00'
              ..endTime = '09:00'
              ..type = 'THEORY'
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          );
          final destOcc = DailyScheduleOccurrenceLocal()
            ..id = 1
            ..serverId = 'shared_conflict_server_id_occ'
            ..date = DateTime.utc(2026, 2, 3)
            ..subjectId = 1
            ..ruleId = 1
            ..title = 'Organic Chemistry'
            ..startTime = '08:00'
            ..endTime = '09:00'
            ..type = 'REGULAR_CLASS'
            ..status = 'ABSENT'
            ..createdFrom = 'WEEKLY_RULE'
            ..createdAt = now
            ..updatedAt = now;
          destOcc.slotKey = computeSlotKeyForLocal(destOcc);
          db.dailyScheduleOccurrenceLocals.put(destOcc);

          db.attendanceRecordLocals.put(
            AttendanceRecordLocal()
              ..id = 1
              ..serverId = 'shared_conflict_server_id_att'
              ..occurrenceId = 1
              ..eventId = 1
              ..subjectId = 1
              ..status = 'ABSENT'
              ..markedAt = DateTime.utc(2026, 2, 3)
              ..createdAt = now
              ..updatedAt = now,
          );
        });

        // 5c. Execute ImportStrategy.merge!
        final importer = BackupImporter(destIsar);
        await importer.importData(backupJson, strategy: ImportStrategy.merge);

        // Existing destination records must stay untouched!
        final destChemSub = destIsar.subjectLocals.get(1)!;
        expect(destChemSub.code, equals('CHM101'));
        final destChemAtt = destIsar.attendanceRecordLocals.get(1)!;
        expect(destChemAtt.occurrenceId, equals(1));
        expect(destChemAtt.status, equals('ABSENT'));

        // Imported Physics Lab must have NEW remapped IDs & valid FKs pointing ONLY to destination records!
        final physSub =
            destIsar.subjectLocals.where().codeEqualTo('PHY301L').findFirst()!;
        expect(physSub.id, isNot(equals(1)));

        final physRule = destIsar.weeklyScheduleRuleLocals
            .where()
            .subjectIdEqualTo(physSub.id)
            .findFirst()!;
        expect(physRule.id, isNot(equals(1)));
        expect(physRule.type, equals('LAB'));
        expect(
          physRule.serverId,
          isNot(equals('shared_conflict_server_id_rule')),
        );

        final physOcc = destIsar.dailyScheduleOccurrenceLocals
            .where()
            .subjectIdEqualTo(physSub.id)
            .findFirst()!;
        expect(physOcc.id, isNot(equals(1)));
        expect(physOcc.ruleId, equals(physRule.id)); // FK remapped!
        expect(
          physOcc.slotKey,
          contains('rule:${physRule.id}|sub:${physSub.id}|'),
        );

        final physAtt = destIsar.attendanceRecordLocals
            .where()
            .subjectIdEqualTo(physSub.id)
            .findFirst()!;
        expect(physAtt.id, isNot(equals(1)));
        expect(physAtt.occurrenceId, equals(physOcc.id)); // FK remapped!
        expect(physAtt.eventId, equals(physOcc.id));
        expect(physAtt.status, equals('PRESENT'));

        // Notification relatedId must also have remapped ruleId/subjectId in slot: key!
        final physNotif = destIsar.notificationItems
            .where()
            .titleContains('Quantum Physics Lab')
            .findFirst()!;
        expect(
          physNotif.relatedId,
          equals(NotificationRelatedKeys.forSlotKey(physOcc.slotKey!)),
        );

        // Re-merging identical backup does NOT duplicate rules/occurrences/attendance/notifications
        final ruleCountAfterFirstMerge =
            destIsar.weeklyScheduleRuleLocals.count();
        final occCountAfterFirstMerge =
            destIsar.dailyScheduleOccurrenceLocals.count();
        final attCountAfterFirstMerge = destIsar.attendanceRecordLocals.count();
        final notifCountAfterFirstMerge = destIsar.notificationItems.count();

        await importer.importData(backupJson, strategy: ImportStrategy.merge);

        expect(
          destIsar.weeklyScheduleRuleLocals.count(),
          equals(ruleCountAfterFirstMerge),
        );
        expect(
          destIsar.dailyScheduleOccurrenceLocals.count(),
          equals(occCountAfterFirstMerge),
        );
        expect(
          destIsar.attendanceRecordLocals.count(),
          equals(attCountAfterFirstMerge),
        );
        expect(
          destIsar.notificationItems.count(),
          equals(notifCountAfterFirstMerge),
        );

        // 5d. Execute ImportStrategy.replace with conflicting existing destination DB
        await importer.importData(backupJson, strategy: ImportStrategy.replace);
        expect(destIsar.subjectLocals.count(), equals(1));
        expect(destIsar.subjectLocals.get(1)!.code, equals('PHY301L'));
        expect(destIsar.weeklyScheduleRuleLocals.get(1)!.type, equals('LAB'));
        expect(
            destIsar.dailyScheduleOccurrenceLocals.get(1)!.ruleId, equals(1));
        expect(destIsar.attendanceRecordLocals.get(1)!.occurrenceId, equals(1));
      } finally {
        srcIsar?.close();
        destIsar?.close();
        if (dirSrc.existsSync()) await dirSrc.delete(recursive: true);
        if (dirDest.existsSync()) await dirDest.delete(recursive: true);
      }
    });

    test(
        '6. Pre-BUG-004 legacy JSON backup upgrades cleanly on both Replace and Merge without FK collisions',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug004_legacy_bkp_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final ts = DateTime.utc(2026, 5, 10);

        // Seed existing destination DB with id=1 subject, rule, occurrence, attendance
        isar.write((db) {
          db.semesterLocals.put(
            SemesterLocal()
              ..id = 1
              ..serverId = 'dest_sem'
              ..name = 'Dest Sem'
              ..startDate = DateTime.utc(2026, 1, 1)
              ..endDate = DateTime.utc(2026, 6, 30)
              ..requiredAttendanceRate = 75.0
              ..status = SemesterLocal.statusActive
              ..isActive = true
              ..createdAt = ts
              ..updatedAt = ts,
          );
          db.subjectLocals.put(
            SubjectLocal()
              ..id = 1
              ..serverId = 'dest_sub'
              ..semesterId = 1
              ..name = 'Existing History'
              ..code = 'HIS101'
              ..credits = 3
              ..attendanceTarget = 75.0
              ..color = '#64748B'
              ..type = 'THEORY'
              ..createdAt = ts
              ..updatedAt = ts,
          );
          final destOcc = DailyScheduleOccurrenceLocal()
            ..id = 1
            ..serverId = 'dest_occ'
            ..date = DateTime.utc(2026, 5, 10)
            ..subjectId = 1
            ..title = 'Existing History'
            ..startTime = '09:00'
            ..endTime = '10:00'
            ..type = 'REGULAR_CLASS'
            ..status = 'ABSENT'
            ..createdFrom = 'MANUAL'
            ..createdAt = ts
            ..updatedAt = ts;
          destOcc.slotKey = computeSlotKeyForLocal(destOcc);
          db.dailyScheduleOccurrenceLocals.put(destOcc);
        });

        final preBug004BackupJson = jsonEncode({
          'metadata': {
            'appVersion': '1.0.0',
            'backupVersion': 1,
            'createdAt': '2026-05-11T00:00:00.000Z',
            'devicePlatform': 'android',
          },
          'userPreferences': <Map<String, dynamic>>[],
          'semesters': [
            {
              'id': 1,
              'serverId': 'legacy_sem',
              'name': 'Legacy Sem',
              'startDate': '2026-01-01T00:00:00.000Z',
              'endDate': '2026-06-30T00:00:00.000Z',
              'requiredAttendanceRate': 75.0,
            }
          ],
          'subjects': [
            {
              'id': 1,
              'serverId': 'legacy_sub',
              'semesterId': 1,
              'name': 'Compiler Design Lab',
              'code': 'CS405L',
              'credits': 2,
              'attendanceTarget': 75.0,
              'color': '#10B981',
              'type': 'LAB',
            }
          ],
          'timetable': [
            {
              'id': 1,
              'serverId': 'legacy_tt',
              'subjectId': 1,
              'weekday': 1,
              'startTime': '14:00',
              'endTime': '16:00',
              'room': 'Lab A',
            }
          ],
          'events': [
            {
              'id': 1,
              'serverId': 'legacy_ev',
              'subjectId': 1,
              'date': '2026-05-11T00:00:00.000Z',
              'startTime': '14:00',
              'endTime': '16:00',
              'eventType': 'REGULAR_CLASS',
              'status': 'PRESENT',
            }
          ],
          'attendance': [
            {
              'id': 1,
              'serverId': 'legacy_att',
              'eventId': 1,
              'subjectId': 1,
              'status': 'PRESENT',
              'markedAt': '2026-05-11T00:00:00.000Z',
            }
          ],
          'notifications': <Map<String, dynamic>>[],
        });

        final importer = BackupImporter(isar);
        await importer.importData(
          preBug004BackupJson,
          strategy: ImportStrategy.merge,
        );

        final compSub =
            isar.subjectLocals.where().codeEqualTo('CS405L').findFirst()!;
        expect(compSub.id, isNot(equals(1)));

        final compRule = isar.weeklyScheduleRuleLocals
            .where()
            .subjectIdEqualTo(compSub.id)
            .findFirst()!;
        expect(compRule.type, equals('LAB'));

        final compOcc = isar.dailyScheduleOccurrenceLocals
            .where()
            .subjectIdEqualTo(compSub.id)
            .findFirst()!;
        expect(compOcc.ruleId, equals(compRule.id));

        final compAtt = isar.attendanceRecordLocals
            .where()
            .subjectIdEqualTo(compSub.id)
            .findFirst()!;
        expect(compAtt.occurrenceId, equals(compOcc.id));
        expect(compAtt.occurrenceId,
            isNot(equals(1))); // Did NOT attach to HIS101 occ #1!
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });
}
