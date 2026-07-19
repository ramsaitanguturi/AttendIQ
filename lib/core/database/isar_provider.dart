import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import '../../features/semester/data/models/semester_local.dart';
import '../../features/subject/data/models/subject_local.dart';
import '../../features/timetable/data/models/timetable_template_local.dart';
import '../../features/timetable/data/models/weekly_schedule_rule_local.dart';
import '../../features/timetable/data/models/schedule_exception_local.dart';
import '../event_generator/data/models/event_local.dart';
import '../../features/attendance/data/models/attendance_record_local.dart';
import '../notifications/models/notification_item.dart';
import '../../features/settings/data/models/user_preferences_local.dart';

import '../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../features/timetable/data/models/academic_event_local.dart';
import '../../features/academic_planner/data/models/academic_task_local.dart';

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
  final isarInstance = await Isar.open(
    schemas: const [
      SemesterLocalSchema,
      SubjectLocalSchema,
      TimetableTemplateLocalSchema,
      WeeklyScheduleRuleLocalSchema,
      ScheduleExceptionLocalSchema,
      DailyScheduleOccurrenceLocalSchema,
      AcademicEventLocalSchema,
      AcademicTaskLocalSchema,
      EventLocalSchema,
      AttendanceRecordLocalSchema,
      NotificationItemSchema,
      UserPreferencesLocalSchema,
    ],
    name: AppConstants.isarDbName,
    directory: dir,
  );

  await _migrateLegacyTimetableTemplates(isarInstance);

  return isarInstance;
}

Future<void> _migrateLegacyTimetableTemplates(Isar isar) async {
  try {
    final templates = await isar.timetableTemplateLocals.where().findAll();
    if (templates.isEmpty) return;

    final existingRules = await isar.weeklyScheduleRuleLocals.where().findAll();

    await isar.writeAsync((isar) {
      for (final template in templates) {
        if (template.isDeleted) continue;
        final alreadyExists = existingRules.any((r) =>
            r.subjectId == template.subjectId &&
            r.dayOfWeek == template.weekday &&
            r.startTime == template.startTime &&
            r.endTime == template.endTime &&
            !r.isDeleted);
        if (!alreadyExists) {
          final rule = WeeklyScheduleRuleLocal()
            ..id = isar.weeklyScheduleRuleLocals.autoIncrement()
            ..serverId = template.serverId
            ..subjectId = template.subjectId
            ..dayOfWeek = template.weekday
            ..startTime = template.startTime
            ..endTime = template.endTime
            ..room = template.room
            ..faculty = template.faculty
            ..isActive = true
            ..createdAt = template.createdAt
            ..updatedAt = DateTime.now().toUtc();
          isar.weeklyScheduleRuleLocals.put(rule);
        }
      }
    });
  } catch (e) {
    debugPrint('Error migrating legacy timetable templates: $e');
  }
}

