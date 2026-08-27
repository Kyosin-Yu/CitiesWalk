import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  UserSettings _settings = const UserSettings();
  bool _isLoading = false;
  String? _errorMessage;

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void reset() {
    _settings = const UserSettings();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _settings = await _repository.load();
    } on AppException catch (error) {
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setLocale(String localeCode) {
    return _save(_settings.copyWith(localeCode: localeCode));
  }

  Future<bool> setRegion(String regionCode) {
    return _save(_settings.copyWith(regionCode: regionCode));
  }

  Future<bool> _save(UserSettings nextSettings) async {
    final previousSettings = _settings;
    _settings = nextSettings;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _settings = await _repository.save(nextSettings);
      return true;
    } on AppException catch (error) {
      _settings = previousSettings;
      _errorMessage = error.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
