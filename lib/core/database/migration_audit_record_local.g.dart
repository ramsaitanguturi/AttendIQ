// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_audit_record_local.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetMigrationAuditRecordLocalCollection on Isar {
  IsarCollection<int, MigrationAuditRecordLocal>
      get migrationAuditRecordLocals => this.collection();
}

const MigrationAuditRecordLocalSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'MigrationAuditRecordLocal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'serverId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'auditKey',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'kind',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'attendanceRecordId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'legacyEventId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'sourceEventId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'occurrenceId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'sourceOccurrenceId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'subjectId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'slotKey',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'candidateOccurrenceIds',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'status',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'eventDate',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'reason',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'diagnosticDetails',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'updatedAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'isDirty',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'isDeleted',
        type: IsarType.bool,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'serverId',
        properties: [
          "serverId",
        ],
        unique: true,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'auditKey',
        properties: [
          "auditKey",
        ],
        unique: true,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'kind',
        properties: [
          "kind",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'attendanceRecordId',
        properties: [
          "attendanceRecordId",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'legacyEventId',
        properties: [
          "legacyEventId",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'occurrenceId',
        properties: [
          "occurrenceId",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'sourceOccurrenceId',
        properties: [
          "sourceOccurrenceId",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'subjectId',
        properties: [
          "subjectId",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'createdAt',
        properties: [
          "createdAt",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, MigrationAuditRecordLocal>(
    serialize: serializeMigrationAuditRecordLocal,
    deserialize: deserializeMigrationAuditRecordLocal,
    deserializeProperty: deserializeMigrationAuditRecordLocalProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeMigrationAuditRecordLocal(
    IsarWriter writer, MigrationAuditRecordLocal object) {
  {
    final value = object.serverId;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  IsarCore.writeString(writer, 2, object.auditKey);
  IsarCore.writeString(writer, 3, object.kind);
  IsarCore.writeLong(
      writer, 4, object.attendanceRecordId ?? -9223372036854775808);
  IsarCore.writeLong(writer, 5, object.legacyEventId ?? -9223372036854775808);
  IsarCore.writeLong(writer, 6, object.sourceEventId ?? -9223372036854775808);
  IsarCore.writeLong(writer, 7, object.occurrenceId ?? -9223372036854775808);
  IsarCore.writeLong(
      writer, 8, object.sourceOccurrenceId ?? -9223372036854775808);
  IsarCore.writeLong(writer, 9, object.subjectId ?? -9223372036854775808);
  {
    final value = object.slotKey;
    if (value == null) {
      IsarCore.writeNull(writer, 10);
    } else {
      IsarCore.writeString(writer, 10, value);
    }
  }
  {
    final value = object.candidateOccurrenceIds;
    if (value == null) {
      IsarCore.writeNull(writer, 11);
    } else {
      IsarCore.writeString(writer, 11, value);
    }
  }
  {
    final value = object.status;
    if (value == null) {
      IsarCore.writeNull(writer, 12);
    } else {
      IsarCore.writeString(writer, 12, value);
    }
  }
  IsarCore.writeLong(writer, 13,
      object.eventDate?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808);
  IsarCore.writeString(writer, 14, object.reason);
  {
    final value = object.diagnosticDetails;
    if (value == null) {
      IsarCore.writeNull(writer, 15);
    } else {
      IsarCore.writeString(writer, 15, value);
    }
  }
  IsarCore.writeLong(
      writer, 16, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 17, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 18, object.isDirty);
  IsarCore.writeBool(writer, 19, object.isDeleted);
  return object.id;
}

@isarProtected
MigrationAuditRecordLocal deserializeMigrationAuditRecordLocal(
    IsarReader reader) {
  final object = MigrationAuditRecordLocal();
  object.id = IsarCore.readId(reader);
  object.serverId = IsarCore.readString(reader, 1);
  object.auditKey = IsarCore.readString(reader, 2) ?? '';
  object.kind = IsarCore.readString(reader, 3) ?? '';
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      object.attendanceRecordId = null;
    } else {
      object.attendanceRecordId = value;
    }
  }
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      object.legacyEventId = null;
    } else {
      object.legacyEventId = value;
    }
  }
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      object.sourceEventId = null;
    } else {
      object.sourceEventId = value;
    }
  }
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      object.occurrenceId = null;
    } else {
      object.occurrenceId = value;
    }
  }
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      object.sourceOccurrenceId = null;
    } else {
      object.sourceOccurrenceId = value;
    }
  }
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      object.subjectId = null;
    } else {
      object.subjectId = value;
    }
  }
  object.slotKey = IsarCore.readString(reader, 10);
  object.candidateOccurrenceIds = IsarCore.readString(reader, 11);
  object.status = IsarCore.readString(reader, 12);
  {
    final value = IsarCore.readLong(reader, 13);
    if (value == -9223372036854775808) {
      object.eventDate = null;
    } else {
      object.eventDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.reason = IsarCore.readString(reader, 14) ?? '';
  object.diagnosticDetails = IsarCore.readString(reader, 15);
  {
    final value = IsarCore.readLong(reader, 16);
    if (value == -9223372036854775808) {
      object.createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 17);
    if (value == -9223372036854775808) {
      object.updatedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.updatedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.isDirty = IsarCore.readBool(reader, 18);
  object.isDeleted = IsarCore.readBool(reader, 19);
  return object;
}

@isarProtected
dynamic deserializeMigrationAuditRecordLocalProp(
    IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 9:
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 10:
      return IsarCore.readString(reader, 10);
    case 11:
      return IsarCore.readString(reader, 11);
    case 12:
      return IsarCore.readString(reader, 12);
    case 13:
      {
        final value = IsarCore.readLong(reader, 13);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 14:
      return IsarCore.readString(reader, 14) ?? '';
    case 15:
      return IsarCore.readString(reader, 15);
    case 16:
      {
        final value = IsarCore.readLong(reader, 16);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 17:
      {
        final value = IsarCore.readLong(reader, 17);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 18:
      return IsarCore.readBool(reader, 18);
    case 19:
      return IsarCore.readBool(reader, 19);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _MigrationAuditRecordLocalUpdate {
  bool call({
    required int id,
    String? serverId,
    String? auditKey,
    String? kind,
    int? attendanceRecordId,
    int? legacyEventId,
    int? sourceEventId,
    int? occurrenceId,
    int? sourceOccurrenceId,
    int? subjectId,
    String? slotKey,
    String? candidateOccurrenceIds,
    String? status,
    DateTime? eventDate,
    String? reason,
    String? diagnosticDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _MigrationAuditRecordLocalUpdateImpl
    implements _MigrationAuditRecordLocalUpdate {
  const _MigrationAuditRecordLocalUpdateImpl(this.collection);

  final IsarCollection<int, MigrationAuditRecordLocal> collection;

  @override
  bool call({
    required int id,
    Object? serverId = ignore,
    Object? auditKey = ignore,
    Object? kind = ignore,
    Object? attendanceRecordId = ignore,
    Object? legacyEventId = ignore,
    Object? sourceEventId = ignore,
    Object? occurrenceId = ignore,
    Object? sourceOccurrenceId = ignore,
    Object? subjectId = ignore,
    Object? slotKey = ignore,
    Object? candidateOccurrenceIds = ignore,
    Object? status = ignore,
    Object? eventDate = ignore,
    Object? reason = ignore,
    Object? diagnosticDetails = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (serverId != ignore) 1: serverId as String?,
          if (auditKey != ignore) 2: auditKey as String?,
          if (kind != ignore) 3: kind as String?,
          if (attendanceRecordId != ignore) 4: attendanceRecordId as int?,
          if (legacyEventId != ignore) 5: legacyEventId as int?,
          if (sourceEventId != ignore) 6: sourceEventId as int?,
          if (occurrenceId != ignore) 7: occurrenceId as int?,
          if (sourceOccurrenceId != ignore) 8: sourceOccurrenceId as int?,
          if (subjectId != ignore) 9: subjectId as int?,
          if (slotKey != ignore) 10: slotKey as String?,
          if (candidateOccurrenceIds != ignore)
            11: candidateOccurrenceIds as String?,
          if (status != ignore) 12: status as String?,
          if (eventDate != ignore) 13: eventDate as DateTime?,
          if (reason != ignore) 14: reason as String?,
          if (diagnosticDetails != ignore) 15: diagnosticDetails as String?,
          if (createdAt != ignore) 16: createdAt as DateTime?,
          if (updatedAt != ignore) 17: updatedAt as DateTime?,
          if (isDirty != ignore) 18: isDirty as bool?,
          if (isDeleted != ignore) 19: isDeleted as bool?,
        }) >
        0;
  }
}

sealed class _MigrationAuditRecordLocalUpdateAll {
  int call({
    required List<int> id,
    String? serverId,
    String? auditKey,
    String? kind,
    int? attendanceRecordId,
    int? legacyEventId,
    int? sourceEventId,
    int? occurrenceId,
    int? sourceOccurrenceId,
    int? subjectId,
    String? slotKey,
    String? candidateOccurrenceIds,
    String? status,
    DateTime? eventDate,
    String? reason,
    String? diagnosticDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _MigrationAuditRecordLocalUpdateAllImpl
    implements _MigrationAuditRecordLocalUpdateAll {
  const _MigrationAuditRecordLocalUpdateAllImpl(this.collection);

  final IsarCollection<int, MigrationAuditRecordLocal> collection;

  @override
  int call({
    required List<int> id,
    Object? serverId = ignore,
    Object? auditKey = ignore,
    Object? kind = ignore,
    Object? attendanceRecordId = ignore,
    Object? legacyEventId = ignore,
    Object? sourceEventId = ignore,
    Object? occurrenceId = ignore,
    Object? sourceOccurrenceId = ignore,
    Object? subjectId = ignore,
    Object? slotKey = ignore,
    Object? candidateOccurrenceIds = ignore,
    Object? status = ignore,
    Object? eventDate = ignore,
    Object? reason = ignore,
    Object? diagnosticDetails = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties(id, {
      if (serverId != ignore) 1: serverId as String?,
      if (auditKey != ignore) 2: auditKey as String?,
      if (kind != ignore) 3: kind as String?,
      if (attendanceRecordId != ignore) 4: attendanceRecordId as int?,
      if (legacyEventId != ignore) 5: legacyEventId as int?,
      if (sourceEventId != ignore) 6: sourceEventId as int?,
      if (occurrenceId != ignore) 7: occurrenceId as int?,
      if (sourceOccurrenceId != ignore) 8: sourceOccurrenceId as int?,
      if (subjectId != ignore) 9: subjectId as int?,
      if (slotKey != ignore) 10: slotKey as String?,
      if (candidateOccurrenceIds != ignore)
        11: candidateOccurrenceIds as String?,
      if (status != ignore) 12: status as String?,
      if (eventDate != ignore) 13: eventDate as DateTime?,
      if (reason != ignore) 14: reason as String?,
      if (diagnosticDetails != ignore) 15: diagnosticDetails as String?,
      if (createdAt != ignore) 16: createdAt as DateTime?,
      if (updatedAt != ignore) 17: updatedAt as DateTime?,
      if (isDirty != ignore) 18: isDirty as bool?,
      if (isDeleted != ignore) 19: isDeleted as bool?,
    });
  }
}

extension MigrationAuditRecordLocalUpdate
    on IsarCollection<int, MigrationAuditRecordLocal> {
  _MigrationAuditRecordLocalUpdate get update =>
      _MigrationAuditRecordLocalUpdateImpl(this);

  _MigrationAuditRecordLocalUpdateAll get updateAll =>
      _MigrationAuditRecordLocalUpdateAllImpl(this);
}

sealed class _MigrationAuditRecordLocalQueryUpdate {
  int call({
    String? serverId,
    String? auditKey,
    String? kind,
    int? attendanceRecordId,
    int? legacyEventId,
    int? sourceEventId,
    int? occurrenceId,
    int? sourceOccurrenceId,
    int? subjectId,
    String? slotKey,
    String? candidateOccurrenceIds,
    String? status,
    DateTime? eventDate,
    String? reason,
    String? diagnosticDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _MigrationAuditRecordLocalQueryUpdateImpl
    implements _MigrationAuditRecordLocalQueryUpdate {
  const _MigrationAuditRecordLocalQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<MigrationAuditRecordLocal> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? auditKey = ignore,
    Object? kind = ignore,
    Object? attendanceRecordId = ignore,
    Object? legacyEventId = ignore,
    Object? sourceEventId = ignore,
    Object? occurrenceId = ignore,
    Object? sourceOccurrenceId = ignore,
    Object? subjectId = ignore,
    Object? slotKey = ignore,
    Object? candidateOccurrenceIds = ignore,
    Object? status = ignore,
    Object? eventDate = ignore,
    Object? reason = ignore,
    Object? diagnosticDetails = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (serverId != ignore) 1: serverId as String?,
      if (auditKey != ignore) 2: auditKey as String?,
      if (kind != ignore) 3: kind as String?,
      if (attendanceRecordId != ignore) 4: attendanceRecordId as int?,
      if (legacyEventId != ignore) 5: legacyEventId as int?,
      if (sourceEventId != ignore) 6: sourceEventId as int?,
      if (occurrenceId != ignore) 7: occurrenceId as int?,
      if (sourceOccurrenceId != ignore) 8: sourceOccurrenceId as int?,
      if (subjectId != ignore) 9: subjectId as int?,
      if (slotKey != ignore) 10: slotKey as String?,
      if (candidateOccurrenceIds != ignore)
        11: candidateOccurrenceIds as String?,
      if (status != ignore) 12: status as String?,
      if (eventDate != ignore) 13: eventDate as DateTime?,
      if (reason != ignore) 14: reason as String?,
      if (diagnosticDetails != ignore) 15: diagnosticDetails as String?,
      if (createdAt != ignore) 16: createdAt as DateTime?,
      if (updatedAt != ignore) 17: updatedAt as DateTime?,
      if (isDirty != ignore) 18: isDirty as bool?,
      if (isDeleted != ignore) 19: isDeleted as bool?,
    });
  }
}

extension MigrationAuditRecordLocalQueryUpdate
    on IsarQuery<MigrationAuditRecordLocal> {
  _MigrationAuditRecordLocalQueryUpdate get updateFirst =>
      _MigrationAuditRecordLocalQueryUpdateImpl(this, limit: 1);

  _MigrationAuditRecordLocalQueryUpdate get updateAll =>
      _MigrationAuditRecordLocalQueryUpdateImpl(this);
}

class _MigrationAuditRecordLocalQueryBuilderUpdateImpl
    implements _MigrationAuditRecordLocalQueryUpdate {
  const _MigrationAuditRecordLocalQueryBuilderUpdateImpl(this.query,
      {this.limit});

  final QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QOperations> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? auditKey = ignore,
    Object? kind = ignore,
    Object? attendanceRecordId = ignore,
    Object? legacyEventId = ignore,
    Object? sourceEventId = ignore,
    Object? occurrenceId = ignore,
    Object? sourceOccurrenceId = ignore,
    Object? subjectId = ignore,
    Object? slotKey = ignore,
    Object? candidateOccurrenceIds = ignore,
    Object? status = ignore,
    Object? eventDate = ignore,
    Object? reason = ignore,
    Object? diagnosticDetails = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (serverId != ignore) 1: serverId as String?,
        if (auditKey != ignore) 2: auditKey as String?,
        if (kind != ignore) 3: kind as String?,
        if (attendanceRecordId != ignore) 4: attendanceRecordId as int?,
        if (legacyEventId != ignore) 5: legacyEventId as int?,
        if (sourceEventId != ignore) 6: sourceEventId as int?,
        if (occurrenceId != ignore) 7: occurrenceId as int?,
        if (sourceOccurrenceId != ignore) 8: sourceOccurrenceId as int?,
        if (subjectId != ignore) 9: subjectId as int?,
        if (slotKey != ignore) 10: slotKey as String?,
        if (candidateOccurrenceIds != ignore)
          11: candidateOccurrenceIds as String?,
        if (status != ignore) 12: status as String?,
        if (eventDate != ignore) 13: eventDate as DateTime?,
        if (reason != ignore) 14: reason as String?,
        if (diagnosticDetails != ignore) 15: diagnosticDetails as String?,
        if (createdAt != ignore) 16: createdAt as DateTime?,
        if (updatedAt != ignore) 17: updatedAt as DateTime?,
        if (isDirty != ignore) 18: isDirty as bool?,
        if (isDeleted != ignore) 19: isDeleted as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension MigrationAuditRecordLocalQueryBuilderUpdate on QueryBuilder<
    MigrationAuditRecordLocal, MigrationAuditRecordLocal, QOperations> {
  _MigrationAuditRecordLocalQueryUpdate get updateFirst =>
      _MigrationAuditRecordLocalQueryBuilderUpdateImpl(this, limit: 1);

  _MigrationAuditRecordLocalQueryUpdate get updateAll =>
      _MigrationAuditRecordLocalQueryBuilderUpdateImpl(this);
}

extension MigrationAuditRecordLocalQueryFilter on QueryBuilder<
    MigrationAuditRecordLocal, MigrationAuditRecordLocal, QFilterCondition> {
  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      serverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      serverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      auditKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      auditKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> auditKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> attendanceRecordIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> attendanceRecordIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> attendanceRecordIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> attendanceRecordIdGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> attendanceRecordIdGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> attendanceRecordIdLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> attendanceRecordIdLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> attendanceRecordIdBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> legacyEventIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> legacyEventIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> legacyEventIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> legacyEventIdGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> legacyEventIdGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> legacyEventIdLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> legacyEventIdLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> legacyEventIdBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceEventIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceEventIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceEventIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceEventIdGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceEventIdGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceEventIdLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceEventIdLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceEventIdBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> occurrenceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> occurrenceIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> occurrenceIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> occurrenceIdGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> occurrenceIdGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> occurrenceIdLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> occurrenceIdLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> occurrenceIdBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceOccurrenceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceOccurrenceIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceOccurrenceIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceOccurrenceIdGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceOccurrenceIdGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceOccurrenceIdLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceOccurrenceIdLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> sourceOccurrenceIdBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> subjectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> subjectIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> subjectIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> subjectIdGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> subjectIdGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> subjectIdLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> subjectIdLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> subjectIdBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      slotKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      slotKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 10,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> slotKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 11,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      candidateOccurrenceIdsContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      candidateOccurrenceIdsMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 11,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> candidateOccurrenceIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 12,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 12,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> eventDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> eventDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> eventDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> eventDateGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> eventDateGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> eventDateLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> eventDateLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> eventDateBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 13,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 14,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 14,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 14,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 14,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 15));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 15));
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 15,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      diagnosticDetailsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 15,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterFilterCondition>
      diagnosticDetailsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 15,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 15,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> diagnosticDetailsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 15,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> createdAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> createdAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 16,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 16,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> updatedAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> updatedAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 17,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 17,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> isDirtyEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 18,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterFilterCondition> isDeletedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 19,
          value: value,
        ),
      );
    });
  }
}

extension MigrationAuditRecordLocalQueryObject on QueryBuilder<
    MigrationAuditRecordLocal, MigrationAuditRecordLocal, QFilterCondition> {}

extension MigrationAuditRecordLocalQuerySortBy on QueryBuilder<
    MigrationAuditRecordLocal, MigrationAuditRecordLocal, QSortBy> {
  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByAuditKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByAuditKeyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByKindDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByAttendanceRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByAttendanceRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByLegacyEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByLegacyEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortBySourceEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortBySourceEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByOccurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByOccurrenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortBySourceOccurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortBySourceOccurrenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortBySlotKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortBySlotKeyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByCandidateOccurrenceIds({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterSortBy>
      sortByCandidateOccurrenceIdsDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByEventDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByEventDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        14,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByReasonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        14,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByDiagnosticDetails({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        15,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByDiagnosticDetailsDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        15,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }
}

extension MigrationAuditRecordLocalQuerySortThenBy on QueryBuilder<
    MigrationAuditRecordLocal, MigrationAuditRecordLocal, QSortThenBy> {
  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByAuditKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByAuditKeyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByKindDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByAttendanceRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByAttendanceRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByLegacyEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByLegacyEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenBySourceEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenBySourceEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByOccurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByOccurrenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenBySourceOccurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenBySourceOccurrenceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenBySlotKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenBySlotKeyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByCandidateOccurrenceIds({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterSortBy>
      thenByCandidateOccurrenceIdsDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByEventDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByEventDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByReasonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByDiagnosticDetails({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByDiagnosticDetailsDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }
}

extension MigrationAuditRecordLocalQueryWhereDistinct on QueryBuilder<
    MigrationAuditRecordLocal, MigrationAuditRecordLocal, QDistinct> {
  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByAuditKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByAttendanceRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByLegacyEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctBySourceEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByOccurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctBySourceOccurrenceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctBySlotKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
          QAfterDistinct>
      distinctByCandidateOccurrenceIds({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByEventDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByDiagnosticDetails({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(15, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(16);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(17);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(18);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, MigrationAuditRecordLocal,
      QAfterDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(19);
    });
  }
}

extension MigrationAuditRecordLocalQueryProperty1 on QueryBuilder<
    MigrationAuditRecordLocal, MigrationAuditRecordLocal, QProperty> {
  QueryBuilder<MigrationAuditRecordLocal, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, String?, QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, String, QAfterProperty>
      auditKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, String, QAfterProperty>
      kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, int?, QAfterProperty>
      attendanceRecordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, int?, QAfterProperty>
      legacyEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, int?, QAfterProperty>
      sourceEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, int?, QAfterProperty>
      occurrenceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, int?, QAfterProperty>
      sourceOccurrenceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, int?, QAfterProperty>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, String?, QAfterProperty>
      slotKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, String?, QAfterProperty>
      candidateOccurrenceIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, String?, QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, DateTime?, QAfterProperty>
      eventDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, String, QAfterProperty>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, String?, QAfterProperty>
      diagnosticDetailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, DateTime, QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, DateTime, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, bool, QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, bool, QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }
}

extension MigrationAuditRecordLocalQueryProperty2<R>
    on QueryBuilder<MigrationAuditRecordLocal, R, QAfterProperty> {
  QueryBuilder<MigrationAuditRecordLocal, (R, int), QAfterProperty>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, String?), QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, String), QAfterProperty>
      auditKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, String), QAfterProperty>
      kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, int?), QAfterProperty>
      attendanceRecordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, int?), QAfterProperty>
      legacyEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, int?), QAfterProperty>
      sourceEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, int?), QAfterProperty>
      occurrenceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, int?), QAfterProperty>
      sourceOccurrenceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, int?), QAfterProperty>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, String?), QAfterProperty>
      slotKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, String?), QAfterProperty>
      candidateOccurrenceIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, String?), QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, DateTime?), QAfterProperty>
      eventDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, String), QAfterProperty>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, String?), QAfterProperty>
      diagnosticDetailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, DateTime), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, bool), QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R, bool), QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }
}

extension MigrationAuditRecordLocalQueryProperty3<R1, R2>
    on QueryBuilder<MigrationAuditRecordLocal, (R1, R2), QAfterProperty> {
  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, int), QOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, String?), QOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, String), QOperations>
      auditKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, String), QOperations>
      kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, int?), QOperations>
      attendanceRecordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, int?), QOperations>
      legacyEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, int?), QOperations>
      sourceEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, int?), QOperations>
      occurrenceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, int?), QOperations>
      sourceOccurrenceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, int?), QOperations>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, String?), QOperations>
      slotKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, String?), QOperations>
      candidateOccurrenceIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, String?), QOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, DateTime?), QOperations>
      eventDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, String), QOperations>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, String?), QOperations>
      diagnosticDetailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, DateTime), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, bool), QOperations>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<MigrationAuditRecordLocal, (R1, R2, bool), QOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }
}
