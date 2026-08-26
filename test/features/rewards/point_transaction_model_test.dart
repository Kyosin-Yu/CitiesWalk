import 'package:citieswalk/features/rewards/business_logic/entities/point_transaction.dart';
import 'package:citieswalk/features/rewards/data/models/point_transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a fitness goal transaction without a journey id', () {
    final model =
        PointTransactionModel.fromRewardTransactionRow(<String, dynamic>{
          'id': 'fitness-transaction',
          'journey_id': null,
          'source_type': 'fitness_goal',
          'points': 31,
          'walking_distance_km': 0,
          'carbon_saved_kg': 0,
          'calories_burned': 0,
          'journey_completed_at': '2026-08-26T07:30:00Z',
        });

    final transaction = model.toEntity();

    expect(transaction.title, 'Fitness goal completed');
    expect(transaction.type, JourneyType.fitnessGoal);
    expect(transaction.points, 31);
    expect(transaction.icon, 'emojiEvents');
  });

  test('keeps journey details when mapping a journey transaction', () {
    final model = PointTransactionModel.fromRewardTransactionRow(
      <String, dynamic>{
        'id': 'journey-transaction',
        'journey_id': 'journey-1',
        'source_type': 'journey',
        'points': 80,
        'walking_distance_km': 1.6,
        'carbon_saved_kg': 0.5,
        'calories_burned': 180,
        'journey_completed_at': '2026-08-26T07:30:00Z',
      },
      journey: <String, dynamic>{
        'origin_name': 'KLCC Park',
        'destination_name': 'Central Market',
        'actual_transit_distance_meters': 1200,
      },
    );

    final transaction = model.toEntity();

    expect(transaction.title, 'KLCC Park → Central Market');
    expect(transaction.type, JourneyType.transit);
    expect(transaction.icon, 'accountBalance');
  });

  test('keeps a zero-point short journey in point history', () {
    final model = PointTransactionModel.fromRewardTransactionRow(
      <String, dynamic>{
        'id': 'short-journey-transaction',
        'journey_id': 'short-journey',
        'source_type': 'journey',
        'points': 0,
        'walking_distance_km': 0.005,
        'carbon_saved_kg': 0,
        'calories_burned': 0,
        'journey_completed_at': '2026-08-26T07:30:00Z',
      },
      journey: <String, dynamic>{
        'origin_name': 'GPS location',
        'destination_name': 'Nearby stop',
        'actual_transit_distance_meters': 0,
      },
    );

    final transaction = model.toEntity();

    expect(transaction.points, 0);
    expect(transaction.distanceKm, 0.005);
    expect(transaction.title, 'GPS location → Nearby stop');
    expect(transaction.type, JourneyType.walk);
  });
}
