import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<User> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.registerWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }
}
