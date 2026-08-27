import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> load();

  Future<UserSettings> save(UserSettings settings);
}
