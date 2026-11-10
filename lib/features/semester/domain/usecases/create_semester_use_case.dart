import '../entities/semester.dart';
import '../repositories/semester_repository.dart';
import '../validators/semester_validator.dart';

class CreateSemesterUseCase {
  final SemesterRepository repository;

  CreateSemesterUseCase(this.repository);

  Future<void> call(Semester semester) async {
    SemesterValidator.validateBasic(semester);
    return repository.createSemester(semester);
  }
}
