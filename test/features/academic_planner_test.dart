import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/task_enums.dart';
import 'package:attend_iq/features/academic_planner/domain/repositories/task_repository.dart';
import 'package:attend_iq/features/academic_planner/presentation/controllers/task_controller.dart';
import 'package:attend_iq/features/academic_planner/services/task_notification_scheduler.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/academic_calendar_controller.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';

class FakeTaskRepository implements TaskRepository {
  final List<AcademicTask> _tasks = [];
  final StreamController<void> _controller = StreamController<void>.broadcast();

  @override
  Future<List<AcademicTask>> getAllTasks() async => List.from(_tasks.where((t) => !t.isDeleted));

  @override
  Future<AcademicTask?> getTaskById(int id) async {
    try {
      return _tasks.firstWhere((t) => t.id == id && !t.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveTask(AcademicTask task) async {
    if (task.id == null || task.id == 0) {
      final newId = _tasks.length + 1;
      final savedTask = task.copyWith(id: newId);
      _tasks.add(savedTask);
    } else {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      } else {
        _tasks.add(task);
      }
    }
    _controller.add(null);
  }

  @override
  Future<void> deleteTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isDeleted: true);
    }
    _controller.add(null);
  }

  @override
  Stream<void> watchTasks() => _controller.stream;
}

class FakeNotificationService implements NotificationService {
  final List<NotificationItem> scheduledItems = [];
  final List<int> cancelledIds = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleNotification(NotificationItem item) async {
    scheduledItems.add(item);
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    scheduledItems.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTaskRepository fakeRepo;
  late FakeNotificationService fakeNotifService;

  setUp(() {
    fakeRepo = FakeTaskRepository();
    fakeNotifService = FakeNotificationService();
  });

  test('Urgency Calculation test (Overdue, Urgent <3d, Warning 3-7d, Normal 7+d)', () {
    final now = DateTime(2026, 7, 20, 10, 0);

    // Overdue
    final overdueTask = AcademicTask(
      id: 1,
      title: 'Overdue Assignment',
      taskType: TaskType.ASSIGNMENT,
      startDate: DateTime(2026, 7, 10),
      dueDate: DateTime(2026, 7, 19, 23, 59),
      priority: TaskPriority.HIGH,
      status: TaskStatus.PENDING,
      reminder: TaskReminder.DAYS_1,
      createdAt: now,
      updatedAt: now,
    );
    expect(overdueTask.urgencyAt(now), equals(TaskUrgency.OVERDUE));
    expect(overdueTask.remainingDaysText(now), contains('Overdue'));

    // Urgent (< 3 days)
    final urgentTask = AcademicTask(
      id: 2,
      title: 'OS Quiz',
      taskType: TaskType.QUIZ,
      startDate: DateTime(2026, 7, 19),
      dueDate: DateTime(2026, 7, 22, 14, 0),
      priority: TaskPriority.CRITICAL,
      status: TaskStatus.PENDING,
      reminder: TaskReminder.HOURS_2,
      createdAt: now,
      updatedAt: now,
    );
    expect(urgentTask.urgencyAt(now), equals(TaskUrgency.URGENT));
    expect(urgentTask.daysRemainingAt(now), equals(2));

    // Warning (3 to 7 days)
    final warningTask = AcademicTask(
      id: 3,
      title: 'DBMS Lab Submission',
      taskType: TaskType.LAB_SUBMISSION,
      startDate: DateTime(2026, 7, 19),
      dueDate: DateTime(2026, 7, 25, 23, 59),
      priority: TaskPriority.MEDIUM,
      status: TaskStatus.PENDING,
      reminder: TaskReminder.DAYS_1,
      createdAt: now,
      updatedAt: now,
    );
    expect(warningTask.urgencyAt(now), equals(TaskUrgency.WARNING));

    // Normal (7+ days)
    final normalTask = AcademicTask(
      id: 4,
      title: 'Final Project',
      taskType: TaskType.PROJECT,
      startDate: DateTime(2026, 7, 19),
      dueDate: DateTime(2026, 8, 1, 23, 59),
      priority: TaskPriority.LOW,
      status: TaskStatus.PENDING,
      reminder: TaskReminder.DAYS_2,
      createdAt: now,
      updatedAt: now,
    );
    expect(normalTask.urgencyAt(now), equals(TaskUrgency.NORMAL));
  });

  test('Creating and editing tasks via TaskListController', () async {
    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(fakeRepo),
        taskNotificationSchedulerProvider.overrideWithValue(TaskNotificationScheduler(fakeNotifService)),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(taskListControllerProvider.notifier);
    await container.read(taskListControllerProvider.future);

    // Create Task
    await controller.addTask(
      title: 'OS Project',
      description: 'Implement memory management module',
      taskType: TaskType.PROJECT,
      startDate: DateTime(2026, 7, 20),
      dueDate: DateTime(2026, 7, 25, 23, 59),
      priority: TaskPriority.HIGH,
      reminder: TaskReminder.DAYS_1,
    );

    await container.read(taskListControllerProvider.future);
    var tasks = container.read(allTasksProvider);
    expect(tasks.length, equals(1));
    expect(tasks.first.title, equals('OS Project'));
    expect(tasks.first.taskType, equals(TaskType.PROJECT));

    // Edit Task
    final createdTask = tasks.first;
    final updatedTask = createdTask.copyWith(
      title: 'OS Advanced Project',
      priority: TaskPriority.CRITICAL,
    );
    await controller.updateTask(updatedTask);

    await container.read(taskListControllerProvider.future);
    tasks = container.read(allTasksProvider);
    expect(tasks.first.title, equals('OS Advanced Project'));
    expect(tasks.first.priority, equals(TaskPriority.CRITICAL));
  });

  test('Completing task toggles status and updates provider filters', () async {
    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(fakeRepo),
        taskNotificationSchedulerProvider.overrideWithValue(TaskNotificationScheduler(fakeNotifService)),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(taskListControllerProvider.notifier);
    await container.read(taskListControllerProvider.future);

    await controller.addTask(
      title: 'DBMS Assignment',
      taskType: TaskType.ASSIGNMENT,
      startDate: DateTime(2026, 7, 20),
      dueDate: DateTime(2026, 7, 21, 18, 0),
      priority: TaskPriority.MEDIUM,
      reminder: TaskReminder.HOURS_2,
    );

    await container.read(taskListControllerProvider.future);
    var tasks = container.read(allTasksProvider);
    final taskId = tasks.first.id!;

    expect(container.read(completedTasksProvider).length, equals(0));
    expect(container.read(upcomingTasksProvider).length, equals(1));

    // Toggle complete
    await controller.toggleTaskCompletion(taskId);

    await container.read(taskListControllerProvider.future);
    expect(container.read(completedTasksProvider).length, equals(1));
    expect(container.read(upcomingTasksProvider).length, equals(0));
    expect(container.read(completedTasksProvider).first.status, equals(TaskStatus.COMPLETED));

    // Toggle back to pending
    await controller.toggleTaskCompletion(taskId);

    await container.read(taskListControllerProvider.future);
    expect(container.read(completedTasksProvider).length, equals(0));
    expect(container.read(upcomingTasksProvider).length, equals(1));
  });

  test('Notification Scheduling calculates time and cancels on completion', () async {
    final scheduler = TaskNotificationScheduler(fakeNotifService);

    // Future due date 3 days from now
    final futureDue = DateTime.now().add(const Duration(days: 3));

    final task = AcademicTask(
      id: 10,
      title: 'DBMS Assignment',
      taskType: TaskType.ASSIGNMENT,
      startDate: DateTime.now(),
      dueDate: futureDue,
      priority: TaskPriority.HIGH,
      status: TaskStatus.PENDING,
      reminder: TaskReminder.DAYS_1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await scheduler.scheduleTaskNotification(task, subjectName: 'DBMS');

    expect(fakeNotifService.scheduledItems.length, equals(1));
    expect(fakeNotifService.scheduledItems.first.body, contains('DBMS Assignment deadline tomorrow'));

    // Cancel notification on complete
    final completedTask = task.copyWith(status: TaskStatus.COMPLETED);
    await scheduler.scheduleTaskNotification(completedTask);

    expect(fakeNotifService.cancelledIds, contains(800010));
  });

  test('Academic Calendar includes Task Deadline items and displays hasTask indicator', () async {
    final testSemester = Semester(
      id: 'sem_1',
      localId: 1,
      name: 'Fall 2026',
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 12, 31),
      requiredAttendanceRate: 75.0,
    );

    final testTask = AcademicTask(
      id: 100,
      title: 'Algorithm Submission',
      taskType: TaskType.ASSIGNMENT,
      startDate: DateTime(2026, 7, 20),
      dueDate: DateTime(2026, 7, 25, 23, 59),
      priority: TaskPriority.CRITICAL,
      status: TaskStatus.PENDING,
      reminder: TaskReminder.DAYS_1,
      createdAt: DateTime(2026, 7, 20),
      updatedAt: DateTime(2026, 7, 20),
    );

    final container = ProviderContainer(
      overrides: [
        allTasksProvider.overrideWith((ref) => [testTask]),
        activeSemesterProvider.overrideWith((ref) => Future.value(testSemester)),
        selectedMonthProvider.overrideWith((ref) => DateTime(2026, 7, 1)),
      ],
    );
    addTearDown(container.dispose);

    final daysAsync = container.read(monthlyCalendarDataProvider);
    final days = daysAsync.value!;

    final july25 = days.firstWhere((d) => d.date.year == 2026 && d.date.month == 7 && d.date.day == 25);
    expect(july25.hasTask, isTrue);
    expect(july25.items.any((i) => i.type == CalendarItemType.TASK && i.title == 'Algorithm Submission'), isTrue);
  });
}
