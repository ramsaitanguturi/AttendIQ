import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TimetableRemoteDataSource {
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
  });

  Future<void> deleteTemplate(String serverId);
}

class TimetableRemoteDataSourceImpl implements TimetableRemoteDataSource {
  final FirebaseFirestore _firestore;

  TimetableRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
    final docRef = serverId != null && serverId.isNotEmpty
        ? _firestore.collection('schedules').doc(serverId)
        : _firestore.collection('schedules').doc();

    await docRef.set({
      'userId': uid,
      'subjectId': subjectId,
      'dayOfWeek': weekday,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'faculty': faculty,
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
      'isDeleted': false,
    });

    return docRef.id;
  }

  @override
  Future<void> deleteTemplate(String serverId) async {
    await _firestore.collection('schedules').doc(serverId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
