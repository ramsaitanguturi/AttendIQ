import 'package:flutter_test/flutter_test.dart';
import 'package:attend_iq/core/backup/backup_path_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackupPathHelper Unit Tests', () {
    test('formatSemesterForFileName sanitizes and formats semester names', () {
      expect(BackupPathHelper.formatSemesterForFileName('Semester 5'), 'Sem5');
      expect(BackupPathHelper.formatSemesterForFileName('Semester_5'), 'Sem5');
      expect(BackupPathHelper.formatSemesterForFileName('Sem 5'), 'Sem5');
      expect(BackupPathHelper.formatSemesterForFileName('Spring 2026'), 'Spring_2026');
      expect(BackupPathHelper.formatSemesterForFileName(''), 'Sem1');
      expect(BackupPathHelper.formatSemesterForFileName(null), 'Sem1');
    });

    test('generateFileName produces standardized filenames with app prefix, type, semester, and date', () async {
      final date = DateTime(2026, 7, 21);
      final filename = await BackupPathHelper.generateFileName(
        type: 'Backup',
        extension: 'attendiq',
        semesterName: 'Semester 5',
        date: date,
      );

      expect(filename, contains('Backup_Sem5_2026-07-21.attendiq'));
    });

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
  });
}
