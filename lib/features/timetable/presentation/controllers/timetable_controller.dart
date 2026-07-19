import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/timetable_template.dart';
import '../../domain/entities/weekly_schedule_rule.dart';
import '../../domain/entities/schedule_exception.dart';
import '../../domain/entities/academic_event.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../../domain/repositories/weekly_schedule_rule_repository.dart';
import '../../domain/repositories/schedule_exception_repository.dart';
import '../../domain/repositories/academic_event_repository.dart';
import '../../data/datasources/timetable_local_data_source.dart';
import '../../data/datasources/weekly_schedule_rule_local_data_source.dart';
import '../../data/datasources/schedule_exception_local_data_source.dart';
import '../../data/datasources/academic_event_local_data_source.dart';
import '../../data/repositories/timetable_repository_impl.dart';
import '../../data/repositories/weekly_schedule_rule_repository_impl.dart';
import '../../data/repositories/schedule_exception_repository_impl.dart';
import '../../data/repositories/academic_event_repository_impl.dart';
import '../../../semester/presentation/controllers/semester_controller.dart';
import '../../../../core/database/isar_provider.dart';

part 'timetable_controller.g.dart';

@riverpod
AcademicEventLocalDataSource academicEventLocalDataSource(AcademicEventLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return AcademicEventLocalDataSourceImpl(isar);
}

@riverpod
AcademicEventRepository academicEventRepository(AcademicEventRepositoryRef ref) {
  return AcademicEventRepositoryImpl(
    ref.watch(academicEventLocalDataSourceProvider),
  );
}

@riverpod
class AcademicEventController extends _$AcademicEventController {
  @override
  FutureOr<List<AcademicEvent>> build() async {
    final repo = ref.watch(academicEventRepositoryProvider);
    final events = await repo.getAllEvents();

    final stream = repo.watchEvents();
    final sub = stream.listen((_) async {
      final updated = await repo.getAllEvents();
      state = AsyncValue.data(updated);
    });

    ref.onDispose(() => sub.cancel());
    return events;
  }

  Future<void> addEvent({
    required String title,
    String? description,
    required DateTime date,
    String? startTime,
    String? endTime,
    required AcademicEventType type,
  }) async {
    final repo = ref.read(academicEventRepositoryProvider);
    final now = DateTime.now().toUtc();
    final event = AcademicEvent(
      title: title,
      description: description,
      date: DateTime.utc(date.year, date.month, date.day),
      startTime: startTime,
      endTime: endTime,
      type: type,
      createdAt: now,
      updatedAt: now,
    );
    await repo.saveEvent(event);
    ref.invalidateSelf();
  }

  Future<void> removeEvent(int id) async {
    final repo = ref.read(academicEventRepositoryProvider);
    await repo.deleteEvent(id);
    ref.invalidateSelf();
  }
}

@riverpod
WeeklyScheduleRuleLocalDataSource weeklyScheduleRuleLocalDataSource(WeeklyScheduleRuleLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return WeeklyScheduleRuleLocalDataSourceImpl(isar);
}

@riverpod
WeeklyScheduleRuleRepository weeklyScheduleRuleRepository(WeeklyScheduleRuleRepositoryRef ref) {
  return WeeklyScheduleRuleRepositoryImpl(
    localDataSource: ref.watch(weeklyScheduleRuleLocalDataSourceProvider),
  );
}

@riverpod
ScheduleExceptionLocalDataSource scheduleExceptionLocalDataSource(ScheduleExceptionLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return ScheduleExceptionLocalDataSourceImpl(isar);
}

@riverpod
ScheduleExceptionRepository scheduleExceptionRepository(ScheduleExceptionRepositoryRef ref) {
  return ScheduleExceptionRepositoryImpl(
    localDataSource: ref.watch(scheduleExceptionLocalDataSourceProvider),
  );
}

@riverpod
TimetableLocalDataSource timetableLocalDataSource(TimetableLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return TimetableLocalDataSourceImpl(isar);
}

@riverpod
TimetableRepository timetableRepository(TimetableRepositoryRef ref) {
  return TimetableRepositoryImpl(
    localDataSource: ref.watch(timetableLocalDataSourceProvider),
  );
}

@riverpod
class WeeklyScheduleRuleListController extends _$WeeklyScheduleRuleListController {
  @override
  FutureOr<List<WeeklyScheduleRule>> build() async {
    final semesterAsync = ref.watch(activeSemesterProvider);
    final semester = semesterAsync.valueOrNull;

    if (semester == null || semester.localId == null) {
      return const [];
    }

    final repo = ref.watch(weeklyScheduleRuleRepositoryProvider);
    final localSemId = semester.localId!;
    final rules = await repo.getRulesForSemester(localSemId);

    final stream = repo.watchRules(localSemId);
    final sub = stream.listen((_) async {
      final updatedRules = await repo.getRulesForSemester(localSemId);
      state = AsyncValue.data(updatedRules);
    });

    ref.onDispose(() {
      sub.cancel();
    });

    return rules;
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  bool checkCollision(int dayOfWeek, String startTime, String endTime, {int? excludeId}) {
    final list = state.valueOrNull ?? [];
    final startMin = _timeToMinutes(startTime);
    final endMin = _timeToMinutes(endTime);

    for (final rule in list) {
      if (rule.id == excludeId || !rule.isActive) continue;
      if (rule.dayOfWeek == dayOfWeek) {
        final tStart = _timeToMinutes(rule.startTime);
        final tEnd = _timeToMinutes(rule.endTime);
        if (startMin < tEnd && endMin > tStart) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> addRulesForDays({
    required int subjectId,
    required List<int> daysOfWeek,
    required String startTime,
    required String endTime,
    String? room,
    String? faculty,
  }) async {
    final repo = ref.read(weeklyScheduleRuleRepositoryProvider);
    final now = DateTime.now().toUtc();
    final newRules = <WeeklyScheduleRule>[];

    for (final day in daysOfWeek) {
      if (checkCollision(day, startTime, endTime)) {
        throw Exception('Schedule collision on day $day: overlapping class exists.');
      }
      newRules.add(
        WeeklyScheduleRule(
          subjectId: subjectId,
          dayOfWeek: day,
          startTime: startTime,
          endTime: endTime,
          room: room,
          faculty: faculty,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    await repo.saveRules(newRules);
    ref.invalidateSelf();
  }

  Future<void> saveRule(WeeklyScheduleRule rule) async {
    if (checkCollision(rule.dayOfWeek, rule.startTime, rule.endTime, excludeId: rule.id)) {
      throw Exception('Schedule collision: overlapping class exists at this time.');
    }
    final repo = ref.read(weeklyScheduleRuleRepositoryProvider);
    await repo.saveRule(rule);
    ref.invalidateSelf();
  }

  Future<void> removeRule(int id) async {
    final repo = ref.read(weeklyScheduleRuleRepositoryProvider);
    await repo.deleteRule(id);
    ref.invalidateSelf();
  }

  Future<void> removeRulesForSubject(int subjectId) async {
    final repo = ref.read(weeklyScheduleRuleRepositoryProvider);
    await repo.deleteRulesForSubject(subjectId);
    ref.invalidateSelf();
  }
}

@riverpod
class ScheduleExceptionController extends _$ScheduleExceptionController {
  @override
  FutureOr<List<ScheduleException>> build() async {
    final repo = ref.watch(scheduleExceptionRepositoryProvider);
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    final end = now.add(const Duration(days: 90));
    final exceptions = await repo.getExceptionsForRange(start, end);

    final stream = repo.watchExceptions();
    final sub = stream.listen((_) async {
      final updated = await repo.getExceptionsForRange(start, end);
      state = AsyncValue.data(updated);
    });

    ref.onDispose(() => sub.cancel());
    return exceptions;
  }

  Future<void> addException({
    required DateTime date,
    int? subjectId,
    required ScheduleExceptionType type,
    required String title,
    String? description,
  }) async {
    final repo = ref.read(scheduleExceptionRepositoryProvider);
    final now = DateTime.now().toUtc();
    final exception = ScheduleException(
      date: DateTime.utc(date.year, date.month, date.day),
      subjectId: subjectId,
      type: type,
      title: title,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    await repo.saveException(exception);
    ref.invalidateSelf();
  }

  Future<void> removeException(int id) async {
    final repo = ref.read(scheduleExceptionRepositoryProvider);
    await repo.deleteException(id);
    ref.invalidateSelf();
  }
}

@riverpod
class TimetableListController extends _$TimetableListController {
  @override
  FutureOr<List<TimetableTemplate>> build() async {
    final rulesAsync = ref.watch(weeklyScheduleRuleListControllerProvider);
    final rules = rulesAsync.valueOrNull ?? [];

    if (rules.isNotEmpty) {
      return rules.where((r) => r.isActive).map((r) => TimetableTemplate(
        id: r.id,
        serverId: r.serverId,
        subjectId: r.subjectId,
        weekday: r.dayOfWeek,
        startTime: r.startTime,
        endTime: r.endTime,
        room: r.room,
        faculty: r.faculty,
        updatedAt: r.updatedAt,
      )).toList();
    }

    final semesterAsync = ref.watch(activeSemesterProvider);
    final semester = semesterAsync.valueOrNull;

    if (semester == null || semester.localId == null) {
      return const [];
    }

    final repo = ref.watch(timetableRepositoryProvider);
    final localSemId = semester.localId!;
    final templates = await repo.getTemplatesForSemester(localSemId);

    final stream = repo.watchTemplates(localSemId);
    final sub = stream.listen((_) async {
      final updatedList = await repo.getTemplatesForSemester(localSemId);
      state = AsyncValue.data(updatedList);
    });

    ref.onDispose(() {
      sub.cancel();
    });

    return templates;
  }

  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  bool checkCollision(int weekday, String startTime, String endTime, {int? excludeId}) {
    final list = state.valueOrNull ?? [];
    final startMin = _timeToMinutes(startTime);
    final endMin = _timeToMinutes(endTime);

    for (final template in list) {
      if (template.id == excludeId) continue;
      if (template.weekday == weekday) {
        final tStart = _timeToMinutes(template.startTime);
        final tEnd = _timeToMinutes(template.endTime);
        if (startMin < tEnd && endMin > tStart) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> addTemplate({
    required int subjectId,
    required int weekday,
    required String startTime,
    required String endTime,
    String? room,
    String? faculty,
    String? notes,
  }) async {
    final ruleController = ref.read(weeklyScheduleRuleListControllerProvider.notifier);
    await ruleController.addRulesForDays(
      subjectId: subjectId,
      daysOfWeek: [weekday],
      startTime: startTime,
      endTime: endTime,
      room: room,
      faculty: faculty,
    );
  }

  Future<void> updateTemplateDetails(TimetableTemplate template) async {
    final ruleRepo = ref.read(weeklyScheduleRuleRepositoryProvider);
    final rule = WeeklyScheduleRule(
      id: template.id,
      serverId: template.serverId,
      subjectId: template.subjectId,
      dayOfWeek: template.weekday,
      startTime: template.startTime,
      endTime: template.endTime,
      room: template.room,
      faculty: template.faculty,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    await ruleRepo.saveRule(rule);
    ref.invalidate(weeklyScheduleRuleListControllerProvider);
  }

  Future<void> removeTemplate(int id) async {
    final ruleRepo = ref.read(weeklyScheduleRuleRepositoryProvider);
    await ruleRepo.deleteRule(id);
    ref.invalidate(weeklyScheduleRuleListControllerProvider);
  }
}
