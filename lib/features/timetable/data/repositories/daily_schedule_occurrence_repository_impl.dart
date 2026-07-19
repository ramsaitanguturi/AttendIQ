import '../../domain/entities/daily_schedule_occurrence.dart';
import '../../domain/repositories/daily_schedule_occurrence_repository.dart';
import '../datasources/daily_schedule_occurrence_local_data_source.dart';
import '../models/daily_schedule_occurrence_local.dart';
import '../../../../core/utils/uuid_generator.dart';

class DailyScheduleOccurrenceRepositoryImpl implements DailyScheduleOccurrenceRepository {
  final DailyScheduleOccurrenceLocalDataSource _localDataSource;

  DailyScheduleOccurrenceRepositoryImpl({
    required DailyScheduleOccurrenceLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  DailyScheduleOccurrence _toEntity(DailyScheduleOccurrenceLocal local) {
    return DailyScheduleOccurrence(
      id: local.id,
      serverId: local.serverId,
      date: local.date,
      subjectId: local.subjectId,
      title: local.title,
      startTime: local.startTime,
      endTime: local.endTime,
      type: OccurrenceType.fromString(local.type),
      status: OccurrenceStatus.fromString(local.status),
      createdFrom: OccurrenceCreatedFrom.fromString(local.createdFrom),
      room: local.room,
      faculty: local.faculty,
      reason: local.reason,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  DailyScheduleOccurrenceLocal _toLocal(DailyScheduleOccurrence occurrence) {
    final local = DailyScheduleOccurrenceLocal()
      ..id = occurrence.id ?? 0
      ..serverId = occurrence.serverId
      ..date = occurrence.date
      ..subjectId = occurrence.subjectId
      ..title = occurrence.title
      ..startTime = occurrence.startTime
      ..endTime = occurrence.endTime
      ..type = occurrence.type.toShortString()
      ..status = occurrence.status.toShortString()
      ..createdFrom = occurrence.createdFrom.toShortString()
      ..room = occurrence.room
      ..faculty = occurrence.faculty
      ..reason = occurrence.reason
      ..createdAt = occurrence.createdAt
      ..updatedAt = occurrence.updatedAt
      ..isDirty = occurrence.isDirty
      ..isDeleted = occurrence.isDeleted;
    return local;
  }

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDate(DateTime date) async {
    final list = await _localDataSource.getOccurrencesForDate(date);
    return list.map(_toEntity).toList();
  }

  @override
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDateRange(DateTime start, DateTime end) async {
    final list = await _localDataSource.getOccurrencesForDateRange(start, end);
    return list.map(_toEntity).toList();
  }

  @override
  Future<DailyScheduleOccurrence?> getOccurrenceById(int id) async {
    final local = await _localDataSource.getOccurrenceById(id);
    if (local != null && !local.isDeleted) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<DailyScheduleOccurrence> saveOccurrence(DailyScheduleOccurrence occurrence) async {
    final serverId = occurrence.serverId ?? generateUuid();
    final now = DateTime.now().toUtc();

    final local = _toLocal(occurrence)
      ..serverId = serverId
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;

    if (local.id != 0) {
      final existing = await _localDataSource.getOccurrenceById(local.id);
      local.createdAt = existing?.createdAt ?? now;
    } else {
      local.createdAt = now;
    }

    final saved = await _localDataSource.saveOccurrence(local);
    return _toEntity(saved);
  }

  @override
  Future<List<DailyScheduleOccurrence>> saveOccurrences(List<DailyScheduleOccurrence> occurrences) async {
    final now = DateTime.now().toUtc();
    final locals = <DailyScheduleOccurrenceLocal>[];

    for (final occurrence in occurrences) {
      final serverId = occurrence.serverId ?? generateUuid();
      final local = _toLocal(occurrence)
        ..serverId = serverId
        ..updatedAt = now
        ..isDirty = false
        ..isDeleted = false;

      if (local.id != 0) {
        final existing = await _localDataSource.getOccurrenceById(local.id);
        local.createdAt = existing?.createdAt ?? now;
      } else {
        local.createdAt = now;
      }
      locals.add(local);
    }

    final saved = await _localDataSource.saveOccurrences(locals);
    return saved.map(_toEntity).toList();
  }

  @override
  Future<void> deleteOccurrence(int id) async {
    await _localDataSource.deleteOccurrence(id);
  }

  @override
  Future<List<DailyScheduleOccurrence>> getAllOccurrences() async {
    final list = await _localDataSource.getAllOccurrences();
    return list.map(_toEntity).toList();
  }

  @override
  Stream<void> watchOccurrencesForDate(DateTime date) {
    return _localDataSource.watchOccurrencesForDate(date);
  }
}
