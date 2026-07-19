// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_event_local.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetAcademicEventLocalCollection on Isar {
  IsarCollection<int, AcademicEventLocal> get academicEventLocals =>
      this.collection();
}

const AcademicEventLocalSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'AcademicEventLocal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'serverId',
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
        name: 'date',
        type: IsarType.dateTime,
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
    ],
  ),
  converter: IsarObjectConverter<int, AcademicEventLocal>(
    serialize: serializeAcademicEventLocal,
    deserialize: deserializeAcademicEventLocal,
    deserializeProperty: deserializeAcademicEventLocalProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeAcademicEventLocal(IsarWriter writer, AcademicEventLocal object) {
  {
    final value = object.serverId;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  IsarCore.writeString(writer, 2, object.title);
  {
    final value = object.description;
    if (value == null) {
      IsarCore.writeNull(writer, 3);
    } else {
      IsarCore.writeString(writer, 3, value);
    }
  }
  IsarCore.writeLong(writer, 4, object.date.toUtc().microsecondsSinceEpoch);
  {
    final value = object.startTime;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeString(writer, 5, value);
    }
  }
  {
    final value = object.endTime;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeString(writer, 6, value);
    }
  }
  IsarCore.writeString(writer, 7, object.type);
  IsarCore.writeLong(
      writer, 8, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 9, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 10, object.isDirty);
  IsarCore.writeBool(writer, 11, object.isDeleted);
  return object.id;
}

@isarProtected
AcademicEventLocal deserializeAcademicEventLocal(IsarReader reader) {
  final object = AcademicEventLocal();
  object.id = IsarCore.readId(reader);
  object.serverId = IsarCore.readString(reader, 1);
  object.title = IsarCore.readString(reader, 2) ?? '';
  object.description = IsarCore.readString(reader, 3);
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      object.date =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.date =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.startTime = IsarCore.readString(reader, 5);
  object.endTime = IsarCore.readString(reader, 6);
  object.type = IsarCore.readString(reader, 7) ?? '';
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      object.createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      object.updatedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.updatedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.isDirty = IsarCore.readBool(reader, 10);
  object.isDeleted = IsarCore.readBool(reader, 11);
  return object;
}

@isarProtected
dynamic deserializeAcademicEventLocalProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3);
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 5:
      return IsarCore.readString(reader, 5);
    case 6:
      return IsarCore.readString(reader, 6);
    case 7:
      return IsarCore.readString(reader, 7) ?? '';
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
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 10:
      return IsarCore.readBool(reader, 10);
    case 11:
      return IsarCore.readBool(reader, 11);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _AcademicEventLocalUpdate {
  bool call({
    required int id,
    String? serverId,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _AcademicEventLocalUpdateImpl implements _AcademicEventLocalUpdate {
  const _AcademicEventLocalUpdateImpl(this.collection);

  final IsarCollection<int, AcademicEventLocal> collection;

  @override
  bool call({
    required int id,
    Object? serverId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? date = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? type = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (serverId != ignore) 1: serverId as String?,
          if (title != ignore) 2: title as String?,
          if (description != ignore) 3: description as String?,
          if (date != ignore) 4: date as DateTime?,
          if (startTime != ignore) 5: startTime as String?,
          if (endTime != ignore) 6: endTime as String?,
          if (type != ignore) 7: type as String?,
          if (createdAt != ignore) 8: createdAt as DateTime?,
          if (updatedAt != ignore) 9: updatedAt as DateTime?,
          if (isDirty != ignore) 10: isDirty as bool?,
          if (isDeleted != ignore) 11: isDeleted as bool?,
        }) >
        0;
  }
}

sealed class _AcademicEventLocalUpdateAll {
  int call({
    required List<int> id,
    String? serverId,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _AcademicEventLocalUpdateAllImpl implements _AcademicEventLocalUpdateAll {
  const _AcademicEventLocalUpdateAllImpl(this.collection);

  final IsarCollection<int, AcademicEventLocal> collection;

  @override
  int call({
    required List<int> id,
    Object? serverId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? date = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? type = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties(id, {
      if (serverId != ignore) 1: serverId as String?,
      if (title != ignore) 2: title as String?,
      if (description != ignore) 3: description as String?,
      if (date != ignore) 4: date as DateTime?,
      if (startTime != ignore) 5: startTime as String?,
      if (endTime != ignore) 6: endTime as String?,
      if (type != ignore) 7: type as String?,
      if (createdAt != ignore) 8: createdAt as DateTime?,
      if (updatedAt != ignore) 9: updatedAt as DateTime?,
      if (isDirty != ignore) 10: isDirty as bool?,
      if (isDeleted != ignore) 11: isDeleted as bool?,
    });
  }
}

extension AcademicEventLocalUpdate on IsarCollection<int, AcademicEventLocal> {
  _AcademicEventLocalUpdate get update => _AcademicEventLocalUpdateImpl(this);

  _AcademicEventLocalUpdateAll get updateAll =>
      _AcademicEventLocalUpdateAllImpl(this);
}

sealed class _AcademicEventLocalQueryUpdate {
  int call({
    String? serverId,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _AcademicEventLocalQueryUpdateImpl
    implements _AcademicEventLocalQueryUpdate {
  const _AcademicEventLocalQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<AcademicEventLocal> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? date = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? type = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (serverId != ignore) 1: serverId as String?,
      if (title != ignore) 2: title as String?,
      if (description != ignore) 3: description as String?,
      if (date != ignore) 4: date as DateTime?,
      if (startTime != ignore) 5: startTime as String?,
      if (endTime != ignore) 6: endTime as String?,
      if (type != ignore) 7: type as String?,
      if (createdAt != ignore) 8: createdAt as DateTime?,
      if (updatedAt != ignore) 9: updatedAt as DateTime?,
      if (isDirty != ignore) 10: isDirty as bool?,
      if (isDeleted != ignore) 11: isDeleted as bool?,
    });
  }
}

extension AcademicEventLocalQueryUpdate on IsarQuery<AcademicEventLocal> {
  _AcademicEventLocalQueryUpdate get updateFirst =>
      _AcademicEventLocalQueryUpdateImpl(this, limit: 1);

  _AcademicEventLocalQueryUpdate get updateAll =>
      _AcademicEventLocalQueryUpdateImpl(this);
}

class _AcademicEventLocalQueryBuilderUpdateImpl
    implements _AcademicEventLocalQueryUpdate {
  const _AcademicEventLocalQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<AcademicEventLocal, AcademicEventLocal, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? date = ignore,
    Object? startTime = ignore,
    Object? endTime = ignore,
    Object? type = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (serverId != ignore) 1: serverId as String?,
        if (title != ignore) 2: title as String?,
        if (description != ignore) 3: description as String?,
        if (date != ignore) 4: date as DateTime?,
        if (startTime != ignore) 5: startTime as String?,
        if (endTime != ignore) 6: endTime as String?,
        if (type != ignore) 7: type as String?,
        if (createdAt != ignore) 8: createdAt as DateTime?,
        if (updatedAt != ignore) 9: updatedAt as DateTime?,
        if (isDirty != ignore) 10: isDirty as bool?,
        if (isDeleted != ignore) 11: isDeleted as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension AcademicEventLocalQueryBuilderUpdate
    on QueryBuilder<AcademicEventLocal, AcademicEventLocal, QOperations> {
  _AcademicEventLocalQueryUpdate get updateFirst =>
      _AcademicEventLocalQueryBuilderUpdateImpl(this, limit: 1);

  _AcademicEventLocalQueryUpdate get updateAll =>
      _AcademicEventLocalQueryBuilderUpdateImpl(this);
}

extension AcademicEventLocalQueryFilter
    on QueryBuilder<AcademicEventLocal, AcademicEventLocal, QFilterCondition> {
  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      idEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      idLessThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdGreaterThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdLessThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdLessThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdBetween(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdStartsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdEndsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      serverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleGreaterThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleLessThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleLessThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleBetween(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleStartsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleEndsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionStartsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionEndsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      dateEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      dateGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      dateLessThan(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      dateLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeEqualTo(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeGreaterThan(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeLessThan(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeStartsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeEndsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      startTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeGreaterThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeLessThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeLessThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeBetween(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeStartsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeEndsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      endTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeGreaterThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeLessThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeLessThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeBetween(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeStartsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeEndsWith(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 7,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      createdAtEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      updatedAtEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      updatedAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      updatedAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      isDirtyEqualTo(
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

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterFilterCondition>
      isDeletedEqualTo(
    bool value,
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
}

extension AcademicEventLocalQueryObject
    on QueryBuilder<AcademicEventLocal, AcademicEventLocal, QFilterCondition> {}

extension AcademicEventLocalQuerySortBy
    on QueryBuilder<AcademicEventLocal, AcademicEventLocal, QSortBy> {
  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByStartTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByStartTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByEndTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy> sortByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        7,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }
}

extension AcademicEventLocalQuerySortThenBy
    on QueryBuilder<AcademicEventLocal, AcademicEventLocal, QSortThenBy> {
  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByStartTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByStartTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByEndTimeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy> thenByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }
}

extension AcademicEventLocalQueryWhereDistinct
    on QueryBuilder<AcademicEventLocal, AcademicEventLocal, QDistinct> {
  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByStartTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByEndTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<AcademicEventLocal, AcademicEventLocal, QAfterDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }
}

extension AcademicEventLocalQueryProperty1
    on QueryBuilder<AcademicEventLocal, AcademicEventLocal, QProperty> {
  QueryBuilder<AcademicEventLocal, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<AcademicEventLocal, String?, QAfterProperty> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<AcademicEventLocal, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<AcademicEventLocal, String?, QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<AcademicEventLocal, DateTime, QAfterProperty> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<AcademicEventLocal, String?, QAfterProperty>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<AcademicEventLocal, String?, QAfterProperty> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<AcademicEventLocal, String, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<AcademicEventLocal, DateTime, QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<AcademicEventLocal, DateTime, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<AcademicEventLocal, bool, QAfterProperty> isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<AcademicEventLocal, bool, QAfterProperty> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension AcademicEventLocalQueryProperty2<R>
    on QueryBuilder<AcademicEventLocal, R, QAfterProperty> {
  QueryBuilder<AcademicEventLocal, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, String?), QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, String), QAfterProperty>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, String?), QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, DateTime), QAfterProperty>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, String?), QAfterProperty>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, String?), QAfterProperty>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, String), QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, DateTime), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, bool), QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<AcademicEventLocal, (R, bool), QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension AcademicEventLocalQueryProperty3<R1, R2>
    on QueryBuilder<AcademicEventLocal, (R1, R2), QAfterProperty> {
  QueryBuilder<AcademicEventLocal, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, String?), QOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, String), QOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, String?), QOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, DateTime), QOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, String?), QOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, String?), QOperations>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, String), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, DateTime), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, bool), QOperations>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<AcademicEventLocal, (R1, R2, bool), QOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}
