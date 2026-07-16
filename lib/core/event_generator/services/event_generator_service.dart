import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:isar/isar.dart';
import '../data/models/event_local.dart';
import '../domain/entities/event.dart';
import '../domain/usecases/event_generator.dart';
import '../../database/isar_provider.dart';
import '../../../features/timetable/data/models/timetable_template_local.dart';
import '../../../features/timetable/domain/entities/timetable_template.dart';
import '../../../features/auth/data/models/semester_local.dart';
import '../../../features/subject/data/models/subject_local.dart';
import '../../../features/subject/domain/entities/subject.dart';

part 'event_generator_service.g.dart';

@riverpod
EventGeneratorService eventGeneratorService(EventGeneratorServiceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return EventGeneratorService(isar);
}

class EventGeneratorService {
  final Isar _isar;

  EventGeneratorService(this._isar);

  Subject _mapSubject(SubjectLocal s) {
    return Subject(
      id: s.id,
      semesterId: s.semesterId,
      name: s.name,
      code: s.code,
      faculty: s.faculty,
      credits: s.credits,
      attendanceTarget: s.attendanceTarget,
      color: s.color,
      type: s.type == 'LAB' ? SubjectType.LAB : SubjectType.THEORY,
      updatedAt: s.updatedAt,
    );
  }

  TimetableTemplate _mapTemplate(TimetableTemplateLocal t) {
    return TimetableTemplate(
      id: t.id,
      subjectId: t.subjectId,
      weekday: t.weekday,
      startTime: t.startTime,
      endTime: t.endTime,
      room: t.room,
      faculty: t.faculty,
      notes: t.notes,
      updatedAt: t.updatedAt,
    );
  }

  Event _mapEvent(EventLocal e) {
    return Event(
      id: e.id,
      subjectId: e.subjectId,
      date: e.date,
      startTime: e.startTime,
      endTime: e.endTime,
      eventType: e.eventType == 'LAB' ? EventType.LAB : EventType.REGULAR_CLASS,
      status: e.status == 'PRESENT'
          ? EventStatus.PRESENT
          : (e.status == 'ABSENT' ? EventStatus.ABSENT : EventStatus.UNMARKED),
      updatedAt: e.updatedAt,
    );
  }

  Future<void> generateEventsForWholeSemester() async {
    final semester = _isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
    if (semester == null) return;

    final subjects = _isar.subjectLocals
        .where()
        .semesterIdEqualTo(semester.id)
        .isDeletedEqualTo(false)
        .findAll();
    final subjectIds = subjects.map((s) => s.id).toSet();
    if (subjectIds.isEmpty) return;

    final templates = _isar.timetableTemplateLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();
    final activeTemplates = templates.where((t) => subjectIds.contains(t.subjectId)).toList();

    final existingEvents = _isar.eventLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();

    final subjectEntities = subjects.map(_mapSubject).toList();
    final templateEntities = activeTemplates.map(_mapTemplate).toList();
    final eventEntities = existingEvents.map(_mapEvent).toList();

    final newEvents = EventGenerator.generateWholeSemester(
      startDate: semester.startDate,
      endDate: semester.endDate,
      subjects: subjectEntities,
      templates: templateEntities,
      existingEvents: eventEntities,
    );

    if (newEvents.isEmpty) return;

    await _isar.writeAsync((isar) {
      for (final event in newEvents) {
        final local = EventLocal()
          ..subjectId = event.subjectId
          ..date = event.date
          ..startTime = event.startTime
          ..endTime = event.endTime
          ..eventType = event.eventType.toShortString()
          ..status = event.status.toShortString()
          ..updatedAt = DateTime.now()
          ..isDirty = true
          ..isDeleted = false;
        isar.eventLocals.put(local);
      }
    });
  }

  Future<void> generateEventsRollingWindow({DateTime? customToday}) async {
    final semester = _isar.semesterLocals.where().isDeletedEqualTo(false).findFirst();
    if (semester == null) return;

    final subjects = _isar.subjectLocals
        .where()
        .semesterIdEqualTo(semester.id)
        .isDeletedEqualTo(false)
        .findAll();
    final subjectIds = subjects.map((s) => s.id).toSet();
    if (subjectIds.isEmpty) return;

    final templates = _isar.timetableTemplateLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();
    final activeTemplates = templates.where((t) => subjectIds.contains(t.subjectId)).toList();

    final existingEvents = _isar.eventLocals
        .where()
        .isDeletedEqualTo(false)
        .findAll();

    final subjectEntities = subjects.map(_mapSubject).toList();
    final templateEntities = activeTemplates.map(_mapTemplate).toList();
    final eventEntities = existingEvents.map(_mapEvent).toList();

    final newEvents = EventGenerator.generateRollingWindow(
      startDate: semester.startDate,
      endDate: semester.endDate,
      subjects: subjectEntities,
      templates: templateEntities,
      existingEvents: eventEntities,
      today: customToday ?? DateTime.now(),
    );

    if (newEvents.isEmpty) return;

    await _isar.writeAsync((isar) {
      for (final event in newEvents) {
        final local = EventLocal()
          ..subjectId = event.subjectId
          ..date = event.date
          ..startTime = event.startTime
          ..endTime = event.endTime
          ..eventType = event.eventType.toShortString()
          ..status = event.status.toShortString()
          ..updatedAt = DateTime.now()
          ..isDirty = true
          ..isDeleted = false;
        isar.eventLocals.put(local);
      }
    });
  }
}
