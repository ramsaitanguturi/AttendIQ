import '../../domain/entities/semester.dart';
import '../../domain/repositories/semester_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/semester_local.dart';

class SemesterRepositoryImpl implements SemesterRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;

  SemesterRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<void> createSemester(Semester semester) async {
    final cachedUser = await _localDataSource.getUser();
    final uid = cachedUser?.uid ?? 'anonymous';

    String? serverId;
    bool isDirty = true;

    try {
      serverId = await _remoteDataSource.saveSemester(
        uid: uid,
        name: semester.name,
        startDate: semester.startDate,
        endDate: semester.endDate,
        requiredAttendanceRate: semester.requiredAttendanceRate,
      );
      isDirty = false;
    } catch (e) {
      serverId = null;
      isDirty = true;
    }

    final localSemester = SemesterLocal()
      ..serverId = serverId
      ..name = semester.name
      ..startDate = semester.startDate
      ..endDate = semester.endDate
      ..requiredAttendanceRate = semester.requiredAttendanceRate
      ..updatedAt = DateTime.now()
      ..isDirty = isDirty
      ..isDeleted = false;

    await _localDataSource.saveSemester(localSemester);
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
