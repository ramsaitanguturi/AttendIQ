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
import 'backup_models.dart';

class BackupExporter {
  final Isar _isar;

  BackupExporter(this._isar);

  Future<BackupData> exportData({String appVersion = '1.1.0'}) async {
    final preferencesList = await _isar.userPreferencesLocals.where().findAll();
    final semesterList = await _isar.semesterLocals.where().findAll();
    final subjectList = await _isar.subjectLocals.where().findAll();
    final timetableList = await _isar.timetableTemplateLocals.where().findAll();
    final eventList = await _isar.eventLocals.where().findAll();
    final attendanceList = await _isar.attendanceRecordLocals.where().findAll();
    final notificationList = await _isar.notificationItems.where().findAll();

    final metadata = BackupMetadata(
      appVersion: appVersion,
      backupVersion: 1,
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
        'eventId': a.eventId,
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
      reportsMetadata: {},
    );
  }

  Future<String> exportToJsonString({String appVersion = '1.1.0'}) async {
    final data = await exportData(appVersion: appVersion);
    return const JsonEncoder.withIndent('  ').convert(data.toJson());
  }
}
