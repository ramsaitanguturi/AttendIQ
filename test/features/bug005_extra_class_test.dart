import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/errors/app_exception.dart';
import 'package:attend_iq/core/event_generator/data/models/event_local.dart';
import 'package:attend_iq/core/notifications/providers/notification_providers.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:attend_iq/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:attend_iq/features/attendance/presentation/pages/subject_details_page.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/data/models/weekly_schedule_rule_local.dart';
import 'package:attend_iq/features/timetable/data/utils/occurrence_identity.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/academic_calendar_controller.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/weekly_schedule_view_controller.dart';
import 'package:attend_iq/features/timetable/presentation/widgets/add_extra_class_dialog.dart';
import 'package:attend_iq/features/timetable/presentation/widgets/date_details_bottom_sheet.dart';
import 'package:attend_iq/features/timetable/presentation/widgets/today_schedule_card.dart';
import 'package:attend_iq/features/widgets/services/widget_refresh_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

class _NoOpWidgetRefreshService extends Fake implements WidgetRefreshService {
  @override
  Future<void> refreshAllWidgets() async {}
}

class _NoOpNotificationService extends Fake implements NotificationService {
  @override
  Future<void> initialize() async {}
}

class _DelayedFakeAttendanceRepository implements AttendanceRepository {
  int saveExtraClassCallCount = 0;
  final Completer<void> blocker = Completer<void>();

  @override
  Future<DailyScheduleOccurrence> saveExtraClassWithAttendance({
    int? occurrenceId,
    required int subjectId,
    required DateTime date,
    String? subjectTitle,
    String? startTime,
    String? endTime,
    String? reason,
    AttendanceStatus? status,
    bool autoAllocateSlot = false,
  }) async {
    saveExtraClassCallCount++;
    await blocker.future;
    final now = DateTime.now().toUtc();
    return DailyScheduleOccurrence(
      id: 42,
      serverId: 'occ-42',
      date: normalizeUtcDate(date),
      subjectId: subjectId,
      title: subjectTitle ?? 'Algorithms',
      startTime: startTime ?? '14:00',
      endTime: endTime ?? '15:00',
      type: OccurrenceType.extraClass,
      status: OccurrenceStatus.present,
      createdFrom: OccurrenceCreatedFrom.manual,
      reason: reason,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceForSubject(
    int subjectId,
  ) async =>
      const [];

  @override
  Future<AttendanceRecord?> getAttendanceForOccurrence(
    int occurrenceId,
  ) async =>
      null;

  @override
  Future<AttendanceRecord?> getAttendanceForOccurrenceAnyStatus(
    int occurrenceId,
  ) async =>
      null;

  @override
  Future<AttendanceRecord?> getAttendanceForEvent(int eventId) async => null;

  @override
  Future<AttendanceRecord?> getAttendanceForEventAnyStatus(
    int eventId,
  ) async =>
      null;

  @override
  Future<void> saveAttendanceRecord(AttendanceRecord record) async {}

  @override
  Future<void> deleteAttendanceRecord(int id) async {}

  @override
  Stream<void> watchAttendance(int subjectId) => const Stream.empty();

  @override
  Future<void> updateEventStatus(int occurrenceId, String status) async {}
}

// Top-level isolate-safe failure hooks for Isar 4 writeAsync tests.
void _failOccurrencePutInTx(Isar _) {
  throw StateError('Simulated occurrence persistence failure');
}

void _failAttendancePutInTx(Isar _) {
  throw StateError('Simulated attendance persistence failure');
}

void _failCommitInTx(Isar _) {
  throw StateError('Simulated transaction commit failure');
}

Future<String?> _resolveIsarNativeLibraryPath() async {
  final packageConfigFile = File('.dart_tool/package_config.json');
  if (!packageConfigFile.existsSync()) return null;

  final decoded = jsonDecode(await packageConfigFile.readAsString())
      as Map<String, dynamic>;
  final packages = decoded['packages'] as List<dynamic>? ?? const [];
  Map<String, dynamic>? isarPackage;
  for (final pkg in packages) {
    if (pkg is Map<String, dynamic> && pkg['name'] == 'isar_flutter_libs') {
      isarPackage = pkg;
      break;
    }
  }
  if (isarPackage == null) return null;

  final rawRootUri = isarPackage['rootUri'] as String?;
  if (rawRootUri == null || rawRootUri.isEmpty) return null;

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
        'attendiq_bug005_${DateTime.now().microsecondsSinceEpoch}_${dbSequence++}';
    return Isar.open(
      schemas: appIsarSchemas,
      name: name,
      directory: tempDir.path,
    );
  }

  ProviderContainer createRealIsarContainer(
    Isar isar, {
    List<Override> extraOverrides = const [],
  }) {
    return ProviderContainer(
      overrides: [
        isarProvider.overrideWith((ref) async => isar),
        notificationServiceProvider
            .overrideWithValue(_NoOpNotificationService()),
        widgetRefreshServiceProvider
            .overrideWithValue(_NoOpWidgetRefreshService()),
        ...extraOverrides,
      ],
    );
  }

  Future<void> pumpRealAsync(
    WidgetTester tester, {
    int ticks = 10,
    Duration step = const Duration(milliseconds: 25),
  }) async {
    for (var i = 0; i < ticks; i++) {
      await tester.runAsync(() => Future<void>.delayed(step));
      await tester.pump(step);
    }
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxTicks = 80,
    Duration step = const Duration(milliseconds: 25),
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      if (finder.evaluate().isNotEmpty) {
        await tester.pump(const Duration(milliseconds: 200));
        return;
      }
      await tester.runAsync(() => Future<void>.delayed(step));
      await tester.pump(step);
    }
    fail('Timed out waiting to find: $finder');
  }

  Future<void> pumpUntilGone(
    WidgetTester tester,
    Finder finder, {
    int maxTicks = 80,
    Duration step = const Duration(milliseconds: 25),
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      if (finder.evaluate().isEmpty) {
        await tester.pump(const Duration(milliseconds: 200));
        return;
      }
      await tester.runAsync(() => Future<void>.delayed(step));
      await tester.pump(step);
    }
    fail('Timed out waiting for widget to disappear: $finder');
  }

  ({
    int activeSemId,
    int archivedSemId,
    int draftSemId,
    int deletedSemId,
    int activeSubId,
    int secondActiveSubId,
    int deletedSubId,
    int archivedSubId,
    int draftSubId,
    int deletedSemSubId,
    DateTime semStart,
    DateTime semEnd,
  }) seedFixture(Isar isar) {
    final now = DateTime.now();
    final todayUtc = DateTime.utc(now.year, now.month, now.day);
    final semStart = todayUtc.subtract(const Duration(days: 15));
    final semEnd = todayUtc.add(const Duration(days: 45));

    late int activeSemId;
    late int archivedSemId;
    late int draftSemId;
    late int deletedSemId;
    late int activeSubId;
    late int secondActiveSubId;
    late int deletedSubId;
    late int archivedSubId;
    late int draftSubId;
    late int deletedSemSubId;

    isar.write((db) {
      final activeSem = SemesterLocal()
        ..id = db.semesterLocals.autoIncrement()
        ..serverId = 'sem-active'
        ..name = 'Fall 2026'
        ..startDate = semStart
        ..endDate = semEnd
        ..requiredAttendanceRate = 75.0
        ..status = SemesterLocal.statusActive
        ..isActive = true
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();
      final archivedSem = SemesterLocal()
        ..id = db.semesterLocals.autoIncrement()
        ..serverId = 'sem-archived'
        ..name = 'Spring 2026'
        ..startDate = semStart.subtract(const Duration(days: 150))
        ..endDate = semStart.subtract(const Duration(days: 10))
        ..requiredAttendanceRate = 75.0
        ..status = SemesterLocal.statusArchived
        ..isActive = false
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();
      final draftSem = SemesterLocal()
        ..id = db.semesterLocals.autoIncrement()
        ..serverId = 'sem-draft'
        ..name = 'Winter 2027'
        ..startDate = semEnd.add(const Duration(days: 10))
        ..endDate = semEnd.add(const Duration(days: 120))
        ..requiredAttendanceRate = 75.0
        ..status = SemesterLocal.statusDraft
        ..isActive = false
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();
      final deletedSem = SemesterLocal()
        ..id = db.semesterLocals.autoIncrement()
        ..serverId = 'sem-deleted'
        ..name = 'Deleted Sem'
        ..startDate = semStart.subtract(const Duration(days: 300))
        ..endDate = semStart.subtract(const Duration(days: 200))
        ..requiredAttendanceRate = 75.0
        ..status = SemesterLocal.statusArchived
        ..isActive = false
        ..isDeleted = true
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();

      db.semesterLocals.putAll(<SemesterLocal>[
        activeSem,
        archivedSem,
        draftSem,
        deletedSem,
      ]);
      activeSemId = activeSem.id;
      archivedSemId = archivedSem.id;
      draftSemId = draftSem.id;
      deletedSemId = deletedSem.id;

      final activeSub = SubjectLocal()
        ..id = db.subjectLocals.autoIncrement()
        ..serverId = 'sub-active-1'
        ..semesterId = activeSemId
        ..name = 'Algorithms'
        ..code = 'CS301'
        ..faculty = 'Dr. Ada'
        ..credits = 4
        ..attendanceTarget = 75.0
        ..color = '#2563EB'
        ..type = 'THEORY'
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();
      final secondActiveSub = SubjectLocal()
        ..id = db.subjectLocals.autoIncrement()
        ..serverId = 'sub-active-2'
        ..semesterId = activeSemId
        ..name = 'Operating Systems'
        ..code = 'CS302'
        ..credits = 4
        ..attendanceTarget = 75.0
        ..color = '#10B981'
        ..type = 'THEORY'
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();
      final deletedSub = SubjectLocal()
        ..id = db.subjectLocals.autoIncrement()
        ..serverId = 'sub-deleted'
        ..semesterId = activeSemId
        ..name = 'Deleted Course'
        ..code = 'DEL101'
        ..credits = 3
        ..attendanceTarget = 75.0
        ..color = '#EF4444'
        ..type = 'THEORY'
        ..isDeleted = true
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();
      final archivedSub = SubjectLocal()
        ..id = db.subjectLocals.autoIncrement()
        ..serverId = 'sub-archived'
        ..semesterId = archivedSemId
        ..name = 'Legacy Course'
        ..code = 'OLD201'
        ..credits = 3
        ..attendanceTarget = 75.0
        ..color = '#8B5CF6'
        ..type = 'THEORY'
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();
      final draftSub = SubjectLocal()
        ..id = db.subjectLocals.autoIncrement()
        ..serverId = 'sub-draft'
        ..semesterId = draftSemId
        ..name = 'Future Course'
        ..code = 'FUT401'
        ..credits = 3
        ..attendanceTarget = 75.0
        ..color = '#F59E0B'
        ..type = 'THEORY'
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();
      final deletedSemSub = SubjectLocal()
        ..id = db.subjectLocals.autoIncrement()
        ..serverId = 'sub-del-sem'
        ..semesterId = deletedSemId
        ..name = 'Orphan Sem Course'
        ..code = 'ORP100'
        ..credits = 3
        ..attendanceTarget = 75.0
        ..color = '#6B7280'
        ..type = 'THEORY'
        ..createdAt = now.toUtc()
        ..updatedAt = now.toUtc();

      db.subjectLocals.putAll(<SubjectLocal>[
        activeSub,
        secondActiveSub,
        deletedSub,
        archivedSub,
        draftSub,
        deletedSemSub,
      ]);
      activeSubId = activeSub.id;
      secondActiveSubId = secondActiveSub.id;
      deletedSubId = deletedSub.id;
      archivedSubId = archivedSub.id;
      draftSubId = draftSub.id;
      deletedSemSubId = deletedSemSub.id;
    });

    return (
      activeSemId: activeSemId,
      archivedSemId: archivedSemId,
      draftSemId: draftSemId,
      deletedSemId: deletedSemId,
      activeSubId: activeSubId,
      secondActiveSubId: secondActiveSubId,
      deletedSubId: deletedSubId,
      archivedSubId: archivedSubId,
      draftSubId: draftSubId,
      deletedSemSubId: deletedSemSubId,
      semStart: semStart,
      semEnd: semEnd,
    );
  }

  group(
      'BUG-005: Atomic Extra-Class Persistence, Validation & UI Consolidation',
      () {
    test(
      '1. Genuine atomic rollback on occurrence failure, attendance failure, and pre-commit failure without deleting pre-existing rows',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_bug005_atomic_');
        Isar? isar;
        try {
          isar = openTempIsar(tempDir);
          final fixture = seedFixture(isar);
          final ds = AttendanceLocalDataSourceImpl(isar);
          final targetDate = fixture.semStart.add(const Duration(days: 5));

          // 1a. Failure during occurrence write rolls back completely.
          await expectLater(
            () => ds.saveExtraClassWithAttendance(
              subjectId: fixture.activeSubId,
              date: targetDate,
              startTime: '14:00',
              endTime: '15:00',
              attendanceStatus: 'EXTRA_PRESENT',
              onBeforeOccurrencePut: _failOccurrencePutInTx,
            ),
            throwsA(isA<StateError>()),
          );
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(0));
          expect(isar.attendanceRecordLocals.count(), equals(0));

          // 1b. Failure during attendance write (after occurrence put!) rolls back BOTH puts.
          await expectLater(
            () => ds.saveExtraClassWithAttendance(
              subjectId: fixture.activeSubId,
              date: targetDate,
              startTime: '14:00',
              endTime: '15:00',
              attendanceStatus: 'EXTRA_PRESENT',
              onBeforeAttendancePut: _failAttendancePutInTx,
            ),
            throwsA(isA<StateError>()),
          );
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(0));
          expect(isar.attendanceRecordLocals.count(), equals(0));

          // 1c. Failure right before commit also rolls back BOTH puts.
          await expectLater(
            () => ds.saveExtraClassWithAttendance(
              subjectId: fixture.activeSubId,
              date: targetDate,
              startTime: '14:00',
              endTime: '15:00',
              attendanceStatus: 'EXTRA_ABSENT',
              onBeforeCommit: _failCommitInTx,
            ),
            throwsA(isA<StateError>()),
          );
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(0));
          expect(isar.attendanceRecordLocals.count(), equals(0));

          // 1d. Seed a valid extra class, then fail mid-update -> existing row & IDs preserved intact!
          final committed = await ds.saveExtraClassWithAttendance(
            subjectId: fixture.activeSubId,
            date: targetDate,
            startTime: '14:00',
            endTime: '15:00',
            reason: 'Initial reason',
            attendanceStatus: 'EXTRA_PRESENT',
          );
          final origOccId = committed.id;
          final origOccServerId = committed.serverId;
          final origAtt = isar.attendanceRecordLocals
              .where()
              .occurrenceIdEqualTo(origOccId)
              .findFirst()!;
          final origAttId = origAtt.id;
          final origAttServerId = origAtt.serverId;

          await expectLater(
            () => ds.saveExtraClassWithAttendance(
              occurrenceId: origOccId,
              subjectId: fixture.activeSubId,
              date: targetDate,
              startTime: '14:00',
              endTime: '15:00',
              reason: 'Failed overwrite',
              attendanceStatus: 'EXTRA_ABSENT',
              onBeforeAttendancePut: _failAttendancePutInTx,
            ),
            throwsA(isA<StateError>()),
          );

          final survivingOcc =
              isar.dailyScheduleOccurrenceLocals.get(origOccId)!;
          expect(survivingOcc.isDeleted, isFalse);
          expect(survivingOcc.serverId, equals(origOccServerId));
          expect(survivingOcc.status, equals('PRESENT'));
          expect(survivingOcc.reason, equals('Initial reason'));

          final survivingAtt = isar.attendanceRecordLocals.get(origAttId)!;
          expect(survivingAtt.isDeleted, isFalse);
          expect(survivingAtt.serverId, equals(origAttServerId));
          expect(survivingAtt.status, equals('EXTRA_PRESENT'));
          expect(isar.eventLocals.count(), equals(0));
        } finally {
          if (isar != null && isar.isOpen) isar.close();
          if (tempDir.existsSync()) await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      '2. Duplicate protection & identity protection: rejects occupied exact slot without occurrenceId, validates explicit occurrenceId, and rejects cross-subject attendance mismatch',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_bug005_guard_');
        Isar? isar;
        ProviderContainer? container;
        try {
          isar = openTempIsar(tempDir);
          final fixture = seedFixture(isar);
          container = createRealIsarContainer(isar);
          await container.read(isarProvider.future);
          final ds = AttendanceLocalDataSourceImpl(isar);
          final attCtrl = container.read(attendanceControllerProvider.notifier);
          final targetDate = fixture.semStart.add(const Duration(days: 6));

          // 2a. First creation succeeds.
          final created = await attCtrl.addExtraClass(
            date: targetDate,
            subjectId: fixture.activeSubId,
            subjectTitle: 'Algorithms',
            startTime: '16:00',
            endTime: '17:00',
            reason: 'First extra',
            initialStatus: AttendanceStatus.extraPresent,
          );
          expect(created.id, isNotNull);
          expect(created.id!, greaterThan(0));

          // 2b. Second creation without occurrenceId on exact same slot MUST reject & never silently reuse!
          await expectLater(
            () => attCtrl.addExtraClass(
              date: targetDate,
              subjectId: fixture.activeSubId,
              subjectTitle: 'Algorithms',
              startTime: '16:00',
              endTime: '17:00',
              reason: 'Duplicate attempt',
              initialStatus: AttendanceStatus.extraAbsent,
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'DUPLICATE_EXTRA_CLASS_SLOT',
              ),
            ),
          );
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(1));
          expect(
            isar.dailyScheduleOccurrenceLocals.get(created.id!)!.status,
            equals('PRESENT'),
          );

          // 2c. Explicit occurrenceId checks: reject non-existent, deleted, REGULAR_CLASS, and wrong subject.
          late int regularOccId;
          late int deletedExtraOccId;
          late int otherSubExtraOccId;
          isar.write((db) {
            final reg = DailyScheduleOccurrenceLocal()
              ..id = db.dailyScheduleOccurrenceLocals.autoIncrement()
              ..serverId = 'reg-1'
              ..date = targetDate
              ..subjectId = fixture.activeSubId
              ..title = 'Algorithms'
              ..startTime = '09:00'
              ..endTime = '10:00'
              ..type = 'REGULAR_CLASS'
              ..status = 'UPCOMING'
              ..createdFrom = 'WEEKLY_RULE'
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            final delExtra = DailyScheduleOccurrenceLocal()
              ..id = db.dailyScheduleOccurrenceLocals.autoIncrement()
              ..serverId = 'del-extra-1'
              ..date = targetDate
              ..subjectId = fixture.activeSubId
              ..title = 'Algorithms'
              ..startTime = '11:00'
              ..endTime = '12:00'
              ..type = 'EXTRA_CLASS'
              ..status = 'UPCOMING'
              ..createdFrom = 'MANUAL'
              ..isDeleted = true
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            final otherSubExtra = DailyScheduleOccurrenceLocal()
              ..id = db.dailyScheduleOccurrenceLocals.autoIncrement()
              ..serverId = 'other-extra-1'
              ..date = targetDate
              ..subjectId = fixture.secondActiveSubId
              ..title = 'Operating Systems'
              ..startTime = '12:00'
              ..endTime = '13:00'
              ..type = 'EXTRA_CLASS'
              ..status = 'UPCOMING'
              ..createdFrom = 'MANUAL'
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            db.dailyScheduleOccurrenceLocals.putAll([
              reg,
              delExtra,
              otherSubExtra,
            ]);
            regularOccId = reg.id;
            deletedExtraOccId = delExtra.id;
            otherSubExtraOccId = otherSubExtra.id;
          });

          for (final badOccId in [
            999999,
            deletedExtraOccId,
            regularOccId,
            otherSubExtraOccId,
          ]) {
            await expectLater(
              () => ds.saveExtraClassWithAttendance(
                occurrenceId: badOccId,
                subjectId: fixture.activeSubId,
                date: targetDate,
                startTime: '16:00',
                endTime: '17:00',
                attendanceStatus: 'EXTRA_PRESENT',
              ),
              throwsA(
                isA<ValidationException>().having(
                  (e) => e.code,
                  'code',
                  'INVALID_EXTRA_CLASS_OCCURRENCE',
                ),
              ),
            );
          }

          // 2d. Moving an existing extra class onto another active extra class's slot is rejected.
          final secondExtra = await attCtrl.addExtraClass(
            date: targetDate,
            subjectId: fixture.activeSubId,
            subjectTitle: 'Algorithms',
            startTime: '18:00',
            endTime: '19:00',
            initialStatus: AttendanceStatus.extraPresent,
          );
          await expectLater(
            () => attCtrl.addExtraClass(
              occurrenceId: secondExtra.id,
              date: targetDate,
              subjectId: fixture.activeSubId,
              startTime: '16:00',
              endTime: '17:00',
              initialStatus: AttendanceStatus.extraPresent,
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'DUPLICATE_EXTRA_CLASS_SLOT',
              ),
            ),
          );

          // 2e. Identity protection: mismatched subjectId on existing AttendanceRecordLocal rejects cleanly.
          late int mismatchOccId;
          isar.write((db) {
            final occ = DailyScheduleOccurrenceLocal()
              ..id = db.dailyScheduleOccurrenceLocals.autoIncrement()
              ..serverId = 'mismatch-occ'
              ..date = targetDate
              ..subjectId = fixture.activeSubId
              ..slotKey = computeCanonicalSlotKey(
                date: targetDate,
                subjectId: fixture.activeSubId,
                startTime: '19:30',
                endTime: '20:30',
                type: 'EXTRA_CLASS',
                title: 'Algorithms',
              )
              ..title = 'Algorithms'
              ..startTime = '19:30'
              ..endTime = '20:30'
              ..type = 'EXTRA_CLASS'
              ..status = 'UPCOMING'
              ..createdFrom = 'MANUAL'
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            db.dailyScheduleOccurrenceLocals.put(occ);
            mismatchOccId = occ.id;

            final badAtt = AttendanceRecordLocal()
              ..id = db.attendanceRecordLocals.autoIncrement()
              ..serverId = 'bad-att'
              ..occurrenceId = mismatchOccId
              ..eventId = mismatchOccId
              ..subjectId = fixture.secondActiveSubId // Wrong subject!
              ..status = 'EXTRA_PRESENT'
              ..markedAt = targetDate
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            db.attendanceRecordLocals.put(badAtt);
          });

          await expectLater(
            () => ds.saveExtraClassWithAttendance(
              occurrenceId: mismatchOccId,
              subjectId: fixture.activeSubId,
              date: targetDate,
              startTime: '19:30',
              endTime: '20:30',
              attendanceStatus: 'EXTRA_ABSENT',
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'ATTENDANCE_IDENTITY_MISMATCH',
              ),
            ),
          );
        } finally {
          try {
            container?.dispose();
          } catch (_) {
            // ignore Riverpod 2.6.1 known dispose race
          }
          if (isar != null && isar.isOpen) isar.close();
          if (tempDir.existsSync()) await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      '3. All 4 status transitions (UPCOMING, EXTRA_PRESENT, EXTRA_ABSENT, CANCELLED) preserve IDs, serverIds, soft-delete semantics & unrelated records',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_bug005_status_');
        Isar? isar;
        ProviderContainer? container;
        try {
          isar = openTempIsar(tempDir);
          final fixture = seedFixture(isar);
          container = createRealIsarContainer(isar);
          await container.read(isarProvider.future);
          final attCtrl = container.read(attendanceControllerProvider.notifier);
          final targetDate = fixture.semStart.add(const Duration(days: 7));

          // Seed an unrelated regular class + attendance record that must remain untouched.
          late int unrelatedOccId;
          late int unrelatedAttId;
          isar.write((db) {
            final uOcc = DailyScheduleOccurrenceLocal()
              ..id = db.dailyScheduleOccurrenceLocals.autoIncrement()
              ..serverId = 'unrelated-occ'
              ..date = targetDate
              ..subjectId = fixture.activeSubId
              ..title = 'Algorithms'
              ..startTime = '09:00'
              ..endTime = '10:00'
              ..type = 'REGULAR_CLASS'
              ..status = 'PRESENT'
              ..createdFrom = 'WEEKLY_RULE'
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            db.dailyScheduleOccurrenceLocals.put(uOcc);
            unrelatedOccId = uOcc.id;

            final uAtt = AttendanceRecordLocal()
              ..id = db.attendanceRecordLocals.autoIncrement()
              ..serverId = 'unrelated-att'
              ..occurrenceId = unrelatedOccId
              ..eventId = unrelatedOccId
              ..subjectId = fixture.activeSubId
              ..status = 'PRESENT'
              ..markedAt = targetDate
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            db.attendanceRecordLocals.put(uAtt);
            unrelatedAttId = uAtt.id;
          });

          // 3a. UPCOMING -> creates occurrence with no active attendance row.
          final upcoming = await attCtrl.addExtraClass(
            date: targetDate,
            subjectId: fixture.activeSubId,
            startTime: '15:00',
            endTime: '16:00',
            reason: 'Revision',
          );
          final occId = upcoming.id!;
          final occServerId = upcoming.serverId!;
          expect(occId, greaterThan(0));
          expect(upcoming.status, equals(OccurrenceStatus.upcoming));
          expect(
            isar.attendanceRecordLocals
                .where()
                .occurrenceIdEqualTo(occId)
                .findAll(),
            isEmpty,
          );

          // 3b. UPCOMING -> EXTRA_PRESENT.
          final presentOcc = await attCtrl.markExtraClass(
            occurrenceId: occId,
            subjectId: fixture.activeSubId,
            date: targetDate,
            startTime: '15:00',
            endTime: '16:00',
            status: AttendanceStatus.extraPresent,
          );
          expect(presentOcc.id, equals(occId));
          expect(presentOcc.serverId, equals(occServerId));
          expect(presentOcc.status, equals(OccurrenceStatus.present));

          final attAfterPresent = isar.attendanceRecordLocals
              .where()
              .occurrenceIdEqualTo(occId)
              .findAll();
          expect(attAfterPresent, hasLength(1));
          final attId = attAfterPresent.single.id;
          final attServerId = attAfterPresent.single.serverId;
          expect(attId, greaterThan(0));
          expect(attAfterPresent.single.occurrenceId, equals(occId));
          expect(attAfterPresent.single.eventId, equals(occId));
          expect(attAfterPresent.single.status, equals('EXTRA_PRESENT'));
          expect(attAfterPresent.single.isDeleted, isFalse);

          // 3c. EXTRA_PRESENT -> EXTRA_ABSENT (reuses same IDs & serverIds).
          final absentOcc = await attCtrl.markExtraClass(
            occurrenceId: occId,
            subjectId: fixture.activeSubId,
            date: targetDate,
            startTime: '15:00',
            endTime: '16:00',
            status: AttendanceStatus.extraAbsent,
          );
          expect(absentOcc.id, equals(occId));
          expect(absentOcc.serverId, equals(occServerId));
          expect(absentOcc.status, equals(OccurrenceStatus.absent));

          final attAfterAbsent = isar.attendanceRecordLocals
              .where()
              .occurrenceIdEqualTo(occId)
              .findAll();
          expect(attAfterAbsent, hasLength(1));
          expect(attAfterAbsent.single.id, equals(attId));
          expect(attAfterAbsent.single.serverId, equals(attServerId));
          expect(attAfterAbsent.single.status, equals('EXTRA_ABSENT'));
          expect(attAfterAbsent.single.isDeleted, isFalse);

          // 3d. EXTRA_ABSENT -> CANCELLED (soft-deletes ONLY this occurrence's attendance).
          final cancelledOcc = await attCtrl.markExtraClass(
            occurrenceId: occId,
            subjectId: fixture.activeSubId,
            date: targetDate,
            startTime: '15:00',
            endTime: '16:00',
            status: AttendanceStatus.cancelled,
          );
          expect(cancelledOcc.id, equals(occId));
          expect(cancelledOcc.serverId, equals(occServerId));
          expect(cancelledOcc.status, equals(OccurrenceStatus.cancelled));

          final attAfterCancel = isar.attendanceRecordLocals.get(attId)!;
          expect(attAfterCancel.id, equals(attId));
          expect(attAfterCancel.serverId, equals(attServerId));
          expect(attAfterCancel.isDeleted, isTrue);

          // Verify unrelated attendance remained active and untouched.
          final unrelatedAtt = isar.attendanceRecordLocals.get(unrelatedAttId)!;
          expect(unrelatedAtt.isDeleted, isFalse);
          expect(unrelatedAtt.status, equals('PRESENT'));

          // 3e. CANCELLED -> EXTRA_PRESENT restores same row without duplicate.
          await attCtrl.markExtraClass(
            occurrenceId: occId,
            subjectId: fixture.activeSubId,
            date: targetDate,
            startTime: '15:00',
            endTime: '16:00',
            status: AttendanceStatus.extraPresent,
          );
          final attRestored = isar.attendanceRecordLocals
              .where()
              .occurrenceIdEqualTo(occId)
              .findAll();
          expect(attRestored, hasLength(1));
          expect(attRestored.single.id, equals(attId));
          expect(attRestored.single.serverId, equals(attServerId));
          expect(attRestored.single.isDeleted, isFalse);
          expect(attRestored.single.status, equals('EXTRA_PRESENT'));

          // 3f. EXTRA_PRESENT -> UPCOMING soft-deletes active attendance without losing history ID.
          final backToUpcoming = await attCtrl.addExtraClass(
            occurrenceId: occId,
            date: targetDate,
            subjectId: fixture.activeSubId,
            startTime: '15:00',
            endTime: '16:00',
            initialStatus: null,
          );
          expect(backToUpcoming.status, equals(OccurrenceStatus.upcoming));
          final attAfterUpcoming = isar.attendanceRecordLocals.get(attId)!;
          expect(attAfterUpcoming.isDeleted, isTrue);
          expect(attAfterUpcoming.serverId, equals(attServerId));

          // 3g. Updating existing occurrence by ID with omitted times preserves slot & reason.
          final omittedTimesUpdate = await attCtrl.markExtraClass(
            occurrenceId: occId,
            subjectId: fixture.activeSubId,
            date: targetDate,
            status: AttendanceStatus.extraPresent,
          );
          expect(omittedTimesUpdate.id, equals(occId));
          expect(omittedTimesUpdate.startTime, equals('15:00'));
          expect(omittedTimesUpdate.endTime, equals('16:00'));
          expect(omittedTimesUpdate.reason, equals('Revision'));
          expect(
            isar.attendanceRecordLocals.get(attId)!.isDeleted,
            isFalse,
          );

          // 3h. Explicit empty reason clears existing notes without wiping IDs.
          final clearedReasonOcc = await attCtrl.markExtraClass(
            occurrenceId: occId,
            subjectId: fixture.activeSubId,
            date: targetDate,
            status: AttendanceStatus.extraAbsent,
            reason: '   ',
          );
          expect(clearedReasonOcc.id, equals(occId));
          expect(clearedReasonOcc.reason, isNull);
          expect(isar.eventLocals.count(), equals(0));
        } finally {
          try {
            container?.dispose();
          } catch (_) {
            // ignore Riverpod 2.6.1 known dispose race
          }
          if (isar != null && isar.isOpen) isar.close();
          if (tempDir.existsSync()) await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      '4. Subject-specific semester, soft-deletion, date-bounds & time-ordering validation',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_bug005_sem_');
        Isar? isar;
        ProviderContainer? container;
        try {
          isar = openTempIsar(tempDir);
          final fixture = seedFixture(isar);
          container = createRealIsarContainer(isar);
          await container.read(isarProvider.future);
          final attCtrl = container.read(attendanceControllerProvider.notifier);
          final validDate = fixture.semStart.add(const Duration(days: 3));

          // Non-existent subject
          await expectLater(
            () => attCtrl.addExtraClass(
              date: validDate,
              subjectId: 99999,
              startTime: '14:00',
              endTime: '15:00',
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'SUBJECT_NOT_FOUND',
              ),
            ),
          );

          // Soft-deleted subject
          await expectLater(
            () => attCtrl.addExtraClass(
              date: validDate,
              subjectId: fixture.deletedSubId,
              startTime: '14:00',
              endTime: '15:00',
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'SUBJECT_NOT_FOUND',
              ),
            ),
          );

          // Soft-deleted semester
          await expectLater(
            () => attCtrl.addExtraClass(
              date: fixture.semStart.subtract(const Duration(days: 250)),
              subjectId: fixture.deletedSemSubId,
              startTime: '14:00',
              endTime: '15:00',
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'SEMESTER_NOT_FOUND',
              ),
            ),
          );

          // Archived semester rejected even when active semester exists!
          await expectLater(
            () => attCtrl.addExtraClass(
              date: fixture.semStart.subtract(const Duration(days: 50)),
              subjectId: fixture.archivedSubId,
              startTime: '14:00',
              endTime: '15:00',
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'SEMESTER_NOT_ACTIVE',
              ),
            ),
          );

          // Draft semester rejected
          await expectLater(
            () => attCtrl.addExtraClass(
              date: fixture.semEnd.add(const Duration(days: 30)),
              subjectId: fixture.draftSubId,
              startTime: '14:00',
              endTime: '15:00',
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'SEMESTER_NOT_ACTIVE',
              ),
            ),
          );

          // Date before and after active subject semester bounds rejected
          await expectLater(
            () => attCtrl.addExtraClass(
              date: fixture.semStart.subtract(const Duration(days: 1)),
              subjectId: fixture.activeSubId,
              startTime: '14:00',
              endTime: '15:00',
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'EXTRA_CLASS_OUT_OF_SEMESTER_RANGE',
              ),
            ),
          );
          await expectLater(
            () => attCtrl.addExtraClass(
              date: fixture.semEnd.add(const Duration(days: 1)),
              subjectId: fixture.activeSubId,
              startTime: '14:00',
              endTime: '15:00',
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'EXTRA_CLASS_OUT_OF_SEMESTER_RANGE',
              ),
            ),
          );

          // Invalid time ranges (end == start, end < start, malformed)
          for (final pair in const [
            ('14:00', '14:00'),
            ('15:00', '14:00'),
            ('25:00', '26:00'),
          ]) {
            await expectLater(
              () => attCtrl.addExtraClass(
                date: validDate,
                subjectId: fixture.activeSubId,
                startTime: pair.$1,
                endTime: pair.$2,
              ),
              throwsA(
                isA<ValidationException>().having(
                  (e) => e.code,
                  'code',
                  'INVALID_TIME_RANGE',
                ),
              ),
            );
          }
          expect(isar.dailyScheduleOccurrenceLocals.count(), equals(0));
        } finally {
          try {
            container?.dispose();
          } catch (_) {
            // ignore Riverpod 2.6.1 known dispose race
          }
          if (isar != null && isar.isOpen) isar.close();
          if (tempDir.existsSync()) await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      '5. Deterministic slot allocation: avoids regular timetable rules, handles >14 extra classes without overwriting, and errors cleanly when day is exhausted',
      () async {
        if (nativeLibPath == null) return;

        final tempDir =
            await Directory.systemTemp.createTemp('attendiq_bug005_slots_');
        Isar? isar;
        ProviderContainer? container;
        try {
          isar = openTempIsar(tempDir);
          final fixture = seedFixture(isar);
          container = createRealIsarContainer(isar);
          await container.read(isarProvider.future);
          final attCtrl = container.read(attendanceControllerProvider.notifier);
          final targetDate = fixture.semStart.add(const Duration(days: 8));
          final fullDate = fixture.semStart.add(const Duration(days: 9));

          // Seed active regular weekly rules on targetDate.weekday at 09:00-10:00 and 14:00-15:00.
          isar.write((db) {
            final rule1 = WeeklyScheduleRuleLocal()
              ..id = db.weeklyScheduleRuleLocals.autoIncrement()
              ..serverId = 'rule-1'
              ..subjectId = fixture.activeSubId
              ..dayOfWeek = targetDate.weekday
              ..startTime = '09:00'
              ..endTime = '10:00'
              ..isActive = true
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            final rule2 = WeeklyScheduleRuleLocal()
              ..id = db.weeklyScheduleRuleLocals.autoIncrement()
              ..serverId = 'rule-2'
              ..subjectId = fixture.secondActiveSubId
              ..dayOfWeek = targetDate.weekday
              ..startTime = '14:00'
              ..endTime = '15:00'
              ..isActive = true
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            db.weeklyScheduleRuleLocals.putAll([rule1, rule2]);

            // Block fullDate completely (00:00-23:59) with an all-day EVENT occurrence.
            final allDay = DailyScheduleOccurrenceLocal()
              ..id = db.dailyScheduleOccurrenceLocals.autoIncrement()
              ..serverId = 'all-day-event'
              ..date = fullDate
              ..title = 'Symposium'
              ..startTime = '00:00'
              ..endTime = '23:59'
              ..type = 'EVENT'
              ..status = 'UPCOMING'
              ..createdFrom = 'MANUAL'
              ..createdAt = DateTime.now().toUtc()
              ..updatedAt = DateTime.now().toUtc();
            db.dailyScheduleOccurrenceLocals.put(allDay);
          });

          // Create 16 (>14!) extra classes via markExtraClass on targetDate.
          final allocatedSlots = <(String, String)>[];
          for (var i = 0; i < 16; i++) {
            final occ = await attCtrl.markExtraClass(
              subjectId: fixture.activeSubId,
              date: targetDate,
              status: AttendanceStatus.extraPresent,
            );
            allocatedSlots.add((occ.startTime, occ.endTime));
          }

          // First allocated slot skipped 09:00-10:00 regular rule and picked 10:00-11:00!
          expect(allocatedSlots.first, equals(('10:00', '11:00')));
          // None of the 16 slots touched 09:00-10:00 or 14:00-15:00.
          expect(allocatedSlots.contains(('09:00', '10:00')), isFalse);
          expect(allocatedSlots.contains(('14:00', '15:00')), isFalse);
          // All 16 slots are unique & distinct occurrences with 16 active attendance rows.
          expect(allocatedSlots.toSet(), hasLength(16));
          final dayOccs = isar.dailyScheduleOccurrenceLocals
              .where()
              .dateBetween(
                targetDate,
                DateTime.utc(
                  targetDate.year,
                  targetDate.month,
                  targetDate.day,
                  23,
                  59,
                  59,
                ),
              )
              .isDeletedEqualTo(false)
              .findAll();
          expect(dayOccs, hasLength(16));
          expect(
            isar.attendanceRecordLocals
                .where()
                .subjectIdEqualTo(fixture.activeSubId)
                .isDeletedEqualTo(false)
                .findAll(),
            hasLength(16),
          );

          // Exhausted day throws ValidationException cleanly without overwriting 09:00-10:00 or Symposium.
          await expectLater(
            () => attCtrl.markExtraClass(
              subjectId: fixture.activeSubId,
              date: fullDate,
              status: AttendanceStatus.extraPresent,
            ),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.code,
                'code',
                'NO_AVAILABLE_EXTRA_CLASS_SLOT',
              ),
            ),
          );
          expect(isar.eventLocals.count(), equals(0));
        } finally {
          try {
            container?.dispose();
          } catch (_) {
            // ignore Riverpod 2.6.1 known dispose race
          }
          if (isar != null && isar.isOpen) isar.close();
          if (tempDir.existsSync()) await tempDir.delete(recursive: true);
        }
      },
    );

    testWidgets(
      '6a. UI Entry Point 1 (SubjectDetailsPage): logs Extra Present via AddExtraClassDialog, refreshes logs/stats/WeeklySchedule, and blocks duplicate slot',
      timeout: const Timeout(Duration(minutes: 2)),
      (tester) async {
        if (nativeLibPath == null) return;

        final tempDir =
            Directory.systemTemp.createTempSync('attendiq_bug005_ui_sub_');
        final isar = openTempIsar(tempDir);
        addTearDown(() {
          if (isar.isOpen) isar.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        });

        final fixture = seedFixture(isar);
        final container = createRealIsarContainer(isar);
        addTearDown(() {
          try {
            container.dispose();
          } catch (_) {}
        });
        await tester.runAsync(() => container.read(isarProvider.future));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: SubjectDetailsPage(subjectId: fixture.activeSubId),
            ),
          ),
        );

        await pumpUntilFound(tester, find.text('No classes logged yet'));

        expect(find.text('Algorithms'), findsOneWidget);
        expect(find.text('No classes logged yet'), findsOneWidget);

        // Open consolidated AddExtraClassDialog from SubjectDetailsPage AppBar.
        await tester.tap(find.byTooltip('Add Extra Class'));
        await pumpUntilFound(tester, find.text('Save Extra Class'));
        await pumpUntilFound(tester, find.textContaining('Semester:'));

        expect(find.text('Algorithms (CS301)'), findsOneWidget);
        expect(find.text('Extra Present'), findsOneWidget);

        // Enter optional reason and save.
        await tester.enterText(find.byType(TextFormField).last, 'Makeup Lab');
        await tester.pump();
        await tester.tap(find.text('Save Extra Class'));
        await pumpUntilGone(tester, find.byType(AddExtraClassDialog));
        await pumpUntilFound(tester, find.textContaining('Extra Class'));

        // Verify persisted occurrence & attendance in real Isar.
        final occs = isar.dailyScheduleOccurrenceLocals
            .where()
            .subjectIdEqualTo(fixture.activeSubId)
            .isDeletedEqualTo(false)
            .findAll();
        expect(occs, hasLength(1));
        expect(occs.single.id, greaterThan(0));
        expect(occs.single.type, equals('EXTRA_CLASS'));
        expect(occs.single.status, equals('PRESENT'));
        expect(occs.single.reason, equals('Makeup Lab'));

        final atts = isar.attendanceRecordLocals
            .where()
            .occurrenceIdEqualTo(occs.single.id)
            .isDeletedEqualTo(false)
            .findAll();
        expect(atts, hasLength(1));
        expect(atts.single.status, equals('EXTRA_PRESENT'));
        expect(isar.eventLocals.count(), equals(0));

        // Verify SubjectDetailsPage updated immediately (no "No classes logged yet").
        await pumpUntilGone(tester, find.text('No classes logged yet'));
        expect(find.text('No classes logged yet'), findsNothing);
        expect(find.textContaining('Extra Class'), findsOneWidget);

        // Attempt submitting duplicate exact slot (14:00-15:00) via Subject Details again -> rejected!
        await tester.tap(find.byTooltip('Add Extra Class'));
        await pumpUntilFound(tester, find.text('Save Extra Class'));
        await pumpUntilFound(tester, find.textContaining('Semester:'));

        await tester.tap(find.text('Save Extra Class'));
        await pumpUntilFound(
          tester,
          find.descendant(
            of: find.byType(AddExtraClassDialog),
            matching: find.textContaining('already exists'),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(AddExtraClassDialog),
            matching: find.textContaining('already exists'),
          ),
          findsOneWidget,
        );
        expect(
          isar.dailyScheduleOccurrenceLocals
              .where()
              .subjectIdEqualTo(fixture.activeSubId)
              .isDeletedEqualTo(false)
              .findAll(),
          hasLength(1),
        );
      },
    );

    testWidgets(
      '6b. UI Entry Point 2 (TodayScheduleCard) & AddExtraClassDialog: subject-specific semester switch, clamped date picker, invalid time, and double-tap lock',
      timeout: const Timeout(Duration(minutes: 2)),
      (tester) async {
        if (nativeLibPath == null) return;

        final tempDir =
            Directory.systemTemp.createTempSync('attendiq_bug005_ui_today_');
        final isar = openTempIsar(tempDir);
        addTearDown(() {
          if (isar.isOpen) isar.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        });

        final fixture = seedFixture(isar);
        final today = DateTime.now();
        final todayContainer = createRealIsarContainer(isar);
        addTearDown(() {
          try {
            todayContainer.dispose();
          } catch (_) {}
        });
        await tester.runAsync(() => todayContainer.read(isarProvider.future));

        // 1) TodayScheduleCard flow -> create Scheduled (Upcoming) extra class.
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: todayContainer,
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: TodayScheduleCard(targetDate: today),
                ),
              ),
            ),
          ),
        );
        await pumpUntilFound(tester, find.text('No classes scheduled today.'));

        await tester.tap(find.text('Extra Class'));
        await pumpUntilFound(tester, find.text('Save Extra Class'));
        await pumpUntilFound(tester, find.byType(DropdownButtonFormField<int>));

        // Select subject from dropdown
        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await pumpRealAsync(tester, ticks: 5);
        await tester.tap(find.text('Algorithms (CS301)').last);
        await pumpUntilFound(tester, find.textContaining('Semester:'));

        expect(find.textContaining('Semester:'), findsOneWidget);
        await tester.tap(find.text('Save Extra Class'));
        await pumpUntilGone(tester, find.byType(AddExtraClassDialog));
        await pumpUntilFound(tester, find.text('Algorithms'));

        expect(
          isar.dailyScheduleOccurrenceLocals
              .where()
              .subjectIdEqualTo(fixture.activeSubId)
              .isDeletedEqualTo(false)
              .findAll(),
          hasLength(1),
        );
        expect(find.text('Algorithms'), findsOneWidget);

        // 2) Subject-specific semester bounds & clamping test:
        //    Seed a future active semester (starts today+10d, ends today+40d) temporarily
        //    so DateTime.now() is outside bounds -> verify date picker clamps initialDate without crashing
        //    and switching to archived subject disables Save with inline warning!
        final futureSemStart =
            normalizeUtcDate(today).add(const Duration(days: 10));
        final futureSemEnd =
            normalizeUtcDate(today).add(const Duration(days: 40));
        late Subject futureSubEntity;
        late Subject archivedSubEntity;
        isar.write((db) {
          final prev = db.semesterLocals.get(fixture.activeSemId)!
            ..status = SemesterLocal.statusArchived
            ..isActive = false;
          final futSem = SemesterLocal()
            ..id = db.semesterLocals.autoIncrement()
            ..serverId = 'sem-future-active'
            ..name = 'Future Active'
            ..startDate = futureSemStart
            ..endDate = futureSemEnd
            ..requiredAttendanceRate = 75.0
            ..status = SemesterLocal.statusActive
            ..isActive = true
            ..createdAt = today.toUtc()
            ..updatedAt = today.toUtc();
          db.semesterLocals.putAll([prev, futSem]);

          final futSub = SubjectLocal()
            ..id = db.subjectLocals.autoIncrement()
            ..serverId = 'sub-fut-active'
            ..semesterId = futSem.id
            ..name = 'Distributed Systems'
            ..code = 'CS401'
            ..credits = 4
            ..attendanceTarget = 75.0
            ..color = '#2563EB'
            ..type = 'THEORY'
            ..createdAt = today.toUtc()
            ..updatedAt = today.toUtc();
          db.subjectLocals.put(futSub);

          futureSubEntity = Subject(
            id: futSub.id,
            semesterId: futSem.id,
            name: futSub.name,
            code: futSub.code,
            credits: futSub.credits,
            attendanceTarget: futSub.attendanceTarget,
            color: futSub.color,
            type: SubjectType.theory,
            updatedAt: futSub.updatedAt,
          );
          final archSubLocal = db.subjectLocals.get(fixture.archivedSubId)!;
          archivedSubEntity = Subject(
            id: archSubLocal.id,
            semesterId: archSubLocal.semesterId,
            name: archSubLocal.name,
            code: archSubLocal.code,
            credits: archSubLocal.credits,
            attendanceTarget: archSubLocal.attendanceTarget,
            color: archSubLocal.color,
            type: SubjectType.theory,
            updatedAt: archSubLocal.updatedAt,
          );
        });

        final dialogContainer = createRealIsarContainer(
          isar,
          extraOverrides: [
            subjectListControllerProvider.overrideWith(
              () => _StaticSubjectListController(
                [futureSubEntity, archivedSubEntity],
              ),
            ),
          ],
        );
        addTearDown(() {
          try {
            dialogContainer.dispose();
          } catch (_) {}
        });
        await tester.runAsync(() => dialogContainer.read(isarProvider.future));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: dialogContainer,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
              home: Scaffold(
                body: AddExtraClassDialog(initialDate: today),
              ),
            ),
          ),
        );
        await pumpUntilFound(tester, find.byType(DropdownButtonFormField<int>));

        // Select future-semester subject while initialDate is today (outside bounds).
        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await pumpRealAsync(tester, ticks: 5);
        await tester.tap(find.text('Distributed Systems (CS401)').last);
        await pumpUntilFound(
          tester,
          find.textContaining('Selected date must be between'),
        );

        // Inline out-of-range error shown & Save disabled.
        expect(
          find.textContaining('Selected date must be between'),
          findsOneWidget,
        );

        // Open date picker -> initialDate clamped to futureSemStart without AssertionError!
        await tester.tap(find.byIcon(Icons.calendar_today));
        await pumpRealAsync(tester, ticks: 5);
        expect(find.text('OK'), findsOneWidget);
        await tester.tap(find.text('OK'));
        await pumpRealAsync(tester, ticks: 5);
        expect(
          find.textContaining('Selected date must be between'),
          findsNothing,
        );

        // Switch end time to 13:00 (before start time 14:00) -> inline error & Save disabled!
        await tester.tap(find.text('15:00'));
        await pumpRealAsync(tester, ticks: 5);
        final keyboardIcon =
            find.byIcon(Icons.keyboard_outlined).evaluate().isNotEmpty
                ? find.byIcon(Icons.keyboard_outlined)
                : find.byIcon(Icons.keyboard);
        await tester.tap(keyboardIcon);
        await pumpRealAsync(tester, ticks: 5);
        final pickerFields = find.descendant(
          of: find.byType(TimePickerDialog),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(pickerFields.at(0), '13');
        await tester.enterText(pickerFields.at(1), '00');
        await tester.tap(find.text('OK'));
        await pumpRealAsync(tester, ticks: 5);
        expect(find.text('End time must be after start time.'), findsOneWidget);
        expect(
          tester
              .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Save Extra Class'),
              )
              .onPressed,
          isNull,
        );

        // Switch subject to archived semester subject -> blocks with clear feedback, no arbitrary fallback.
        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await pumpRealAsync(tester, ticks: 5);
        await tester.tap(find.text('Legacy Course (OLD201)').last);
        await pumpUntilFound(tester, find.textContaining('archived'));

        expect(find.textContaining('archived'), findsOneWidget);
        final saveBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Save Extra Class'),
        );
        expect(saveBtn.onPressed, isNull);

        // 3) Double-tap lock test using delayed repository.
        final delayedRepo = _DelayedFakeAttendanceRepository();
        final lockContainer = createRealIsarContainer(
          isar,
          extraOverrides: [
            attendanceRepositoryProvider.overrideWithValue(delayedRepo),
          ],
        );
        addTearDown(() {
          try {
            lockContainer.dispose();
          } catch (_) {}
        });
        await tester.runAsync(() => lockContainer.read(isarProvider.future));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            key: const ValueKey('double_tap_scope'),
            container: lockContainer,
            child: MaterialApp(
              home: Scaffold(
                body: AddExtraClassDialog(
                  key: const ValueKey('double_tap_dialog'),
                  initialDate: futureSemStart.add(const Duration(days: 1)),
                  initialSubjectId: futureSubEntity.id,
                  initialSubject: futureSubEntity,
                  lockSubject: true,
                ),
              ),
            ),
          ),
        );
        await pumpUntilFound(tester, find.textContaining('Semester:'));

        await tester.tap(find.text('Save Extra Class'));
        await tester.pump();
        final lockedSaveBtn = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(lockedSaveBtn.onPressed, isNull);
        await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
        await tester.pump();

        expect(delayedRepo.saveExtraClassCallCount, equals(1));
        delayedRepo.blocker.complete();
        await pumpRealAsync(tester, ticks: 8);
      },
    );

    testWidgets(
      '6c. UI Entry Point 3 (DateDetailsBottomSheet): opens consolidated AddExtraClassDialog, saves extra class, and updates dayScheduleByKeyProvider',
      timeout: const Timeout(Duration(minutes: 2)),
      (tester) async {
        if (nativeLibPath == null) return;

        final tempDir =
            Directory.systemTemp.createTempSync('attendiq_bug005_ui_cal_');
        final isar = openTempIsar(tempDir);
        addTearDown(() {
          if (isar.isOpen) isar.close();
          if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        });

        final fixture = seedFixture(isar);
        final targetDate = fixture.semStart.add(const Duration(days: 4));
        final container = createRealIsarContainer(isar);
        addTearDown(() {
          try {
            container.dispose();
          } catch (_) {}
        });
        await tester.runAsync(() => container.read(isarProvider.future));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final dayAsync =
                            ref.watch(dayScheduleProvider(targetDate));
                        return dayAsync.when(
                          data: (d) => Text('DaySlots: ${d.items.length}'),
                          loading: () => const Text('DaySlots: loading'),
                          error: (e, _) => Text('DaySlots: error $e'),
                        );
                      },
                    ),
                    Builder(
                      builder: (context) => ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => DateDetailsBottomSheet(
                              dayData: CalendarDayData(
                                date: targetDate,
                                isCurrentMonth: true,
                                isToday: false,
                                isInSemesterRange: true,
                                items: const [],
                                hasRegularClass: false,
                                hasExam: false,
                                hasTask: false,
                                hasHoliday: false,
                                hasExtraClass: false,
                                hasEvent: false,
                              ),
                            ),
                          );
                        },
                        child: const Text('Open Day Sheet'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await pumpUntilFound(tester, find.text('DaySlots: 0'));
        await tester.tap(find.text('Open Day Sheet'));
        await pumpUntilFound(tester, find.text('+ Add Extra Class'));

        await tester.tap(find.text('+ Add Extra Class'));
        await pumpUntilFound(tester, find.byType(DropdownButtonFormField<int>));

        await tester.tap(find.byType(DropdownButtonFormField<int>));
        await pumpRealAsync(tester, ticks: 5);
        await tester.tap(find.text('Algorithms (CS301)').last);
        await pumpUntilFound(tester, find.textContaining('Semester:'));

        await tester.tap(find.text('Save Extra Class'));
        await pumpUntilGone(tester, find.byType(AddExtraClassDialog));
        await pumpUntilGone(tester, find.byType(DateDetailsBottomSheet));

        final occs = isar.dailyScheduleOccurrenceLocals
            .where()
            .subjectIdEqualTo(fixture.activeSubId)
            .isDeletedEqualTo(false)
            .findAll();
        expect(occs, hasLength(1));
        expect(occs.single.type, equals('EXTRA_CLASS'));
        expect(isar.eventLocals.count(), equals(0));

        // Verify reactive dayScheduleProvider (dayScheduleByKeyProvider) updates live!
        await pumpUntilFound(tester, find.text('DaySlots: 1'));
        expect(find.text('DaySlots: 1'), findsOneWidget);
      },
    );
  });
}

class _StaticSubjectListController extends SubjectListController {
  final List<Subject> _subjects;
  _StaticSubjectListController(this._subjects);

  @override
  FutureOr<List<Subject>> build() async => _subjects;
}
