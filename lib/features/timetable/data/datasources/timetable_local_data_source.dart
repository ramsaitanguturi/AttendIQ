import 'package:isar/isar.dart';
import '../models/timetable_template_local.dart';
import '../../../subject/data/models/subject_local.dart';

abstract class TimetableLocalDataSource {
  Future<List<TimetableTemplateLocal>> getTemplatesForSubject(int subjectId);
  Future<List<TimetableTemplateLocal>> getTemplatesForSemester(int semesterId);
  Future<TimetableTemplateLocal?> getTemplateById(int id);
  Future<void> saveTemplate(TimetableTemplateLocal template);
  Stream<void> watchTemplates(int semesterId);
}

class TimetableLocalDataSourceImpl implements TimetableLocalDataSource {
  final Isar _isar;

  TimetableLocalDataSourceImpl(this._isar);

  @override
  Future<List<TimetableTemplateLocal>> getTemplatesForSubject(int subjectId) async {
    return _isar.timetableTemplateLocals
        .where()
        .subjectIdEqualTo(subjectId)
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<List<TimetableTemplateLocal>> getTemplatesForSemester(int semesterId) async {
    // 1. Get all subject IDs for the semester
    final subjects = _isar.subjectLocals
        .where()
        .semesterIdEqualTo(semesterId)
        .isDeletedEqualTo(false)
        .findAll();
    final subjectIds = subjects.map((s) => s.id).toSet();
    if (subjectIds.isEmpty) return [];

    // 2. Fetch all templates and filter by subject ID
    final allTemplates = _isar.timetableTemplateLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();

    return allTemplates.where((t) => subjectIds.contains(t.subjectId)).toList();
  }

  @override
  Future<TimetableTemplateLocal?> getTemplateById(int id) async {
    return _isar.timetableTemplateLocals.get(id);
  }

  @override
  Future<void> saveTemplate(TimetableTemplateLocal template) async {
    await _isar.writeAsync((isar) {
      if (template.id == 0) {
        template.id = isar.timetableTemplateLocals.autoIncrement();
      }
      isar.timetableTemplateLocals.put(template);
    });
  }

  @override
  Stream<void> watchTemplates(int semesterId) {
    return _isar.timetableTemplateLocals.where().isDeletedEqualTo(false).watch();
  }
}
