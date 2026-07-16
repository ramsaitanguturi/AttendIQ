import '../../domain/entities/timetable_template.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/timetable_local_data_source.dart';
import '../datasources/timetable_remote_data_source.dart';
import '../models/timetable_template_local.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableLocalDataSource _localDataSource;
  final TimetableRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  TimetableRepositoryImpl({
    required TimetableLocalDataSource localDataSource,
    required TimetableRemoteDataSource remoteDataSource,
    required AuthLocalDataSource authLocalDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _authLocalDataSource = authLocalDataSource;

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
    final cachedUser = await _authLocalDataSource.getUser();
    final uid = cachedUser?.uid ?? 'anonymous';

    String? serverId;
    bool isDirty = true;

    try {
      serverId = await _remoteDataSource.saveTemplate(
        uid: uid,
        subjectId: template.subjectId.toString(),
        weekday: template.weekday,
        startTime: template.startTime,
        endTime: template.endTime,
        room: template.room,
        faculty: template.faculty,
        notes: template.notes,
        serverId: template.serverId,
      );
      isDirty = false;
    } catch (e) {
      serverId = template.serverId;
      isDirty = true;
    }

    final localTemplate = _toLocal(template)
      ..serverId = serverId
      ..isDirty = isDirty
      ..updatedAt = DateTime.now();

    await _localDataSource.saveTemplate(localTemplate);
  }

  @override
  Future<void> deleteTemplate(int id) async {
    final local = await _localDataSource.getTemplateById(id);
    if (local != null) {
      bool isDirty = true;
      try {
        if (local.serverId != null) {
          await _remoteDataSource.deleteTemplate(local.serverId!);
          isDirty = false;
        }
      } catch (e) {
        isDirty = true;
      }

      local.isDeleted = true;
      local.isDirty = isDirty;
      local.updatedAt = DateTime.now();

      await _localDataSource.saveTemplate(local);
    }
  }
}
