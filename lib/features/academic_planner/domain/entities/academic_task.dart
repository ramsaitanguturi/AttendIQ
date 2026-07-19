import 'task_enums.dart';

class AcademicTask {
  final int? id;
  final String? serverId;
  final String title;
  final String? description;
  final TaskType taskType;
  final int? subjectId;
  final DateTime startDate;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskReminder reminder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDirty;
  final bool isDeleted;

  const AcademicTask({
    this.id,
    this.serverId,
    required this.title,
    this.description,
    required this.taskType,
    this.subjectId,
    required this.startDate,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.reminder,
    required this.createdAt,
    required this.updatedAt,
    this.isDirty = true,
    this.isDeleted = false,
  });

  TaskUrgency urgencyAt(DateTime now) {
    return TaskUrgency.calculate(dueDate, now, status: status);
  }

  int daysRemainingAt(DateTime now) {
    if (status == TaskStatus.COMPLETED) return 0;
    final cleanDue = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final cleanNow = DateTime(now.year, now.month, now.day);
    return cleanDue.difference(cleanNow).inDays;
  }

  String remainingDaysText(DateTime now) {
    if (status == TaskStatus.COMPLETED) {
      return 'Completed';
    }
    final days = daysRemainingAt(now);
    if (dueDate.isBefore(now)) {
      if (days == 0) return 'Overdue today';
      final overdueDays = days.abs();
      return overdueDays == 1 ? 'Overdue by 1 day' : 'Overdue by $overdueDays days';
    }
    if (days == 0) {
      final hours = dueDate.difference(now).inHours;
      if (hours > 0) return 'Due in $hours hrs';
      return 'Due today';
    }
    return days == 1 ? 'Due tomorrow' : 'Due in $days days';
  }

  AcademicTask copyWith({
    int? id,
    String? serverId,
    String? title,
    String? description,
    TaskType? taskType,
    int? subjectId,
    DateTime? startDate,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    TaskReminder? reminder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  }) {
    return AcademicTask(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      subjectId: subjectId ?? this.subjectId,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      reminder: reminder ?? this.reminder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serverId == other.serverId &&
          title == other.title &&
          description == other.description &&
          taskType == other.taskType &&
          subjectId == other.subjectId &&
          startDate == other.startDate &&
          dueDate == other.dueDate &&
          priority == other.priority &&
          status == other.status &&
          reminder == other.reminder &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isDirty == other.isDirty &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      id.hashCode ^
      serverId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      taskType.hashCode ^
      subjectId.hashCode ^
      startDate.hashCode ^
      dueDate.hashCode ^
      priority.hashCode ^
      status.hashCode ^
      reminder.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isDirty.hashCode ^
      isDeleted.hashCode;
}
