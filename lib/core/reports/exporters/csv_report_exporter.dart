import 'package:csv/csv.dart';
import '../models/attendance_report.dart';

class CsvReportExporter {
  static String exportToCsv(AttendanceReport report) {
    final List<List<dynamic>> rows = [];

    // Header Row
    rows.add([
      'Subject',
      'Faculty',
      'Present',
      'Absent',
      'Total',
      'Percentage',
    ]);

    for (final sub in report.subjectReports) {
      rows.add([
        sub.subjectName,
        sub.faculty ?? 'N/A',
        sub.present,
        sub.absent,
        sub.totalClasses,
        '${sub.percentage.toStringAsFixed(1)}%',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
