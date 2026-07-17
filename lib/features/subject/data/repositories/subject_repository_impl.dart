import 'dart:convert';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_local_data_source.dart';
import '../models/subject_local.dart';
import '../../../../core/sync/sync_queue/sync_queue.dart';
import '../../../../core/sync/models/sync_mappers.dart';
import '../../../../core/utils/uuid_generator.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource _localDataSource;
  final SyncQueue _syncQueue;

  SubjectRepositoryImpl({
    required SubjectLocalDataSource localDataSource,
    required SyncQueue syncQueue,
  })  : _localDataSource = localDataSource,
        _syncQueue = syncQueue;

  Subject _toEntity(SubjectLocal local) {
    return Subject(
      id: local.id,
      serverId: local.serverId,
      semesterId: local.semesterId,
      name: local.name,
      code: local.code,
      faculty: local.faculty,
      credits: local.credits,
      attendanceTarget: local.attendanceTarget,
      color: local.color,
      type: local.type == 'LAB' ? SubjectType.LAB : SubjectType.THEORY,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  SubjectLocal _toLocal(Subject subject) {
    return SubjectLocal()
      ..id = subject.id ?? 0
      ..serverId = subject.serverId
      ..semesterId = subject.semesterId
      ..name = subject.name
      ..code = subject.code
      ..faculty = subject.faculty
      ..credits = subject.credits
      ..attendanceTarget = subject.attendanceTarget
      ..color = subject.color
      ..type = subject.type.toShortString()
      ..updatedAt = subject.updatedAt
      ..isDirty = subject.isDirty
      ..isDeleted = subject.isDeleted;
  }

  @override
  Future<List<Subject>> getSubjectsBySemester(int semesterId) async {
    final list = await _localDataSource.getSubjectsBySemester(semesterId);
    return list.map(_toEntity).toList();
  }

  @override
  Future<Subject?> getSubjectById(int id) async {
    final local = await _localDataSource.getSubjectById(id);
    if (local != null && !local.isDeleted) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<void> createSubject(Subject subject) async {
    final serverId = subject.serverId ?? generateUuid();
    final now = DateTime.now().toUtc();

    final localSubject = _toLocal(subject)
      ..serverId = serverId
      ..createdAt = now
      ..updatedAt = now
      ..isDirty = true
      ..isDeleted = false;

    await _localDataSource.saveSubject(localSubject);

    await _syncQueue.enqueue(
      collectionName: 'subjects',
      documentId: serverId,
      operationType: 'CREATE',
      payload: jsonEncode(localSubject.toMap()),
    );
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    final now = DateTime.now().toUtc();
    final serverId = subject.serverId ?? generateUuid();

    final localSubject = _toLocal(subject)
      ..serverId = serverId
      ..updatedAt = now
      ..isDirty = true;

    final existing = await _localDataSource.getSubjectById(localSubject.id);
    localSubject.createdAt = existing?.createdAt ?? now;

    await _localDataSource.saveSubject(localSubject);

    await _syncQueue.enqueue(
      collectionName: 'subjects',
      documentId: serverId,
      operationType: 'UPDATE',
      payload: jsonEncode(localSubject.toMap()),
    );
  }

  @override
  Future<void> deleteSubject(int id) async {
    final local = await _localDataSource.getSubjectById(id);
    if (local != null) {
      final now = DateTime.now().toUtc();
      local.isDeleted = true;
      local.isDirty = true;
      local.updatedAt = now;

      await _localDataSource.saveSubject(local);

      if (local.serverId != null) {
        await _syncQueue.enqueue(
          collectionName: 'subjects',
          documentId: local.serverId!,
          operationType: 'DELETE',
          payload: jsonEncode(local.toMap()),
        );
      }
    }
  }
}
