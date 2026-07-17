import 'package:isar/isar.dart';

part 'notification_item.g.dart';

enum NotificationType {
  CLASS_REMINDER,
  ATTENDANCE_WARNING,
  LOW_ATTENDANCE_ALERT,
  ASSIGNMENT_REMINDER,
  EXAM_REMINDER,
  WEEKLY_REPORT;

  String toShortString() => name;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.CLASS_REMINDER,
    );
  }
}

@collection
class NotificationItem {
  int id = 0;

  late String title;
  late String body;

  @Index()
  late String type;

  late DateTime scheduledTime;

  String? relatedId;

  late bool isRead;
}
