import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/core/backup/backup_models.dart';
import 'package:attend_iq/core/backup/backup_importer.dart';

class FakeIsar extends Fake implements Isar {}

void main() {
  group('Backup & Restore Unit Tests', () {
    test('BackupMetadata serialization and deserialization', () {
      final meta = BackupMetadata(
        appVersion: '1.1.0',
        backupVersion: 1,
        createdAt: DateTime.utc(2026, 7, 19),
        devicePlatform: 'android',
      );

      final json = meta.toJson();
      expect(json['appVersion'], '1.1.0');
      expect(json['backupVersion'], 1);
      expect(json['devicePlatform'], 'android');

      final deserialized = BackupMetadata.fromJson(json);
      expect(deserialized.appVersion, '1.1.0');
      expect(deserialized.backupVersion, 1);
      expect(deserialized.devicePlatform, 'android');
    });

    test('BackupData serialization and deserialization', () {
      final meta = BackupMetadata(
        appVersion: '1.1.0',
        backupVersion: 1,
        createdAt: DateTime.utc(2026, 7, 19),
        devicePlatform: 'windows',
      );

      final backupData = BackupData(
        metadata: meta,
        userPreferences: [
          {
            'id': 1,
            'serverId': 'local_user',
            'themeMode': 'dark',
            'defaultAttendanceTarget': 80.0,
            'classReminderOffset': 5,
            'enableNotifications': true,
            'enableAttendanceWarnings': true,
            'weeklyReportEnabled': true,
          }
        ],
        semesters: [
          {
            'id': 101,
            'serverId': 'sem_1',
            'name': 'Fall 2026',
            'startDate': '2026-08-01T00:00:00.000Z',
            'endDate': '2026-12-01T00:00:00.000Z',
            'requiredAttendanceRate': 75.0,
            'createdAt': '2026-07-19T00:00:00.000Z',
            'updatedAt': '2026-07-19T00:00:00.000Z',
            'isDirty': false,
            'isDeleted': false,
          }
        ],
        subjects: [
          {
            'id': 201,
            'serverId': 'sub_1',
            'semesterId': 101,
            'name': 'Algorithms',
            'code': 'CS201',
            'credits': 4,
            'attendanceTarget': 75.0,
            'color': '0xFF10B981',
            'type': 'THEORY',
          }
        ],
        attendance: [],
        timetable: [],
        events: [],
        notifications: [],
      );

      final json = backupData.toJson();
      final parsed = BackupData.fromJson(json);

      expect(parsed.metadata.appVersion, '1.1.0');
      expect(parsed.semesters.length, 1);
      expect(parsed.semesters.first['name'], 'Fall 2026');
      expect(parsed.subjects.length, 1);
      expect(parsed.subjects.first['code'], 'CS201');
      expect(parsed.userPreferences.first['themeMode'], 'dark');
    });

    test('BackupImporter throws FormatException on corrupted JSON', () {
      final importer = BackupImporter(FakeIsar());
      expect(
        () => importer.parseAndValidateJson('invalid-json-string{{'),
        throwsA(isA<FormatException>()),
      );
    });

    test('BackupImporter throws FormatException on higher unsupported backupVersion', () {
      final importer = BackupImporter(FakeIsar());
      final invalidVersionJson = '''
      {
        "metadata": {
          "appVersion": "2.0.0",
          "backupVersion": 99,
          "createdAt": "2026-07-19T00:00:00.000Z",
          "devicePlatform": "android"
        },
        "semesters": [],
        "subjects": []
      }
      ''';

      expect(
        () => importer.parseAndValidateJson(invalidVersionJson),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Unsupported backup version 99'),
          ),
        ),
      );
    });
  });
}
