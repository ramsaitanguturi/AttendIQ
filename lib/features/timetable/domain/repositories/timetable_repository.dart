import '../entities/timetable_template.dart';

abstract class TimetableRepository {
  Future<List<TimetableTemplate>> getTemplatesForSubject(int subjectId);
  Future<List<TimetableTemplate>> getTemplatesForSemester(int semesterId);
  Future<TimetableTemplate?> getTemplateById(int id);
  Future<void> saveTemplate(TimetableTemplate template);
  Future<void> deleteTemplate(int id);
}
