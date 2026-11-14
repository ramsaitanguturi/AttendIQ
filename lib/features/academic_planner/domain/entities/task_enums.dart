import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

enum TaskType {
  midSem,
  endSem,
  assignment,
  project,
  labSubmission,
  quiz,
  presentation,
  other;

  String toShortString() {
    switch (this) {
      case TaskType.midSem:
        return 'MID_SEM';
      case TaskType.endSem:
        return 'END_SEM';
      case TaskType.assignment:
        return 'ASSIGNMENT';
      case TaskType.project:
        return 'PROJECT';
      case TaskType.labSubmission:
        return 'LAB_SUBMISSION';
      case TaskType.quiz:
        return 'QUIZ';
      case TaskType.presentation:
        return 'PRESENTATION';
      case TaskType.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case TaskType.midSem:
        return 'Mid Sem';
      case TaskType.endSem:
        return 'End Sem';
      case TaskType.assignment:
        return 'Assignment';
      case TaskType.project:
        return 'Project';
      case TaskType.labSubmission:
        return 'Lab Submission';
      case TaskType.quiz:
        return 'Quiz';
      case TaskType.presentation:
        return 'Presentation';
      case TaskType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskType.midSem:
      case TaskType.endSem:
        return Icons.menu_book;
      case TaskType.assignment:
        return Icons.assignment;
      case TaskType.project:
        return Icons.work_outline;
      case TaskType.labSubmission:
        return Icons.science;
      case TaskType.quiz:
        return Icons.quiz;
      case TaskType.presentation:
        return Icons.co_present;
      case TaskType.other:
        return Icons.task_alt;
    }
  }

  static TaskType fromString(String value) {
    final norm = value.trim().toUpperCase();
    return TaskType.values.firstWhere(
      (e) =>
          e.toShortString() == norm ||
          e.name.toUpperCase() == norm ||
          e.displayName.toUpperCase() == norm,
      orElse: () => TaskType.other,
    );
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  critical;

  String toShortString() {
    switch (this) {
      case TaskPriority.low:
        return 'LOW';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.high:
        return 'HIGH';
      case TaskPriority.critical:
        return 'CRITICAL';
    }
  }

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
    }
  }

  Color get color => getAdaptiveColor(true);

  Color getAdaptiveColor(bool isDark) {
    if (isDark) {
      switch (this) {
        case TaskPriority.low:
          return AppColors.gray400;
        case TaskPriority.medium:
          return AppColors.gray300;
        case TaskPriority.high:
          return AppColors.gray200;
        case TaskPriority.critical:
          return AppColors.gray100;
      }
    } else {
      switch (this) {
        case TaskPriority.low:
          return AppColors.gray600;
        case TaskPriority.medium:
          return AppColors.gray700;
        case TaskPriority.high:
          return AppColors.gray800;
        case TaskPriority.critical:
          return AppColors.gray900;
      }
    }
  }

  int get level {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
      case TaskPriority.critical:
        return 4;
    }
  }

  static TaskPriority fromString(String value) {
    final norm = value.trim().toUpperCase();
    return TaskPriority.values.firstWhere(
      (e) =>
          e.toShortString() == norm ||
          e.name.toUpperCase() == norm ||
          e.displayName.toUpperCase() == norm,
      orElse: () => TaskPriority.medium,
    );
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed;

  String toShortString() {
    switch (this) {
      case TaskStatus.pending:
        return 'PENDING';
      case TaskStatus.inProgress:
        return 'IN_PROGRESS';
      case TaskStatus.completed:
        return 'COMPLETED';
    }
  }

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }

  static TaskStatus fromString(String value) {
    final norm = value.trim().toUpperCase();
    return TaskStatus.values.firstWhere(
      (e) =>
          e.toShortString() == norm ||
          e.name.toUpperCase() == norm ||
          e.displayName.toUpperCase() == norm,
      orElse: () => TaskStatus.pending,
    );
  }
}

enum TaskReminder {
  none,
  atDeadline,
  minutes15,
  hours1,
  hours2,
  days1,
  days2;

  String toShortString() {
    switch (this) {
      case TaskReminder.none:
        return 'NONE';
      case TaskReminder.atDeadline:
        return 'AT_DEADLINE';
      case TaskReminder.minutes15:
        return 'MINUTES_15';
      case TaskReminder.hours1:
        return 'HOURS_1';
      case TaskReminder.hours2:
        return 'HOURS_2';
      case TaskReminder.days1:
        return 'DAYS_1';
      case TaskReminder.days2:
        return 'DAYS_2';
    }
  }

  String get displayName {
    switch (this) {
      case TaskReminder.none:
        return 'No Reminder';
      case TaskReminder.atDeadline:
        return 'At Deadline';
      case TaskReminder.minutes15:
        return '15 Minutes Before';
      case TaskReminder.hours1:
        return '1 Hour Before';
      case TaskReminder.hours2:
        return '2 Hours Before';
      case TaskReminder.days1:
        return '1 Day Before';
      case TaskReminder.days2:
        return '2 Days Before';
    }
  }

  Duration? get offset {
    switch (this) {
      case TaskReminder.none:
        return null;
      case TaskReminder.atDeadline:
        return Duration.zero;
      case TaskReminder.minutes15:
        return const Duration(minutes: 15);
      case TaskReminder.hours1:
        return const Duration(hours: 1);
      case TaskReminder.hours2:
        return const Duration(hours: 2);
      case TaskReminder.days1:
        return const Duration(days: 1);
      case TaskReminder.days2:
        return const Duration(days: 2);
    }
  }

  static TaskReminder fromString(String value) {
    final norm = value.trim().toUpperCase();
    return TaskReminder.values.firstWhere(
      (e) =>
          e.toShortString() == norm ||
          e.name.toUpperCase() == norm ||
          e.displayName.toUpperCase() == norm,
      orElse: () => TaskReminder.days1,
    );
  }
}

enum TaskUrgency {
  normal,
  warning,
  urgent,
  overdue;

  String get displayName {
    switch (this) {
      case TaskUrgency.normal:
        return 'Normal';
      case TaskUrgency.warning:
        return 'Warning';
      case TaskUrgency.urgent:
        return 'Urgent';
      case TaskUrgency.overdue:
        return 'Overdue';
    }
  }

  Color get color => getAdaptiveColor(true);

  Color getAdaptiveColor(bool isDark) {
    if (isDark) {
      switch (this) {
        case TaskUrgency.normal:
          return AppColors.gray400;
        case TaskUrgency.warning:
          return AppColors.gray300;
        case TaskUrgency.urgent:
          return AppColors.gray200;
        case TaskUrgency.overdue:
          return AppColors.gray100;
      }
    } else {
      switch (this) {
        case TaskUrgency.normal:
          return AppColors.gray600;
        case TaskUrgency.warning:
          return AppColors.gray700;
        case TaskUrgency.urgent:
          return AppColors.gray800;
        case TaskUrgency.overdue:
          return AppColors.gray900;
      }
    }
  }

  static TaskUrgency calculate(
    DateTime dueDate,
    DateTime now, {
    TaskStatus? status,
  }) {
    if (status == TaskStatus.completed) {
      return TaskUrgency.normal;
    }
    if (dueDate.isBefore(now)) {
      return TaskUrgency.overdue;
    }

    final diff = dueDate.difference(now);
    final days = diff.inDays;

    if (diff.inHours < 72) {
      return TaskUrgency.urgent;
    } else if (days < 7) {
      return TaskUrgency.warning;
    } else {
      return TaskUrgency.normal;
    }
  }
}
