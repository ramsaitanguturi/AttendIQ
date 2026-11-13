import 'package:isar/isar.dart';

import '../models/daily_schedule_occurrence_local.dart';
import '../utils/occurrence_identity.dart';

abstract class DailyScheduleOccurrenceLocalDataSource {
  Future<DailyScheduleOccurrenceLocal> saveOccurrence(
      DailyScheduleOccurrenceLocal occurrence);
  Future<List<DailyScheduleOccurrenceLocal>> saveOccurrences(
      List<DailyScheduleOccurrenceLocal> occurrences);
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrencesForDate(
      DateTime date);
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrencesForDateRange(
      DateTime start, DateTime end);
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrencesForSubject(
      int subjectId);
  Future<DailyScheduleOccurrenceLocal?> getOccurrenceById(int id);
  Future<void> deleteOccurrence(int id);
  Future<List<DailyScheduleOccurrenceLocal>> getAllOccurrences();
  Stream<void> watchOccurrencesForDate(DateTime date);
}

class DailyScheduleOccurrenceLocalDataSourceImpl
    implements DailyScheduleOccurrenceLocalDataSource {
  final Isar _isar;

  DailyScheduleOccurrenceLocalDataSourceImpl(this._isar);

  @override
  Future<DailyScheduleOccurrenceLocal> saveOccurrence(
      DailyScheduleOccurrenceLocal occurrence) async {
    return _isar.writeAsync<DailyScheduleOccurrenceLocal>((isar) {
      return upsertCanonicalOccurrenceInWriteTx(isar, occurrence);
    });
  }

  @override
  Future<List<DailyScheduleOccurrenceLocal>> saveOccurrences(
      List<DailyScheduleOccurrenceLocal> occurrences) async {
    return _isar.writeAsync<List<DailyScheduleOccurrenceLocal>>((isar) {
      final saved = <DailyScheduleOccurrenceLocal>[];
      for (final occurrence in occurrences) {
        saved.add(upsertCanonicalOccurrenceInWriteTx(isar, occurrence));
      }
      return saved;
    });
  }

  @override
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrencesForDate(
      DateTime date) async {
    final startUtc = DateTime.utc(date.year, date.month, date.day);
    final endUtc = DateTime.utc(date.year, date.month, date.day, 23, 59, 59);
    final all = _isar.dailyScheduleOccurrenceLocals
        .where()
        .dateBetween(startUtc, endUtc)
        .isDeletedEqualTo(false)
        .findAll();
    return all;
  }

  @override
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrencesForDateRange(
      DateTime start, DateTime end) async {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day, 23, 59, 59);
    return _isar.dailyScheduleOccurrenceLocals
        .where()
        .dateBetween(startUtc, endUtc)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<DailyScheduleOccurrenceLocal>> getOccurrencesForSubject(
      int subjectId) async {
    return _isar.dailyScheduleOccurrenceLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<DailyScheduleOccurrenceLocal?> getOccurrenceById(int id) async {
    return _isar.dailyScheduleOccurrenceLocals.get(id);
  }

  @override
  Future<void> deleteOccurrence(int id) async {
    await _isar.writeAsync((isar) {
      final occurrence = isar.dailyScheduleOccurrenceLocals.get(id);
      if (occurrence != null) {
        occurrence
          ..isDeleted = true
          ..isDirty = true
          ..updatedAt = DateTime.now().toUtc();
        isar.dailyScheduleOccurrenceLocals.put(occurrence);
      }
    });
  }

  @override
  Future<List<DailyScheduleOccurrenceLocal>> getAllOccurrences() async {
    return _isar.dailyScheduleOccurrenceLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Stream<void> watchOccurrencesForDate(DateTime date) {
    return _isar.dailyScheduleOccurrenceLocals
        .where()
        .isDeletedEqualTo(false)
        .watch();
  }
}
