import 'package:flutter_test/flutter_test.dart';

// App Imports
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/subject/data/datasources/subject_local_data_source.dart';
import 'package:attend_iq/features/subject/data/datasources/subject_remote_data_source.dart';
import 'package:attend_iq/features/subject/data/repositories/subject_repository_impl.dart';
import 'package:attend_iq/features/auth/data/models/user_local.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_local_data_source.dart';

// Fakes
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

class FakeSubjectRemoteDataSource implements SubjectRemoteDataSource {
  final Map<String, Map<String, dynamic>> subjectsCollection = {};
  bool isOnline = true;

  @override
  Future<String> saveSubject({
    required String uid,
    required String semesterId,
    required String name,
    required String code,
    String? faculty,
    required int credits,
    required double attendanceTarget,
    required String color,
    required String type,
    String? serverId,
  }) async {
    if (!isOnline) throw Exception('No network connection');
    final id = serverId ?? 'mock_sub_${DateTime.now().millisecondsSinceEpoch}_${subjectsCollection.length}';
    subjectsCollection[id] = {
      'userId': uid,
      'semesterId': semesterId,
      'name': name,
      'courseCode': code,
      'instructor': faculty,
      'credits': credits,
      'colorHex': color,
      'requiredAttendanceOverride': attendanceTarget,
      'type': type,
      'isDeleted': false,
    };
    return id;
  }

  @override
  Future<void> deleteSubject(String serverId) async {
    if (!isOnline) throw Exception('No network connection');
    if (subjectsCollection.containsKey(serverId)) {
      subjectsCollection[serverId]!['isDeleted'] = true;
    }
  }
}

void main() {
  late FakeAuthLocalDataSource authLocalDataSource;
  late FakeSubjectLocalDataSource localDataSource;
  late FakeSubjectRemoteDataSource remoteDataSource;
  late SubjectRepositoryImpl repository;

  setUp(() {
    authLocalDataSource = FakeAuthLocalDataSource();
    localDataSource = FakeSubjectLocalDataSource();
    remoteDataSource = FakeSubjectRemoteDataSource();

    repository = SubjectRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      authLocalDataSource: authLocalDataSource,
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
    test('Create Subject saves locally and remotely when online', () async {
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
      expect(list.first.serverId, isNotNull);
      expect(list.first.isDirty, isFalse);

      // Verify remote document
      final remoteId = list.first.serverId!;
      final remoteDoc = remoteDataSource.subjectsCollection[remoteId];
      expect(remoteDoc, isNotNull);
      expect(remoteDoc!['name'], 'Mathematics IV');
      expect(remoteDoc['courseCode'], 'MATH-401');
    });

    test('Create Subject sets isDirty=true and serverId=null when offline', () async {
      remoteDataSource.isOnline = false;

      final subject = Subject(
        semesterId: 1,
        name: 'Physics Lab',
        code: 'PHYS-202',
        credits: 2,
        attendanceTarget: 80.0,
        color: '#33FF57',
        type: SubjectType.LAB,
        updatedAt: DateTime.now(),
      );

      await repository.createSubject(subject);

      final list = await repository.getSubjectsBySemester(1);
      expect(list.length, 1);
      expect(list.first.serverId, isNull);
      expect(list.first.isDirty, isTrue);
    });

    test('Update Subject modifications persist', () async {
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
    });

    test('Delete Subject flags isDeleted=true (Soft Delete)', () async {
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
    });
  });
}
