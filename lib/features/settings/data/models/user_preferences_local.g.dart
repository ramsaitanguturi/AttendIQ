// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_local.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetUserPreferencesLocalCollection on Isar {
  IsarCollection<int, UserPreferencesLocal> get userPreferencesLocals =>
      this.collection();
}

const UserPreferencesLocalSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'UserPreferencesLocal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'serverId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'themeMode',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'defaultAttendanceTarget',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'classReminderOffset',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'enableNotifications',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'enableAttendanceWarnings',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'weeklyReportEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'lastSyncTime',
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
    ],
  ),
  converter: IsarObjectConverter<int, UserPreferencesLocal>(
    serialize: serializeUserPreferencesLocal,
    deserialize: deserializeUserPreferencesLocal,
    deserializeProperty: deserializeUserPreferencesLocalProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeUserPreferencesLocal(
    IsarWriter writer, UserPreferencesLocal object) {
  {
    final value = object.serverId;
    if (value == null) {
      IsarCore.writeNull(writer, 1);
    } else {
      IsarCore.writeString(writer, 1, value);
    }
  }
  IsarCore.writeString(writer, 2, object.themeMode);
  IsarCore.writeDouble(writer, 3, object.defaultAttendanceTarget);
  IsarCore.writeLong(writer, 4, object.classReminderOffset);
  IsarCore.writeBool(writer, 5, object.enableNotifications);
  IsarCore.writeBool(writer, 6, object.enableAttendanceWarnings);
  IsarCore.writeBool(writer, 7, object.weeklyReportEnabled);
  IsarCore.writeLong(
      writer,
      8,
      object.lastSyncTime?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  IsarCore.writeLong(
      writer, 9, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 10, object.isDirty);
  IsarCore.writeBool(writer, 11, object.isDeleted);
  return object.id;
}

@isarProtected
UserPreferencesLocal deserializeUserPreferencesLocal(IsarReader reader) {
  final object = UserPreferencesLocal();
  object.id = IsarCore.readId(reader);
  object.serverId = IsarCore.readString(reader, 1);
  object.themeMode = IsarCore.readString(reader, 2) ?? '';
  object.defaultAttendanceTarget = IsarCore.readDouble(reader, 3);
  object.classReminderOffset = IsarCore.readLong(reader, 4);
  object.enableNotifications = IsarCore.readBool(reader, 5);
  object.enableAttendanceWarnings = IsarCore.readBool(reader, 6);
  object.weeklyReportEnabled = IsarCore.readBool(reader, 7);
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      object.lastSyncTime = null;
    } else {
      object.lastSyncTime =
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
dynamic deserializeUserPreferencesLocalProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readDouble(reader, 3);
    case 4:
      return IsarCore.readLong(reader, 4);
    case 5:
      return IsarCore.readBool(reader, 5);
    case 6:
      return IsarCore.readBool(reader, 6);
    case 7:
      return IsarCore.readBool(reader, 7);
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
        if (value == -9223372036854775808) {
          return null;
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

sealed class _UserPreferencesLocalUpdate {
  bool call({
    required int id,
    String? serverId,
    String? themeMode,
    double? defaultAttendanceTarget,
    int? classReminderOffset,
    bool? enableNotifications,
    bool? enableAttendanceWarnings,
    bool? weeklyReportEnabled,
    DateTime? lastSyncTime,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _UserPreferencesLocalUpdateImpl implements _UserPreferencesLocalUpdate {
  const _UserPreferencesLocalUpdateImpl(this.collection);

  final IsarCollection<int, UserPreferencesLocal> collection;

  @override
  bool call({
    required int id,
    Object? serverId = ignore,
    Object? themeMode = ignore,
    Object? defaultAttendanceTarget = ignore,
    Object? classReminderOffset = ignore,
    Object? enableNotifications = ignore,
    Object? enableAttendanceWarnings = ignore,
    Object? weeklyReportEnabled = ignore,
    Object? lastSyncTime = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (serverId != ignore) 1: serverId as String?,
          if (themeMode != ignore) 2: themeMode as String?,
          if (defaultAttendanceTarget != ignore)
            3: defaultAttendanceTarget as double?,
          if (classReminderOffset != ignore) 4: classReminderOffset as int?,
          if (enableNotifications != ignore) 5: enableNotifications as bool?,
          if (enableAttendanceWarnings != ignore)
            6: enableAttendanceWarnings as bool?,
          if (weeklyReportEnabled != ignore) 7: weeklyReportEnabled as bool?,
          if (lastSyncTime != ignore) 8: lastSyncTime as DateTime?,
          if (updatedAt != ignore) 9: updatedAt as DateTime?,
          if (isDirty != ignore) 10: isDirty as bool?,
          if (isDeleted != ignore) 11: isDeleted as bool?,
        }) >
        0;
  }
}

sealed class _UserPreferencesLocalUpdateAll {
  int call({
    required List<int> id,
    String? serverId,
    String? themeMode,
    double? defaultAttendanceTarget,
    int? classReminderOffset,
    bool? enableNotifications,
    bool? enableAttendanceWarnings,
    bool? weeklyReportEnabled,
    DateTime? lastSyncTime,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _UserPreferencesLocalUpdateAllImpl
    implements _UserPreferencesLocalUpdateAll {
  const _UserPreferencesLocalUpdateAllImpl(this.collection);

  final IsarCollection<int, UserPreferencesLocal> collection;

  @override
  int call({
    required List<int> id,
    Object? serverId = ignore,
    Object? themeMode = ignore,
    Object? defaultAttendanceTarget = ignore,
    Object? classReminderOffset = ignore,
    Object? enableNotifications = ignore,
    Object? enableAttendanceWarnings = ignore,
    Object? weeklyReportEnabled = ignore,
    Object? lastSyncTime = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return collection.updateProperties(id, {
      if (serverId != ignore) 1: serverId as String?,
      if (themeMode != ignore) 2: themeMode as String?,
      if (defaultAttendanceTarget != ignore)
        3: defaultAttendanceTarget as double?,
      if (classReminderOffset != ignore) 4: classReminderOffset as int?,
      if (enableNotifications != ignore) 5: enableNotifications as bool?,
      if (enableAttendanceWarnings != ignore)
        6: enableAttendanceWarnings as bool?,
      if (weeklyReportEnabled != ignore) 7: weeklyReportEnabled as bool?,
      if (lastSyncTime != ignore) 8: lastSyncTime as DateTime?,
      if (updatedAt != ignore) 9: updatedAt as DateTime?,
      if (isDirty != ignore) 10: isDirty as bool?,
      if (isDeleted != ignore) 11: isDeleted as bool?,
    });
  }
}

extension UserPreferencesLocalUpdate
    on IsarCollection<int, UserPreferencesLocal> {
  _UserPreferencesLocalUpdate get update =>
      _UserPreferencesLocalUpdateImpl(this);

  _UserPreferencesLocalUpdateAll get updateAll =>
      _UserPreferencesLocalUpdateAllImpl(this);
}

sealed class _UserPreferencesLocalQueryUpdate {
  int call({
    String? serverId,
    String? themeMode,
    double? defaultAttendanceTarget,
    int? classReminderOffset,
    bool? enableNotifications,
    bool? enableAttendanceWarnings,
    bool? weeklyReportEnabled,
    DateTime? lastSyncTime,
    DateTime? updatedAt,
    bool? isDirty,
    bool? isDeleted,
  });
}

class _UserPreferencesLocalQueryUpdateImpl
    implements _UserPreferencesLocalQueryUpdate {
  const _UserPreferencesLocalQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<UserPreferencesLocal> query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? themeMode = ignore,
    Object? defaultAttendanceTarget = ignore,
    Object? classReminderOffset = ignore,
    Object? enableNotifications = ignore,
    Object? enableAttendanceWarnings = ignore,
    Object? weeklyReportEnabled = ignore,
    Object? lastSyncTime = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (serverId != ignore) 1: serverId as String?,
      if (themeMode != ignore) 2: themeMode as String?,
      if (defaultAttendanceTarget != ignore)
        3: defaultAttendanceTarget as double?,
      if (classReminderOffset != ignore) 4: classReminderOffset as int?,
      if (enableNotifications != ignore) 5: enableNotifications as bool?,
      if (enableAttendanceWarnings != ignore)
        6: enableAttendanceWarnings as bool?,
      if (weeklyReportEnabled != ignore) 7: weeklyReportEnabled as bool?,
      if (lastSyncTime != ignore) 8: lastSyncTime as DateTime?,
      if (updatedAt != ignore) 9: updatedAt as DateTime?,
      if (isDirty != ignore) 10: isDirty as bool?,
      if (isDeleted != ignore) 11: isDeleted as bool?,
    });
  }
}

extension UserPreferencesLocalQueryUpdate on IsarQuery<UserPreferencesLocal> {
  _UserPreferencesLocalQueryUpdate get updateFirst =>
      _UserPreferencesLocalQueryUpdateImpl(this, limit: 1);

  _UserPreferencesLocalQueryUpdate get updateAll =>
      _UserPreferencesLocalQueryUpdateImpl(this);
}

class _UserPreferencesLocalQueryBuilderUpdateImpl
    implements _UserPreferencesLocalQueryUpdate {
  const _UserPreferencesLocalQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QOperations>
      query;
  final int? limit;

  @override
  int call({
    Object? serverId = ignore,
    Object? themeMode = ignore,
    Object? defaultAttendanceTarget = ignore,
    Object? classReminderOffset = ignore,
    Object? enableNotifications = ignore,
    Object? enableAttendanceWarnings = ignore,
    Object? weeklyReportEnabled = ignore,
    Object? lastSyncTime = ignore,
    Object? updatedAt = ignore,
    Object? isDirty = ignore,
    Object? isDeleted = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (serverId != ignore) 1: serverId as String?,
        if (themeMode != ignore) 2: themeMode as String?,
        if (defaultAttendanceTarget != ignore)
          3: defaultAttendanceTarget as double?,
        if (classReminderOffset != ignore) 4: classReminderOffset as int?,
        if (enableNotifications != ignore) 5: enableNotifications as bool?,
        if (enableAttendanceWarnings != ignore)
          6: enableAttendanceWarnings as bool?,
        if (weeklyReportEnabled != ignore) 7: weeklyReportEnabled as bool?,
        if (lastSyncTime != ignore) 8: lastSyncTime as DateTime?,
        if (updatedAt != ignore) 9: updatedAt as DateTime?,
        if (isDirty != ignore) 10: isDirty as bool?,
        if (isDeleted != ignore) 11: isDeleted as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension UserPreferencesLocalQueryBuilderUpdate
    on QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QOperations> {
  _UserPreferencesLocalQueryUpdate get updateFirst =>
      _UserPreferencesLocalQueryBuilderUpdateImpl(this, limit: 1);

  _UserPreferencesLocalQueryUpdate get updateAll =>
      _UserPreferencesLocalQueryBuilderUpdateImpl(this);
}

extension UserPreferencesLocalQueryFilter on QueryBuilder<UserPreferencesLocal,
    UserPreferencesLocal, QFilterCondition> {
  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> serverIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 1));
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeGreaterThan(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeGreaterThanOrEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeLessThan(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeLessThanOrEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeBetween(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeStartsWith(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeEndsWith(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
          QAfterFilterCondition>
      themeModeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
          QAfterFilterCondition>
      themeModeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> themeModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> defaultAttendanceTargetEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> defaultAttendanceTargetGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> defaultAttendanceTargetGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> defaultAttendanceTargetLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> defaultAttendanceTargetLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> defaultAttendanceTargetBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> classReminderOffsetEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> classReminderOffsetGreaterThan(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> classReminderOffsetGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> classReminderOffsetLessThan(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> classReminderOffsetLessThanOrEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> classReminderOffsetBetween(
    int lower,
    int upper,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> enableNotificationsEqualTo(
    bool value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> enableAttendanceWarningsEqualTo(
    bool value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> weeklyReportEnabledEqualTo(
    bool value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastSyncTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastSyncTimeIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastSyncTimeEqualTo(
    DateTime? value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastSyncTimeGreaterThan(
    DateTime? value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastSyncTimeGreaterThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastSyncTimeLessThan(
    DateTime? value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastSyncTimeLessThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastSyncTimeBetween(
    DateTime? lower,
    DateTime? upper,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> updatedAtEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> updatedAtGreaterThanOrEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> updatedAtLessThanOrEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> isDirtyEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> isDeletedEqualTo(
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

extension UserPreferencesLocalQueryObject on QueryBuilder<UserPreferencesLocal,
    UserPreferencesLocal, QFilterCondition> {}

extension UserPreferencesLocalQuerySortBy
    on QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QSortBy> {
  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByThemeMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByThemeModeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByDefaultAttendanceTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByDefaultAttendanceTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByClassReminderOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByClassReminderOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByEnableAttendanceWarnings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByEnableAttendanceWarningsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByWeeklyReportEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByWeeklyReportEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByLastSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }
}

extension UserPreferencesLocalQuerySortThenBy
    on QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QSortThenBy> {
  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByServerIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByThemeMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByThemeModeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByDefaultAttendanceTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByDefaultAttendanceTargetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByClassReminderOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByClassReminderOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByEnableNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByEnableAttendanceWarnings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByEnableAttendanceWarningsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByWeeklyReportEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByWeeklyReportEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByLastSyncTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }
}

extension UserPreferencesLocalQueryWhereDistinct
    on QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QDistinct> {
  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByServerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByThemeMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByDefaultAttendanceTarget() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByClassReminderOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByEnableNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByEnableAttendanceWarnings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByWeeklyReportEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByLastSyncTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }
}

extension UserPreferencesLocalQueryProperty1
    on QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QProperty> {
  QueryBuilder<UserPreferencesLocal, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<UserPreferencesLocal, String?, QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<UserPreferencesLocal, String, QAfterProperty>
      themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<UserPreferencesLocal, double, QAfterProperty>
      defaultAttendanceTargetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<UserPreferencesLocal, int, QAfterProperty>
      classReminderOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      enableNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      enableAttendanceWarningsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      weeklyReportEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<UserPreferencesLocal, DateTime?, QAfterProperty>
      lastSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<UserPreferencesLocal, DateTime, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty> isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension UserPreferencesLocalQueryProperty2<R>
    on QueryBuilder<UserPreferencesLocal, R, QAfterProperty> {
  QueryBuilder<UserPreferencesLocal, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, String?), QAfterProperty>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, String), QAfterProperty>
      themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, double), QAfterProperty>
      defaultAttendanceTargetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, int), QAfterProperty>
      classReminderOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      enableNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      enableAttendanceWarningsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      weeklyReportEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, DateTime?), QAfterProperty>
      lastSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, DateTime), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension UserPreferencesLocalQueryProperty3<R1, R2>
    on QueryBuilder<UserPreferencesLocal, (R1, R2), QAfterProperty> {
  QueryBuilder<UserPreferencesLocal, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, String?), QOperations>
      serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, String), QOperations>
      themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, double), QOperations>
      defaultAttendanceTargetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, int), QOperations>
      classReminderOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      enableNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      enableAttendanceWarningsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      weeklyReportEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, DateTime?), QOperations>
      lastSyncTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, DateTime), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}
