import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../database/isar_provider.dart';
import '../models/sync_operation.dart';

part 'sync_queue.g.dart';

@riverpod
SyncQueue syncQueue(SyncQueueRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return SyncQueue(isar);
}

class SyncQueue {
  final Isar _isar;

  SyncQueue(this._isar);

  Future<void> enqueue({
    required String collectionName,
    required String documentId,
    required String operationType,
    required String payload,
  }) async {
    final operation = SyncOperation()
      ..collectionName = collectionName
      ..documentId = documentId
      ..operationType = operationType
      ..payload = payload
      ..createdAt = DateTime.now().toUtc()
      ..retryCount = 0;

    await _isar.writeAsync((isar) {
      if (operation.id == 0) {
        operation.id = isar.syncOperations.autoIncrement();
      }
      isar.syncOperations.put(operation);
    });
  }

  Future<List<SyncOperation>> getPendingOperations() async {
    return _isar.syncOperations
        .where()
        .sortByCreatedAt()
        .findAll();
  }

  Future<void> remove(int id) async {
    await _isar.writeAsync((isar) {
      isar.syncOperations.delete(id);
    });
  }

  Future<void> incrementRetryCount(int id) async {
    await _isar.writeAsync((isar) {
      final op = isar.syncOperations.get(id);
      if (op != null) {
        op.retryCount += 1;
        isar.syncOperations.put(op);
      }
    });
  }
}
