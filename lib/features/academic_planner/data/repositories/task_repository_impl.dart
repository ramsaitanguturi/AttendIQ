import '../../domain/entities/academic_task.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../models/academic_task_local.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  AcademicTask _toDomain(AcademicTaskLocal local) {
    return AcademicTask(
      id: local.id,
      serverId: local.serverId,
      title: local.title,
      description: local.description,
      taskType: TaskType.fromString(local.taskType),
      subjectId: local.subjectId,
      startDate: local.startDate,
      dueDate: local.dueDate,
      priority: TaskPriority.fromString(local.priority),
      status: TaskStatus.fromString(local.status),
      reminder: TaskReminder.fromString(local.reminder),
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  AcademicTaskLocal _toLocal(AcademicTask domain) {
    final local = AcademicTaskLocal()
      ..id = domain.id ?? 0
      ..serverId = domain.serverId
      ..title = domain.title
      ..description = domain.description
      ..taskType = domain.taskType.name
      ..subjectId = domain.subjectId
      ..startDate = domain.startDate
      ..dueDate = domain.dueDate
      ..priority = domain.priority.name
      ..status = domain.status.name
      ..reminder = domain.reminder.name
      ..createdAt = domain.createdAt
      ..updatedAt = domain.updatedAt
      ..isDirty = domain.isDirty
      ..isDeleted = domain.isDeleted;
    return local;
  }

  @override
  Future<List<AcademicTask>> getAllTasks() async {
    final list = await _dataSource.getAllTasks();
    return list.map(_toDomain).toList();
  }

  @override
  Future<AcademicTask?> getTaskById(int id) async {
    final local = await _dataSource.getTaskById(id);
    return local != null ? _toDomain(local) : null;
  }

  @override
  Future<void> saveTask(AcademicTask task) async {
    final local = _toLocal(task);
    await _dataSource.saveTask(local);
  }

  @override
  Future<void> deleteTask(int id) async {
    await _dataSource.deleteTask(id);
  }

  @override
  Stream<void> watchTasks() {
    return _dataSource.watchTasks();
  }
}
