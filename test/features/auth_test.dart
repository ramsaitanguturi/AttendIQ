import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_test/flutter_test.dart';

// App Imports
import 'package:attend_iq/features/auth/domain/entities/user.dart';
import 'package:attend_iq/features/auth/domain/entities/semester.dart';
import 'package:attend_iq/features/auth/data/models/user_local.dart';
import 'package:attend_iq/features/auth/data/models/semester_local.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attend_iq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:attend_iq/features/auth/data/repositories/semester_repository_impl.dart';
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

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  final Map<String, Map<String, dynamic>> usersCollection = {};
  final Map<String, Map<String, dynamic>> semestersCollection = {};
  bool isOnline = true;

  @override
  Future<fb_auth.UserCredential> registerWithEmailAndPassword({required String email, required String password}) async {
    if (!isOnline) throw Exception('No internet');
    return MockUserCredential('mock_uid_123');
  }

  @override
  Future<fb_auth.UserCredential> loginWithEmailAndPassword({required String email, required String password}) async {
    if (!isOnline) throw Exception('No internet');
    String uid = 'mock_uid_123';
    for (final entry in usersCollection.entries) {
      if (entry.value['email'] == email) {
        uid = entry.key;
        break;
      }
    }
    return MockUserCredential(uid);
  }

  @override
  Future<void> logout() async {}
  @override
  Future<void> sendForgotPasswordEmail({required String email}) async {}

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required DateTime createdAt,
  }) async {
    usersCollection[uid] = {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt,
    };
  }

  @override
  Future<Map<String, dynamic>?> fetchUserProfile({required String uid}) async {
    return usersCollection[uid];
  }

  @override
  Future<String> saveSemester({
    required String uid,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required double requiredAttendanceRate,
    String? serverId,
  }) async {
    if (!isOnline) throw Exception('No internet');
    final id = serverId ?? 'semester_abc';
    semestersCollection[id] = {
      'userId': uid,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'requiredAttendanceRate': requiredAttendanceRate,
      'isDeleted': false,
    };
    return id;
  }

  @override
  Future<void> deleteUserAccount() async {}
}

class MockUserCredential implements fb_auth.UserCredential {
  @override
  final MockUser? user;
  MockUserCredential(String uid) : user = MockUser(uid);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUser implements fb_auth.User {
  @override
  final String uid;
  @override
  final String? displayName;
  MockUser(this.uid, {this.displayName});
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeAuthLocalDataSource localDataSource;
  late FakeAuthRemoteDataSource remoteDataSource;
  late FakeSyncQueue syncQueue;
  late AuthRepositoryImpl authRepository;
  late SemesterRepositoryImpl semesterRepository;

  setUp(() {
    localDataSource = FakeAuthLocalDataSource();
    remoteDataSource = FakeAuthRemoteDataSource();
    syncQueue = FakeSyncQueue();

    authRepository = AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    semesterRepository = SemesterRepositoryImpl(
      localDataSource: localDataSource,
      syncQueue: syncQueue,
    );
  });

  group('Authentication Caching & Profiles', () {
    test('Register stores user locally and remotely', () async {
      const email = 'rohan@test.com';
      const name = 'Rohan';

      final user = await authRepository.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: 'password123',
      );

      expect(user.email, email);
      expect(user.name, name);

      // Verify remote document
      final remoteProfile = remoteDataSource.usersCollection[user.id];
      expect(remoteProfile, isNotNull);
      expect(remoteProfile!['name'], name);

      // Verify local cache
      final cached = await localDataSource.getUser();
      expect(cached, isNotNull);
      expect(cached!.uid, user.id);
      expect(cached.name, name);
    });

    test('Login updates local cache offline-access parameters', () async {
      const email = 'sarah@test.com';
      const name = 'Sarah';
      final uid = 'mock_uid_sarah';

      // Seed remote document
      remoteDataSource.usersCollection[uid] = {
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      };

      final user = await authRepository.loginWithEmailAndPassword(
        email: email,
        password: 'password123',
      );

      expect(user.id, uid);
      expect(user.name, name);

      // Verify local cache
      final cached = await localDataSource.getUser();
      expect(cached, isNotNull);
      expect(cached!.uid, uid);
    });

    test('Logout clears local database user and semester records', () async {
      // Seed user and semester
      await localDataSource.saveUser(UserLocal()
        ..uid = 'user123'
        ..name = 'Rohan'
        ..email = 'rohan@test.com'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false);

      await localDataSource.saveSemester(SemesterLocal()
        ..name = 'Fall 2026'
        ..startDate = DateTime.now()
        ..endDate = DateTime.now().add(const Duration(days: 90))
        ..requiredAttendanceRate = 75.0
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false);

      expect(await localDataSource.getUser(), isNotNull);
      expect(await localDataSource.hasActiveSemester(), isTrue);

      await authRepository.logout();

      expect(await localDataSource.getUser(), isNull);
      expect(await localDataSource.hasActiveSemester(), isFalse);
    });

    test('Offline retrieval succeeds when previously logged in', () async {
      final uid = 'offline_user';
      final localUser = UserLocal()
        ..uid = uid
        ..name = 'Kevin'
        ..email = 'kevin@test.com'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false;

      await localDataSource.saveUser(localUser);

      // Break network connection
      remoteDataSource.isOnline = false;

      final current = await authRepository.getCurrentUser();
      expect(current, isNotNull);
      expect(current!.id, uid);
      expect(current.name, 'Kevin');
    });
  });

  group('Onboarding Setup Flow', () {
    test('Create semester sets local status to dirty and enqueues CREATE sync operation', () async {
      await localDataSource.saveUser(UserLocal()
        ..uid = 'user123'
        ..name = 'Rohan'
        ..email = 'rohan@test.com'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false);

      final start = DateTime.now();
      final end = start.add(const Duration(days: 90));
      final semester = Semester(
        name: 'Spring 2026',
        startDate: start,
        endDate: end,
        requiredAttendanceRate: 80.0,
      );

      await semesterRepository.createSemester(semester);

      // Verify locally cached
      final active = await localDataSource.getActiveSemester();
      expect(active, isNotNull);
      expect(active!.name, 'Spring 2026');
      expect(active.requiredAttendanceRate, 80.0);
      expect(active.isDirty, isTrue); // In outbox flow, this starts as true
      expect(active.serverId, isNotNull); // UUID is generated locally offline

      // Verify Sync Queue has the CREATE operation
      expect(syncQueue.operations.length, 1);
      final op = syncQueue.operations.first;
      expect(op.collectionName, 'semesters');
      expect(op.documentId, active.serverId);
      expect(op.operationType, 'CREATE');
    });
  });
}
