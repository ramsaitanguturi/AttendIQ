import 'dart:convert';
import '../../domain/entities/timetable_template.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/timetable_local_data_source.dart';
import '../models/timetable_template_local.dart';
import '../../../../core/sync/sync_queue/sync_queue.dart';
import '../../../../core/sync/models/sync_mappers.dart';
import '../../../../core/utils/uuid_generator.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableLocalDataSource _localDataSource;
  final SyncQueue _syncQueue;

  TimetableRepositoryImpl({
    required TimetableLocalDataSource localDataSource,
    required SyncQueue syncQueue,
  })  : _localDataSource = localDataSource,
        _syncQueue = syncQueue;

  TimetableTemplate _toEntity(TimetableTemplateLocal local) {
    return TimetableTemplate(
      id: local.id,
      serverId: local.serverId,
      subjectId: local.subjectId,
      weekday: local.weekday,
      startTime: local.startTime,
      endTime: local.endTime,
      room: local.room,
      faculty: local.faculty,
      notes: local.notes,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  TimetableTemplateLocal _toLocal(TimetableTemplate template) {
    return TimetableTemplateLocal()
      ..id = template.id ?? 0
      ..serverId = template.serverId
      ..subjectId = template.subjectId
      ..weekday = template.weekday
      ..startTime = template.startTime
      ..endTime = template.endTime
      ..room = template.room
      ..faculty = template.faculty
      ..notes = template.notes
      ..updatedAt = template.updatedAt
      ..isDirty = template.isDirty
      ..isDeleted = template.isDeleted;
  }

  @override
  Future<List<TimetableTemplate>> getTemplatesForSubject(int subjectId) async {
    final list = await _localDataSource.getTemplatesForSubject(subjectId);
    return list.map(_toEntity).toList();
  }

  @override
  Future<List<TimetableTemplate>> getTemplatesForSemester(int semesterId) async {
    final list = await _localDataSource.getTemplatesForSemester(semesterId);
    return list.map(_toEntity).toList();
  }

  @override
  Future<TimetableTemplate?> getTemplateById(int id) async {
    final local = await _localDataSource.getTemplateById(id);
    if (local != null && !local.isDeleted) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<void> saveTemplate(TimetableTemplate template) async {
    final serverId = template.serverId ?? generateUuid();
    final now = DateTime.now().toUtc();

    final localTemplate = _toLocal(template)
      ..serverId = serverId
      ..updatedAt = now
      ..isDirty = true
      ..isDeleted = false;

    // Check if we already have a createdAt, if not use now
    final existing = await _localDataSource.getTemplateById(localTemplate.id);
    localTemplate.createdAt = existing?.createdAt ?? now;

    await _localDataSource.saveTemplate(localTemplate);

    await _syncQueue.enqueue(
      collectionName: 'schedules',
      documentId: serverId,
      operationType: template.serverId != null ? 'UPDATE' : 'CREATE',
      payload: jsonEncode(localTemplate.toMap()),
    );
  }

  @override
  Future<void> deleteTemplate(int id) async {
    final local = await _localDataSource.getTemplateById(id);
    if (local != null) {
      final now = DateTime.now().toUtc();
      local.isDeleted = true;
      local.isDirty = true;
      local.updatedAt = now;

      await _localDataSource.saveTemplate(local);

      if (local.serverId != null) {
        await _syncQueue.enqueue(
          collectionName: 'schedules',
          documentId: local.serverId!,
          operationType: 'DELETE',
          payload: jsonEncode(local.toMap()),
        );
      }
    }
  }

  @override
  Stream<void> watchTemplates(int semesterId) {
    return _localDataSource.watchTemplates(semesterId);
  }
}
