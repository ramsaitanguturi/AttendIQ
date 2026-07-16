import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../constants/app_constants.dart';
import '../../features/auth/data/models/user_local.dart';
import '../../features/auth/data/models/semester_local.dart';
import '../../features/subject/data/models/subject_local.dart';
import '../../features/timetable/data/models/timetable_template_local.dart';
import '../event_generator/data/models/event_local.dart';
import '../../features/attendance/data/models/attendance_record_local.dart';

part 'isar_provider.g.dart';

@riverpod
Future<Isar> isar(IsarRef ref) async {
  // In later phases, we will use path_provider to resolve the directory on mobile devices.
  // Register schemas (UserLocal, SemesterLocal) here in Phase 1
  return Isar.open(
    schemas: const [
      UserLocalSchema,
      SemesterLocalSchema,
      SubjectLocalSchema,
      TimetableTemplateLocalSchema,
      EventLocalSchema,
      AttendanceRecordLocalSchema,
    ],
    name: AppConstants.isarDbName,
    directory: '.',
  );
}

