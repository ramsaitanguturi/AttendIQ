import '../entities/semester.dart';

abstract class SemesterRepository {
  Future<void> createSemester(Semester semester);
  Future<void> updateSemester(Semester semester);
  Future<void> setActiveSemester(int localId);
  Future<void> archiveSemester(int localId);
  Future<Semester?> getSemesterById(int localId);
  Future<Semester?> getActiveSemester();
  Future<bool> hasActiveSemester();
  Future<List<Semester>> getAllSemesters();
}
