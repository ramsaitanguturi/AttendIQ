// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_operation.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetSyncOperationCollection on Isar {
  IsarCollection<int, SyncOperation> get syncOperations => this.collection();
}

const SyncOperationSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'SyncOperation',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'collectionName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'documentId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'operationType',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'payload',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'retryCount',
        type: IsarType.long,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, SyncOperation>(
    serialize: serializeSyncOperation,
    deserialize: deserializeSyncOperation,
    deserializeProperty: deserializeSyncOperationProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeSyncOperation(IsarWriter writer, SyncOperation object) {
  IsarCore.writeString(writer, 1, object.collectionName);
  IsarCore.writeString(writer, 2, object.documentId);
  IsarCore.writeString(writer, 3, object.operationType);
  IsarCore.writeString(writer, 4, object.payload);
  IsarCore.writeLong(
      writer, 5, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 6, object.retryCount);
  return object.id;
}

@isarProtected
SyncOperation deserializeSyncOperation(IsarReader reader) {
  final object = SyncOperation();
  object.id = IsarCore.readId(reader);
  object.collectionName = IsarCore.readString(reader, 1) ?? '';
  object.documentId = IsarCore.readString(reader, 2) ?? '';
  object.operationType = IsarCore.readString(reader, 3) ?? '';
  object.payload = IsarCore.readString(reader, 4) ?? '';
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      object.createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.retryCount = IsarCore.readLong(reader, 6);
  return object;
}

@isarProtected
dynamic deserializeSyncOperationProp(IsarReader reader, int property) {
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
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 6:
      return IsarCore.readLong(reader, 6);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _SyncOperationUpdate {
  bool call({
    required int id,
    String? collectionName,
    String? documentId,
    String? operationType,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
  });
}

class _SyncOperationUpdateImpl implements _SyncOperationUpdate {
  const _SyncOperationUpdateImpl(this.collection);

  final IsarCollection<int, SyncOperation> collection;

  @override
  bool call({
    required int id,
    Object? collectionName = ignore,
    Object? documentId = ignore,
    Object? operationType = ignore,
    Object? payload = ignore,
    Object? createdAt = ignore,
    Object? retryCount = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (collectionName != ignore) 1: collectionName as String?,
          if (documentId != ignore) 2: documentId as String?,
          if (operationType != ignore) 3: operationType as String?,
          if (payload != ignore) 4: payload as String?,
          if (createdAt != ignore) 5: createdAt as DateTime?,
          if (retryCount != ignore) 6: retryCount as int?,
        }) >
        0;
  }
}

sealed class _SyncOperationUpdateAll {
  int call({
    required List<int> id,
    String? collectionName,
    String? documentId,
    String? operationType,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
  });
}

class _SyncOperationUpdateAllImpl implements _SyncOperationUpdateAll {
  const _SyncOperationUpdateAllImpl(this.collection);

  final IsarCollection<int, SyncOperation> collection;

  @override
  int call({
    required List<int> id,
    Object? collectionName = ignore,
    Object? documentId = ignore,
    Object? operationType = ignore,
    Object? payload = ignore,
    Object? createdAt = ignore,
    Object? retryCount = ignore,
  }) {
    return collection.updateProperties(id, {
      if (collectionName != ignore) 1: collectionName as String?,
      if (documentId != ignore) 2: documentId as String?,
      if (operationType != ignore) 3: operationType as String?,
      if (payload != ignore) 4: payload as String?,
      if (createdAt != ignore) 5: createdAt as DateTime?,
      if (retryCount != ignore) 6: retryCount as int?,
    });
  }
}

extension SyncOperationUpdate on IsarCollection<int, SyncOperation> {
  _SyncOperationUpdate get update => _SyncOperationUpdateImpl(this);

  _SyncOperationUpdateAll get updateAll => _SyncOperationUpdateAllImpl(this);
}

sealed class _SyncOperationQueryUpdate {
  int call({
    String? collectionName,
    String? documentId,
    String? operationType,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
  });
}

class _SyncOperationQueryUpdateImpl implements _SyncOperationQueryUpdate {
  const _SyncOperationQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<SyncOperation> query;
  final int? limit;

  @override
  int call({
    Object? collectionName = ignore,
    Object? documentId = ignore,
    Object? operationType = ignore,
    Object? payload = ignore,
    Object? createdAt = ignore,
    Object? retryCount = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (collectionName != ignore) 1: collectionName as String?,
      if (documentId != ignore) 2: documentId as String?,
      if (operationType != ignore) 3: operationType as String?,
      if (payload != ignore) 4: payload as String?,
      if (createdAt != ignore) 5: createdAt as DateTime?,
      if (retryCount != ignore) 6: retryCount as int?,
    });
  }
}

extension SyncOperationQueryUpdate on IsarQuery<SyncOperation> {
  _SyncOperationQueryUpdate get updateFirst =>
      _SyncOperationQueryUpdateImpl(this, limit: 1);

  _SyncOperationQueryUpdate get updateAll =>
      _SyncOperationQueryUpdateImpl(this);
}

class _SyncOperationQueryBuilderUpdateImpl
    implements _SyncOperationQueryUpdate {
  const _SyncOperationQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<SyncOperation, SyncOperation, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? collectionName = ignore,
    Object? documentId = ignore,
    Object? operationType = ignore,
    Object? payload = ignore,
    Object? createdAt = ignore,
    Object? retryCount = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (collectionName != ignore) 1: collectionName as String?,
        if (documentId != ignore) 2: documentId as String?,
        if (operationType != ignore) 3: operationType as String?,
        if (payload != ignore) 4: payload as String?,
        if (createdAt != ignore) 5: createdAt as DateTime?,
        if (retryCount != ignore) 6: retryCount as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension SyncOperationQueryBuilderUpdate
    on QueryBuilder<SyncOperation, SyncOperation, QOperations> {
  _SyncOperationQueryUpdate get updateFirst =>
      _SyncOperationQueryBuilderUpdateImpl(this, limit: 1);

  _SyncOperationQueryUpdate get updateAll =>
      _SyncOperationQueryBuilderUpdateImpl(this);
}

extension SyncOperationQueryFilter
    on QueryBuilder<SyncOperation, SyncOperation, QFilterCondition> {
  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameGreaterThan(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameGreaterThanOrEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameLessThan(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameLessThanOrEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameBetween(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameStartsWith(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameEndsWith(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      collectionNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdGreaterThan(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdGreaterThanOrEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdLessThan(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdLessThanOrEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdBetween(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdStartsWith(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdEndsWith(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeGreaterThan(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeGreaterThanOrEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeLessThan(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeLessThanOrEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeBetween(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeStartsWith(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeEndsWith(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      operationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadGreaterThan(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadGreaterThanOrEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadLessThan(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadLessThanOrEqualTo(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadBetween(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadStartsWith(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadEndsWith(
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      createdAtEqualTo(
    DateTime value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      retryCountEqualTo(
    int value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      retryCountGreaterThan(
    int value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      retryCountGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      retryCountLessThan(
    int value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      retryCountLessThanOrEqualTo(
    int value,
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

  QueryBuilder<SyncOperation, SyncOperation, QAfterFilterCondition>
      retryCountBetween(
    int lower,
    int upper,
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
}

extension SyncOperationQueryObject
    on QueryBuilder<SyncOperation, SyncOperation, QFilterCondition> {}

extension SyncOperationQuerySortBy
    on QueryBuilder<SyncOperation, SyncOperation, QSortBy> {
  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortByCollectionName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy>
      sortByCollectionNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortByDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortByDocumentIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortByOperationType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy>
      sortByOperationTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortByPayloadDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy>
      sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension SyncOperationQuerySortThenBy
    on QueryBuilder<SyncOperation, SyncOperation, QSortThenBy> {
  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenByCollectionName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy>
      thenByCollectionNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenByDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenByDocumentIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenByOperationType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy>
      thenByOperationTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenByPayloadDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy> thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterSortBy>
      thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension SyncOperationQueryWhereDistinct
    on QueryBuilder<SyncOperation, SyncOperation, QDistinct> {
  QueryBuilder<SyncOperation, SyncOperation, QAfterDistinct>
      distinctByCollectionName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterDistinct>
      distinctByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterDistinct>
      distinctByOperationType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterDistinct> distinctByPayload(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<SyncOperation, SyncOperation, QAfterDistinct>
      distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }
}

extension SyncOperationQueryProperty1
    on QueryBuilder<SyncOperation, SyncOperation, QProperty> {
  QueryBuilder<SyncOperation, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SyncOperation, String, QAfterProperty> collectionNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SyncOperation, String, QAfterProperty> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SyncOperation, String, QAfterProperty> operationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SyncOperation, String, QAfterProperty> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SyncOperation, DateTime, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SyncOperation, int, QAfterProperty> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension SyncOperationQueryProperty2<R>
    on QueryBuilder<SyncOperation, R, QAfterProperty> {
  QueryBuilder<SyncOperation, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SyncOperation, (R, String), QAfterProperty>
      collectionNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SyncOperation, (R, String), QAfterProperty>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SyncOperation, (R, String), QAfterProperty>
      operationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SyncOperation, (R, String), QAfterProperty> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SyncOperation, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SyncOperation, (R, int), QAfterProperty> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension SyncOperationQueryProperty3<R1, R2>
    on QueryBuilder<SyncOperation, (R1, R2), QAfterProperty> {
  QueryBuilder<SyncOperation, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<SyncOperation, (R1, R2, String), QOperations>
      collectionNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SyncOperation, (R1, R2, String), QOperations>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SyncOperation, (R1, R2, String), QOperations>
      operationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SyncOperation, (R1, R2, String), QOperations> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SyncOperation, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SyncOperation, (R1, R2, int), QOperations> retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetFailedSyncOperationCollection on Isar {
  IsarCollection<int, FailedSyncOperation> get failedSyncOperations =>
      this.collection();
}

const FailedSyncOperationSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'FailedSyncOperation',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'collectionName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'documentId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'operationType',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'payload',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'error',
        type: IsarType.string,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, FailedSyncOperation>(
    serialize: serializeFailedSyncOperation,
    deserialize: deserializeFailedSyncOperation,
    deserializeProperty: deserializeFailedSyncOperationProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeFailedSyncOperation(
    IsarWriter writer, FailedSyncOperation object) {
  IsarCore.writeString(writer, 1, object.collectionName);
  IsarCore.writeString(writer, 2, object.documentId);
  IsarCore.writeString(writer, 3, object.operationType);
  IsarCore.writeString(writer, 4, object.payload);
  IsarCore.writeLong(
      writer, 5, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeString(writer, 6, object.error);
  return object.id;
}

@isarProtected
FailedSyncOperation deserializeFailedSyncOperation(IsarReader reader) {
  final object = FailedSyncOperation();
  object.id = IsarCore.readId(reader);
  object.collectionName = IsarCore.readString(reader, 1) ?? '';
  object.documentId = IsarCore.readString(reader, 2) ?? '';
  object.operationType = IsarCore.readString(reader, 3) ?? '';
  object.payload = IsarCore.readString(reader, 4) ?? '';
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      object.createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      object.createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  object.error = IsarCore.readString(reader, 6) ?? '';
  return object;
}

@isarProtected
dynamic deserializeFailedSyncOperationProp(IsarReader reader, int property) {
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
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 6:
      return IsarCore.readString(reader, 6) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _FailedSyncOperationUpdate {
  bool call({
    required int id,
    String? collectionName,
    String? documentId,
    String? operationType,
    String? payload,
    DateTime? createdAt,
    String? error,
  });
}

class _FailedSyncOperationUpdateImpl implements _FailedSyncOperationUpdate {
  const _FailedSyncOperationUpdateImpl(this.collection);

  final IsarCollection<int, FailedSyncOperation> collection;

  @override
  bool call({
    required int id,
    Object? collectionName = ignore,
    Object? documentId = ignore,
    Object? operationType = ignore,
    Object? payload = ignore,
    Object? createdAt = ignore,
    Object? error = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (collectionName != ignore) 1: collectionName as String?,
          if (documentId != ignore) 2: documentId as String?,
          if (operationType != ignore) 3: operationType as String?,
          if (payload != ignore) 4: payload as String?,
          if (createdAt != ignore) 5: createdAt as DateTime?,
          if (error != ignore) 6: error as String?,
        }) >
        0;
  }
}

sealed class _FailedSyncOperationUpdateAll {
  int call({
    required List<int> id,
    String? collectionName,
    String? documentId,
    String? operationType,
    String? payload,
    DateTime? createdAt,
    String? error,
  });
}

class _FailedSyncOperationUpdateAllImpl
    implements _FailedSyncOperationUpdateAll {
  const _FailedSyncOperationUpdateAllImpl(this.collection);

  final IsarCollection<int, FailedSyncOperation> collection;

  @override
  int call({
    required List<int> id,
    Object? collectionName = ignore,
    Object? documentId = ignore,
    Object? operationType = ignore,
    Object? payload = ignore,
    Object? createdAt = ignore,
    Object? error = ignore,
  }) {
    return collection.updateProperties(id, {
      if (collectionName != ignore) 1: collectionName as String?,
      if (documentId != ignore) 2: documentId as String?,
      if (operationType != ignore) 3: operationType as String?,
      if (payload != ignore) 4: payload as String?,
      if (createdAt != ignore) 5: createdAt as DateTime?,
      if (error != ignore) 6: error as String?,
    });
  }
}

extension FailedSyncOperationUpdate
    on IsarCollection<int, FailedSyncOperation> {
  _FailedSyncOperationUpdate get update => _FailedSyncOperationUpdateImpl(this);

  _FailedSyncOperationUpdateAll get updateAll =>
      _FailedSyncOperationUpdateAllImpl(this);
}

sealed class _FailedSyncOperationQueryUpdate {
  int call({
    String? collectionName,
    String? documentId,
    String? operationType,
    String? payload,
    DateTime? createdAt,
    String? error,
  });
}

class _FailedSyncOperationQueryUpdateImpl
    implements _FailedSyncOperationQueryUpdate {
  const _FailedSyncOperationQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<FailedSyncOperation> query;
  final int? limit;

  @override
  int call({
    Object? collectionName = ignore,
    Object? documentId = ignore,
    Object? operationType = ignore,
    Object? payload = ignore,
    Object? createdAt = ignore,
    Object? error = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (collectionName != ignore) 1: collectionName as String?,
      if (documentId != ignore) 2: documentId as String?,
      if (operationType != ignore) 3: operationType as String?,
      if (payload != ignore) 4: payload as String?,
      if (createdAt != ignore) 5: createdAt as DateTime?,
      if (error != ignore) 6: error as String?,
    });
  }
}

extension FailedSyncOperationQueryUpdate on IsarQuery<FailedSyncOperation> {
  _FailedSyncOperationQueryUpdate get updateFirst =>
      _FailedSyncOperationQueryUpdateImpl(this, limit: 1);

  _FailedSyncOperationQueryUpdate get updateAll =>
      _FailedSyncOperationQueryUpdateImpl(this);
}

class _FailedSyncOperationQueryBuilderUpdateImpl
    implements _FailedSyncOperationQueryUpdate {
  const _FailedSyncOperationQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<FailedSyncOperation, FailedSyncOperation, QOperations>
      query;
  final int? limit;

  @override
  int call({
    Object? collectionName = ignore,
    Object? documentId = ignore,
    Object? operationType = ignore,
    Object? payload = ignore,
    Object? createdAt = ignore,
    Object? error = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (collectionName != ignore) 1: collectionName as String?,
        if (documentId != ignore) 2: documentId as String?,
        if (operationType != ignore) 3: operationType as String?,
        if (payload != ignore) 4: payload as String?,
        if (createdAt != ignore) 5: createdAt as DateTime?,
        if (error != ignore) 6: error as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension FailedSyncOperationQueryBuilderUpdate
    on QueryBuilder<FailedSyncOperation, FailedSyncOperation, QOperations> {
  _FailedSyncOperationQueryUpdate get updateFirst =>
      _FailedSyncOperationQueryBuilderUpdateImpl(this, limit: 1);

  _FailedSyncOperationQueryUpdate get updateAll =>
      _FailedSyncOperationQueryBuilderUpdateImpl(this);
}

extension FailedSyncOperationQueryFilter on QueryBuilder<FailedSyncOperation,
    FailedSyncOperation, QFilterCondition> {
  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameGreaterThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameGreaterThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameLessThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameLessThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameBetween(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameStartsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameEndsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      collectionNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdGreaterThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdGreaterThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdLessThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdLessThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdBetween(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdStartsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdEndsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeGreaterThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeGreaterThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeLessThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeLessThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeBetween(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeStartsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeEndsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      operationTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadGreaterThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadGreaterThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadLessThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadLessThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadBetween(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadStartsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadEndsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      payloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 4,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      createdAtEqualTo(
    DateTime value,
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value,
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value,
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper,
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorGreaterThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorGreaterThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorLessThan(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorLessThanOrEqualTo(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorBetween(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorStartsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorEndsWith(
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterFilterCondition>
      errorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }
}

extension FailedSyncOperationQueryObject on QueryBuilder<FailedSyncOperation,
    FailedSyncOperation, QFilterCondition> {}

extension FailedSyncOperationQuerySortBy
    on QueryBuilder<FailedSyncOperation, FailedSyncOperation, QSortBy> {
  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByCollectionName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByCollectionNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByDocumentIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByOperationType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByOperationTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByPayloadDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        4,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      sortByErrorDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension FailedSyncOperationQuerySortThenBy
    on QueryBuilder<FailedSyncOperation, FailedSyncOperation, QSortThenBy> {
  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByCollectionName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByCollectionNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByDocumentIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByOperationType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByOperationTypeDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByPayloadDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterSortBy>
      thenByErrorDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension FailedSyncOperationQueryWhereDistinct
    on QueryBuilder<FailedSyncOperation, FailedSyncOperation, QDistinct> {
  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterDistinct>
      distinctByCollectionName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterDistinct>
      distinctByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterDistinct>
      distinctByOperationType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterDistinct>
      distinctByPayload({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<FailedSyncOperation, FailedSyncOperation, QAfterDistinct>
      distinctByError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }
}

extension FailedSyncOperationQueryProperty1
    on QueryBuilder<FailedSyncOperation, FailedSyncOperation, QProperty> {
  QueryBuilder<FailedSyncOperation, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FailedSyncOperation, String, QAfterProperty>
      collectionNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FailedSyncOperation, String, QAfterProperty>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FailedSyncOperation, String, QAfterProperty>
      operationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FailedSyncOperation, String, QAfterProperty> payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FailedSyncOperation, DateTime, QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FailedSyncOperation, String, QAfterProperty> errorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension FailedSyncOperationQueryProperty2<R>
    on QueryBuilder<FailedSyncOperation, R, QAfterProperty> {
  QueryBuilder<FailedSyncOperation, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FailedSyncOperation, (R, String), QAfterProperty>
      collectionNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FailedSyncOperation, (R, String), QAfterProperty>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FailedSyncOperation, (R, String), QAfterProperty>
      operationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FailedSyncOperation, (R, String), QAfterProperty>
      payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FailedSyncOperation, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FailedSyncOperation, (R, String), QAfterProperty>
      errorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension FailedSyncOperationQueryProperty3<R1, R2>
    on QueryBuilder<FailedSyncOperation, (R1, R2), QAfterProperty> {
  QueryBuilder<FailedSyncOperation, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FailedSyncOperation, (R1, R2, String), QOperations>
      collectionNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FailedSyncOperation, (R1, R2, String), QOperations>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FailedSyncOperation, (R1, R2, String), QOperations>
      operationTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FailedSyncOperation, (R1, R2, String), QOperations>
      payloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FailedSyncOperation, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FailedSyncOperation, (R1, R2, String), QOperations>
      errorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}
