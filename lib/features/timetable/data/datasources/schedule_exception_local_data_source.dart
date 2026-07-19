import 'package:isar/isar.dart';
import '../models/schedule_exception_local.dart';

abstract class ScheduleExceptionLocalDataSource {
  Future<List<ScheduleExceptionLocal>> getExceptionsForDate(DateTime date);
  Future<List<ScheduleExceptionLocal>> getExceptionsForRange(DateTime startDate, DateTime endDate);
  Future<ScheduleExceptionLocal?> getExceptionById(int id);
  Future<void> saveException(ScheduleExceptionLocal exception);
  Future<void> deleteException(int id);
  Stream<void> watchExceptions();
}

class ScheduleExceptionLocalDataSourceImpl implements ScheduleExceptionLocalDataSource {
  final Isar _isar;

  ScheduleExceptionLocalDataSourceImpl(this._isar);

  DateTime _cleanDate(DateTime dt) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }

  @override
  Future<List<ScheduleExceptionLocal>> getExceptionsForDate(DateTime date) async {
    final targetDate = _cleanDate(date);
    return _isar.scheduleExceptionLocals
        .where()
        .dateEqualTo(targetDate)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<ScheduleExceptionLocal>> getExceptionsForRange(DateTime startDate, DateTime endDate) async {
    final start = _cleanDate(startDate);
    final end = _cleanDate(endDate);

    final all = _isar.scheduleExceptionLocals
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
  Future<ScheduleExceptionLocal?> getExceptionById(int id) async {
    return _isar.scheduleExceptionLocals.get(id);
  }

  @override
  Future<void> saveException(ScheduleExceptionLocal exception) async {
    await _isar.writeAsync((isar) {
      if (exception.id == 0) {
        exception.id = isar.scheduleExceptionLocals.autoIncrement();
      }
      exception.date = _cleanDate(exception.date);
      isar.scheduleExceptionLocals.put(exception);
    });
  }

  @override
  Future<void> deleteException(int id) async {
    final exception = await _isar.scheduleExceptionLocals.get(id);
    if (exception != null) {
      await _isar.writeAsync((isar) {
        exception.isDeleted = true;
        exception.updatedAt = DateTime.now().toUtc();
        isar.scheduleExceptionLocals.put(exception);
      });
    }
  }

  @override
  Stream<void> watchExceptions() {
    return _isar.scheduleExceptionLocals.where().isDeletedEqualTo(false).watch();
  }
}
