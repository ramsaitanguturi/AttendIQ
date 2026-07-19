// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_task_local.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetAcademicTaskLocalCollection on Isar {
  IsarCollection<int, AcademicTaskLocal> get academicTaskLocals =>
      this.collection();
}

const AcademicTaskLocalSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'AcademicTaskLocal',
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
        name: 'taskType',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'subjectId',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'startDate',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'dueDate',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'priority',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'status',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'reminder',
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
        name: 'taskType',
        properties: [
          "taskType",
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
        name: 'startDate',
        properties: [
          "startDate",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'dueDate',
        properties: [
          "dueDate",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'priority',
        properties: [
          "priority",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'status',
        properties: [
          "status",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, AcademicTaskLocal>(
    serialize: serializeAcademicTaskLocal,
    deserialize: deserializeAcademicTaskLocal,
    deserializeProperty: deserializeAcademicTaskLocalProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeAcademicTaskLocal(IsarWriter writer, AcademicTaskLocal object) {
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
  IsarCore.writeString(writer, 4, object.taskType);
  IsarCore.writeLong(writer, 5, object.subjectId ?? -9223372036854775808);
  IsarCore.writeLong(
      writer, 6, object.startDate.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 7, object.dueDate.toUtc().microsecondsSinceEpoch);
  IsarCore.writeString(writer, 8, object.priority);
  IsarCore.writeString(writer, 9, object.status);
  IsarCore.writeString(writer, 10, object.reminder);
  IsarCore.writeLong(
      writer, 11, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer, 12, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 13, object.isDirty);
  IsarCore.writeBool(writer, 14, object.isDeleted);
  return object.id;
}

@isarProtected
AcademicTaskLocal deserializeAcademicTaskLocal(IsarReader reader) {
  final object = AcademicTaskLocal();
  object.id = IsarCore.readId(reader);
  object.serverId = IsarCore.readString(reader, 1);
  object.title = IsarCore.readString(reader, 2) ?? '';
  object.description = IsarCore.readString(reader, 3);
  object.taskType = IsarCore.readString(reader, 4) ?? '';
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      object.subjectId = null;
    } else {
      object.subjectId = value;
    }
  }
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      object.startDate =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.startDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      object.dueDate =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.dueDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.priority = IsarCore.readString(reader, 8) ?? '';
  object.status = IsarCore.readString(reader, 9) ?? '';
  object.reminder = IsarCore.readString(reader, 10) ?? '';
  {
    final value = IsarCore.readLong(reader, 11);
    if (value == -9223372036854775808) {
      object.createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 12);
    if (value == -9223372036854775808) {
      object.updatedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.updatedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.isDirty = IsarCore.readBool(reader, 13);
  object.isDeleted = IsarCore.readBool(reader, 14);
  return object;
}

@isarProtected
dynamic deserializeAcademicTaskLocalProp(IsarReader reader, int property) {
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
      return IsarCore.readString(reader, 4) ?? '';
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
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
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
      return IsarCore.readString(reader, 8) ?? '';
    case 9:
      return IsarCore.readString(reader, 9) ?? '';
    case 10:
      return IsarCore.readString(reader, 10) ?? '';
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
      {
        final value = IsarCore.readLong(reader, 12);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 13:
      return IsarCore.readBool(reader, 13);
    case 14:
      return IsarCore.readBool(reader, 14);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _AcademicTaskLocalUpdate {
  bool call({
    required int id,
    String? serverId,
    String? title,
    String? description,
    String? taskType,
    int? subjectId,
    DateTime? startDate,
    DateTime? dueDate,
    String? priority,
    String? status,
    String? reminder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _AcademicTaskLocalUpdateImpl implements _AcademicTaskLocalUpdate {
  const _AcademicTaskLocalUpdateImpl(this.collection);

  final IsarCollection<int, AcademicTaskLocal> collection;

  @override
  bool call({
    required int id,
    Object? serverId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? taskType = ignore,
    Object? subjectId = ignore,
    Object? startDate = ignore,
    Object? dueDate = ignore,
    Object? priority = ignore,
    Object? status = ignore,
    Object? reminder = ignore,
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
          if (taskType != ignore) 4: taskType as String?,
          if (subjectId != ignore) 5: subjectId as int?,
          if (startDate != ignore) 6: startDate as DateTime?,
          if (dueDate != ignore) 7: dueDate as DateTime?,
          if (priority != ignore) 8: priority as String?,
          if (status != ignore) 9: status as String?,
          if (reminder != ignore) 10: reminder as String?,
          if (createdAt != ignore) 11: createdAt as DateTime?,
          if (updatedAt != ignore) 12: updatedAt as DateTime?,
          if (isDirty != ignore) 13: isDirty as bool?,
          if (isDeleted != ignore) 14: isDeleted as bool?,
        }) >
        0;
  }
}

sealed class _AcademicTaskLocalUpdateAll {
  int call({
    required List<int> id,
    String? serverId,
    String? title,
    String? description,
    String? taskType,
    int? subjectId,
    DateTime? startDate,
    DateTime? dueDate,
    String? priority,
    String? status,
    String? reminder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _AcademicTaskLocalUpdateAllImpl implements _AcademicTaskLocalUpdateAll {
  const _AcademicTaskLocalUpdateAllImpl(this.collection);

  final IsarCollection<int, AcademicTaskLocal> collection;

  @override
  int call({
    required List<int> id,
    Object? serverId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? taskType = ignore,
    Object? subjectId = ignore,
    Object? startDate = ignore,
    Object? dueDate = ignore,
    Object? priority = ignore,
    Object? status = ignore,
    Object? reminder = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties(id, {
      if (serverId != ignore) 1: serverId as String?,
      if (title != ignore) 2: title as String?,
      if (description != ignore) 3: description as String?,
      if (taskType != ignore) 4: taskType as String?,
      if (subjectId != ignore) 5: subjectId as int?,
      if (startDate != ignore) 6: startDate as DateTime?,
      if (dueDate != ignore) 7: dueDate as DateTime?,
      if (priority != ignore) 8: priority as String?,
      if (status != ignore) 9: status as String?,
      if (reminder != ignore) 10: reminder as String?,
      if (createdAt != ignore) 11: createdAt as DateTime?,
      if (updatedAt != ignore) 12: updatedAt as DateTime?,
      if (isDirty != ignore) 13: isDirty as bool?,
      if (isDeleted != ignore) 14: isDeleted as bool?,
    });
  }
}

extension AcademicTaskLocalUpdate on IsarCollection<int, AcademicTaskLocal> {
  _AcademicTaskLocalUpdate get update => _AcademicTaskLocalUpdateImpl(this);

  _AcademicTaskLocalUpdateAll get updateAll =>
      _AcademicTaskLocalUpdateAllImpl(this);
}

sealed class _AcademicTaskLocalQueryUpdate {
  int call({
    String? serverId,
    String? title,
    String? description,
    String? taskType,
    int? subjectId,
    DateTime? startDate,
    DateTime? dueDate,
    String? priority,
    String? status,
    String? reminder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _AcademicTaskLocalQueryUpdateImpl
    implements _AcademicTaskLocalQueryUpdate {
  const _AcademicTaskLocalQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<AcademicTaskLocal> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? taskType = ignore,
    Object? subjectId = ignore,
    Object? startDate = ignore,
    Object? dueDate = ignore,
    Object? priority = ignore,
    Object? status = ignore,
    Object? reminder = ignore,
    Object? createdAt = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (serverId != ignore) 1: serverId as String?,
      if (title != ignore) 2: title as String?,
      if (description != ignore) 3: description as String?,
      if (taskType != ignore) 4: taskType as String?,
      if (subjectId != ignore) 5: subjectId as int?,
      if (startDate != ignore) 6: startDate as DateTime?,
      if (dueDate != ignore) 7: dueDate as DateTime?,
      if (priority != ignore) 8: priority as String?,
      if (status != ignore) 9: status as String?,
      if (reminder != ignore) 10: reminder as String?,
      if (createdAt != ignore) 11: createdAt as DateTime?,
      if (updatedAt != ignore) 12: updatedAt as DateTime?,
      if (isDirty != ignore) 13: isDirty as bool?,
      if (isDeleted != ignore) 14: isDeleted as bool?,
    });
  }
}

extension AcademicTaskLocalQueryUpdate on IsarQuery<AcademicTaskLocal> {
  _AcademicTaskLocalQueryUpdate get updateFirst =>
      _AcademicTaskLocalQueryUpdateImpl(this, limit: 1);

  _AcademicTaskLocalQueryUpdate get updateAll =>
      _AcademicTaskLocalQueryUpdateImpl(this);
}

class _AcademicTaskLocalQueryBuilderUpdateImpl
    implements _AcademicTaskLocalQueryUpdate {
  const _AcademicTaskLocalQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? taskType = ignore,
    Object? subjectId = ignore,
    Object? startDate = ignore,
    Object? dueDate = ignore,
    Object? priority = ignore,
    Object? status = ignore,
    Object? reminder = ignore,
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
        if (taskType != ignore) 4: taskType as String?,
        if (subjectId != ignore) 5: subjectId as int?,
        if (startDate != ignore) 6: startDate as DateTime?,
        if (dueDate != ignore) 7: dueDate as DateTime?,
        if (priority != ignore) 8: priority as String?,
        if (status != ignore) 9: status as String?,
        if (reminder != ignore) 10: reminder as String?,
        if (createdAt != ignore) 11: createdAt as DateTime?,
        if (updatedAt != ignore) 12: updatedAt as DateTime?,
        if (isDirty != ignore) 13: isDirty as bool?,
        if (isDeleted != ignore) 14: isDeleted as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension AcademicTaskLocalQueryBuilderUpdate
    on QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QOperations> {
  _AcademicTaskLocalQueryUpdate get updateFirst =>
      _AcademicTaskLocalQueryBuilderUpdateImpl(this, limit: 1);

  _AcademicTaskLocalQueryUpdate get updateAll =>
      _AcademicTaskLocalQueryBuilderUpdateImpl(this);
}

extension AcademicTaskLocalQueryFilter
    on QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QFilterCondition> {
  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeGreaterThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeLessThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeLessThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeBetween(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeStartsWith(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeEndsWith(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      taskTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      subjectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      subjectIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      subjectIdEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      subjectIdGreaterThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      subjectIdGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      subjectIdLessThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      subjectIdLessThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      subjectIdBetween(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      startDateEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime value,
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      startDateGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      startDateLessThan(
    DateTime value,
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      startDateLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      startDateBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      dueDateEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      dueDateGreaterThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      dueDateGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      dueDateLessThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      dueDateLessThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      dueDateBetween(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityGreaterThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityLessThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityLessThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityBetween(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityStartsWith(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityEndsWith(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      priorityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusGreaterThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusLessThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusLessThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusBetween(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusStartsWith(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusEndsWith(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 9,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 9,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderEqualTo(
    String value, {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderGreaterThan(
    String value, {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderGreaterThanOrEqualTo(
    String value, {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderLessThan(
    String value, {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderLessThanOrEqualTo(
    String value, {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderBetween(
    String lower,
    String upper, {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderStartsWith(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderEndsWith(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      reminderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      createdAtEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      updatedAtEqualTo(
    DateTime value,
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      updatedAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      updatedAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 12,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      isDirtyEqualTo(
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

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterFilterCondition>
      isDeletedEqualTo(
    bool value,
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
}

extension AcademicTaskLocalQueryObject
    on QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QFilterCondition> {}

extension AcademicTaskLocalQuerySortBy
    on QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QSortBy> {
  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy> sortByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByTaskType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByTaskTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByPriority({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByPriorityDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy> sortByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        9,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        9,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByReminder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByReminderDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }
}

extension AcademicTaskLocalQuerySortThenBy
    on QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QSortThenBy> {
  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy> thenByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByTaskType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByTaskTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByPriority({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByPriorityDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy> thenByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByStatusDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByReminder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByReminderDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }
}

extension AcademicTaskLocalQueryWhereDistinct
    on QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QDistinct> {
  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByTaskType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByPriority({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByReminder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }

  QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QAfterDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14);
    });
  }
}

extension AcademicTaskLocalQueryProperty1
    on QueryBuilder<AcademicTaskLocal, AcademicTaskLocal, QProperty> {
  QueryBuilder<AcademicTaskLocal, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<AcademicTaskLocal, String?, QAfterProperty> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<AcademicTaskLocal, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<AcademicTaskLocal, String?, QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<AcademicTaskLocal, String, QAfterProperty> taskTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<AcademicTaskLocal, int?, QAfterProperty> subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<AcademicTaskLocal, DateTime, QAfterProperty>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<AcademicTaskLocal, DateTime, QAfterProperty> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<AcademicTaskLocal, String, QAfterProperty> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<AcademicTaskLocal, String, QAfterProperty> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<AcademicTaskLocal, String, QAfterProperty> reminderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<AcademicTaskLocal, DateTime, QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<AcademicTaskLocal, DateTime, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<AcademicTaskLocal, bool, QAfterProperty> isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<AcademicTaskLocal, bool, QAfterProperty> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }
}

extension AcademicTaskLocalQueryProperty2<R>
    on QueryBuilder<AcademicTaskLocal, R, QAfterProperty> {
  QueryBuilder<AcademicTaskLocal, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, String?), QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, String?), QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, String), QAfterProperty>
      taskTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, int?), QAfterProperty>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, DateTime), QAfterProperty>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, DateTime), QAfterProperty>
      dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, String), QAfterProperty>
      priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, String), QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, String), QAfterProperty>
      reminderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, DateTime), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, bool), QAfterProperty> isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R, bool), QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }
}

extension AcademicTaskLocalQueryProperty3<R1, R2>
    on QueryBuilder<AcademicTaskLocal, (R1, R2), QAfterProperty> {
  QueryBuilder<AcademicTaskLocal, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, String?), QOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, String), QOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, String?), QOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, String), QOperations>
      taskTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, int?), QOperations>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, DateTime), QOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, DateTime), QOperations>
      dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, String), QOperations>
      priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, String), QOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, String), QOperations>
      reminderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, DateTime), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, bool), QOperations>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<AcademicTaskLocal, (R1, R2, bool), QOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }
}
