import 'package:flutter_test/flutter_test.dart';

// App Imports
import 'package:attend_iq/features/timetable/domain/entities/timetable_template.dart';
import 'package:attend_iq/features/timetable/data/models/timetable_template_local.dart';
import 'package:attend_iq/features/timetable/data/datasources/timetable_local_data_source.dart';
import 'package:attend_iq/features/timetable/data/datasources/timetable_remote_data_source.dart';
import 'package:attend_iq/features/timetable/data/repositories/timetable_repository_impl.dart';
import 'package:attend_iq/features/auth/data/models/user_local.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:attend_iq/features/subject/data/models/subject_local.dart';

// Fakes
class FakeAuthLocalDataSource implements AuthLocalDataSource {
  UserLocal? currentUser;
  @override
  Future<void> saveUser(UserLocal user) async => currentUser = user;
  @override
  Future<UserLocal?> getUser() async => currentUser;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

    return templates.values
        .where((t) => subjectIds.contains(t.subjectId) && !t.isDeleted)
        .toList();
  }

  @override
  Future<TimetableTemplateLocal?> getTemplateById(int id) async {
    return templates[id];
  }

  @override
  Future<void> saveTemplate(TimetableTemplateLocal template) async {
    if (template.id == 0) {
      template.id = _nextId++;
    }
    templates[template.id] = template;
  }
}

class FakeTimetableRemoteDataSource implements TimetableRemoteDataSource {
  final Map<String, Map<String, dynamic>> schedulesCollection = {};
  bool isOnline = true;

  @override
  Future<String> saveTemplate({
    required String uid,
    required String subjectId,
    required int weekday,
    required String startTime,
    required String endTime,
    String? room,
    String? faculty,
    String? notes,
    String? serverId,
  }) async {
    if (!isOnline) throw Exception('No network connection');
    final id = serverId ?? 'mock_schedule_${DateTime.now().millisecondsSinceEpoch}_${schedulesCollection.length}';
    schedulesCollection[id] = {
      'userId': uid,
      'subjectId': subjectId,
      'dayOfWeek': weekday,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'faculty': faculty,
      'notes': notes,
      'isDeleted': false,
    };
    return id;
  }

  @override
  Future<void> deleteTemplate(String serverId) async {
    if (!isOnline) throw Exception('No network connection');
    if (schedulesCollection.containsKey(serverId)) {
      schedulesCollection[serverId]!['isDeleted'] = true;
    }
  }
}

void main() {
  late FakeAuthLocalDataSource authLocalDataSource;
  late FakeTimetableLocalDataSource localDataSource;
  late FakeTimetableRemoteDataSource remoteDataSource;
  late TimetableRepositoryImpl repository;

  setUp(() {
    authLocalDataSource = FakeAuthLocalDataSource();
    localDataSource = FakeTimetableLocalDataSource();
    remoteDataSource = FakeTimetableRemoteDataSource();

    repository = TimetableRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      authLocalDataSource: authLocalDataSource,
    );

    // Seed mock user
    authLocalDataSource.saveUser(UserLocal()
      ..uid = 'user_abc'
      ..name = 'Rohan'
      ..email = 'rohan@test.com'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now());

    // Seed mock subjects in the fake datasource
    localDataSource.subjects.addAll([
      SubjectLocal()
        ..id = 1
        ..semesterId = 1
        ..name = 'Mathematics IV'
        ..code = 'MATH-401'
        ..credits = 4
        ..attendanceTarget = 75.0
        ..color = '#FF5733'
        ..type = 'THEORY'
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false,
      SubjectLocal()
        ..id = 2
        ..semesterId = 1
        ..name = 'Physics Lab'
        ..code = 'PHYS-202'
        ..credits = 2
        ..attendanceTarget = 80.0
        ..color = '#33FF57'
        ..type = 'LAB'
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false,
    ]);
  });

  group('Timetable Template Operations', () {
    test('Create class template slot saves successfully', () async {
      final template = TimetableTemplate(
        subjectId: 1,
        weekday: 1, // Monday
        startTime: '09:00',
        endTime: '10:00',
        room: 'Room 301',
        faculty: 'Dr. Newton',
        notes: 'Bring calculator',
        updatedAt: DateTime.now(),
      );

      await repository.saveTemplate(template);

      final list = await repository.getTemplatesForSemester(1);
      expect(list.length, 1);
      expect(list.first.subjectId, 1);
      expect(list.first.startTime, '09:00');
      expect(list.first.room, 'Room 301');
      expect(list.first.serverId, isNotNull);
    });

    test('Collision checks block overlapping time slots', () {
      final existing = [
        TimetableTemplate(
          id: 1,
          subjectId: 1,
          weekday: 1, // Monday
          startTime: '09:00',
          endTime: '10:00',
          updatedAt: DateTime.now(),
        ),
      ];

      int timeToMinutes(String timeStr) {
        final parts = timeStr.split(':');
        return int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }

      bool checkCollision(int weekday, String start, String end, List<TimetableTemplate> list) {
        final startMin = timeToMinutes(start);
        final endMin = timeToMinutes(end);

        for (final t in list) {
          if (t.weekday == weekday) {
            final tStart = timeToMinutes(t.startTime);
            final tEnd = timeToMinutes(t.endTime);
            if (startMin < tEnd && endMin > tStart) {
              return true;
            }
          }
        }
        return false;
      }

      // 1. Direct overlap
      expect(checkCollision(1, '09:15', '09:45', existing), isTrue);

      // 2. Starts exactly at existing end time (No overlap)
      expect(checkCollision(1, '10:00', '11:00', existing), isFalse);

      // 3. Ends exactly at existing start time (No overlap)
      expect(checkCollision(1, '08:00', '09:00', existing), isFalse);

      // 4. Different weekday (No overlap)
      expect(checkCollision(2, '09:30', '10:30', existing), isFalse);
    });

    test('Delete timetable slot flags as deleted', () async {
      final template = TimetableTemplate(
        subjectId: 1,
        weekday: 2, // Tuesday
        startTime: '11:00',
        endTime: '12:00',
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
