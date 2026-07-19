import 'package:isar/isar.dart';
import '../models/academic_task_local.dart';

abstract class TaskLocalDataSource {
  Future<List<AcademicTaskLocal>> getAllTasks();
  Future<AcademicTaskLocal?> getTaskById(int id);
  Future<void> saveTask(AcademicTaskLocal task);
  Future<void> deleteTask(int id);
  Stream<void> watchTasks();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Isar _isar;

  TaskLocalDataSourceImpl(this._isar);

  @override
  Future<List<AcademicTaskLocal>> getAllTasks() async {
    return _isar.academicTaskLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<AcademicTaskLocal?> getTaskById(int id) async {
    return _isar.academicTaskLocals.get(id);
  }

  @override
  Future<void> saveTask(AcademicTaskLocal task) async {
    await _isar.writeAsync((isar) {
      if (task.id == 0) {
        task.id = isar.academicTaskLocals.autoIncrement();
      }
      isar.academicTaskLocals.put(task);
    });
  }

  @override
  Future<void> deleteTask(int id) async {
    final task = await _isar.academicTaskLocals.get(id);
    if (task != null) {
      await _isar.writeAsync((isar) {
        task.isDeleted = true;
        task.updatedAt = DateTime.now().toUtc();
        isar.academicTaskLocals.put(task);
      });
    }
  }

  @override
  Stream<void> watchTasks() {
    return _isar.academicTaskLocals.where().isDeletedEqualTo(false).watch();
  }
}
