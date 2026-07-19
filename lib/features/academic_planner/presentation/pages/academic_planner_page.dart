import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attend_iq/core/theme/colors.dart';
import '../../domain/entities/academic_task.dart';
import '../controllers/task_controller.dart';
import '../widgets/add_edit_task_sheet.dart';
import '../widgets/task_card_widget.dart';

class AcademicPlannerPage extends ConsumerStatefulWidget {
  const AcademicPlannerPage({super.key});

  @override
  ConsumerState<AcademicPlannerPage> createState() => _AcademicPlannerPageState();
}

class _AcademicPlannerPageState extends ConsumerState<AcademicPlannerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<AcademicTask> _filterTasks(List<AcademicTask> tasks) {
    if (_searchQuery.trim().isEmpty) return tasks;
    final query = _searchQuery.toLowerCase();
    return tasks.where((t) {
      return t.title.toLowerCase().contains(query) ||
          (t.description != null && t.description!.toLowerCase().contains(query)) ||
          t.taskType.displayName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allTasks = _filterTasks(ref.watch(allTasksProvider));
    final todayTasks = _filterTasks(ref.watch(todayTasksProvider));
    final upcomingTasks = _filterTasks(ref.watch(upcomingTasksProvider));
    final completedTasks = _filterTasks(ref.watch(completedTasksProvider));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'All Tasks (${allTasks.length})'),
            Tab(text: 'Today (${todayTasks.length})'),
            Tab(text: 'Upcoming (${upcomingTasks.length})'),
            Tab(text: 'Completed (${completedTasks.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks by title, note, type...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.grey[200],
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
            ),
          ),

          // Tab Bar Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(allTasks, 'No tasks found. Tap + to add one!'),
                _buildTaskList(todayTasks, 'No tasks due today!'),
                _buildTaskList(upcomingTasks, 'No upcoming tasks scheduled!'),
                _buildTaskList(completedTasks, 'No completed tasks yet!'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const AddEditTaskSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildTaskList(List<AcademicTask> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_turned_in_outlined,
                size: 64,
                color: AppColors.primary.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCardWidget(task: tasks[index]);
      },
    );
  }
}
