import 'package:flutter/foundation.dart';

import '../entities/location_access.dart';
import '../repositories/location_settings_repository.dart';

class LocationDataController extends ChangeNotifier {
  LocationDataController(this._repository);

  final LocationSettingsRepository _repository;
  LocationAccess? _access;
  bool _isLoading = false;
  String? _errorMessage;

  LocationAccess? get access => _access;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() => _run(_repository.checkAccess);
  Future<void> requestAccess() => _run(_repository.requestAccess);
  Future<bool> openAppSettings() => _repository.openAppSettings();
  Future<bool> openLocationSettings() => _repository.openLocationSettings();

  Future<void> _run(Future<LocationAccess> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _access = await action();
    } catch (error) {
      _errorMessage = 'Unable to read location settings.';
      debugPrint('Location settings check failed: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
