import '../entities/semester.dart';
import '../repositories/semester_repository.dart';

class CreateSemesterUseCase {
  final SemesterRepository _repository;

  CreateSemesterUseCase(this._repository);

  Future<void> call(Semester semester) {
    return _repository.createSemester(semester);
  }
}
