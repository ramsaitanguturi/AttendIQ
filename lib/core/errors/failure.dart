import 'package:flutter/foundation.dart';
import 'app_exception.dart';

@immutable
abstract class Failure {
  final String message;
  final dynamic error;

  const Failure(this.message, [this.error]);

  @override
  String toString() => '$runtimeType: $message';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.error]);

  factory DatabaseFailure.fromException(DatabaseException exception) {
    return DatabaseFailure(exception.message, exception);
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.error]);

  factory NetworkFailure.fromException(NetworkException exception) {
    return NetworkFailure(exception.message, exception);
  }
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.error]);

  factory AuthFailure.fromException(AuthException exception) {
    return AuthFailure(exception.message, exception);
  }
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.error]);

  factory ServerFailure.fromException(ServerException exception) {
    return ServerFailure(exception.message, exception);
  }
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.error]);
}
