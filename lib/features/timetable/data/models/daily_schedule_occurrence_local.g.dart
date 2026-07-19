// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_schedule_occurrence_local.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDailyScheduleOccurrenceLocalCollection on Isar {
  IsarCollection<int, DailyScheduleOccurrenceLocal>
      get dailyScheduleOccurrenceLocals => this.collection();
}

const DailyScheduleOccurrenceLocalSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DailyScheduleOccurrenceLocal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'serverId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'date',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'subjectId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'title',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'startTime',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'endTime',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'status',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'createdFrom',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'room',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'faculty',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'reason',
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
        name: 'date',
        properties: [
          "date",
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
    ],
  ),
  converter: IsarObjectConverter<int, DailyScheduleOccurrenceLocal>(
    serialize: serializeDailyScheduleOccurrenceLocal,
    deserialize: deserializeDailyScheduleOccurrenceLocal,
    deserializeProperty: deserializeDailyScheduleOccurrenceLocalProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeDailyScheduleOccurrenceLocal(
    IsarWriter writer, DailyScheduleOccurrenceLocal object) {
  {
    final value = object.serverId;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  IsarCore.writeLong(writer, 2, object.date.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 3, object.subjectId ?? -9223372036854775808);
  IsarCore.writeString(writer, 4, object.title);
  IsarCore.writeString(writer, 5, object.startTime);
  IsarCore.writeString(writer, 6, object.endTime);
  IsarCore.writeString(writer, 7, object.type);
  IsarCore.writeString(writer, 8, object.status);
  IsarCore.writeString(writer, 9, object.createdFrom);
  {
    final value = object.room;
    if (value == null) {
      IsarCore.writeNull(writer, 10);
    } else {
      IsarCore.writeString(writer, 10, value);
    }
  }
  {
    final value = object.faculty;
    if (value == null) {
      IsarCore.writeNull(writer, 11);
    } else {
      IsarCore.writeString(writer, 11, value);
    }
  }
  {
    final value = object.reason;
    if (value == null) {
      IsarCore.writeNull(writer, 12);
    } else {
      IsarCore.writeString(writer, 12, value);
    }
  }
  IsarCore.writeLong(
      writer, 13, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 14, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 15, object.isDirty);
  IsarCore.writeBool(writer, 16, object.isDeleted);
  return object.id;
}

@isarProtected
DailyScheduleOccurrenceLocal deserializeDailyScheduleOccurrenceLocal(
    IsarReader reader) {
  final object = DailyScheduleOccurrenceLocal();
  object.id = IsarCore.readId(reader);
  object.serverId = IsarCore.readString(reader, 1);
  {
    final value = IsarCore.readLong(reader, 2);
    if (value == -9223372036854775808) {
      object.date =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.date =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      object.subjectId = null;
    } else {
      object.subjectId = value;
    }
  }
  object.title = IsarCore.readString(reader, 4) ?? '';
  object.startTime = IsarCore.readString(reader, 5) ?? '';
  object.endTime = IsarCore.readString(reader, 6) ?? '';
  object.type = IsarCore.readString(reader, 7) ?? '';
  object.status = IsarCore.readString(reader, 8) ?? '';
  object.createdFrom = IsarCore.readString(reader, 9) ?? '';
  object.room = IsarCore.readString(reader, 10);
  object.faculty = IsarCore.readString(reader, 11);
  object.reason = IsarCore.readString(reader, 12);
  {
    final value = IsarCore.readLong(reader, 13);
    if (value == -9223372036854775808) {
      object.createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 14);
    if (value == -9223372036854775808) {
      object.updatedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.updatedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.isDirty = IsarCore.readBool(reader, 15);
  object.isDeleted = IsarCore.readBool(reader, 16);
  return object;
}

@isarProtected
dynamic deserializeDailyScheduleOccurrenceLocalProp(
    IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      {
        final value = IsarCore.readLong(reader, 2);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 3:
      {
        final value = IsarCore.readLong(reader, 3);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 4:
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    case 6:
      return IsarCore.readString(reader, 6) ?? '';
    case 7:
      return IsarCore.readString(reader, 7) ?? '';
    case 8:
      return IsarCore.readString(reader, 8) ?? '';
    case 9:
      return IsarCore.readString(reader, 9) ?? '';
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
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 14:
      {
        final value = IsarCore.readLong(reader, 14);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 15:
      return IsarCore.readBool(reader, 15);
    case 16:
      return IsarCore.readBool(reader, 16);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DailyScheduleOccurrenceLocalUpdate {
  bool call({
    required int id,
    String? serverId,
    DateTime? date,
    int? subjectId,
    String? title,
    String? startTime,
    String? endTime,
    String? type,
    String? status,
    String? createdFrom,
    String? room,
    String? faculty,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _DailyScheduleOccurrenceLocalUpdateImpl
    implements _DailyScheduleOccurrenceLocalUpdate {
  const _DailyScheduleOccurrenceLocalUpdateImpl(this.collection);

  final IsarCollection<int, DailyScheduleOccurrenceLocal> collection;

  @override
  bool call({
    required int id,
    Object? serverId = ignore,
    Object? date = ignore,
    Object? subjectId = ignore,
    Object? title = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? type = ignore,
    Object? status = ignore,
    Object? createdFrom = ignore,
    Object? room = ignore,
    Object? faculty = ignore,
    Object? reason = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (serverId != ignore) 1: serverId as String?,
          if (date != ignore) 2: date as DateTime?,
          if (subjectId != ignore) 3: subjectId as int?,
          if (title != ignore) 4: title as String?,
          if (startTime != ignore) 5: startTime as String?,
          if (endTime != ignore) 6: endTime as String?,
          if (type != ignore) 7: type as String?,
          if (status != ignore) 8: status as String?,
          if (createdFrom != ignore) 9: createdFrom as String?,
          if (room != ignore) 10: room as String?,
          if (faculty != ignore) 11: faculty as String?,
          if (reason != ignore) 12: reason as String?,
          if (createdAt != ignore) 13: createdAt as DateTime?,
          if (updatedAt != ignore) 14: updatedAt as DateTime?,
          if (isDirty != ignore) 15: isDirty as bool?,
          if (isDeleted != ignore) 16: isDeleted as bool?,
        }) >
        0;
  }
}

sealed class _DailyScheduleOccurrenceLocalUpdateAll {
  int call({
    required List<int> id,
    String? serverId,
    DateTime? date,
    int? subjectId,
    String? title,
    String? startTime,
    String? endTime,
    String? type,
    String? status,
    String? createdFrom,
    String? room,
    String? faculty,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _DailyScheduleOccurrenceLocalUpdateAllImpl
    implements _DailyScheduleOccurrenceLocalUpdateAll {
  const _DailyScheduleOccurrenceLocalUpdateAllImpl(this.collection);

  final IsarCollection<int, DailyScheduleOccurrenceLocal> collection;

  @override
  int call({
    required List<int> id,
    Object? serverId = ignore,
    Object? date = ignore,
    Object? subjectId = ignore,
    Object? title = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? type = ignore,
    Object? status = ignore,
    Object? createdFrom = ignore,
    Object? room = ignore,
    Object? faculty = ignore,
    Object? reason = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties(id, {
      if (serverId != ignore) 1: serverId as String?,
      if (date != ignore) 2: date as DateTime?,
      if (subjectId != ignore) 3: subjectId as int?,
      if (title != ignore) 4: title as String?,
      if (startTime != ignore) 5: startTime as String?,
      if (endTime != ignore) 6: endTime as String?,
      if (type != ignore) 7: type as String?,
      if (status != ignore) 8: status as String?,
      if (createdFrom != ignore) 9: createdFrom as String?,
      if (room != ignore) 10: room as String?,
      if (faculty != ignore) 11: faculty as String?,
      if (reason != ignore) 12: reason as String?,
      if (createdAt != ignore) 13: createdAt as DateTime?,
      if (updatedAt != ignore) 14: updatedAt as DateTime?,
      if (isDirty != ignore) 15: isDirty as bool?,
      if (isDeleted != ignore) 16: isDeleted as bool?,
    });
  }
}

extension DailyScheduleOccurrenceLocalUpdate
    on IsarCollection<int, DailyScheduleOccurrenceLocal> {
  _DailyScheduleOccurrenceLocalUpdate get update =>
      _DailyScheduleOccurrenceLocalUpdateImpl(this);

  _DailyScheduleOccurrenceLocalUpdateAll get updateAll =>
      _DailyScheduleOccurrenceLocalUpdateAllImpl(this);
}

sealed class _DailyScheduleOccurrenceLocalQueryUpdate {
  int call({
    String? serverId,
    DateTime? date,
    int? subjectId,
    String? title,
    String? startTime,
    String? endTime,
    String? type,
    String? status,
    String? createdFrom,
    String? room,
    String? faculty,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _DailyScheduleOccurrenceLocalQueryUpdateImpl
    implements _DailyScheduleOccurrenceLocalQueryUpdate {
  const _DailyScheduleOccurrenceLocalQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DailyScheduleOccurrenceLocal> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? date = ignore,
    Object? subjectId = ignore,
    Object? title = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? type = ignore,
    Object? status = ignore,
    Object? createdFrom = ignore,
    Object? room = ignore,
    Object? faculty = ignore,
    Object? reason = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (serverId != ignore) 1: serverId as String?,
      if (date != ignore) 2: date as DateTime?,
      if (subjectId != ignore) 3: subjectId as int?,
      if (title != ignore) 4: title as String?,
      if (startTime != ignore) 5: startTime as String?,
      if (endTime != ignore) 6: endTime as String?,
      if (type != ignore) 7: type as String?,
      if (status != ignore) 8: status as String?,
      if (createdFrom != ignore) 9: createdFrom as String?,
      if (room != ignore) 10: room as String?,
      if (faculty != ignore) 11: faculty as String?,
      if (reason != ignore) 12: reason as String?,
      if (createdAt != ignore) 13: createdAt as DateTime?,
      if (updatedAt != ignore) 14: updatedAt as DateTime?,
      if (isDirty != ignore) 15: isDirty as bool?,
      if (isDeleted != ignore) 16: isDeleted as bool?,
    });
  }
}

extension DailyScheduleOccurrenceLocalQueryUpdate
    on IsarQuery<DailyScheduleOccurrenceLocal> {
  _DailyScheduleOccurrenceLocalQueryUpdate get updateFirst =>
      _DailyScheduleOccurrenceLocalQueryUpdateImpl(this, limit: 1);

  _DailyScheduleOccurrenceLocalQueryUpdate get updateAll =>
      _DailyScheduleOccurrenceLocalQueryUpdateImpl(this);
}

class _DailyScheduleOccurrenceLocalQueryBuilderUpdateImpl
    implements _DailyScheduleOccurrenceLocalQueryUpdate {
  const _DailyScheduleOccurrenceLocalQueryBuilderUpdateImpl(this.query,
      {this.limit});

  final QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QOperations> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? date = ignore,
    Object? subjectId = ignore,
    Object? title = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? type = ignore,
    Object? status = ignore,
    Object? createdFrom = ignore,
    Object? room = ignore,
    Object? faculty = ignore,
    Object? reason = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (serverId != ignore) 1: serverId as String?,
        if (date != ignore) 2: date as DateTime?,
        if (subjectId != ignore) 3: subjectId as int?,
        if (title != ignore) 4: title as String?,
        if (startTime != ignore) 5: startTime as String?,
        if (endTime != ignore) 6: endTime as String?,
        if (type != ignore) 7: type as String?,
        if (status != ignore) 8: status as String?,
        if (createdFrom != ignore) 9: createdFrom as String?,
        if (room != ignore) 10: room as String?,
        if (faculty != ignore) 11: faculty as String?,
        if (reason != ignore) 12: reason as String?,
        if (createdAt != ignore) 13: createdAt as DateTime?,
        if (updatedAt != ignore) 14: updatedAt as DateTime?,
        if (isDirty != ignore) 15: isDirty as bool?,
        if (isDeleted != ignore) 16: isDeleted as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension DailyScheduleOccurrenceLocalQueryBuilderUpdate on QueryBuilder<
    DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal, QOperations> {
  _DailyScheduleOccurrenceLocalQueryUpdate get updateFirst =>
      _DailyScheduleOccurrenceLocalQueryBuilderUpdateImpl(this, limit: 1);

  _DailyScheduleOccurrenceLocalQueryUpdate get updateAll =>
      _DailyScheduleOccurrenceLocalQueryBuilderUpdateImpl(this);
}

extension DailyScheduleOccurrenceLocalQueryFilter on QueryBuilder<
    DailyScheduleOccurrenceLocal,
    DailyScheduleOccurrenceLocal,
    QFilterCondition> {
  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> serverIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> dateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> dateGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> dateGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> dateLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> dateLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> subjectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> subjectIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> subjectIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> subjectIdGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> subjectIdGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> subjectIdLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> subjectIdLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> subjectIdBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      startTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      startTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> startTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      endTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      endTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> endTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 8,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      createdFromContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      createdFromMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 9,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 9,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdFromIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 9,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomEqualTo(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomGreaterThan(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomGreaterThanOrEqualTo(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomLessThan(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomLessThanOrEqualTo(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomBetween(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomStartsWith(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomEndsWith(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      roomContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      roomMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> roomIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyEqualTo(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyGreaterThan(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyGreaterThanOrEqualTo(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyLessThan(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyLessThanOrEqualTo(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyBetween(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyStartsWith(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyEndsWith(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      facultyContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      facultyMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> facultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonEqualTo(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonGreaterThan(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonGreaterThanOrEqualTo(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonLessThan(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonLessThanOrEqualTo(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonBetween(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonStartsWith(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonEndsWith(
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
          QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> updatedAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> updatedAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 14,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> isDirtyEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 15,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterFilterCondition> isDeletedEqualTo(
    bool value,
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
}

extension DailyScheduleOccurrenceLocalQueryObject on QueryBuilder<
    DailyScheduleOccurrenceLocal,
    DailyScheduleOccurrenceLocal,
    QFilterCondition> {}

extension DailyScheduleOccurrenceLocalQuerySortBy on QueryBuilder<
    DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal, QSortBy> {
  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByStartTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByStartTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByEndTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByCreatedFrom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        9,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByCreatedFromDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        9,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByRoom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByRoomDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByFaculty({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByFacultyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByReasonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }
}

extension DailyScheduleOccurrenceLocalQuerySortThenBy on QueryBuilder<
    DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal, QSortThenBy> {
  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByStartTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByStartTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByEndTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByCreatedFrom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByCreatedFromDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByRoom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByRoomDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByFaculty({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByFacultyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByReasonDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }
}

extension DailyScheduleOccurrenceLocalQueryWhereDistinct on QueryBuilder<
    DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal, QDistinct> {
  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByStartTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByCreatedFrom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByRoom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByFaculty({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(15);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal,
      QAfterDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(16);
    });
  }
}

extension DailyScheduleOccurrenceLocalQueryProperty1 on QueryBuilder<
    DailyScheduleOccurrenceLocal, DailyScheduleOccurrenceLocal, QProperty> {
  QueryBuilder<DailyScheduleOccurrenceLocal, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String?, QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DateTime, QAfterProperty>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, int?, QAfterProperty>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String, QAfterProperty>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String, QAfterProperty>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String, QAfterProperty>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String, QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String, QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String, QAfterProperty>
      createdFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String?, QAfterProperty>
      roomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String?, QAfterProperty>
      facultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, String?, QAfterProperty>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DateTime, QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, DateTime, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, bool, QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, bool, QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }
}

extension DailyScheduleOccurrenceLocalQueryProperty2<R>
    on QueryBuilder<DailyScheduleOccurrenceLocal, R, QAfterProperty> {
  QueryBuilder<DailyScheduleOccurrenceLocal, (R, int), QAfterProperty>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String?), QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, DateTime), QAfterProperty>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, int?), QAfterProperty>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String), QAfterProperty>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String), QAfterProperty>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String), QAfterProperty>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String), QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String), QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String), QAfterProperty>
      createdFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String?), QAfterProperty>
      roomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String?), QAfterProperty>
      facultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, String?), QAfterProperty>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, DateTime), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, bool), QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R, bool), QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }
}

extension DailyScheduleOccurrenceLocalQueryProperty3<R1, R2>
    on QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2), QAfterProperty> {
  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, int), QOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String?), QOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, DateTime), QOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, int?), QOperations>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String), QOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String), QOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String), QOperations>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String), QOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String), QOperations>
      createdFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String?), QOperations>
      roomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String?), QOperations>
      facultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, String?), QOperations>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, DateTime), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, bool), QOperations>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<DailyScheduleOccurrenceLocal, (R1, R2, bool), QOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }
}
