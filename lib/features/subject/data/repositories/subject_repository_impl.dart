import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_local_data_source.dart';
import '../datasources/subject_remote_data_source.dart';
import '../models/subject_local.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource _localDataSource;
  final SubjectRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  SubjectRepositoryImpl({
    required SubjectLocalDataSource localDataSource,
    required SubjectRemoteDataSource remoteDataSource,
    required AuthLocalDataSource authLocalDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _authLocalDataSource = authLocalDataSource;

  Subject _toEntity(SubjectLocal local) {
    return Subject(
      id: local.id,
      serverId: local.serverId,
      semesterId: local.semesterId,
      name: local.name,
      code: local.code,
      faculty: local.faculty,
      credits: local.credits,
      attendanceTarget: local.attendanceTarget,
      color: local.color,
      type: local.type == 'LAB' ? SubjectType.LAB : SubjectType.THEORY,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  SubjectLocal _toLocal(Subject subject) {
    return SubjectLocal()
      ..id = subject.id ?? 0
      ..serverId = subject.serverId
      ..semesterId = subject.semesterId
      ..name = subject.name
      ..code = subject.code
      ..faculty = subject.faculty
      ..credits = subject.credits
      ..attendanceTarget = subject.attendanceTarget
      ..color = subject.color
      ..type = subject.type.toShortString()
      ..updatedAt = subject.updatedAt
      ..isDirty = subject.isDirty
      ..isDeleted = subject.isDeleted;
  }

  @override
  Future<List<Subject>> getSubjectsBySemester(int semesterId) async {
    final list = await _localDataSource.getSubjectsBySemester(semesterId);
    return list.map(_toEntity).toList();
  }

  @override
  Future<Subject?> getSubjectById(int id) async {
    final local = await _localDataSource.getSubjectById(id);
    if (local != null && !local.isDeleted) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<void> createSubject(Subject subject) async {
    final cachedUser = await _authLocalDataSource.getUser();
    final uid = cachedUser?.uid ?? 'anonymous';

    String? serverId;
    bool isDirty = true;

    try {
      serverId = await _remoteDataSource.saveSubject(
        uid: uid,
        semesterId: subject.semesterId.toString(),
        name: subject.name,
        code: subject.code,
        faculty: subject.faculty,
        credits: subject.credits,
        attendanceTarget: subject.attendanceTarget,
        color: subject.color,
        type: subject.type.toShortString(),
      );
      isDirty = false;
    } catch (e) {
      serverId = null;
      isDirty = true;
    }

    final localSubject = _toLocal(subject)
      ..serverId = serverId
      ..isDirty = isDirty
      ..updatedAt = DateTime.now();

    await _localDataSource.saveSubject(localSubject);
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    final cachedUser = await _authLocalDataSource.getUser();
    final uid = cachedUser?.uid ?? 'anonymous';

    bool isDirty = true;
    try {
      if (subject.serverId != null) {
        await _remoteDataSource.saveSubject(
          uid: uid,
          semesterId: subject.semesterId.toString(),
          name: subject.name,
          code: subject.code,
          faculty: subject.faculty,
          credits: subject.credits,
          attendanceTarget: subject.attendanceTarget,
          color: subject.color,
          type: subject.type.toShortString(),
          serverId: subject.serverId,
        );
        isDirty = false;
      }
    } catch (e) {
      isDirty = true;
    }

    final localSubject = _toLocal(subject)
      ..isDirty = isDirty
      ..updatedAt = DateTime.now();

    await _localDataSource.saveSubject(localSubject);
  }

  @override
  Future<void> deleteSubject(int id) async {
    final local = await _localDataSource.getSubjectById(id);
    if (local != null) {
      bool isDirty = true;
      try {
        if (local.serverId != null) {
          await _remoteDataSource.deleteSubject(local.serverId!);
          isDirty = false;
        }
      } catch (e) {
        isDirty = true;
      }

      local.isDeleted = true;
      local.isDirty = isDirty;
      local.updatedAt = DateTime.now();

      await _localDataSource.saveSubject(local);
    }
  }
}
