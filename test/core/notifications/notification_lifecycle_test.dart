import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/app/app.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/errors/app_exception.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/core/notifications/providers/notification_providers.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_scheduler.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/core/widgets/database_startup_error_page.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/task_enums.dart';
import 'package:attend_iq/features/academic_planner/presentation/controllers/task_controller.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';
import 'package:attend_iq/features/settings/domain/repositories/settings_repository.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/domain/repositories/subject_repository.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:attend_iq/features/timetable/data/models/academic_event_local.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/schedule_exception_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/utils/occurrence_identity.dart';
import 'package:attend_iq/features/widgets/services/widget_refresh_service.dart';
import 'package:attend_iq/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

class _TrackingFakeIsar extends Fake implements Isar {
  bool _open = true;

  @override
  bool get isOpen => _open;

  @override
  bool close({bool deleteFromDisk = false}) {
    final wasOpen = _open;
    _open = false;
    return wasOpen;
  }
}

class _SpyNotificationService implements NotificationService {
  int initializeCalls = 0;
  int permissionRequests = 0;
  bool shouldThrowOnInitialize = false;
  Completer<void>? initBlocker;

  final List<NotificationItem> scheduled = <NotificationItem>[];
  final List<int> cancelled = <int>[];
  bool allCancelled = false;

  @override
  Future<void> initialize() async {
    initializeCalls++;
    if (initBlocker != null) {
      await initBlocker!.future;
    }
    if (shouldThrowOnInitialize) {
      throw PlatformException(
        code: 'INIT_FAILED',
        message: 'Notification plugin initialization failed',
      );
    }
  }

  @override
  Future<bool> requestPermissions() async {
    permissionRequests++;
    return true;
  }

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
    allCancelled = true;
    scheduled.clear();
  }
}

class _SpyNotificationDatabase implements NotificationDatabase {
  final List<DailyScheduleOccurrenceLocal> occurrences =
      <DailyScheduleOccurrenceLocal>[];
  final List<AcademicEventLocal> academicEvents = <AcademicEventLocal>[];
  final List<SubjectLocal> subjects = <SubjectLocal>[];
  final List<WeeklyScheduleRuleLocal> weeklyRules = <WeeklyScheduleRuleLocal>[];
  final List<ScheduleExceptionLocal> scheduleExceptions =
      <ScheduleExceptionLocal>[];
  final List<AttendanceRecordLocal> attendanceRecords =
      <AttendanceRecordLocal>[];
  final List<NotificationItem> notifications = <NotificationItem>[];
  SemesterLocal? activeSemester;

  Completer<void>? getEventsBlocker;
  int getEventsCalls = 0;
  int activeConcurrentRescheduleReads = 0;
  int maxConcurrentRescheduleReads = 0;
  int _nextNotificationId = 1;

  @override
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrences(
      DateTime start, DateTime end) async {
    getEventsCalls++;
    activeConcurrentRescheduleReads++;
    if (activeConcurrentRescheduleReads > maxConcurrentRescheduleReads) {
      maxConcurrentRescheduleReads = activeConcurrentRescheduleReads;
    }
    try {
      if (getEventsBlocker != null && !getEventsBlocker!.isCompleted) {
        await getEventsBlocker!.future;
      }
      return occurrences.where((o) {
        final dateStripped =
            DateTime.utc(o.date.year, o.date.month, o.date.day);
        return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
      }).toList();
    } finally {
      activeConcurrentRescheduleReads--;
    }
  }

  @override
  Future<List<WeeklyScheduleRuleLocal>> getWeeklyRules() async => weeklyRules;

  @override
  Future<List<ScheduleExceptionLocal>> getScheduleExceptions(
      DateTime start, DateTime end) async {
    return scheduleExceptions.where((e) {
      final dateStripped = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<AcademicEventLocal>> getAcademicEvents(
    DateTime start,
    DateTime end,
  ) async {
    return academicEvents.where((e) {
      final dateStripped = DateTime.utc(e.date.year, e.date.month, e.date.day);
      return !dateStripped.isBefore(start) && !dateStripped.isAfter(end);
    }).toList();
  }

  @override
  Future<List<SubjectLocal>> getSubjects() async => subjects;

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceRecordsForSubject(
    int subjectId,
  ) async {
    return attendanceRecords.where((r) => r.subjectId == subjectId).toList();
  }

  @override
  Future<List<AttendanceRecordLocal>> getAllAttendanceRecords() async =>
      attendanceRecords;

  @override
  Future<SemesterLocal?> getActiveSemester() async => activeSemester;

  @override
  Future<List<NotificationItem>> getFutureNotifications(DateTime now) async {
    return notifications.where((n) => n.scheduledTime.isAfter(now)).toList();
  }

  @override
  Future<List<NotificationItem>> getFutureNotificationsByType(
    String type,
    DateTime now,
  ) async {
    return notifications
        .where((n) => n.type == type && n.scheduledTime.isAfter(now))
        .toList();
  }

  @override
  Future<NotificationItem?> getLastNotification(
    String type,
    String relatedId,
  ) async {
    final list = notifications
        .where((n) => n.type == type && n.relatedId == relatedId)
        .toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    return list.first;
  }

  @override
  Future<void> deleteNotification(int id) async {
    notifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> saveNotification(NotificationItem item) async {
    if (item.id == 0) {
      item.id = _nextNotificationId++;
    } else {
      notifications.removeWhere((n) => n.id == item.id);
    }
    notifications.add(item);
  }
}

class _CountingNotificationScheduler extends NotificationScheduler {
  int rescheduleAllCalls = 0;
  int completedReschedulePasses = 0;
  Completer<void>? _passSignal;

  _CountingNotificationScheduler(super.db, super.notificationService);

  @override
  Future<void> rescheduleAll({
    List<int> reminderOffsets = const [15],
    DateTime? customNow,
  }) async {
    rescheduleAllCalls++;
    await super.rescheduleAll(
      reminderOffsets: reminderOffsets,
      customNow: customNow,
    );
    completedReschedulePasses++;
    final signal = _passSignal;
    if (signal != null && !signal.isCompleted) {
      _passSignal = null;
      signal.complete();
    }
  }

  Future<void> waitForCompletedPasses(int targetCount) async {
    while (completedReschedulePasses < targetCount) {
      _passSignal ??= Completer<void>();
      await _passSignal!.future.timeout(const Duration(seconds: 5));
    }
  }
}

class _SpyCollectionStreams {
  final Map<String, StreamController<void>> controllers =
      <String, StreamController<void>>{};
  final Map<String, int> listenCounts = <String, int>{};
  final Map<String, int> cancelCounts = <String, int>{};

  _SpyCollectionStreams() {
    for (final name in watchedNotificationCollections) {
      listenCounts[name] = 0;
      cancelCounts[name] = 0;
      controllers[name] = StreamController<void>.broadcast(
        onListen: () {
          listenCounts[name] = (listenCounts[name] ?? 0) + 1;
        },
        onCancel: () {
          cancelCounts[name] = (cancelCounts[name] ?? 0) + 1;
        },
      );
    }
  }

  Map<String, Stream<void>> build(Isar _) {
    return controllers.map(
      (key, controller) => MapEntry(key, controller.stream),
    );
  }

  void emit(String collectionName) {
    controllers[collectionName]!.add(null);
  }

  int get totalListenCount =>
      listenCounts.values.fold<int>(0, (sum, count) => sum + count);

  int get totalCancelCount =>
      cancelCounts.values.fold<int>(0, (sum, count) => sum + count);

  Future<void> dispose() async {
    for (final controller in controllers.values) {
      await controller.close();
    }
  }
}

class _FakeSemesterRepository implements SemesterRepository {
  @override
  Future<void> createSemester(Semester semester) async {}

  @override
  Future<void> updateSemester(Semester semester) async {}

  @override
  Future<void> setActiveSemester(int localId) async {}

  @override
  Future<void> archiveSemester(int localId) async {}

  @override
  Future<Semester?> getSemesterById(int localId) async => null;

  @override
  Future<Semester?> getActiveSemester() async => null;

  @override
  Future<List<Semester>> getAllSemesters() async => const <Semester>[];

  @override
  Future<bool> hasActiveSemester() async => false;
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<UserPreferences?> getPreferences(String id) async =>
      const UserPreferences(
        id: 'local_user',
        themeMode: 'system',
        defaultAttendanceTarget: 75.0,
        classReminderOffset: 15,
        enableNotifications: true,
        enableAttendanceWarnings: true,
        weeklyReportEnabled: true,
      );

  @override
  Future<void> savePreferences(UserPreferences preferences) async {}

  @override
  Stream<UserPreferences?> watchPreferences(String userId) =>
      const Stream<UserPreferences?>.empty();
}

class _FakeSubjectRepository implements SubjectRepository {
  @override
  Future<void> createSubject(Subject subject) async {}

  @override
  Future<void> deleteSubject(int id) async {}

  @override
  Future<Subject?> getSubjectById(int id) async => null;

  @override
  Future<List<Subject>> getSubjectsBySemester(int semesterId) async =>
      const <Subject>[];

  @override
  Future<void> updateSubject(Subject subject) async {}

  @override
  Stream<void> watchSubjects(int semesterId) => const Stream<void>.empty();
}

class _NoOpWidgetRefreshService extends Fake implements WidgetRefreshService {
  @override
  Future<void> refreshAllWidgets() async {}
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

Future<void> _pumpMicrotasksAndEventQueue() async {
  await Future<void>.delayed(const Duration(milliseconds: 25));
}

Future<int> _seedSemesterAndSubject(Isar isar, DateTime now) {
  return isar.writeAsync<int>((db) {
    final semester = SemesterLocal()
      ..id = db.semesterLocals.autoIncrement()
      ..name = 'Test Semester'
      ..startDate = DateTime.utc(now.year, now.month, now.day)
          .subtract(const Duration(days: 30))
      ..endDate = DateTime.utc(now.year, now.month, now.day)
          .add(const Duration(days: 120))
      ..requiredAttendanceRate = 75.0
      ..createdAt = now.toUtc()
      ..updatedAt = now.toUtc();
    db.semesterLocals.put(semester);

    final subject = SubjectLocal()
      ..id = db.subjectLocals.autoIncrement()
      ..semesterId = semester.id
      ..name = 'Distributed Systems'
      ..code = 'CS501'
      ..credits = 4
      ..attendanceTarget = 75.0
      ..color = '#2563EB'
      ..type = 'THEORY'
      ..createdAt = now.toUtc()
      ..updatedAt = now.toUtc();
    db.subjectLocals.put(subject);
    return subject.id;
  });
}

Future<void> _writeRealEvent(
  Isar isar,
  int subjectId,
  DateTime tomorrow,
  DateTime now,
) async {
  await isar.writeAsync((db) {
    final occ = DailyScheduleOccurrenceLocal()
      ..id = db.dailyScheduleOccurrenceLocals.autoIncrement()
      ..subjectId = subjectId
      ..date = DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day)
      ..title = 'Distributed Systems'
      ..startTime = '10:00'
      ..endTime = '11:00'
      ..type = 'REGULAR_CLASS'
      ..status = 'UPCOMING'
      ..createdFrom = 'WEEKLY_RULE'
      ..createdAt = now.toUtc()
      ..updatedAt = now.toUtc();
    occ.slotKey = computeSlotKeyForLocal(occ);
    db.dailyScheduleOccurrenceLocals.put(occ);
  });
}

Future<void> _writeRealAttendanceRecord(
  Isar isar,
  int subjectId,
  DateTime now,
) async {
  await isar.writeAsync((db) {
    final absentRecord = AttendanceRecordLocal()
      ..id = db.attendanceRecordLocals.autoIncrement()
      ..eventId = 1
      ..subjectId = subjectId
      ..status = 'ABSENT'
      ..markedAt = now
      ..createdAt = now.toUtc()
      ..updatedAt = now.toUtc();
    db.attendanceRecordLocals.put(absentRecord);
  });
}

Future<void> _writeRealAcademicEvent(
  Isar isar,
  DateTime eventDay,
  DateTime now,
) async {
  await isar.writeAsync((db) {
    final academicEvent = AcademicEventLocal()
      ..id = db.academicEventLocals.autoIncrement()
      ..title = 'Midterm Exam'
      ..description = 'Chapters 1-5'
      ..date = DateTime.utc(eventDay.year, eventDay.month, eventDay.day)
      ..startTime = '09:00'
      ..endTime = '11:00'
      ..type = 'EXAM'
      ..createdAt = now.toUtc()
      ..updatedAt = now.toUtc();
    db.academicEventLocals.put(academicEvent);
  });
}

Future<void> _writeRealTimetableTemplate(
  Isar isar,
  int subjectId,
  int weekday,
  DateTime now,
) async {
  await isar.writeAsync((db) {
    final rule = WeeklyScheduleRuleLocal()
      ..id = db.weeklyScheduleRuleLocals.autoIncrement()
      ..subjectId = subjectId
      ..dayOfWeek = weekday
      ..startTime = '10:00'
      ..endTime = '11:00'
      ..room = 'Hall A'
      ..type = 'THEORY'
      ..isActive = true
      ..createdAt = now.toUtc()
      ..updatedAt = now.toUtc();
    db.weeklyScheduleRuleLocals.put(rule);
  });
}

Future<void> _writeRealScheduleException(
  Isar isar,
  int subjectId,
  DateTime tomorrow,
  DateTime now,
) async {
  await isar.writeAsync((db) {
    final exception = ScheduleExceptionLocal()
      ..id = db.scheduleExceptionLocals.autoIncrement()
      ..date = DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day)
      ..subjectId = subjectId
      ..type = 'HOLIDAY'
      ..title = 'Founder Day'
      ..createdAt = now.toUtc()
      ..updatedAt = now.toUtc();
    db.scheduleExceptionLocals.put(exception);
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BUG-003: Notification lifecycle & listener retention', () {
    test('1. Registers all five Isar collection listeners exactly once',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final spyService = _SpyNotificationService();
      final spyDb = _SpyNotificationDatabase();
      final scheduler = _CountingNotificationScheduler(spyDb, spyService);
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) async => fakeIsar),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationSchedulerProvider.overrideWith((ref) {
            ref.watch(isarProvider);
            ref.onDispose(scheduler.dispose);
            return scheduler;
          }),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue(spyStreams.build),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationInitializerProvider.future);

      final manager = container.read(notificationLifecycleManagerProvider);
      expect(manager.isInitialized, isTrue);
      expect(manager.activeListenerCount, equals(5));
      expect(
        manager.activeListenerCollections,
        equals(watchedNotificationCollections),
      );
      expect(spyStreams.totalListenCount, equals(5));
      for (final collectionName in watchedNotificationCollections) {
        expect(spyStreams.listenCounts[collectionName], equals(1));
      }
      expect(spyService.initializeCalls, equals(1));
      expect(scheduler.rescheduleAllCalls, equals(1));
    });

    test(
        '2. Listeners remain active after one-time container.read initialization',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final spyService = _SpyNotificationService();
      final spyDb = _SpyNotificationDatabase();
      final scheduler = _CountingNotificationScheduler(spyDb, spyService);
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) async => fakeIsar),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationSchedulerProvider.overrideWith((ref) {
            ref.watch(isarProvider);
            ref.onDispose(scheduler.dispose);
            return scheduler;
          }),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue(spyStreams.build),
        ],
      );
      addTearDown(container.dispose);

      // Simulate main.dart one-shot read without any active watch()er.
      await container.read(notificationInitializerProvider.future);
      await _pumpMicrotasksAndEventQueue();

      final manager = container.read(notificationLifecycleManagerProvider);
      expect(manager.isInitialized, isTrue);
      expect(manager.activeListenerCount, equals(5));
      expect(spyStreams.totalCancelCount, equals(0));
      expect(scheduler.isDisposed, isFalse);
      expect(scheduler.rescheduleAllCalls, equals(1));

      // Verify every single one of the 5 listeners still reacts post-boot.
      for (var i = 0; i < watchedNotificationCollections.length; i++) {
        final collectionName = watchedNotificationCollections[i];
        spyStreams.emit(collectionName);
        await _pumpMicrotasksAndEventQueue();
        expect(scheduler.rescheduleAllCalls, equals(i + 2));
      }
    });

    test(
        '3. Real Isar database changes across all five collections trigger notification updates',
        () async {
      final libPath = await _resolveIsarNativeLibraryPath();
      if (libPath == null) {
        return;
      }

      await Isar.initialize(libPath);
      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_notif_lifecycle_');
      Isar? openedIsar;

      try {
        final spyService = _SpyNotificationService();
        late _CountingNotificationScheduler countingScheduler;
        final uniqueDbName =
            'attendiq_notif_lifecycle_${DateTime.now().microsecondsSinceEpoch}';

        final container = ProviderContainer(
          overrides: [
            databaseDirectoryResolverProvider.overrideWithValue(
              () async => tempDir.path,
            ),
            isarOpenerProvider.overrideWithValue(({
              required schemas,
              required name,
              required directory,
            }) {
              return defaultIsarOpener(
                schemas: schemas,
                name: uniqueDbName,
                directory: directory,
              );
            }),
            notificationServiceProvider.overrideWithValue(spyService),
            notificationSchedulerProvider.overrideWith((ref) {
              final isar = ref.watch(isarProvider).requireValue;
              countingScheduler = _CountingNotificationScheduler(
                IsarNotificationDatabaseImpl(isar),
                spyService,
              );
              ref.onDispose(countingScheduler.dispose);
              return countingScheduler;
            }),
          ],
        );

        final bootstrap = await initializeAppStartup(container);
        expect(bootstrap.databaseReady, isTrue);
        expect(bootstrap.notificationsReady, isTrue);

        final isar = container.read(isarProvider).requireValue;
        openedIsar = isar;

        final manager = container.read(notificationLifecycleManagerProvider);
        expect(manager.activeListenerCount, equals(5));
        expect(countingScheduler.rescheduleAllCalls, equals(1));
        expect(countingScheduler.completedReschedulePasses, equals(1));

        // Seed active semester and subject (non-watched collections).
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final subjectId = await _seedSemesterAndSubject(isar, now);

        // 1) Write EventLocal -> watchLazy triggers reminder + weekly report.
        await _writeRealEvent(isar, subjectId, tomorrow, now);
        await countingScheduler.waitForCompletedPasses(2);

        expect(countingScheduler.rescheduleAllCalls, equals(2));
        expect(
          spyService.scheduled.any(
            (n) =>
                n.type == NotificationType.CLASS_REMINDER.toShortString() &&
                n.title.contains('Distributed Systems'),
          ),
          isTrue,
        );

        // 2) Write AttendanceRecordLocal -> watchLazy triggers risk alert.
        await _writeRealAttendanceRecord(isar, subjectId, now);
        await countingScheduler.waitForCompletedPasses(3);

        expect(countingScheduler.rescheduleAllCalls, equals(3));
        expect(
          spyService.scheduled.any(
            (n) =>
                n.type ==
                    NotificationType.LOW_ATTENDANCE_ALERT.toShortString() &&
                n.title.contains('Distributed Systems'),
          ),
          isTrue,
        );

        // 3) Write AcademicEventLocal -> watchLazy triggers academic reminder.
        final eventDay = now.add(const Duration(days: 3));
        await _writeRealAcademicEvent(isar, eventDay, now);
        await countingScheduler.waitForCompletedPasses(4);

        expect(countingScheduler.rescheduleAllCalls, equals(4));
        expect(
          spyService.scheduled.any(
            (n) =>
                n.type == NotificationType.CLASS_REMINDER.toShortString() &&
                n.body.contains('Midterm Exam'),
          ),
          isTrue,
        );

        // 4) Write TimetableTemplateLocal -> watchLazy triggers rescheduleAll.
        await _writeRealTimetableTemplate(
          isar,
          subjectId,
          tomorrow.weekday,
          now,
        );
        await countingScheduler.waitForCompletedPasses(5);

        expect(countingScheduler.rescheduleAllCalls, equals(5));
        expect(
          spyService.scheduled.any((n) => n.body.contains('Hall A')),
          isTrue,
        );

        // 5) Write ScheduleExceptionLocal -> watchLazy triggers rescheduleAll.
        await _writeRealScheduleException(isar, subjectId, tomorrow, now);
        await countingScheduler.waitForCompletedPasses(6);

        expect(countingScheduler.rescheduleAllCalls, equals(6));

        // Clean container disposal cancels listeners before closing Isar.
        container.dispose();
        openedIsar = null;
        expect(isar.isOpen, isFalse);
        expect(manager.isDisposed, isTrue);
        expect(manager.activeListenerCount, equals(0));
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
        '4. Prevents duplicate initialization across concurrent and repeated reads',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final spyService = _SpyNotificationService()
        ..initBlocker = Completer<void>();
      final spyDb = _SpyNotificationDatabase();
      final scheduler = _CountingNotificationScheduler(spyDb, spyService);
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) async => fakeIsar),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationSchedulerProvider.overrideWith((ref) {
            ref.watch(isarProvider);
            ref.onDispose(scheduler.dispose);
            return scheduler;
          }),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue(spyStreams.build),
        ],
      );
      addTearDown(container.dispose);

      final future1 = container.read(notificationInitializerProvider.future);
      final future2 = container.read(notificationInitializerProvider.future);
      spyService.initBlocker!.complete();
      await Future.wait(<Future<void>>[future1, future2]);

      // Subsequent reads or startup calls must be idempotent no-ops.
      await container.read(notificationInitializerProvider.future);
      final secondBootstrap = await initializeAppStartup(container);
      expect(secondBootstrap.databaseReady, isTrue);
      expect(secondBootstrap.notificationsReady, isTrue);

      final manager = container.read(notificationLifecycleManagerProvider);
      expect(spyService.initializeCalls, equals(1));
      expect(spyStreams.totalListenCount, equals(5));
      expect(manager.initializationCount, equals(1));
      expect(scheduler.rescheduleAllCalls, equals(1));
    });

    test(
        '4b. LocalNotificationServiceImpl.initialize is single-flight and recoverable on error',
        () async {
      const channel =
          MethodChannel('dexterous.com/flutter/local_notifications');
      var pluginInitCalls = 0;
      var channelCreationCalls = 0;
      var shouldFail = true;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'initialize') {
          pluginInitCalls++;
          if (shouldFail) {
            throw PlatformException(code: 'INIT_ERR', message: 'Plugin busy');
          }
          return true;
        }
        if (call.method == 'createNotificationChannel') {
          channelCreationCalls++;
          return null;
        }
        return null;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      final service = LocalNotificationServiceImpl();

      // First attempt fails explicitly and leaves isInitialized == false.
      await expectLater(
        service.initialize(),
        throwsA(isA<PlatformException>()),
      );
      expect(service.isInitialized, isFalse);
      expect(pluginInitCalls, equals(1));

      // Retry succeeds and subsequent concurrent/repeated calls are no-ops.
      shouldFail = false;
      await Future.wait(<Future<void>>[
        service.initialize(),
        service.initialize(),
      ]);
      await service.initialize();

      expect(service.isInitialized, isTrue);
      expect(pluginInitCalls, equals(2));
      expect(channelCreationCalls, equals(4));
    });

    test(
        '5. Cancels all 5 subscriptions on container disposal, invalidation, and mid-init teardown',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final spyService = _SpyNotificationService();
      final spyDb = _SpyNotificationDatabase();
      final scheduler = _CountingNotificationScheduler(spyDb, spyService);
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) async => fakeIsar),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationSchedulerProvider.overrideWith((ref) {
            ref.watch(isarProvider);
            ref.onDispose(scheduler.dispose);
            return scheduler;
          }),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue(spyStreams.build),
        ],
      );

      await container.read(notificationInitializerProvider.future);
      final manager = container.read(notificationLifecycleManagerProvider);
      expect(manager.activeListenerCount, equals(5));
      expect(spyStreams.totalCancelCount, equals(0));

      // Invalidation cancels all 5 subscriptions before re-subscribing.
      container.invalidate(notificationInitializerProvider);
      await _pumpMicrotasksAndEventQueue();
      expect(spyStreams.totalCancelCount, equals(5));
      expect(manager.activeListenerCount, equals(0));

      // Re-reading subscribes cleanly again.
      await container.read(notificationInitializerProvider.future);
      expect(spyStreams.totalListenCount, equals(10));
      expect(manager.activeListenerCount, equals(5));

      // Container disposal cancels all 5 subscriptions and stops reacting.
      container.dispose();
      await _pumpMicrotasksAndEventQueue();
      expect(spyStreams.totalCancelCount, equals(10));
      expect(manager.isDisposed, isTrue);
      expect(manager.activeListenerCount, equals(0));
      expect(scheduler.isDisposed, isTrue);

      final callsBeforePostDisposeEmit = scheduler.rescheduleAllCalls;
      for (final collectionName in watchedNotificationCollections) {
        spyStreams.emit(collectionName);
      }
      await _pumpMicrotasksAndEventQueue();
      expect(scheduler.rescheduleAllCalls, equals(callsBeforePostDisposeEmit));
    });

    test(
        '5b. Disposing container mid-initialization does not leak subscriptions',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final blocker = Completer<void>();
      final spyService = _SpyNotificationService()..initBlocker = blocker;
      final spyDb = _SpyNotificationDatabase();
      final scheduler = _CountingNotificationScheduler(spyDb, spyService);
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) async => fakeIsar),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationSchedulerProvider.overrideWith((ref) {
            ref.watch(isarProvider);
            ref.onDispose(scheduler.dispose);
            return scheduler;
          }),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue(spyStreams.build),
        ],
      );

      final initFuture = container.read(notificationInitializerProvider.future);
      await Future<void>.delayed(Duration.zero);
      expect(spyService.initializeCalls, equals(1));

      container.dispose();
      blocker.complete();
      await initFuture;

      expect(spyStreams.totalListenCount, equals(0));
      expect(scheduler.rescheduleAllCalls, equals(0));
    });

    test(
        '6. Initializes notifications strictly after Isar opens and awaits loading Isar',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final isarGate = Completer<Isar>();
      final events = <String>[];
      final spyService = _SpyNotificationService();
      final spyDb = _SpyNotificationDatabase();
      final scheduler = _CountingNotificationScheduler(spyDb, spyService);
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) async {
            final isar = await isarGate.future;
            events.add('isar_ready');
            return isar;
          }),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationSchedulerProvider.overrideWithValue(scheduler),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue((isar) {
            events.add('listeners_registered');
            return spyStreams.build(isar);
          }),
        ],
      );
      addTearDown(container.dispose);

      // Accessing real scheduler while Isar is loading fails explicitly.
      final uninitializedContainer = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) => Completer<Isar>().future),
        ],
      );
      addTearDown(uninitializedContainer.dispose);
      expect(
        () => uninitializedContainer.read(notificationSchedulerProvider),
        throwsStateError,
      );

      // Reading notificationInitializer while Isar is loading waits for Isar.
      final initFuture = container.read(notificationInitializerProvider.future);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, isEmpty);
      expect(spyService.initializeCalls, equals(0));

      isarGate.complete(fakeIsar);
      await initFuture;

      expect(events, equals(<String>['isar_ready', 'listeners_registered']));
      expect(spyService.initializeCalls, equals(1));
      expect(scheduler.rescheduleAllCalls, equals(1));
    });

    test(
        '7a. Failed Isar startup skips notifications and retry via initializeAppStartup recovers cleanly',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final spyService = _SpyNotificationService();
      final spyDb = _SpyNotificationDatabase();
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);
      var attempt = 0;

      final container = ProviderContainer(
        overrides: [
          databaseDirectoryResolverProvider.overrideWithValue(
            () async => '/app/docs',
          ),
          isarOpenerProvider.overrideWithValue(({
            required schemas,
            required name,
            required directory,
          }) {
            attempt++;
            if (attempt == 1) {
              throw const DatabaseException(
                'Temporary storage lock',
                'DB_LOCKED',
              );
            }
            return fakeIsar;
          }),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue(spyStreams.build),
          notificationSchedulerProvider.overrideWith((ref) {
            final isar = ref.watch(isarProvider).requireValue;
            expect(identical(isar, fakeIsar), isTrue);
            return _CountingNotificationScheduler(spyDb, spyService);
          }),
        ],
      );
      addTearDown(container.dispose);

      // First boot attempt fails on Isar.
      final firstResult = await initializeAppStartup(container);
      expect(firstResult.databaseReady, isFalse);
      expect(firstResult.notificationsReady, isFalse);
      expect(spyService.initializeCalls, equals(0));
      expect(spyStreams.totalListenCount, equals(0));

      // Retry after storage lock clears -> Isar and notifications recover.
      final retryResult = await initializeAppStartup(container);
      expect(retryResult.databaseReady, isTrue);
      expect(retryResult.notificationsReady, isTrue);
      expect(attempt, equals(2));
      expect(spyService.initializeCalls, equals(1));
      expect(spyStreams.totalListenCount, equals(5));
      expect(
        container
            .read(notificationLifecycleManagerProvider)
            .activeListenerCount,
        equals(5),
      );
    });

    testWidgets(
        '7b. UI Retry after failed initializeAppStartup initializes notifications and listeners when router shell mounts',
        (tester) async {
      final fakeIsar = _TrackingFakeIsar();
      final spyService = _SpyNotificationService();
      final spyDb = _SpyNotificationDatabase();
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);
      late _CountingNotificationScheduler scheduler;
      var attempt = 0;

      final container = ProviderContainer(
        overrides: [
          databaseDirectoryResolverProvider.overrideWithValue(() async {
            attempt++;
            if (attempt == 1) {
              throw const DatabaseException('Disk busy', 'DB_OPEN_FAILED');
            }
            return '/recovered/docs';
          }),
          isarOpenerProvider.overrideWithValue(
            ({
              required schemas,
              required name,
              required directory,
            }) =>
                fakeIsar,
          ),
          isarMigrationRunnerProvider.overrideWithValue((_) async {}),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue(spyStreams.build),
          notificationSchedulerProvider.overrideWith((ref) {
            ref.watch(isarProvider).requireValue;
            scheduler = _CountingNotificationScheduler(spyDb, spyService);
            ref.onDispose(scheduler.dispose);
            return scheduler;
          }),
          semesterRepositoryProvider
              .overrideWithValue(_FakeSemesterRepository()),
          settingsRepositoryProvider
              .overrideWithValue(_FakeSettingsRepository()),
          subjectRepositoryProvider.overrideWithValue(_FakeSubjectRepository()),
          widgetRefreshServiceProvider
              .overrideWithValue(_NoOpWidgetRefreshService()),
        ],
      );
      addTearDown(container.dispose);

      // Boot fails on Isar -> notifications are skipped.
      final startupFailure = await initializeAppStartup(container);
      expect(startupFailure.databaseReady, isFalse);
      expect(spyService.initializeCalls, equals(0));
      expect(spyStreams.totalListenCount, equals(0));

      await tester.pumpWidget(
        AttendIQRootScope(
          container: container,
          child: const AttendIQApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseStartupErrorPage), findsOneWidget);
      expect(spyService.initializeCalls, equals(0));
      expect(spyStreams.totalListenCount, equals(0));

      // Tap Retry -> Isar succeeds -> router shell triggers notification init.
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.byType(DatabaseStartupErrorPage), findsNothing);
      expect(attempt, equals(2));
      expect(spyService.initializeCalls, equals(1));
      expect(spyStreams.totalListenCount, equals(5));
      final manager = container.read(notificationLifecycleManagerProvider);
      expect(manager.activeListenerCount, equals(5));
      expect(scheduler.rescheduleAllCalls, equals(1));

      // Unmount AttendIQRootScope -> cancels all 5 listeners cleanly.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(spyStreams.totalCancelCount, equals(5));
      expect(manager.isDisposed, isTrue);
      expect(manager.activeListenerCount, equals(0));
    });

    test(
        '7c. Explicit notification initialization failure leaves zero leaked listeners and allows retry',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final spyService = _SpyNotificationService()
        ..shouldThrowOnInitialize = true;
      final spyDb = _SpyNotificationDatabase();
      final scheduler = _CountingNotificationScheduler(spyDb, spyService);
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) async => fakeIsar),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationSchedulerProvider.overrideWith((ref) {
            ref.watch(isarProvider);
            ref.onDispose(scheduler.dispose);
            return scheduler;
          }),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue(spyStreams.build),
        ],
      );
      addTearDown(container.dispose);

      final firstAttempt = await initializeAppStartup(container);
      expect(firstAttempt.databaseReady, isTrue);
      expect(firstAttempt.notificationsReady, isFalse);
      expect(firstAttempt.notificationError, isA<PlatformException>());
      expect(container.read(notificationInitializerProvider).hasError, isTrue);

      final manager = container.read(notificationLifecycleManagerProvider);
      expect(manager.isInitialized, isFalse);
      expect(manager.lastError, isA<PlatformException>());
      expect(manager.activeListenerCount, equals(0));
      expect(spyStreams.totalListenCount, equals(0));

      // Retry after plugin issue resolves -> succeeds cleanly.
      spyService.shouldThrowOnInitialize = false;
      final retryAttempt = await initializeAppStartup(container);
      expect(retryAttempt.databaseReady, isTrue);
      expect(retryAttempt.notificationsReady, isTrue);
      expect(retryAttempt.notificationError, isNull);
      expect(manager.isInitialized, isTrue);
      expect(manager.lastError, isNull);
      expect(manager.activeListenerCount, equals(5));
      expect(spyStreams.totalListenCount, equals(5));
    });

    test(
        '8. Serializes and coalesces concurrent rescheduleAll calls without duplicate scheduling',
        () async {
      final spyService = _SpyNotificationService();
      final spyDb = _SpyNotificationDatabase();
      final now = DateTime(2026, 7, 17, 9, 0);

      spyDb.activeSemester = SemesterLocal()
        ..id = 1
        ..name = 'Fall 2026'
        ..startDate = DateTime(2026, 7, 1)
        ..endDate = DateTime(2026, 12, 31)
        ..requiredAttendanceRate = 75.0
        ..createdAt = now
        ..updatedAt = now;

      spyDb.subjects.add(
        SubjectLocal()
          ..id = 1
          ..semesterId = 1
          ..name = 'Compilers'
          ..code = 'CS410'
          ..credits = 4
          ..attendanceTarget = 75.0
          ..color = '#10B981'
          ..type = 'THEORY'
          ..createdAt = now
          ..updatedAt = now,
      );

      spyDb.occurrences.add(
        DailyScheduleOccurrenceLocal()
          ..id = 101
          ..subjectId = 1
          ..date = DateTime.utc(2026, 7, 17)
          ..title = 'Compilers'
          ..startTime = '10:00'
          ..endTime = '11:00'
          ..type = 'REGULAR_CLASS'
          ..status = 'UPCOMING'
          ..createdFrom = 'WEEKLY_RULE'
          ..createdAt = now
          ..updatedAt = now,
      );

      final scheduler = NotificationScheduler(spyDb, spyService);
      spyDb.getEventsBlocker = Completer<void>();

      // Fire 3 concurrent rescheduleAll calls (simulating listener + controller race).
      final f1 = scheduler.rescheduleAll(customNow: now);
      final f2 = scheduler.rescheduleAll(customNow: now);
      final f3 = scheduler.rescheduleAll(customNow: now);

      await Future<void>.delayed(Duration.zero);
      expect(spyDb.getEventsCalls, equals(1));
      expect(spyDb.maxConcurrentRescheduleReads, equals(1));

      // Release blocker -> f2 and f3 coalesce into 1 trailing sequential pass.
      spyDb.getEventsBlocker!.complete();
      await Future.wait(<Future<void>>[f1, f2, f3]);

      expect(spyDb.maxConcurrentRescheduleReads, equals(1));
      // Each sequential rescheduleAll pass queries getEvents twice
      // (rescheduleRollingWindow + scheduleWeeklyReport); 2 passes = 4 calls.
      expect(spyDb.getEventsCalls, equals(4));

      // Exactly 1 class reminder + 1 weekly report (no duplicate class reminders!).
      final classReminders = spyDb.notifications
          .where(
            (n) => n.type == NotificationType.CLASS_REMINDER.toShortString(),
          )
          .toList();
      final scheduledClassReminders = spyService.scheduled
          .where(
            (n) => n.type == NotificationType.CLASS_REMINDER.toShortString(),
          )
          .toList();
      expect(classReminders, hasLength(1));
      expect(scheduledClassReminders, hasLength(1));
    });

    test(
        '8b. Simultaneous events across all 5 watched streams coalesce into a single reschedule',
        () async {
      final fakeIsar = _TrackingFakeIsar();
      final spyService = _SpyNotificationService();
      final spyDb = _SpyNotificationDatabase();
      final scheduler = _CountingNotificationScheduler(spyDb, spyService);
      final spyStreams = _SpyCollectionStreams();
      addTearDown(spyStreams.dispose);

      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWith((ref) async => fakeIsar),
          notificationServiceProvider.overrideWithValue(spyService),
          notificationSchedulerProvider.overrideWith((ref) {
            ref.watch(isarProvider);
            ref.onDispose(scheduler.dispose);
            return scheduler;
          }),
          notificationCollectionStreamsBuilderProvider
              .overrideWithValue(spyStreams.build),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationInitializerProvider.future);
      expect(scheduler.rescheduleAllCalls, equals(1));

      // Burst emit on all 5 collections synchronously.
      for (final collectionName in watchedNotificationCollections) {
        spyStreams.emit(collectionName);
      }
      await _pumpMicrotasksAndEventQueue();

      final manager = container.read(notificationLifecycleManagerProvider);
      expect(manager.rescheduleTriggerCount, equals(1));
      expect(scheduler.rescheduleAllCalls, equals(2));
    });

    test(
        '9. Preserves LocalNotificationServiceImpl scheduling/cancellation and TaskNotificationScheduler behavior',
        () async {
      const channel =
          MethodChannel('dexterous.com/flutter/local_notifications');
      final methodCalls = <String>[];
      var simulateExactSecurityException = true;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        methodCalls.add(call.method);
        if (call.method == 'initialize') return true;
        if (call.method == 'zonedSchedule' && simulateExactSecurityException) {
          simulateExactSecurityException = false;
          throw PlatformException(
            code: 'exact_alarms_not_permitted',
            message: 'SecurityException',
          );
        }
        if (call.method == 'requestNotificationsPermission') return true;
        return null;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(notificationServiceProvider);
      await service.initialize();
      expect(await service.requestPermissions(), isTrue);

      final taskScheduler = container.read(taskNotificationSchedulerProvider);
      final futureDue = DateTime.now().add(const Duration(days: 2));
      final task = AcademicTask(
        id: 7,
        title: 'Lab Viva',
        taskType: TaskType.ASSIGNMENT,
        startDate: DateTime.now(),
        dueDate: futureDue,
        priority: TaskPriority.HIGH,
        status: TaskStatus.PENDING,
        reminder: TaskReminder.HOURS_1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await taskScheduler.scheduleTaskNotification(task, subjectName: 'OS');
      await service.cancelNotification(800007);
      await service.cancelAllNotifications();

      expect(methodCalls, contains('initialize'));
      expect(methodCalls, contains('createNotificationChannel'));
      expect(
        methodCalls.where((m) => m == 'zonedSchedule').length,
        equals(2), // Initial exact attempt + inexact fallback
      );
      expect(methodCalls, contains('cancel'));
      expect(methodCalls, contains('cancelAll'));
    });
  });
}
