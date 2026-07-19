// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_schedule_rule_local.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetWeeklyScheduleRuleLocalCollection on Isar {
  IsarCollection<int, WeeklyScheduleRuleLocal> get weeklyScheduleRuleLocals =>
      this.collection();
}

const WeeklyScheduleRuleLocalSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'WeeklyScheduleRuleLocal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'serverId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'subjectId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'dayOfWeek',
        type: IsarType.long,
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
        name: 'room',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'faculty',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'isActive',
        type: IsarType.bool,
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
        name: 'subjectId',
        properties: [
          "subjectId",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'dayOfWeek',
        properties: [
          "dayOfWeek",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, WeeklyScheduleRuleLocal>(
    serialize: serializeWeeklyScheduleRuleLocal,
    deserialize: deserializeWeeklyScheduleRuleLocal,
    deserializeProperty: deserializeWeeklyScheduleRuleLocalProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeWeeklyScheduleRuleLocal(
    IsarWriter writer, WeeklyScheduleRuleLocal object) {
  {
    final value = object.serverId;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  IsarCore.writeLong(writer, 2, object.subjectId);
  IsarCore.writeLong(writer, 3, object.dayOfWeek);
  IsarCore.writeString(writer, 4, object.startTime);
  IsarCore.writeString(writer, 5, object.endTime);
  {
    final value = object.room;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  {
    final value = object.faculty;
    if (value == null) {
      IsarCore.writeNull(writer, 7);
    } else {
      IsarCore.writeString(writer, 7, value);
    }
  }
  IsarCore.writeString(writer, 8, object.type);
  IsarCore.writeBool(writer, 9, object.isActive);
  IsarCore.writeLong(
      writer, 10, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 11, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 12, object.isDirty);
  IsarCore.writeBool(writer, 13, object.isDeleted);
  return object.id;
}

@isarProtected
WeeklyScheduleRuleLocal deserializeWeeklyScheduleRuleLocal(IsarReader reader) {
  final object = WeeklyScheduleRuleLocal();
  object.id = IsarCore.readId(reader);
  object.serverId = IsarCore.readString(reader, 1);
  object.subjectId = IsarCore.readLong(reader, 2);
  object.dayOfWeek = IsarCore.readLong(reader, 3);
  object.startTime = IsarCore.readString(reader, 4) ?? '';
  object.endTime = IsarCore.readString(reader, 5) ?? '';
  object.room = IsarCore.readString(reader, 6);
  object.faculty = IsarCore.readString(reader, 7);
  object.type = IsarCore.readString(reader, 8) ?? '';
  object.isActive = IsarCore.readBool(reader, 9);
  {
    final value = IsarCore.readLong(reader, 10);
    if (value == -9223372036854775808) {
      object.createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 11);
    if (value == -9223372036854775808) {
      object.updatedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.updatedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.isDirty = IsarCore.readBool(reader, 12);
  object.isDeleted = IsarCore.readBool(reader, 13);
  return object;
}

@isarProtected
dynamic deserializeWeeklyScheduleRuleLocalProp(
    IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      return IsarCore.readLong(reader, 2);
    case 3:
      return IsarCore.readLong(reader, 3);
    case 4:
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    case 6:
      return IsarCore.readString(reader, 6);
    case 7:
      return IsarCore.readString(reader, 7);
    case 8:
      return IsarCore.readString(reader, 8) ?? '';
    case 9:
      return IsarCore.readBool(reader, 9);
    case 10:
      {
        final value = IsarCore.readLong(reader, 10);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 11:
      {
        final value = IsarCore.readLong(reader, 11);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 12:
      return IsarCore.readBool(reader, 12);
    case 13:
      return IsarCore.readBool(reader, 13);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _WeeklyScheduleRuleLocalUpdate {
  bool call({
    required int id,
    String? serverId,
    int? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? faculty,
    String? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _WeeklyScheduleRuleLocalUpdateImpl
    implements _WeeklyScheduleRuleLocalUpdate {
  const _WeeklyScheduleRuleLocalUpdateImpl(this.collection);

  final IsarCollection<int, WeeklyScheduleRuleLocal> collection;

  @override
  bool call({
    required int id,
    Object? serverId = ignore,
    Object? subjectId = ignore,
    Object? dayOfWeek = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? room = ignore,
    Object? faculty = ignore,
    Object? type = ignore,
    Object? isActive = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (serverId != ignore) 1: serverId as String?,
          if (subjectId != ignore) 2: subjectId as int?,
          if (dayOfWeek != ignore) 3: dayOfWeek as int?,
          if (startTime != ignore) 4: startTime as String?,
          if (endTime != ignore) 5: endTime as String?,
          if (room != ignore) 6: room as String?,
          if (faculty != ignore) 7: faculty as String?,
          if (type != ignore) 8: type as String?,
          if (isActive != ignore) 9: isActive as bool?,
          if (createdAt != ignore) 10: createdAt as DateTime?,
          if (updatedAt != ignore) 11: updatedAt as DateTime?,
          if (isDirty != ignore) 12: isDirty as bool?,
          if (isDeleted != ignore) 13: isDeleted as bool?,
        }) >
        0;
  }
}

sealed class _WeeklyScheduleRuleLocalUpdateAll {
  int call({
    required List<int> id,
    String? serverId,
    int? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? faculty,
    String? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _WeeklyScheduleRuleLocalUpdateAllImpl
    implements _WeeklyScheduleRuleLocalUpdateAll {
  const _WeeklyScheduleRuleLocalUpdateAllImpl(this.collection);

  final IsarCollection<int, WeeklyScheduleRuleLocal> collection;

  @override
  int call({
    required List<int> id,
    Object? serverId = ignore,
    Object? subjectId = ignore,
    Object? dayOfWeek = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? room = ignore,
    Object? faculty = ignore,
    Object? type = ignore,
    Object? isActive = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties(id, {
      if (serverId != ignore) 1: serverId as String?,
      if (subjectId != ignore) 2: subjectId as int?,
      if (dayOfWeek != ignore) 3: dayOfWeek as int?,
      if (startTime != ignore) 4: startTime as String?,
      if (endTime != ignore) 5: endTime as String?,
      if (room != ignore) 6: room as String?,
      if (faculty != ignore) 7: faculty as String?,
      if (type != ignore) 8: type as String?,
      if (isActive != ignore) 9: isActive as bool?,
      if (createdAt != ignore) 10: createdAt as DateTime?,
      if (updatedAt != ignore) 11: updatedAt as DateTime?,
      if (isDirty != ignore) 12: isDirty as bool?,
      if (isDeleted != ignore) 13: isDeleted as bool?,
    });
  }
}

extension WeeklyScheduleRuleLocalUpdate
    on IsarCollection<int, WeeklyScheduleRuleLocal> {
  _WeeklyScheduleRuleLocalUpdate get update =>
      _WeeklyScheduleRuleLocalUpdateImpl(this);

  _WeeklyScheduleRuleLocalUpdateAll get updateAll =>
      _WeeklyScheduleRuleLocalUpdateAllImpl(this);
}

sealed class _WeeklyScheduleRuleLocalQueryUpdate {
  int call({
    String? serverId,
    int? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? faculty,
    String? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _WeeklyScheduleRuleLocalQueryUpdateImpl
    implements _WeeklyScheduleRuleLocalQueryUpdate {
  const _WeeklyScheduleRuleLocalQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<WeeklyScheduleRuleLocal> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? subjectId = ignore,
    Object? dayOfWeek = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? room = ignore,
    Object? faculty = ignore,
    Object? type = ignore,
    Object? isActive = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (serverId != ignore) 1: serverId as String?,
      if (subjectId != ignore) 2: subjectId as int?,
      if (dayOfWeek != ignore) 3: dayOfWeek as int?,
      if (startTime != ignore) 4: startTime as String?,
      if (endTime != ignore) 5: endTime as String?,
      if (room != ignore) 6: room as String?,
      if (faculty != ignore) 7: faculty as String?,
      if (type != ignore) 8: type as String?,
      if (isActive != ignore) 9: isActive as bool?,
      if (createdAt != ignore) 10: createdAt as DateTime?,
      if (updatedAt != ignore) 11: updatedAt as DateTime?,
      if (isDirty != ignore) 12: isDirty as bool?,
      if (isDeleted != ignore) 13: isDeleted as bool?,
    });
  }
}

extension WeeklyScheduleRuleLocalQueryUpdate
    on IsarQuery<WeeklyScheduleRuleLocal> {
  _WeeklyScheduleRuleLocalQueryUpdate get updateFirst =>
      _WeeklyScheduleRuleLocalQueryUpdateImpl(this, limit: 1);

  _WeeklyScheduleRuleLocalQueryUpdate get updateAll =>
      _WeeklyScheduleRuleLocalQueryUpdateImpl(this);
}

class _WeeklyScheduleRuleLocalQueryBuilderUpdateImpl
    implements _WeeklyScheduleRuleLocalQueryUpdate {
  const _WeeklyScheduleRuleLocalQueryBuilderUpdateImpl(this.query,
      {this.limit});

  final QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QOperations> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? subjectId = ignore,
    Object? dayOfWeek = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? room = ignore,
    Object? faculty = ignore,
    Object? type = ignore,
    Object? isActive = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (serverId != ignore) 1: serverId as String?,
        if (subjectId != ignore) 2: subjectId as int?,
        if (dayOfWeek != ignore) 3: dayOfWeek as int?,
        if (startTime != ignore) 4: startTime as String?,
        if (endTime != ignore) 5: endTime as String?,
        if (room != ignore) 6: room as String?,
        if (faculty != ignore) 7: faculty as String?,
        if (type != ignore) 8: type as String?,
        if (isActive != ignore) 9: isActive as bool?,
        if (createdAt != ignore) 10: createdAt as DateTime?,
        if (updatedAt != ignore) 11: updatedAt as DateTime?,
        if (isDirty != ignore) 12: isDirty as bool?,
        if (isDeleted != ignore) 13: isDeleted as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension WeeklyScheduleRuleLocalQueryBuilderUpdate on QueryBuilder<
    WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QOperations> {
  _WeeklyScheduleRuleLocalQueryUpdate get updateFirst =>
      _WeeklyScheduleRuleLocalQueryBuilderUpdateImpl(this, limit: 1);

  _WeeklyScheduleRuleLocalQueryUpdate get updateAll =>
      _WeeklyScheduleRuleLocalQueryBuilderUpdateImpl(this);
}

extension WeeklyScheduleRuleLocalQueryFilter on QueryBuilder<
    WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QFilterCondition> {
  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> serverIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> subjectIdEqualTo(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> subjectIdGreaterThan(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> subjectIdGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> subjectIdLessThan(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> subjectIdLessThanOrEqualTo(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> subjectIdBetween(
    int lower,
    int upper,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> dayOfWeekEqualTo(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> dayOfWeekGreaterThan(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> dayOfWeekGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> dayOfWeekLessThan(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> dayOfWeekLessThanOrEqualTo(
    int value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> dayOfWeekBetween(
    int lower,
    int upper,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeEqualTo(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeGreaterThan(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeGreaterThanOrEqualTo(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeLessThan(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeLessThanOrEqualTo(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeBetween(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeStartsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeEndsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      startTimeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      startTimeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> startTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeEqualTo(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeGreaterThan(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeGreaterThanOrEqualTo(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeLessThan(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeLessThanOrEqualTo(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeBetween(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeStartsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeEndsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      endTimeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      endTimeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> endTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomEqualTo(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomGreaterThan(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomLessThan(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomStartsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomEndsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      roomContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      roomMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> roomIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyEqualTo(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyGreaterThan(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyLessThan(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyStartsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyEndsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      facultyContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      facultyMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> facultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeGreaterThan(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeGreaterThanOrEqualTo(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeLessThanOrEqualTo(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeBetween(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeStartsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> isActiveEqualTo(
    bool value,
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

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> createdAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> createdAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> updatedAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> updatedAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 11,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> isDirtyEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal,
      QAfterFilterCondition> isDeletedEqualTo(
    bool value,
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
}

extension WeeklyScheduleRuleLocalQueryObject on QueryBuilder<
    WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QFilterCondition> {}

extension WeeklyScheduleRuleLocalQuerySortBy
    on QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QSortBy> {
  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByStartTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByStartTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByEndTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByRoom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByRoomDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByFaculty({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByFacultyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }
}

extension WeeklyScheduleRuleLocalQuerySortThenBy on QueryBuilder<
    WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QSortThenBy> {
  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByDayOfWeekDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByStartTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByStartTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByEndTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByRoom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByRoomDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByFaculty({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByFacultyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }
}

extension WeeklyScheduleRuleLocalQueryWhereDistinct on QueryBuilder<
    WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QDistinct> {
  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByDayOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByStartTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByRoom({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByFaculty({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QAfterDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }
}

extension WeeklyScheduleRuleLocalQueryProperty1 on QueryBuilder<
    WeeklyScheduleRuleLocal, WeeklyScheduleRuleLocal, QProperty> {
  QueryBuilder<WeeklyScheduleRuleLocal, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, String?, QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, int, QAfterProperty>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, int, QAfterProperty>
      dayOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, String, QAfterProperty>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, String, QAfterProperty>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, String?, QAfterProperty>
      roomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, String?, QAfterProperty>
      facultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, String, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, bool, QAfterProperty>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, DateTime, QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, DateTime, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, bool, QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, bool, QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }
}

extension WeeklyScheduleRuleLocalQueryProperty2<R>
    on QueryBuilder<WeeklyScheduleRuleLocal, R, QAfterProperty> {
  QueryBuilder<WeeklyScheduleRuleLocal, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, String?), QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, int), QAfterProperty>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, int), QAfterProperty>
      dayOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, String), QAfterProperty>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, String), QAfterProperty>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, String?), QAfterProperty>
      roomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, String?), QAfterProperty>
      facultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, String), QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, bool), QAfterProperty>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, DateTime), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, bool), QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R, bool), QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }
}

extension WeeklyScheduleRuleLocalQueryProperty3<R1, R2>
    on QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2), QAfterProperty> {
  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, int), QOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, String?), QOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, int), QOperations>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, int), QOperations>
      dayOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, String), QOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, String), QOperations>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, String?), QOperations>
      roomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, String?), QOperations>
      facultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, String), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, bool), QOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, DateTime), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, bool), QOperations>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<WeeklyScheduleRuleLocal, (R1, R2, bool), QOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }
}
