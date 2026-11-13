import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/presentation/controllers/subject_controller.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/task_enums.dart';
import 'package:attend_iq/features/academic_planner/domain/repositories/task_repository.dart';
import 'package:attend_iq/features/academic_planner/services/task_notification_scheduler.dart';
import 'package:attend_iq/features/academic_planner/presentation/controllers/task_controller.dart';
import 'package:attend_iq/features/academic_planner/presentation/widgets/add_edit_task_sheet.dart';

class _FakeTaskRepository implements TaskRepository {
  final List<AcademicTask> _tasks = [];
  final _controller = StreamController<void>.broadcast();
  bool shouldFailOnSave = false;

  @override
  Future<List<AcademicTask>> getAllTasks() async =>
      List.from(_tasks.where((t) => !t.isDeleted));

  @override
  Future<AcademicTask?> getTaskById(int id) async =>
      _tasks.where((t) => t.id == id && !t.isDeleted).firstOrNull;

  @override
  Future<void> saveTask(AcademicTask task) async {
    if (shouldFailOnSave) {
      throw Exception('Simulated DB disk failure');
    }
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

class _FakeNotificationService implements NotificationService {
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
    scheduledItems.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    scheduledItems.clear();
  }
}

class _FakeSubjectListNotifier extends SubjectListController {
  final List<Subject> _subjects;
  _FakeSubjectListNotifier(this._subjects);

  @override
  FutureOr<List<Subject>> build() => _subjects;
}

void main() {
  group('BUG-019: Task list crashes and overdue filtering regression tests',
      () {
    late _FakeTaskRepository fakeRepo;
    late _FakeNotificationService fakeNotifService;

    final subjectCs = Subject(
      id: 10,
      semesterId: 1,
      name: 'Computer Science',
      code: 'CS101',
      credits: 4,
      attendanceTarget: 75,
      color: '#4F46E5',
      type: SubjectType.THEORY,
      updatedAt: DateTime.now(),
    );

    setUp(() {
      fakeRepo = _FakeTaskRepository();
      fakeNotifService = _FakeNotificationService();
    });

    ProviderContainer createContainer({List<Subject> subjects = const []}) {
      return ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(fakeRepo),
          taskNotificationSchedulerProvider
              .overrideWithValue(TaskNotificationScheduler(fakeNotifService)),
          subjectListControllerProvider
              .overrideWith(() => _FakeSubjectListNotifier(subjects)),
        ],
      );
    }

    test(
        '1. Empty-list safety: adding task with subjectId when subjects list is empty does not throw StateError',
        () async {
      // subjects is empty!
      final container = createContainer(subjects: []);
      addTearDown(container.dispose);

      final controller = container.read(taskListControllerProvider.notifier);
      await container.read(taskListControllerProvider.future);

      // Adding task with non-null subjectId (e.g. 99) when subjects is empty
      // Pre-fix: subjects.firstWhere(..., orElse: () => subjects.first) threw StateError!
      await controller.addTask(
        title: 'Empty Subject Safety Task',
        taskType: TaskType.ASSIGNMENT,
        subjectId: 99,
        startDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.HIGH,
        reminder: TaskReminder.HOURS_1,
      );

      await container.read(taskListControllerProvider.future);

      final tasks = container.read(allTasksProvider);
      expect(tasks, hasLength(1));
      expect(tasks.first.title, equals('Empty Subject Safety Task'));
      expect(tasks.first.subjectId, equals(99));
    });

    test(
        '2. Overdue task filtering: overdue tasks appear in overdueTasksProvider, NOT in upcomingTasksProvider',
        () async {
      final container = createContainer(subjects: [subjectCs]);
      addTearDown(container.dispose);

      final controller = container.read(taskListControllerProvider.notifier);
      await container.read(taskListControllerProvider.future);

      final now = DateTime.now();

      // Task 1: Overdue (due 2 days ago)
      await controller.addTask(
        title: 'Past Due Task',
        taskType: TaskType.ASSIGNMENT,
        subjectId: 10,
        startDate: now.subtract(const Duration(days: 5)),
        dueDate: now.subtract(const Duration(days: 2)),
        priority: TaskPriority.CRITICAL,
        reminder: TaskReminder.NONE,
      );

      // Task 2: Upcoming (due 3 days in future)
      await controller.addTask(
        title: 'Future Upcoming Task',
        taskType: TaskType.PROJECT,
        subjectId: 10,
        startDate: now,
        dueDate: now.add(const Duration(days: 3)),
        priority: TaskPriority.MEDIUM,
        reminder: TaskReminder.DAYS_1,
      );

      await container.read(taskListControllerProvider.future);

      final all = container.read(allTasksProvider);
      final upcoming = container.read(upcomingTasksProvider);
      final overdue = container.read(overdueTasksProvider);

      expect(all, hasLength(2));
      // Pre-fix: upcoming had length 2 because of `|| t.dueDate.isBefore(now)`
      expect(upcoming, hasLength(1));
      expect(upcoming.first.title, equals('Future Upcoming Task'));

      expect(overdue, hasLength(1));
      expect(overdue.first.title, equals('Past Due Task'));
    });

    test(
        '3. Completed tasks appear only in completedTasksProvider and not in upcoming or overdue',
        () async {
      final container = createContainer(subjects: [subjectCs]);
      addTearDown(container.dispose);

      final controller = container.read(taskListControllerProvider.notifier);
      await container.read(taskListControllerProvider.future);

      final now = DateTime.now();

      // Add a past due task that is completed
      await controller.addTask(
        title: 'Completed Past Task',
        taskType: TaskType.ASSIGNMENT,
        subjectId: 10,
        startDate: now.subtract(const Duration(days: 5)),
        dueDate: now.subtract(const Duration(days: 2)),
        priority: TaskPriority.LOW,
        reminder: TaskReminder.NONE,
      );

      await container.read(taskListControllerProvider.future);
      final taskId = container.read(allTasksProvider).first.id!;

      // Mark completed
      await controller.toggleTaskCompletion(taskId);
      await container.read(taskListControllerProvider.future);

      final completed = container.read(completedTasksProvider);
      final upcoming = container.read(upcomingTasksProvider);
      final overdue = container.read(overdueTasksProvider);

      expect(completed, hasLength(1));
      expect(completed.first.title, equals('Completed Past Task'));
      expect(upcoming, isEmpty);
      expect(overdue, isEmpty);
    });

    testWidgets(
        '4. Deleted subject handling: editing a task referencing a deleted subject does not crash dropdown',
        (tester) async {
      // Existing task references subjectId: 888, but active subjects list only contains subjectCs (id: 10)
      final taskWithDeletedSubject = AcademicTask(
        id: 1,
        title: 'Task for Archived Subject',
        taskType: TaskType.ASSIGNMENT,
        subjectId: 888, // Subject 888 is deleted / absent from active list
        startDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: TaskPriority.MEDIUM,
        status: TaskStatus.PENDING,
        reminder: TaskReminder.DAYS_1,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(fakeRepo),
            taskNotificationSchedulerProvider
                .overrideWithValue(TaskNotificationScheduler(fakeNotifService)),
            subjectListControllerProvider
                .overrideWith(() => _FakeSubjectListNotifier([subjectCs])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AddEditTaskSheet(taskToEdit: taskWithDeletedSubject),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no Flutter assertion error was thrown
      expect(tester.takeException(), isNull);

      // Verify deleted subject option is rendered in dropdown
      expect(find.text('Deleted Subject (#888)'), findsOneWidget);
    });

    testWidgets(
        '5. Task editing: save failure preserves user input and displays error',
        (tester) async {
      fakeRepo.shouldFailOnSave = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(fakeRepo),
            taskNotificationSchedulerProvider
                .overrideWithValue(TaskNotificationScheduler(fakeNotifService)),
            subjectListControllerProvider
                .overrideWith(() => _FakeSubjectListNotifier([subjectCs])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AddEditTaskSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter title
      await tester.enterText(
          find.byType(TextFormField).first, 'Unsaved Important Task');
      await tester.pumpAndSettle();

      // Tap Create Task
      final createButtonFinder = find.text('Create Task');
      await tester.ensureVisible(createButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(createButtonFinder);
      await tester.pumpAndSettle();

      // Sheet must NOT have popped! It must still be visible with the user input
      expect(find.byType(AddEditTaskSheet), findsOneWidget);
      expect(find.text('Unsaved Important Task'), findsOneWidget);

      // Meaningful error message SnackBar displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to save task'), findsOneWidget);
    });
  });
}
