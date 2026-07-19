import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/isar_provider.dart';
import '../../data/repositories/semester_repository_impl.dart';
import '../../domain/entities/semester.dart';
import '../../domain/repositories/semester_repository.dart';
import '../../domain/usecases/create_semester_use_case.dart';

part 'semester_controller.g.dart';

@riverpod
SemesterRepository semesterRepository(SemesterRepositoryRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return SemesterRepositoryImpl(isar);
}

@riverpod
CreateSemesterUseCase createSemesterUseCase(CreateSemesterUseCaseRef ref) {
  return CreateSemesterUseCase(ref.watch(semesterRepositoryProvider));
}

@riverpod
Future<bool> hasActiveSemester(HasActiveSemesterRef ref) async {
  final repo = ref.watch(semesterRepositoryProvider);
  return repo.hasActiveSemester();
}

@riverpod
Future<Semester?> activeSemester(ActiveSemesterRef ref) async {
  final repo = ref.watch(semesterRepositoryProvider);
  return repo.getActiveSemester();
}

@riverpod
Future<List<Semester>> allSemesters(AllSemestersRef ref) async {
  final repo = ref.watch(semesterRepositoryProvider);
  return repo.getAllSemesters();
}

