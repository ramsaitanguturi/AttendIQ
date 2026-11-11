import 'backup_validator.dart';

export 'backup_validator.dart' show ImportStrategy;

class BackupMetadata {
  final String appVersion;
  final int backupVersion;
  final DateTime createdAt;
  final String devicePlatform;

  BackupMetadata({
    required this.appVersion,
    this.backupVersion = 1,
    required this.createdAt,
    required this.devicePlatform,
  });

  factory BackupMetadata._fromValidated(ValidatedBackupMetadata validated) {
    return BackupMetadata(
      appVersion: validated.appVersion,
      backupVersion: validated.backupVersion,
      createdAt: validated.createdAt,
      devicePlatform: validated.devicePlatform,
    );
  }

  Map<String, dynamic> toJson() => {
        'appVersion': appVersion,
        'backupVersion': backupVersion,
        'createdAt': createdAt.toIso8601String(),
        'devicePlatform': devicePlatform,
      };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata._fromValidated(
      BackupValidator.validateMetadata(json),
    );
  }
}

class BackupData {
  final BackupMetadata metadata;
  final List<Map<String, dynamic>> userPreferences;
  final List<Map<String, dynamic>> semesters;
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> attendance;
  final List<Map<String, dynamic>> timetable;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> notifications;
  final List<Map<String, dynamic>> scheduleExceptions;
  final List<Map<String, dynamic>> weeklyRules;
  final List<Map<String, dynamic>> occurrences;
  final List<Map<String, dynamic>> academicEvents;
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> migrationAudits;
  final Map<String, dynamic> reportsMetadata;

  BackupData({
    required this.metadata,
    required this.userPreferences,
    required this.semesters,
    required this.subjects,
    required this.attendance,
    required this.timetable,
    required this.events,
    required this.notifications,
    this.scheduleExceptions = const [],
    this.weeklyRules = const [],
    this.occurrences = const [],
    this.academicEvents = const [],
    this.tasks = const [],
    this.migrationAudits = const [],
    this.reportsMetadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'metadata': metadata.toJson(),
        'userPreferences': userPreferences,
        'semesters': semesters,
        'subjects': subjects,
        'attendance': attendance,
        'timetable': timetable,
        'events': events,
        'notifications': notifications,
        'scheduleExceptions': scheduleExceptions,
        'weeklyRules': weeklyRules,
        'occurrences': occurrences,
        'academicEvents': academicEvents,
        'tasks': tasks,
        'migrationAudits': migrationAudits,
        'reportsMetadata': reportsMetadata,
      };

  /// Deserializes and validates a backup JSON map through the complete
  /// [BackupValidator] pipeline (envelope, version, collection shapes,
  /// row-level schema/enum/date/time rules across all 13 collections, and
  /// strategy-aware relationship validation, defaulting to
  /// [ImportStrategy.replace]).
  factory BackupData.fromJson(
    Map<String, dynamic> json, {
    ImportStrategy? strategy = ImportStrategy.replace,
  }) {
    final validated = BackupValidator.validateMap(json, strategy: strategy);
    return BackupData(
      metadata: BackupMetadata._fromValidated(validated.metadata),
      userPreferences: validated.userPreferences,
      semesters: validated.semesters,
      subjects: validated.subjects,
      attendance: validated.attendance,
      timetable: validated.timetable,
      events: validated.events,
      notifications: validated.notifications,
      scheduleExceptions: validated.scheduleExceptions,
      weeklyRules: validated.weeklyRules,
      occurrences: validated.occurrences,
      academicEvents: validated.academicEvents,
      tasks: validated.tasks,
      migrationAudits: validated.migrationAudits,
      reportsMetadata: validated.reportsMetadata,
    );
  }
}
