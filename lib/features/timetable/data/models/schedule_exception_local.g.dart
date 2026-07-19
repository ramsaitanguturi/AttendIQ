// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_exception_local.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetScheduleExceptionLocalCollection on Isar {
  IsarCollection<int, ScheduleExceptionLocal> get scheduleExceptionLocals =>
      this.collection();
}

const ScheduleExceptionLocalSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'ScheduleExceptionLocal',
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
        name: 'type',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'title',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'description',
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
  converter: IsarObjectConverter<int, ScheduleExceptionLocal>(
    serialize: serializeScheduleExceptionLocal,
    deserialize: deserializeScheduleExceptionLocal,
    deserializeProperty: deserializeScheduleExceptionLocalProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeScheduleExceptionLocal(
    IsarWriter writer, ScheduleExceptionLocal object) {
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
  IsarCore.writeString(writer, 4, object.type);
  IsarCore.writeString(writer, 5, object.title);
  {
    final value = object.description;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  IsarCore.writeLong(
      writer, 7, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 8, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 9, object.isDirty);
  IsarCore.writeBool(writer, 10, object.isDeleted);
  return object.id;
}

@isarProtected
ScheduleExceptionLocal deserializeScheduleExceptionLocal(IsarReader reader) {
  final object = ScheduleExceptionLocal();
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
  object.type = IsarCore.readString(reader, 4) ?? '';
  object.title = IsarCore.readString(reader, 5) ?? '';
  object.description = IsarCore.readString(reader, 6);
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      object.createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      object.updatedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.updatedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.isDirty = IsarCore.readBool(reader, 9);
  object.isDeleted = IsarCore.readBool(reader, 10);
  return object;
}

@isarProtected
dynamic deserializeScheduleExceptionLocalProp(IsarReader reader, int property) {
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
      return IsarCore.readString(reader, 6);
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 9:
      return IsarCore.readBool(reader, 9);
    case 10:
      return IsarCore.readBool(reader, 10);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _ScheduleExceptionLocalUpdate {
  bool call({
    required int id,
    String? serverId,
    DateTime? date,
    int? subjectId,
    String? type,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _ScheduleExceptionLocalUpdateImpl
    implements _ScheduleExceptionLocalUpdate {
  const _ScheduleExceptionLocalUpdateImpl(this.collection);

  final IsarCollection<int, ScheduleExceptionLocal> collection;

  @override
  bool call({
    required int id,
    Object? serverId = ignore,
    Object? date = ignore,
    Object? subjectId = ignore,
    Object? type = ignore,
    Object? title = ignore,
    Object? description = ignore,
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
          if (type != ignore) 4: type as String?,
          if (title != ignore) 5: title as String?,
          if (description != ignore) 6: description as String?,
          if (createdAt != ignore) 7: createdAt as DateTime?,
          if (updatedAt != ignore) 8: updatedAt as DateTime?,
          if (isDirty != ignore) 9: isDirty as bool?,
          if (isDeleted != ignore) 10: isDeleted as bool?,
        }) >
        0;
  }
}

sealed class _ScheduleExceptionLocalUpdateAll {
  int call({
    required List<int> id,
    String? serverId,
    DateTime? date,
    int? subjectId,
    String? type,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _ScheduleExceptionLocalUpdateAllImpl
    implements _ScheduleExceptionLocalUpdateAll {
  const _ScheduleExceptionLocalUpdateAllImpl(this.collection);

  final IsarCollection<int, ScheduleExceptionLocal> collection;

  @override
  int call({
    required List<int> id,
    Object? serverId = ignore,
    Object? date = ignore,
    Object? subjectId = ignore,
    Object? type = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties(id, {
      if (serverId != ignore) 1: serverId as String?,
      if (date != ignore) 2: date as DateTime?,
      if (subjectId != ignore) 3: subjectId as int?,
      if (type != ignore) 4: type as String?,
      if (title != ignore) 5: title as String?,
      if (description != ignore) 6: description as String?,
      if (createdAt != ignore) 7: createdAt as DateTime?,
      if (updatedAt != ignore) 8: updatedAt as DateTime?,
      if (isDirty != ignore) 9: isDirty as bool?,
      if (isDeleted != ignore) 10: isDeleted as bool?,
    });
  }
}

extension ScheduleExceptionLocalUpdate
    on IsarCollection<int, ScheduleExceptionLocal> {
  _ScheduleExceptionLocalUpdate get update =>
      _ScheduleExceptionLocalUpdateImpl(this);

  _ScheduleExceptionLocalUpdateAll get updateAll =>
      _ScheduleExceptionLocalUpdateAllImpl(this);
}

sealed class _ScheduleExceptionLocalQueryUpdate {
  int call({
    String? serverId,
    DateTime? date,
    int? subjectId,
    String? type,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _ScheduleExceptionLocalQueryUpdateImpl
    implements _ScheduleExceptionLocalQueryUpdate {
  const _ScheduleExceptionLocalQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<ScheduleExceptionLocal> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? date = ignore,
    Object? subjectId = ignore,
    Object? type = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (serverId != ignore) 1: serverId as String?,
      if (date != ignore) 2: date as DateTime?,
      if (subjectId != ignore) 3: subjectId as int?,
      if (type != ignore) 4: type as String?,
      if (title != ignore) 5: title as String?,
      if (description != ignore) 6: description as String?,
      if (createdAt != ignore) 7: createdAt as DateTime?,
      if (updatedAt != ignore) 8: updatedAt as DateTime?,
      if (isDirty != ignore) 9: isDirty as bool?,
      if (isDeleted != ignore) 10: isDeleted as bool?,
    });
  }
}

extension ScheduleExceptionLocalQueryUpdate
    on IsarQuery<ScheduleExceptionLocal> {
  _ScheduleExceptionLocalQueryUpdate get updateFirst =>
      _ScheduleExceptionLocalQueryUpdateImpl(this, limit: 1);

  _ScheduleExceptionLocalQueryUpdate get updateAll =>
      _ScheduleExceptionLocalQueryUpdateImpl(this);
}

class _ScheduleExceptionLocalQueryBuilderUpdateImpl
    implements _ScheduleExceptionLocalQueryUpdate {
  const _ScheduleExceptionLocalQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QOperations> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? date = ignore,
    Object? subjectId = ignore,
    Object? type = ignore,
    Object? title = ignore,
    Object? description = ignore,
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
        if (type != ignore) 4: type as String?,
        if (title != ignore) 5: title as String?,
        if (description != ignore) 6: description as String?,
        if (createdAt != ignore) 7: createdAt as DateTime?,
        if (updatedAt != ignore) 8: updatedAt as DateTime?,
        if (isDirty != ignore) 9: isDirty as bool?,
        if (isDeleted != ignore) 10: isDeleted as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension ScheduleExceptionLocalQueryBuilderUpdate on QueryBuilder<
    ScheduleExceptionLocal, ScheduleExceptionLocal, QOperations> {
  _ScheduleExceptionLocalQueryUpdate get updateFirst =>
      _ScheduleExceptionLocalQueryBuilderUpdateImpl(this, limit: 1);

  _ScheduleExceptionLocalQueryUpdate get updateAll =>
      _ScheduleExceptionLocalQueryBuilderUpdateImpl(this);
}

extension ScheduleExceptionLocalQueryFilter on QueryBuilder<
    ScheduleExceptionLocal, ScheduleExceptionLocal, QFilterCondition> {
  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> serverIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> subjectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> subjectIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeGreaterThan(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeGreaterThanOrEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeLessThanOrEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeBetween(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeStartsWith(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeEndsWith(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleGreaterThanOrEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleLessThanOrEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleBetween(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleStartsWith(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleEndsWith(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
          QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
          QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionGreaterThan(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionGreaterThanOrEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionLessThan(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionLessThanOrEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionBetween(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionStartsWith(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionEndsWith(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
          QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
          QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> createdAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> createdAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> updatedAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> updatedAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> isDirtyEqualTo(
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

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal,
      QAfterFilterCondition> isDeletedEqualTo(
    bool value,
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
}

extension ScheduleExceptionLocalQueryObject on QueryBuilder<
    ScheduleExceptionLocal, ScheduleExceptionLocal, QFilterCondition> {}

extension ScheduleExceptionLocalQuerySortBy
    on QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QSortBy> {
  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension ScheduleExceptionLocalQuerySortThenBy on QueryBuilder<
    ScheduleExceptionLocal, ScheduleExceptionLocal, QSortThenBy> {
  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension ScheduleExceptionLocalQueryWhereDistinct
    on QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QDistinct> {
  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QAfterDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }
}

extension ScheduleExceptionLocalQueryProperty1
    on QueryBuilder<ScheduleExceptionLocal, ScheduleExceptionLocal, QProperty> {
  QueryBuilder<ScheduleExceptionLocal, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, String?, QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, DateTime, QAfterProperty>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, int?, QAfterProperty>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, String, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, String?, QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, DateTime, QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, DateTime, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, bool, QAfterProperty> isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, bool, QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension ScheduleExceptionLocalQueryProperty2<R>
    on QueryBuilder<ScheduleExceptionLocal, R, QAfterProperty> {
  QueryBuilder<ScheduleExceptionLocal, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, String?), QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, DateTime), QAfterProperty>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, int?), QAfterProperty>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, String), QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, String), QAfterProperty>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, String?), QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, DateTime), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, bool), QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R, bool), QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension ScheduleExceptionLocalQueryProperty3<R1, R2>
    on QueryBuilder<ScheduleExceptionLocal, (R1, R2), QAfterProperty> {
  QueryBuilder<ScheduleExceptionLocal, (R1, R2, int), QOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, String?), QOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, DateTime), QOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, int?), QOperations>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, String), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, String), QOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, String?), QOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, DateTime), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, bool), QOperations>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<ScheduleExceptionLocal, (R1, R2, bool), QOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}
