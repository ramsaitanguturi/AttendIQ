import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/timetable_template.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../../data/datasources/timetable_local_data_source.dart';
import '../../data/datasources/timetable_remote_data_source.dart';
import '../../data/repositories/timetable_repository_impl.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../auth/data/models/semester_local.dart';
import '../../data/models/timetable_template_local.dart';

import '../../../../core/sync/sync_queue/sync_queue.dart';

part 'timetable_controller.g.dart';

@riverpod
TimetableLocalDataSource timetableLocalDataSource(TimetableLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return TimetableLocalDataSourceImpl(isar);
}

@riverpod
TimetableRemoteDataSource timetableRemoteDataSource(TimetableRemoteDataSourceRef ref) {
  return TimetableRemoteDataSourceImpl();
}

@riverpod
TimetableRepository timetableRepository(TimetableRepositoryRef ref) {
  return TimetableRepositoryImpl(
    localDataSource: ref.watch(timetableLocalDataSourceProvider),
    syncQueue: ref.watch(syncQueueProvider),
  );
}

@riverpod
class TimetableListController extends _$TimetableListController {
  @override
  FutureOr<List<TimetableTemplate>> build() async {
    final isar = ref.watch(isarProvider).requireValue;
    
    // Get local active semester
    final localSem = isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
    if (localSem == null) {
      return const [];
    }

    final repo = ref.watch(timetableRepositoryProvider);
    
    // Listen to changes in Isar timetableTemplateLocals
    final stream = isar.timetableTemplateLocals.where().isDeletedEqualTo(false).watch();

    final sub = stream.listen((_) async {
      final updatedList = await repo.getTemplatesForSemester(localSem.id);
      state = AsyncValue.data(updatedList);
    });

    ref.onDispose(() {
      sub.cancel();
    });

    return repo.getTemplatesForSemester(localSem.id);
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  bool checkCollision(int weekday, String startTime, String endTime, {int? excludeId}) {
    final list = state.valueOrNull ?? [];
    final startMin = _timeToMinutes(startTime);
    final endMin = _timeToMinutes(endTime);

    for (final template in list) {
      if (template.id == excludeId) continue;
      if (template.weekday == weekday) {
        final tStart = _timeToMinutes(template.startTime);
        final tEnd = _timeToMinutes(template.endTime);
        if (startMin < tEnd && endMin > tStart) {
          return true; // Overlap detected
        }
      }
    }
    return false;
  }

  Future<void> addTemplate({
    required int subjectId,
    required int weekday,
    required String startTime,
    required String endTime,
    String? room,
    String? faculty,
    String? notes,
  }) async {
    if (checkCollision(weekday, startTime, endTime)) {
      throw Exception('Schedule collision: overlapping class exists at this time.');
    }

    final template = TimetableTemplate(
      subjectId: subjectId,
      weekday: weekday,
      startTime: startTime,
      endTime: endTime,
      room: room,
      faculty: faculty,
      notes: notes,
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(timetableRepositoryProvider);
    await repo.saveTemplate(template);
  }

  Future<void> updateTemplateDetails(TimetableTemplate template) async {
    if (checkCollision(template.weekday, template.startTime, template.endTime, excludeId: template.id)) {
      throw Exception('Schedule collision: overlapping class exists at this time.');
    }

    final repo = ref.read(timetableRepositoryProvider);
    await repo.saveTemplate(template);
  }

  Future<void> removeTemplate(int id) async {
    final repo = ref.read(timetableRepositoryProvider);
    await repo.deleteTemplate(id);
  }
}
