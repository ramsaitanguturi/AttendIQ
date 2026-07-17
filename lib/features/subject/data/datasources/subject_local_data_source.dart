import 'package:isar/isar.dart';
import '../models/subject_local.dart';

abstract class SubjectLocalDataSource {
  Future<List<SubjectLocal>> getSubjectsBySemester(int semesterId);
  Future<SubjectLocal?> getSubjectById(int id);
  Future<void> saveSubject(SubjectLocal subject);
  Stream<void> watchSubjects(int semesterId);
}

class SubjectLocalDataSourceImpl implements SubjectLocalDataSource {
  final Isar _isar;

  SubjectLocalDataSourceImpl(this._isar);

  @override
  Future<List<SubjectLocal>> getSubjectsBySemester(int semesterId) async {
    return _isar.subjectLocals
        .where()
        .semesterIdEqualTo(semesterId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<SubjectLocal?> getSubjectById(int id) async {
    return _isar.subjectLocals.get(id);
  }

  @override
  Future<void> saveSubject(SubjectLocal subject) async {
    await _isar.writeAsync((isar) {
      if (subject.id == 0) {
        subject.id = isar.subjectLocals.autoIncrement();
      }
      isar.subjectLocals.put(subject);
    });
  }

  @override
  Stream<void> watchSubjects(int semesterId) {
    return _isar.subjectLocals
        .where()
        .semesterIdEqualTo(semesterId)
        .isDeletedEqualTo(false)
        .watch();
  }
}
