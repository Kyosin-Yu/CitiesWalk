import 'package:flutter/foundation.dart';

import '../entities/fitness_dashboard.dart';
import '../repositories/fitness_repository.dart';
import '../services/fitness_dashboard_service.dart';

enum FitnessStatus { initial, loading, success, failure }

class FitnessController extends ChangeNotifier {
  FitnessController({
    required this.userId,
    required this.userName,
    required this.repository,
    this.dashboardService = const FitnessDashboardService(),
  });

  final String userId;
  final String userName;
  final FitnessRepository repository;
  final FitnessDashboardService dashboardService;

  FitnessStatus _status = FitnessStatus.initial;
  FitnessDashboard? _dashboard;
  String? _errorMessage;
  bool _notificationsEnabled = true;
  bool _isRefreshing = false;
  bool _refreshPending = false;

  FitnessStatus get status => _status;
  FitnessDashboard? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isRefreshing => _isRefreshing;

  Future<void> loadDashboard() => _load(showLoading: true);

  Future<void> refresh() => _load(showLoading: false);

  Future<void> _load({required bool showLoading}) async {
    if (_isRefreshing) {
      _refreshPending = true;
      return;
    }
    _isRefreshing = true;
    if (showLoading || _dashboard == null) {
      _status = FitnessStatus.loading;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final journeys = await repository.fetchCompletedJourneys(userId: userId);
      _dashboard = dashboardService.build(
        userName: userName,
        journeys: journeys,
      );
      _status = FitnessStatus.success;
    } catch (error, stackTrace) {
      debugPrint('Unable to load Fitness data: $error');
      debugPrint(stackTrace.toString());
      _errorMessage = 'Unable to sync completed routes. Pull to try again.';
      if (_dashboard == null) _status = FitnessStatus.failure;
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
    if (_refreshPending) {
      _refreshPending = false;
      await _load(showLoading: false);
    }
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }
}
