// ignore_for_file: subtype_of_sealed_class

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/core/sync/models/sync_operation.dart';
import 'package:attend_iq/core/sync/models/sync_mappers.dart';
import 'package:attend_iq/core/sync/sync_queue/sync_queue.dart';
import 'package:attend_iq/core/sync/sync_manager/sync_manager.dart';
import 'package:attend_iq/core/sync/sync_manager/firebase_sync_service.dart';

import 'package:attend_iq/features/auth/data/models/semester_local.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/data/repositories/subject_repository_impl.dart';
import 'package:attend_iq/features/auth/data/models/user_local.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:attend_iq/features/subject/data/datasources/subject_local_data_source.dart';

// Mocks & Fakes

class FakeSyncQueue implements SyncQueue {
  final List<SyncOperation> operations = [];
  final List<FailedSyncOperation> failedOperations = [];
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
  Future<List<SyncOperation>> getPendingOperations() async {
    return List.from(operations);
  }

  @override
  Future<void> remove(int id) async {
    operations.removeWhere((op) => op.id == id);
  }

  @override
  Future<void> incrementRetryCount(int id) async {
    final idx = operations.indexWhere((op) => op.id == id);
    if (idx != -1) {
      operations[idx].retryCount += 1;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirebaseSyncService implements FirebaseSyncService {
  final Map<String, Map<String, dynamic>> firestoreDb = {};
  bool isOnline = true;
  String? mockUserId = 'user_123';
  String? triggerErrorType; // 'network', 'permission-denied'

  @override
  String? get currentUserId => mockUserId;

  @override
  Future<DocumentSnapshot> fetchRemoteDocument(String collectionName, String docId) async {
    if (!isOnline) throw Exception('Network unreachable');
    if (triggerErrorType == 'network') throw Exception('Timeout');
    if (triggerErrorType == 'permission-denied') {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions',
      );
    }
    
    final key = '$collectionName/$docId';
    final data = firestoreDb[key];
    return MockDocumentSnapshot(docId, data);
  }

  @override
  Future<void> saveDocument(String collectionName, String docId, Map<String, dynamic> data) async {
    if (!isOnline) throw Exception('Network unreachable');
    if (triggerErrorType == 'network') throw Exception('Timeout');
    if (triggerErrorType == 'permission-denied') {
      throw FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
        message: 'Missing or insufficient permissions',
      );
    }
    final key = '$collectionName/$docId';
    firestoreDb[key] = data;
  }

  @override
  Future<void> deleteDocument(String collectionName, String docId) async {
    if (!isOnline) throw Exception('Network unreachable');
    final key = '$collectionName/$docId';
    if (firestoreDb.containsKey(key)) {
      firestoreDb[key]!['isDeleted'] = true;
      firestoreDb[key]!['updatedAt'] = Timestamp.fromDate(DateTime.now().toUtc());
    }
  }
}

class MockDocumentSnapshot implements DocumentSnapshot {
  @override
  final String id;
  final Map<String, dynamic>? _data;

  MockDocumentSnapshot(this.id, this._data);

  @override
  bool get exists => _data != null;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  UserLocal? currentUser;
  SemesterLocal? activeSemester;

  @override
  Future<void> saveUser(UserLocal user) async => currentUser = user;
  @override
  Future<UserLocal?> getUser() async => currentUser;
  @override
  Future<void> clearUser() async {
    currentUser = null;
    activeSemester = null;
  }
  @override
  Future<void> saveSemester(SemesterLocal semester) async => activeSemester = semester;
  @override
  Future<SemesterLocal?> getActiveSemester() async => activeSemester;
  @override
  Future<bool> hasActiveSemester() async => activeSemester != null;
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
  Future<SubjectLocal?> getSubjectById(int id) async => subjects[id];

  @override
  Future<void> saveSubject(SubjectLocal subject) async {
    if (subject.id == 0) {
      subject.id = _nextId++;
    }
    subjects[subject.id] = subject;
  }

  @override
  Stream<void> watchSubjects(int semesterId) {
    return const Stream.empty();
  }
}

// Testable SyncManager subclass to bypass Isar native dll loading
class TestSyncManager extends SyncManager {
  final Map<String, Map<String, dynamic>> localDatabase = {};
  final List<FailedSyncOperation> localFailedOps = [];
  final FakeFirebaseSyncService remoteSyncService;

  TestSyncManager(FakeSyncQueue syncQueue, this.remoteSyncService)
      : super(null, syncQueue, remoteSyncService);

  @override
  void initConnectivityListener() {
    // Override to prevent Connectivity listeners in tests
  }

  @override
  Future<bool> checkConnectivity() async {
    return remoteSyncService.isOnline;
  }

  @override
  Future<void> writeToLocalDatabase(FutureOr<void> Function(Isar? isar) callback) async {
    await callback(null);
  }

  @override
  Future<dynamic> fetchLocalModel(String collectionName, String serverId) async {
    final key = '$collectionName/$serverId';
    final data = localDatabase[key];
    if (data == null) return null;

    switch (collectionName) {
      case 'semesters':
        return SemesterLocalMapper.fromMap(data);
      case 'subjects':
        return SubjectLocalMapper.fromMap(data);
    }
    return null;
  }

  @override
  void putLocalModel(dynamic isar, String collectionName, dynamic model) {
    final serverId = model.serverId;
    final key = '$collectionName/$serverId';
    localDatabase[key] = _modelToMap(collectionName, model);
  }

  @override
  Future<void> deleteLocalRecord(String collectionName, String serverId) async {
    final key = '$collectionName/$serverId';
    localDatabase.remove(key);
  }

  @override
  Future<void> overwriteLocalRecord(String collectionName, String serverId, Map<String, dynamic> remoteData) async {
    final key = '$collectionName/$serverId';
    final localData = Map<String, dynamic>.from(remoteData);
    
    for (final field in ['updatedAt', 'createdAt', 'startDate', 'endDate']) {
      if (localData[field] is Timestamp) {
        localData[field] = (localData[field] as Timestamp).toDate().toUtc().toIso8601String();
      }
    }
    localDatabase[key] = localData;
  }

  @override
  Future<void> isolatePoisonPill(SyncOperation op, String error) async {
    localFailedOps.add(FailedSyncOperation()
      ..collectionName = op.collectionName
      ..documentId = op.documentId
      ..operationType = op.operationType
      ..payload = op.payload
      ..createdAt = op.createdAt
      ..error = error);
  }

  @override
  Future<Map<String, dynamic>> translatePayload(String collectionName, Map<String, dynamic> localPayload, dynamic isar, String userId) async {
    final result = Map<String, dynamic>.from(localPayload);
    result['userId'] = userId;
    result.remove('id');
    result.remove('serverId');
    
    // Parse Iso dates to Timestamps for Firestore simulation
    if (result.containsKey('createdAt')) {
      result['createdAt'] = Timestamp.fromDate(DateTime.parse(result['createdAt'] as String));
    }
    if (result.containsKey('updatedAt')) {
      result['updatedAt'] = Timestamp.fromDate(DateTime.parse(result['updatedAt'] as String));
    }
    if (result.containsKey('startDate')) {
      result['startDate'] = Timestamp.fromDate(DateTime.parse(result['startDate'] as String));
    }
    if (result.containsKey('endDate')) {
      result['endDate'] = Timestamp.fromDate(DateTime.parse(result['endDate'] as String));
    }
    
    return result;
  }

  Map<String, dynamic> _modelToMap(String collectionName, dynamic model) {
    if (model is SemesterLocal) return model.toMap();
    if (model is SubjectLocal) return model.toMap();
    return {};
  }
}

// Unit Tests Main
void main() {
  group('Part 1 & 3: Offline Create & Outbox Queue Creation', () {
    late FakeSubjectLocalDataSource localDataSource;
    late FakeSyncQueue syncQueue;
    late SubjectRepositoryImpl repository;

    setUp(() {
      localDataSource = FakeSubjectLocalDataSource();
      syncQueue = FakeSyncQueue();
      repository = SubjectRepositoryImpl(
        localDataSource: localDataSource,
        syncQueue: syncQueue,
      );
    });

    test('Create Subject offline registers immediately locally and enqueues CREATE op', () async {
      final subject = Subject(
        semesterId: 1,
        name: 'Distributed Systems',
        code: 'CS-402',
        credits: 4,
        attendanceTarget: 75.0,
        color: '#FF5733',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now().toUtc(),
      );

      await repository.createSubject(subject);

      // 1. Verify Local write is completed
      final list = await repository.getSubjectsBySemester(1);
      expect(list.length, 1);
      final savedLocal = list.first;
      expect(savedLocal.name, 'Distributed Systems');
      expect(savedLocal.serverId, isNotNull); // UUID generated offline
      expect(savedLocal.isDirty, isTrue);

      // 2. Verify Sync Queue operation is enqueued
      expect(syncQueue.operations.length, 1);
      final op = syncQueue.operations.first;
      expect(op.collectionName, 'subjects');
      expect(op.documentId, savedLocal.serverId);
      expect(op.operationType, 'CREATE');
      
      final payloadMap = jsonDecode(op.payload);
      expect(payloadMap['name'], 'Distributed Systems');
    });
  });

  group('Part 4, 5, 6: Sync Manager, Upload, Retries & Conflict Resolution', () {
    late FakeSyncQueue syncQueue;
    late FakeFirebaseSyncService firebaseSyncService;
    late TestSyncManager syncManager;

    setUp(() {
      syncQueue = FakeSyncQueue();
      firebaseSyncService = FakeFirebaseSyncService();
      syncManager = TestSyncManager(syncQueue, firebaseSyncService);
    });

    test('Successful sync processes queue and cleans local flags', () async {
      // 1. Setup local state
      final serverId = 'sem_999';
      final now = DateTime.now().toUtc();
      final localSem = SemesterLocal()
        ..serverId = serverId
        ..name = 'Spring 2026'
        ..startDate = now
        ..endDate = now.add(const Duration(days: 120))
        ..requiredAttendanceRate = 75.0
        ..createdAt = now
        ..updatedAt = now
        ..isDirty = true
        ..isDeleted = false;

      syncManager.localDatabase['semesters/$serverId'] = localSem.toMap();

      // 2. Enqueue CREATE operation
      await syncQueue.enqueue(
        collectionName: 'semesters',
        documentId: serverId,
        operationType: 'CREATE',
        payload: jsonEncode(localSem.toMap()),
      );

      expect(syncQueue.operations.length, 1);

      // 3. Trigger sync
      await syncManager.sync();

      // 4. Verify sync completion
      expect(syncQueue.operations, isEmpty); // Queue processed and cleared
      expect(firebaseSyncService.firestoreDb['semesters/$serverId'], isNotNull); // Remote document saved
      expect(firebaseSyncService.firestoreDb['semesters/$serverId']!['name'], 'Spring 2026');

      // Local database is marked isDirty = false
      final finalLocal = await syncManager.fetchLocalModel('semesters', serverId) as SemesterLocal?;
      expect(finalLocal, isNotNull);
      expect(finalLocal!.isDirty, isFalse);
    });

    test('Temporary network failure stops queue and increments retryCount', () async {
      firebaseSyncService.triggerErrorType = 'network'; // Simulate temporary error

      final serverId = 'sem_999';
      final now = DateTime.now().toUtc();
      final localSem = SemesterLocal()
        ..serverId = serverId
        ..name = 'Spring 2026'
        ..startDate = now
        ..endDate = now
        ..requiredAttendanceRate = 75.0
        ..createdAt = now
        ..updatedAt = now
        ..isDirty = true
        ..isDeleted = false;

      await syncQueue.enqueue(
        collectionName: 'semesters',
        documentId: serverId,
        operationType: 'CREATE',
        payload: jsonEncode(localSem.toMap()),
      );

      // Run sync, which will throw temporary error
      await syncManager.sync();

      // Verify operation is NOT removed but retryCount is incremented
      expect(syncQueue.operations.length, 1);
      expect(syncQueue.operations.first.retryCount, 1);
      expect(syncManager.localFailedOps, isEmpty); // No poison pills logged
    });

    test('Poison pill isolation moves bad operations to failed logs', () async {
      firebaseSyncService.triggerErrorType = 'permission-denied'; // Simulate rules reject

      final serverId = 'sem_999';
      final now = DateTime.now().toUtc();
      final localSem = SemesterLocal()
        ..serverId = serverId
        ..name = 'Forbidden Semester'
        ..startDate = now
        ..endDate = now
        ..requiredAttendanceRate = 75.0
        ..createdAt = now
        ..updatedAt = now
        ..isDirty = true
        ..isDeleted = false;

      await syncQueue.enqueue(
        collectionName: 'semesters',
        documentId: serverId,
        operationType: 'CREATE',
        payload: jsonEncode(localSem.toMap()),
      );

      await syncManager.sync();

      // Verify operation was removed from main queue and isolated to failed ops
      expect(syncQueue.operations, isEmpty);
      expect(syncManager.localFailedOps.length, 1);
      expect(syncManager.localFailedOps.first.documentId, serverId);
      expect(syncManager.localFailedOps.first.error, contains('permission-denied'));
    });

    test('Conflict Resolution: Local wins when local.updatedAt is newer than remote.updatedAt', () async {
      final serverId = 'sem_999';
      final now = DateTime.now().toUtc();
      
      final localUpdatedAt = now.add(const Duration(minutes: 10));
      final remoteUpdatedAt = now;

      // Local is newer
      final localSem = SemesterLocal()
        ..serverId = serverId
        ..name = 'Semester Local Wins'
        ..startDate = now
        ..endDate = now
        ..requiredAttendanceRate = 75.0
        ..createdAt = now
        ..updatedAt = localUpdatedAt
        ..isDirty = true
        ..isDeleted = false;

      syncManager.localDatabase['semesters/$serverId'] = localSem.toMap();

      // Seed remote document in fake Firestore (older updatedAt)
      firebaseSyncService.firestoreDb['semesters/$serverId'] = {
        'name': 'Semester Remote Old',
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(now),
        'requiredAttendanceRate': 75.0,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(remoteUpdatedAt),
        'isDeleted': false,
      };

      await syncQueue.enqueue(
        collectionName: 'semesters',
        documentId: serverId,
        operationType: 'UPDATE',
        payload: jsonEncode(localSem.toMap()),
      );

      await syncManager.sync();

      // Local wins -> Firestore is overwritten by local name
      final finalRemote = firebaseSyncService.firestoreDb['semesters/$serverId'];
      expect(finalRemote, isNotNull);
      expect(finalRemote!['name'], 'Semester Local Wins');
    });

    test('Conflict Resolution: Remote wins when remote.updatedAt is newer than local.updatedAt', () async {
      final serverId = 'sem_999';
      final now = DateTime.now().toUtc();
      
      final localUpdatedAt = now;
      final remoteUpdatedAt = now.add(const Duration(minutes: 10));

      // Local is older
      final localSem = SemesterLocal()
        ..serverId = serverId
        ..name = 'Semester Local Old'
        ..startDate = now
        ..endDate = now
        ..requiredAttendanceRate = 75.0
        ..createdAt = now
        ..updatedAt = localUpdatedAt
        ..isDirty = true
        ..isDeleted = false;

      syncManager.localDatabase['semesters/$serverId'] = localSem.toMap();

      // Seed remote document in fake Firestore (newer updatedAt)
      firebaseSyncService.firestoreDb['semesters/$serverId'] = {
        'name': 'Semester Remote Wins',
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(now),
        'requiredAttendanceRate': 80.0,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(remoteUpdatedAt),
        'isDeleted': false,
      };

      await syncQueue.enqueue(
        collectionName: 'semesters',
        documentId: serverId,
        operationType: 'UPDATE',
        payload: jsonEncode(localSem.toMap()),
      );

      await syncManager.sync();

      // Remote wins -> Local database is overwritten by remote values and marked clean
      final finalLocal = await syncManager.fetchLocalModel('semesters', serverId) as SemesterLocal?;
      expect(finalLocal, isNotNull);
      expect(finalLocal!.name, 'Semester Remote Wins');
      expect(finalLocal.requiredAttendanceRate, 80.0);
      expect(finalLocal.isDirty, isFalse);
    });
  });
}
