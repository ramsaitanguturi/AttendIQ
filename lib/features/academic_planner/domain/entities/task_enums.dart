import 'package:flutter/material.dart';

enum TaskType {
  MID_SEM,
  END_SEM,
  ASSIGNMENT,
  PROJECT,
  LAB_SUBMISSION,
  QUIZ,
  PRESENTATION,
  OTHER;

  String get displayName {
    switch (this) {
      case TaskType.MID_SEM:
        return 'Mid Sem';
      case TaskType.END_SEM:
        return 'End Sem';
      case TaskType.ASSIGNMENT:
        return 'Assignment';
      case TaskType.PROJECT:
        return 'Project';
      case TaskType.LAB_SUBMISSION:
        return 'Lab Submission';
      case TaskType.QUIZ:
        return 'Quiz';
      case TaskType.PRESENTATION:
        return 'Presentation';
      case TaskType.OTHER:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskType.MID_SEM:
      case TaskType.END_SEM:
        return Icons.menu_book;
      case TaskType.ASSIGNMENT:
        return Icons.assignment;
      case TaskType.PROJECT:
        return Icons.work_outline;
      case TaskType.LAB_SUBMISSION:
        return Icons.science;
      case TaskType.QUIZ:
        return Icons.quiz;
      case TaskType.PRESENTATION:
        return Icons.co_present;
      case TaskType.OTHER:
        return Icons.task_alt;
    }
  }

  static TaskType fromString(String value) {
    return TaskType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase() || e.displayName.toUpperCase() == value.toUpperCase(),
      orElse: () => TaskType.OTHER,
    );
  }
}

enum TaskPriority {
  LOW,
  MEDIUM,
  HIGH,
  CRITICAL;

  String get displayName {
    switch (this) {
      case TaskPriority.LOW:
        return 'Low';
      case TaskPriority.MEDIUM:
        return 'Medium';
      case TaskPriority.HIGH:
        return 'High';
      case TaskPriority.CRITICAL:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.LOW:
        return Colors.blue;
      case TaskPriority.MEDIUM:
        return Colors.green;
      case TaskPriority.HIGH:
        return Colors.orange;
      case TaskPriority.CRITICAL:
        return Colors.red;
    }
  }

  int get level {
    switch (this) {
      case TaskPriority.LOW:
        return 1;
      case TaskPriority.MEDIUM:
        return 2;
      case TaskPriority.HIGH:
        return 3;
      case TaskPriority.CRITICAL:
        return 4;
    }
  }

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase() || e.displayName.toUpperCase() == value.toUpperCase(),
      orElse: () => TaskPriority.MEDIUM,
    );
  }
}

enum TaskStatus {
  PENDING,
  IN_PROGRESS,
  COMPLETED;

  String get displayName {
    switch (this) {
      case TaskStatus.PENDING:
        return 'Pending';
      case TaskStatus.IN_PROGRESS:
        return 'In Progress';
      case TaskStatus.COMPLETED:
        return 'Completed';
    }
  }

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase() || e.displayName.toUpperCase() == value.toUpperCase(),
      orElse: () => TaskStatus.PENDING,
    );
  }
}

enum TaskReminder {
  NONE,
  AT_DEADLINE,
  MINUTES_15,
  HOURS_1,
  HOURS_2,
  DAYS_1,
  DAYS_2;

  String get displayName {
    switch (this) {
      case TaskReminder.NONE:
        return 'No Reminder';
      case TaskReminder.AT_DEADLINE:
        return 'At Deadline';
      case TaskReminder.MINUTES_15:
        return '15 Minutes Before';
      case TaskReminder.HOURS_1:
        return '1 Hour Before';
      case TaskReminder.HOURS_2:
        return '2 Hours Before';
      case TaskReminder.DAYS_1:
        return '1 Day Before';
      case TaskReminder.DAYS_2:
        return '2 Days Before';
    }
  }

  Duration? get offset {
    switch (this) {
      case TaskReminder.NONE:
        return null;
      case TaskReminder.AT_DEADLINE:
        return Duration.zero;
      case TaskReminder.MINUTES_15:
        return const Duration(minutes: 15);
      case TaskReminder.HOURS_1:
        return const Duration(hours: 1);
      case TaskReminder.HOURS_2:
        return const Duration(hours: 2);
      case TaskReminder.DAYS_1:
        return const Duration(days: 1);
      case TaskReminder.DAYS_2:
        return const Duration(days: 2);
    }
  }

  static TaskReminder fromString(String value) {
    return TaskReminder.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase() || e.displayName.toUpperCase() == value.toUpperCase(),
      orElse: () => TaskReminder.DAYS_1,
    );
  }
}

enum TaskUrgency {
  NORMAL,
  WARNING,
  URGENT,
  OVERDUE;

  String get displayName {
    switch (this) {
      case TaskUrgency.NORMAL:
        return 'Normal';
      case TaskUrgency.WARNING:
        return 'Warning';
      case TaskUrgency.URGENT:
        return 'Urgent';
      case TaskUrgency.OVERDUE:
        return 'Overdue';
    }
  }

  Color get color {
    switch (this) {
      case TaskUrgency.NORMAL:
        return Colors.green;
      case TaskUrgency.WARNING:
        return Colors.amber;
      case TaskUrgency.URGENT:
        return Colors.orange;
      case TaskUrgency.OVERDUE:
        return Colors.red;
    }
  }

  static TaskUrgency calculate(DateTime dueDate, DateTime now, {TaskStatus? status}) {
    if (status == TaskStatus.COMPLETED) {
      return TaskUrgency.NORMAL;
    }
    if (dueDate.isBefore(now)) {
      return TaskUrgency.OVERDUE;
    }

    final diff = dueDate.difference(now);
    final days = diff.inDays;
    
    if (diff.inHours < 72) {
      return TaskUrgency.URGENT;
    } else if (days < 7) {
      return TaskUrgency.WARNING;
    } else {
      return TaskUrgency.NORMAL;
    }
  }
}
