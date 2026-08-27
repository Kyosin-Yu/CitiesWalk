import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_exception.dart';
import '../../business_logic/entities/user_settings.dart';
import '../../business_logic/repositories/settings_repository.dart';
import '../data_sources/supabase_settings_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dataSource);

  static const supportedLocales = {'en', 'ms', 'zh'};
  static const supportedRegions = {UserSettings.defaultRegionCode};

  final SupabaseSettingsDataSource _dataSource;

  @override
  Future<UserSettings> load() async {
    try {
      return _fromMap(_dataSource.load());
    } on AuthException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<UserSettings> save(UserSettings settings) async {
    if (!supportedLocales.contains(settings.localeCode) ||
        !supportedRegions.contains(settings.regionCode)) {
      throw const AppException('Unsupported language or region.');
    }
    try {
      final saved = await _dataSource.save({
        'locale_code': settings.localeCode,
        'region_code': settings.regionCode,
      });
      return _fromMap(saved);
    } on AuthException catch (error) {
      throw AppException(error.message);
    } catch (_) {
      throw const AppException('Unable to save settings. Please try again.');
    }
  }

  UserSettings _fromMap(Map<String, dynamic>? value) {
    final localeCode = value?['locale_code']?.toString();
    final regionCode = value?['region_code']?.toString();
    return UserSettings(
      localeCode: supportedLocales.contains(localeCode)
          ? localeCode!
          : UserSettings.defaultLocaleCode,
      regionCode: supportedRegions.contains(regionCode)
          ? regionCode!
          : UserSettings.defaultRegionCode,
    );
  }
}
