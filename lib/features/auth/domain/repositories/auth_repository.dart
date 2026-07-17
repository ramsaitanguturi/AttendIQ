import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> sendForgotPasswordEmail({required String email});

  Future<User?> getCurrentUser();

  Stream<User?> get authStateChanges;

  Future<void> updateProfileName(String name);

  Future<void> deleteAccount();
}
