import 'dart:convert';

import 'package:isar/isar.dart';

import '../backup/backup_json_reader.dart';

part 'migration_audit_record_local.g.dart';

/// Durable Isar collection storing BUG-004 timetable, occurrence, and attendance
/// migration audit records across database reopens and repeated startup runs.
@collection
class MigrationAuditRecordLocal {
  int id = 0;

  @Index(unique: true)
  String? serverId;

  /// Deterministic stable identity key preventing duplicate rows for the same
  /// historical migration event across repeated runs and database reopens.
  @Index(unique: true)
  late String auditKey;

  /// String name matching `MigrationAuditKind` (e.g. `recoveredAttendance`).
  @Index()
  late String kind;

  @Index()
  int? attendanceRecordId;

  @Index()
  int? legacyEventId;

  int? sourceEventId;

  @Index()
  int? occurrenceId;

  @Index()
  int? sourceOccurrenceId;

  @Index()
  int? subjectId;

  String? slotKey;

  /// Comma-separated candidate occurrence IDs when applicable.
  String? candidateOccurrenceIds;

  String? status;
  DateTime? eventDate;
  late String reason;
  String? diagnosticDetails;

  @Index()
  late DateTime createdAt;

  late DateTime updatedAt;
  bool isDirty = false;
  bool isDeleted = false;

  MigrationAuditRecordLocal();

  @ignore
  List<int> get parsedCandidateOccurrenceIds =>
      parseCandidateOccurrenceIds(candidateOccurrenceIds);

  static List<int> parseCandidateOccurrenceIds(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const <int>[];
    }
    final result = <int>[];
    for (final part in raw.split(',')) {
      final parsed = int.tryParse(part.trim());
      if (parsed != null && parsed > 0) {
        result.add(parsed);
      }
    }
    return List<int>.unmodifiable(result);
  }

  static String? formatCandidateOccurrenceIds(Iterable<int> ids) {
    final cleaned = ids.where((id) => id > 0).toList(growable: false);
    if (cleaned.isEmpty) return null;
    return cleaned.join(',');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'serverId': serverId,
      'auditKey': auditKey,
      'kind': kind,
      'attendanceRecordId': attendanceRecordId,
      'legacyEventId': legacyEventId,
      'sourceEventId': sourceEventId,
      'occurrenceId': occurrenceId,
      'sourceOccurrenceId': sourceOccurrenceId,
      'subjectId': subjectId,
      'slotKey': slotKey,
      'candidateOccurrenceIds': candidateOccurrenceIds,
      'status': status,
      'eventDate': eventDate?.toIso8601String(),
      'reason': reason,
      'diagnosticDetails': diagnosticDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDirty': isDirty,
      'isDeleted': isDeleted,
    };
  }

  factory MigrationAuditRecordLocal.fromJson(
    Map<String, dynamic> json, {
    String path = 'migrationAudit',
  }) {
    final now = DateTime.now().toUtc();
    final rawCandidates = json['candidateOccurrenceIds'];
    String? candidateStr;
    if (rawCandidates == null) {
      candidateStr = null;
    } else if (rawCandidates is String) {
      final trimmed = rawCandidates.trim();
      if (trimmed.isEmpty) {
        candidateStr = null;
      } else {
        final parsedIds = <int>[];
        for (final part in trimmed.split(',')) {
          final parsed = int.tryParse(part.trim());
          if (parsed == null || parsed <= 0) {
            throw FormatException(
              '$path.candidateOccurrenceIds: Invalid occurrence ID "$part" in "$rawCandidates".',
            );
          }
          parsedIds.add(parsed);
        }
        candidateStr = formatCandidateOccurrenceIds(parsedIds);
      }
    } else if (rawCandidates is List) {
      final parsedIds = <int>[];
      for (var i = 0; i < rawCandidates.length; i++) {
        final item = rawCandidates[i];
        if (item is! int || item <= 0) {
          throw FormatException(
            '$path.candidateOccurrenceIds[$i]: Expected a positive integer.',
          );
        }
        parsedIds.add(item);
      }
      candidateStr = formatCandidateOccurrenceIds(parsedIds);
    } else {
      throw FormatException(
        '$path.candidateOccurrenceIds: Expected a string, integer list, or null.',
      );
    }

    final rawDetails = json['diagnosticDetails'];
    String? detailsStr;
    if (rawDetails == null) {
      detailsStr = null;
    } else if (rawDetails is String) {
      detailsStr = rawDetails;
    } else if (rawDetails is Map) {
      final detailsMap = BackupJsonReader.asJsonObject(
        rawDetails,
        '$path.diagnosticDetails',
      );
      try {
        detailsStr = jsonEncode(detailsMap);
      } catch (e) {
        throw FormatException(
          '$path.diagnosticDetails: Could not encode JSON object ($e).',
        );
      }
    } else {
      throw FormatException(
        '$path.diagnosticDetails: Expected a string, JSON object, or null.',
      );
    }

    return MigrationAuditRecordLocal()
      ..id = BackupJsonReader.optionalNonNullIntField(
            json,
            'id',
            path,
            min: 0,
          ) ??
          0
      ..serverId = BackupJsonReader.nullableStringField(json, 'serverId', path)
      ..auditKey = BackupJsonReader.requireNonEmptyStringField(
        json,
        'auditKey',
        path,
      )
      ..kind = BackupJsonReader.requireNonEmptyStringField(json, 'kind', path)
      ..attendanceRecordId = BackupJsonReader.nullableIntField(
        json,
        'attendanceRecordId',
        path,
        min: 0,
      )
      ..legacyEventId = BackupJsonReader.nullableIntField(
        json,
        'legacyEventId',
        path,
        min: 0,
      )
      ..sourceEventId = BackupJsonReader.nullableIntField(
        json,
        'sourceEventId',
        path,
        min: 0,
      )
      ..occurrenceId = BackupJsonReader.nullableIntField(
        json,
        'occurrenceId',
        path,
        min: 0,
      )
      ..sourceOccurrenceId = BackupJsonReader.nullableIntField(
        json,
        'sourceOccurrenceId',
        path,
        min: 0,
      )
      ..subjectId = BackupJsonReader.nullableIntField(
        json,
        'subjectId',
        path,
        min: 0,
      )
      ..slotKey = BackupJsonReader.nullableStringField(json, 'slotKey', path)
      ..candidateOccurrenceIds = candidateStr
      ..status = BackupJsonReader.nullableStringField(json, 'status', path)
      ..eventDate = BackupJsonReader.nullableIsoDateTimeField(
        json,
        'eventDate',
        path,
      )?.toUtc()
      ..reason = BackupJsonReader.requireStringField(json, 'reason', path)
      ..diagnosticDetails = detailsStr
      ..createdAt = BackupJsonReader.optionalNonNullIsoDateTimeField(
            json,
            'createdAt',
            path,
          )?.toUtc() ??
          now
      ..updatedAt = BackupJsonReader.optionalNonNullIsoDateTimeField(
            json,
            'updatedAt',
            path,
          )?.toUtc() ??
          now
      ..isDirty = BackupJsonReader.optionalNonNullBoolField(
            json,
            'isDirty',
            path,
          ) ??
          false
      ..isDeleted = BackupJsonReader.optionalNonNullBoolField(
            json,
            'isDeleted',
            path,
          ) ??
          false;
  }
}
