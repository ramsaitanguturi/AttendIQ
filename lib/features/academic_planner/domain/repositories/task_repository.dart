import '../entities/academic_task.dart';

abstract class TaskRepository {
  Future<List<AcademicTask>> getAllTasks();
  Future<AcademicTask?> getTaskById(int id);
  Future<void> saveTask(AcademicTask task);
  Future<void> deleteTask(int id);
  Stream<void> watchTasks();
}
