import 'dart:convert';
import '../../domain/entities/semester.dart';
import '../../domain/repositories/semester_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/semester_local.dart';
import '../../../../core/sync/sync_queue/sync_queue.dart';
import '../../../../core/sync/models/sync_mappers.dart';
import '../../../../core/utils/uuid_generator.dart';

class SemesterRepositoryImpl implements SemesterRepository {
  final AuthLocalDataSource _localDataSource;
  final SyncQueue _syncQueue;

  SemesterRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required SyncQueue syncQueue,
  })  : _localDataSource = localDataSource,
        _syncQueue = syncQueue;

  @override
  Future<void> createSemester(Semester semester) async {
    final serverId = semester.id ?? generateUuid();
    final now = DateTime.now().toUtc();

    final localSemester = SemesterLocal()
      ..serverId = serverId
      ..name = semester.name
      ..startDate = semester.startDate
      ..endDate = semester.endDate
      ..requiredAttendanceRate = semester.requiredAttendanceRate
      ..createdAt = now
      ..updatedAt = now
      ..isDirty = true
      ..isDeleted = false;

    await _localDataSource.saveSemester(localSemester);

    await _syncQueue.enqueue(
      collectionName: 'semesters',
      documentId: serverId,
      operationType: 'CREATE',
      payload: jsonEncode(localSemester.toMap()),
    );
  }

  @override
  Future<Semester?> getActiveSemester() async {
    final cached = await _localDataSource.getActiveSemester();
    if (cached != null) {
      return Semester(
        id: cached.serverId ?? cached.id.toString(),
        name: cached.name,
        startDate: cached.startDate,
        endDate: cached.endDate,
        requiredAttendanceRate: cached.requiredAttendanceRate,
      );
    }
    return null;
  }

  @override
  Future<bool> hasActiveSemester() async {
    return _localDataSource.hasActiveSemester();
  }
}
