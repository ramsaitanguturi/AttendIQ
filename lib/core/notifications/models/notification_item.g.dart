// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetNotificationItemCollection on Isar {
  IsarCollection<int, NotificationItem> get notificationItems =>
      this.collection();
}

const NotificationItemSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'NotificationItem',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'title',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'body',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'scheduledTime',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'relatedId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'isRead',
        type: IsarType.bool,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'type',
        properties: [
          "type",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, NotificationItem>(
    serialize: serializeNotificationItem,
    deserialize: deserializeNotificationItem,
    deserializeProperty: deserializeNotificationItemProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeNotificationItem(IsarWriter writer, NotificationItem object) {
  IsarCore.writeString(writer, 1, object.title);
  IsarCore.writeString(writer, 2, object.body);
  IsarCore.writeString(writer, 3, object.type);
  IsarCore.writeLong(
      writer, 4, object.scheduledTime.toUtc().microsecondsSinceEpoch);
  {
    final value = object.relatedId;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeString(writer, 5, value);
    }
  }
  IsarCore.writeBool(writer, 6, object.isRead);
  return object.id;
}

@isarProtected
NotificationItem deserializeNotificationItem(IsarReader reader) {
  final object = NotificationItem();
  object.id = IsarCore.readId(reader);
  object.title = IsarCore.readString(reader, 1) ?? '';
  object.body = IsarCore.readString(reader, 2) ?? '';
  object.type = IsarCore.readString(reader, 3) ?? '';
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      object.scheduledTime =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.scheduledTime =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.relatedId = IsarCore.readString(reader, 5);
  object.isRead = IsarCore.readBool(reader, 6);
  return object;
}

@isarProtected
dynamic deserializeNotificationItemProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
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
      return IsarCore.readBool(reader, 6);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _NotificationItemUpdate {
  bool call({
    required int id,
    String? title,
    String? body,
    String? type,
    DateTime? scheduledTime,
    String? relatedId,
    bool? isRead,
  });
}

class _NotificationItemUpdateImpl implements _NotificationItemUpdate {
  const _NotificationItemUpdateImpl(this.collection);

  final IsarCollection<int, NotificationItem> collection;

  @override
  bool call({
    required int id,
    Object? title = ignore,
    Object? body = ignore,
    Object? type = ignore,
    Object? scheduledTime = ignore,
    Object? relatedId = ignore,
    Object? isRead = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (title != ignore) 1: title as String?,
          if (body != ignore) 2: body as String?,
          if (type != ignore) 3: type as String?,
          if (scheduledTime != ignore) 4: scheduledTime as DateTime?,
          if (relatedId != ignore) 5: relatedId as String?,
          if (isRead != ignore) 6: isRead as bool?,
        }) >
        0;
  }
}

sealed class _NotificationItemUpdateAll {
  int call({
    required List<int> id,
    String? title,
    String? body,
    String? type,
    DateTime? scheduledTime,
    String? relatedId,
    bool? isRead,
  });
}

class _NotificationItemUpdateAllImpl implements _NotificationItemUpdateAll {
  const _NotificationItemUpdateAllImpl(this.collection);

  final IsarCollection<int, NotificationItem> collection;

  @override
  int call({
    required List<int> id,
    Object? title = ignore,
    Object? body = ignore,
    Object? type = ignore,
    Object? scheduledTime = ignore,
    Object? relatedId = ignore,
    Object? isRead = ignore,
  }) {
    return collection.updateProperties(id, {
      if (title != ignore) 1: title as String?,
      if (body != ignore) 2: body as String?,
      if (type != ignore) 3: type as String?,
      if (scheduledTime != ignore) 4: scheduledTime as DateTime?,
      if (relatedId != ignore) 5: relatedId as String?,
      if (isRead != ignore) 6: isRead as bool?,
    });
  }
}

extension NotificationItemUpdate on IsarCollection<int, NotificationItem> {
  _NotificationItemUpdate get update => _NotificationItemUpdateImpl(this);

  _NotificationItemUpdateAll get updateAll =>
      _NotificationItemUpdateAllImpl(this);
}

sealed class _NotificationItemQueryUpdate {
  int call({
    String? title,
    String? body,
    String? type,
    DateTime? scheduledTime,
    String? relatedId,
    bool? isRead,
  });
}

class _NotificationItemQueryUpdateImpl implements _NotificationItemQueryUpdate {
  const _NotificationItemQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<NotificationItem> query;
  final int? limit;

  @override
  int call({
    Object? title = ignore,
    Object? body = ignore,
    Object? type = ignore,
    Object? scheduledTime = ignore,
    Object? relatedId = ignore,
    Object? isRead = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (title != ignore) 1: title as String?,
      if (body != ignore) 2: body as String?,
      if (type != ignore) 3: type as String?,
      if (scheduledTime != ignore) 4: scheduledTime as DateTime?,
      if (relatedId != ignore) 5: relatedId as String?,
      if (isRead != ignore) 6: isRead as bool?,
    });
  }
}

extension NotificationItemQueryUpdate on IsarQuery<NotificationItem> {
  _NotificationItemQueryUpdate get updateFirst =>
      _NotificationItemQueryUpdateImpl(this, limit: 1);

  _NotificationItemQueryUpdate get updateAll =>
      _NotificationItemQueryUpdateImpl(this);
}

class _NotificationItemQueryBuilderUpdateImpl
    implements _NotificationItemQueryUpdate {
  const _NotificationItemQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<NotificationItem, NotificationItem, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? title = ignore,
    Object? body = ignore,
    Object? type = ignore,
    Object? scheduledTime = ignore,
    Object? relatedId = ignore,
    Object? isRead = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (title != ignore) 1: title as String?,
        if (body != ignore) 2: body as String?,
        if (type != ignore) 3: type as String?,
        if (scheduledTime != ignore) 4: scheduledTime as DateTime?,
        if (relatedId != ignore) 5: relatedId as String?,
        if (isRead != ignore) 6: isRead as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension NotificationItemQueryBuilderUpdate
    on QueryBuilder<NotificationItem, NotificationItem, QOperations> {
  _NotificationItemQueryUpdate get updateFirst =>
      _NotificationItemQueryBuilderUpdateImpl(this, limit: 1);

  _NotificationItemQueryUpdate get updateAll =>
      _NotificationItemQueryBuilderUpdateImpl(this);
}

extension NotificationItemQueryFilter
    on QueryBuilder<NotificationItem, NotificationItem, QFilterCondition> {
  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleEqualTo(
    String value, {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleGreaterThanOrEqualTo(
    String value, {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleLessThan(
    String value, {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleLessThanOrEqualTo(
    String value, {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleStartsWith(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleEndsWith(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyGreaterThan(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyGreaterThanOrEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyLessThan(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyLessThanOrEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyBetween(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyStartsWith(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyEndsWith(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      bodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeGreaterThan(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeGreaterThanOrEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeLessThan(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeLessThanOrEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeBetween(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeStartsWith(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeEndsWith(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      scheduledTimeEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      scheduledTimeGreaterThan(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      scheduledTimeGreaterThanOrEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      scheduledTimeLessThan(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      scheduledTimeLessThanOrEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      scheduledTimeBetween(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdGreaterThan(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdGreaterThanOrEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdLessThan(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdLessThanOrEqualTo(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdBetween(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdStartsWith(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdEndsWith(
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      relatedIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 5,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterFilterCondition>
      isReadEqualTo(
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
}

extension NotificationItemQueryObject
    on QueryBuilder<NotificationItem, NotificationItem, QFilterCondition> {}

extension NotificationItemQuerySortBy
    on QueryBuilder<NotificationItem, NotificationItem, QSortBy> {
  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> sortByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      sortByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> sortByBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> sortByBodyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> sortByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> sortByTypeDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      sortByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      sortByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      sortByRelatedId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      sortByRelatedIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        5,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      sortByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      sortByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension NotificationItemQuerySortThenBy
    on QueryBuilder<NotificationItem, NotificationItem, QSortThenBy> {
  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> thenByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      thenByTitleDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> thenByBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> thenByBodyDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> thenByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy> thenByTypeDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      thenByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      thenByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      thenByRelatedId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      thenByRelatedIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      thenByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterSortBy>
      thenByIsReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension NotificationItemQueryWhereDistinct
    on QueryBuilder<NotificationItem, NotificationItem, QDistinct> {
  QueryBuilder<NotificationItem, NotificationItem, QAfterDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterDistinct>
      distinctByBody({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterDistinct>
      distinctByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterDistinct>
      distinctByRelatedId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationItem, NotificationItem, QAfterDistinct>
      distinctByIsRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }
}

extension NotificationItemQueryProperty1
    on QueryBuilder<NotificationItem, NotificationItem, QProperty> {
  QueryBuilder<NotificationItem, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NotificationItem, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NotificationItem, String, QAfterProperty> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationItem, String, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationItem, DateTime, QAfterProperty>
      scheduledTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationItem, String?, QAfterProperty> relatedIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationItem, bool, QAfterProperty> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension NotificationItemQueryProperty2<R>
    on QueryBuilder<NotificationItem, R, QAfterProperty> {
  QueryBuilder<NotificationItem, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NotificationItem, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NotificationItem, (R, String), QAfterProperty> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationItem, (R, String), QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationItem, (R, DateTime), QAfterProperty>
      scheduledTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationItem, (R, String?), QAfterProperty>
      relatedIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationItem, (R, bool), QAfterProperty> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension NotificationItemQueryProperty3<R1, R2>
    on QueryBuilder<NotificationItem, (R1, R2), QAfterProperty> {
  QueryBuilder<NotificationItem, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<NotificationItem, (R1, R2, String), QOperations>
      titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<NotificationItem, (R1, R2, String), QOperations> bodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<NotificationItem, (R1, R2, String), QOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<NotificationItem, (R1, R2, DateTime), QOperations>
      scheduledTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<NotificationItem, (R1, R2, String?), QOperations>
      relatedIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<NotificationItem, (R1, R2, bool), QOperations> isReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}
