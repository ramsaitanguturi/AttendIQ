import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../../data/datasources/subject_local_data_source.dart';
import '../../data/datasources/subject_remote_data_source.dart';
import '../../data/repositories/subject_repository_impl.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../auth/data/models/semester_local.dart';
import '../../data/models/subject_local.dart';

part 'subject_controller.g.dart';

@riverpod
SubjectLocalDataSource subjectLocalDataSource(SubjectLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return SubjectLocalDataSourceImpl(isar);
}

@riverpod
SubjectRemoteDataSource subjectRemoteDataSource(SubjectRemoteDataSourceRef ref) {
  return SubjectRemoteDataSourceImpl();
}

@riverpod
SubjectRepository subjectRepository(SubjectRepositoryRef ref) {
  return SubjectRepositoryImpl(
    localDataSource: ref.watch(subjectLocalDataSourceProvider),
    remoteDataSource: ref.watch(subjectRemoteDataSourceProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
}

@riverpod
class SubjectListController extends _$SubjectListController {
  @override
  FutureOr<List<Subject>> build() async {
    final isar = ref.watch(isarProvider).requireValue;
    
    // Get local active semester
    final localSem = isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
    if (localSem == null) {
      return const [];
    }

    final repo = ref.watch(subjectRepositoryProvider);
    
    // Listen to changes in Isar subjectLocals
    final stream = isar.subjectLocals
        .where()
        .semesterIdEqualTo(localSem.id)
        .isDeletedEqualTo(false)
        .watch();

    final sub = stream.listen((_) async {
      final updatedList = await repo.getSubjectsBySemester(localSem.id);
      state = AsyncValue.data(updatedList);
    });

    ref.onDispose(() {
      sub.cancel();
    });

    return repo.getSubjectsBySemester(localSem.id);
  }

  Future<void> addSubject({
    required String name,
    required String code,
    String? faculty,
    required int credits,
    required double attendanceTarget,
    required String color,
    required SubjectType type,
  }) async {
    final isar = ref.read(isarProvider).requireValue;
    final localSem = isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
    if (localSem == null) throw Exception('No active semester');

    final subject = Subject(
      semesterId: localSem.id,
      name: name,
      code: code,
      faculty: faculty,
      credits: credits,
      attendanceTarget: attendanceTarget,
      color: color,
      type: type,
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(subjectRepositoryProvider);
    await repo.createSubject(subject);
  }

  Future<void> updateSubjectDetails(Subject subject) async {
    final repo = ref.read(subjectRepositoryProvider);
    await repo.updateSubject(subject);
  }

  Future<void> removeSubject(int id) async {
    final repo = ref.read(subjectRepositoryProvider);
    await repo.deleteSubject(id);
  }
}
