import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/semester_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/semester_repository.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import '../../domain/usecases/create_semester_use_case.dart';
import '../../domain/entities/semester.dart';
import '../../../../core/database/isar_provider.dart';

part 'auth_controller.g.dart';

@riverpod
AuthLocalDataSource authLocalDataSource(AuthLocalDataSourceRef ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return AuthLocalDataSourceImpl(isar);
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSourceImpl();
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
}

@riverpod
SemesterRepository semesterRepository(SemesterRepositoryRef ref) {
  return SemesterRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
}

@riverpod
LoginUseCase loginUseCase(LoginUseCaseRef ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
RegisterUseCase registerUseCase(RegisterUseCaseRef ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
LogoutUseCase logoutUseCase(LogoutUseCaseRef ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
ForgotPasswordUseCase forgotPasswordUseCase(ForgotPasswordUseCaseRef ref) {
  return ForgotPasswordUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
CreateSemesterUseCase createSemesterUseCase(CreateSemesterUseCaseRef ref) {
  return CreateSemesterUseCase(ref.watch(semesterRepositoryProvider));
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<User?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    
    // Listen to authentication changes
    final subscription = repo.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
    
    ref.onDispose(() {
      subscription.cancel();
    });

    return repo.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(loginUseCaseProvider);
      return await useCase(email: email, password: password);
    });
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(registerUseCaseProvider);
      return await useCase(name: name, email: email, password: password);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(logoutUseCaseProvider);
      await useCase();
      return null;
    });
  }

  Future<void> forgotPassword(String email) async {
    final useCase = ref.read(forgotPasswordUseCaseProvider);
    await useCase(email: email);
  }

  Future<void> completeOnboarding({
    required String name,
    required String email,
    required String semesterName,
    required DateTime startDate,
    required DateTime endDate,
    required double requiredAttendanceRate,
  }) async {
    final localDS = ref.read(authLocalDataSourceProvider);
    final cached = await localDS.getUser();
    if (cached != null && (cached.name != name || cached.email != email)) {
      cached.name = name;
      cached.email = email;
      cached.updatedAt = DateTime.now();
      await localDS.saveUser(cached);
      
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(User(
          id: current.id,
          name: name,
          email: email,
          createdAt: current.createdAt,
        ),);
      }
    }

    final createSemester = ref.read(createSemesterUseCaseProvider);
    final semester = Semester(
      name: semesterName,
      startDate: startDate,
      endDate: endDate,
      requiredAttendanceRate: requiredAttendanceRate,
    );
    await createSemester(semester);
    
    ref.invalidate(hasActiveSemesterProvider);
  }
}

@riverpod
Future<bool> hasActiveSemester(HasActiveSemesterRef ref) async {
  final repo = ref.watch(semesterRepositoryProvider);
  return repo.hasActiveSemester();
}
