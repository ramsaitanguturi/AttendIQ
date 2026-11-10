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
  /// Lower bound of the collision-resistant 32-bit Android notification ID
  /// namespace reserved for persisted [NotificationItem] records.
  ///
  /// Kept strictly above [TaskNotificationScheduler] IDs (`800000 + taskId`)
  /// and strictly below signed 32-bit `INT_MAX` (`0x7FFFFFFF`).
  static const int minPersistedAndroidId = 100000000;

  /// Upper bound of the collision-resistant persisted Android notification ID
  /// namespace (`2,099,999,999 < 2,147,483,647 = 0x7FFFFFFF`).
  static const int maxPersistedAndroidId = 2099999999;

  /// Total capacity of the persisted Android notification ID namespace.
  static const int persistedAndroidIdSpan =
      maxPersistedAndroidId - minPersistedAndroidId + 1;

  /// Minimum signed 32-bit integer accepted by `flutter_local_notifications`.
  static const int minAndroidInt32 = -0x80000000;

  /// Maximum signed 32-bit integer accepted by `flutter_local_notifications`.
  static const int maxAndroidInt32 = 0x7FFFFFFF;

  int id = 0;

  /// Stable 32-bit Android notification ID persisted alongside [id].
  ///
  /// Separated from Isar's 64-bit primary key [id] so database primary keys
  /// cannot overflow Android's 32-bit notification ID space or collide with
  /// unpersisted task reminders (`800000 + taskId`).
  @Index()
  int? androidNotificationId;

  late String title;
  late String body;

  @Index()
  late String type;

  late DateTime scheduledTime;

  String? relatedId;

  bool isRead = false;

  /// Returns whether [value] fits inside Android's signed 32-bit integer range.
  static bool isValidAndroidInt32(int value) {
    return value >= minAndroidInt32 && value <= maxAndroidInt32;
  }

  /// Returns whether [value] belongs to the persisted notification Android ID
  /// namespace `[minPersistedAndroidId, maxPersistedAndroidId]`.
  static bool isValidPersistedAndroidId(int value) {
    return value >= minPersistedAndroidId && value <= maxPersistedAndroidId;
  }

  /// Deterministically maps any database primary key [dbId] into the positive,
  /// 32-bit, collision-resistant Android ID range
  /// `[minPersistedAndroidId, maxPersistedAndroidId]`.
  static int deriveAndroidNotificationId(int dbId) {
    if (dbId >= 1) {
      final offset = (dbId - 1) % persistedAndroidIdSpan;
      return minPersistedAndroidId + offset;
    }
    final safeAbs = dbId == -0x8000000000000000 ? 0 : dbId.abs();
    return minPersistedAndroidId + (safeAbs % persistedAndroidIdSpan);
  }

  /// Advances [currentId] by one slot inside
  /// `[minPersistedAndroidId, maxPersistedAndroidId]`, wrapping safely without
  /// integer overflow.
  static int nextPersistedAndroidId(int currentId) {
    if (!isValidPersistedAndroidId(currentId)) {
      return minPersistedAndroidId;
    }
    return currentId >= maxPersistedAndroidId
        ? minPersistedAndroidId
        : currentId + 1;
  }

  /// Ensures [rawId] fits within Android's 32-bit signed integer limits without
  /// overflow, preserving in-range IDs (such as `800000 + taskId` or `0` for
  /// legacy cleanup) and folding out-of-range 64-bit values deterministically.
  static int normalizeAndroidId(int rawId) {
    if (isValidAndroidInt32(rawId)) {
      return rawId;
    }
    return deriveAndroidNotificationId(rawId);
  }

  /// Effective 32-bit Android notification ID to pass to the platform plugin.
  ///
  /// Uses the persisted [androidNotificationId] when available, falls back to
  /// [normalizeAndroidId] for in-memory callers (such as
  /// `TaskNotificationScheduler` setting `id = 800000 + taskId`), and computes
  /// a deterministic non-zero 32-bit fallback if neither is set.
  @ignore
  int get effectiveAndroidNotificationId {
    final persistedId = androidNotificationId;
    if (persistedId != null && persistedId > 0) {
      return normalizeAndroidId(persistedId);
    }
    if (id > 0) {
      return normalizeAndroidId(id);
    }
    return _deriveUnsavedAndroidId();
  }

  int _deriveUnsavedAndroidId() {
    final seed =
        '$type|${relatedId ?? ''}|${scheduledTime.toUtc().microsecondsSinceEpoch}|$title';
    var hash = 0x811c9dc5;
    for (final unit in seed.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return minPersistedAndroidId + (hash % persistedAndroidIdSpan);
  }
}
