import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_local.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource {
    _init();
  }

  void _init() async {
    final cachedUser = await getCurrentUser();
    _authStateController.add(cachedUser);
  }

  @override
  Future<User> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _remoteDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final createdAt = DateTime.now();

    await _remoteDataSource.saveUserProfile(
      uid: uid,
      name: name,
      email: email,
      createdAt: createdAt,
    );

    final localUser = UserLocal()
      ..uid = uid
      ..name = name
      ..email = email
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();
    await _localDataSource.saveUser(localUser);

    final user = User(
      id: uid,
      name: name,
      email: email,
      createdAt: createdAt,
    );
    _authStateController.add(user);
    return user;
  }

  @override
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _remoteDataSource.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final profileData = await _remoteDataSource.fetchUserProfile(uid: uid);
    final name = profileData?['name'] as String? ?? credential.user!.displayName ?? 'Student';
    final rawCreatedAt = profileData?['createdAt'];
    final DateTime createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else {
      createdAt = DateTime.now();
    }

    final localUser = UserLocal()
      ..uid = uid
      ..name = name
      ..email = email
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();
    await _localDataSource.saveUser(localUser);

    final user = User(
      id: uid,
      name: name,
      email: email,
      createdAt: createdAt,
    );
    _authStateController.add(user);
    return user;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {}
    await _localDataSource.clearUser();
    _authStateController.add(null);
  }

  @override
  Future<void> sendForgotPasswordEmail({required String email}) async {
    await _remoteDataSource.sendForgotPasswordEmail(email: email);
  }

  @override
  Future<User?> getCurrentUser() async {
    final cached = await _localDataSource.getUser();
    if (cached != null) {
      return User(
        id: cached.uid,
        name: cached.name,
        email: cached.email,
        createdAt: cached.createdAt,
      );
    }
    return null;
  }

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;
}
