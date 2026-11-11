import 'dart:convert';

import 'package:isar/isar.dart';

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

  factory MigrationAuditRecordLocal.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toUtc();
    final rawEventDate = json['eventDate'] as String?;
    final rawCreatedAt = json['createdAt'] as String?;
    final rawUpdatedAt = json['updatedAt'] as String?;
    final rawCandidates = json['candidateOccurrenceIds'];
    String? candidateStr;
    if (rawCandidates is String) {
      candidateStr = rawCandidates.trim().isEmpty ? null : rawCandidates.trim();
    } else if (rawCandidates is List) {
      final parsed = rawCandidates
          .map((e) => e is int ? e : int.tryParse('$e'))
          .whereType<int>();
      candidateStr = formatCandidateOccurrenceIds(parsed);
    }

    final rawDetails = json['diagnosticDetails'];
    String? detailsStr;
    if (rawDetails is String) {
      detailsStr = rawDetails;
    } else if (rawDetails is Map) {
      detailsStr = jsonEncode(rawDetails);
    }

    return MigrationAuditRecordLocal()
      ..id = json['id'] as int? ?? 0
      ..serverId = json['serverId'] as String?
      ..auditKey = json['auditKey'] as String? ?? ''
      ..kind = json['kind'] as String? ?? 'missingOccurrenceTarget'
      ..attendanceRecordId = json['attendanceRecordId'] as int?
      ..legacyEventId = json['legacyEventId'] as int?
      ..sourceEventId = json['sourceEventId'] as int?
      ..occurrenceId = json['occurrenceId'] as int?
      ..sourceOccurrenceId = json['sourceOccurrenceId'] as int?
      ..subjectId = json['subjectId'] as int?
      ..slotKey = json['slotKey'] as String?
      ..candidateOccurrenceIds = candidateStr
      ..status = json['status'] as String?
      ..eventDate =
          rawEventDate != null ? DateTime.tryParse(rawEventDate)?.toUtc() : null
      ..reason = json['reason'] as String? ?? ''
      ..diagnosticDetails = detailsStr
      ..createdAt = (rawCreatedAt != null
              ? DateTime.tryParse(rawCreatedAt)?.toUtc()
              : null) ??
          now
      ..updatedAt = (rawUpdatedAt != null
              ? DateTime.tryParse(rawUpdatedAt)?.toUtc()
              : null) ??
          now
      ..isDirty = json['isDirty'] as bool? ?? false
      ..isDeleted = json['isDeleted'] as bool? ?? false;
  }
}
