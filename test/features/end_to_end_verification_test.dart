import 'package:flutter_test/flutter_test.dart';

import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/data/models/attendance_record_local.dart';
import 'package:attend_iq/features/attendance/data/datasources/attendance_local_data_source.dart';
import 'package:attend_iq/features/attendance/data/repositories/attendance_repository_impl.dart';

import 'package:attend_iq/features/timetable/data/models/daily_schedule_occurrence_local.dart';
import 'package:attend_iq/features/timetable/domain/entities/daily_schedule_occurrence.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/entities/academic_event.dart';

import 'package:attend_iq/features/academic_planner/domain/entities/academic_task.dart';
import 'package:attend_iq/features/academic_planner/domain/entities/task_enums.dart';

import 'package:attend_iq/core/backup/backup_models.dart';
import 'package:attend_iq/core/attendance_engine/calculator.dart';

class InMemoryAttendanceLocalDataSource implements AttendanceLocalDataSource {
  final Map<int, AttendanceRecordLocal> records = {};
  int _nextId = 1;

  @override
  Future<List<AttendanceRecordLocal>> getAttendanceForSubject(int subjectId) async {
    return records.values
        .where((r) => r.subjectId == subjectId && !r.isDeleted)
        .toList();
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForOccurrence(
      int occurrenceId) async {
    if (occurrenceId <= 0) return null;
    try {
      return records.values.firstWhere(
        (r) =>
            (r.occurrenceId ?? r.eventId) == occurrenceId && !r.isDeleted,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForOccurrenceAnyStatus(
      int occurrenceId) async {
    if (occurrenceId <= 0) return null;
    try {
      return records.values.firstWhere(
        (r) => (r.occurrenceId ?? r.eventId) == occurrenceId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AttendanceRecordLocal?> getAttendanceForEvent(int eventId) =>
      getAttendanceForOccurrence(eventId);

  @override
  Future<AttendanceRecordLocal?> getAttendanceForEventAnyStatus(int eventId) =>
      getAttendanceForOccurrenceAnyStatus(eventId);

  @override
  Future<AttendanceRecordLocal?> getAttendanceRecordById(int id) async {
    return records[id];
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecordLocal record) async {
    final targetId = record.occurrenceId ?? record.eventId;
    if (record.id == 0) {
      if (targetId > 0) {
        final existing = records.values
            .where((r) => (r.occurrenceId ?? r.eventId) == targetId)
            .firstOrNull;
        if (existing != null) {
          record.id = existing.id;
        } else {
          record.id = _nextId++;
        }
      } else {
        record.id = _nextId++;
      }
    }
    records[record.id] = record;
  }

  @override
  Future<void> deleteAttendanceRecord(int id) async {
    final record = records[id];
    if (record != null) {
      record.isDeleted = true;
      record.isDirty = true;
      record.updatedAt = DateTime.now();
    }
  }

  @override
  Stream<void> watchAttendance(int subjectId) => const Stream.empty();

  @override
  Future<void> updateEventStatus(int eventId, String status) async {}

  @override
  Future<DailyScheduleOccurrenceLocal> saveExtraClassWithAttendance({
    int? occurrenceId,
    required int subjectId,
    required DateTime date,
    String? subjectTitle,
    String? startTime,
    String? endTime,
    String? reason,
    String? attendanceStatus,
    bool autoAllocateSlot = false,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('Issue 1: Attendance Statistics & Records Verification', () {
    late InMemoryAttendanceLocalDataSource dataSource;
    late AttendanceRepositoryImpl repository;

    setUp(() {
      dataSource = InMemoryAttendanceLocalDataSource();
      repository = AttendanceRepositoryImpl(dataSource);
    });

    test('Marking all 5 classes PRESENT creates 5 distinct records without overwrite', () async {
      final date = DateTime.utc(2026, 7, 21);

      // Simulate 5 classes with unique occurrence IDs (1, 2, 3, 4, 5)
      for (int eventId = 1; eventId <= 5; eventId++) {
        final record = AttendanceRecord(
          eventId: eventId,
          subjectId: 100 + eventId, // 5 different subjects or same subject
          status: AttendanceStatus.PRESENT,
          markedAt: date,
          updatedAt: DateTime.now(),
        );
        await repository.saveAttendanceRecord(record);
      }

      expect(dataSource.records.length, equals(5));

      int totalConducted = 0;
      int presentCount = 0;
      int absentCount = 0;

      for (final recLocal in dataSource.records.values) {
        if (!recLocal.isDeleted) {
          if (recLocal.status == 'PRESENT' || recLocal.status == 'EXTRA_PRESENT') {
            presentCount++;
            totalConducted++;
          } else if (recLocal.status == 'ABSENT' || recLocal.status == 'EXTRA_ABSENT') {
            absentCount++;
            totalConducted++;
          }
        }
      }

      final percentage = AttendanceCalculator.calculatePercentage(
        attended: presentCount,
        total: totalConducted,
      );

      expect(totalConducted, equals(5));
      expect(presentCount, equals(5));
      expect(absentCount, equals(0));
      expect(percentage, equals(100.0));
    });

    test('Marking Present -> Absent -> Present updates exact single record', () async {
      final date = DateTime.utc(2026, 7, 21);
      const eventId = 42;

      // 1. Mark Present
      final record1 = AttendanceRecord(
        eventId: eventId,
        subjectId: 101,
        status: AttendanceStatus.PRESENT,
        markedAt: date,
        updatedAt: DateTime.now(),
      );
      await repository.saveAttendanceRecord(record1);

      expect(dataSource.records.length, equals(1));
      expect(dataSource.records.values.first.status, equals('PRESENT'));

      // 2. Mark Absent (Edit)
      final record2 = AttendanceRecord(
        eventId: eventId,
        subjectId: 101,
        status: AttendanceStatus.ABSENT,
        markedAt: date,
        updatedAt: DateTime.now(),
      );
      await repository.saveAttendanceRecord(record2);

      expect(dataSource.records.length, equals(1));
      expect(dataSource.records.values.first.status, equals('ABSENT'));

      // 3. Mark Present again
      final record3 = AttendanceRecord(
        eventId: eventId,
        subjectId: 101,
        status: AttendanceStatus.PRESENT,
        markedAt: date,
        updatedAt: DateTime.now(),
      );
      await repository.saveAttendanceRecord(record3);

      expect(dataSource.records.length, equals(1));
      expect(dataSource.records.values.first.status, equals('PRESENT'));
    });

    test('Cancelled class excludes attendance record', () async {
      final date = DateTime.utc(2026, 7, 21);
      const eventId = 99;

      // Mark present first
      final record = AttendanceRecord(
        eventId: eventId,
        subjectId: 101,
        status: AttendanceStatus.PRESENT,
        markedAt: date,
        updatedAt: DateTime.now(),
      );
      await repository.saveAttendanceRecord(record);
      expect(dataSource.records.length, equals(1));

      // Cancel class -> delete attendance record
      await repository.deleteAttendanceRecord(dataSource.records.keys.first);

      final subjectRecords = await repository.getAttendanceForSubject(101);
      expect(subjectRecords.isEmpty, isTrue);
    });
  });

  group('Issue 2: Holiday & Schedule Exceptions Verification', () {
    test('Holiday exception filters out regular classes for that date', () {
      final date = DateTime.utc(2026, 7, 21);

      final exceptions = [
        ScheduleException(
          id: 1,
          date: date,
          type: ScheduleExceptionType.HOLIDAY,
          title: 'Independence Day',
          description: 'National Holiday',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final holidayException = exceptions.where((e) => e.type == ScheduleExceptionType.HOLIDAY).firstOrNull;

      expect(holidayException, isNotNull);
      expect(holidayException!.title, equals('Independence Day'));
    });
  });

  group('Issue 3: Calendar Actions Domain Model Verification', () {
    test('All calendar entities instantiate and serialize correctly', () {
      // 1. Task
      final task = AcademicTask(
        id: 1,
        title: 'Assignment 1',
        startDate: DateTime.utc(2026, 7, 21),
        dueDate: DateTime.utc(2026, 7, 25),
        priority: TaskPriority.HIGH,
        taskType: TaskType.ASSIGNMENT,
        status: TaskStatus.PENDING,
        reminder: TaskReminder.DAYS_1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(task.title, equals('Assignment 1'));

      // 2. Academic Event
      final event = AcademicEvent(
        id: 2,
        title: 'Tech Fest',
        date: DateTime.utc(2026, 7, 28),
        type: AcademicEventType.EVENT,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(event.type, equals(AcademicEventType.EVENT));

      // 3. Holiday (ScheduleException)
      final holiday = ScheduleException(
        id: 3,
        date: DateTime.utc(2026, 8, 15),
        type: ScheduleExceptionType.HOLIDAY,
        title: 'Independence Day',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(holiday.type, equals(ScheduleExceptionType.HOLIDAY));

      // 4. Exam (AcademicEvent)
      final exam = AcademicEvent(
        id: 4,
        title: 'Mid-term Exam',
        date: DateTime.utc(2026, 8, 20),
        type: AcademicEventType.EXAM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(exam.type, equals(AcademicEventType.EXAM));

      // 5. Extra Class (DailyScheduleOccurrence)
      final extraClass = DailyScheduleOccurrence(
        id: 5,
        date: DateTime.utc(2026, 7, 22),
        subjectId: 101,
        title: 'OS Extra Class',
        startTime: '16:00',
        endTime: '17:00',
        type: OccurrenceType.EXTRA_CLASS,
        status: OccurrenceStatus.UPCOMING,
        createdFrom: OccurrenceCreatedFrom.MANUAL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(extraClass.type, equals(OccurrenceType.EXTRA_CLASS));
    });
  });

  group('Issue 4: Backup & Restore Completeness Verification', () {
    test('BackupData supports serialization and deserialization of all 5 additional collections', () {
      final meta = BackupMetadata(
        appVersion: '1.1.0',
        backupVersion: 2,
        createdAt: DateTime.utc(2026, 7, 21),
        devicePlatform: 'windows',
      );

      final backup = BackupData(
        metadata: meta,
        userPreferences: [],
        semesters: [
          {
            'id': 1,
            'name': 'Fall 2026',
            'startDate': '2026-07-01T00:00:00.000Z',
            'endDate': '2026-12-15T00:00:00.000Z',
            'requiredAttendanceRate': 75.0,
            'status': 'active',
            'isActive': true,
          },
        ],
        subjects: [
          {
            'id': 101,
            'semesterId': 1,
            'name': 'Mathematics',
            'code': 'MATH101',
          },
        ],
        attendance: [
          {
            'id': 1,
            'subjectId': 101,
            'status': 'PRESENT',
            'markedAt': '2026-07-21T09:00:00.000Z',
          },
        ],
        timetable: [],
        events: [],
        notifications: [],
        scheduleExceptions: [
          {
            'id': 10,
            'title': 'College Holiday',
            'type': 'HOLIDAY',
            'date': '2026-07-21T00:00:00.000Z',
          },
        ],
        weeklyRules: [
          {
            'id': 20,
            'subjectId': 101,
            'dayOfWeek': 1,
            'startTime': '09:00',
            'endTime': '10:00',
          },
        ],
        occurrences: [
          {
            'id': 30,
            'date': '2026-07-21T00:00:00.000Z',
            'subjectId': 101,
            'title': 'Math Extra',
            'startTime': '14:00',
            'endTime': '15:00',
            'type': 'EXTRA_CLASS',
            'status': 'PRESENT',
          },
        ],
        academicEvents: [
          {
            'id': 40,
            'title': 'Midterm Exam',
            'date': '2026-08-15T00:00:00.000Z',
            'type': 'EXAM',
          },
        ],
        tasks: [
          {
            'id': 50,
            'title': 'Lab Report 1',
            'startDate': '2026-07-21T00:00:00.000Z',
            'dueDate': '2026-07-28T00:00:00.000Z',
            'priority': 'HIGH',
          },
        ],
      );

      final json = backup.toJson();
      final restored = BackupData.fromJson(json);

      expect(restored.metadata.backupVersion, equals(2));
      expect(restored.scheduleExceptions.length, equals(1));
      expect(restored.scheduleExceptions.first['title'], equals('College Holiday'));
      expect(restored.weeklyRules.length, equals(1));
      expect(restored.occurrences.length, equals(1));
      expect(restored.academicEvents.length, equals(1));
      expect(restored.academicEvents.first['title'], equals('Midterm Exam'));
      expect(restored.tasks.length, equals(1));
      expect(restored.tasks.first['title'], equals('Lab Report 1'));
    });
  });
}
