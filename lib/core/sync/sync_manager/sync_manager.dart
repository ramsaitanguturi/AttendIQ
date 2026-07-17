import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/isar_provider.dart';
import '../models/sync_operation.dart';
import '../models/sync_mappers.dart';
import '../sync_queue/sync_queue.dart';
import 'firebase_sync_service.dart';
import '../conflict_resolver/conflict_resolver.dart';

import '../../../../features/auth/data/models/semester_local.dart';
import '../../../../features/subject/data/models/subject_local.dart';
import '../../../../features/timetable/data/models/timetable_template_local.dart';
import '../../event_generator/data/models/event_local.dart';
import '../../../../features/attendance/data/models/attendance_record_local.dart';
import '../../../../features/settings/data/models/user_preferences_local.dart';

part 'sync_manager.g.dart';

@riverpod
SyncManager syncManager(SyncManagerRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  final queue = ref.watch(syncQueueProvider);
  final remote = ref.watch(firebaseSyncServiceProvider);
  
  final manager = SyncManager(isar, queue, remote);
  ref.onDispose(() {
    manager.dispose();
  });
  return manager;
}

class SyncManager {
  final Isar? _isar;
  final SyncQueue _syncQueue;
  final FirebaseSyncService _remoteSyncService;
  
  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;
  Timer? _retryTimer;

  SyncManager(this._isar, this._syncQueue, this._remoteSyncService) {
    initConnectivityListener();
  }

  void initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        sync();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
  }

  Future<bool> checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity.any((r) => r != ConnectivityResult.none);
  }

  Future<void> writeToLocalDatabase(FutureOr<void> Function(Isar? isar) callback) async {
    await _isar!.writeAsync((isar) => callback(isar));
  }

  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    
    final hasConnection = await checkConnectivity();
    if (!hasConnection) {
      _isSyncing = false;
      return;
    }

    final userId = _remoteSyncService.currentUserId;
    if (userId == null) {
      _isSyncing = false;
      return;
    }

    _retryTimer?.cancel();

    try {
      final pending = await _syncQueue.getPendingOperations();
      bool hasFailed = false;
      for (final op in pending) {
        try {
          await _processOperation(op, userId);
          await _syncQueue.remove(op.id);
        } catch (e) {
          hasFailed = true;
          if (_isPoisonPill(e)) {
            await isolatePoisonPill(op, e.toString());
            await _syncQueue.remove(op.id);
          } else {
            await _syncQueue.incrementRetryCount(op.id);
            _scheduleRetry(op.retryCount + 1);
            break; 
          }
        }
      }
      if (!hasFailed && pending.isNotEmpty) {
        await _updatePreferencesLastSyncTime(userId);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _updatePreferencesLastSyncTime(String userId) async {
    await writeToLocalDatabase((isar) async {
      if (isar == null) return;
      final existing = await isar.userPreferencesLocals.where().serverIdEqualTo(userId).findFirst();
      if (existing != null) {
        existing.lastSyncTime = DateTime.now().toUtc();
        existing.isDirty = false;
        isar.userPreferencesLocals.put(existing);
      }
    });
  }

  void _scheduleRetry(int retryCount) {
    if (retryCount > 5) return; 
    final delaySeconds = (1 << retryCount) * 5; 
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      sync();
    });
  }

  Future<void> isolatePoisonPill(SyncOperation op, String error) async {
    final failedOp = FailedSyncOperation()
      ..collectionName = op.collectionName
      ..documentId = op.documentId
      ..operationType = op.operationType
      ..payload = op.payload
      ..createdAt = op.createdAt
      ..error = error;
    
    await writeToLocalDatabase((isar) {
      if (isar == null) return;
      if (failedOp.id == 0) {
        failedOp.id = isar.failedSyncOperations.autoIncrement();
      }
      isar.failedSyncOperations.put(failedOp);
    });
  }

  bool _isPoisonPill(Object error) {
    if (error is FirebaseException) {
      final code = error.code.toLowerCase();
      return code == 'permission-denied' || 
             code == 'invalid-argument' || 
             code == 'already-exists';
    }
    return error is FormatException || error is ArgumentError;
  }

  Future<void> _processOperation(SyncOperation op, String userId) async {
    final localModelMap = jsonDecode(op.payload) as Map<String, dynamic>;
    final localModel = await fetchLocalModel(op.collectionName, op.documentId);
    
    DateTime localUpdatedAt;
    if (localModel != null) {
      localUpdatedAt = localModel.updatedAt;
    } else {
      localUpdatedAt = DateTime.parse(localModelMap['updatedAt'] ?? DateTime.now().toUtc().toIso8601String()).toUtc();
    }

    final remoteDoc = await _remoteSyncService.fetchRemoteDocument(op.collectionName, op.documentId);

    if (!remoteDoc.exists) {
      if (op.operationType == 'DELETE') {
        await _remoteSyncService.deleteDocument(op.collectionName, op.documentId);
      } else {
        final translated = await translatePayload(op.collectionName, localModelMap, _isar, userId);
        await _remoteSyncService.saveDocument(op.collectionName, op.documentId, translated);
        if (localModel != null) {
          await writeToLocalDatabase((isar) {
            localModel.isDirty = false;
            putLocalModel(isar, op.collectionName, localModel);
          });
        }
      }
    } else {
      final remoteData = remoteDoc.data() as Map<String, dynamic>;
      final remoteUpdatedAt = (remoteData['updatedAt'] as Timestamp).toDate().toUtc();

      if (ConflictResolver.localWins(localUpdatedAt, remoteUpdatedAt)) {
        if (op.operationType == 'DELETE') {
          await _remoteSyncService.deleteDocument(op.collectionName, op.documentId);
          await deleteLocalRecord(op.collectionName, op.documentId);
        } else {
          final translated = await translatePayload(op.collectionName, localModelMap, _isar, userId);
          await _remoteSyncService.saveDocument(op.collectionName, op.documentId, translated);
          if (localModel != null) {
            await writeToLocalDatabase((isar) {
              localModel.isDirty = false;
              putLocalModel(isar, op.collectionName, localModel);
            });
          }
        }
      } else {
        final isRemoteDeleted = remoteData['isDeleted'] as bool? ?? false;
        if (isRemoteDeleted) {
          await deleteLocalRecord(op.collectionName, op.documentId);
        } else {
          await overwriteLocalRecord(op.collectionName, op.documentId, remoteData);
        }
      }
    }
  }

  Future<dynamic> fetchLocalModel(String collectionName, String serverId) async {
    switch (collectionName) {
      case 'semesters':
        return _isar!.semesterLocals.where().serverIdEqualTo(serverId).findFirst();
      case 'subjects':
        return _isar!.subjectLocals.where().serverIdEqualTo(serverId).findFirst();
      case 'schedules':
        return _isar!.timetableTemplateLocals.where().serverIdEqualTo(serverId).findFirst();
      case 'events':
        return _isar!.eventLocals.where().serverIdEqualTo(serverId).findFirst();
      case 'attendance_records':
        return _isar!.attendanceRecordLocals.where().serverIdEqualTo(serverId).findFirst();
      case 'user_preferences':
        return _isar!.userPreferencesLocals.where().serverIdEqualTo(serverId).findFirst();
      default:
        return null;
    }
  }

  void putLocalModel(Isar? isar, String collectionName, dynamic model) {
    if (isar == null) return;
    switch (collectionName) {
      case 'semesters':
        isar.semesterLocals.put(model as SemesterLocal);
        break;
      case 'subjects':
        isar.subjectLocals.put(model as SubjectLocal);
        break;
      case 'schedules':
        isar.timetableTemplateLocals.put(model as TimetableTemplateLocal);
        break;
      case 'events':
        isar.eventLocals.put(model as EventLocal);
        break;
      case 'attendance_records':
        isar.attendanceRecordLocals.put(model as AttendanceRecordLocal);
        break;
      case 'user_preferences':
        isar.userPreferencesLocals.put(model as UserPreferencesLocal);
        break;
    }
  }

  Future<void> deleteLocalRecord(String collectionName, String serverId) async {
    await writeToLocalDatabase((isar) async {
      if (isar == null) return;
      switch (collectionName) {
        case 'semesters':
          final existing = await isar.semesterLocals.where().serverIdEqualTo(serverId).findFirst();
          if (existing != null) isar.semesterLocals.delete(existing.id);
          break;
        case 'subjects':
          final existing = await isar.subjectLocals.where().serverIdEqualTo(serverId).findFirst();
          if (existing != null) isar.subjectLocals.delete(existing.id);
          break;
        case 'schedules':
          final existing = await isar.timetableTemplateLocals.where().serverIdEqualTo(serverId).findFirst();
          if (existing != null) isar.timetableTemplateLocals.delete(existing.id);
          break;
        case 'events':
          final existing = await isar.eventLocals.where().serverIdEqualTo(serverId).findFirst();
          if (existing != null) isar.eventLocals.delete(existing.id);
          break;
        case 'attendance_records':
          final existing = await isar.attendanceRecordLocals.where().serverIdEqualTo(serverId).findFirst();
          if (existing != null) isar.attendanceRecordLocals.delete(existing.id);
          break;
        case 'user_preferences':
          final existing = await isar.userPreferencesLocals.where().serverIdEqualTo(serverId).findFirst();
          if (existing != null) isar.userPreferencesLocals.delete(existing.id);
          break;
      }
    });
  }

  Future<void> overwriteLocalRecord(String collectionName, String serverId, Map<String, dynamic> remoteData) async {
    final now = DateTime.now().toUtc();
    final updatedAt = remoteData['updatedAt'] != null 
        ? (remoteData['updatedAt'] as Timestamp).toDate().toUtc() 
        : now;
    final createdAt = remoteData['createdAt'] != null 
        ? (remoteData['createdAt'] as Timestamp).toDate().toUtc() 
        : now;

    await writeToLocalDatabase((isar) async {
      if (isar == null) return;
      switch (collectionName) {
        case 'semesters':
          final existing = await isar.semesterLocals.where().serverIdEqualTo(serverId).findFirst();
          final local = (existing ?? SemesterLocal())
            ..serverId = serverId
            ..name = remoteData['name'] as String? ?? ''
            ..startDate = (remoteData['startDate'] as Timestamp).toDate().toUtc()
            ..endDate = (remoteData['endDate'] as Timestamp).toDate().toUtc()
            ..requiredAttendanceRate = (remoteData['requiredAttendanceRate'] as num).toDouble()
            ..createdAt = createdAt
            ..updatedAt = updatedAt
            ..isDirty = false
            ..isDeleted = remoteData['isDeleted'] as bool? ?? false;
          
          if (local.id == 0) {
            local.id = isar.semesterLocals.autoIncrement();
          }
          isar.semesterLocals.put(local);
          break;

        case 'subjects':
          final existing = await isar.subjectLocals.where().serverIdEqualTo(serverId).findFirst();
          final semServerId = remoteData['semesterId'] as String?;
          int localSemId = 0;
          if (semServerId != null) {
            final sem = await isar.semesterLocals.where().serverIdEqualTo(semServerId).findFirst();
            localSemId = sem?.id ?? 0;
          }
          
          final local = (existing ?? SubjectLocal())
            ..serverId = serverId
            ..semesterId = localSemId
            ..name = remoteData['name'] as String? ?? ''
            ..code = remoteData['courseCode'] as String? ?? ''
            ..faculty = remoteData['instructor'] as String?
            ..credits = remoteData['credits'] as int? ?? 0
            ..attendanceTarget = (remoteData['requiredAttendanceOverride'] as num?)?.toDouble() ?? 75.0
            ..color = remoteData['colorHex'] as String? ?? '#000000'
            ..type = remoteData['type'] as String? ?? 'THEORY'
            ..createdAt = createdAt
            ..updatedAt = updatedAt
            ..isDirty = false
            ..isDeleted = remoteData['isDeleted'] as bool? ?? false;

          if (local.id == 0) {
            local.id = isar.subjectLocals.autoIncrement();
          }
          isar.subjectLocals.put(local);
          break;

        case 'schedules':
          final existing = await isar.timetableTemplateLocals.where().serverIdEqualTo(serverId).findFirst();
          final subServerId = remoteData['subjectId'] as String?;
          int localSubId = 0;
          if (subServerId != null) {
            final sub = await isar.subjectLocals.where().serverIdEqualTo(subServerId).findFirst();
            localSubId = sub?.id ?? 0;
          }

          final local = (existing ?? TimetableTemplateLocal())
            ..serverId = serverId
            ..subjectId = localSubId
            ..weekday = remoteData['dayOfWeek'] as int? ?? 1
            ..startTime = remoteData['startTime'] as String? ?? '09:00'
            ..endTime = remoteData['endTime'] as String? ?? '10:00'
            ..room = remoteData['room'] as String?
            ..faculty = remoteData['faculty'] as String?
            ..notes = remoteData['notes'] as String?
            ..createdAt = createdAt
            ..updatedAt = updatedAt
            ..isDirty = false
            ..isDeleted = remoteData['isDeleted'] as bool? ?? false;

          if (local.id == 0) {
            local.id = isar.timetableTemplateLocals.autoIncrement();
          }
          isar.timetableTemplateLocals.put(local);
          break;

        case 'events':
          final existing = await isar.eventLocals.where().serverIdEqualTo(serverId).findFirst();
          final subServerId = remoteData['subjectId'] as String?;
          int localSubId = 0;
          if (subServerId != null) {
            final sub = await isar.subjectLocals.where().serverIdEqualTo(subServerId).findFirst();
            localSubId = sub?.id ?? 0;
          }

          final local = (existing ?? EventLocal())
            ..serverId = serverId
            ..subjectId = localSubId
            ..date = (remoteData['date'] as Timestamp).toDate().toUtc()
            ..startTime = remoteData['startTime'] as String? ?? '09:00'
            ..endTime = remoteData['endTime'] as String? ?? '10:00'
            ..eventType = remoteData['eventType'] as String? ?? 'REGULAR_CLASS'
            ..status = remoteData['status'] as String? ?? 'UNMARKED'
            ..createdAt = createdAt
            ..updatedAt = updatedAt
            ..isDirty = false
            ..isDeleted = remoteData['isDeleted'] as bool? ?? false;

          if (local.id == 0) {
            local.id = isar.eventLocals.autoIncrement();
          }
          isar.eventLocals.put(local);
          break;

        case 'attendance_records':
          final existing = await isar.attendanceRecordLocals.where().serverIdEqualTo(serverId).findFirst();
          final evServerId = remoteData['eventId'] as String?;
          int localEvId = 0;
          if (evServerId != null) {
            final ev = await isar.eventLocals.where().serverIdEqualTo(evServerId).findFirst();
            localEvId = ev?.id ?? 0;
          }
          final subServerId = remoteData['subjectId'] as String?;
          int localSubId = 0;
          if (subServerId != null) {
            final sub = await isar.subjectLocals.where().serverIdEqualTo(subServerId).findFirst();
            localSubId = sub?.id ?? 0;
          }

          final local = (existing ?? AttendanceRecordLocal())
            ..serverId = serverId
            ..eventId = localEvId
            ..subjectId = localSubId
            ..status = remoteData['status'] as String? ?? 'PRESENT'
            ..markedAt = (remoteData['markedAt'] as Timestamp).toDate().toUtc()
            ..createdAt = createdAt
            ..updatedAt = updatedAt
            ..isDirty = false
            ..isDeleted = remoteData['isDeleted'] as bool? ?? false;

          if (local.id == 0) {
            local.id = isar.attendanceRecordLocals.autoIncrement();
          }
          isar.attendanceRecordLocals.put(local);
          break;

        case 'user_preferences':
          final existing = await isar.userPreferencesLocals.where().serverIdEqualTo(serverId).findFirst();
          final local = (existing ?? UserPreferencesLocal())
            ..serverId = serverId
            ..themeMode = remoteData['themeMode'] as String? ?? 'system'
            ..defaultAttendanceTarget = (remoteData['defaultAttendanceTarget'] as num?)?.toDouble() ?? 75.0
            ..classReminderOffset = remoteData['classReminderOffset'] as int? ?? 5
            ..enableNotifications = remoteData['enableNotifications'] as bool? ?? true
            ..enableAttendanceWarnings = remoteData['enableAttendanceWarnings'] as bool? ?? true
            ..weeklyReportEnabled = remoteData['weeklyReportEnabled'] as bool? ?? true
            ..updatedAt = updatedAt
            ..isDirty = false
            ..isDeleted = remoteData['isDeleted'] as bool? ?? false;

          if (local.id == 0) {
            local.id = isar.userPreferencesLocals.autoIncrement();
          }
          isar.userPreferencesLocals.put(local);
          break;
      }
    });
  }

  Future<Map<String, dynamic>> translatePayload(String collectionName, Map<String, dynamic> localPayload, Isar? isar, String userId) async {
    final Map<String, dynamic> result = Map.from(localPayload);
    result['userId'] = userId;
    
    result.remove('id');
    result.remove('serverId');
    
    if (result.containsKey('createdAt') && result['createdAt'] != null) {
      result['createdAt'] = Timestamp.fromDate(DateTime.parse(result['createdAt'] as String));
    }
    if (result.containsKey('updatedAt') && result['updatedAt'] != null) {
      result['updatedAt'] = Timestamp.fromDate(DateTime.parse(result['updatedAt'] as String));
    }
    if (result.containsKey('markedAt') && result['markedAt'] != null) {
      result['markedAt'] = Timestamp.fromDate(DateTime.parse(result['markedAt'] as String));
    }
    if (result.containsKey('startDate') && result['startDate'] != null) {
      result['startDate'] = Timestamp.fromDate(DateTime.parse(result['startDate'] as String));
    }
    if (result.containsKey('endDate') && result['endDate'] != null) {
      result['endDate'] = Timestamp.fromDate(DateTime.parse(result['endDate'] as String));
    }
    if (result.containsKey('date') && result['date'] != null) {
      result['date'] = Timestamp.fromDate(DateTime.parse(result['date'] as String));
    }
    if (result.containsKey('lastSyncTime') && result['lastSyncTime'] != null) {
      result['lastSyncTime'] = Timestamp.fromDate(DateTime.parse(result['lastSyncTime'] as String));
    }
    
    if (isar == null) return result;

    if (collectionName == 'subjects') {
      final semId = localPayload['semesterId'] as int?;
      if (semId != null) {
        final sem = await isar.semesterLocals.get(semId);
        result['semesterId'] = sem?.serverId ?? 'unknown';
      }
    } else if (collectionName == 'schedules') {
      final subId = localPayload['subjectId'] as int?;
      if (subId != null) {
        final sub = await isar.subjectLocals.get(subId);
        result['subjectId'] = sub?.serverId ?? 'unknown';
      }
    } else if (collectionName == 'events') {
      final subId = localPayload['subjectId'] as int?;
      if (subId != null) {
        final sub = await isar.subjectLocals.get(subId);
        result['subjectId'] = sub?.serverId ?? 'unknown';
      }
    } else if (collectionName == 'attendance_records') {
      final evId = localPayload['eventId'] as int?;
      if (evId != null) {
        final ev = await isar.eventLocals.get(evId);
        result['eventId'] = ev?.serverId ?? 'unknown';
      }
      final subId = localPayload['subjectId'] as int?;
      if (subId != null) {
        final sub = await isar.subjectLocals.get(subId);
        result['subjectId'] = sub?.serverId ?? 'unknown';
      }
    }
    
    return result;
  }
}
