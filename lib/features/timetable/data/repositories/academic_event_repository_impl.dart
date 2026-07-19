import '../../domain/entities/academic_event.dart';
import '../../domain/repositories/academic_event_repository.dart';
import '../datasources/academic_event_local_data_source.dart';
import '../models/academic_event_local.dart';

class AcademicEventRepositoryImpl implements AcademicEventRepository {
  final AcademicEventLocalDataSource _localDataSource;

  AcademicEventRepositoryImpl(this._localDataSource);

  AcademicEvent _mapToDomain(AcademicEventLocal local) {
    return AcademicEvent(
      id: local.id,
      serverId: local.serverId,
      title: local.title,
      description: local.description,
      date: local.date,
      startTime: local.startTime,
      endTime: local.endTime,
      type: AcademicEventType.fromString(local.type),
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  AcademicEventLocal _mapToLocal(AcademicEvent domain) {
    final now = DateTime.now().toUtc();
    return AcademicEventLocal()
      ..id = domain.id ?? 0
      ..serverId = domain.serverId
      ..title = domain.title
      ..description = domain.description
      ..date = domain.date
      ..startTime = domain.startTime
      ..endTime = domain.endTime
      ..type = domain.type.toShortString()
      ..createdAt = domain.createdAt
      ..updatedAt = now
      ..isDirty = domain.isDirty
      ..isDeleted = domain.isDeleted;
  }

  @override
  Future<List<AcademicEvent>> getEventsForDate(DateTime date) async {
    final locals = await _localDataSource.getEventsForDate(date);
    return locals.map(_mapToDomain).toList();
  }

  @override
  Future<List<AcademicEvent>> getEventsForRange(DateTime startDate, DateTime endDate) async {
    final locals = await _localDataSource.getEventsForRange(startDate, endDate);
    return locals.map(_mapToDomain).toList();
  }

  @override
  Future<List<AcademicEvent>> getAllEvents() async {
    final locals = await _localDataSource.getAllEvents();
    return locals.map(_mapToDomain).toList();
  }

  @override
  Future<AcademicEvent?> getEventById(int id) async {
    final local = await _localDataSource.getEventById(id);
    return local == null ? null : _mapToDomain(local);
  }

  @override
  Future<void> saveEvent(AcademicEvent event) async {
    final local = _mapToLocal(event);
    await _localDataSource.saveEvent(local);
  }

  @override
  Future<void> deleteEvent(int id) async {
    await _localDataSource.deleteEvent(id);
  }

  @override
  Stream<void> watchEvents() {
    return _localDataSource.watchEvents();
  }
}
