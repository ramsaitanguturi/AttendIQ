import '../../domain/entities/schedule_exception.dart';
import '../../domain/repositories/schedule_exception_repository.dart';
import '../datasources/schedule_exception_local_data_source.dart';
import '../models/schedule_exception_local.dart';
import '../../../../core/utils/uuid_generator.dart';

class ScheduleExceptionRepositoryImpl implements ScheduleExceptionRepository {
  final ScheduleExceptionLocalDataSource _localDataSource;

  ScheduleExceptionRepositoryImpl({
    required ScheduleExceptionLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  ScheduleException _toEntity(ScheduleExceptionLocal local) {
    return ScheduleException(
      id: local.id,
      serverId: local.serverId,
      date: local.date,
      subjectId: local.subjectId,
      type: ScheduleExceptionType.fromString(local.type),
      title: local.title,
      description: local.description,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  ScheduleExceptionLocal _toLocal(ScheduleException entity) {
    return ScheduleExceptionLocal()
      ..id = entity.id ?? 0
      ..serverId = entity.serverId
      ..date = entity.date
      ..subjectId = entity.subjectId
      ..type = entity.type.toShortString()
      ..title = entity.title
      ..description = entity.description
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..isDirty = entity.isDirty
      ..isDeleted = entity.isDeleted;
  }

  @override
  Future<List<ScheduleException>> getExceptionsForDate(DateTime date) async {
    final list = await _localDataSource.getExceptionsForDate(date);
    return list.map(_toEntity).toList();
  }

  @override
  Future<List<ScheduleException>> getExceptionsForRange(DateTime startDate, DateTime endDate) async {
    final list = await _localDataSource.getExceptionsForRange(startDate, endDate);
    return list.map(_toEntity).toList();
  }

  @override
  Future<ScheduleException?> getExceptionById(int id) async {
    final local = await _localDataSource.getExceptionById(id);
    if (local != null && !local.isDeleted) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<void> saveException(ScheduleException exception) async {
    final serverId = exception.serverId ?? generateUuid();
    final now = DateTime.now().toUtc();

    final local = _toLocal(exception)
      ..serverId = serverId
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;

    if (local.id != 0) {
      final existing = await _localDataSource.getExceptionById(local.id);
      local.createdAt = existing?.createdAt ?? now;
    } else {
      local.createdAt = now;
    }

    await _localDataSource.saveException(local);
  }

  @override
  Future<void> deleteException(int id) async {
    await _localDataSource.deleteException(id);
  }

  @override
  Stream<void> watchExceptions() {
    return _localDataSource.watchExceptions();
  }
}
