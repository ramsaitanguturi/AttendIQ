import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../data/datasources/attendance_local_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../../../core/database/isar_provider.dart';
import '../../../../core/event_generator/data/models/event_local.dart';


part 'attendance_controller.g.dart';

@riverpod
AttendanceLocalDataSource attendanceLocalDataSource(AttendanceLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return AttendanceLocalDataSourceImpl(isar);
}

@riverpod
AttendanceRepository attendanceRepository(AttendanceRepositoryRef ref) {
  return AttendanceRepositoryImpl(ref.watch(attendanceLocalDataSourceProvider));
}

@riverpod
class AttendanceController extends _$AttendanceController {
  @override
  FutureOr<void> build() async {
    // Empty build
  }

  Future<void> markAttendance({
    required int eventId,
    required int subjectId,
    required AttendanceStatus status,
  }) async {
    final isar = ref.read(isarProvider).requireValue;
    final repo = ref.read(attendanceRepositoryProvider);

    // 1. Get or create attendance record
    final existing = await repo.getAttendanceForEvent(eventId);
    final record = AttendanceRecord(
      id: existing?.id,
      serverId: existing?.serverId,
      eventId: eventId,
      subjectId: subjectId,
      status: status,
      markedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: true,
      isDeleted: false,
    );

    // 2. Save attendance record
    await repo.saveAttendanceRecord(record);

    // 3. Update the Event status in Isar
    await isar.writeAsync((isar) {
      final event = isar.eventLocals.get(eventId);
      if (event != null) {
        event.status = _mapToEventStatus(status);
        event.updatedAt = DateTime.now();
        event.isDirty = true;
        isar.eventLocals.put(event);
      }
    });
  }

  Future<void> markExtraClass({
    required int subjectId,
    required DateTime date,
    required AttendanceStatus status, // EXTRA_PRESENT or EXTRA_ABSENT
  }) async {
    final isar = ref.read(isarProvider).requireValue;
    final repo = ref.read(attendanceRepositoryProvider);

    // 1. Create a new EventLocal for the extra class
    int eventId = 0;
    await isar.writeAsync((isar) {
      final event = EventLocal()
        ..subjectId = subjectId
        ..date = date
        ..startTime = '09:00'
        ..endTime = '10:00'
        ..eventType = 'REGULAR_CLASS'
        ..status = _mapToEventStatus(status)
        ..updatedAt = DateTime.now()
        ..isDirty = true
        ..isDeleted = false;
      isar.eventLocals.put(event);
      eventId = event.id;
    });

    // 2. Create the AttendanceRecord linked to the new event
    final record = AttendanceRecord(
      eventId: eventId,
      subjectId: subjectId,
      status: status,
      markedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: true,
      isDeleted: false,
    );

    await repo.saveAttendanceRecord(record);
  }

  String _mapToEventStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.PRESENT:
      case AttendanceStatus.EXTRA_PRESENT:
        return 'PRESENT';
      case AttendanceStatus.ABSENT:
      case AttendanceStatus.EXTRA_ABSENT:
        return 'ABSENT';
      case AttendanceStatus.CANCELLED:
        return 'CANCELLED';
    }
  }
}
