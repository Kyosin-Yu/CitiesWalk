import 'package:flutter/foundation.dart';

import '../../../../core/services/eco_points_service.dart';
import '../entities/fitness_dashboard.dart';
import '../entities/completed_fitness_journey.dart';
import '../entities/fitness_goal.dart';
import '../entities/fitness_history.dart';
import '../entities/fitness_recent_badge.dart';
import '../entities/fitness_route_point.dart';
import '../entities/health_activity.dart';
import '../repositories/health_activity_repository.dart';
import '../repositories/fitness_repository.dart';
import '../services/fitness_dashboard_service.dart';
import '../services/fitness_goal_progress_service.dart';
import '../services/fitness_history_service.dart';

enum FitnessStatus { initial, loading, success, failure }

class FitnessController extends ChangeNotifier {
  FitnessController({
    required this.userId,
    required this.userName,
    required this.repository,
    this.ecoPointsService,
    this.dashboardService = const FitnessDashboardService(),
    this.goalProgressService = const FitnessGoalProgressService(),
    this.historyService = const FitnessHistoryService(),
    this.healthActivityRepository,
  });

  final String userId;
  final String userName;
  final FitnessRepository repository;
  final EcoPointsService? ecoPointsService;
  final FitnessDashboardService dashboardService;
  final FitnessGoalProgressService goalProgressService;
  final FitnessHistoryService historyService;
  final HealthActivityRepository? healthActivityRepository;

  FitnessStatus _status = FitnessStatus.initial;
  FitnessDashboard? _dashboard;
  List<CompletedFitnessJourney> _journeys = const [];
  List<FitnessGoal> _goals = const [];
  List<FitnessRecentBadge> _recentBadges = const [];
  String? _errorMessage;
  String? _goalErrorMessage;
  bool _isRefreshing = false;
  bool _refreshPending = false;
  bool _isGoalMutationInProgress = false;
  FitnessHistoryPeriod _historyPeriod = FitnessHistoryPeriod.daily;
  DateTime? _selectedHistoryDate;
  List<DateTime> _availableHistoryDates = const [];
  FitnessGoalStatus _goalFilter = FitnessGoalStatus.active;
  HealthIntegrationStatus _healthIntegrationStatus =
      HealthIntegrationStatus.unsupported;
  HealthActivitySnapshot? _healthActivity;
  String? _healthMessage;
  bool _isHealthSyncing = false;
  final Map<String, List<FitnessRoutePoint>> _routePointsByJourney = {};
  final Set<String> _loadingRouteIds = {};
  final Map<String, String> _routeErrorsByJourney = {};

  FitnessStatus get status => _status;
  FitnessDashboard? get dashboard => _dashboard;
  List<FitnessGoal> get goals => List.unmodifiable(_goals);
  List<FitnessGoal> get visibleGoals =>
      List.unmodifiable(_goals.where((goal) => goal.status == _goalFilter));
  List<CompletedFitnessJourney> get recentActivities =>
      List.unmodifiable(_journeys.take(3));
  List<FitnessRecentBadge> get recentBadges => List.unmodifiable(_recentBadges);
  String? get errorMessage => _errorMessage;
  String? get goalErrorMessage => _goalErrorMessage;
  bool get isRefreshing => _isRefreshing;
  bool get isGoalMutationInProgress => _isGoalMutationInProgress;
  FitnessHistoryPeriod get historyPeriod => _historyPeriod;
  FitnessGoalStatus get goalFilter => _goalFilter;
  HealthIntegrationStatus get healthIntegrationStatus =>
      _healthIntegrationStatus;
  HealthActivitySnapshot? get healthActivity => _healthActivity;
  String? get healthMessage => _healthMessage;
  bool get isHealthSyncing => _isHealthSyncing;
  List<FitnessRoutePoint> routePointsFor(String journeyId) =>
      List.unmodifiable(_routePointsByJourney[journeyId] ?? const []);
  bool isRouteLoading(String journeyId) => _loadingRouteIds.contains(journeyId);
  bool hasLoadedRoute(String journeyId) =>
      _routePointsByJourney.containsKey(journeyId);
  String? routeErrorFor(String journeyId) => _routeErrorsByJourney[journeyId];
  DateTime? get selectedHistoryDate => _selectedHistoryDate;
  List<DateTime> get availableHistoryDates =>
      List.unmodifiable(_availableHistoryDates);
  DateTime? get firstHistoryDate =>
      _availableHistoryDates.isEmpty ? null : _availableHistoryDates.first;
  DateTime? get lastHistoryDate =>
      _availableHistoryDates.isEmpty ? null : _availableHistoryDates.last;
  FitnessHistorySummary? get historySummary {
    final selectedDate = _selectedHistoryDate;
    if (selectedDate == null) return null;
    return historyService.build(
      journeys: _journeys,
      period: _historyPeriod,
      anchorDate: selectedDate,
    );
  }

  Future<void> loadDashboard() => _load(showLoading: true);

  Future<void> refresh() => _load(showLoading: false);

  Future<void> loadJourneyRoute(
    String journeyId, {
    bool forceRefresh = false,
  }) async {
    if (_loadingRouteIds.contains(journeyId)) return;
    if (!forceRefresh && _routePointsByJourney.containsKey(journeyId)) return;

    _loadingRouteIds.add(journeyId);
    _routeErrorsByJourney.remove(journeyId);
    notifyListeners();
    try {
      _routePointsByJourney[journeyId] = await repository
          .fetchJourneyRoutePoints(userId: userId, journeyId: journeyId);
    } catch (error, stackTrace) {
      debugPrint('Unable to load Fitness route $journeyId: $error');
      debugPrint(stackTrace.toString());
      _routeErrorsByJourney[journeyId] =
          'Unable to load this route. Please try again.';
    } finally {
      _loadingRouteIds.remove(journeyId);
      notifyListeners();
    }
  }

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
      _journeys = journeys;
      _syncHistoryDates();
      final ecoPoints = await _loadCurrentWeekEcoPoints();
      await _loadHealthActivity();
      _dashboard = dashboardService.build(
        userName: userName,
        journeys: journeys,
        ecoPoints: ecoPoints,
        healthActivity: _healthActivity,
      );
      try {
        _goals = await repository.fetchGoals(userId: userId);
      } catch (error, stackTrace) {
        debugPrint('Unable to load Fitness goals: $error');
        debugPrint(stackTrace.toString());
        _goalErrorMessage =
            'Goals are unavailable. Apply the Fitness goals migration and try again.';
      }
      try {
        _recentBadges = await repository.fetchRecentBadges(userId: userId);
      } catch (error, stackTrace) {
        debugPrint('Unable to load recent Fitness badges: $error');
        debugPrint(stackTrace.toString());
        _recentBadges = const [];
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

  Future<void> _loadHealthActivity() async {
    final healthRepository = healthActivityRepository;
    if (healthRepository == null) return;
    try {
      _applyHealthAccess(await healthRepository.loadToday());
    } catch (error, stackTrace) {
      _handleHealthError(error, stackTrace);
    }
  }

  Future<void> connectHealth() async {
    final healthRepository = healthActivityRepository;
    if (healthRepository == null || _isHealthSyncing) return;
    _isHealthSyncing = true;
    _healthMessage = null;
    notifyListeners();
    try {
      _applyHealthAccess(await healthRepository.requestAccessAndLoadToday());
      _rebuildDashboardWithHealth();
    } catch (error, stackTrace) {
      _handleHealthError(error, stackTrace);
    } finally {
      _isHealthSyncing = false;
      notifyListeners();
    }
  }

  Future<void> disconnectHealth() async {
    final healthRepository = healthActivityRepository;
    if (healthRepository == null || _isHealthSyncing) return;
    _isHealthSyncing = true;
    notifyListeners();
    try {
      await healthRepository.revokeAccess();
      _healthIntegrationStatus = HealthIntegrationStatus.permissionRequired;
      _healthActivity = null;
      _healthMessage = 'Health Connect has been disconnected.';
      _rebuildDashboardWithHealth();
    } catch (error, stackTrace) {
      _handleHealthError(error, stackTrace);
    } finally {
      _isHealthSyncing = false;
      notifyListeners();
    }
  }

  Future<void> installHealthConnect() async {
    final healthRepository = healthActivityRepository;
    if (healthRepository == null || _isHealthSyncing) return;
    try {
      await healthRepository.installHealthConnect();
    } catch (error, stackTrace) {
      _handleHealthError(error, stackTrace);
      notifyListeners();
    }
  }

  void _applyHealthAccess(HealthActivityAccess access) {
    _healthIntegrationStatus = access.status;
    _healthActivity = access.snapshot;
    _healthMessage = access.message;
  }

  void _rebuildDashboardWithHealth() {
    final dashboard = _dashboard;
    if (dashboard == null) return;
    _dashboard = dashboardService.build(
      userName: userName,
      journeys: _journeys,
      ecoPoints: dashboard.ecoPoints,
      healthActivity: _healthActivity,
    );
  }

  void _handleHealthError(Object error, StackTrace stackTrace) {
    debugPrint('Unable to sync Health Connect: $error');
    debugPrint(stackTrace.toString());
    _healthIntegrationStatus = HealthIntegrationStatus.error;
    _healthMessage = 'Unable to sync Health Connect. Please try again.';
  }

  bool isHistoryDateSelectable(DateTime date) =>
      historyService.hasActivityOnDate(_availableHistoryDates, date);

  void selectHistoryDate(DateTime date) {
    if (!isHistoryDateSelectable(date)) return;
    final local = date.toLocal();
    final selected = DateTime(local.year, local.month, local.day);
    if (_selectedHistoryDate == selected) return;
    _selectedHistoryDate = selected;
    notifyListeners();
  }

  void selectHistoryPeriod(FitnessHistoryPeriod period) {
    if (_historyPeriod == period) return;
    _historyPeriod = period;
    notifyListeners();
  }

  int goalCount(FitnessGoalStatus status) =>
      _goals.where((goal) => goal.status == status).length;

  void selectGoalFilter(FitnessGoalStatus status) {
    if (_goalFilter == status) return;
    _goalFilter = status;
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
    return goalProgressService.calculate(goal: goal, journeys: _journeys);
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

  Future<bool> cancelGoal(FitnessGoal goal) async {
    if (!goal.isActive) {
      _goalErrorMessage = 'Only an active goal can be cancelled.';
      notifyListeners();
      return false;
    }
    _beginGoalMutation();
    try {
      final cancelled = await repository.cancelGoal(
        userId: userId,
        goalId: goal.id,
      );
      _goals = [
        for (final item in _goals)
          if (item.id == cancelled.id) cancelled else item,
      ];
      _sortGoals();
      return true;
    } catch (error, stackTrace) {
      _handleGoalMutationError('cancel', error, stackTrace);
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

  bool _canSaveGoal(FitnessGoalInput input) {
    if (!input.targetValue.isFinite || input.targetValue <= 0) {
      _goalErrorMessage = 'Enter a target greater than zero.';
      notifyListeners();
      return false;
    }
    final duplicate = _goals.any(
      (goal) =>
          goal.isActive &&
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
      final statusComparison = first.status.index.compareTo(
        second.status.index,
      );
      if (statusComparison != 0) return statusComparison;
      final periodComparison = first.period.index.compareTo(
        second.period.index,
      );
      return periodComparison != 0
          ? periodComparison
          : first.metric.index.compareTo(second.metric.index);
    });
  }

  void _syncHistoryDates() {
    _availableHistoryDates = historyService.availableDates(_journeys);
    if (_availableHistoryDates.isEmpty) {
      _selectedHistoryDate = null;
      return;
    }
    final selected = _selectedHistoryDate;
    if (selected == null || !isHistoryDateSelectable(selected)) {
      _selectedHistoryDate = _availableHistoryDates.last;
    }
  }
}
