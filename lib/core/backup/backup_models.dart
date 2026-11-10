import 'dart:io';
import 'package:flutter/foundation.dart';

class BackupMetadata {
  final String appVersion;
  final int backupVersion;
  final DateTime createdAt;
  final String devicePlatform;

  BackupMetadata({
    required this.appVersion,
    this.backupVersion = 1,
    required this.createdAt,
    required this.devicePlatform,
  });

  Map<String, dynamic> toJson() => {
        'appVersion': appVersion,
        'backupVersion': backupVersion,
        'createdAt': createdAt.toIso8601String(),
        'devicePlatform': devicePlatform,
      };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      backupVersion: json['backupVersion'] as int? ?? 1,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      devicePlatform: json['devicePlatform'] as String? ?? (kIsWeb ? 'web' : Platform.operatingSystem),
    );
  }
}

class BackupData {
  final BackupMetadata metadata;
  final List<Map<String, dynamic>> userPreferences;
  final List<Map<String, dynamic>> semesters;
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> attendance;
  final List<Map<String, dynamic>> timetable;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> notifications;
  final List<Map<String, dynamic>> scheduleExceptions;
  final List<Map<String, dynamic>> weeklyRules;
  final List<Map<String, dynamic>> occurrences;
  final List<Map<String, dynamic>> academicEvents;
  final List<Map<String, dynamic>> tasks;
  final Map<String, dynamic> reportsMetadata;

  BackupData({
    required this.metadata,
    required this.userPreferences,
    required this.semesters,
    required this.subjects,
    required this.attendance,
    required this.timetable,
    required this.events,
    required this.notifications,
    this.scheduleExceptions = const [],
    this.weeklyRules = const [],
    this.occurrences = const [],
    this.academicEvents = const [],
    this.tasks = const [],
    this.reportsMetadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'metadata': metadata.toJson(),
        'userPreferences': userPreferences,
        'semesters': semesters,
        'subjects': subjects,
        'attendance': attendance,
        'timetable': timetable,
        'events': events,
        'notifications': notifications,
        'scheduleExceptions': scheduleExceptions,
        'weeklyRules': weeklyRules,
        'occurrences': occurrences,
        'academicEvents': academicEvents,
        'tasks': tasks,
        'reportsMetadata': reportsMetadata,
      };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      metadata: BackupMetadata.fromJson(
        Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      ),
      userPreferences: (json['userPreferences'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      semesters: (json['semesters'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      subjects: (json['subjects'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      attendance: (json['attendance'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      timetable: (json['timetable'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      events: (json['events'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      notifications: (json['notifications'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      scheduleExceptions: (json['scheduleExceptions'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      weeklyRules: (json['weeklyRules'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      occurrences: (json['occurrences'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      academicEvents: (json['academicEvents'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      tasks: (json['tasks'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      reportsMetadata: Map<String, dynamic>.from(json['reportsMetadata'] as Map? ?? {}),
    );
  }
}
