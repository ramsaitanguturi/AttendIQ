import 'package:isar/isar.dart';
import '../models/academic_event_local.dart';

abstract class AcademicEventLocalDataSource {
  Future<List<AcademicEventLocal>> getEventsForDate(DateTime date);
  Future<List<AcademicEventLocal>> getEventsForRange(DateTime startDate, DateTime endDate);
  Future<List<AcademicEventLocal>> getAllEvents();
  Future<AcademicEventLocal?> getEventById(int id);
  Future<void> saveEvent(AcademicEventLocal event);
  Future<void> deleteEvent(int id);
  Stream<void> watchEvents();
}

class AcademicEventLocalDataSourceImpl implements AcademicEventLocalDataSource {
  final Isar _isar;

  AcademicEventLocalDataSourceImpl(this._isar);

  DateTime _cleanDate(DateTime dt) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }

  @override
  Future<List<AcademicEventLocal>> getEventsForDate(DateTime date) async {
    final targetDate = _cleanDate(date);
    return _isar.academicEventLocals
        .where()
        .dateEqualTo(targetDate)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<AcademicEventLocal>> getEventsForRange(DateTime startDate, DateTime endDate) async {
    final start = _cleanDate(startDate);
    final end = _cleanDate(endDate);

    final all = await _isar.academicEventLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();

    return all.where((e) {
      final date = _cleanDate(e.date);
      return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
          (date.isBefore(end) || date.isAtSameMomentAs(end));
    }).toList();
  }

  @override
  Future<List<AcademicEventLocal>> getAllEvents() async {
    return _isar.academicEventLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<AcademicEventLocal?> getEventById(int id) async {
    return _isar.academicEventLocals.get(id);
  }

  @override
  Future<void> saveEvent(AcademicEventLocal event) async {
    await _isar.writeAsync((isar) {
      if (event.id == 0) {
        event.id = isar.academicEventLocals.autoIncrement();
      }
      event.date = _cleanDate(event.date);
      isar.academicEventLocals.put(event);
    });
  }

  @override
  Future<void> deleteEvent(int id) async {
    final event = await _isar.academicEventLocals.get(id);
    if (event != null) {
      await _isar.writeAsync((isar) {
        event.isDeleted = true;
        event.updatedAt = DateTime.now().toUtc();
        isar.academicEventLocals.put(event);
      });
    }
  }

  @override
  Stream<void> watchEvents() {
    return _isar.academicEventLocals.where().isDeletedEqualTo(false).watch();
  }
}
