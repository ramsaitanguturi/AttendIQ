import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// App Imports
import 'package:attend_iq/features/settings/domain/entities/user_preferences.dart';
import 'package:attend_iq/features/settings/data/models/user_preferences_local.dart';
import 'package:attend_iq/features/settings/domain/repositories/settings_repository.dart';
import 'package:attend_iq/features/settings/presentation/controllers/settings_controller.dart';
import 'package:attend_iq/features/auth/domain/entities/user.dart';
import 'package:attend_iq/features/auth/presentation/controllers/auth_controller.dart';
import 'package:attend_iq/features/auth/data/models/user_local.dart';
import 'package:attend_iq/features/auth/data/models/semester_local.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:attend_iq/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:attend_iq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:attend_iq/core/sync/models/sync_mappers.dart';

// Fakes
class FakeSettingsRepository implements SettingsRepository {
  final Map<String, UserPreferences> _store = {};
  final StreamController<UserPreferences?> _controller = StreamController<UserPreferences?>.broadcast();
  int saveCount = 0;

  @override
  Future<UserPreferences?> getPreferences(String userId) async {
    return _store[userId];
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    saveCount++;
    _store[preferences.id] = preferences;
    _controller.add(preferences);
  }

  @override
  Stream<UserPreferences?> watchPreferences(String userId) {
    return _controller.stream;
  }
}

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  UserLocal? currentUser;
  bool isCleared = false;

  @override
  Future<void> saveUser(UserLocal user) async {
    currentUser = user;
    isCleared = false;
  }

  @override
  Future<UserLocal?> getUser() async => currentUser;

  @override
  Future<void> clearUser() async {
    currentUser = null;
    isCleared = true;
  }

  @override
  Future<void> saveSemester(SemesterLocal semester) async {}
  @override
  Future<SemesterLocal?> getActiveSemester() async => null;
  @override
  Future<bool> hasActiveSemester() async => false;
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  bool isLoggedOut = false;
  bool isDeleted = false;

  @override
  Future<fb_auth.UserCredential> registerWithEmailAndPassword({required String email, required String password}) async => throw UnimplementedError();
  @override
  Future<fb_auth.UserCredential> loginWithEmailAndPassword({required String email, required String password}) async => throw UnimplementedError();
  
  @override
  Future<void> logout() async {
    isLoggedOut = true;
  }

  @override
  Future<void> sendForgotPasswordEmail({required String email}) async {}
  @override
  Future<void> saveUserProfile({required String uid, required String name, required String email, required DateTime createdAt}) async {}
  @override
  Future<Map<String, dynamic>?> fetchUserProfile({required String uid}) async => null;
  @override
  Future<String> saveSemester({required String uid, required String name, required DateTime startDate, required DateTime endDate, required double requiredAttendanceRate, String? serverId}) async => '';
  
  @override
  Future<void> deleteUserAccount() async {
    isDeleted = true;
  }
}

class FakeAuthController extends AuthController {
  final User? _user;
  FakeAuthController(this._user);

  @override
  FutureOr<User?> build() async {
    return _user;
  }
}

void main() {
  group('UserPreferences Entity and Model tests', () {
    test('Entity should initialize with correct values and support copyWith', () {
      const prefs = UserPreferences(
        id: 'user_123',
        themeMode: 'system',
        defaultAttendanceTarget: 75.0,
        classReminderOffset: 5,
        enableNotifications: true,
        enableAttendanceWarnings: true,
        weeklyReportEnabled: true,
      );

      expect(prefs.id, 'user_123');
      expect(prefs.themeMode, 'system');
      expect(prefs.defaultAttendanceTarget, 75.0);

      final updated = prefs.copyWith(themeMode: 'dark', defaultAttendanceTarget: 80.0);
      expect(updated.themeMode, 'dark');
      expect(updated.defaultAttendanceTarget, 80.0);
      expect(updated.id, 'user_123'); // Unchanged
    });

    test('UserPreferencesLocal mapper serialization and deserialization', () {
      final local = UserPreferencesLocal()
        ..id = 1
        ..serverId = 'user_123'
        ..themeMode = 'dark'
        ..defaultAttendanceTarget = 80.0
        ..classReminderOffset = 10
        ..enableNotifications = false
        ..enableAttendanceWarnings = true
        ..weeklyReportEnabled = false
        ..updatedAt = DateTime.utc(2026, 1, 1)
        ..isDirty = false
        ..isDeleted = false;

      final map = local.toMap();
      expect(map['serverId'], 'user_123');
      expect(map['themeMode'], 'dark');
      expect(map['defaultAttendanceTarget'], 80.0);
      expect(map['classReminderOffset'], 10);
      expect(map['enableNotifications'], false);
      expect(map['enableAttendanceWarnings'], true);
      expect(map['weeklyReportEnabled'], false);

      final mappedBack = UserPreferencesLocalMapper.fromMap(map);
      expect(mappedBack.serverId, 'user_123');
      expect(mappedBack.themeMode, 'dark');
      expect(mappedBack.defaultAttendanceTarget, 80.0);
      expect(mappedBack.classReminderOffset, 10);
      expect(mappedBack.enableNotifications, false);
      expect(mappedBack.enableAttendanceWarnings, true);
      expect(mappedBack.weeklyReportEnabled, false);
    });
  });

  group('SettingsController & Preferences modification tests', () {
    late FakeSettingsRepository settingsRepository;
    late ProviderContainer container;

    setUp(() {
      settingsRepository = FakeSettingsRepository();
      
      container = ProviderContainer(
        overrides: [
          // Override settingsRepositoryProvider to use Fake
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
          // Override authState to pretend a user is logged in
          authControllerProvider.overrideWith(() => FakeAuthController(
                User(
                  id: 'user_123',
                  name: 'Alice',
                  email: 'alice@example.com',
                  createdAt: DateTime.now(),
                ),
              )),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Controller initializes preferences with defaults if none stored in repository', () async {
      // Keep provider alive using a listener during testing
      final sub = container.listen(settingsControllerProvider, (_, __) {});

      final stateAsync = container.read(settingsControllerProvider);
      expect(stateAsync.isLoading, true);

      final state = await container.read(settingsControllerProvider.future);
      expect(state.id, 'user_123');
      expect(state.themeMode, 'system');
      expect(state.defaultAttendanceTarget, 75.0);
      expect(state.classReminderOffset, 5);

      // Verify defaults saved to repo
      expect(settingsRepository.saveCount, 1);

      sub.close();
    });

    test('Updating settings fields updates state and calls repository savePreferences', () async {
      // Keep provider alive using a listener during testing
      final sub = container.listen(settingsControllerProvider, (_, __) {});

      // Initialize settings controller
      await container.read(settingsControllerProvider.future);
      settingsRepository.saveCount = 0; // reset saveCount

      final notifier = container.read(settingsControllerProvider.notifier);

      // 1. Update theme
      await notifier.updateThemeMode('dark');
      var state = container.read(settingsControllerProvider).valueOrNull!;
      expect(state.themeMode, 'dark');
      expect(settingsRepository.saveCount, 1);

      // 2. Update default target
      await notifier.updateDefaultAttendanceTarget(85.0);
      state = container.read(settingsControllerProvider).valueOrNull!;
      expect(state.defaultAttendanceTarget, 85.0);
      expect(settingsRepository.saveCount, 2);

      // 3. Update toggles
      await notifier.updateEnableNotifications(false);
      state = container.read(settingsControllerProvider).valueOrNull!;
      expect(state.enableNotifications, false);
      expect(settingsRepository.saveCount, 3);

      sub.close();
    });
  });

  group('Auth Repository Logout and Delete Account flow tests', () {
    late FakeAuthLocalDataSource localDS;
    late FakeAuthRemoteDataSource remoteDS;
    late AuthRepositoryImpl authRepository;

    setUp(() {
      localDS = FakeAuthLocalDataSource();
      remoteDS = FakeAuthRemoteDataSource();
      authRepository = AuthRepositoryImpl(
        localDataSource: localDS,
        remoteDataSource: remoteDS,
      );

      // Seeding a logged-in user locally
      localDS.saveUser(UserLocal()
        ..uid = 'user_123'
        ..name = 'Alice'
        ..email = 'alice@example.com'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isDirty = false
        ..isDeleted = false);
    });

    test('Logout clears local user session and triggers remote logout', () async {
      expect(localDS.currentUser, isNotNull);
      expect(remoteDS.isLoggedOut, false);

      await authRepository.logout();

      expect(localDS.currentUser, isNull);
      expect(localDS.isCleared, true);
      expect(remoteDS.isLoggedOut, true);
    });

    test('Delete account triggers remote delete and clears local session', () async {
      expect(localDS.currentUser, isNotNull);
      expect(remoteDS.isDeleted, false);

      await authRepository.deleteAccount();

      expect(localDS.currentUser, isNull);
      expect(localDS.isCleared, true);
      expect(remoteDS.isDeleted, true);
    });
  });
}
