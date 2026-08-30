import 'package:citieswalk/features/fitness/business_logic/entities/completed_fitness_journey.dart';
import 'package:citieswalk/features/fitness/business_logic/entities/health_activity.dart';
import 'package:citieswalk/features/fitness/business_logic/services/fitness_dashboard_service.dart';
import 'package:citieswalk/features/fitness/presentation/widgets/metrics_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('separates journey steps from Health Connect daily steps', (
    tester,
  ) async {
    final dashboard = const FitnessDashboardService().build(
      userName: 'Alex',
      now: DateTime(2026, 8, 28, 12),
      healthActivity: HealthActivitySnapshot(
        syncedAt: DateTime(2026, 8, 28, 12),
        stepsToday: 6200,
      ),
      journeys: [
        CompletedFitnessJourney(
          id: 'journey',
          walkingDistanceMeters: 1400,
          estimatedCalories: 90,
          estimatedCarbonSavedKg: .3,
          startedAt: DateTime(2026, 8, 28, 9),
          completedAt: DateTime(2026, 8, 28, 10),
          stepCount: 1900,
          stepsSource: FitnessMetricSource.recorded,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: MetricsGrid(dashboard: dashboard)),
        ),
      ),
    );

    expect(find.text('Journey Steps'), findsOneWidget);
    expect(find.text('1900'), findsOneWidget);
    expect(find.text('Overall Steps Today'), findsOneWidget);
    expect(find.text('6200'), findsOneWidget);
    expect(find.text('steps • Health Connect'), findsOneWidget);
  });
}
