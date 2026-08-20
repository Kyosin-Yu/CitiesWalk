import 'package:flutter/foundation.dart';

import '../../../../core/services/eco_points_service.dart';
import '../entities/fitness_dashboard.dart';
import '../entities/fitness_goal.dart';
import '../repositories/fitness_repository.dart';
import '../services/fitness_dashboard_service.dart';
import '../services/fitness_goal_progress_service.dart';

enum FitnessStatus { initial, loading, success, failure }

class FitnessController extends ChangeNotifier {
  FitnessController({
    required this.userId,
    required this.userName,
    required this.repository,
    this.ecoPointsService,
    this.dashboardService = const FitnessDashboardService(),
    this.goalProgressService = const FitnessGoalProgressService(),
  });

  final String userId;
  final String userName;
  final FitnessRepository repository;
  final EcoPointsService? ecoPointsService;
  final FitnessDashboardService dashboardService;
  final FitnessGoalProgressService goalProgressService;

  FitnessStatus _status = FitnessStatus.initial;
  FitnessDashboard? _dashboard;
  List<FitnessGoal> _goals = const [];
  String? _errorMessage;
  String? _goalErrorMessage;
  bool _notificationsEnabled = true;
  bool _isRefreshing = false;
  bool _refreshPending = false;
  bool _isGoalMutationInProgress = false;

  FitnessStatus get status => _status;
  FitnessDashboard? get dashboard => _dashboard;
  List<FitnessGoal> get goals => List.unmodifiable(_goals);
  String? get errorMessage => _errorMessage;
  String? get goalErrorMessage => _goalErrorMessage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isRefreshing => _isRefreshing;
  bool get isGoalMutationInProgress => _isGoalMutationInProgress;

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
    _goalErrorMessage = null;
    notifyListeners();

    try {
      final journeys = await repository.fetchCompletedJourneys(userId: userId);
      final ecoPoints = await _loadCurrentWeekEcoPoints();
      _dashboard = dashboardService.build(
        userName: userName,
        journeys: journeys,
        ecoPoints: ecoPoints,
      );
      try {
        _goals = await repository.fetchGoals(userId: userId);
      } catch (error, stackTrace) {
        debugPrint('Unable to load Fitness goals: $error');
        debugPrint(stackTrace.toString());
        _goalErrorMessage =
            'Goals are unavailable. Apply the Fitness goals migration and try again.';
      }
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

  Future<int?> _loadCurrentWeekEcoPoints() async {
    final service = ecoPointsService;
    if (service == null) return null;
    try {
      return await service.fetchCurrentWeekPoints(userId: userId);
    } catch (error, stackTrace) {
      debugPrint('Unable to load Eco Points: $error');
      debugPrint(stackTrace.toString());
      return null;
    }
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  FitnessGoalProgress progressFor(FitnessGoal goal) {
    final currentDashboard = _dashboard;
    if (currentDashboard == null) {
      return FitnessGoalProgress(
        currentValue: 0,
        targetValue: goal.targetValue,
      );
    }
    return goalProgressService.calculate(
      goal: goal,
      dashboard: currentDashboard,
    );
  }

  Future<bool> createGoal(FitnessGoalInput input) async {
    if (!_canSaveGoal(input)) return false;
    _beginGoalMutation();
    try {
      final created = await repository.createGoal(userId: userId, input: input);
      _goals = [..._goals, created];
      _sortGoals();
      return true;
    } catch (error, stackTrace) {
      _handleGoalMutationError('create', error, stackTrace);
      return false;
    } finally {
      _endGoalMutation();
    }
  }

  Future<bool> updateGoal(FitnessGoal goal, FitnessGoalInput input) async {
    if (!_canSaveGoal(input, existingGoalId: goal.id)) return false;
    _beginGoalMutation();
    try {
      final updated = await repository.updateGoal(
        userId: userId,
        goalId: goal.id,
        input: input,
      );
      _goals = [
        for (final item in _goals)
          if (item.id == updated.id) updated else item,
      ];
      _sortGoals();
      return true;
    } catch (error, stackTrace) {
      _handleGoalMutationError('update', error, stackTrace);
      return false;
    } finally {
      _endGoalMutation();
    }
  }

  Future<bool> deleteGoal(FitnessGoal goal) async {
    _beginGoalMutation();
    try {
      await repository.deleteGoal(userId: userId, goalId: goal.id);
      _goals = _goals.where((item) => item.id != goal.id).toList();
      return true;
    } catch (error, stackTrace) {
      _handleGoalMutationError('delete', error, stackTrace);
      return false;
    } finally {
      _endGoalMutation();
    }
  }

  void clearGoalError() {
    if (_goalErrorMessage == null) return;
    _goalErrorMessage = null;
    notifyListeners();
  }

  bool _canSaveGoal(FitnessGoalInput input, {String? existingGoalId}) {
    if (!input.targetValue.isFinite || input.targetValue <= 0) {
      _goalErrorMessage = 'Enter a target greater than zero.';
      notifyListeners();
      return false;
    }
    final duplicate = _goals.any(
      (goal) =>
          goal.id != existingGoalId &&
          goal.metric == input.metric &&
          goal.period == input.period,
    );
    if (duplicate) {
      _goalErrorMessage =
          'A ${input.period.label.toLowerCase()} ${input.metric.label.toLowerCase()} goal already exists.';
      notifyListeners();
      return false;
    }
    return true;
  }

  void _beginGoalMutation() {
    _isGoalMutationInProgress = true;
    _goalErrorMessage = null;
    notifyListeners();
  }

  void _endGoalMutation() {
    _isGoalMutationInProgress = false;
    notifyListeners();
  }

  void _handleGoalMutationError(
    String operation,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('Unable to $operation Fitness goal: $error');
    debugPrint(stackTrace.toString());
    _goalErrorMessage = 'Unable to $operation this goal. Please try again.';
  }

  void _sortGoals() {
    _goals.sort((first, second) {
      final periodComparison = first.period.index.compareTo(
        second.period.index,
      );
      return periodComparison != 0
          ? periodComparison
          : first.metric.index.compareTo(second.metric.index);
    });
  }
}
