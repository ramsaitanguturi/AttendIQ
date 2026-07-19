import '../entities/semester.dart';
import '../repositories/semester_repository.dart';

class CreateSemesterUseCase {
  final SemesterRepository repository;

  CreateSemesterUseCase(this.repository);

  Future<void> call(Semester semester) async {
    return repository.createSemester(semester);
  }
}
