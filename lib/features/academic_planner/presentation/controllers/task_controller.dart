import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attend_iq/core/database/isar_provider.dart';
import 'package:attend_iq/core/notifications/providers/notification_providers.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/academic_task.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../services/task_notification_scheduler.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final isar = ref.watch(isarProvider).requireValue;
  final dataSource = TaskLocalDataSourceImpl(isar);
  return TaskRepositoryImpl(dataSource);
});

final taskNotificationSchedulerProvider = Provider<TaskNotificationScheduler>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return TaskNotificationScheduler(notificationService);
});

class TaskListController extends AsyncNotifier<List<AcademicTask>> {
  StreamSubscription<void>? _subscription;

  @override
  FutureOr<List<AcademicTask>> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    _subscription?.cancel();
    _subscription = repository.watchTasks().listen((_) async {
      ref.invalidateSelf();
    });
    ref.onDispose(() => _subscription?.cancel());

    final tasks = await repository.getAllTasks();
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }

  Future<void> addTask({
    required String title,
    String? description,
    required TaskType taskType,
    int? subjectId,
    required DateTime startDate,
    required DateTime dueDate,
    required TaskPriority priority,
    required TaskReminder reminder,
  }) async {
    final repository = ref.read(taskRepositoryProvider);
    final scheduler = ref.read(taskNotificationSchedulerProvider);
    final now = DateTime.now().toUtc();

    final task = AcademicTask(
      title: title,
      description: description,
      taskType: taskType,
      subjectId: subjectId,
      startDate: startDate,
      dueDate: dueDate,
      priority: priority,
      status: TaskStatus.PENDING,
      reminder: reminder,
      createdAt: now,
      updatedAt: now,
      isDirty: true,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.saveTask(task);
      final updatedList = await repository.getAllTasks();
      
      // Get saved task to have valid id
      final savedTask = updatedList.firstWhere(
        (t) => t.title == title && t.dueDate == dueDate,
        orElse: () => updatedList.last,
      );

      // Schedule notification
      String? subjectName;
      if (subjectId != null) {
        final subjects = ref.read(subjectListControllerProvider).valueOrNull ?? [];
        final sub = subjects.firstWhere((s) => s.id == subjectId, orElse: () => subjects.first);
        subjectName = sub.name;
      }
      await scheduler.scheduleTaskNotification(savedTask, subjectName: subjectName);

      updatedList.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return updatedList;
    });
  }

  Future<void> updateTask(AcademicTask task) async {
    final repository = ref.read(taskRepositoryProvider);
    final scheduler = ref.read(taskNotificationSchedulerProvider);

    final updatedTask = task.copyWith(
      updatedAt: DateTime.now().toUtc(),
      isDirty: true,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.saveTask(updatedTask);
      
      String? subjectName;
      if (updatedTask.subjectId != null) {
        final subjects = ref.read(subjectListControllerProvider).valueOrNull ?? [];
        final sub = subjects.firstWhere((s) => s.id == updatedTask.subjectId, orElse: () => subjects.first);
        subjectName = sub.name;
      }
      await scheduler.scheduleTaskNotification(updatedTask, subjectName: subjectName);

      final list = await repository.getAllTasks();
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return list;
    });
  }

  Future<void> toggleTaskCompletion(int taskId) async {
    final currentTasks = state.valueOrNull ?? [];
    final index = currentTasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final existingTask = currentTasks[index];
    final newStatus = existingTask.status == TaskStatus.COMPLETED
        ? TaskStatus.PENDING
        : TaskStatus.COMPLETED;

    final updatedTask = existingTask.copyWith(
      status: newStatus,
      updatedAt: DateTime.now().toUtc(),
      isDirty: true,
    );

    await updateTask(updatedTask);
  }

  Future<void> deleteTask(int taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    final scheduler = ref.read(taskNotificationSchedulerProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteTask(taskId);
      await scheduler.cancelTaskNotification(taskId);

      final list = await repository.getAllTasks();
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return list;
    });
  }
}

final taskListControllerProvider = AsyncNotifierProvider<TaskListController, List<AcademicTask>>(() {
  return TaskListController();
});

// Filtered Selectors
final allTasksProvider = Provider<List<AcademicTask>>((ref) {
  final tasksAsync = ref.watch(taskListControllerProvider);
  final tasks = tasksAsync.valueOrNull ?? [];
  final list = List<AcademicTask>.from(tasks);
  list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return list;
});

final todayTasksProvider = Provider<List<AcademicTask>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  final now = DateTime.now();
  final todayClean = DateTime(now.year, now.month, now.day);

  return tasks.where((t) {
    final dueClean = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
    return dueClean.isAtSameMomentAs(todayClean);
  }).toList();
});

final upcomingTasksProvider = Provider<List<AcademicTask>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  final now = DateTime.now();
  final todayClean = DateTime(now.year, now.month, now.day);

  return tasks.where((t) {
    if (t.status == TaskStatus.COMPLETED) return false;
    final dueClean = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
    return dueClean.isAfter(todayClean) || dueClean.isAtSameMomentAs(todayClean) || t.dueDate.isBefore(now);
  }).toList();
});

final completedTasksProvider = Provider<List<AcademicTask>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  return tasks.where((t) => t.status == TaskStatus.COMPLETED).toList();
});

final dashboardUpcomingTasksProvider = Provider<List<AcademicTask>>((ref) {
  final upcoming = ref.watch(upcomingTasksProvider);
  return upcoming.take(5).toList();
});
