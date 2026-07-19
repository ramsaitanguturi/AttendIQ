import '../../../subject/domain/entities/subject.dart';
import '../../domain/entities/weekly_schedule_rule.dart';
import '../../domain/repositories/weekly_schedule_rule_repository.dart';
import '../datasources/weekly_schedule_rule_local_data_source.dart';
import '../models/weekly_schedule_rule_local.dart';
import '../../../../core/utils/uuid_generator.dart';

class WeeklyScheduleRuleRepositoryImpl implements WeeklyScheduleRuleRepository {
  final WeeklyScheduleRuleLocalDataSource _localDataSource;

  WeeklyScheduleRuleRepositoryImpl({
    required WeeklyScheduleRuleLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  WeeklyScheduleRule _toEntity(WeeklyScheduleRuleLocal local) {
    return WeeklyScheduleRule(
      id: local.id,
      serverId: local.serverId,
      subjectId: local.subjectId,
      dayOfWeek: local.dayOfWeek,
      startTime: local.startTime,
      endTime: local.endTime,
      room: local.room,
      faculty: local.faculty,
      type: local.type.toUpperCase() == 'LAB' ? SubjectType.LAB : SubjectType.THEORY,
      isActive: local.isActive,
      createdAt: local.createdAt,
      updatedAt: local.updatedAt,
      isDirty: local.isDirty,
      isDeleted: local.isDeleted,
    );
  }

  WeeklyScheduleRuleLocal _toLocal(WeeklyScheduleRule rule) {
    final local = WeeklyScheduleRuleLocal()
      ..id = rule.id ?? 0
      ..serverId = rule.serverId
      ..subjectId = rule.subjectId
      ..dayOfWeek = rule.dayOfWeek
      ..startTime = rule.startTime
      ..endTime = rule.endTime
      ..room = rule.room
      ..faculty = rule.faculty
      ..type = rule.type == SubjectType.LAB ? 'LAB' : 'THEORY'
      ..isActive = rule.isActive
      ..createdAt = rule.createdAt
      ..updatedAt = rule.updatedAt
      ..isDirty = rule.isDirty
      ..isDeleted = rule.isDeleted;
    return local;
  }

  @override
  Future<List<WeeklyScheduleRule>> getRulesForSubject(int subjectId) async {
    final list = await _localDataSource.getRulesForSubject(subjectId);
    return list.map(_toEntity).toList();
  }

  @override
  Future<List<WeeklyScheduleRule>> getRulesForSemester(int semesterId) async {
    final list = await _localDataSource.getRulesForSemester(semesterId);
    return list.map(_toEntity).toList();
  }

  @override
  Future<WeeklyScheduleRule?> getRuleById(int id) async {
    final local = await _localDataSource.getRuleById(id);
    if (local != null && !local.isDeleted) {
      return _toEntity(local);
    }
    return null;
  }

  @override
  Future<void> saveRule(WeeklyScheduleRule rule) async {
    final serverId = rule.serverId ?? generateUuid();
    final now = DateTime.now().toUtc();

    final local = _toLocal(rule)
      ..serverId = serverId
      ..updatedAt = now
      ..isDirty = false
      ..isDeleted = false;

    if (local.id != 0) {
      final existing = await _localDataSource.getRuleById(local.id);
      local.createdAt = existing?.createdAt ?? now;
    } else {
      local.createdAt = now;
    }

    await _localDataSource.saveRule(local);
  }

  @override
  Future<void> saveRules(List<WeeklyScheduleRule> rules) async {
    final now = DateTime.now().toUtc();
    final locals = <WeeklyScheduleRuleLocal>[];

    for (final rule in rules) {
      final serverId = rule.serverId ?? generateUuid();
      final local = _toLocal(rule)
        ..serverId = serverId
        ..updatedAt = now
        ..isDirty = false
        ..isDeleted = false;

      if (local.id != 0) {
        final existing = await _localDataSource.getRuleById(local.id);
        local.createdAt = existing?.createdAt ?? now;
      } else {
        local.createdAt = now;
      }
      locals.add(local);
    }

    await _localDataSource.saveRules(locals);
  }

  @override
  Future<void> deleteRule(int id) async {
    await _localDataSource.deleteRule(id);
  }

  @override
  Future<void> deleteRulesForSubject(int subjectId) async {
    await _localDataSource.deleteRulesForSubject(subjectId);
  }

  @override
  Stream<void> watchRules(int semesterId) {
    return _localDataSource.watchRules(semesterId);
  }
}
