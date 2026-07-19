import 'package:isar/isar.dart';
import '../../domain/entities/semester.dart';
import '../../domain/repositories/semester_repository.dart';
import '../models/semester_local.dart';
import '../../../../core/utils/uuid_generator.dart';

class SemesterRepositoryImpl implements SemesterRepository {
  final Isar _isar;

  SemesterRepositoryImpl(this._isar);

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
      ..isDirty = false
      ..isDeleted = false;

    await _isar.writeAsync((isar) {
      if (localSemester.id == 0) {
        localSemester.id = isar.semesterLocals.autoIncrement();
      }
      isar.semesterLocals.put(localSemester);
    });
  }

  @override
  Future<Semester?> getActiveSemester() async {
    final list = await _isar.semesterLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();

    if (list.isNotEmpty) {
      final cached = list.last;
      return Semester(
        id: cached.serverId ?? cached.id.toString(),
        localId: cached.id,
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
    final count = await _isar.semesterLocals
        .where()
        .isDeletedEqualTo(false)
        .count();
    return count > 0;
  }

  @override
  Future<List<Semester>> getAllSemesters() async {
    final list = await _isar.semesterLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();

    return list.map((cached) => Semester(
      id: cached.serverId ?? cached.id.toString(),
      localId: cached.id,
      name: cached.name,
      startDate: cached.startDate,
      endDate: cached.endDate,
      requiredAttendanceRate: cached.requiredAttendanceRate,
    )).toList();
  }
}
