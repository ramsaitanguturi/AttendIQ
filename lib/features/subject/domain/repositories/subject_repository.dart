import '../entities/subject.dart';

abstract class SubjectRepository {
  Future<List<Subject>> getSubjectsBySemester(int semesterId,
      {bool includeDeleted = false});
  Future<Subject?> getSubjectById(int id);
  Future<Subject> createSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(int id);
  Stream<void> watchSubjects(int semesterId);
}
