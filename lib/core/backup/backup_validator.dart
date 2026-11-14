import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../features/academic_planner/domain/entities/task_enums.dart';
import '../../features/attendance/domain/entities/attendance_record.dart';
import '../../features/semester/data/models/semester_local.dart';
import '../../features/subject/domain/entities/subject.dart';
import '../../features/timetable/domain/entities/academic_event.dart';
import '../../features/timetable/domain/entities/daily_schedule_occurrence.dart';
import '../../features/timetable/domain/entities/schedule_exception.dart';
import '../database/migration_audit_record_local.dart';
import '../database/timetable_migration.dart';
import '../event_generator/domain/entities/event.dart';
import '../notifications/models/notification_item.dart';
import 'backup_json_reader.dart';

enum ImportStrategy { replace, merge }

/// Validated metadata container produced only by [BackupValidator].
class ValidatedBackupMetadata {
  final String appVersion;
  final int backupVersion;
  final DateTime createdAt;
  final String devicePlatform;

  const ValidatedBackupMetadata._({
    required this.appVersion,
    required this.backupVersion,
    required this.createdAt,
    required this.devicePlatform,
  });
}

/// Validated backup collection bundle produced only by [BackupValidator].
class ValidatedBackupPayload {
  final ValidatedBackupMetadata metadata;
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

  const ValidatedBackupPayload._({
    required this.metadata,
    required this.userPreferences,
    required this.semesters,
    required this.subjects,
    required this.attendance,
    required this.timetable,
    required this.events,
    required this.notifications,
    required this.scheduleExceptions,
    required this.weeklyRules,
    required this.occurrences,
    required this.academicEvents,
    required this.tasks,
    required this.migrationAudits,
    required this.reportsMetadata,
  });
}

/// Maximum accepted raw backup payload size (20 MiB).
///
/// Accommodates multi-year student datasets (~50,000+ indented JSON rows)
/// while guarding mobile devices against out-of-memory crashes from arbitrary
/// oversized files.
const int maxBackupPayloadBytes = 20 * 1024 * 1024;

const int minSupportedBackupVersion = 1;
const int maxSupportedBackupVersion = 2;

const List<String> requiredCoreBackupKeys = <String>[
  'userPreferences',
  'semesters',
  'subjects',
  'attendance',
  'timetable',
  'events',
  'notifications',
];

const List<String> optionalV2BackupKeys = <String>[
  'scheduleExceptions',
  'weeklyRules',
  'occurrences',
  'academicEvents',
  'tasks',
  'migrationAudits',
];

const List<String> allBackupCollectionKeys = <String>[
  ...requiredCoreBackupKeys,
  ...optionalV2BackupKeys,
];

/// Validates and parses backup JSON payloads before any Isar write transaction.
class BackupValidator {
  BackupValidator._();

  static const String skippedMergeAuditKind = 'backupMergeSkippedRecord';

  static final RegExp _strictHhMmPattern = RegExp(r'^(\d{2}):(\d{2})$');

  static const Set<String> _validThemeModes = <String>{
    'light',
    'dark',
    'system',
  };

  static final Set<String> _validSubjectTypes =
      SubjectType.values.map((e) => e.toShortString().toUpperCase()).toSet();

  static final Set<String> _validAttendanceStatuses = AttendanceStatus.values
      .map((e) => e.toShortString().toUpperCase())
      .toSet();

  static final Set<String> _validOccurrenceTypes =
      OccurrenceType.values.map((e) => e.toShortString().toUpperCase()).toSet();

  static final Set<String> _validOccurrenceStatuses = OccurrenceStatus.values
      .map((e) => e.toShortString().toUpperCase())
      .toSet();

  static final Set<String> _validOccurrenceCreatedFrom = OccurrenceCreatedFrom
      .values
      .map((e) => e.toShortString().toUpperCase())
      .toSet();

  static final Set<String> _validScheduleExceptionTypes = ScheduleExceptionType
      .values
      .map((e) => e.toShortString().toUpperCase())
      .toSet();

  static final Set<String> _validAcademicEventTypes = AcademicEventType.values
      .map((e) => e.toShortString().toUpperCase())
      .toSet();

  static final Set<String> _validTaskTypes =
      TaskType.values.map((e) => e.toShortString().toUpperCase()).toSet();

  static final Set<String> _validTaskPriorities =
      TaskPriority.values.map((e) => e.toShortString().toUpperCase()).toSet();

  static final Set<String> _validTaskStatuses =
      TaskStatus.values.map((e) => e.toShortString().toUpperCase()).toSet();

  static final Set<String> _validTaskReminders =
      TaskReminder.values.map((e) => e.toShortString().toUpperCase()).toSet();

  static final Set<String> _validNotificationTypes = NotificationType.values
      .map((e) => e.toShortString().toUpperCase())
      .toSet();

  static final Set<String> _validLegacyEventTypes = <String>{
    ...EventType.values.map((e) => e.toShortString().toUpperCase()),
    ...OccurrenceType.values.map((e) => e.toShortString().toUpperCase()),
  };

  static final Set<String> _validLegacyEventStatuses = <String>{
    ...EventStatus.values.map((e) => e.toShortString().toUpperCase()),
    'UPCOMING',
    'EXTRA_PRESENT',
    'EXTRA_ABSENT',
  };

  static final Set<String> _validMigrationAuditKinds = <String>{
    ...MigrationAuditKind.values.map((e) => e.name),
    skippedMergeAuditKind,
  };

  /// Full pre-transaction validation pipeline for raw JSON text:
  /// 1. Decode raw JSON safely (empty / oversized / syntax / root type).
  /// 2. Validate backup envelope and version (`1` or `2`).
  /// 3. Validate metadata and collection structure.
  /// 4. Validate every row's field types and required/optional fields.
  /// 5. Validate entity-specific date, time, enum, range, and consistency rules.
  /// 6. Apply strategy-aware relationship validation (defaults to `replace`).
  static ValidatedBackupPayload decodeAndValidate(
    String rawJson, {
    ImportStrategy? strategy = ImportStrategy.replace,
  }) {
    final rootMap = decodeRawJson(rawJson);
    return validateMap(rootMap, strategy: strategy);
  }

  /// Validates an already-decoded backup JSON map through Stages 2–6.
  static ValidatedBackupPayload validateMap(
    Map<String, dynamic> rootMap, {
    ImportStrategy? strategy = ImportStrategy.replace,
  }) {
    final payload = validateStructure(rootMap);
    validateAllRows(payload);
    validateRelationshipsForStrategy(payload, strategy: strategy);
    return payload;
  }

  /// Validates that [rawJson] is non-empty and within [maxBackupPayloadBytes].
  static void validatePayloadSize(String rawJson) {
    if (rawJson.trim().isEmpty) {
      throw const FormatException('Backup JSON cannot be empty.');
    }

    if (rawJson.length > maxBackupPayloadBytes ||
        (rawJson.length * 3 > maxBackupPayloadBytes &&
            utf8.encode(rawJson).length > maxBackupPayloadBytes)) {
      throw const FormatException(
        'Backup payload exceeds maximum supported size of 20 MB.',
      );
    }
  }

  /// Stage 1: Decode raw JSON string safely with size and syntax checks.
  static Map<String, dynamic> decodeRawJson(String rawJson) {
    validatePayloadSize(rawJson);

    final dynamic decoded;
    try {
      decoded = jsonDecode(rawJson);
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }

    if (decoded is! Map) {
      throw const FormatException(
        'Invalid backup payload layout: root must be a JSON object.',
      );
    }

    return BackupJsonReader.asJsonObject(decoded, 'root');
  }

  /// Validates and parses a backup `metadata` object directly.
  static ValidatedBackupMetadata validateMetadata(
    Map<String, dynamic> json,
  ) {
    final backupVersion = BackupJsonReader.requireIntField(
      json,
      'backupVersion',
      'metadata',
      min: minSupportedBackupVersion,
    );
    if (backupVersion > maxSupportedBackupVersion) {
      throw FormatException(
        'Unsupported backup version $backupVersion. Current maximum supported version is $maxSupportedBackupVersion.',
      );
    }
    final appVersion = BackupJsonReader.optionalNonNullStringField(
          json,
          'appVersion',
          'metadata',
          allowEmpty: false,
        ) ??
        '1.0.0';
    final createdAt = BackupJsonReader.optionalNonNullIsoDateTimeField(
          json,
          'createdAt',
          'metadata',
        ) ??
        DateTime.now().toUtc();
    final devicePlatform = BackupJsonReader.optionalNonNullStringField(
          json,
          'devicePlatform',
          'metadata',
          allowEmpty: false,
        ) ??
        (kIsWeb ? 'web' : Platform.operatingSystem);

    return ValidatedBackupMetadata._(
      appVersion: appVersion,
      backupVersion: backupVersion,
      createdAt: createdAt,
      devicePlatform: devicePlatform,
    );
  }

  /// Stage 2: Validate the backup metadata envelope and schema version.
  static ValidatedBackupMetadata validateEnvelopeAndVersion(
    Map<String, dynamic> rootMap,
  ) {
    if (!rootMap.containsKey('metadata') || rootMap['metadata'] == null) {
      throw const FormatException(
        'metadata: Missing required backup metadata object.',
      );
    }
    final metadataMap = BackupJsonReader.asJsonObject(
      rootMap['metadata'],
      'metadata',
    );
    return validateMetadata(metadataMap);
  }

  /// Stage 3: Validate metadata and collection array/object structure.
  static ValidatedBackupPayload validateStructure(
    Map<String, dynamic> rootMap,
  ) {
    final metadata = validateEnvelopeAndVersion(rootMap);
    return ValidatedBackupPayload._(
      metadata: metadata,
      userPreferences: BackupJsonReader.requireObjectListField(
        rootMap,
        'userPreferences',
        '',
      ),
      semesters: BackupJsonReader.requireObjectListField(
        rootMap,
        'semesters',
        '',
      ),
      subjects: BackupJsonReader.requireObjectListField(
        rootMap,
        'subjects',
        '',
      ),
      attendance: BackupJsonReader.requireObjectListField(
        rootMap,
        'attendance',
        '',
      ),
      timetable: BackupJsonReader.requireObjectListField(
        rootMap,
        'timetable',
        '',
      ),
      events: BackupJsonReader.requireObjectListField(
        rootMap,
        'events',
        '',
      ),
      notifications: BackupJsonReader.requireObjectListField(
        rootMap,
        'notifications',
        '',
      ),
      scheduleExceptions: BackupJsonReader.optionalObjectListField(
            rootMap,
            'scheduleExceptions',
            '',
          ) ??
          const <Map<String, dynamic>>[],
      weeklyRules: BackupJsonReader.optionalObjectListField(
            rootMap,
            'weeklyRules',
            '',
          ) ??
          const <Map<String, dynamic>>[],
      occurrences: BackupJsonReader.optionalObjectListField(
            rootMap,
            'occurrences',
            '',
          ) ??
          const <Map<String, dynamic>>[],
      academicEvents: BackupJsonReader.optionalObjectListField(
            rootMap,
            'academicEvents',
            '',
          ) ??
          const <Map<String, dynamic>>[],
      tasks: BackupJsonReader.optionalObjectListField(
            rootMap,
            'tasks',
            '',
          ) ??
          const <Map<String, dynamic>>[],
      migrationAudits: BackupJsonReader.optionalObjectListField(
            rootMap,
            'migrationAudits',
            '',
          ) ??
          const <Map<String, dynamic>>[],
      reportsMetadata: BackupJsonReader.optionalObjectField(
            rootMap,
            'reportsMetadata',
            '',
          ) ??
          const <String, dynamic>{},
    );
  }

  /// Stage 4 & 5: Validate every row's field types, required/optional fields,
  /// dates, strict `HH:mm` times, numeric bounds, enums, and consistency rules.
  static void validateAllRows(ValidatedBackupPayload data) {
    _validateUserPreferences(data.userPreferences);
    _validateSemesters(data.semesters);
    _validateSubjects(data.subjects);
    _validateTimetableTemplates(data.timetable);
    _validateLegacyEvents(data.events);
    _validateWeeklyRules(data.weeklyRules);
    _validateOccurrences(data.occurrences);
    _validateAttendance(data.attendance);
    _validateScheduleExceptions(data.scheduleExceptions);
    _validateAcademicEvents(data.academicEvents);
    _validateTasks(data.tasks);
    _validateNotifications(data.notifications);
    _validateMigrationAudits(data.migrationAudits);
  }

  static void _validateSyncMetadata(
    Map<String, dynamic> row,
    String path, {
    bool allowNullableServerId = true,
  }) {
    BackupJsonReader.optionalNonNullIntField(row, 'id', path, min: 0);
    if (allowNullableServerId) {
      BackupJsonReader.nullableStringField(row, 'serverId', path);
    }
    BackupJsonReader.optionalNonNullIsoDateTimeField(row, 'createdAt', path);
    BackupJsonReader.optionalNonNullIsoDateTimeField(row, 'updatedAt', path);
    BackupJsonReader.optionalNonNullBoolField(row, 'isDirty', path);
    BackupJsonReader.optionalNonNullBoolField(row, 'isDeleted', path);
  }

  static void _validateUserPreferences(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'userPreferences[$i]';
      BackupJsonReader.optionalNonNullIntField(row, 'id', path, min: 0);
      BackupJsonReader.nullableStringField(row, 'serverId', path);

      final themeMode = BackupJsonReader.optionalNonNullStringField(
        row,
        'themeMode',
        path,
        allowEmpty: false,
      );
      if (themeMode != null &&
          !_validThemeModes.contains(themeMode.trim().toLowerCase())) {
        throw FormatException(
          '$path.themeMode: Invalid themeMode "$themeMode". Expected one of ${_validThemeModes.join(', ')}.',
        );
      }

      BackupJsonReader.optionalNonNullDoubleField(
        row,
        'defaultAttendanceTarget',
        path,
        min: 0.0,
        max: 100.0,
      );
      BackupJsonReader.optionalNonNullIntField(
        row,
        'classReminderOffset',
        path,
        min: 0,
      );
      BackupJsonReader.optionalNonNullBoolField(
        row,
        'enableNotifications',
        path,
      );
      BackupJsonReader.optionalNonNullBoolField(
        row,
        'enableAttendanceWarnings',
        path,
      );
      BackupJsonReader.optionalNonNullBoolField(
        row,
        'weeklyReportEnabled',
        path,
      );
      BackupJsonReader.optionalNonNullBoolField(
        row,
        'enableAutoBackup',
        path,
      );
      BackupJsonReader.optionalNonNullIntField(
        row,
        'autoBackupDay',
        path,
        min: 1,
        max: 7,
      );
      BackupJsonReader.optionalNonNullIntField(
        row,
        'autoBackupHour',
        path,
        min: 0,
        max: 23,
      );
      BackupJsonReader.nullableIsoDateTimeField(row, 'lastSyncTime', path);
      BackupJsonReader.nullableIsoDateTimeField(row, 'lastBackupDate', path);
      BackupJsonReader.optionalNonNullIsoDateTimeField(row, 'updatedAt', path);
      BackupJsonReader.optionalNonNullBoolField(row, 'isDirty', path);
      BackupJsonReader.optionalNonNullBoolField(row, 'isDeleted', path);
    }
  }

  static void _validateSemesters(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      SemesterLocal.fromJson(rows[i], path: 'semesters[$i]');
    }
  }

  static void _validateSubjects(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'subjects[$i]';
      _validateSyncMetadata(row, path);
      BackupJsonReader.requireIntField(row, 'semesterId', path, min: 1);
      BackupJsonReader.requireNonEmptyStringField(row, 'name', path);
      BackupJsonReader.requireNonEmptyStringField(row, 'code', path);
      BackupJsonReader.nullableStringField(row, 'faculty', path);
      BackupJsonReader.optionalNonNullIntField(row, 'credits', path, min: 0);
      BackupJsonReader.optionalNonNullDoubleField(
        row,
        'attendanceTarget',
        path,
        min: 0.0,
        max: 100.0,
      );
      BackupJsonReader.optionalNonNullStringField(
        row,
        'color',
        path,
        allowEmpty: false,
      );
      final type = BackupJsonReader.optionalNonNullStringField(
        row,
        'type',
        path,
        allowEmpty: false,
      );
      if (type != null) {
        _requireEnumValue(type, _validSubjectTypes, '$path.type');
      }
    }
  }

  static void _validateTimetableTemplates(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'timetable[$i]';
      _validateSyncMetadata(row, path);
      BackupJsonReader.requireIntField(row, 'subjectId', path, min: 1);
      BackupJsonReader.requireIntField(row, 'weekday', path, min: 1, max: 7);
      final startTime = BackupJsonReader.requireNonEmptyStringField(
        row,
        'startTime',
        path,
      );
      final endTime = BackupJsonReader.requireNonEmptyStringField(
        row,
        'endTime',
        path,
      );
      _validateTimeRange(
        startTime: startTime,
        endTime: endTime,
        path: path,
      );
      BackupJsonReader.nullableStringField(row, 'room', path);
      BackupJsonReader.nullableStringField(row, 'faculty', path);
      BackupJsonReader.nullableStringField(row, 'notes', path);
    }
  }

  static void _validateLegacyEvents(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'events[$i]';
      _validateSyncMetadata(row, path);
      BackupJsonReader.requireIntField(row, 'subjectId', path, min: 1);
      BackupJsonReader.requireIsoDateTimeField(row, 'date', path);
      final startTime = BackupJsonReader.requireNonEmptyStringField(
        row,
        'startTime',
        path,
      );
      final endTime = BackupJsonReader.requireNonEmptyStringField(
        row,
        'endTime',
        path,
      );
      _validateTimeRange(
        startTime: startTime,
        endTime: endTime,
        path: path,
      );
      final eventType = BackupJsonReader.optionalNonNullStringField(
        row,
        'eventType',
        path,
        allowEmpty: false,
      );
      if (eventType != null) {
        _requireEnumValue(
          eventType,
          _validLegacyEventTypes,
          '$path.eventType',
        );
      }
      final status = BackupJsonReader.optionalNonNullStringField(
        row,
        'status',
        path,
        allowEmpty: false,
      );
      if (status != null) {
        _requireEnumValue(status, _validLegacyEventStatuses, '$path.status');
      }
    }
  }

  static void _validateWeeklyRules(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'weeklyRules[$i]';
      _validateSyncMetadata(row, path);
      BackupJsonReader.requireIntField(row, 'subjectId', path, min: 1);
      BackupJsonReader.nullableIntField(row, 'legacyTemplateId', path, min: 1);
      BackupJsonReader.requireIntField(row, 'dayOfWeek', path, min: 1, max: 7);
      final startTime = BackupJsonReader.requireNonEmptyStringField(
        row,
        'startTime',
        path,
      );
      final endTime = BackupJsonReader.requireNonEmptyStringField(
        row,
        'endTime',
        path,
      );
      _validateTimeRange(
        startTime: startTime,
        endTime: endTime,
        path: path,
      );
      BackupJsonReader.nullableStringField(row, 'room', path);
      BackupJsonReader.nullableStringField(row, 'faculty', path);
      final type = BackupJsonReader.optionalNonNullStringField(
        row,
        'type',
        path,
        allowEmpty: false,
      );
      if (type != null) {
        _requireEnumValue(type, _validSubjectTypes, '$path.type');
      }
      BackupJsonReader.optionalNonNullBoolField(row, 'isActive', path);
    }
  }

  static void _validateOccurrences(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'occurrences[$i]';
      _validateSyncMetadata(row, path);
      BackupJsonReader.requireIsoDateTimeField(row, 'date', path);

      final rawType = BackupJsonReader.requireNonEmptyStringField(
        row,
        'type',
        path,
      );
      final normType = _requireEnumValue(
        rawType,
        _validOccurrenceTypes,
        '$path.type',
      );
      if (normType == 'REGULAR_CLASS' || normType == 'EXTRA_CLASS') {
        BackupJsonReader.requireIntField(row, 'subjectId', path, min: 1);
      } else {
        BackupJsonReader.nullableIntField(row, 'subjectId', path, min: 1);
      }

      BackupJsonReader.nullableIntField(row, 'ruleId', path, min: 1);
      BackupJsonReader.nullableIntField(row, 'legacyEventId', path, min: 1);
      BackupJsonReader.nullableStringField(row, 'slotKey', path);
      BackupJsonReader.requireNonEmptyStringField(row, 'title', path);

      final startTime = BackupJsonReader.requireNonEmptyStringField(
        row,
        'startTime',
        path,
      );
      final endTime = BackupJsonReader.requireNonEmptyStringField(
        row,
        'endTime',
        path,
      );
      _validateTimeRange(
        startTime: startTime,
        endTime: endTime,
        path: path,
      );

      final status = BackupJsonReader.requireNonEmptyStringField(
        row,
        'status',
        path,
      );
      _requireEnumValue(status, _validOccurrenceStatuses, '$path.status');

      final createdFrom = BackupJsonReader.optionalNonNullStringField(
        row,
        'createdFrom',
        path,
        allowEmpty: false,
      );
      if (createdFrom != null) {
        _requireEnumValue(
          createdFrom,
          _validOccurrenceCreatedFrom,
          '$path.createdFrom',
        );
      }

      BackupJsonReader.nullableStringField(row, 'room', path);
      BackupJsonReader.nullableStringField(row, 'faculty', path);
      BackupJsonReader.nullableStringField(row, 'reason', path);
    }
  }

  static void _validateAttendance(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'attendance[$i]';
      _validateSyncMetadata(row, path);
      BackupJsonReader.nullableIntField(row, 'occurrenceId', path, min: 1);
      BackupJsonReader.nullableIntField(row, 'legacyEventId', path, min: 1);
      BackupJsonReader.optionalNonNullIntField(row, 'eventId', path, min: 0);
      BackupJsonReader.requireIntField(row, 'subjectId', path, min: 1);
      final status = BackupJsonReader.requireNonEmptyStringField(
        row,
        'status',
        path,
      );
      _requireEnumValue(status, _validAttendanceStatuses, '$path.status');
      BackupJsonReader.requireIsoDateTimeField(row, 'markedAt', path);
    }
  }

  static void _validateScheduleExceptions(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'scheduleExceptions[$i]';
      _validateSyncMetadata(row, path);
      BackupJsonReader.requireIsoDateTimeField(row, 'date', path);
      final rawType = BackupJsonReader.requireNonEmptyStringField(
        row,
        'type',
        path,
      );
      final normType = _requireEnumValue(
        rawType,
        _validScheduleExceptionTypes,
        '$path.type',
      );
      if (normType == 'CANCELLED_CLASS') {
        BackupJsonReader.requireIntField(row, 'subjectId', path, min: 1);
      } else {
        BackupJsonReader.nullableIntField(row, 'subjectId', path, min: 1);
      }
      BackupJsonReader.requireNonEmptyStringField(row, 'title', path);
      BackupJsonReader.nullableStringField(row, 'description', path);
    }
  }

  static void _validateAcademicEvents(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'academicEvents[$i]';
      _validateSyncMetadata(row, path);
      BackupJsonReader.requireNonEmptyStringField(row, 'title', path);
      BackupJsonReader.nullableStringField(row, 'description', path);
      BackupJsonReader.requireIsoDateTimeField(row, 'date', path);

      final startTime = BackupJsonReader.nullableStringField(
        row,
        'startTime',
        path,
      );
      final endTime = BackupJsonReader.nullableStringField(
        row,
        'endTime',
        path,
      );
      if (startTime != null && endTime != null) {
        _validateTimeRange(
          startTime: startTime,
          endTime: endTime,
          path: path,
        );
      } else {
        if (startTime != null) {
          _parseStrictHhMm(startTime, '$path.startTime');
        }
        if (endTime != null) {
          _parseStrictHhMm(endTime, '$path.endTime');
        }
      }

      final type = BackupJsonReader.requireNonEmptyStringField(
        row,
        'type',
        path,
      );
      _requireEnumValue(type, _validAcademicEventTypes, '$path.type');
    }
  }

  static void _validateTasks(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'tasks[$i]';
      _validateSyncMetadata(row, path);
      BackupJsonReader.nullableIntField(row, 'subjectId', path, min: 1);
      BackupJsonReader.requireNonEmptyStringField(row, 'title', path);
      BackupJsonReader.nullableStringField(row, 'description', path);

      final startDate = BackupJsonReader.requireIsoDateTimeField(
        row,
        'startDate',
        path,
      );
      final dueDate = BackupJsonReader.requireIsoDateTimeField(
        row,
        'dueDate',
        path,
      );
      if (dueDate.toUtc().isBefore(startDate.toUtc())) {
        throw FormatException(
          '$path: dueDate must not be before startDate.',
        );
      }

      final priority = BackupJsonReader.optionalNonNullStringField(
        row,
        'priority',
        path,
        allowEmpty: false,
      );
      if (priority != null) {
        _requireEnumValue(priority, _validTaskPriorities, '$path.priority');
      }

      final taskType = BackupJsonReader.optionalNonNullStringField(
        row,
        'taskType',
        path,
        allowEmpty: false,
      );
      if (taskType != null) {
        _requireEnumValue(taskType, _validTaskTypes, '$path.taskType');
      }

      final status = BackupJsonReader.optionalNonNullStringField(
        row,
        'status',
        path,
        allowEmpty: false,
      );
      if (status != null) {
        _requireEnumValue(status, _validTaskStatuses, '$path.status');
      }

      final reminder = BackupJsonReader.optionalNonNullStringField(
        row,
        'reminder',
        path,
        allowEmpty: false,
      );
      if (reminder != null) {
        _requireEnumValue(reminder, _validTaskReminders, '$path.reminder');
      }
    }
  }

  static void _validateNotifications(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final path = 'notifications[$i]';
      BackupJsonReader.optionalNonNullIntField(row, 'id', path, min: 0);
      BackupJsonReader.nullableIntField(row, 'androidNotificationId', path);
      BackupJsonReader.requireNonEmptyStringField(row, 'title', path);
      BackupJsonReader.requireStringField(row, 'body', path);
      final type = BackupJsonReader.requireNonEmptyStringField(
        row,
        'type',
        path,
      );
      _requireEnumValue(type, _validNotificationTypes, '$path.type');
      BackupJsonReader.requireIsoDateTimeField(row, 'scheduledTime', path);
      BackupJsonReader.nullableStringField(row, 'relatedId', path);
      BackupJsonReader.optionalNonNullBoolField(row, 'isRead', path);
    }
  }

  static void _validateMigrationAudits(List<Map<String, dynamic>> rows) {
    for (var i = 0; i < rows.length; i++) {
      final path = 'migrationAudits[$i]';
      final parsed = MigrationAuditRecordLocal.fromJson(rows[i], path: path);
      final trimmedKind = parsed.kind.trim();
      if (!_validMigrationAuditKinds.contains(trimmedKind)) {
        throw FormatException(
          '$path.kind: Invalid migration audit kind "$trimmedKind".',
        );
      }
    }
  }

  static int _parseStrictHhMm(String raw, String fieldPath) {
    final trimmed = raw.trim();
    final match = _strictHhMmPattern.firstMatch(trimmed);
    if (match == null) {
      throw FormatException(
        '$fieldPath: Expected strict HH:mm time (got "$raw").',
      );
    }
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw FormatException(
        '$fieldPath: Time out of valid 24-hour range (got "$raw").',
      );
    }
    return hour * 60 + minute;
  }

  static void _validateTimeRange({
    required String startTime,
    required String endTime,
    required String path,
  }) {
    final startMin = _parseStrictHhMm(startTime, '$path.startTime');
    final endMin = _parseStrictHhMm(endTime, '$path.endTime');
    if (startMin >= endMin) {
      throw FormatException(
        '$path: endTime ($endTime) must be strictly after startTime ($startTime).',
      );
    }
  }

  static String _requireEnumValue(
    String raw,
    Set<String> allowedUpper,
    String fieldPath,
  ) {
    final normalized = raw.trim().toUpperCase();
    if (!allowedUpper.contains(normalized)) {
      throw FormatException(
        '$fieldPath: Invalid value "$raw". Expected one of ${allowedUpper.join(', ')}.',
      );
    }
    return normalized;
  }

  /// Stage 6: Apply strategy-aware relationship validation.
  ///
  /// - [ImportStrategy.merge] preserves BUG-006 orphan skip + durable audit
  ///   handling without rejecting unmapped parent references.
  /// - [ImportStrategy.replace] rejects duplicate positive IDs within any
  ///   collection and rejects dangling required or explicit optional FKs
  ///   strictly before opening the Isar write transaction.
  static void validateRelationshipsForStrategy(
    ValidatedBackupPayload data, {
    ImportStrategy? strategy = ImportStrategy.replace,
  }) {
    if (strategy != ImportStrategy.replace) {
      return;
    }

    _collectUniquePositiveIds(data.userPreferences, 'userPreferences');
    final semesterIds = _collectUniquePositiveIds(data.semesters, 'semesters');
    final subjectIds = _collectUniquePositiveIds(data.subjects, 'subjects');
    final timetableIds = _collectUniquePositiveIds(data.timetable, 'timetable');
    final eventIds = _collectUniquePositiveIds(data.events, 'events');
    final weeklyRuleIds =
        _collectUniquePositiveIds(data.weeklyRules, 'weeklyRules');
    final occurrenceIds =
        _collectUniquePositiveIds(data.occurrences, 'occurrences');
    _collectUniquePositiveIds(data.attendance, 'attendance');
    _collectUniquePositiveIds(data.scheduleExceptions, 'scheduleExceptions');
    final academicEventIds =
        _collectUniquePositiveIds(data.academicEvents, 'academicEvents');
    final taskIds = _collectUniquePositiveIds(data.tasks, 'tasks');
    _collectUniquePositiveIds(data.notifications, 'notifications');
    _collectUniquePositiveIds(data.migrationAudits, 'migrationAudits');

    for (var i = 0; i < data.subjects.length; i++) {
      final semId = data.subjects[i]['semesterId'] as int;
      if (!semesterIds.contains(semId)) {
        throw FormatException(
          'subjects[$i].semesterId: References missing semester ID $semId.',
        );
      }
    }

    for (var i = 0; i < data.timetable.length; i++) {
      final subId = data.timetable[i]['subjectId'] as int;
      if (!subjectIds.contains(subId)) {
        throw FormatException(
          'timetable[$i].subjectId: References missing subject ID $subId.',
        );
      }
    }

    for (var i = 0; i < data.events.length; i++) {
      final subId = data.events[i]['subjectId'] as int;
      if (!subjectIds.contains(subId)) {
        throw FormatException(
          'events[$i].subjectId: References missing subject ID $subId.',
        );
      }
    }

    for (var i = 0; i < data.weeklyRules.length; i++) {
      final row = data.weeklyRules[i];
      final subId = row['subjectId'] as int;
      if (!subjectIds.contains(subId)) {
        throw FormatException(
          'weeklyRules[$i].subjectId: References missing subject ID $subId.',
        );
      }
      final legacyTplId = row['legacyTemplateId'] as int?;
      if (legacyTplId != null && !timetableIds.contains(legacyTplId)) {
        throw FormatException(
          'weeklyRules[$i].legacyTemplateId: References missing timetable ID $legacyTplId.',
        );
      }
    }

    for (var i = 0; i < data.occurrences.length; i++) {
      final row = data.occurrences[i];
      final subId = row['subjectId'] as int?;
      if (subId != null && !subjectIds.contains(subId)) {
        throw FormatException(
          'occurrences[$i].subjectId: References missing subject ID $subId.',
        );
      }
      final ruleId = row['ruleId'] as int?;
      if (ruleId != null && !weeklyRuleIds.contains(ruleId)) {
        throw FormatException(
          'occurrences[$i].ruleId: References missing weekly rule ID $ruleId.',
        );
      }
      final legacyEvId = row['legacyEventId'] as int?;
      if (legacyEvId != null && !eventIds.contains(legacyEvId)) {
        throw FormatException(
          'occurrences[$i].legacyEventId: References missing legacy event ID $legacyEvId.',
        );
      }
    }

    for (var i = 0; i < data.attendance.length; i++) {
      final row = data.attendance[i];
      final subId = row['subjectId'] as int;
      if (!subjectIds.contains(subId)) {
        throw FormatException(
          'attendance[$i].subjectId: References missing subject ID $subId.',
        );
      }
      final occId = row['occurrenceId'] as int?;
      if (occId != null && !occurrenceIds.contains(occId)) {
        throw FormatException(
          'attendance[$i].occurrenceId: References missing occurrence ID $occId.',
        );
      }
    }

    for (var i = 0; i < data.scheduleExceptions.length; i++) {
      final subId = data.scheduleExceptions[i]['subjectId'] as int?;
      if (subId != null && !subjectIds.contains(subId)) {
        throw FormatException(
          'scheduleExceptions[$i].subjectId: References missing subject ID $subId.',
        );
      }
    }

    for (var i = 0; i < data.tasks.length; i++) {
      final subId = data.tasks[i]['subjectId'] as int?;
      if (subId != null && !subjectIds.contains(subId)) {
        throw FormatException(
          'tasks[$i].subjectId: References missing subject ID $subId.',
        );
      }
    }

    for (var i = 0; i < data.notifications.length; i++) {
      final row = data.notifications[i];
      final rawRelatedId = row['relatedId'] as String?;
      if (rawRelatedId == null || rawRelatedId.trim().isEmpty) {
        continue;
      }
      final type = (row['type'] as String).trim().toUpperCase();
      _validateReplaceNotificationRelatedId(
        rawRelatedId: rawRelatedId.trim(),
        type: type,
        path: 'notifications[$i].relatedId',
        subjectIds: subjectIds,
        weeklyRuleIds: weeklyRuleIds,
        occurrenceIds: occurrenceIds,
        eventIds: eventIds,
        academicEventIds: academicEventIds,
        taskIds: taskIds,
      );
    }
  }

  static Set<int> _collectUniquePositiveIds(
    List<Map<String, dynamic>> rows,
    String collectionName,
  ) {
    final ids = <int>{};
    for (var i = 0; i < rows.length; i++) {
      final id = rows[i]['id'] as int?;
      if (id != null && id > 0 && !ids.add(id)) {
        throw FormatException(
          '$collectionName[$i].id: Duplicate positive ID $id.',
        );
      }
    }
    return ids;
  }

  static void _validateReplaceNotificationRelatedId({
    required String rawRelatedId,
    required String type,
    required String path,
    required Set<int> subjectIds,
    required Set<int> weeklyRuleIds,
    required Set<int> occurrenceIds,
    required Set<int> eventIds,
    required Set<int> academicEventIds,
    required Set<int> taskIds,
  }) {
    if (rawRelatedId.startsWith('slot:')) {
      final slotKey = rawRelatedId.substring('slot:'.length).trim();
      if (slotKey.isEmpty) {
        throw FormatException('$path: Empty slot key reference.');
      }
      if (slotKey.startsWith('LEGACY_EV:')) {
        final evId = int.tryParse(slotKey.substring('LEGACY_EV:'.length));
        if (evId == null || evId <= 0 || !eventIds.contains(evId)) {
          throw FormatException(
            '$path: Slot references missing legacy event in "$rawRelatedId".',
          );
        }
        return;
      }
      final parts = slotKey.split('|');
      final slotType = parts.first.trim().toUpperCase();
      final allowsZeroSubject = slotType == 'EXAM' || slotType == 'EVENT';
      for (final segment in parts) {
        if (segment.startsWith('rule:')) {
          final ruleId = int.tryParse(segment.substring('rule:'.length));
          if (ruleId == null ||
              ruleId <= 0 ||
              !weeklyRuleIds.contains(ruleId)) {
            throw FormatException(
              '$path: Slot references missing weekly rule in "$rawRelatedId".',
            );
          }
        } else if (segment.startsWith('sub:')) {
          final subId = int.tryParse(segment.substring('sub:'.length));
          if (subId == null) {
            throw FormatException(
              '$path: Invalid subject ID in slot "$rawRelatedId".',
            );
          }
          if (subId == 0 && allowsZeroSubject) {
            continue;
          }
          if (subId <= 0 || !subjectIds.contains(subId)) {
            throw FormatException(
              '$path: Slot references missing subject ID $subId.',
            );
          }
        }
      }
      return;
    }

    if (rawRelatedId.startsWith('occ:')) {
      final id = _parsePrefixedPositiveId(rawRelatedId, 'occ:', path);
      if (!occurrenceIds.contains(id)) {
        throw FormatException('$path: References missing occurrence ID $id.');
      }
      return;
    }
    if (rawRelatedId.startsWith('ae_1d:')) {
      final id = _parsePrefixedPositiveId(rawRelatedId, 'ae_1d:', path);
      if (!academicEventIds.contains(id)) {
        throw FormatException(
          '$path: References missing academic event ID $id.',
        );
      }
      return;
    }
    if (rawRelatedId.startsWith('ae_30m:')) {
      final id = _parsePrefixedPositiveId(rawRelatedId, 'ae_30m:', path);
      if (!academicEventIds.contains(id)) {
        throw FormatException(
          '$path: References missing academic event ID $id.',
        );
      }
      return;
    }
    if (rawRelatedId.startsWith('sub:')) {
      final id = _parsePrefixedPositiveId(rawRelatedId, 'sub:', path);
      if (!subjectIds.contains(id)) {
        throw FormatException('$path: References missing subject ID $id.');
      }
      return;
    }
    if (rawRelatedId.startsWith('task:')) {
      final id = _parsePrefixedPositiveId(rawRelatedId, 'task:', path);
      if (!taskIds.contains(id)) {
        throw FormatException('$path: References missing task ID $id.');
      }
      return;
    }

    final numeric = int.tryParse(rawRelatedId);
    if (numeric == null || numeric <= 0) {
      throw FormatException(
        '$path: Invalid relatedId reference "$rawRelatedId".',
      );
    }

    if (type == 'LOW_ATTENDANCE_ALERT' || type == 'ATTENDANCE_WARNING') {
      if (!subjectIds.contains(numeric)) {
        throw FormatException(
          '$path: References missing subject ID $numeric.',
        );
      }
      return;
    }
    if (type == 'ASSIGNMENT_REMINDER') {
      if (!taskIds.contains(numeric)) {
        throw FormatException('$path: References missing task ID $numeric.');
      }
      return;
    }
    if (type == 'CLASS_REMINDER') {
      final matchesAcademicEvent =
          (numeric > 200000 && academicEventIds.contains(numeric - 200000)) ||
              (numeric > 100000 && academicEventIds.contains(numeric - 100000));
      if (!matchesAcademicEvent &&
          !occurrenceIds.contains(numeric) &&
          !eventIds.contains(numeric)) {
        throw FormatException(
          '$path: References missing class/event target ID $numeric.',
        );
      }
      return;
    }

    throw FormatException(
      '$path: Unrecognized numeric relatedId "$rawRelatedId" for notification type "$type".',
    );
  }

  static int _parsePrefixedPositiveId(
    String raw,
    String prefix,
    String path,
  ) {
    final id = int.tryParse(raw.substring(prefix.length));
    if (id == null || id <= 0) {
      throw FormatException(
        '$path: Invalid positive ID in reference "$raw".',
      );
    }
    return id;
  }
}
