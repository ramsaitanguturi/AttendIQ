import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:attend_iq/core/notifications/models/notification_item.dart';
import 'package:attend_iq/core/notifications/services/notification_service.dart';
import '../domain/entities/academic_task.dart';
import '../domain/entities/task_enums.dart';

class TaskNotificationScheduler {
  final NotificationService _notificationService;

  TaskNotificationScheduler(this._notificationService);

  int _getNotificationId(int taskId) {
    return 800000 + taskId;
  }

  Future<void> scheduleTaskNotification(AcademicTask task, {String? subjectName}) async {
    if (task.id == null) return;
    final notifId = _getNotificationId(task.id!);

    // Always cancel existing notification first
    try {
      await _notificationService.cancelNotification(notifId);
    } catch (e) {
      debugPrint('Error cancelling previous task notification: $e');
    }

    if (task.status == TaskStatus.COMPLETED || task.isDeleted || task.reminder == TaskReminder.NONE) {
      return;
    }

    final offset = task.reminder.offset;
    if (offset == null) return;

    final scheduledTime = task.dueDate.subtract(offset);
    final now = DateTime.now();

    if (scheduledTime.isBefore(now)) {
      debugPrint('Task reminder scheduled time $scheduledTime is in the past. Skipping notification.');
      return;
    }

    // Build user friendly notification message
    String bodyText;
    final prefix = subjectName != null && subjectName.isNotEmpty ? '$subjectName: ' : '';

    switch (task.reminder) {
      case TaskReminder.AT_DEADLINE:
        bodyText = '$prefix${task.title} is due now!';
        break;
      case TaskReminder.MINUTES_15:
        bodyText = '$prefix${task.title} due in 15 minutes';
        break;
      case TaskReminder.HOURS_1:
        bodyText = '$prefix${task.title} due in 1 hour';
        break;
      case TaskReminder.HOURS_2:
        bodyText = '$prefix${task.title} due in 2 hours';
        break;
      case TaskReminder.DAYS_1:
        bodyText = '$prefix${task.title} deadline tomorrow';
        break;
      case TaskReminder.DAYS_2:
        bodyText = '$prefix${task.title} due in 2 days';
        break;
      default:
        bodyText = '$prefix${task.title} deadline on ${DateFormat('MMM d, jm').format(task.dueDate)}';
    }

    final item = NotificationItem()
      ..id = notifId
      ..title = '${task.taskType.displayName} Reminder'
      ..body = bodyText
      ..type = NotificationType.ASSIGNMENT_REMINDER.name
      ..scheduledTime = scheduledTime
      ..relatedId = task.id.toString()
      ..isRead = false;

    try {
      await _notificationService.scheduleNotification(item);
      debugPrint('Successfully scheduled task notification ID $notifId for $scheduledTime');
    } catch (e) {
      debugPrint('Failed to schedule task notification: $e');
    }
  }

  Future<void> cancelTaskNotification(int taskId) async {
    final notifId = _getNotificationId(taskId);
    try {
      await _notificationService.cancelNotification(notifId);
    } catch (e) {
      debugPrint('Error cancelling task notification: $e');
    }
  }
}
