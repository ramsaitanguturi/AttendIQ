import 'package:isar/isar.dart';

part 'sync_operation.g.dart';

@collection
class SyncOperation {
  int id = 0;

  late String collectionName; // e.g., 'semesters', 'subjects', 'schedules', 'events', 'attendance_records'
  late String documentId; // UUID of the record (serverId)
  late String operationType; // 'CREATE', 'UPDATE', 'DELETE'
  late String payload; // JSON representation of the model data
  late DateTime createdAt;
  late int retryCount;
}

@collection
class FailedSyncOperation {
  int id = 0;

  late String collectionName;
  late String documentId;
  late String operationType;
  late String payload;
  late DateTime createdAt;
  late String error;
}
