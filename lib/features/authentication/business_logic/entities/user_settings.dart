import 'package:flutter/foundation.dart';

@immutable
class UserSettings {
  static const defaultLocaleCode = 'en';
  static const defaultRegionCode = 'my-kul';

  const UserSettings({
    this.localeCode = defaultLocaleCode,
    this.regionCode = defaultRegionCode,
  });

  final String localeCode;
  final String regionCode;

  UserSettings copyWith({String? localeCode, String? regionCode}) {
    return UserSettings(
      localeCode: localeCode ?? this.localeCode,
      regionCode: regionCode ?? this.regionCode,
    );
  }
}
