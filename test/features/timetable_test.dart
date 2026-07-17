import 'package:flutter_test/flutter_test.dart';

// App Imports
import 'package:attend_iq/features/timetable/domain/entities/timetable_template.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/timetable/data/datasources/timetable_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/repositories/timetable_repository_impl.dart';
import 'package:attend_iq/features/auth/data/models/user_local.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/core/sync/sync_queue/sync_queue.dart';
import 'package:attend_iq/core/sync/models/sync_operation.dart';

// Fakes
class FakeSyncQueue implements SyncQueue {
  final List<SyncOperation> operations = [];
  int _nextId = 1;

  @override
  Future<void> enqueue({
    required String collectionName,
    required String documentId,
    required String operationType,
    required String payload,
  }) async {
    operations.add(SyncOperation()
      ..id = _nextId++
      ..collectionName = collectionName
      ..documentId = documentId
      ..operationType = operationType
      ..payload = payload
      ..createdAt = DateTime.now().toUtc()
      ..retryCount = 0);
  }

  @override
  Future<List<SyncOperation>> getPendingOperations() async => operations;
  @override
  Future<void> remove(int id) async => operations.removeWhere((op) => op.id == id);
  @override
  Future<void> incrementRetryCount(int id) async {}
}

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  UserLocal? currentUser;

  @override
  Future<void> saveUser(UserLocal user) async => currentUser = user;
  @override
  Future<UserLocal?> getUser() async => currentUser;
  @override
  Future<void> clearUser() async => currentUser = null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTimetableLocalDataSource implements TimetableLocalDataSource {
  final Map<int, TimetableTemplateLocal> templates = {};
  final List<SubjectLocal> subjects = [];
  int _nextId = 1;

  @override
  Future<List<TimetableTemplateLocal>> getTemplatesForSubject(int subjectId) async {
    return templates.values
        .where((t) => t.subjectId == subjectId && !t.isDeleted)
        .toList();
  }

  @override
  Future<List<TimetableTemplateLocal>> getTemplatesForSemester(int semesterId) async {
    final subjectIds = subjects
        .where((s) => s.semesterId == semesterId && !s.isDeleted)
        .map((s) => s.id)
        .toSet();
    if (subjectIds.isEmpty) return [];

    return templates.values
        .where((t) => subjectIds.contains(t.subjectId) && !t.isDeleted)
        .toList();
  }

  @override
  Future<TimetableTemplateLocal?> getTemplateById(int id) async => templates[id];

  @override
  Future<void> saveTemplate(TimetableTemplateLocal template) async {
    if (template.id == 0) {
      template.id = _nextId++;
    }
    templates[template.id] = template;
  }

  @override
  Stream<void> watchTemplates(int semesterId) {
    return const Stream.empty();
  }
}

void main() {
  late FakeAuthLocalDataSource authLocalDataSource;
  late FakeTimetableLocalDataSource localDataSource;
  late FakeSyncQueue syncQueue;
  late TimetableRepositoryImpl repository;

  setUp(() {
    authLocalDataSource = FakeAuthLocalDataSource();
    localDataSource = FakeTimetableLocalDataSource();
    syncQueue = FakeSyncQueue();

    repository = TimetableRepositoryImpl(
      localDataSource: localDataSource,
      syncQueue: syncQueue,
    );

    // Seed mock user
    authLocalDataSource.saveUser(UserLocal()
      ..uid = 'user_abc'
      ..name = 'Rohan'
      ..email = 'rohan@test.com'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now());

    // Seed mock subjects in the fake datasource
    localDataSource.subjects.addAll([
      SubjectLocal()
        ..id = 5
        ..semesterId = 1
        ..name = 'Maths'
        ..code = 'M101'
        ..credits = 4
        ..color = '#FFFFFF'
        ..attendanceTarget = 75.0
        ..type = 'THEORY'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false,
      SubjectLocal()
        ..id = 6
        ..semesterId = 1
        ..name = 'Physics'
        ..code = 'P101'
        ..credits = 3
        ..color = '#000000'
        ..attendanceTarget = 75.0
        ..type = 'LAB'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false,
    ]);
  });

  group('Timetable Template CRUD Tests', () {
    test('saveTemplate persists locally and enqueues CREATE sync operation', () async {
      final template = TimetableTemplate(
        subjectId: 5,
        weekday: 1,
        startTime: '09:00',
        endTime: '09:55',
        room: 'Room 301',
        faculty: 'Dr. Prasad',
        updatedAt: DateTime.now(),
      );

      await repository.saveTemplate(template);

      final list = await repository.getTemplatesForSemester(1);
      expect(list.length, 1);
      expect(list.first.subjectId, 5);
      expect(list.first.room, 'Room 301');
      expect(list.first.serverId, isNotNull); // Generated offline UUID
      expect(list.first.isDirty, isTrue);

      expect(syncQueue.operations.length, 1);
      expect(syncQueue.operations.first.operationType, 'CREATE');
    });

    test('deleteTemplate marks local isDeleted=true and enqueues DELETE sync operation', () async {
      final template = TimetableTemplate(
        subjectId: 6,
        weekday: 2,
        startTime: '10:00',
        endTime: '11:00',
        room: 'Lab 2',
        updatedAt: DateTime.now(),
      );

      await repository.saveTemplate(template);
      final created = (await repository.getTemplatesForSemester(1)).first;

      await repository.deleteTemplate(created.id!);

      final activeList = await repository.getTemplatesForSemester(1);
      expect(activeList, isEmpty);

      final rawLocal = await localDataSource.getTemplateById(created.id!);
      expect(rawLocal, isNotNull);
      expect(rawLocal!.isDeleted, isTrue);

      expect(syncQueue.operations.length, 2);
      expect(syncQueue.operations.last.operationType, 'DELETE');
    });
  });
}
