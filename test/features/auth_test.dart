import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

// App Imports
import 'package:attend_iq/features/auth/domain/entities/semester.dart';
import 'package:attend_iq/features/auth/data/models/user_local.dart';
import 'package:attend_iq/features/auth/data/models/semester_local.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attend_iq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:attend_iq/features/auth/data/repositories/semester_repository_impl.dart';

// Mocks
class MockUserCredential implements fb.UserCredential {
  @override
  final fb.User? user;
  MockUserCredential(this.user);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFbUser implements fb.User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  MockFbUser({required this.uid, this.email, this.displayName});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  final Map<String, Map<String, dynamic>> usersCollection = {};
  final Map<String, Map<String, dynamic>> semestersCollection = {};
  bool isOnline = true;
  fb.User? currentUser;

  @override
  Future<fb.UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isOnline) throw Exception('No network connection');
    final user = MockFbUser(uid: 'mock_uid_${email.split("@")[0]}', email: email);
    currentUser = user;
    return MockUserCredential(user);
  }

  @override
  Future<fb.UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!isOnline) throw Exception('No network connection');
    final user = MockFbUser(uid: 'mock_uid_${email.split("@")[0]}', email: email);
    currentUser = user;
    return MockUserCredential(user);
  }

  @override
  Future<void> logout() async {
    currentUser = null;
  }

  @override
  Future<void> sendForgotPasswordEmail({required String email}) async {
    if (!isOnline) throw Exception('No network connection');
  }

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required DateTime createdAt,
  }) async {
    if (!isOnline) throw Exception('No network connection');
    usersCollection[uid] = {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt,
    };
  }

  @override
  Future<Map<String, dynamic>?> fetchUserProfile({required String uid}) async {
    if (!isOnline) throw Exception('No network connection');
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
    if (!isOnline) throw Exception('No network connection');
    final id = serverId ?? 'mock_semester_id_${DateTime.now().millisecondsSinceEpoch}';
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
}

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  UserLocal? currentUser;
  SemesterLocal? activeSemester;

  @override
  Future<void> saveUser(UserLocal user) async {
    currentUser = user;
  }

  @override
  Future<UserLocal?> getUser() async {
    return currentUser;
  }

  @override
  Future<void> clearUser() async {
    currentUser = null;
    activeSemester = null;
  }

  @override
  Future<void> saveSemester(SemesterLocal semester) async {
    activeSemester = semester;
  }

  @override
  Future<SemesterLocal?> getActiveSemester() async {
    if (activeSemester != null && !activeSemester!.isDeleted) {
      return activeSemester;
    }
    return null;
  }

  @override
  Future<bool> hasActiveSemester() async {
    final active = await getActiveSemester();
    return active != null;
  }
}

void main() {
  late AuthLocalDataSource localDataSource;
  late FakeAuthRemoteDataSource remoteDataSource;
  late AuthRepositoryImpl authRepository;
  late SemesterRepositoryImpl semesterRepository;

  setUp(() {
    localDataSource = FakeAuthLocalDataSource();
    remoteDataSource = FakeAuthRemoteDataSource();

    authRepository = AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    semesterRepository = SemesterRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
  });

  tearDown(() {});

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
        ..updatedAt = DateTime.now());

      await localDataSource.saveSemester(SemesterLocal()
        ..name = 'Fall 2026'
        ..startDate = DateTime.now()
        ..endDate = DateTime.now().add(const Duration(days: 90))
        ..requiredAttendanceRate = 75.0
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
        ..updatedAt = DateTime.now();

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
    test('Create semester sets local status and pushes remotely if online', () async {
      await localDataSource.saveUser(UserLocal()
        ..uid = 'user123'
        ..name = 'Rohan'
        ..email = 'rohan@test.com'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now());

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
      expect(active.isDirty, isFalse); // Should be false because remote succeeded
      expect(active.serverId, isNotNull);

      // Verify remote document
      expect(remoteDataSource.semestersCollection, isNotEmpty);
      final remoteDoc = remoteDataSource.semestersCollection[active.serverId!];
      expect(remoteDoc, isNotNull);
      expect(remoteDoc!['name'], 'Spring 2026');
    });

    test('Create semester caches locally with isDirty=true when remote throws offline', () async {
      await localDataSource.saveUser(UserLocal()
        ..uid = 'user123'
        ..name = 'Rohan'
        ..email = 'rohan@test.com'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now());

      remoteDataSource.isOnline = false; // Go offline

      final start = DateTime.now();
      final end = start.add(const Duration(days: 90));
      final semester = Semester(
        name: 'Spring 2026 (Offline)',
        startDate: start,
        endDate: end,
        requiredAttendanceRate: 80.0,
      );

      await semesterRepository.createSemester(semester);

      // Verify local status
      final active = await localDataSource.getActiveSemester();
      expect(active, isNotNull);
      expect(active!.name, 'Spring 2026 (Offline)');
      expect(active.isDirty, isTrue); // Must be marked dirty
      expect(active.serverId, isNull);
    });
  });
}
