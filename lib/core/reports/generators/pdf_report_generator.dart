import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../analytics/models/risk_status.dart';
import '../models/attendance_report.dart';

class PdfReportGenerator {
  static Future<List<int>> generatePdf(AttendanceReport report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'AttendIQ Attendance Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Date: ${report.generatedDate.toLocal().toString().split(' ').first}',
                      style: const pw.TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.SizedBox(height: 16),

                // Student and Semester Details
                pw.Text(
                  'Student & Semester Details',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Student Name: ${report.studentName}'),
                    pw.Text('Semester: ${report.semesterName}'),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Overall Attendance Summary
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            '${report.overallPercentage.toStringAsFixed(1)}%',
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                              color: report.overallPercentage >= 75.0 ? PdfColors.green : PdfColors.red,
                            ),
                          ),
                          pw.Text('Overall Attendance'),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text('${report.totalClasses}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Total Classes'),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text('${report.totalPresent}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Present'),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text('${report.totalAbsent}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Absent'),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // Subject-wise Table
                pw.Text(
                  'Subject-wise Report',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  headers: ['Subject', 'Faculty', 'Present', 'Absent', 'Total', 'Percentage', 'Status'],
                  data: report.subjectReports.map((sub) {
                    return [
                      sub.subjectName,
                      sub.faculty ?? 'N/A',
                      '${sub.present}',
                      '${sub.absent}',
                      '${sub.totalClasses}',
                      '${sub.percentage.toStringAsFixed(1)}%',
                      sub.riskStatus.name,
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
                pw.SizedBox(height: 24),

                // Risk Subjects Summary
                ..._buildRiskSection(report),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static List<pw.Widget> _buildRiskSection(AttendanceReport report) {
    final criticalSubjects = report.subjectReports
        .where((sub) => sub.riskStatus == RiskStatus.CRITICAL)
        .toList();
    final warningSubjects = report.subjectReports
        .where((sub) => sub.riskStatus == RiskStatus.WARNING)
        .toList();

    if (criticalSubjects.isEmpty && warningSubjects.isEmpty) {
      return [
        pw.Text(
          'Status: Excellent! All subjects are in the safe zone.',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green),
        )
      ];
    }

    final List<pw.Widget> widgets = [];
    widgets.add(pw.Text('Risk Assessment', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)));
    widgets.add(pw.SizedBox(height: 8));

    if (criticalSubjects.isNotEmpty) {
      widgets.add(
        pw.Text(
          'Critical Subjects (Below Target):',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red),
        ),
      );
      for (final sub in criticalSubjects) {
        widgets.add(pw.Bullet(text: '${sub.subjectName} (${sub.percentage.toStringAsFixed(1)}%)'));
      }
      widgets.add(pw.SizedBox(height: 8));
    }

    if (warningSubjects.isNotEmpty) {
      widgets.add(
        pw.Text(
          'Warning Subjects (Near Threshold):',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.orange),
        ),
      );
      for (final sub in warningSubjects) {
        widgets.add(pw.Bullet(text: '${sub.subjectName} (${sub.percentage.toStringAsFixed(1)}%)'));
      }
    }

    return widgets;
  }
}
