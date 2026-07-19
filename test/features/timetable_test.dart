import 'package:flutter_test/flutter_test.dart';

import 'package:attend_iq/features/timetable/domain/entities/timetable_template.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/timetable/data/datasources/timetable_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/repositories/timetable_repository_impl.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';

class FakeTimetableLocalDataSource implements TimetableLocalDataSource {
  final Map<int, TimetableTemplateLocal> templates = {};
  final List<SubjectLocal> subjects = [];
  int _nextId = 1;

  @override
  Future<List<TimetableTemplateLocal>> getTemplatesForSubject(int subjectId) async {
    return templates.values
        .where((t) => t.subjectId == subjectId && !t.isDeleted)
        .toList();
  }

  @override
  Future<List<TimetableTemplateLocal>> getTemplatesForSemester(int semesterId) async {
    final subjectIds = subjects
        .where((s) => s.semesterId == semesterId && !s.isDeleted)
        .map((s) => s.id)
        .toSet();
    if (subjectIds.isEmpty) return [];

    return templates.values
        .where((t) => subjectIds.contains(t.subjectId) && !t.isDeleted)
        .toList();
  }

  @override
  Future<TimetableTemplateLocal?> getTemplateById(int id) async => templates[id];

  @override
  Future<void> saveTemplate(TimetableTemplateLocal template) async {
    if (template.id == 0) {
      template.id = _nextId++;
    }
    templates[template.id] = template;
  }

  @override
  Stream<void> watchTemplates(int semesterId) {
    return const Stream.empty();
  }
}

void main() {
  late FakeTimetableLocalDataSource localDataSource;
  late TimetableRepositoryImpl repository;

  setUp(() {
    localDataSource = FakeTimetableLocalDataSource();
    repository = TimetableRepositoryImpl(
      localDataSource: localDataSource,
    );

    localDataSource.subjects.addAll([
      SubjectLocal()
        ..id = 5
        ..semesterId = 1
        ..name = 'Maths'
        ..code = 'M101'
        ..credits = 4
        ..color = '#FFFFFF'
        ..attendanceTarget = 75.0
        ..type = 'THEORY'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false,
      SubjectLocal()
        ..id = 6
        ..semesterId = 1
        ..name = 'Physics'
        ..code = 'P101'
        ..credits = 3
        ..color = '#000000'
        ..attendanceTarget = 75.0
        ..type = 'LAB'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false,
    ]);
  });

  group('Timetable Template CRUD Tests', () {
    test('saveTemplate persists locally', () async {
      final template = TimetableTemplate(
        subjectId: 5,
        weekday: 1,
        startTime: '09:00',
        endTime: '09:55',
        room: 'Room 301',
        faculty: 'Dr. Prasad',
        updatedAt: DateTime.now(),
      );

      await repository.saveTemplate(template);

      final list = await repository.getTemplatesForSemester(1);
      expect(list.length, 1);
      expect(list.first.subjectId, 5);
      expect(list.first.room, 'Room 301');
      expect(list.first.serverId, isNotNull);
    });

    test('deleteTemplate marks local isDeleted=true', () async {
      final template = TimetableTemplate(
        subjectId: 6,
        weekday: 2,
        startTime: '10:00',
        endTime: '11:00',
        room: 'Lab 2',
        updatedAt: DateTime.now(),
      );

      await repository.saveTemplate(template);
      final created = (await repository.getTemplatesForSemester(1)).first;

      await repository.deleteTemplate(created.id!);

      final activeList = await repository.getTemplatesForSemester(1);
      expect(activeList, isEmpty);

      final rawLocal = await localDataSource.getTemplateById(created.id!);
      expect(rawLocal, isNotNull);
      expect(rawLocal!.isDeleted, isTrue);
    });
  });
}
