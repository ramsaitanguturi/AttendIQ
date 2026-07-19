import '../entities/weekly_schedule_rule.dart';

abstract class WeeklyScheduleRuleRepository {
  Future<List<WeeklyScheduleRule>> getRulesForSubject(int subjectId);
  Future<List<WeeklyScheduleRule>> getRulesForSemester(int semesterId);
  Future<WeeklyScheduleRule?> getRuleById(int id);
  Future<void> saveRule(WeeklyScheduleRule rule);
  Future<void> saveRules(List<WeeklyScheduleRule> rules);
  Future<void> deleteRule(int id);
  Future<void> deleteRulesForSubject(int subjectId);
  Stream<void> watchRules(int semesterId);
}
