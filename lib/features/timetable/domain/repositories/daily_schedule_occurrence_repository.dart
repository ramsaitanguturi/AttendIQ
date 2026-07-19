import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/daily_schedule_occurrence.dart';
import '../../data/datasources/daily_schedule_occurrence_local_data_source.dart';
import '../../data/repositories/daily_schedule_occurrence_repository_impl.dart';
import '../../../../core/database/isar_provider.dart';

part 'daily_schedule_occurrence_repository.g.dart';

abstract class DailyScheduleOccurrenceRepository {
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDate(DateTime date);
  Future<List<DailyScheduleOccurrence>> getOccurrencesForDateRange(DateTime start, DateTime end);
  Future<DailyScheduleOccurrence?> getOccurrenceById(int id);
  Future<DailyScheduleOccurrence> saveOccurrence(DailyScheduleOccurrence occurrence);
  Future<List<DailyScheduleOccurrence>> saveOccurrences(List<DailyScheduleOccurrence> occurrences);
  Future<void> deleteOccurrence(int id);
  Future<List<DailyScheduleOccurrence>> getAllOccurrences();
  Stream<void> watchOccurrencesForDate(DateTime date);
}

@riverpod
DailyScheduleOccurrenceLocalDataSource dailyScheduleOccurrenceLocalDataSource(
    DailyScheduleOccurrenceLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return DailyScheduleOccurrenceLocalDataSourceImpl(isar);
}

@riverpod
DailyScheduleOccurrenceRepository dailyScheduleOccurrenceRepository(
    DailyScheduleOccurrenceRepositoryRef ref) {
  final dataSource = ref.watch(dailyScheduleOccurrenceLocalDataSourceProvider);
  return DailyScheduleOccurrenceRepositoryImpl(localDataSource: dataSource);
}
