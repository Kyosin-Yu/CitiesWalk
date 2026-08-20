import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared read model for points earned from completed eco journeys.
///
/// Rewards uses this value for the current user's leaderboard entry, while
/// Fitness uses the same weekly value for its Eco Points metric.
class EcoPointsService {
  const EcoPointsService(this._client);

  final SupabaseClient _client;

  Future<int> fetchCurrentWeekPoints({
    required String userId,
    DateTime? now,
  }) async {
    final weekStart = _currentWeekStartUtc(now ?? DateTime.now());
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _sumPoints(
      _client
          .from('reward_point_transactions')
          .select('points')
          .eq('user_id', userId)
          .gte('journey_completed_at', weekStart.toIso8601String())
          .lt('journey_completed_at', weekEnd.toIso8601String()),
    );
  }

  Future<int> fetchLifetimePoints({required String userId}) => _sumPoints(
    _client.from('reward_point_transactions').select('points').eq(
          'user_id',
          userId,
        ),
  );

  Future<int> _sumPoints(Future<dynamic> request) async {
    final rows = await request as List<dynamic>;
    return rows.fold<int>(0, (total, row) {
      final value = (row as Map<dynamic, dynamic>)['points'];
      return total + switch (value) {
        num number => number.toInt(),
        String text => int.tryParse(text) ?? 0,
        _ => 0,
      };
    });
  }

  /// Mirrors the leaderboard's Monday 00:00 Asia/Kuala_Lumpur boundary.
  DateTime _currentWeekStartUtc(DateTime value) {
    const malaysiaOffset = Duration(hours: 8);
    final malaysiaNow = value.toUtc().add(malaysiaOffset);
    final monday = DateTime.utc(
      malaysiaNow.year,
      malaysiaNow.month,
      malaysiaNow.day,
    ).subtract(Duration(days: malaysiaNow.weekday - DateTime.monday));
    return monday.subtract(malaysiaOffset);
  }
}
