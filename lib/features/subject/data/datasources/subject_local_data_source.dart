import 'package:isar/isar.dart';
import '../models/subject_local.dart';
import '../../../timetable/data/models/weekly_schedule_rule_local.dart';
import '../../../timetable/data/models/daily_schedule_occurrence_local.dart';

abstract class SubjectLocalDataSource {
  Future<List<SubjectLocal>> getSubjectsBySemester(
    int semesterId, {
    bool includeDeleted = false,
  });
  Future<SubjectLocal?> getSubjectById(int id);
  Future<void> saveSubject(SubjectLocal subject);
  Future<void> deleteSubject(int id);
  Stream<void> watchSubjects(int semesterId);
}

class SubjectLocalDataSourceImpl implements SubjectLocalDataSource {
  final Isar _isar;

  SubjectLocalDataSourceImpl(this._isar);

  @override
  Future<List<SubjectLocal>> getSubjectsBySemester(
    int semesterId, {
    bool includeDeleted = false,
  }) async {
    if (includeDeleted) {
      return _isar.subjectLocals
          .where()
          .semesterIdEqualTo(semesterId)
          .findAll();
    }
    return _isar.subjectLocals
        .where()
        .semesterIdEqualTo(semesterId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<SubjectLocal?> getSubjectById(int id) async {
    return _isar.subjectLocals.get(id);
  }

  @override
  Future<void> saveSubject(SubjectLocal subject) async {
    final assignedId = await _isar.writeAsync((isar) {
      if (subject.id == 0) {
        subject.id = isar.subjectLocals.autoIncrement();
      }
      isar.subjectLocals.put(subject);
      return subject.id;
    });
    subject.id = assignedId;
  }

  @override
  Future<void> deleteSubject(int id) async {
    await _isar.writeAsync((isar) {
      final local = isar.subjectLocals.get(id);
      if (local != null) {
        final now = DateTime.now().toUtc();
        local.isDeleted = true;
        local.isDirty = false;
        local.updatedAt = now;
        isar.subjectLocals.put(local);

        // Cascade soft-delete active weekly recurring rules for this subject
        final rules = isar.weeklyScheduleRuleLocals
            .where()
            .subjectIdEqualTo(id)
            .findAll();
        for (final rule in rules) {
          if (!rule.isDeleted) {
            rule.isDeleted = true;
            rule.updatedAt = now;
            isar.weeklyScheduleRuleLocals.put(rule);
          }
        }

        // Cascade soft-delete future schedule occurrences for this subject
        final todayMidnight = DateTime.utc(now.year, now.month, now.day);
        final occurrences = isar.dailyScheduleOccurrenceLocals
            .where()
            .subjectIdEqualTo(id)
            .findAll();
        for (final occ in occurrences) {
          if (!occ.isDeleted) {
            final occDate =
                DateTime.utc(occ.date.year, occ.date.month, occ.date.day);
            if (!occDate.isBefore(todayMidnight)) {
              occ.isDeleted = true;
              occ.updatedAt = now;
              isar.dailyScheduleOccurrenceLocals.put(occ);
            }
          }
        }
        // Note: AttendanceRecordLocal records are strictly preserved for historical stats
      }
    });
  }

  @override
  Stream<void> watchSubjects(int semesterId) {
    return _isar.subjectLocals
        .where()
        .semesterIdEqualTo(semesterId)
        .isDeletedEqualTo(false)
        .watch();
  }
}
