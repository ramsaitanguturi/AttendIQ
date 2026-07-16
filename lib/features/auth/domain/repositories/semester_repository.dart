import '../entities/semester.dart';

abstract class SemesterRepository {
  Future<void> createSemester(Semester semester);
  Future<Semester?> getActiveSemester();
  Future<bool> hasActiveSemester();
}
