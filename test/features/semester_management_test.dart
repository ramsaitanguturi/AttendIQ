import 'dart:convert';
import 'dart:io';

import 'package:attend_iq/app/app_router.dart';
import 'package:attend_iq/core/ai/context/ai_context_builder.dart';
import 'package:attend_iq/core/analytics/services/analytics_service.dart';
import 'package:attend_iq/core/backup/backup_importer.dart';
import 'package:attend_iq/core/backup/backup_service.dart';
import 'package:attend_iq/core/constants/app_constants.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/errors/app_exception.dart';
import 'package:attend_iq/core/event_generator/data/models/event_local.dart';
import 'package:attend_iq/core/event_generator/services/event_generator_service.dart';
import 'package:attend_iq/core/notifications/scheduler/notification_database.dart';
import 'package:attend_iq/core/reports/services/report_service.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:attend_iq/features/semester/data/models/semester_local.dart';
import 'package:attend_iq/features/semester/data/repositories/semester_repository_impl.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/semester/domain/usecases/create_semester_use_case.dart';
import 'package:attend_iq/features/semester/domain/validators/semester_validator.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';
import 'package:attend_iq/features/settings/domain/repositories/settings_repository.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import 'package:attend_iq/features/settings/presentation/pages/settings_page.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';

class _LegacySemesterLocal {
  int id = 0;
  String? serverId;
  late String name;
  late DateTime startDate;
  late DateTime endDate;
  late double requiredAttendanceRate;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;
}

@isarProtected
int _serializeLegacySemester(IsarWriter writer, _LegacySemesterLocal object) {
  final serverId = object.serverId;
  if (serverId == null) {
    IsarCore.writeNull(writer, 1);
  } else {
    IsarCore.writeString(writer, 1, serverId);
  }
  IsarCore.writeString(writer, 2, object.name);
  IsarCore.writeLong(
    writer,
    3,
    object.startDate.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeLong(writer, 4, object.endDate.toUtc().microsecondsSinceEpoch);
  IsarCore.writeDouble(writer, 5, object.requiredAttendanceRate);
  IsarCore.writeLong(
    writer,
    6,
    object.createdAt.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeLong(
    writer,
    7,
    object.updatedAt.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeBool(writer, 8, object.isDirty);
  IsarCore.writeBool(writer, 9, object.isDeleted);
  return object.id;
}

@isarProtected
_LegacySemesterLocal _deserializeLegacySemester(IsarReader reader) {
  final object = _LegacySemesterLocal();
  object.id = IsarCore.readId(reader);
  object.serverId = IsarCore.readString(reader, 1);
  object.name = IsarCore.readString(reader, 2) ?? '';
  final startUs = IsarCore.readLong(reader, 3);
  object.startDate =
      DateTime.fromMicrosecondsSinceEpoch(startUs, isUtc: true).toLocal();
  final endUs = IsarCore.readLong(reader, 4);
  object.endDate =
      DateTime.fromMicrosecondsSinceEpoch(endUs, isUtc: true).toLocal();
  object.requiredAttendanceRate = IsarCore.readDouble(reader, 5);
  final createdUs = IsarCore.readLong(reader, 6);
  object.createdAt =
      DateTime.fromMicrosecondsSinceEpoch(createdUs, isUtc: true).toLocal();
  final updatedUs = IsarCore.readLong(reader, 7);
  object.updatedAt =
      DateTime.fromMicrosecondsSinceEpoch(updatedUs, isUtc: true).toLocal();
  object.isDirty = IsarCore.readBool(reader, 8);
  object.isDeleted = IsarCore.readBool(reader, 9);
  return object;
}

const _legacySemesterSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'SemesterLocal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'serverId', type: IsarType.string),
      IsarPropertySchema(name: 'name', type: IsarType.string),
      IsarPropertySchema(name: 'startDate', type: IsarType.dateTime),
      IsarPropertySchema(name: 'endDate', type: IsarType.dateTime),
      IsarPropertySchema(name: 'requiredAttendanceRate', type: IsarType.double),
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
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, _LegacySemesterLocal>(
    serialize: _serializeLegacySemester,
    deserialize: _deserializeLegacySemester,
  ),
  embeddedSchemas: [],
);

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

class _InMemorySemesterRepository implements SemesterRepository {
  final List<Semester> _items = <Semester>[];
  int _nextId = 1;
  int createCalls = 0;
  Duration createDelay = Duration.zero;

  void seed(List<Semester> initial) {
    _items
      ..clear()
      ..addAll(initial);
    for (final s in initial) {
      if ((s.localId ?? 0) >= _nextId) {
        _nextId = (s.localId ?? 0) + 1;
      }
    }
  }

  @override
  Future<void> createSemester(Semester semester) async {
    createCalls++;
    if (createDelay > Duration.zero) {
      await Future<void>.delayed(createDelay);
    }
    SemesterValidator.validateForSave(
      candidate: semester,
      existingSemesters: _items,
    );
    if (semester.status == SemesterStatus.active) {
      for (var i = 0; i < _items.length; i++) {
        if (_items[i].isActive) {
          _items[i] = _items[i].copyWith(status: SemesterStatus.archived);
        }
      }
    }
    _items.add(
      semester.copyWith(
        localId: semester.localId ?? _nextId++,
        id: semester.id ?? 'sem_${_nextId - 1}',
      ),
    );
  }

  @override
  Future<void> updateSemester(Semester semester) async {
    final idx = _items.indexWhere((s) => s.localId == semester.localId);
    if (idx < 0) {
      throw const ValidationException(
        'Semester not found.',
        'SEMESTER_NOT_FOUND',
      );
    }
    if (_items[idx].isArchived) {
      throw const ValidationException(
        'Archived semesters are read-only.',
        'SEMESTER_ARCHIVED_READ_ONLY',
      );
    }
    SemesterValidator.validateForSave(
      candidate: semester,
      existingSemesters: _items,
    );
    if (semester.status == SemesterStatus.active) {
      for (var i = 0; i < _items.length; i++) {
        if (i != idx && _items[i].isActive) {
          _items[i] = _items[i].copyWith(status: SemesterStatus.archived);
        }
      }
    }
    _items[idx] = semester;
  }

  @override
  Future<void> setActiveSemester(int localId) async {
    final idx = _items.indexWhere((s) => s.localId == localId);
    if (idx < 0) {
      throw const ValidationException(
        'Semester not found.',
        'SEMESTER_NOT_FOUND',
      );
    }
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(
        status: i == idx ? SemesterStatus.active : SemesterStatus.archived,
      );
    }
  }

  @override
  Future<void> archiveSemester(int localId) async {
    final idx = _items.indexWhere((s) => s.localId == localId);
    if (idx < 0) {
      throw const ValidationException(
        'Semester not found.',
        'SEMESTER_NOT_FOUND',
      );
    }
    _items[idx] = _items[idx].copyWith(status: SemesterStatus.archived);
  }

  @override
  Future<Semester?> getSemesterById(int localId) async {
    for (final s in _items) {
      if (s.localId == localId) return s;
    }
    return null;
  }

  @override
  Future<Semester?> getActiveSemester() async {
    for (final s in _items) {
      if (s.isActive) return s;
    }
    return null;
  }

  @override
  Future<bool> hasActiveSemester() async => _items.any((s) => s.isActive);

  @override
  Future<List<Semester>> getAllSemesters() async {
    final copy = List<Semester>.from(_items);
    copy.sort((a, b) => b.startDate.compareTo(a.startDate));
    return copy;
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<UserPreferences?> getPreferences(String id) async =>
      const UserPreferences(
        id: 'local_user',
        themeMode: 'system',
        defaultAttendanceTarget: 75.0,
        classReminderOffset: 5,
        enableNotifications: true,
        enableAttendanceWarnings: true,
        weeklyReportEnabled: true,
      );

  @override
  Future<void> savePreferences(UserPreferences prefs) async {}

  @override
  Stream<UserPreferences?> watchPreferences(String id) => const Stream.empty();
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
        'attendiq_bug017_${DateTime.now().microsecondsSinceEpoch}_${dbSequence++}';
    return Isar.open(
      schemas: appIsarSchemas,
      name: name,
      directory: tempDir.path,
    );
  }

  group('BUG-017: Domain validation & CreateSemesterUseCase', () {
    test('rejects empty name, invalid target, and startDate >= endDate',
        () async {
      final repo = _InMemorySemesterRepository();
      final useCase = CreateSemesterUseCase(repo);

      await expectLater(
        () => useCase(
          Semester(
            name: '   ',
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 12, 1),
            requiredAttendanceRate: 75.0,
          ),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'SEMESTER_NAME_EMPTY',
          ),
        ),
      );

      await expectLater(
        () => useCase(
          Semester(
            name: 'Same Day',
            startDate: DateTime(2026, 8, 1, 9, 0),
            endDate: DateTime(2026, 8, 1, 18, 0),
            requiredAttendanceRate: 75.0,
          ),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'SEMESTER_INVALID_DATE_RANGE',
          ),
        ),
      );

      await expectLater(
        () => useCase(
          Semester(
            name: 'Reversed',
            startDate: DateTime(2026, 12, 1),
            endDate: DateTime(2026, 8, 1),
            requiredAttendanceRate: 75.0,
          ),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'SEMESTER_INVALID_DATE_RANGE',
          ),
        ),
      );

      await expectLater(
        () => useCase(
          Semester(
            name: 'Invalid Rate',
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 12, 1),
            requiredAttendanceRate: 105.0,
          ),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.code,
            'code',
            'SEMESTER_INVALID_RATE',
          ),
        ),
      );
    });

    test(
        'detects overlaps across all boundary cases including touching edge day',
        () {
      final existing = [
        Semester(
          localId: 1,
          name: 'Fall 2026',
          startDate: DateTime(2026, 8, 1),
          endDate: DateTime(2026, 12, 15),
          requiredAttendanceRate: 75.0,
        ),
      ];

      // Touching boundary day (15 Dec)
      expect(
        SemesterValidator.findOverlappingSemester(
          startDate: DateTime(2026, 12, 15),
          endDate: DateTime(2027, 4, 30),
          existingSemesters: existing,
        ),
        isNotNull,
      );

      // Partial overlap at start
      expect(
        SemesterValidator.findOverlappingSemester(
          startDate: DateTime(2026, 6, 1),
          endDate: DateTime(2026, 8, 10),
          existingSemesters: existing,
        ),
        isNotNull,
      );

      // Wholly enclosing
      expect(
        SemesterValidator.findOverlappingSemester(
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 12, 31),
          existingSemesters: existing,
        ),
        isNotNull,
      );

      // Next day after endDate is valid
      expect(
        SemesterValidator.findOverlappingSemester(
          startDate: DateTime(2026, 12, 16),
          endDate: DateTime(2027, 4, 30),
          existingSemesters: existing,
        ),
        isNull,
      );

      // Editing same semester ID does not conflict with itself
      expect(
        SemesterValidator.findOverlappingSemester(
          startDate: DateTime(2026, 8, 5),
          endDate: DateTime(2026, 12, 10),
          existingSemesters: existing,
          excludeLocalId: 1,
        ),
        isNull,
      );
    });

    test('SemesterLocal.toJson and fromJson support new and legacy formats',
        () {
      final local = SemesterLocal()
        ..id = 3
        ..serverId = 'sem-uuid-3'
        ..name = 'Spring 2027'
        ..startDate = DateTime(2027, 1, 10)
        ..endDate = DateTime(2027, 5, 20)
        ..requiredAttendanceRate = 80.0
        ..status = SemesterLocal.statusDraft
        ..isActive = false
        ..createdAt = DateTime.utc(2026, 11, 1)
        ..updatedAt = DateTime.utc(2026, 11, 2);

      final roundtrip = SemesterLocal.fromJson(local.toJson());
      expect(roundtrip.status, equals(SemesterLocal.statusDraft));
      expect(roundtrip.isActive, isFalse);
      expect(roundtrip.name, equals('Spring 2027'));

      final legacyJson = <String, dynamic>{
        'id': 1,
        'serverId': 'legacy-1',
        'name': 'Fall 2025',
        'startDate': '2025-08-01T00:00:00.000Z',
        'endDate': '2025-12-15T00:00:00.000Z',
        'requiredAttendanceRate': 75.0,
      };
      final legacyParsed = SemesterLocal.fromJson(legacyJson);
      expect(legacyParsed.status, equals(SemesterLocal.statusActive));
      expect(legacyParsed.isActive, isTrue);
    });
  });

  group('BUG-017: Real Isar repository lifecycle & migration', () {
    test(
        'enforces validation, single-active invariant, draft/archive/switch, and read-only archived lock',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug017_repo_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final repo = SemesterRepositoryImpl(isar);

        // 1. Create active semester #1
        await repo.createSemester(
          Semester(
            name: 'Fall 2026',
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 12, 15),
            requiredAttendanceRate: 75.0,
          ),
        );
        final sem1 = await repo.getActiveSemester();
        expect(sem1, isNotNull);
        expect(sem1!.name, equals('Fall 2026'));
        expect(sem1.status, equals(SemesterStatus.active));
        expect(await repo.hasActiveSemester(), isTrue);

        // 2. Reject overlapping semester
        await expectLater(
          () => repo.createSemester(
            Semester(
              name: 'Overlap Term',
              startDate: DateTime(2026, 12, 1),
              endDate: DateTime(2027, 4, 15),
              requiredAttendanceRate: 75.0,
            ),
          ),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.code,
              'code',
              'SEMESTER_DATE_OVERLAP',
            ),
          ),
        );

        // 3. Create draft semester #2 — must NOT deactivate semester #1
        await repo.createSemester(
          Semester(
            name: 'Spring 2027',
            startDate: DateTime(2027, 1, 10),
            endDate: DateTime(2027, 5, 20),
            requiredAttendanceRate: 80.0,
            status: SemesterStatus.draft,
          ),
        );
        final stillActive = await repo.getActiveSemester();
        expect(stillActive!.localId, equals(sem1.localId));

        final allAfterDraft = await repo.getAllSemesters();
        expect(allAfterDraft, hasLength(2));
        final sem2 = allAfterDraft.firstWhere((s) => s.name == 'Spring 2027');
        expect(sem2.status, equals(SemesterStatus.draft));

        // 4. Edit draft semester #2
        await repo.updateSemester(
          sem2.copyWith(
            name: 'Spring 2027 Updated',
            requiredAttendanceRate: 82.0,
          ),
        );
        final updatedSem2 = await repo.getSemesterById(sem2.localId!);
        expect(updatedSem2!.name, equals('Spring 2027 Updated'));
        expect(updatedSem2.requiredAttendanceRate, equals(82.0));

        // 5. Activate semester #2 — must archive semester #1 atomically
        await repo.setActiveSemester(sem2.localId!);
        final newActive = await repo.getActiveSemester();
        expect(newActive!.localId, equals(sem2.localId));
        expect(newActive.status, equals(SemesterStatus.active));

        final reloadedSem1 = await repo.getSemesterById(sem1.localId!);
        expect(reloadedSem1!.status, equals(SemesterStatus.archived));

        // 6. Archived semester #1 must reject direct edits (read-only rule)
        await expectLater(
          () => repo.updateSemester(
            reloadedSem1.copyWith(name: 'Should Fail'),
          ),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.code,
              'code',
              'SEMESTER_ARCHIVED_READ_ONLY',
            ),
          ),
        );

        // 7. Create active semester #3 — archives semester #2
        await repo.createSemester(
          Semester(
            name: 'Summer 2027',
            startDate: DateTime(2027, 6, 1),
            endDate: DateTime(2027, 8, 15),
            requiredAttendanceRate: 85.0,
          ),
        );
        final sem3 = await repo.getActiveSemester();
        expect(sem3!.name, equals('Summer 2027'));
        expect(
          (await repo.getSemesterById(sem2.localId!))!.status,
          equals(SemesterStatus.archived),
        );

        // Verify only 1 active row exists in DB
        final activeRows = isar.semesterLocals
            .where()
            .isActiveEqualTo(true)
            .isDeletedEqualTo(false)
            .findAll();
        expect(activeRows, hasLength(1));
        expect(activeRows.single.name, equals('Summer 2027'));

        // 8. Archive semester #3 -> no active semester left
        await repo.archiveSemester(sem3.localId!);
        expect(await repo.getActiveSemester(), isNull);
        expect(await repo.hasActiveSemester(), isFalse);
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        'migrates legacy pre-BUG-017 Isar schema idempotently, preserves data on reopen, and does not reactivate archived semesters',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug017_migrate_');
      Isar? isar;
      try {
        // 1. Seed pre-BUG-017 Isar database (no isActive / status fields)
        final legacyIsar = Isar.open(
          schemas: <IsarGeneratedSchema>[_legacySemesterSchema],
          name: AppConstants.isarDbName,
          directory: tempDir.path,
        );
        legacyIsar.write((db) {
          final col = db.collection<int, _LegacySemesterLocal>();
          col.putAll([
            _LegacySemesterLocal()
              ..id = col.autoIncrement()
              ..serverId = 'legacy-sem-1'
              ..name = 'Fall 2025'
              ..startDate = DateTime(2025, 8, 1)
              ..endDate = DateTime(2025, 12, 15)
              ..requiredAttendanceRate = 75.0
              ..createdAt = DateTime.utc(2025, 8, 1)
              ..updatedAt = DateTime.utc(2025, 8, 1),
            _LegacySemesterLocal()
              ..id = col.autoIncrement()
              ..serverId = 'legacy-sem-2'
              ..name = 'Spring 2026'
              ..startDate = DateTime(2026, 1, 10)
              ..endDate = DateTime(2026, 5, 20)
              ..requiredAttendanceRate = 80.0
              ..createdAt = DateTime.utc(2026, 1, 10)
              ..updatedAt = DateTime.utc(2026, 1, 10),
          ]);
        });
        legacyIsar.close();

        // 2. Open with app's isarProvider (runs migrateLegacySemesters)
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
        final repo = SemesterRepositoryImpl(migratedIsar);

        final active = await repo.getActiveSemester();
        expect(active, isNotNull);
        expect(active!.name, equals('Spring 2026'));
        expect(active.status, equals(SemesterStatus.active));

        final all = await repo.getAllSemesters();
        expect(all, hasLength(2));
        final oldSem = all.firstWhere((s) => s.name == 'Fall 2025');
        expect(oldSem.status, equals(SemesterStatus.archived));

        // 3. Re-running migration must be a no-op (0 updated rows)
        expect(await migrateLegacySemesters(migratedIsar), equals(0));

        // 4. Intentionally archive Spring 2026, reopen DB, ensure it stays archived
        await repo.archiveSemester(active.localId!);
        expect(await repo.getActiveSemester(), isNull);

        container.dispose();
        final reopenedIsar =
            openTempIsar(tempDir, customName: AppConstants.isarDbName);
        isar = reopenedIsar;
        expect(await migrateLegacySemesters(reopenedIsar), equals(0));
        final repoAfterReopen = SemesterRepositoryImpl(reopenedIsar);
        expect(await repoAfterReopen.getActiveSemester(), isNull);
        expect(await repoAfterReopen.hasActiveSemester(), isFalse);
        expect(await repoAfterReopen.getAllSemesters(), hasLength(2));
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
        'unifies active semester lookup across AnalyticsService, ReportService, NotificationDatabase, AiContextBuilder, and EventGeneratorService',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug017_consumers_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final repo = SemesterRepositoryImpl(isar);

        // Create Sem 1 (then replaced as active by Sem 2 so Sem 1 is archived id=1, Sem 2 is active id=2)
        await repo.createSemester(
          Semester(
            name: 'Fall 2026 (Old)',
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 12, 15),
            requiredAttendanceRate: 75.0,
          ),
        );
        await repo.createSemester(
          Semester(
            name: 'Spring 2027 (Active)',
            startDate: DateTime(2027, 1, 10),
            endDate: DateTime(2027, 5, 20),
            requiredAttendanceRate: 85.0,
          ),
        );

        final allSemesters = await repo.getAllSemesters();
        final oldSem =
            allSemesters.firstWhere((s) => s.name == 'Fall 2026 (Old)');
        final activeSem =
            allSemesters.firstWhere((s) => s.name == 'Spring 2027 (Active)');

        // Seed distinct subjects, templates, events, and attendance per semester
        late int oldSubId;
        late int activeSubId;
        isar.write((db) {
          final now = DateTime.now().toUtc();
          final oldSub = SubjectLocal()
            ..id = db.subjectLocals.autoIncrement()
            ..serverId = 'sub-old'
            ..semesterId = oldSem.localId!
            ..name = 'Old Chemistry'
            ..code = 'CHEM101'
            ..credits = 3
            ..attendanceTarget = 75.0
            ..color = '#FF0000'
            ..type = 'THEORY'
            ..createdAt = now
            ..updatedAt = now;
          db.subjectLocals.put(oldSub);
          oldSubId = oldSub.id;

          final activeSub = SubjectLocal()
            ..id = db.subjectLocals.autoIncrement()
            ..serverId = 'sub-active'
            ..semesterId = activeSem.localId!
            ..name = 'Distributed Systems'
            ..code = 'CS501'
            ..credits = 4
            ..attendanceTarget = 85.0
            ..color = '#10B981'
            ..type = 'THEORY'
            ..createdAt = now
            ..updatedAt = now;
          db.subjectLocals.put(activeSub);
          activeSubId = activeSub.id;

          final evOld = EventLocal()
            ..id = db.eventLocals.autoIncrement()
            ..serverId = 'ev-old'
            ..subjectId = oldSubId
            ..date = DateTime.utc(2026, 9, 1)
            ..startTime = '09:00'
            ..endTime = '10:00'
            ..eventType = 'REGULAR_CLASS'
            ..status = 'PRESENT'
            ..createdAt = now
            ..updatedAt = now;
          db.eventLocals.put(evOld);

          db.attendanceRecordLocals.put(
            AttendanceRecordLocal()
              ..id = db.attendanceRecordLocals.autoIncrement()
              ..serverId = 'att-old'
              ..eventId = evOld.id
              ..subjectId = oldSubId
              ..status = 'PRESENT'
              ..markedAt = DateTime.utc(2026, 9, 1)
              ..createdAt = now
              ..updatedAt = now,
          );

          final evActive1 = EventLocal()
            ..id = db.eventLocals.autoIncrement()
            ..serverId = 'ev-act-1'
            ..subjectId = activeSubId
            ..date = DateTime.utc(2027, 2, 1)
            ..startTime = '10:00'
            ..endTime = '11:00'
            ..eventType = 'REGULAR_CLASS'
            ..status = 'PRESENT'
            ..createdAt = now
            ..updatedAt = now;
          final evActive2 = EventLocal()
            ..id = db.eventLocals.autoIncrement()
            ..serverId = 'ev-act-2'
            ..subjectId = activeSubId
            ..date = DateTime.utc(2027, 2, 2)
            ..startTime = '10:00'
            ..endTime = '11:00'
            ..eventType = 'REGULAR_CLASS'
            ..status = 'ABSENT'
            ..createdAt = now
            ..updatedAt = now;
          db.eventLocals.putAll([evActive1, evActive2]);

          db.attendanceRecordLocals.putAll([
            AttendanceRecordLocal()
              ..id = db.attendanceRecordLocals.autoIncrement()
              ..serverId = 'att-act-1'
              ..eventId = evActive1.id
              ..subjectId = activeSubId
              ..status = 'PRESENT'
              ..markedAt = DateTime.utc(2027, 2, 1)
              ..createdAt = now
              ..updatedAt = now,
            AttendanceRecordLocal()
              ..id = db.attendanceRecordLocals.autoIncrement()
              ..serverId = 'att-act-2'
              ..eventId = evActive2.id
              ..subjectId = activeSubId
              ..status = 'ABSENT'
              ..markedAt = DateTime.utc(2027, 2, 2)
              ..createdAt = now
              ..updatedAt = now,
          ]);

          db.timetableTemplateLocals.put(
            TimetableTemplateLocal()
              ..id = db.timetableTemplateLocals.autoIncrement()
              ..serverId = 'tpl-old'
              ..subjectId = oldSubId
              ..weekday = DateTime.monday
              ..startTime = '11:00'
              ..endTime = '12:00'
              ..createdAt = now
              ..updatedAt = now,
          );
        });

        final container = ProviderContainer(
          overrides: [
            isarProvider.overrideWith((ref) async => isar!),
          ],
        );
        addTearDown(container.dispose);

        // Wait for isarProvider to resolve inside container
        await container.read(isarProvider.future);

        // 1. ReportService must match active semester name AND subjects (50%)
        final reportService = container.read(reportServiceProvider);
        expect(
          await reportService.getActiveSemesterLocalId(),
          equals(activeSem.localId),
        );
        final report = await reportService.generateSemesterReport();
        expect(report, isNotNull);
        expect(report!.semesterName, equals('Spring 2027 (Active)'));
        expect(
          report.subjectReports.map((s) => s.subjectName),
          equals(['Distributed Systems']),
        );
        expect(report.overallPercentage, closeTo(50.0, 0.01));

        // 2. AnalyticsService must compute 50% for active semester (not 100% for Old Chemistry)
        final analytics =
            await container.read(analyticsServiceProvider).getAnalytics();
        expect(analytics, isNotNull);
        expect(analytics!.totalClasses, equals(2));
        expect(analytics.overallPercentage, closeTo(50.0, 0.01));

        // 3. IsarNotificationDatabaseImpl must return active semester
        final notifDb = IsarNotificationDatabaseImpl(isar);
        final notifSem = await notifDb.getActiveSemester();
        expect(notifSem, isNotNull);
        expect(notifSem!.id, equals(activeSem.localId));

        // 4. aiContextProvider must return active semester metadata and subjects
        final aiCtx = await container.read(aiContextProvider.future);
        expect(aiCtx.semester['name'], equals('Spring 2027 (Active)'));
        expect(aiCtx.attendanceTarget, equals(85.0));
        expect(
          aiCtx.subjectStatistics.map((s) => s['name']),
          equals(['Distributed Systems']),
        );

        // 5. EventGeneratorService must resolve active semester (which has no templates),
        // NOT Fall 2026 (Old) which has tpl-old.
        final eventGen = EventGeneratorService(isar);
        await eventGen.generateEventsForWholeSemester();
        final generatedForOld =
            isar.eventLocals.where().subjectIdEqualTo(oldSubId).findAll();
        expect(generatedForOld, hasLength(1));

        // 6. Switch active semester back to Fall 2026 (Old) and verify all consumers follow
        await repo.setActiveSemester(oldSem.localId!);
        container.invalidate(activeSemesterProvider);
        container.invalidate(hasActiveSemesterProvider);

        final switchedReport = await container
            .read(reportServiceProvider)
            .generateSemesterReport();
        expect(switchedReport!.semesterName, equals('Fall 2026 (Old)'));
        expect(
          switchedReport.subjectReports.map((s) => s.subjectName),
          equals(['Old Chemistry']),
        );
        expect(switchedReport.overallPercentage, closeTo(100.0, 0.01));

        final switchedAnalytics =
            await container.read(analyticsServiceProvider).getAnalytics();
        expect(switchedAnalytics!.overallPercentage, closeTo(100.0, 0.01));

        expect((await notifDb.getActiveSemester())!.id, equals(oldSem.localId));

        final switchedAi = await container.read(aiContextProvider.future);
        expect(switchedAi.semester['name'], equals('Fall 2026 (Old)'));
        expect(switchedAi.attendanceTarget, equals(75.0));
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });

  group('BUG-017: Settings Semester Management & Onboarding UI', () {
    testWidgets(
        'SettingsPage opens Manage Semesters sheet, creates semester, enforces overlap validation, switches active, and archives',
        (tester) async {
      final fakeRepo = _InMemorySemesterRepository()
        ..seed([
          Semester(
            localId: 1,
            id: 'sem-1',
            name: 'Fall 2026',
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 12, 15),
            requiredAttendanceRate: 75.0,
            status: SemesterStatus.active,
          ),
        ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            semesterRepositoryProvider.overrideWithValue(fakeRepo),
            settingsRepositoryProvider
                .overrideWithValue(_FakeSettingsRepository()),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Active semester summary shown in Settings
      expect(find.text('Semester Management'), findsOneWidget);
      expect(find.text('Fall 2026'), findsOneWidget);
      expect(find.text('Manage (1)'), findsOneWidget);

      // Open Manage Semesters sheet
      await tester
          .tap(find.byKey(const ValueKey<String>('manage_semesters_button')));
      await tester.pumpAndSettle();
      expect(find.text('Manage Semesters'), findsOneWidget);

      // Open New Semester dialog
      await tester.tap(
        find.byKey(const ValueKey<String>('sheet_new_semester_button')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Create Semester'), findsOneWidget);

      // Enter overlapping semester name (default dates are around today 2026-11-10 which overlaps Fall 2026!)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Semester Name'),
        'Overlapping Term',
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Overlap validation prevents save and keeps dialog open with error banner
      expect(find.textContaining('overlap with "Fall 2026"'), findsOneWidget);
      expect(find.text('Create Semester'), findsOneWidget);

      // Cancel dialog and test creating a non-overlapping draft semester
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Add non-overlapping semester directly into fakeRepo and refresh via sheet
      await fakeRepo.createSemester(
        Semester(
          name: 'Spring 2027',
          startDate: DateTime(2027, 1, 10),
          endDate: DateTime(2027, 5, 20),
          requiredAttendanceRate: 80.0,
          status: SemesterStatus.draft,
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      container.invalidate(allSemestersProvider);
      await tester.pumpAndSettle();

      expect(find.text('Spring 2027'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);

      // Activate Spring 2027
      await tester.tap(find.text('Activate').first);
      await tester.pumpAndSettle();

      expect((await fakeRepo.getActiveSemester())!.name, equals('Spring 2027'));
      expect(find.text('Read-only (activate to edit)'), findsOneWidget);

      // Edit active Spring 2027 via Edit button
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();
      expect(find.text('Edit Semester'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Semester Name'),
        'Spring 2027 Edited',
      );
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(
        (await fakeRepo.getActiveSemester())!.name,
        equals('Spring 2027 Edited'),
      );
      expect(find.text('Spring 2027 Edited'), findsNWidgets(2));

      // Archive active Spring 2027 Edited via confirmation dialog
      await tester.tap(find.text('Archive').first);
      await tester.pumpAndSettle();
      expect(find.text('Archive Active Semester?'), findsOneWidget);
      await tester.tap(find.text('Archive').last);
      await tester.pumpAndSettle();

      expect(await fakeRepo.getActiveSemester(), isNull);
    });

    testWidgets(
        'OnboardingPage enforces strict startDate < endDate and completes valid setup',
        (tester) async {
      final fakeRepo = _InMemorySemesterRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            semesterRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: OnboardingPage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'Fall 2026',
      );
      await tester.pump();

      // Pick End Date equal to Start Date (today) -> should reject on Continue
      final today = DateTime.now();
      final defaultEnd = today.add(const Duration(days: 120));
      final formattedToday =
          '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
      final formattedDefaultEnd =
          '${defaultEnd.day.toString().padLeft(2, '0')}/${defaultEnd.month.toString().padLeft(2, '0')}/${defaultEnd.year}';

      await tester.tap(find.text(formattedDefaultEnd));
      await tester.pumpAndSettle();

      final monthsDiff = (defaultEnd.year - today.year) * 12 +
          (defaultEnd.month - today.month);
      for (var i = 0; i < monthsDiff; i++) {
        await tester.tap(find.byTooltip('Previous month'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('${today.day}').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text(formattedToday), findsNWidgets(2));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('End date must be after start date.'), findsOneWidget);
      expect(find.text('Attendance Target'), findsNothing);

      // Now pick a valid end date (start + 1 day or reload fresh widget) and complete setup
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            semesterRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            key: ValueKey<String>('fresh_onboarding'),
            home: OnboardingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'Fall 2026',
      );
      await tester.pump();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Attendance Target'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm Setup'), findsOneWidget);

      fakeRepo.createDelay = const Duration(milliseconds: 50);
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      // Second tap while submitting must be ignored cleanly
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(fakeRepo.createCalls, equals(1));
      expect(find.textContaining('Onboarding failed:'), findsNothing);
      final created = await fakeRepo.getActiveSemester();
      expect(created, isNotNull);
      expect(created!.name, equals('Fall 2026'));
      expect(created.status, equals(SemesterStatus.active));
    });
  });

  group('BUG-017 Edge Case 1: Active semester archiving & zero-active flow',
      () {
    test(
        'archiving the currently active semester leaves zero active semesters cleanly without auto-promoting draft/archived siblings',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug017_ec1_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final repo = SemesterRepositoryImpl(isar);

        await repo.createSemester(
          Semester(
            name: 'Fall 2026',
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 12, 15),
            requiredAttendanceRate: 75.0,
            status: SemesterStatus.active,
          ),
        );
        await repo.createSemester(
          Semester(
            name: 'Spring 2027 (Draft)',
            startDate: DateTime(2027, 1, 10),
            endDate: DateTime(2027, 5, 20),
            requiredAttendanceRate: 80.0,
            status: SemesterStatus.draft,
          ),
        );

        final activeBefore = await repo.getActiveSemester();
        expect(activeBefore, isNotNull);
        expect(activeBefore!.name, equals('Fall 2026'));

        // Archive the currently active semester
        await repo.archiveSemester(activeBefore.localId!);

        // Zero active semesters remain; draft sibling stays draft (not auto-activated)
        expect(await repo.getActiveSemester(), isNull);
        expect(await repo.hasActiveSemester(), isFalse);
        final activeRows = isar.semesterLocals
            .where()
            .isActiveEqualTo(true)
            .isDeletedEqualTo(false)
            .findAll();
        expect(activeRows, isEmpty);

        final allAfter = await repo.getAllSemesters();
        expect(allAfter, hasLength(2));
        expect(
          allAfter.firstWhere((s) => s.name == 'Fall 2026').status,
          equals(SemesterStatus.archived),
        );
        expect(
          allAfter.firstWhere((s) => s.name == 'Spring 2027 (Draft)').status,
          equals(SemesterStatus.draft),
        );

        // Archiving again is idempotent
        await repo.archiveSemester(activeBefore.localId!);
        expect(await repo.getActiveSemester(), isNull);

        // Downstream consumers handle zero active semesters safely
        final container = ProviderContainer(
          overrides: [
            isarProvider.overrideWith((ref) async => isar!),
          ],
        );
        addTearDown(container.dispose);
        await container.read(isarProvider.future);

        final reportService = container.read(reportServiceProvider);
        expect(await reportService.getActiveSemesterLocalId(), isNull);
        expect(await reportService.generateSemesterReport(), isNull);

        final analytics =
            await container.read(analyticsServiceProvider).getAnalytics();
        expect(analytics, isNull);

        final notifDb = IsarNotificationDatabaseImpl(isar);
        expect(await notifDb.getActiveSemester(), isNull);
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    testWidgets(
        'when zero active semesters exist due to archiving, OnboardingPage offers Saved sheet access and reactivation redirects cleanly',
        (tester) async {
      final fakeRepo = _InMemorySemesterRepository()
        ..seed([
          Semester(
            localId: 1,
            id: 'sem-1',
            name: 'Fall 2026',
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 12, 15),
            requiredAttendanceRate: 75.0,
            status: SemesterStatus.active,
          ),
        ]);

      // Archive the sole active semester so 0 active semesters remain.
      await fakeRepo.archiveSemester(1);
      expect(await fakeRepo.hasActiveSemester(), isFalse);

      late GoRouter capturedRouter;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            semesterRepositoryProvider.overrideWithValue(fakeRepo),
            settingsRepositoryProvider
                .overrideWithValue(_FakeSettingsRepository()),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(appRouterProvider);
              capturedRouter = router;
              return MaterialApp.router(routerConfig: router);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // App starts at /splash -> redirects to /onboarding when 0 active semesters exist.
      expect(
        capturedRouter.routerDelegate.currentConfiguration.uri.path,
        equals('/onboarding'),
      );
      expect(find.byType(OnboardingPage), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey<String>('onboarding_manage_semesters_button'),
        ),
        findsOneWidget,
      );
      expect(find.text('Saved (1)'), findsOneWidget);

      // User can open Manage Semesters from Onboarding and reactivate Fall 2026.
      await tester.tap(
        find.byKey(
          const ValueKey<String>('onboarding_manage_semesters_button'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Semesters'), findsOneWidget);
      expect(find.text('Fall 2026'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);

      await tester.tap(find.text('Activate'));
      await tester.pumpAndSettle();

      final reactivated = await fakeRepo.getActiveSemester();
      expect(reactivated, isNotNull);
      expect(reactivated!.name, equals('Fall 2026'));
      expect(reactivated.status, equals(SemesterStatus.active));
      expect(
        capturedRouter.routerDelegate.currentConfiguration.uri.path,
        equals('/dashboard'),
      );
      expect(find.byType(OnboardingPage), findsNothing);
      expect(find.text('Manage Semesters'), findsNothing);
    });
  });

  group('BUG-017 Edge Case 2: Legacy, multi-active, and partial migrations',
      () {
    test(
        'migrates multiple pre-BUG-017 legacy semesters with soft-deleted rows cleanly and remains idempotent across repeated restarts',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug017_ec2_multi_');
      Isar? isar;
      try {
        // Seed 3 non-deleted + 1 soft-deleted pre-BUG-017 legacy records
        final legacyIsar = Isar.open(
          schemas: <IsarGeneratedSchema>[_legacySemesterSchema],
          name: AppConstants.isarDbName,
          directory: tempDir.path,
        );
        legacyIsar.write((db) {
          final col = db.collection<int, _LegacySemesterLocal>();
          col.putAll([
            _LegacySemesterLocal()
              ..id = col.autoIncrement()
              ..serverId = 'leg-1'
              ..name = 'Fall 2024'
              ..startDate = DateTime(2024, 8, 1)
              ..endDate = DateTime(2024, 12, 15)
              ..requiredAttendanceRate = 75.0
              ..createdAt = DateTime.utc(2024, 8, 1)
              ..updatedAt = DateTime.utc(2024, 8, 1),
            _LegacySemesterLocal()
              ..id = col.autoIncrement()
              ..serverId = 'leg-2'
              ..name = 'Spring 2025'
              ..startDate = DateTime(2025, 1, 10)
              ..endDate = DateTime(2025, 5, 20)
              ..requiredAttendanceRate = 80.0
              ..createdAt = DateTime.utc(2025, 1, 10)
              ..updatedAt = DateTime.utc(2025, 1, 10),
            _LegacySemesterLocal()
              ..id = col.autoIncrement()
              ..serverId = 'leg-3'
              ..name = 'Fall 2025'
              ..startDate = DateTime(2025, 8, 1)
              ..endDate = DateTime(2025, 12, 15)
              ..requiredAttendanceRate = 85.0
              ..createdAt = DateTime.utc(2025, 8, 1)
              ..updatedAt = DateTime.utc(2025, 8, 1),
            _LegacySemesterLocal()
              ..id = col.autoIncrement()
              ..serverId = 'leg-del'
              ..name = 'Deleted Sem'
              ..startDate = DateTime(2026, 1, 10)
              ..endDate = DateTime(2026, 5, 20)
              ..requiredAttendanceRate = 75.0
              ..createdAt = DateTime.utc(2026, 1, 10)
              ..updatedAt = DateTime.utc(2026, 1, 10)
              ..isDeleted = true,
          ]);
        });
        legacyIsar.close();

        // Startup #1 via isarProvider
        final container1 = ProviderContainer(
          overrides: [
            databaseDirectoryResolverProvider.overrideWithValue(
              () async => tempDir.path,
            ),
          ],
        );
        final isar1 = await container1.read(isarProvider.future);
        isar = isar1;

        final allRows1 = isar1.semesterLocals.where().findAll();
        expect(allRows1, hasLength(4));

        final activeRow =
            allRows1.where((s) => s.isActive && !s.isDeleted).toList();
        expect(activeRow, hasLength(1));
        expect(activeRow.single.name, equals('Fall 2025'));
        expect(activeRow.single.status, equals(SemesterLocal.statusActive));
        expect(activeRow.single.requiredAttendanceRate, equals(85.0));

        final deletedRow = allRows1.firstWhere((s) => s.serverId == 'leg-del');
        expect(deletedRow.isDeleted, isTrue);
        expect(deletedRow.isActive, isFalse);
        expect(deletedRow.status, equals(SemesterLocal.statusArchived));

        final timestampsAfterFirst = <int, DateTime>{
          for (final row in allRows1) row.id: row.updatedAt,
        };

        isar1.close();
        container1.dispose();
        isar = null;

        // Startup #2 via fresh isarProvider (idempotent no-op)
        final container2 = ProviderContainer(
          overrides: [
            databaseDirectoryResolverProvider.overrideWithValue(
              () async => tempDir.path,
            ),
          ],
        );
        addTearDown(container2.dispose);
        final isar2 = await container2.read(isarProvider.future);
        isar = isar2;

        expect(await migrateLegacySemesters(isar2), equals(0));
        final allRows2 = isar2.semesterLocals.where().findAll();
        expect(allRows2, hasLength(4));
        for (final row in allRows2) {
          expect(row.updatedAt, equals(timestampsAfterFirst[row.id]));
        }
        final repo2 = SemesterRepositoryImpl(isar2);
        final active2 = await repo2.getActiveSemester();
        expect(active2!.name, equals('Fall 2025'));
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
        'normalizes multiple active records, preserves draft/archived semantics, and handles partially migrated records safely without reactivation',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug017_ec2_partial_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final repo = SemesterRepositoryImpl(isar);
        final now = DateTime.utc(2026, 1, 1);

        // Scenario A: Multiple active rows + draft + soft-deleted falsely marked active
        isar.write((db) {
          db.semesterLocals.putAll([
            SemesterLocal()
              ..id = db.semesterLocals.autoIncrement()
              ..serverId = 'act-1'
              ..name = 'Active 1'
              ..startDate = DateTime(2025, 1, 1)
              ..endDate = DateTime(2025, 5, 1)
              ..requiredAttendanceRate = 75.0
              ..status = SemesterLocal.statusActive
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
            SemesterLocal()
              ..id = db.semesterLocals.autoIncrement()
              ..serverId = 'act-2'
              ..name = 'Active 2'
              ..startDate = DateTime(2025, 8, 1)
              ..endDate = DateTime(2025, 12, 1)
              ..requiredAttendanceRate = 75.0
              ..status = SemesterLocal.statusActive
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
            SemesterLocal()
              ..id = db.semesterLocals.autoIncrement()
              ..serverId = 'act-3'
              ..name = 'Active 3 (Latest)'
              ..startDate = DateTime(2026, 1, 10)
              ..endDate = DateTime(2026, 5, 20)
              ..requiredAttendanceRate = 80.0
              ..status = SemesterLocal.statusActive
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
            SemesterLocal()
              ..id = db.semesterLocals.autoIncrement()
              ..serverId = 'draft-1'
              ..name = 'Planned Future'
              ..startDate = DateTime(2026, 8, 1)
              ..endDate = DateTime(2026, 12, 15)
              ..requiredAttendanceRate = 75.0
              ..status = SemesterLocal.statusDraft
              ..isActive = false
              ..createdAt = now
              ..updatedAt = now,
            SemesterLocal()
              ..id = db.semesterLocals.autoIncrement()
              ..serverId = 'del-active'
              ..name = 'Deleted Active'
              ..startDate = DateTime(2024, 1, 1)
              ..endDate = DateTime(2024, 5, 1)
              ..requiredAttendanceRate = 75.0
              ..status = SemesterLocal.statusActive
              ..isActive = true
              ..isDeleted = true
              ..createdAt = now
              ..updatedAt = now,
          ]);
        });

        // Even before migration runs, getAllSemesters must never present 2 active rows
        final preMigrationList = await repo.getAllSemesters();
        expect(
          preMigrationList.where((s) => s.status == SemesterStatus.active),
          hasLength(1),
        );

        // act-1, act-2 archived; del-active fixed
        final fixedCountA = await migrateLegacySemesters(isar);
        expect(fixedCountA, equals(3));
        expect(await migrateLegacySemesters(isar), equals(0));

        final afterA = await repo.getAllSemesters();
        expect(afterA, hasLength(4));
        expect(
          afterA.singleWhere((s) => s.isActive).name,
          equals('Active 3 (Latest)'),
        );
        expect(
          afterA.firstWhere((s) => s.name == 'Planned Future').status,
          equals(SemesterStatus.draft),
        );

        // Scenario B: Partially migrated rows where status is empty (''),
        // one legacy row carries isActive=true and a newer unmigrated row has isActive=false,
        // plus a mismatched archived row (status='archived', isActive=true).
        isar.write((db) {
          db.semesterLocals.clear();
          db.semesterLocals.putAll([
            SemesterLocal()
              ..id = 1
              ..serverId = 'p-intended-active'
              ..name = 'Intended Active'
              ..startDate = DateTime(2025, 8, 1)
              ..endDate = DateTime(2025, 12, 15)
              ..requiredAttendanceRate = 75.0
              ..status = ''
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
            SemesterLocal()
              ..id = 2
              ..serverId = 'p-old-unflagged'
              ..name = 'Unflagged Legacy'
              ..startDate = DateTime(2026, 1, 10)
              ..endDate = DateTime(2026, 5, 20)
              ..requiredAttendanceRate = 75.0
              ..status = ''
              ..isActive = false
              ..createdAt = now
              ..updatedAt = now,
            SemesterLocal()
              ..id = 3
              ..serverId = 'p-mismatched-archived'
              ..name = 'Archived Mismatched'
              ..startDate = DateTime(2024, 8, 1)
              ..endDate = DateTime(2024, 12, 15)
              ..requiredAttendanceRate = 75.0
              ..status = SemesterLocal.statusArchived
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          ]);
        });

        await migrateLegacySemesters(isar);
        expect(await migrateLegacySemesters(isar), equals(0));

        final activeAfterB = await repo.getActiveSemester();
        expect(activeAfterB, isNotNull);
        expect(activeAfterB!.name, equals('Intended Active'));
        expect(
          (await repo.getAllSemesters())
              .firstWhere((s) => s.name == 'Unflagged Legacy')
              .status,
          equals(SemesterStatus.archived),
        );
        expect(
          (await repo.getAllSemesters())
              .firstWhere((s) => s.name == 'Archived Mismatched')
              .status,
          equals(SemesterStatus.archived),
        );

        // Scenario C: Partially migrated DB where ONLY archived/draft rows exist
        // with stale isActive=true flags -> must fix isActive=false without reactivating!
        isar.write((db) {
          db.semesterLocals.clear();
          db.semesterLocals.putAll([
            SemesterLocal()
              ..id = 1
              ..serverId = 'c-arch'
              ..name = 'Archived Stale Flag'
              ..startDate = DateTime(2025, 8, 1)
              ..endDate = DateTime(2025, 12, 15)
              ..requiredAttendanceRate = 75.0
              ..status = SemesterLocal.statusArchived
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
            SemesterLocal()
              ..id = 2
              ..serverId = 'c-draft'
              ..name = 'Draft Stale Flag'
              ..startDate = DateTime(2026, 1, 10)
              ..endDate = DateTime(2026, 5, 20)
              ..requiredAttendanceRate = 80.0
              ..status = SemesterLocal.statusDraft
              ..isActive = true
              ..createdAt = now
              ..updatedAt = now,
          ]);
        });

        await migrateLegacySemesters(isar);
        expect(await migrateLegacySemesters(isar), equals(0));
        expect(await repo.getActiveSemester(), isNull);
        expect(await repo.hasActiveSemester(), isFalse);
        final rowsC = isar.semesterLocals.where().findAll();
        expect(rowsC.every((r) => !r.isActive), isTrue);
        expect(
          rowsC.firstWhere((r) => r.name == 'Draft Stale Flag').status,
          equals(SemesterLocal.statusDraft),
        );
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });

  group('BUG-017 Edge Case 3: BackupImporter & BackupService compatibility',
      () {
    test(
        'BackupImporter restores pre-BUG-017 backup missing status/isActive with single active invariant intact',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug017_ec3_legacy_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final importer = BackupImporter(isar);
        final repo = SemesterRepositoryImpl(isar);

        // Pre-BUG-017 JSON payload: no status or isActive keys on any semester
        final preBug017Json = jsonEncode({
          'metadata': {
            'appVersion': '1.1.0',
            'backupVersion': 1,
            'createdAt': '2026-07-19T00:00:00.000Z',
            'devicePlatform': 'android',
          },
          'userPreferences': <Map<String, dynamic>>[],
          'semesters': [
            {
              'id': 1,
              'serverId': 'old-sem-1',
              'name': 'Fall 2025',
              'startDate': '2025-08-01T00:00:00.000Z',
              'endDate': '2025-12-15T00:00:00.000Z',
              'requiredAttendanceRate': 75.0,
              'createdAt': '2025-08-01T00:00:00.000Z',
              'updatedAt': '2025-08-01T00:00:00.000Z',
              'isDirty': false,
              'isDeleted': false,
            },
            {
              'id': 2,
              'serverId': 'old-sem-2',
              'name': 'Spring 2026',
              'startDate': '2026-01-10T00:00:00.000Z',
              'endDate': '2026-05-20T00:00:00.000Z',
              'requiredAttendanceRate': 80.0,
              'createdAt': '2026-01-10T00:00:00.000Z',
              'updatedAt': '2026-01-10T00:00:00.000Z',
              'isDirty': false,
              'isDeleted': false,
            },
            {
              'id': 3,
              'serverId': 'old-sem-del',
              'name': 'Deleted Sem',
              'startDate': '2024-08-01T00:00:00.000Z',
              'endDate': '2024-12-15T00:00:00.000Z',
              'requiredAttendanceRate': 75.0,
              'createdAt': '2024-08-01T00:00:00.000Z',
              'updatedAt': '2024-08-01T00:00:00.000Z',
              'isDirty': false,
              'isDeleted': true,
            },
          ],
          'subjects': <Map<String, dynamic>>[],
          'attendance': <Map<String, dynamic>>[],
          'timetable': <Map<String, dynamic>>[],
          'events': <Map<String, dynamic>>[],
          'notifications': <Map<String, dynamic>>[],
        });

        await importer.importData(
          preBug017Json,
          strategy: ImportStrategy.replace,
        );

        // Immediately after BackupImporter completes (without restarting app):
        final activeRows =
            isar.semesterLocals.where().isActiveEqualTo(true).findAll();
        expect(activeRows, hasLength(1));
        expect(activeRows.single.name, equals('Spring 2026'));
        expect(activeRows.single.status, equals(SemesterLocal.statusActive));

        final deletedRow = isar.semesterLocals.get(3);
        expect(deletedRow, isNotNull);
        expect(deletedRow!.isDeleted, isTrue);
        expect(deletedRow.isActive, isFalse);
        expect(deletedRow.status, equals(SemesterLocal.statusArchived));

        final activeSem = await repo.getActiveSemester();
        expect(activeSem, isNotNull);
        expect(activeSem!.name, equals('Spring 2026'));

        final allSemesters = await repo.getAllSemesters();
        expect(allSemesters, hasLength(2));
        expect(
          allSemesters.where((s) => s.status == SemesterStatus.active),
          hasLength(1),
        );
        expect(
          allSemesters.firstWhere((s) => s.name == 'Fall 2025').status,
          equals(SemesterStatus.archived),
        );

        // Startup migration must see an already-clean DB (0 writes)
        expect(await migrateLegacySemesters(isar), equals(0));
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        'BackupImporter honors explicit legacy isActive flag when status is missing, preserves all-archived zero-active backups, and keeps single active on merge',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug017_ec3_modes_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final importer = BackupImporter(isar);
        final repo = SemesterRepositoryImpl(isar);

        // 1. Legacy backup missing `status` where `id=1` has `isActive: true`
        //    and `id=2` has `isActive: false` -> id=1 must be restored as active.
        final legacyWithIsActiveJson = jsonEncode({
          'metadata': {
            'appVersion': '1.1.0',
            'backupVersion': 1,
            'createdAt': '2026-07-19T00:00:00.000Z',
            'devicePlatform': 'android',
          },
          'userPreferences': <Map<String, dynamic>>[],
          'semesters': [
            {
              'id': 1,
              'serverId': 'sem-target',
              'name': 'Spring 2026 (Intended Active)',
              'startDate': '2026-01-10T00:00:00.000Z',
              'endDate': '2026-05-20T00:00:00.000Z',
              'requiredAttendanceRate': 75.0,
              'isActive': true,
              'createdAt': '2026-01-10T00:00:00.000Z',
              'updatedAt': '2026-01-10T00:00:00.000Z',
            },
            {
              'id': 2,
              'serverId': 'sem-older',
              'name': 'Fall 2025 (Inactive)',
              'startDate': '2025-08-01T00:00:00.000Z',
              'endDate': '2025-12-15T00:00:00.000Z',
              'requiredAttendanceRate': 75.0,
              'isActive': false,
              'createdAt': '2025-08-01T00:00:00.000Z',
              'updatedAt': '2025-08-01T00:00:00.000Z',
            },
          ],
          'subjects': <Map<String, dynamic>>[],
          'attendance': <Map<String, dynamic>>[],
          'timetable': <Map<String, dynamic>>[],
          'events': <Map<String, dynamic>>[],
          'notifications': <Map<String, dynamic>>[],
        });

        await importer.importData(
          legacyWithIsActiveJson,
          strategy: ImportStrategy.replace,
        );

        final active1 = await repo.getActiveSemester();
        expect(active1, isNotNull);
        expect(active1!.name, equals('Spring 2026 (Intended Active)'));
        expect(active1.status, equals(SemesterStatus.active));
        expect(
          (await repo.getAllSemesters())
              .firstWhere((s) => s.name == 'Fall 2025 (Inactive)')
              .status,
          equals(SemesterStatus.archived),
        );

        // 2. Merge strategy importing another pre-BUG-017 semester must not leave 2 active rows
        final mergeLegacyJson = jsonEncode({
          'metadata': {
            'appVersion': '1.1.0',
            'backupVersion': 1,
            'createdAt': '2026-07-19T00:00:00.000Z',
            'devicePlatform': 'android',
          },
          'userPreferences': <Map<String, dynamic>>[],
          'semesters': [
            {
              'id': 1,
              'serverId': 'sem-merged',
              'name': 'Fall 2026 (Merged Legacy)',
              'startDate': '2026-08-01T00:00:00.000Z',
              'endDate': '2026-12-15T00:00:00.000Z',
              'requiredAttendanceRate': 80.0,
              'createdAt': '2026-08-01T00:00:00.000Z',
              'updatedAt': '2026-08-01T00:00:00.000Z',
            },
          ],
          'subjects': <Map<String, dynamic>>[],
          'attendance': <Map<String, dynamic>>[],
          'timetable': <Map<String, dynamic>>[],
          'events': <Map<String, dynamic>>[],
          'notifications': <Map<String, dynamic>>[],
        });

        await importer.importData(
          mergeLegacyJson,
          strategy: ImportStrategy.merge,
        );

        final activeAfterMergeRows =
            isar.semesterLocals.where().isActiveEqualTo(true).findAll();
        expect(activeAfterMergeRows, hasLength(1));
        expect(
          activeAfterMergeRows.single.name,
          equals('Fall 2026 (Merged Legacy)'),
        );

        // 3. Replace with an all-archived / draft backup keeps zero active semesters
        final zeroActiveJson = jsonEncode({
          'metadata': {
            'appVersion': '1.1.0',
            'backupVersion': 2,
            'createdAt': '2026-07-19T00:00:00.000Z',
            'devicePlatform': 'android',
          },
          'userPreferences': <Map<String, dynamic>>[],
          'semesters': [
            {
              'id': 1,
              'serverId': 'z-arch',
              'name': 'Completed Sem',
              'startDate': '2025-08-01T00:00:00.000Z',
              'endDate': '2025-12-15T00:00:00.000Z',
              'requiredAttendanceRate': 75.0,
              'status': 'archived',
              'isActive': false,
              'createdAt': '2025-08-01T00:00:00.000Z',
              'updatedAt': '2025-08-01T00:00:00.000Z',
            },
            {
              'id': 2,
              'serverId': 'z-draft',
              'name': 'Future Draft Sem',
              'startDate': '2026-08-01T00:00:00.000Z',
              'endDate': '2026-12-15T00:00:00.000Z',
              'requiredAttendanceRate': 75.0,
              'status': 'draft',
              'isActive': false,
              'createdAt': '2026-07-01T00:00:00.000Z',
              'updatedAt': '2026-07-01T00:00:00.000Z',
            },
          ],
          'subjects': <Map<String, dynamic>>[],
          'attendance': <Map<String, dynamic>>[],
          'timetable': <Map<String, dynamic>>[],
          'events': <Map<String, dynamic>>[],
          'notifications': <Map<String, dynamic>>[],
        });

        await importer.importData(
          zeroActiveJson,
          strategy: ImportStrategy.replace,
        );

        expect(await repo.getActiveSemester(), isNull);
        expect(await repo.hasActiveSemester(), isFalse);
        expect(
          (await repo.getAllSemesters())
              .firstWhere((s) => s.name == 'Completed Sem')
              .status,
          equals(SemesterStatus.archived),
        );
        expect(
          (await repo.getAllSemesters())
              .firstWhere((s) => s.name == 'Future Draft Sem')
              .status,
          equals(SemesterStatus.draft),
        );
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
        'BackupService round-trip export and import preserves exact lifecycle states across archived, active, and draft semesters',
        () async {
      if (nativeLibPath == null) return;

      final tempDir =
          await Directory.systemTemp.createTemp('attendiq_bug017_ec3_round_');
      Isar? isar;
      try {
        isar = openTempIsar(tempDir);
        final repo = SemesterRepositoryImpl(isar);
        final backupService = BackupService(isar);

        await repo.createSemester(
          Semester(
            name: 'Archived Sem',
            startDate: DateTime(2025, 8, 1),
            endDate: DateTime(2025, 12, 15),
            requiredAttendanceRate: 75.0,
            status: SemesterStatus.archived,
          ),
        );
        await repo.createSemester(
          Semester(
            name: 'Current Active Sem',
            startDate: DateTime(2026, 1, 10),
            endDate: DateTime(2026, 5, 20),
            requiredAttendanceRate: 80.0,
            status: SemesterStatus.active,
          ),
        );
        await repo.createSemester(
          Semester(
            name: 'Upcoming Draft Sem',
            startDate: DateTime(2026, 8, 1),
            endDate: DateTime(2026, 12, 15),
            requiredAttendanceRate: 85.0,
            status: SemesterStatus.draft,
          ),
        );

        final exportedJson = await backupService.exportBackupString();
        isar.write((db) => db.semesterLocals.clear());
        expect(await repo.getAllSemesters(), isEmpty);

        await backupService.importFromBackupString(
          exportedJson,
          strategy: ImportStrategy.replace,
        );

        final restoredActive = await repo.getActiveSemester();
        expect(restoredActive, isNotNull);
        expect(restoredActive!.name, equals('Current Active Sem'));
        expect(restoredActive.status, equals(SemesterStatus.active));

        final restoredAll = await repo.getAllSemesters();
        expect(restoredAll, hasLength(3));
        expect(
          restoredAll.firstWhere((s) => s.name == 'Archived Sem').status,
          equals(SemesterStatus.archived),
        );
        expect(
          restoredAll.firstWhere((s) => s.name == 'Upcoming Draft Sem').status,
          equals(SemesterStatus.draft),
        );
        expect(await migrateLegacySemesters(isar), equals(0));
      } finally {
        isar?.close();
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });
}
