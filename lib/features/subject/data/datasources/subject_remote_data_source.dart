import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SubjectRemoteDataSource {
  Future<String> saveSubject({
    required String uid,
    required String semesterId,
    required String name,
    required String code,
    String? faculty,
    required int credits,
    required double attendanceTarget,
    required String color,
    required String type,
    String? serverId,
  });

  Future<void> deleteSubject(String serverId);
}

class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  SubjectRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> saveSubject({
    required String uid,
    required String semesterId,
    required String name,
    required String code,
    String? faculty,
    required int credits,
    required double attendanceTarget,
    required String color,
    required String type,
    String? serverId,
  }) async {
    final docRef = serverId != null && serverId.isNotEmpty
        ? _firestore.collection('subjects').doc(serverId)
        : _firestore.collection('subjects').doc();

    await docRef.set({
      'userId': uid,
      'semesterId': semesterId,
      'name': name,
      'courseCode': code,
      'instructor': faculty,
      'credits': credits,
      'colorHex': color,
      'requiredAttendanceOverride': attendanceTarget,
      'type': type,
      'updatedAt': FieldValue.serverTimestamp(),
      'isDeleted': false,
    });

    return docRef.id;
  }

  @override
  Future<void> deleteSubject(String serverId) async {
    await _firestore.collection('subjects').doc(serverId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
