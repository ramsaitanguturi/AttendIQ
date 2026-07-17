import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../../data/datasources/subject_local_data_source.dart';
import '../../data/datasources/subject_remote_data_source.dart';
import '../../data/repositories/subject_repository_impl.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

import '../../../../core/sync/sync_queue/sync_queue.dart';

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
    syncQueue: ref.watch(syncQueueProvider),
  );
}

@riverpod
class SubjectListController extends _$SubjectListController {
  @override
  FutureOr<List<Subject>> build() async {
    final semester = await ref.watch(semesterRepositoryProvider).getActiveSemester();
    if (semester == null || semester.localId == null) {
      return const [];
    }

    final repo = ref.watch(subjectRepositoryProvider);
    final localSemId = semester.localId!;
    
    // Listen to changes in subjectRepository stream
    final stream = repo.watchSubjects(localSemId);

    final sub = stream.listen((_) async {
      final updatedList = await repo.getSubjectsBySemester(localSemId);
      state = AsyncValue.data(updatedList);
    });

    ref.onDispose(() {
      sub.cancel();
    });

    return repo.getSubjectsBySemester(localSemId);
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
    final semester = await ref.read(semesterRepositoryProvider).getActiveSemester();
    if (semester == null || semester.localId == null) {
      throw Exception('No active semester');
    }

    final subject = Subject(
      semesterId: semester.localId!,
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
