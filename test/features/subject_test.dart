import 'package:flutter_test/flutter_test.dart';

import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';
import 'package:attend_iq/features/subject/data/datasources/subject_local_data_source.dart';
import 'package:attend_iq/features/subject/data/repositories/subject_repository_impl.dart';

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

  @override
  Stream<void> watchSubjects(int semesterId) {
    return const Stream.empty();
  }
}

void main() {
  late FakeSubjectLocalDataSource localDataSource;
  late SubjectRepositoryImpl repository;

  setUp(() {
    localDataSource = FakeSubjectLocalDataSource();
    repository = SubjectRepositoryImpl(
      localDataSource: localDataSource,
    );
  });

  group('Subject CRUD Operations', () {
    test('Create Subject saves locally', () async {
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

      final list = await repository.getSubjectsBySemester(1);
      expect(list.length, 1);
      expect(list.first.name, 'Mathematics IV');
      expect(list.first.id, 1);
      expect(list.first.serverId, isNotNull);
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

      final list = await repository.getSubjectsBySemester(1);
      expect(list, isEmpty);

      final rawLocal = await localDataSource.getSubjectById(created.id!);
      expect(rawLocal, isNotNull);
      expect(rawLocal!.isDeleted, isTrue);
    });
  });
}
