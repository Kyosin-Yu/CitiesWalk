import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/device_health_activity_model.dart';
import '../../business_logic/entities/health_activity.dart';

class DeviceHealthDataSource {
  DeviceHealthDataSource({Health? health}) : _health = health ?? Health();

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];
  static const _readPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  final Health _health;
  bool _isConfigured = false;

  bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<DeviceHealthActivityModel> loadToday({
    bool requestAccess = false,
  }) async {
    if (!isSupported) {
      return const DeviceHealthActivityModel(
        status: HealthIntegrationStatus.unsupported,
        message: 'Health Connect is available on Android devices.',
      );
    }

    await _configure();
    final sdkStatus = await _health.getHealthConnectSdkStatus();
    if (sdkStatus != HealthConnectSdkStatus.sdkAvailable) {
      return const DeviceHealthActivityModel(
        status: HealthIntegrationStatus.unavailable,
        message: 'Install or update Health Connect to sync activity data.',
      );
    }

    if (requestAccess) {
      final recognitionStatus = await Permission.activityRecognition.request();
      if (!recognitionStatus.isGranted) {
        return const DeviceHealthActivityModel(
          status: HealthIntegrationStatus.permissionRequired,
          message: 'Activity recognition permission is required for steps.',
        );
      }

      final authorized = await _health.requestAuthorization(
        _types,
        permissions: _readPermissions,
      );
      if (!authorized) {
        return const DeviceHealthActivityModel(
          status: HealthIntegrationStatus.permissionRequired,
          message: 'Allow Fitness data access to sync your activity.',
        );
      }
    } else {
      final recognitionStatus = await Permission.activityRecognition.status;
      final hasHealthPermissions =
          await _health.hasPermissions(_types, permissions: _readPermissions) ??
          false;
      if (!recognitionStatus.isGranted || !hasHealthPermissions) {
        return const DeviceHealthActivityModel(
          status: HealthIntegrationStatus.permissionRequired,
        );
      }
    }

    return _readToday();
  }

  Future<void> revokeAccess() async {
    if (!isSupported) return;
    await _configure();
    await _health.revokePermissions();
  }

  Future<void> installHealthConnect() async {
    if (!isSupported) return;
    await _configure();
    await _health.installHealthConnect();
  }

  Future<void> _configure() async {
    if (_isConfigured) return;
    await _health.configure();
    _isConfigured = true;
  }

  Future<DeviceHealthActivityModel> _readToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final steps = await _health.getTotalStepsInInterval(
      start,
      now,
      includeManualEntry: false,
    );
    final points = await _health.getHealthAggregateDataFromTypes(
      types: const [
        HealthDataType.DISTANCE_WALKING_RUNNING,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ],
      startDate: start,
      endDate: now,
      includeManualEntry: false,
    );

    return DeviceHealthActivityModel(
      status: HealthIntegrationStatus.connected,
      syncedAt: now,
      stepsToday: steps,
      walkingDistanceMetersToday: _sum(
        points,
        HealthDataType.DISTANCE_WALKING_RUNNING,
      )?.round(),
      activeCaloriesToday: _sum(
        points,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      )?.round(),
    );
  }

  double? _sum(List<HealthDataPoint> points, HealthDataType type) {
    final matching = points.where((point) => point.type == type).toList();
    if (matching.isEmpty) return null;
    return matching.fold<double>(0, (sum, point) {
      final value = point.value;
      return value is NumericHealthValue
          ? sum + value.numericValue.toDouble()
          : sum;
    });
  }
}
