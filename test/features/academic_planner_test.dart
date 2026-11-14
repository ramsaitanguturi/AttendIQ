import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/task_enums.dart';
import 'package:attend_iq/features/academic_planner/data/datasources/task_local_datasource.dart';
import 'package:attend_iq/features/academic_planner/data/repositories/task_repository_impl.dart';
import 'package:attend_iq/features/academic_planner/presentation/controllers/task_controller.dart';
import 'package:attend_iq/features/academic_planner/services/task_notification_scheduler.dart';
import 'package:attend_iq/features/timetable/presentation/controllers/academic_calendar_controller.dart';
import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/presentation/controllers/semester_controller.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import '../test_helpers/test_isar_helper.dart';

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

  late TestIsarInstance testDb;
  late TaskLocalDataSourceImpl localDataSource;
  late TaskRepositoryImpl repository;
  late FakeNotificationService fakeNotifService;

  setUpAll(() async {
    await ensureIsarInitialized();
  });

  setUp(() {
    testDb = openTestIsar(prefix: 'tasks_crud');
    localDataSource = TaskLocalDataSourceImpl(testDb.isar);
    repository = TaskRepositoryImpl(localDataSource);
    fakeNotifService = FakeNotificationService();
  });

  tearDown(() async {
    await testDb.dispose();
  });

  test(
      'Urgency Calculation test (Overdue, Urgent <3d, Warning 3-7d, Normal 7+d)',
      () {
    final now = DateTime(2026, 7, 20, 10, 0);

    // Overdue
    final overdueTask = AcademicTask(
      id: 1,
      title: 'Overdue Assignment',
      taskType: TaskType.assignment,
      startDate: DateTime(2026, 7, 10),
      dueDate: DateTime(2026, 7, 19, 23, 59),
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      reminder: TaskReminder.days1,
      createdAt: now,
      updatedAt: now,
    );
    expect(overdueTask.urgencyAt(now), equals(TaskUrgency.overdue));
    expect(overdueTask.remainingDaysText(now), contains('Overdue'));

    // Urgent (< 3 days)
    final urgentTask = AcademicTask(
      id: 2,
      title: 'OS Quiz',
      taskType: TaskType.quiz,
      startDate: DateTime(2026, 7, 19),
      dueDate: DateTime(2026, 7, 22, 14, 0),
      priority: TaskPriority.critical,
      status: TaskStatus.pending,
      reminder: TaskReminder.hours2,
      createdAt: now,
      updatedAt: now,
    );
    expect(urgentTask.urgencyAt(now), equals(TaskUrgency.urgent));
    expect(urgentTask.daysRemainingAt(now), equals(2));

    // Warning (3 to 7 days)
    final warningTask = AcademicTask(
      id: 3,
      title: 'DBMS Lab Submission',
      taskType: TaskType.labSubmission,
      startDate: DateTime(2026, 7, 19),
      dueDate: DateTime(2026, 7, 25, 23, 59),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      reminder: TaskReminder.days1,
      createdAt: now,
      updatedAt: now,
    );
    expect(warningTask.urgencyAt(now), equals(TaskUrgency.warning));

    // Normal (7+ days)
    final normalTask = AcademicTask(
      id: 4,
      title: 'Final Project',
      taskType: TaskType.project,
      startDate: DateTime(2026, 7, 19),
      dueDate: DateTime(2026, 8, 1, 23, 59),
      priority: TaskPriority.low,
      status: TaskStatus.pending,
      reminder: TaskReminder.days2,
      createdAt: now,
      updatedAt: now,
    );
    expect(normalTask.urgencyAt(now), equals(TaskUrgency.normal));
  });

  test('Creating and editing tasks via TaskListController (Real Isar Database)',
      () async {
    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        taskNotificationSchedulerProvider
            .overrideWithValue(TaskNotificationScheduler(fakeNotifService)),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(taskListControllerProvider.notifier);
    await container.read(taskListControllerProvider.future);

    // Create Task
    await controller.addTask(
      title: 'OS Project',
      description: 'Implement memory management module',
      taskType: TaskType.project,
      startDate: DateTime(2026, 7, 20),
      dueDate: DateTime(2026, 7, 25, 23, 59),
      priority: TaskPriority.high,
      reminder: TaskReminder.days1,
    );

    await container.read(taskListControllerProvider.future);
    var tasks = container.read(allTasksProvider);
    expect(tasks.length, equals(1));
    expect(tasks.first.title, equals('OS Project'));
    expect(tasks.first.taskType, equals(TaskType.project));

    // Edit Task
    final createdTask = tasks.first;
    final updatedTask = createdTask.copyWith(
      title: 'OS Advanced Project',
      priority: TaskPriority.critical,
    );
    await controller.updateTask(updatedTask);

    await container.read(taskListControllerProvider.future);
    tasks = container.read(allTasksProvider);
    expect(tasks.first.title, equals('OS Advanced Project'));
    expect(tasks.first.priority, equals(TaskPriority.critical));
  });

  test(
      'Completing task toggles status and updates provider filters (Real Isar Database)',
      () async {
    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repository),
        taskNotificationSchedulerProvider
            .overrideWithValue(TaskNotificationScheduler(fakeNotifService)),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(taskListControllerProvider.notifier);
    await container.read(taskListControllerProvider.future);

    await controller.addTask(
      title: 'DBMS Assignment',
      taskType: TaskType.assignment,
      startDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.medium,
      reminder: TaskReminder.hours2,
    );

    await container.read(taskListControllerProvider.future);
    final tasks = container.read(allTasksProvider);
    final taskId = tasks.first.id!;

    expect(container.read(completedTasksProvider).length, equals(0));
    expect(container.read(upcomingTasksProvider).length, equals(1));

    // Toggle complete
    await controller.toggleTaskCompletion(taskId);

    await container.read(taskListControllerProvider.future);
    expect(container.read(completedTasksProvider).length, equals(1));
    expect(container.read(upcomingTasksProvider).length, equals(0));
    expect(
      container.read(completedTasksProvider).first.status,
      equals(TaskStatus.completed),
    );

    // Toggle back to pending
    await controller.toggleTaskCompletion(taskId);

    await container.read(taskListControllerProvider.future);
    expect(container.read(completedTasksProvider).length, equals(0));
    expect(container.read(upcomingTasksProvider).length, equals(1));
  });

  test('Notification Scheduling calculates time and cancels on completion',
      () async {
    final scheduler = TaskNotificationScheduler(fakeNotifService);

    // Future due date 3 days from now
    final futureDue = DateTime.now().add(const Duration(days: 3));

    final task = AcademicTask(
      id: 10,
      title: 'DBMS Assignment',
      taskType: TaskType.assignment,
      startDate: DateTime.now(),
      dueDate: futureDue,
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      reminder: TaskReminder.days1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await scheduler.scheduleTaskNotification(task, subjectName: 'DBMS');

    expect(fakeNotifService.scheduledItems.length, equals(1));
    expect(
      fakeNotifService.scheduledItems.first.body,
      contains('DBMS Assignment deadline tomorrow'),
    );

    // Cancel notification on complete
    final completedTask = task.copyWith(status: TaskStatus.completed);
    await scheduler.scheduleTaskNotification(completedTask);

    expect(fakeNotifService.cancelledIds, contains(800010));
  });

  test(
      'Academic Calendar includes Task Deadline items and displays hasTask indicator',
      () async {
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
      taskType: TaskType.assignment,
      startDate: DateTime(2026, 7, 20),
      dueDate: DateTime(2026, 7, 25, 23, 59),
      priority: TaskPriority.critical,
      status: TaskStatus.pending,
      reminder: TaskReminder.days1,
      createdAt: DateTime(2026, 7, 20),
      updatedAt: DateTime(2026, 7, 20),
    );

    final container = ProviderContainer(
      overrides: [
        allTasksProvider.overrideWith((ref) => [testTask]),
        activeSemesterProvider
            .overrideWith((ref) => Future.value(testSemester)),
        selectedMonthProvider.overrideWith((ref) => DateTime(2026, 7, 1)),
      ],
    );
    addTearDown(container.dispose);

    final daysAsync = container.read(monthlyCalendarDataProvider);
    final days = daysAsync.value!;

    final july25 = days.firstWhere(
      (d) => d.date.year == 2026 && d.date.month == 7 && d.date.day == 25,
    );
    expect(july25.hasTask, isTrue);
    expect(
      july25.items.any(
        (i) =>
            i.type == CalendarItemType.task &&
            i.title == 'Algorithm Submission',
      ),
      isTrue,
    );
  });
}
