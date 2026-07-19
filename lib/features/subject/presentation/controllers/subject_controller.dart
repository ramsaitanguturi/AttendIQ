import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../../data/datasources/subject_local_data_source.dart';
import '../../data/repositories/subject_repository_impl.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';

part 'subject_controller.g.dart';

@riverpod
SubjectLocalDataSource subjectLocalDataSource(SubjectLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return SubjectLocalDataSourceImpl(isar);
}

@riverpod
SubjectRepository subjectRepository(SubjectRepositoryRef ref) {
  return SubjectRepositoryImpl(
    localDataSource: ref.watch(subjectLocalDataSourceProvider),
  );
}

@riverpod
class SubjectListController extends _$SubjectListController {
  @override
  FutureOr<List<Subject>> build() async {
    final semesterAsync = ref.watch(activeSemesterProvider);
    final semester = semesterAsync.valueOrNull;

    if (semester == null || semester.localId == null) {
      if (kDebugMode) {
        developer.log('[SubjectListController] Selected semester: None active', name: 'SubjectListController');
        developer.log('[SubjectListController] Loaded subjects: []', name: 'SubjectListController');
        developer.log('[SubjectListController] Subject count: 0', name: 'SubjectListController');
      }
      return const [];
    }

    final repo = ref.watch(subjectRepositoryProvider);
    final localSemId = semester.localId!;
    
    final subjects = await repo.getSubjectsBySemester(localSemId);

    if (kDebugMode) {
      developer.log('[SubjectListController] Selected semester: ${semester.name} (localId: ${semester.localId})', name: 'SubjectListController');
      developer.log('[SubjectListController] Loaded subjects: ${subjects.map((s) => '${s.code}[id=${s.id}]').toList()}', name: 'SubjectListController');
      developer.log('[SubjectListController] Subject count: ${subjects.length}', name: 'SubjectListController');
    }

    final stream = repo.watchSubjects(localSemId);
    final sub = stream.listen((_) async {
      final updatedList = await repo.getSubjectsBySemester(localSemId);
      state = AsyncValue.data(updatedList);
      if (kDebugMode) {
        developer.log('[SubjectListController Stream Update] Subject count: ${updatedList.length}', name: 'SubjectListController');
      }
    });

    ref.onDispose(() {
      sub.cancel();
    });

    return subjects;
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
      throw Exception('No active semester found. Please configure a semester first.');
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

    final updatedList = await repo.getSubjectsBySemester(semester.localId!);
    state = AsyncValue.data(updatedList);

    if (kDebugMode) {
      developer.log('[SubjectListController] Added subject ${subject.code}. Updated Subject count: ${updatedList.length}', name: 'SubjectListController');
    }
  }

  Future<void> updateSubjectDetails(Subject subject) async {
    final repo = ref.read(subjectRepositoryProvider);
    await repo.updateSubject(subject);

    final semester = await repo.getSubjectById(subject.id ?? 0);
    final semId = semester?.semesterId ?? subject.semesterId;
    final updatedList = await repo.getSubjectsBySemester(semId);
    state = AsyncValue.data(updatedList);

    if (kDebugMode) {
      developer.log('[SubjectListController] Updated subject ${subject.code}. Subject count: ${updatedList.length}', name: 'SubjectListController');
    }
  }

  Future<void> removeSubject(int id) async {
    final repo = ref.read(subjectRepositoryProvider);
    final subject = await repo.getSubjectById(id);
    await repo.deleteSubject(id);

    if (subject != null) {
      final updatedList = await repo.getSubjectsBySemester(subject.semesterId);
      state = AsyncValue.data(updatedList);
      if (kDebugMode) {
        developer.log('[SubjectListController] Removed subject id=$id. Subject count: ${updatedList.length}', name: 'SubjectListController');
      }
    }
  }
}

