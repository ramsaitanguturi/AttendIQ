import '../../domain/entities/timetable_template.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/timetable_local_data_source.dart';
import '../models/timetable_template_local.dart';
import '../../../../core/utils/uuid_generator.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableLocalDataSource _localDataSource;

  TimetableRepositoryImpl({
    required TimetableLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

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
      ..isDirty = false
      ..isDeleted = false;

    final existing = await _localDataSource.getTemplateById(localTemplate.id);
    localTemplate.createdAt = existing?.createdAt ?? now;

    await _localDataSource.saveTemplate(localTemplate);
  }

  @override
  Future<void> deleteTemplate(int id) async {
    final local = await _localDataSource.getTemplateById(id);
    if (local != null) {
      final now = DateTime.now().toUtc();
      local.isDeleted = true;
      local.isDirty = false;
      local.updatedAt = now;

      await _localDataSource.saveTemplate(local);
    }
  }

  @override
  Stream<void> watchTemplates(int semesterId) {
    return _localDataSource.watchTemplates(semesterId);
  }
}
