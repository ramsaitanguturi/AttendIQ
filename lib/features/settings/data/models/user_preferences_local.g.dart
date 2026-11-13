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
        name: 'lateAttendanceWeight',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'lateAttendancePolicy',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'quietHoursEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'quietHoursStartHour',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'quietHoursEndHour',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'notificationSound',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'notificationVibration',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'missedAttendanceReminderEnabled',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'missedAttendanceReminderOffset',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'enableCloudSync',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'cloudSyncConsentGiven',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'enableAutoBackup',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'lastBackupDate',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'autoBackupDay',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'autoBackupHour',
        type: IsarType.long,
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
  IsarCore.writeDouble(writer, 9, object.lateAttendanceWeight);
  IsarCore.writeString(writer, 10, object.lateAttendancePolicy);
  IsarCore.writeBool(writer, 11, object.quietHoursEnabled);
  IsarCore.writeLong(writer, 12, object.quietHoursStartHour);
  IsarCore.writeLong(writer, 13, object.quietHoursEndHour);
  IsarCore.writeBool(writer, 14, object.notificationSound);
  IsarCore.writeBool(writer, 15, object.notificationVibration);
  IsarCore.writeBool(writer, 16, object.missedAttendanceReminderEnabled);
  IsarCore.writeLong(writer, 17, object.missedAttendanceReminderOffset);
  IsarCore.writeBool(writer, 18, object.enableCloudSync);
  IsarCore.writeBool(writer, 19, object.cloudSyncConsentGiven);
  IsarCore.writeBool(writer, 20, object.enableAutoBackup);
  IsarCore.writeLong(
      writer,
      21,
      object.lastBackupDate?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  IsarCore.writeLong(writer, 22, object.autoBackupDay);
  IsarCore.writeLong(writer, 23, object.autoBackupHour);
  IsarCore.writeLong(
      writer, 24, object.updatedAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeBool(writer, 25, object.isDirty);
  IsarCore.writeBool(writer, 26, object.isDeleted);
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
  object.lateAttendanceWeight = IsarCore.readDouble(reader, 9);
  object.lateAttendancePolicy = IsarCore.readString(reader, 10) ?? '';
  object.quietHoursEnabled = IsarCore.readBool(reader, 11);
  object.quietHoursStartHour = IsarCore.readLong(reader, 12);
  object.quietHoursEndHour = IsarCore.readLong(reader, 13);
  object.notificationSound = IsarCore.readBool(reader, 14);
  object.notificationVibration = IsarCore.readBool(reader, 15);
  object.missedAttendanceReminderEnabled = IsarCore.readBool(reader, 16);
  object.missedAttendanceReminderOffset = IsarCore.readLong(reader, 17);
  object.enableCloudSync = IsarCore.readBool(reader, 18);
  object.cloudSyncConsentGiven = IsarCore.readBool(reader, 19);
  object.enableAutoBackup = IsarCore.readBool(reader, 20);
  {
    final value = IsarCore.readLong(reader, 21);
    if (value == -9223372036854775808) {
      object.lastBackupDate = null;
    } else {
      object.lastBackupDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.autoBackupDay = IsarCore.readLong(reader, 22);
  object.autoBackupHour = IsarCore.readLong(reader, 23);
  {
    final value = IsarCore.readLong(reader, 24);
    if (value == -9223372036854775808) {
      object.updatedAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.updatedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.isDirty = IsarCore.readBool(reader, 25);
  object.isDeleted = IsarCore.readBool(reader, 26);
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
      return IsarCore.readDouble(reader, 9);
    case 10:
      return IsarCore.readString(reader, 10) ?? '';
    case 11:
      return IsarCore.readBool(reader, 11);
    case 12:
      return IsarCore.readLong(reader, 12);
    case 13:
      return IsarCore.readLong(reader, 13);
    case 14:
      return IsarCore.readBool(reader, 14);
    case 15:
      return IsarCore.readBool(reader, 15);
    case 16:
      return IsarCore.readBool(reader, 16);
    case 17:
      return IsarCore.readLong(reader, 17);
    case 18:
      return IsarCore.readBool(reader, 18);
    case 19:
      return IsarCore.readBool(reader, 19);
    case 20:
      return IsarCore.readBool(reader, 20);
    case 21:
      {
        final value = IsarCore.readLong(reader, 21);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 22:
      return IsarCore.readLong(reader, 22);
    case 23:
      return IsarCore.readLong(reader, 23);
    case 24:
      {
        final value = IsarCore.readLong(reader, 24);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 25:
      return IsarCore.readBool(reader, 25);
    case 26:
      return IsarCore.readBool(reader, 26);
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
    double? lateAttendanceWeight,
    String? lateAttendancePolicy,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursEndHour,
    bool? notificationSound,
    bool? notificationVibration,
    bool? missedAttendanceReminderEnabled,
    int? missedAttendanceReminderOffset,
    bool? enableCloudSync,
    bool? cloudSyncConsentGiven,
    bool? enableAutoBackup,
    DateTime? lastBackupDate,
    int? autoBackupDay,
    int? autoBackupHour,
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
    Object? lateAttendanceWeight = ignore,
    Object? lateAttendancePolicy = ignore,
    Object? quietHoursEnabled = ignore,
    Object? quietHoursStartHour = ignore,
    Object? quietHoursEndHour = ignore,
    Object? notificationSound = ignore,
    Object? notificationVibration = ignore,
    Object? missedAttendanceReminderEnabled = ignore,
    Object? missedAttendanceReminderOffset = ignore,
    Object? enableCloudSync = ignore,
    Object? cloudSyncConsentGiven = ignore,
    Object? enableAutoBackup = ignore,
    Object? lastBackupDate = ignore,
    Object? autoBackupDay = ignore,
    Object? autoBackupHour = ignore,
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
          if (lateAttendanceWeight != ignore)
            9: lateAttendanceWeight as double?,
          if (lateAttendancePolicy != ignore)
            10: lateAttendancePolicy as String?,
          if (quietHoursEnabled != ignore) 11: quietHoursEnabled as bool?,
          if (quietHoursStartHour != ignore) 12: quietHoursStartHour as int?,
          if (quietHoursEndHour != ignore) 13: quietHoursEndHour as int?,
          if (notificationSound != ignore) 14: notificationSound as bool?,
          if (notificationVibration != ignore)
            15: notificationVibration as bool?,
          if (missedAttendanceReminderEnabled != ignore)
            16: missedAttendanceReminderEnabled as bool?,
          if (missedAttendanceReminderOffset != ignore)
            17: missedAttendanceReminderOffset as int?,
          if (enableCloudSync != ignore) 18: enableCloudSync as bool?,
          if (cloudSyncConsentGiven != ignore)
            19: cloudSyncConsentGiven as bool?,
          if (enableAutoBackup != ignore) 20: enableAutoBackup as bool?,
          if (lastBackupDate != ignore) 21: lastBackupDate as DateTime?,
          if (autoBackupDay != ignore) 22: autoBackupDay as int?,
          if (autoBackupHour != ignore) 23: autoBackupHour as int?,
          if (updatedAt != ignore) 24: updatedAt as DateTime?,
          if (isDirty != ignore) 25: isDirty as bool?,
          if (isDeleted != ignore) 26: isDeleted as bool?,
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
    double? lateAttendanceWeight,
    String? lateAttendancePolicy,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursEndHour,
    bool? notificationSound,
    bool? notificationVibration,
    bool? missedAttendanceReminderEnabled,
    int? missedAttendanceReminderOffset,
    bool? enableCloudSync,
    bool? cloudSyncConsentGiven,
    bool? enableAutoBackup,
    DateTime? lastBackupDate,
    int? autoBackupDay,
    int? autoBackupHour,
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
    Object? lateAttendanceWeight = ignore,
    Object? lateAttendancePolicy = ignore,
    Object? quietHoursEnabled = ignore,
    Object? quietHoursStartHour = ignore,
    Object? quietHoursEndHour = ignore,
    Object? notificationSound = ignore,
    Object? notificationVibration = ignore,
    Object? missedAttendanceReminderEnabled = ignore,
    Object? missedAttendanceReminderOffset = ignore,
    Object? enableCloudSync = ignore,
    Object? cloudSyncConsentGiven = ignore,
    Object? enableAutoBackup = ignore,
    Object? lastBackupDate = ignore,
    Object? autoBackupDay = ignore,
    Object? autoBackupHour = ignore,
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
      if (lateAttendanceWeight != ignore) 9: lateAttendanceWeight as double?,
      if (lateAttendancePolicy != ignore) 10: lateAttendancePolicy as String?,
      if (quietHoursEnabled != ignore) 11: quietHoursEnabled as bool?,
      if (quietHoursStartHour != ignore) 12: quietHoursStartHour as int?,
      if (quietHoursEndHour != ignore) 13: quietHoursEndHour as int?,
      if (notificationSound != ignore) 14: notificationSound as bool?,
      if (notificationVibration != ignore) 15: notificationVibration as bool?,
      if (missedAttendanceReminderEnabled != ignore)
        16: missedAttendanceReminderEnabled as bool?,
      if (missedAttendanceReminderOffset != ignore)
        17: missedAttendanceReminderOffset as int?,
      if (enableCloudSync != ignore) 18: enableCloudSync as bool?,
      if (cloudSyncConsentGiven != ignore) 19: cloudSyncConsentGiven as bool?,
      if (enableAutoBackup != ignore) 20: enableAutoBackup as bool?,
      if (lastBackupDate != ignore) 21: lastBackupDate as DateTime?,
      if (autoBackupDay != ignore) 22: autoBackupDay as int?,
      if (autoBackupHour != ignore) 23: autoBackupHour as int?,
      if (updatedAt != ignore) 24: updatedAt as DateTime?,
      if (isDirty != ignore) 25: isDirty as bool?,
      if (isDeleted != ignore) 26: isDeleted as bool?,
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
    double? lateAttendanceWeight,
    String? lateAttendancePolicy,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursEndHour,
    bool? notificationSound,
    bool? notificationVibration,
    bool? missedAttendanceReminderEnabled,
    int? missedAttendanceReminderOffset,
    bool? enableCloudSync,
    bool? cloudSyncConsentGiven,
    bool? enableAutoBackup,
    DateTime? lastBackupDate,
    int? autoBackupDay,
    int? autoBackupHour,
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
    Object? lateAttendanceWeight = ignore,
    Object? lateAttendancePolicy = ignore,
    Object? quietHoursEnabled = ignore,
    Object? quietHoursStartHour = ignore,
    Object? quietHoursEndHour = ignore,
    Object? notificationSound = ignore,
    Object? notificationVibration = ignore,
    Object? missedAttendanceReminderEnabled = ignore,
    Object? missedAttendanceReminderOffset = ignore,
    Object? enableCloudSync = ignore,
    Object? cloudSyncConsentGiven = ignore,
    Object? enableAutoBackup = ignore,
    Object? lastBackupDate = ignore,
    Object? autoBackupDay = ignore,
    Object? autoBackupHour = ignore,
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
      if (lateAttendanceWeight != ignore) 9: lateAttendanceWeight as double?,
      if (lateAttendancePolicy != ignore) 10: lateAttendancePolicy as String?,
      if (quietHoursEnabled != ignore) 11: quietHoursEnabled as bool?,
      if (quietHoursStartHour != ignore) 12: quietHoursStartHour as int?,
      if (quietHoursEndHour != ignore) 13: quietHoursEndHour as int?,
      if (notificationSound != ignore) 14: notificationSound as bool?,
      if (notificationVibration != ignore) 15: notificationVibration as bool?,
      if (missedAttendanceReminderEnabled != ignore)
        16: missedAttendanceReminderEnabled as bool?,
      if (missedAttendanceReminderOffset != ignore)
        17: missedAttendanceReminderOffset as int?,
      if (enableCloudSync != ignore) 18: enableCloudSync as bool?,
      if (cloudSyncConsentGiven != ignore) 19: cloudSyncConsentGiven as bool?,
      if (enableAutoBackup != ignore) 20: enableAutoBackup as bool?,
      if (lastBackupDate != ignore) 21: lastBackupDate as DateTime?,
      if (autoBackupDay != ignore) 22: autoBackupDay as int?,
      if (autoBackupHour != ignore) 23: autoBackupHour as int?,
      if (updatedAt != ignore) 24: updatedAt as DateTime?,
      if (isDirty != ignore) 25: isDirty as bool?,
      if (isDeleted != ignore) 26: isDeleted as bool?,
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
    Object? lateAttendanceWeight = ignore,
    Object? lateAttendancePolicy = ignore,
    Object? quietHoursEnabled = ignore,
    Object? quietHoursStartHour = ignore,
    Object? quietHoursEndHour = ignore,
    Object? notificationSound = ignore,
    Object? notificationVibration = ignore,
    Object? missedAttendanceReminderEnabled = ignore,
    Object? missedAttendanceReminderOffset = ignore,
    Object? enableCloudSync = ignore,
    Object? cloudSyncConsentGiven = ignore,
    Object? enableAutoBackup = ignore,
    Object? lastBackupDate = ignore,
    Object? autoBackupDay = ignore,
    Object? autoBackupHour = ignore,
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
        if (lateAttendanceWeight != ignore) 9: lateAttendanceWeight as double?,
        if (lateAttendancePolicy != ignore) 10: lateAttendancePolicy as String?,
        if (quietHoursEnabled != ignore) 11: quietHoursEnabled as bool?,
        if (quietHoursStartHour != ignore) 12: quietHoursStartHour as int?,
        if (quietHoursEndHour != ignore) 13: quietHoursEndHour as int?,
        if (notificationSound != ignore) 14: notificationSound as bool?,
        if (notificationVibration != ignore) 15: notificationVibration as bool?,
        if (missedAttendanceReminderEnabled != ignore)
          16: missedAttendanceReminderEnabled as bool?,
        if (missedAttendanceReminderOffset != ignore)
          17: missedAttendanceReminderOffset as int?,
        if (enableCloudSync != ignore) 18: enableCloudSync as bool?,
        if (cloudSyncConsentGiven != ignore) 19: cloudSyncConsentGiven as bool?,
        if (enableAutoBackup != ignore) 20: enableAutoBackup as bool?,
        if (lastBackupDate != ignore) 21: lastBackupDate as DateTime?,
        if (autoBackupDay != ignore) 22: autoBackupDay as int?,
        if (autoBackupHour != ignore) 23: autoBackupHour as int?,
        if (updatedAt != ignore) 24: updatedAt as DateTime?,
        if (isDirty != ignore) 25: isDirty as bool?,
        if (isDeleted != ignore) 26: isDeleted as bool?,
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
      QAfterFilterCondition> lateAttendanceWeightEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendanceWeightGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendanceWeightGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendanceWeightLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendanceWeightLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendanceWeightBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyGreaterThan(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyGreaterThanOrEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyLessThan(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyLessThanOrEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyBetween(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyStartsWith(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyEndsWith(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
          QAfterFilterCondition>
      lateAttendancePolicyContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
          QAfterFilterCondition>
      lateAttendancePolicyMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lateAttendancePolicyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursEnabledEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursStartHourEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursStartHourGreaterThan(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursStartHourGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursStartHourLessThan(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursStartHourLessThanOrEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursStartHourBetween(
    int lower,
    int upper,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursEndHourEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursEndHourGreaterThan(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursEndHourGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursEndHourLessThan(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursEndHourLessThanOrEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> quietHoursEndHourBetween(
    int lower,
    int upper,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> notificationSoundEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> notificationVibrationEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> missedAttendanceReminderEnabledEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> missedAttendanceReminderOffsetEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> missedAttendanceReminderOffsetGreaterThan(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> missedAttendanceReminderOffsetGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> missedAttendanceReminderOffsetLessThan(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> missedAttendanceReminderOffsetLessThanOrEqualTo(
    int value,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> missedAttendanceReminderOffsetBetween(
    int lower,
    int upper,
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> enableCloudSyncEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> cloudSyncConsentGivenEqualTo(
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

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> enableAutoBackupEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 20,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastBackupDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 21));
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastBackupDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 21));
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastBackupDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 21,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastBackupDateGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 21,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastBackupDateGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 21,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastBackupDateLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 21,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastBackupDateLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 21,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> lastBackupDateBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 21,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupDayEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 22,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupDayGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 22,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupDayGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 22,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupDayLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 22,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupDayLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 22,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupDayBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 22,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupHourEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 23,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupHourGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 23,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupHourGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 23,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupHourLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 23,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupHourLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 23,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal,
      QAfterFilterCondition> autoBackupHourBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 23,
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
          property: 24,
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
          property: 24,
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
          property: 24,
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
          property: 24,
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
          property: 24,
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
          property: 24,
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
          property: 25,
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
          property: 26,
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
      sortByLateAttendanceWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByLateAttendanceWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByLateAttendancePolicy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByLateAttendancePolicyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByQuietHoursEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByQuietHoursEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByQuietHoursStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByQuietHoursStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByQuietHoursEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByQuietHoursEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByNotificationSound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByNotificationSoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByNotificationVibration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByNotificationVibrationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByMissedAttendanceReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByMissedAttendanceReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByMissedAttendanceReminderOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByMissedAttendanceReminderOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByEnableCloudSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByEnableCloudSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByCloudSyncConsentGiven() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByCloudSyncConsentGivenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByEnableAutoBackup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByEnableAutoBackupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByLastBackupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(21);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByLastBackupDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(21, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByAutoBackupDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(22);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByAutoBackupDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(22, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByAutoBackupHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(23);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByAutoBackupHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(23, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(24);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(24, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(25);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(25, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(26);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(26, sort: Sort.desc);
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
      thenByLateAttendanceWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByLateAttendanceWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByLateAttendancePolicy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByLateAttendancePolicyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByQuietHoursEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByQuietHoursEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByQuietHoursStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByQuietHoursStartHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByQuietHoursEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByQuietHoursEndHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByNotificationSound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByNotificationSoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByNotificationVibration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByNotificationVibrationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByMissedAttendanceReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByMissedAttendanceReminderEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByMissedAttendanceReminderOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByMissedAttendanceReminderOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByEnableCloudSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByEnableCloudSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(18, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByCloudSyncConsentGiven() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByCloudSyncConsentGivenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(19, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByEnableAutoBackup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByEnableAutoBackupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(20, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByLastBackupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(21);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByLastBackupDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(21, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByAutoBackupDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(22);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByAutoBackupDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(22, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByAutoBackupHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(23);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByAutoBackupHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(23, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(24);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(24, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(25);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByIsDirtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(25, sort: Sort.desc);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(26);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterSortBy>
      thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(26, sort: Sort.desc);
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
      distinctByLateAttendanceWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByLateAttendancePolicy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByQuietHoursEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByQuietHoursStartHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByQuietHoursEndHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByNotificationSound() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByNotificationVibration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(15);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByMissedAttendanceReminderEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(16);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByMissedAttendanceReminderOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(17);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByEnableCloudSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(18);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByCloudSyncConsentGiven() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(19);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByEnableAutoBackup() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(20);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByLastBackupDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(21);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByAutoBackupDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(22);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByAutoBackupHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(23);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(24);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByIsDirty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(25);
    });
  }

  QueryBuilder<UserPreferencesLocal, UserPreferencesLocal, QAfterDistinct>
      distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(26);
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

  QueryBuilder<UserPreferencesLocal, double, QAfterProperty>
      lateAttendanceWeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, String, QAfterProperty>
      lateAttendancePolicyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      quietHoursEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<UserPreferencesLocal, int, QAfterProperty>
      quietHoursStartHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<UserPreferencesLocal, int, QAfterProperty>
      quietHoursEndHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      notificationSoundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      notificationVibrationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      missedAttendanceReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<UserPreferencesLocal, int, QAfterProperty>
      missedAttendanceReminderOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      enableCloudSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      cloudSyncConsentGivenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty>
      enableAutoBackupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }

  QueryBuilder<UserPreferencesLocal, DateTime?, QAfterProperty>
      lastBackupDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(21);
    });
  }

  QueryBuilder<UserPreferencesLocal, int, QAfterProperty>
      autoBackupDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(22);
    });
  }

  QueryBuilder<UserPreferencesLocal, int, QAfterProperty>
      autoBackupHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(23);
    });
  }

  QueryBuilder<UserPreferencesLocal, DateTime, QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(24);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty> isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(25);
    });
  }

  QueryBuilder<UserPreferencesLocal, bool, QAfterProperty> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(26);
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

  QueryBuilder<UserPreferencesLocal, (R, double), QAfterProperty>
      lateAttendanceWeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, String), QAfterProperty>
      lateAttendancePolicyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      quietHoursEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, int), QAfterProperty>
      quietHoursStartHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, int), QAfterProperty>
      quietHoursEndHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      notificationSoundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      notificationVibrationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      missedAttendanceReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, int), QAfterProperty>
      missedAttendanceReminderOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      enableCloudSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      cloudSyncConsentGivenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      enableAutoBackupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, DateTime?), QAfterProperty>
      lastBackupDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(21);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, int), QAfterProperty>
      autoBackupDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(22);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, int), QAfterProperty>
      autoBackupHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(23);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, DateTime), QAfterProperty>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(24);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(25);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R, bool), QAfterProperty>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(26);
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

  QueryBuilder<UserPreferencesLocal, (R1, R2, double), QOperations>
      lateAttendanceWeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, String), QOperations>
      lateAttendancePolicyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      quietHoursEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, int), QOperations>
      quietHoursStartHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, int), QOperations>
      quietHoursEndHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      notificationSoundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      notificationVibrationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      missedAttendanceReminderEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, int), QOperations>
      missedAttendanceReminderOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      enableCloudSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(18);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      cloudSyncConsentGivenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(19);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      enableAutoBackupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(20);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, DateTime?), QOperations>
      lastBackupDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(21);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, int), QOperations>
      autoBackupDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(22);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, int), QOperations>
      autoBackupHourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(23);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, DateTime), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(24);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      isDirtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(25);
    });
  }

  QueryBuilder<UserPreferencesLocal, (R1, R2, bool), QOperations>
      isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(26);
    });
  }
}
