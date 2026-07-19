import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/domain/repositories/subject_repository.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/domain/repositories/attendance_repository.dart';

import 'package:attend_iq/core/reports/services/report_service.dart';
import 'package:attend_iq/core/reports/models/attendance_report.dart';
import 'package:attend_iq/core/reports/models/subject_report.dart';
import 'package:attend_iq/core/reports/generators/pdf_report_generator.dart';
import 'package:attend_iq/core/reports/exporters/csv_report_exporter.dart';
import 'package:attend_iq/core/analytics/models/risk_status.dart';

// Fakes
class FakeIsar extends Fake implements Isar {}

class FakeSemesterRepository implements SemesterRepository {
  Semester? activeSemester;

  @override
  Future<Semester?> getActiveSemester() async => activeSemester;

  @override
  Future<bool> hasActiveSemester() async => activeSemester != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSubjectRepository implements SubjectRepository {
  final List<Subject> subjects = [];

  @override
  Future<List<Subject>> getSubjectsBySemester(int semesterId) async => subjects;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAttendanceRepository implements AttendanceRepository {
  final Map<int, List<AttendanceRecord>> records = {};

  @override
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId) async {
    return records[subjectId] ?? [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestReportService extends ReportService {
  final int? mockSemesterId;

  TestReportService({
    required this.mockSemesterId,
    required super.semesterRepository,
    required super.subjectRepository,
    required super.attendanceRepository,
  }) : super(isar: FakeIsar());

  @override
  Future<int?> getActiveSemesterLocalId() async {
    return mockSemesterId;
  }
}

void main() {
  group('Reports System Unit Tests', () {
    late FakeSemesterRepository semesterRepository;
    late FakeSubjectRepository subjectRepository;
    late FakeAttendanceRepository attendanceRepository;
    late TestReportService reportService;

    setUp(() {
      semesterRepository = FakeSemesterRepository();
      subjectRepository = FakeSubjectRepository();
      attendanceRepository = FakeAttendanceRepository();

      reportService = TestReportService(
        mockSemesterId: 1,
        semesterRepository: semesterRepository,
        subjectRepository: subjectRepository,
        attendanceRepository: attendanceRepository,
      );
    });

    test('generateSemesterReport returns null if no active semester', () async {
      final report = await reportService.generateSemesterReport();
      expect(report, isNull);
    });

    test('generateSemesterReport handles empty data gracefully (no subjects)', () async {
      semesterRepository.activeSemester = Semester(
        id: '1',
        name: 'Fall 2026',
        startDate: DateTime.utc(2026, 8, 1),
        endDate: DateTime.utc(2026, 12, 1),
        requiredAttendanceRate: 75.0,
      );
      final report = await reportService.generateSemesterReport();
      expect(report, isNotNull);
      expect(report!.studentName, 'Student');
      expect(report.semesterName, 'Fall 2026');
      expect(report.overallPercentage, 100.0);
      expect(report.totalClasses, 0);
      expect(report.subjectReports, isEmpty);
    });

    test('generateSemesterReport calculates correct metrics and risk levels', () async {
      semesterRepository.activeSemester = Semester(
        id: '1',
        name: 'Fall 2026',
        startDate: DateTime.utc(2026, 8, 1),
        endDate: DateTime.utc(2026, 12, 1),
        requiredAttendanceRate: 75.0,
      );

      final sub1 = Subject(
        id: 10,
        semesterId: 1,
        name: 'Mathematics',
        code: 'MATH101',
        faculty: 'Dr. Euler',
        credits: 4,
        attendanceTarget: 75.0,
        color: '#FF0000',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now(),
      );
      final sub2 = Subject(
        id: 20,
        semesterId: 1,
        name: 'Physics',
        code: 'PHYS101',
        faculty: 'Dr. Newton',
        credits: 3,
        attendanceTarget: 75.0,
        color: '#0000FF',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now(),
      );
      final sub3 = Subject(
        id: 30,
        semesterId: 1,
        name: 'Chemistry',
        code: 'CHEM101',
        faculty: 'Dr. Boyle',
        credits: 3,
        attendanceTarget: 75.0,
        color: '#00FF00',
        type: SubjectType.THEORY,
        updatedAt: DateTime.now(),
      );

      subjectRepository.subjects.addAll([sub1, sub2, sub3]);

      // MATH101: 8 present, 2 absent -> 80% (Safe status: 80 - 75 = 5 > 2.5)
      attendanceRepository.records[10] = List.generate(
        8,
        (i) => AttendanceRecord(
          id: i,
          eventId: i,
          subjectId: 10,
          status: AttendanceStatus.PRESENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ) + List.generate(
        2,
        (i) => AttendanceRecord(
          id: 100 + i,
          eventId: 100 + i,
          subjectId: 10,
          status: AttendanceStatus.ABSENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // PHYS101: 7 present, 3 absent -> 70% (Critical status: 70 < 75)
      attendanceRepository.records[20] = List.generate(
        7,
        (i) => AttendanceRecord(
          id: 20 + i,
          eventId: 20 + i,
          subjectId: 20,
          status: AttendanceStatus.PRESENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ) + List.generate(
        3,
        (i) => AttendanceRecord(
          id: 200 + i,
          eventId: 200 + i,
          subjectId: 20,
          status: AttendanceStatus.ABSENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // CHEM101: 23 present, 7 absent -> 76.67% (Warning status: 76.67 - 75 = 1.67 <= 2.5)
      attendanceRepository.records[30] = List.generate(
        23,
        (i) => AttendanceRecord(
          id: 30 + i,
          eventId: 30 + i,
          subjectId: 30,
          status: AttendanceStatus.PRESENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ) + List.generate(
        7,
        (i) => AttendanceRecord(
          id: 300 + i,
          eventId: 300 + i,
          subjectId: 30,
          status: AttendanceStatus.ABSENT,
          markedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final report = await reportService.generateSemesterReport();
      expect(report, isNotNull);
      expect(report!.totalClasses, 50); // 10 + 10 + 30
      expect(report.totalPresent, 38); // 8 + 7 + 23
      expect(report.totalAbsent, 12); // 2 + 3 + 7
      expect(report.overallPercentage, closeTo(76.0, 0.01)); // 38 / 50 * 100

      final mathReport = report.subjectReports.firstWhere((s) => s.subjectName == 'Mathematics');
      expect(mathReport.percentage, 80.0);
      expect(mathReport.riskStatus, RiskStatus.SAFE);

      final physReport = report.subjectReports.firstWhere((s) => s.subjectName == 'Physics');
      expect(physReport.percentage, 70.0);
      expect(physReport.riskStatus, RiskStatus.CRITICAL);

      final chemReport = report.subjectReports.firstWhere((s) => s.subjectName == 'Chemistry');
      expect(chemReport.percentage, closeTo(76.67, 0.1));
      expect(chemReport.riskStatus, RiskStatus.WARNING);
    });

    test('PdfReportGenerator compiles a valid document', () async {
      final mockReport = AttendanceReport(
        studentName: 'Alice Smith',
        semesterName: 'Fall 2026',
        generatedDate: DateTime.now(),
        overallPercentage: 76.0,
        totalClasses: 50,
        totalPresent: 38,
        totalAbsent: 12,
        subjectReports: [
          SubjectReport(
            subjectName: 'Mathematics',
            faculty: 'Dr. Euler',
            percentage: 80.0,
            present: 8,
            absent: 2,
            totalClasses: 10,
            riskStatus: RiskStatus.SAFE,
          ),
          SubjectReport(
            subjectName: 'Physics',
            faculty: 'Dr. Newton',
            percentage: 70.0,
            present: 7,
            absent: 3,
            totalClasses: 10,
            riskStatus: RiskStatus.CRITICAL,
          ),
        ],
      );

      final bytes = await PdfReportGenerator.generatePdf(mockReport);
      expect(bytes, isNotEmpty);
    });

    test('CsvReportExporter formats correct CSV columns and rows', () async {
      final mockReport = AttendanceReport(
        studentName: 'Alice Smith',
        semesterName: 'Fall 2026',
        generatedDate: DateTime.now(),
        overallPercentage: 76.0,
        totalClasses: 50,
        totalPresent: 38,
        totalAbsent: 12,
        subjectReports: [
          SubjectReport(
            subjectName: 'Mathematics',
            faculty: 'Dr. Euler',
            percentage: 80.0,
            present: 8,
            absent: 2,
            totalClasses: 10,
            riskStatus: RiskStatus.SAFE,
          ),
        ],
      );

      final csv = CsvReportExporter.exportToCsv(mockReport);
      expect(csv, contains('Subject,Faculty,Present,Absent,Total,Percentage'));
      expect(csv, contains('Mathematics,Dr. Euler,8,2,10,80.0%'));
    });
  });
}
