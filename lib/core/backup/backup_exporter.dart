import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../../features/semester/data/models/semester_local.dart';
import '../../features/subject/data/models/subject_local.dart';
import '../../features/timetable/data/models/timetable_template_local.dart';
import '../event_generator/data/models/event_local.dart';
import '../../features/attendance/data/models/attendance_record_local.dart';
import '../notifications/models/notification_item.dart';
import '../../features/settings/data/models/user_preferences_local.dart';
import '../../features/timetable/data/models/schedule_exception_local.dart';
import '../../features/timetable/data/models/weekly_schedule_rule_local.dart';
import '../../features/timetable/data/models/daily_schedule_occurrence_local.dart';
import '../../features/timetable/data/models/academic_event_local.dart';
import '../../features/academic_planner/data/models/academic_task_local.dart';
import '../database/migration_audit_record_local.dart';
import 'backup_models.dart';

class BackupExporter {
  final Isar _isar;

  BackupExporter(this._isar);

  Future<BackupData> exportData({String appVersion = '1.1.0'}) async {
    final preferencesList = _isar.userPreferencesLocals.where().findAll();
    final semesterList = _isar.semesterLocals.where().findAll();
    final subjectList = _isar.subjectLocals.where().findAll();
    final timetableList = _isar.timetableTemplateLocals.where().findAll();
    final eventList = _isar.eventLocals.where().findAll();
    final attendanceList = _isar.attendanceRecordLocals.where().findAll();
    final notificationList = _isar.notificationItems.where().findAll();
    final exceptionList = _isar.scheduleExceptionLocals.where().findAll();
    final ruleList = _isar.weeklyScheduleRuleLocals.where().findAll();
    final occurrenceList = _isar.dailyScheduleOccurrenceLocals.where().findAll();
    final academicEventList = _isar.academicEventLocals.where().findAll();
    final taskList = _isar.academicTaskLocals.where().findAll();
    final migrationAuditList = _isar.migrationAuditRecordLocals.where().findAll();

    final metadata = BackupMetadata(
      appVersion: appVersion,
      backupVersion: 2,
      createdAt: DateTime.now().toUtc(),
      devicePlatform: kIsWeb ? 'web' : Platform.operatingSystem,
    );

    return BackupData(
      metadata: metadata,
      userPreferences: preferencesList.map((p) => {
        'id': p.id,
        'serverId': p.serverId,
        'themeMode': p.themeMode,
        'defaultAttendanceTarget': p.defaultAttendanceTarget,
        'classReminderOffset': p.classReminderOffset,
        'enableNotifications': p.enableNotifications,
        'enableAttendanceWarnings': p.enableAttendanceWarnings,
        'weeklyReportEnabled': p.weeklyReportEnabled,
        'lastSyncTime': p.lastSyncTime?.toIso8601String(),
        'updatedAt': p.updatedAt.toIso8601String(),
        'isDirty': p.isDirty,
        'isDeleted': p.isDeleted,
      }).toList(),
      semesters: semesterList.map((s) => s.toJson()).toList(),
      subjects: subjectList.map((s) => {
        'id': s.id,
        'serverId': s.serverId,
        'semesterId': s.semesterId,
        'name': s.name,
        'code': s.code,
        'faculty': s.faculty,
        'credits': s.credits,
        'attendanceTarget': s.attendanceTarget,
        'color': s.color,
        'type': s.type,
        'createdAt': s.createdAt.toIso8601String(),
        'updatedAt': s.updatedAt.toIso8601String(),
        'isDirty': s.isDirty,
        'isDeleted': s.isDeleted,
      }).toList(),
      attendance: attendanceList.map((a) => {
        'id': a.id,
        'serverId': a.serverId,
        'occurrenceId': a.occurrenceId,
        'legacyEventId': a.legacyEventId,
        'eventId': a.occurrenceId ?? a.eventId,
        'subjectId': a.subjectId,
        'status': a.status,
        'markedAt': a.markedAt.toIso8601String(),
        'createdAt': a.createdAt.toIso8601String(),
        'updatedAt': a.updatedAt.toIso8601String(),
        'isDirty': a.isDirty,
        'isDeleted': a.isDeleted,
      }).toList(),
      timetable: timetableList.map((t) => {
        'id': t.id,
        'serverId': t.serverId,
        'subjectId': t.subjectId,
        'weekday': t.weekday,
        'startTime': t.startTime,
        'endTime': t.endTime,
        'room': t.room,
        'faculty': t.faculty,
        'notes': t.notes,
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
        'isDirty': t.isDirty,
        'isDeleted': t.isDeleted,
      }).toList(),
      events: eventList.map((e) => {
        'id': e.id,
        'serverId': e.serverId,
        'subjectId': e.subjectId,
        'date': e.date.toIso8601String(),
        'startTime': e.startTime,
        'endTime': e.endTime,
        'eventType': e.eventType,
        'status': e.status,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
        'isDirty': e.isDirty,
        'isDeleted': e.isDeleted,
      }).toList(),
      notifications: notificationList.map((n) => {
        'id': n.id,
        'title': n.title,
        'body': n.body,
        'type': n.type,
        'scheduledTime': n.scheduledTime.toIso8601String(),
        'relatedId': n.relatedId,
        'isRead': n.isRead,
      }).toList(),
      scheduleExceptions: exceptionList.map((e) => {
        'id': e.id,
        'serverId': e.serverId,
        'date': e.date.toIso8601String(),
        'subjectId': e.subjectId,
        'type': e.type,
        'title': e.title,
        'description': e.description,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
        'isDirty': e.isDirty,
        'isDeleted': e.isDeleted,
      }).toList(),
      weeklyRules: ruleList.map((r) => {
        'id': r.id,
        'serverId': r.serverId,
        'subjectId': r.subjectId,
        'legacyTemplateId': r.legacyTemplateId,
        'dayOfWeek': r.dayOfWeek,
        'startTime': r.startTime,
        'endTime': r.endTime,
        'room': r.room,
        'faculty': r.faculty,
        'type': r.type,
        'isActive': r.isActive,
        'createdAt': r.createdAt.toIso8601String(),
        'updatedAt': r.updatedAt.toIso8601String(),
        'isDirty': r.isDirty,
        'isDeleted': r.isDeleted,
      }).toList(),
      occurrences: occurrenceList.map((o) => {
        'id': o.id,
        'serverId': o.serverId,
        'date': o.date.toIso8601String(),
        'subjectId': o.subjectId,
        'ruleId': o.ruleId,
        'legacyEventId': o.legacyEventId,
        'slotKey': o.slotKey,
        'title': o.title,
        'startTime': o.startTime,
        'endTime': o.endTime,
        'type': o.type,
        'status': o.status,
        'createdFrom': o.createdFrom,
        'room': o.room,
        'faculty': o.faculty,
        'reason': o.reason,
        'createdAt': o.createdAt.toIso8601String(),
        'updatedAt': o.updatedAt.toIso8601String(),
        'isDirty': o.isDirty,
        'isDeleted': o.isDeleted,
      }).toList(),
      academicEvents: academicEventList.map((a) => {
        'id': a.id,
        'serverId': a.serverId,
        'title': a.title,
        'description': a.description,
        'date': a.date.toIso8601String(),
        'startTime': a.startTime,
        'endTime': a.endTime,
        'type': a.type,
        'createdAt': a.createdAt.toIso8601String(),
        'updatedAt': a.updatedAt.toIso8601String(),
        'isDirty': a.isDirty,
        'isDeleted': a.isDeleted,
      }).toList(),
      tasks: taskList.map((tk) => {
        'id': tk.id,
        'serverId': tk.serverId,
        'subjectId': tk.subjectId,
        'title': tk.title,
        'description': tk.description,
        'startDate': tk.startDate.toIso8601String(),
        'dueDate': tk.dueDate.toIso8601String(),
        'priority': tk.priority,
        'taskType': tk.taskType,
        'status': tk.status,
        'reminder': tk.reminder,
        'createdAt': tk.createdAt.toIso8601String(),
        'updatedAt': tk.updatedAt.toIso8601String(),
        'isDirty': tk.isDirty,
        'isDeleted': tk.isDeleted,
      }).toList(),
      migrationAudits: migrationAuditList.map((a) => a.toJson()).toList(),
      reportsMetadata: {},
    );
  }

  Future<String> exportToJsonString({String appVersion = '1.1.0'}) async {
    final data = await exportData(appVersion: appVersion);
    return const JsonEncoder.withIndent('  ').convert(data.toJson());
  }
}
