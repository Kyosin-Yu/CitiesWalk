import 'package:flutter/foundation.dart';

import '../entities/fitness_dashboard.dart';
import '../repositories/fitness_repository.dart';

enum FitnessStatus { initial, loading, success, failure }

class FitnessController extends ChangeNotifier {
  FitnessController(this._repository);

  final FitnessRepository _repository;
  FitnessStatus _status = FitnessStatus.initial;
  FitnessDashboard? _dashboard;
  String? _errorMessage;
  bool _notificationsEnabled = true;

  FitnessStatus get status => _status;
  FitnessDashboard? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> loadDashboard() async {
    _status = FitnessStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboard = await _repository.getDashboard();
      _status = FitnessStatus.success;
    } catch (_) {
      _status = FitnessStatus.failure;
      _errorMessage = 'Unable to load your fitness dashboard.';
    }
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }
}
