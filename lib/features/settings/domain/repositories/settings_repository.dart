import '../entities/user_preferences.dart';

abstract class SettingsRepository {
  Future<UserPreferences?> getPreferences(String userId);
  Future<void> savePreferences(UserPreferences preferences);
  Stream<UserPreferences?> watchPreferences(String userId);
}
