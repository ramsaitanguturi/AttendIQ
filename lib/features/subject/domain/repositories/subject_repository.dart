import '../entities/subject.dart';

abstract class SubjectRepository {
  Future<List<Subject>> getSubjectsBySemester(int semesterId);
  Future<Subject?> getSubjectById(int id);
  Future<void> createSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(int id);
}
