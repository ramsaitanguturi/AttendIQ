import 'dart:io';

import 'package:attend_iq/core/backup/backup_path_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel storageChannel =
      MethodChannel('com.ramsa.attendiq/storage');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  group('BackupPathHelper Unit Tests', () {
    test('formatSemesterForFileName sanitizes and formats semester names', () {
      expect(BackupPathHelper.formatSemesterForFileName('Semester 5'), 'Sem5');
      expect(BackupPathHelper.formatSemesterForFileName('Semester_5'), 'Sem5');
      expect(BackupPathHelper.formatSemesterForFileName('Sem 5'), 'Sem5');
      expect(
        BackupPathHelper.formatSemesterForFileName('Spring 2026'),
        'Spring_2026',
      );
      expect(BackupPathHelper.formatSemesterForFileName(''), 'Sem1');
      expect(BackupPathHelper.formatSemesterForFileName(null), 'Sem1');
    });

    test(
      'generateFileName produces standardized filenames with app prefix, type, semester, and date',
      () async {
        final date = DateTime(2026, 7, 21);
        final filename = await BackupPathHelper.generateFileName(
          type: 'Backup',
          extension: 'attendiq',
          semesterName: 'Semester 5',
          date: date,
        );

        expect(filename, contains('Backup_Sem5_2026-07-21.attendiq'));
      },
    );

    test('generateFileName produces valid PDF report filename', () async {
      final date = DateTime(2026, 7, 21);
      final filename = await BackupPathHelper.generateFileName(
        type: 'Attendance_Report',
        extension: 'pdf',
        semesterName: 'Sem 5',
        date: date,
      );

      expect(filename, contains('Attendance_Report_Sem5_2026-07-21.pdf'));
    });

    test('generateFileName produces valid CSV report filename', () async {
      final date = DateTime(2026, 7, 21);
      final filename = await BackupPathHelper.generateFileName(
        type: 'Attendance_Report',
        extension: 'csv',
        semesterName: 'Sem 5',
        date: date,
      );

      expect(filename, contains('Attendance_Report_Sem5_2026-07-21.csv'));
    });

    test(
      'getAppBackupsDirectory and getPrivateExportsDirectory remain separate',
      () async {
        final tempBase = await Directory.systemTemp.createTemp('bph_sep_');
        try {
          final backupsDir = await BackupPathHelper.getAppBackupsDirectory(
            baseDirectoryOverride: tempBase,
          );
          final exportsDir = await BackupPathHelper.getPrivateExportsDirectory(
            subFolder: 'Reports',
            baseDirectoryOverride: tempBase,
          );

          expect(backupsDir.path, isNot(equals(exportsDir.path)));
          expect(
            backupsDir.path.toLowerCase(),
            endsWith('${Platform.pathSeparator}backups'),
          );
          expect(
            exportsDir.path.toLowerCase(),
            endsWith('${Platform.pathSeparator}reports'),
          );
          expect(backupsDir.path, isNot(contains('/storage/emulated/0')));
          expect(exportsDir.path, isNot(contains('/storage/emulated/0')));
        } finally {
          if (await tempBase.exists()) {
            await tempBase.delete(recursive: true);
          }
        }
      },
    );

    test(
      'validateFileName rejects traversal segments, separators, and NUL bytes',
      () {
        expect(
          () => BackupPathHelper.validateFileName('../secret.attendiq'),
          throwsA(isA<FileSystemException>()),
        );
        expect(
          () => BackupPathHelper.validateFileName(r'sub\file.attendiq'),
          throwsA(isA<FileSystemException>()),
        );
        expect(
          () => BackupPathHelper.validateFileName('sub/file.attendiq'),
          throwsA(isA<FileSystemException>()),
        );
        expect(
          () => BackupPathHelper.validateFileName('bad\u0000.attendiq'),
          throwsA(isA<FileSystemException>()),
        );
        expect(
          BackupPathHelper.validateFileName('AttendIQ_Backup_Sem1.attendiq'),
          'AttendIQ_Backup_Sem1.attendiq',
        );
      },
    );

    test(
      'openExportUri only invokes channel for content:// URIs',
      () async {
        String? invokedUri;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(storageChannel, (call) async {
          if (call.method == 'openExportUri') {
            final args = call.arguments as Map<dynamic, dynamic>;
            invokedUri = args['contentUri'] as String?;
            return true;
          }
          return null;
        });

        expect(
          await BackupPathHelper.openExportUri(
            contentUri: '/storage/emulated/0/Documents/test.pdf',
            mimeType: 'application/pdf',
            isAndroidOverride: true,
          ),
          isFalse,
        );
        expect(invokedUri, isNull);

        expect(
          await BackupPathHelper.openExportUri(
            contentUri: 'content://media/external/file/99',
            mimeType: 'application/pdf',
            isAndroidOverride: true,
          ),
          isTrue,
        );
        expect(invokedUri, 'content://media/external/file/99');
      },
    );
  });
}
