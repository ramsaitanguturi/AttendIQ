import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import '../../features/auth/data/models/user_local.dart';
import '../../features/auth/data/models/semester_local.dart';
import '../../features/subject/data/models/subject_local.dart';
import '../../features/timetable/data/models/timetable_template_local.dart';
import '../event_generator/data/models/event_local.dart';
import '../../features/attendance/data/models/attendance_record_local.dart';
import '../sync/models/sync_operation.dart';
import '../notifications/models/notification_item.dart';
import '../../features/settings/data/models/user_preferences_local.dart';

part 'isar_provider.g.dart';

@riverpod
Future<Isar> isar(IsarRef ref) async {
  String dir = '.';
  if (!kIsWeb) {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      dir = appDir.path;
    } catch (e) {
      debugPrint('Failed to get application documents directory, falling back to local: $e');
    }
  }
  return Isar.open(
    schemas: const [
      UserLocalSchema,
      SemesterLocalSchema,
      SubjectLocalSchema,
      TimetableTemplateLocalSchema,
      EventLocalSchema,
      AttendanceRecordLocalSchema,
      SyncOperationSchema,
      FailedSyncOperationSchema,
      NotificationItemSchema,
      UserPreferencesLocalSchema,
    ],
    name: AppConstants.isarDbName,
    directory: dir,
  );
}

