import 'package:citieswalk/core/errors/app_exception.dart';
import 'package:citieswalk/features/authentication/business_logic/entities/user_settings.dart';
import 'package:citieswalk/features/authentication/business_logic/providers/settings_controller.dart';
import 'package:citieswalk/features/authentication/business_logic/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads account settings and saves a language change', () async {
    final repository = _FakeSettingsRepository(
      const UserSettings(localeCode: 'ms'),
    );
    final controller = SettingsController(repository);

    await controller.load();
    expect(controller.settings.localeCode, 'ms');

    final saved = await controller.setLocale('zh');

    expect(saved, isTrue);
    expect(controller.settings.localeCode, 'zh');
    expect(repository.savedSettings?.localeCode, 'zh');
  });

  test('saves the Kuala Lumpur pilot region', () async {
    final repository = _FakeSettingsRepository(
      const UserSettings(regionCode: 'my-kul'),
    );
    final controller = SettingsController(repository);

    final saved = await controller.setRegion('my-kul');

    expect(saved, isTrue);
    expect(repository.savedSettings?.regionCode, 'my-kul');
  });

  test('restores the previous settings when saving fails', () async {
    final repository = _FakeSettingsRepository(const UserSettings());
    final controller = SettingsController(repository);
    await controller.load();
    repository.shouldFail = true;

    final saved = await controller.setLocale('ms');

    expect(saved, isFalse);
    expect(controller.settings.localeCode, 'en');
    expect(controller.errorMessage, 'Save failed.');
  });

  test('resets settings when the signed-in user changes', () async {
    final controller = SettingsController(
      _FakeSettingsRepository(const UserSettings(localeCode: 'zh')),
    );
    await controller.load();

    controller.reset();

    expect(controller.settings, const TypeMatcher<UserSettings>());
    expect(controller.settings.localeCode, 'en');
    expect(controller.errorMessage, isNull);
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.value);

  UserSettings value;
  UserSettings? savedSettings;
  bool shouldFail = false;

  @override
  Future<UserSettings> load() async => value;

  @override
  Future<UserSettings> save(UserSettings settings) async {
    if (shouldFail) throw const AppException('Save failed.');
    savedSettings = settings;
    value = settings;
    return settings;
  }
}
