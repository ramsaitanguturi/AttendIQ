import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

abstract class AuthRemoteDataSource {
  Future<fb.UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<fb.UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> sendForgotPasswordEmail({required String email});

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required DateTime createdAt,
  });

  Future<Map<String, dynamic>?> fetchUserProfile({required String uid});

  Future<String> saveSemester({
    required String uid,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required double requiredAttendanceRate,
    String? serverId,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<fb.UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<fb.UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendForgotPasswordEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required DateTime createdAt,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    });
  }

  @override
  Future<Map<String, dynamic>?> fetchUserProfile({required String uid}) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  @override
  Future<String> saveSemester({
    required String uid,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required double requiredAttendanceRate,
    String? serverId,
  }) async {
    final docRef = serverId != null && serverId.isNotEmpty
        ? _firestore.collection('semesters').doc(serverId)
        : _firestore.collection('semesters').doc();

    await docRef.set({
      'userId': uid,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'requiredAttendanceRate': requiredAttendanceRate,
      'updatedAt': FieldValue.serverTimestamp(),
      'isDeleted': false,
    });

    return docRef.id;
  }
}
