import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../../database/isar_provider.dart';
import '../services/notification_service.dart';
import '../scheduler/notification_scheduler.dart';
import '../../../features/timetable/data/models/timetable_template_local.dart';
import '../../event_generator/data/models/event_local.dart';
import '../../../features/attendance/data/models/attendance_record_local.dart';

import '../scheduler/notification_database.dart';

part 'notification_providers.g.dart';

@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  return LocalNotificationServiceImpl();
}

@riverpod
NotificationScheduler notificationScheduler(NotificationSchedulerRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  final service = ref.watch(notificationServiceProvider);
  final db = IsarNotificationDatabaseImpl(isar);
  return NotificationScheduler(db, service);
}

@riverpod
Future<void> notificationInitializer(NotificationInitializerRef ref) async {
  final isar = ref.watch(isarProvider).requireValue;
  final service = ref.watch(notificationServiceProvider);
  final scheduler = ref.watch(notificationSchedulerProvider);

  // 1. Initialize notification service and request permissions
  await service.initialize();
  await service.requestPermissions();

  // 2. Set up database observers to auto-reschedule on edits or sync writes
  final timetableSub = isar.timetableTemplateLocals.where().watchLazy().listen((_) {
    scheduler.rescheduleAll();
  });
  ref.onDispose(() => timetableSub.cancel());

  final eventSub = isar.eventLocals.where().watchLazy().listen((_) {
    scheduler.rescheduleAll();
  });
  ref.onDispose(() => eventSub.cancel());

  final recordSub = isar.attendanceRecordLocals.where().watchLazy().listen((_) {
    scheduler.rescheduleAll();
  });
  ref.onDispose(() => recordSub.cancel());

  // 3. Initial scheduling run
  await scheduler.rescheduleAll();
}
