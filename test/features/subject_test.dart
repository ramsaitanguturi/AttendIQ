import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

// App Imports
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/subject/data/datasources/subject_local_data_source.dart';
import 'package:attend_iq/features/subject/data/repositories/subject_repository_impl.dart';
import 'package:attend_iq/features/auth/data/models/user_local.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_local_data_source.dart';
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

class FakeSubjectLocalDataSource implements SubjectLocalDataSource {
  final Map<int, SubjectLocal> subjects = {};
  int _nextId = 1;

  @override
  Future<List<SubjectLocal>> getSubjectsBySemester(int semesterId) async {
    return subjects.values
        .where((s) => s.semesterId == semesterId && !s.isDeleted)
        .toList();
  }

  @override
  Future<SubjectLocal?> getSubjectById(int id) async {
    return subjects[id];
  }

  @override
  Future<void> saveSubject(SubjectLocal subject) async {
    if (subject.id == 0) {
      subject.id = _nextId++;
    }
    subjects[subject.id] = subject;
  }
}

void main() {
  late FakeAuthLocalDataSource authLocalDataSource;
  late FakeSubjectLocalDataSource localDataSource;
  late FakeSyncQueue syncQueue;
  late SubjectRepositoryImpl repository;

  setUp(() {
    authLocalDataSource = FakeAuthLocalDataSource();
    localDataSource = FakeSubjectLocalDataSource();
    syncQueue = FakeSyncQueue();

    repository = SubjectRepositoryImpl(
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
  });

  group('Subject CRUD Operations', () {
    test('Create Subject saves locally and enqueues CREATE operation in SyncQueue', () async {
      final subject = Subject(
        semesterId: 1,
        name: 'Mathematics IV',
        code: 'MATH-401',
        credits: 4,
        attendanceTarget: 75.0,
        color: '#FF5733',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now(),
      );

      await repository.createSubject(subject);

      // Verify locally saved with ID
      final list = await repository.getSubjectsBySemester(1);
      expect(list.length, 1);
      expect(list.first.name, 'Mathematics IV');
      expect(list.first.id, 1);
      expect(list.first.serverId, isNotNull); // UUID is generated locally offline
      expect(list.first.isDirty, isTrue); // Set to dirty for outbox sync

      // Verify enqueued sync operation
      expect(syncQueue.operations.length, 1);
      final op = syncQueue.operations.first;
      expect(op.collectionName, 'subjects');
      expect(op.documentId, list.first.serverId);
      expect(op.operationType, 'CREATE');
    });

    test('Update Subject modifications persist and enqueue UPDATE operation', () async {
      final subject = Subject(
        semesterId: 1,
        name: 'Chemistry',
        code: 'CHEM-101',
        credits: 3,
        attendanceTarget: 75.0,
        color: '#3357FF',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now(),
      );

      await repository.createSubject(subject);
      final created = (await repository.getSubjectsBySemester(1)).first;

      final updatedSubject = created.copyWith(
        name: 'Advanced Chemistry',
        credits: 4,
      );

      await repository.updateSubject(updatedSubject);

      final updatedList = await repository.getSubjectsBySemester(1);
      expect(updatedList.first.name, 'Advanced Chemistry');
      expect(updatedList.first.credits, 4);

      // Verify UPDATE operation enqueued (1 from create, 1 from update = 2)
      expect(syncQueue.operations.length, 2);
      expect(syncQueue.operations.last.operationType, 'UPDATE');
    });

    test('Delete Subject flags isDeleted=true (Soft Delete) and enqueues DELETE operation', () async {
      final subject = Subject(
        semesterId: 1,
        name: 'History',
        code: 'HIST-301',
        credits: 3,
        attendanceTarget: 75.0,
        color: '#E0E0E0',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now(),
      );

      await repository.createSubject(subject);
      final created = (await repository.getSubjectsBySemester(1)).first;

      await repository.deleteSubject(created.id!);

      // Should not be returned by getSubjectsBySemester (hidden from active view)
      final list = await repository.getSubjectsBySemester(1);
      expect(list, isEmpty);

      // Verify the record is still in local database but marked isDeleted = true
      final rawLocal = await localDataSource.getSubjectById(created.id!);
      expect(rawLocal, isNotNull);
      expect(rawLocal!.isDeleted, isTrue);

      // Verify DELETE operation enqueued (1 from create, 1 from delete = 2)
      expect(syncQueue.operations.length, 2);
      expect(syncQueue.operations.last.operationType, 'DELETE');
    });
  });
}
