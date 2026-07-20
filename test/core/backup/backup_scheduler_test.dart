import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/backup/backup_scheduler.dart';
import 'package:attend_iq/core/backup/backup_path_helper.dart';

void main() {
  group('BackupScheduler Unit Tests', () {
    test('getNextScheduledBackup from Monday returns upcoming Sunday 2 AM', () {
      // Monday 2026-07-20 10:00 AM
      final mondayDate = DateTime(2026, 7, 20, 10, 0);
      final nextScheduled = BackupScheduler.getNextScheduledBackup(
        fromDate: mondayDate,
        targetWeekday: DateTime.sunday,
        targetHour: 2,
      );

      // Should be Sunday 2026-07-26 02:00 AM
      expect(nextScheduled.year, 2026);
      expect(nextScheduled.month, 7);
      expect(nextScheduled.day, 26);
      expect(nextScheduled.hour, 2);
      expect(nextScheduled.weekday, DateTime.sunday);
    });

    test('getNextScheduledBackup from Sunday early morning returns today 2 AM', () {
      // Sunday 2026-07-26 01:30 AM
      final sundayEarly = DateTime(2026, 7, 26, 1, 30);
      final nextScheduled = BackupScheduler.getNextScheduledBackup(
        fromDate: sundayEarly,
        targetWeekday: DateTime.sunday,
        targetHour: 2,
      );

      expect(nextScheduled.day, 26);
      expect(nextScheduled.hour, 2);
    });

    test('getNextScheduledBackup from Sunday after 2 AM returns next Sunday 2 AM', () {
      // Sunday 2026-07-26 03:00 AM
      final sundayLate = DateTime(2026, 7, 26, 3, 0);
      final nextScheduled = BackupScheduler.getNextScheduledBackup(
        fromDate: sundayLate,
        targetWeekday: DateTime.sunday,
        targetHour: 2,
      );

      // Should be next Sunday Aug 2, 2026
      expect(nextScheduled.year, 2026);
      expect(nextScheduled.month, 8);
      expect(nextScheduled.day, 2);
      expect(nextScheduled.hour, 2);
    });
  });

  group('BackupPathHelper Unit Tests', () {
    test('getDisplayFolderPath returns valid display string', () {
      final pathStr = BackupPathHelper.getDisplayFolderPath();
      expect(pathStr, contains('Documents/AttendIQ Backups'));
    });

    test('BackupFileItem formattedSize formats bytes correctly', () {
      final itemBytes = BackupFileItem(
        fileName: 'test.attendiq',
        filePath: '/path/test.attendiq',
        modifiedDate: DateTime.now(),
        sizeBytes: 500,
      );
      expect(itemBytes.formattedSize, '500 B');

      final itemKb = BackupFileItem(
        fileName: 'test.attendiq',
        filePath: '/path/test.attendiq',
        modifiedDate: DateTime.now(),
        sizeBytes: 1536, // 1.5 KB
      );
      expect(itemKb.formattedSize, '1.5 KB');

      final itemMb = BackupFileItem(
        fileName: 'test.attendiq',
        filePath: '/path/test.attendiq',
        modifiedDate: DateTime.now(),
        sizeBytes: 2621440, // 2.5 MB
      );
      expect(itemMb.formattedSize, '2.5 MB');
    });
  });
}
