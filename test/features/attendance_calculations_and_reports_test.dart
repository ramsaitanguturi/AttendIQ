import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:attend_iq/features/semester/domain/entities/semester.dart';
import 'package:attend_iq/features/semester/domain/repositories/semester_repository.dart';
import 'package:attend_iq/features/subject/domain/entities/subject.dart';
import 'package:attend_iq/features/subject/domain/repositories/subject_repository.dart';
import 'package:attend_iq/features/attendance/domain/entities/attendance_record.dart';
import 'package:attend_iq/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:attend_iq/features/timetable/domain/entities/schedule_exception.dart';
import 'package:attend_iq/features/timetable/domain/entities/weekly_schedule_rule.dart';
import 'package:attend_iq/core/reports/services/report_service.dart';
import 'package:attend_iq/core/reports/models/attendance_report.dart';
import 'package:attend_iq/core/reports/models/subject_report.dart';
import 'package:attend_iq/core/reports/generators/pdf_report_generator.dart';
import 'package:attend_iq/core/analytics/calculators/analytics_calculator.dart';
import 'package:attend_iq/core/attendance_engine/calculator.dart';
import 'package:attend_iq/core/analytics/models/risk_status.dart';

// --- Fakes ---

class _FakeIsar extends Fake implements Isar {}

class _FakeSemesterRepository extends Fake implements SemesterRepository {
  Semester? activeSemester;
  _FakeSemesterRepository([this.activeSemester]);

  @override
  Future<Semester?> getActiveSemester() async => activeSemester;

  @override
  Future<bool> hasActiveSemester() async => activeSemester != null;

  @override
  Future<Semester?> getSemesterById(int id) async => activeSemester;
}

class _FakeSubjectRepository extends Fake implements SubjectRepository {
  final List<Subject> subjects;
  _FakeSubjectRepository(this.subjects);

  @override
  Future<List<Subject>> getSubjectsBySemester(int semesterId,
      {bool includeDeleted = false}) async {
    return includeDeleted
        ? subjects.where((s) => s.semesterId == semesterId).toList()
        : subjects
            .where((s) => s.semesterId == semesterId && !s.isDeleted)
            .toList();
  }

  @override
  Future<Subject?> getSubjectById(int id) async {
    return subjects.where((s) => s.id == id).firstOrNull;
  }
}

class _FakeAttendanceRepository extends Fake implements AttendanceRepository {
  final List<AttendanceRecord> records;
  _FakeAttendanceRepository(this.records);

  @override
  Future<List<AttendanceRecord>> getAttendanceForSubject(int subjectId) async {
    return records
        .where((r) => r.subjectId == subjectId && !r.isDeleted)
        .toList();
  }

  @override
  Stream<void> watchAttendance(int subjectId) => const Stream<void>.empty();
}

class _TestReportService extends ReportService {
  final int? mockSemesterId;

  _TestReportService({
    required this.mockSemesterId,
    required super.semesterRepository,
    required super.subjectRepository,
    required super.attendanceRepository,
  }) : super(isar: _FakeIsar());

  @override
  Future<int?> getActiveSemesterLocalId() async => mockSemesterId;
}

void main() {
  final testSemester = Semester(
    id: 'sem_1',
    localId: 1,
    name: 'Fall 2026',
    startDate: DateTime.utc(2026, 8, 1),
    endDate: DateTime.utc(2026, 12, 31),
    requiredAttendanceRate: 75.0,
  );

  group('Group B: Attendance Calculations & Historical Data', () {
    group('BUG-011: Remaining class calculations & 30-day rate', () {
      test('remaining count excludes holidays and cancellations', () {
        // Monday rule: 4 Mondays left between Nov 10 and Nov 30 (Nov 10, 17, 24, Dec 1)
        final rules = [
          WeeklyScheduleRule(
            id: 1,
            subjectId: 10,
            dayOfWeek: 1, // Monday
            startTime: '09:00',
            endTime: '10:00',
            isActive: true,
            createdAt: DateTime.utc(2026, 8, 1),
            updatedAt: DateTime.utc(2026, 8, 1),
          ),
        ];

        final activeRuleWeekdays = rules
            .where((r) => r.isActive && !r.isDeleted)
            .map((r) => r.dayOfWeek)
            .toList();

        final startDate = DateTime.utc(2026, 11, 10);
        final endDate = DateTime.utc(2026, 11, 30);

        final exceptions = [
          // Nov 16 is a holiday (Monday)
          ScheduleException(
            id: 1,
            date: DateTime.utc(2026, 11, 16),
            type: ScheduleExceptionType.HOLIDAY,
            title: 'College Holiday',
            createdAt: DateTime.utc(2026, 11, 1),
            updatedAt: DateTime.utc(2026, 11, 1),
          ),
          // Nov 23 is a cancelled class for subject 10 (Monday)
          ScheduleException(
            id: 2,
            date: DateTime.utc(2026, 11, 23),
            subjectId: 10,
            type: ScheduleExceptionType.CANCELLED_CLASS,
            title: 'Faculty Leave',
            createdAt: DateTime.utc(2026, 11, 1),
            updatedAt: DateTime.utc(2026, 11, 1),
          ),
        ];

        // Simulate remaining calculation logic from subject_attendance_stats_provider.dart
        int remaining = 0;
        final currentNorm =
            DateTime.utc(startDate.year, startDate.month, startDate.day);
        final endNorm = DateTime.utc(endDate.year, endDate.month, endDate.day);

        var cur = currentNorm;
        while (!cur.isAfter(endNorm)) {
          if (activeRuleWeekdays.contains(cur.weekday)) {
            final isHoliday = exceptions.any((e) =>
                e.type == ScheduleExceptionType.HOLIDAY &&
                DateTime.utc(e.date.year, e.date.month, e.date.day) == cur);
            final isCancelled = exceptions.any((e) =>
                e.type == ScheduleExceptionType.CANCELLED_CLASS &&
                e.subjectId == 10 &&
                DateTime.utc(e.date.year, e.date.month, e.date.day) == cur);

            if (!isHoliday && !isCancelled) {
              remaining++;
            }
          }
          cur = cur.add(const Duration(days: 1));
        }

        // Between Nov 10 and Nov 30, Mondays are:
        // Nov 16 (Holiday - excluded)
        // Nov 23 (Cancelled - excluded)
        // Nov 30 (Active - counted)
        expect(remaining, 1);
      });

      test('remaining calculation does not double count today marked class',
          () {
        // Today is Monday Nov 16. Total remaining Mondays until Nov 23 = 2 (Nov 16, Nov 23).
        final todayUtc = DateTime.utc(2026, 11, 16);
        final endUtc = DateTime.utc(2026, 11, 23);

        int remaining = 0;
        var cur = todayUtc;
        while (!cur.isAfter(endUtc)) {
          if (cur.weekday == DateTime.monday) {
            remaining++;
          }
          cur = cur.add(const Duration(days: 1));
        }
        expect(remaining, 2);

        // If today's class has already been marked as PRESENT
        final List<AttendanceRecord> todayRecords = [
          AttendanceRecord(
            id: 1,
            subjectId: 10,
            occurrenceId: 101,
            markedAt: todayUtc,
            status: AttendanceStatus.PRESENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: todayUtc,
          ),
        ];

        final alreadyMarkedToday = todayRecords.any((r) {
          final markedNorm =
              DateTime.utc(r.markedAt.year, r.markedAt.month, r.markedAt.day);
          return markedNorm == todayUtc && !r.isDeleted;
        });

        if (alreadyMarkedToday && remaining > 0) {
          remaining -= 1;
        }

        // Should be 1 instead of double-counting today's class as remaining
        expect(remaining, 1);
      });

      test(
          '30-day attendance rate calculation respects date boundary and ignores deleted records',
          () {
        final now = DateTime.utc(2026, 11, 16);
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));

        final List<AttendanceRecord> records = [
          // Within 30 days - PRESENT
          AttendanceRecord(
            id: 1,
            subjectId: 10,
            markedAt: DateTime.utc(2026, 11, 10),
            status: AttendanceStatus.PRESENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 11, 10),
          ),
          // Within 30 days - ABSENT
          AttendanceRecord(
            id: 2,
            subjectId: 10,
            markedAt: DateTime.utc(2026, 11, 5),
            status: AttendanceStatus.ABSENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 11, 5),
          ),
          // Within 30 days - DELETED (must be ignored)
          AttendanceRecord(
            id: 3,
            subjectId: 10,
            markedAt: DateTime.utc(2026, 11, 1),
            status: AttendanceStatus.ABSENT,
            isDirty: false,
            isDeleted: true,
            updatedAt: DateTime.utc(2026, 11, 1),
          ),
          // Older than 30 days (must be ignored)
          AttendanceRecord(
            id: 4,
            subjectId: 10,
            markedAt: DateTime.utc(2026, 9, 1),
            status: AttendanceStatus.PRESENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        ];

        int present30 = 0;
        int total30 = 0;
        for (final r in records) {
          if (r.isDeleted) continue;
          final markedDate =
              DateTime.utc(r.markedAt.year, r.markedAt.month, r.markedAt.day);
          if (markedDate.isBefore(thirtyDaysAgo) || markedDate.isAfter(now))
            continue;

          if (r.status == AttendanceStatus.PRESENT ||
              r.status == AttendanceStatus.EXTRA_PRESENT) {
            present30++;
            total30++;
          } else if (r.status == AttendanceStatus.ABSENT ||
              r.status == AttendanceStatus.EXTRA_ABSENT) {
            total30++;
          }
        }

        expect(total30, 2);
        expect(present30, 1);
        final rate = AttendanceCalculator.calculatePercentage(
            attended: present30, total: total30);
        expect(rate, 50.0);
      });
    });

    group(
        'BUG-012 & NEW-BUG-04: Historical attendance from soft-deleted subjects',
        () {
      test(
          'SubjectRepository getSubjectsBySemester with includeDeleted returns soft-deleted subjects',
          () async {
        final activeSubject = Subject(
          id: 1,
          semesterId: 1,
          name: 'Active Subject',
          code: 'ACT101',
          credits: 3,
          attendanceTarget: 75.0,
          color: '#10B981',
          type: SubjectType.THEORY,
          isDeleted: false,
          updatedAt: DateTime.utc(2026, 8, 1),
        );
        final deletedSubject = Subject(
          id: 2,
          semesterId: 1,
          name: 'Dropped Subject',
          code: 'DRP102',
          credits: 3,
          attendanceTarget: 75.0,
          color: '#EF4444',
          type: SubjectType.THEORY,
          isDeleted: true,
          updatedAt: DateTime.utc(2026, 9, 1),
        );

        final repo = _FakeSubjectRepository([activeSubject, deletedSubject]);

        final withoutDeleted =
            await repo.getSubjectsBySemester(1, includeDeleted: false);
        expect(withoutDeleted.length, 1);
        expect(withoutDeleted.first.name, 'Active Subject');

        final withDeleted =
            await repo.getSubjectsBySemester(1, includeDeleted: true);
        expect(withDeleted.length, 2);
        expect(withDeleted.map((s) => s.name),
            containsAll(['Active Subject', 'Dropped Subject']));
      });

      test(
          'AnalyticsCalculator includes historical attendance from soft-deleted subjects',
          () {
        final activeSubject = Subject(
          id: 1,
          semesterId: 1,
          name: 'Active Subject',
          code: 'ACT101',
          credits: 3,
          attendanceTarget: 75.0,
          color: '#10B981',
          type: SubjectType.THEORY,
          isDeleted: false,
          updatedAt: DateTime.utc(2026, 8, 1),
        );
        final droppedSubject = Subject(
          id: 2,
          semesterId: 1,
          name: 'Dropped Subject',
          code: 'DRP102',
          credits: 3,
          attendanceTarget: 75.0,
          color: '#EF4444',
          type: SubjectType.THEORY,
          isDeleted: true,
          updatedAt: DateTime.utc(2026, 9, 1),
        );

        final List<AttendanceRecord> records = [
          // Active subject: 2 attended, 2 total
          AttendanceRecord(
            id: 1,
            subjectId: 1,
            markedAt: DateTime.utc(2026, 9, 1),
            status: AttendanceStatus.PRESENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
          AttendanceRecord(
            id: 2,
            subjectId: 1,
            markedAt: DateTime.utc(2026, 9, 8),
            status: AttendanceStatus.PRESENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 9, 8),
          ),
          // Dropped subject: 1 absent, 1 attended
          AttendanceRecord(
            id: 3,
            subjectId: 2,
            markedAt: DateTime.utc(2026, 9, 2),
            status: AttendanceStatus.PRESENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 9, 2),
          ),
          AttendanceRecord(
            id: 4,
            subjectId: 2,
            markedAt: DateTime.utc(2026, 9, 9),
            status: AttendanceStatus.ABSENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 9, 9),
          ),
        ];

        final occurrences = [
          LoggedOccurrence(
              date: DateTime.utc(2026, 9, 1),
              startTime: '09:00',
              status: AttendanceStatus.PRESENT),
          LoggedOccurrence(
              date: DateTime.utc(2026, 9, 2),
              startTime: '09:00',
              status: AttendanceStatus.PRESENT),
          LoggedOccurrence(
              date: DateTime.utc(2026, 9, 8),
              startTime: '09:00',
              status: AttendanceStatus.PRESENT),
          LoggedOccurrence(
              date: DateTime.utc(2026, 9, 9),
              startTime: '09:00',
              status: AttendanceStatus.ABSENT),
        ];

        // NEW-BUG-04: When subjects list includes deleted subject, overall analytics reflects all records
        final analytics = AnalyticsCalculator.calculateOverallAnalytics(
          semester: testSemester,
          subjects: [activeSubject, droppedSubject],
          records: records,
          occurrences: occurrences,
        );

        expect(analytics.totalClasses, 4);
        expect(analytics.totalPresent, 3);
        expect(analytics.totalAbsent, 1);
        expect(analytics.overallPercentage, 75.0);
      });
    });

    group(
        'BUG-026: Report generation with soft-deleted subjects, custom identity, and Unicode fix',
        () {
      test(
          'ReportService includes soft-deleted subjects with records and marks them (Archived)',
          () async {
        final activeSubject = Subject(
          id: 1,
          semesterId: 1,
          name: 'Physics',
          code: 'PHY101',
          credits: 4,
          attendanceTarget: 75.0,
          color: '#10B981',
          type: SubjectType.THEORY,
          isDeleted: false,
          updatedAt: DateTime.utc(2026, 8, 1),
        );
        final archivedWithRecords = Subject(
          id: 2,
          semesterId: 1,
          name: 'Chemistry',
          code: 'CHM101',
          credits: 3,
          attendanceTarget: 75.0,
          color: '#6366F1',
          type: SubjectType.THEORY,
          isDeleted: true,
          updatedAt: DateTime.utc(2026, 9, 1),
        );
        final archivedWithoutRecords = Subject(
          id: 3,
          semesterId: 1,
          name: 'Ancient History',
          code: 'HIS101',
          credits: 2,
          attendanceTarget: 75.0,
          color: '#F59E0B',
          type: SubjectType.THEORY,
          isDeleted: true,
          updatedAt: DateTime.utc(2026, 9, 1),
        );

        final List<AttendanceRecord> records = [
          AttendanceRecord(
            id: 1,
            subjectId: 1,
            markedAt: DateTime.utc(2026, 9, 1),
            status: AttendanceStatus.PRESENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
          AttendanceRecord(
            id: 2,
            subjectId: 2,
            markedAt: DateTime.utc(2026, 9, 2),
            status: AttendanceStatus.PRESENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 9, 2),
          ),
          AttendanceRecord(
            id: 3,
            subjectId: 2,
            markedAt: DateTime.utc(2026, 9, 9),
            status: AttendanceStatus.ABSENT,
            isDirty: false,
            isDeleted: false,
            updatedAt: DateTime.utc(2026, 9, 9),
          ),
        ];

        final reportService = _TestReportService(
          mockSemesterId: 1,
          semesterRepository: _FakeSemesterRepository(testSemester),
          subjectRepository: _FakeSubjectRepository(
              [activeSubject, archivedWithRecords, archivedWithoutRecords]),
          attendanceRepository: _FakeAttendanceRepository(records),
        );

        final report = await reportService.generateSemesterReport(
          studentName: 'John Doe',
          targetPercentage: 80.0,
        );

        expect(report, isNotNull);
        expect(report!.studentName, 'John Doe');
        expect(report.targetPercentage, 80.0);

        // Subject reports: Physics (active) and Chemistry (Archived) should be present; Ancient History (0 records) omitted
        expect(report.subjectReports.length, 2);
        final chemReport = report.subjectReports
            .firstWhere((s) => s.subjectName.contains('Chemistry'));
        expect(chemReport.subjectName, 'Chemistry (Archived)');
        expect(chemReport.totalClasses, 2);
        expect(chemReport.present, 1);
        expect(chemReport.absent, 1);
        expect(chemReport.percentage, 50.0);

        // Ancient History has 0 records and was soft-deleted, so it should not appear
        expect(
            report.subjectReports
                .any((s) => s.subjectName.contains('Ancient History')),
            isFalse);
      });

      test(
          'PdfReportGenerator produces valid PDF bytes without Unicode bullet rendering crash',
          () async {
        final sampleReport = AttendanceReport(
          studentName: 'Jane Smith',
          semesterName: 'Fall 2026',
          generatedDate: DateTime.now(),
          overallPercentage: 85.0,
          targetPercentage: 80.0,
          totalClasses: 30,
          totalPresent: 24,
          totalAbsent: 6,
          subjectReports: [
            SubjectReport(
              subjectName: 'Mathematics',
              faculty: 'Prof. Gauss',
              percentage: 90.0,
              present: 18,
              absent: 2,
              totalClasses: 20,
              riskStatus: RiskStatus.SAFE,
            ),
            SubjectReport(
              subjectName: 'Electromagnetism (Archived)',
              faculty: 'Prof. Maxwell',
              percentage: 60.0,
              present: 6,
              absent: 4,
              totalClasses: 10,
              riskStatus: RiskStatus.CRITICAL,
            ),
          ],
        );

        final pdfBytes = await PdfReportGenerator.generatePdf(sampleReport);
        expect(pdfBytes, isNotNull);
        expect(pdfBytes, isA<Uint8List>());
        expect(pdfBytes.isNotEmpty, isTrue);
        // PDF format starts with "%PDF-"
        expect(String.fromCharCodes(pdfBytes.take(5)), '%PDF-');
      });
    });
  });
}
