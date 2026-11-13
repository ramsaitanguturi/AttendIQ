import 'package:isar/isar.dart';
import '../models/weekly_schedule_rule_local.dart';
import '../models/timetable_template_local.dart';
import '../../../subject/data/models/subject_local.dart';
import '../../../../core/database/timetable_migration.dart';

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

class WeeklyScheduleRuleLocalDataSourceImpl
    implements WeeklyScheduleRuleLocalDataSource {
  final Isar _isar;
  bool _migrationChecked = false;

  WeeklyScheduleRuleLocalDataSourceImpl(this._isar);

  Future<void> _ensureLegacyTemplatesMigratedIfNeeded() async {
    if (_migrationChecked) return;
    _migrationChecked = true;
    try {
      if (_isar.weeklyScheduleRuleLocals.count() == 0 &&
          _isar.timetableTemplateLocals.count() > 0) {
        await migrateLegacyTimetableAndEvents(_isar);
      }
    } catch (_) {
      // Non-fatal guard when collection is unavailable in unit tests
    }
  }

  @override
  Future<List<WeeklyScheduleRuleLocal>> getRulesForSubject(
      int subjectId) async {
    await _ensureLegacyTemplatesMigratedIfNeeded();
    return _isar.weeklyScheduleRuleLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<WeeklyScheduleRuleLocal>> getRulesForSemester(
      int semesterId) async {
    await _ensureLegacyTemplatesMigratedIfNeeded();
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
    await _isar.writeAsync((isar) {
      final rule = isar.weeklyScheduleRuleLocals.get(id);
      if (rule != null) {
        rule
          ..isDeleted = true
          ..updatedAt = DateTime.now().toUtc();
        isar.weeklyScheduleRuleLocals.put(rule);
      }
    });
  }

  @override
  Future<void> deleteRulesForSubject(int subjectId) async {
    await _isar.writeAsync((isar) {
      final rules = isar.weeklyScheduleRuleLocals
          .where()
          .subjectIdEqualTo(subjectId)
          .findAll();

      if (rules.isNotEmpty) {
        final now = DateTime.now().toUtc();
        for (final rule in rules) {
          rule
            ..isDeleted = true
            ..updatedAt = now;
          isar.weeklyScheduleRuleLocals.put(rule);
        }
      }
    });
  }

  @override
  Stream<void> watchRules(int semesterId) {
    return _isar.weeklyScheduleRuleLocals
        .where()
        .isDeletedEqualTo(false)
        .watch();
  }
}
