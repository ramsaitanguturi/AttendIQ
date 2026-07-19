import 'package:isar/isar.dart';
import '../models/weekly_schedule_rule_local.dart';
import '../models/timetable_template_local.dart';
import '../../../subject/data/models/subject_local.dart';

abstract class WeeklyScheduleRuleLocalDataSource {
  Future<List<WeeklyScheduleRuleLocal>> getRulesForSubject(int subjectId);
  Future<List<WeeklyScheduleRuleLocal>> getRulesForSemester(int semesterId);
  Future<WeeklyScheduleRuleLocal?> getRuleById(int id);
  Future<void> saveRule(WeeklyScheduleRuleLocal rule);
  Future<void> saveRules(List<WeeklyScheduleRuleLocal> rules);
  Future<void> deleteRule(int id);
  Future<void> deleteRulesForSubject(int subjectId);
  Stream<void> watchRules(int semesterId);
}

class WeeklyScheduleRuleLocalDataSourceImpl implements WeeklyScheduleRuleLocalDataSource {
  final Isar _isar;

  WeeklyScheduleRuleLocalDataSourceImpl(this._isar) {
    _migrateLegacyDataIfNeeded();
  }

  Future<void> _migrateLegacyDataIfNeeded() async {
    try {
      final existingRulesCount = _isar.weeklyScheduleRuleLocals.count();
      if (existingRulesCount == 0) {
        final legacyTemplates = _isar.timetableTemplateLocals
            .where()
            .isDeletedEqualTo(false)
            .findAll();
        if (legacyTemplates.isNotEmpty) {
          await _isar.writeAsync((isar) {
            for (final t in legacyTemplates) {
              final rule = WeeklyScheduleRuleLocal()
                ..id = isar.weeklyScheduleRuleLocals.autoIncrement()
                ..serverId = t.serverId
                ..subjectId = t.subjectId
                ..dayOfWeek = t.weekday
                ..startTime = t.startTime
                ..endTime = t.endTime
                ..room = t.room
                ..faculty = t.faculty
                ..isActive = true
                ..createdAt = t.createdAt
                ..updatedAt = t.updatedAt
                ..isDirty = t.isDirty
                ..isDeleted = false;
              isar.weeklyScheduleRuleLocals.put(rule);
            }
          });
        }
      }
    } catch (_) {
      // Ignore migration errors if collection is newly created
    }
  }

  @override
  Future<List<WeeklyScheduleRuleLocal>> getRulesForSubject(int subjectId) async {
    await _migrateLegacyDataIfNeeded();
    return _isar.weeklyScheduleRuleLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<WeeklyScheduleRuleLocal>> getRulesForSemester(int semesterId) async {
    await _migrateLegacyDataIfNeeded();
    final subjects = _isar.subjectLocals
        .where()
        .semesterIdEqualTo(semesterId)
        .isDeletedEqualTo(false)
        .findAll();
    final subjectIds = subjects.map((s) => s.id).toSet();
    if (subjectIds.isEmpty) return [];

    final allRules = _isar.weeklyScheduleRuleLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();

    return allRules.where((r) => subjectIds.contains(r.subjectId)).toList();
  }

  @override
  Future<WeeklyScheduleRuleLocal?> getRuleById(int id) async {
    return _isar.weeklyScheduleRuleLocals.get(id);
  }

  @override
  Future<void> saveRule(WeeklyScheduleRuleLocal rule) async {
    await _isar.writeAsync((isar) {
      if (rule.id == 0) {
        rule.id = isar.weeklyScheduleRuleLocals.autoIncrement();
      }
      isar.weeklyScheduleRuleLocals.put(rule);
    });
  }

  @override
  Future<void> saveRules(List<WeeklyScheduleRuleLocal> rules) async {
    await _isar.writeAsync((isar) {
      for (final rule in rules) {
        if (rule.id == 0) {
          rule.id = isar.weeklyScheduleRuleLocals.autoIncrement();
        }
        isar.weeklyScheduleRuleLocals.put(rule);
      }
    });
  }

  @override
  Future<void> deleteRule(int id) async {
    final rule = await _isar.weeklyScheduleRuleLocals.get(id);
    if (rule != null) {
      await _isar.writeAsync((isar) {
        rule.isDeleted = true;
        rule.updatedAt = DateTime.now().toUtc();
        isar.weeklyScheduleRuleLocals.put(rule);
      });
    }
  }

  @override
  Future<void> deleteRulesForSubject(int subjectId) async {
    final rules = _isar.weeklyScheduleRuleLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .findAll();

    if (rules.isNotEmpty) {
      await _isar.writeAsync((isar) {
        final now = DateTime.now().toUtc();
        for (final rule in rules) {
          rule.isDeleted = true;
          rule.updatedAt = now;
          isar.weeklyScheduleRuleLocals.put(rule);
        }
      });
    }
  }

  @override
  Stream<void> watchRules(int semesterId) {
    return _isar.weeklyScheduleRuleLocals.where().isDeletedEqualTo(false).watch();
  }
}
