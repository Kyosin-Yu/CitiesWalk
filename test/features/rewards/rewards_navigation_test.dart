import 'package:citieswalk/features/rewards/business_logic/entities/leaderboard_entry.dart';
import 'package:citieswalk/features/rewards/business_logic/providers/rewards_controller.dart';
import 'package:citieswalk/features/rewards/data/data_sources/rewards_mock_data_source.dart';
import 'package:citieswalk/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:citieswalk/features/rewards/presentation/screens/achievement_locker_screen.dart';
import 'package:citieswalk/features/rewards/presentation/screens/leaderboard_screen.dart';
import 'package:citieswalk/features/rewards/presentation/screens/points_history_screen.dart';
import 'package:citieswalk/features/rewards/presentation/screens/rewards_hub_screen.dart';
import 'package:citieswalk/features/rewards/presentation/widgets/podium_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Widget _withRewardsController(Widget child) {
  return ChangeNotifierProvider<RewardsController>(
    create: (_) =>
        RewardsController(const RewardsRepositoryImpl(RewardsMockDataSource()))
          ..load(),
    child: child,
  );
}

class _RecordingRewardsController extends RewardsController {
  _RecordingRewardsController()
    : super(const RewardsRepositoryImpl(RewardsMockDataSource()));

  int loadCount = 0;

  @override
  Future<void> load() {
    loadCount += 1;
    return super.load();
  }
}

void main() {
  testWidgets('Rewards tab opens the leaderboard without an internal nav bar', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(504, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RewardsHubScreen(
            repository: const RewardsRepositoryImpl(RewardsMockDataSource()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Rewards Centre'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      tester.getTopLeft(find.text('Alex Park').last).dy,
      greaterThan(700),
      reason: 'The fixed current-user summary must not expand over the page.',
    );
  });

  testWidgets(
    'Standalone leaderboard back button returns to the previous page',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _withRewardsController(
            Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: context.read<RewardsController>(),
                            child: const LeaderboardScreen(),
                          ),
                        ),
                      ),
                      child: const Text('Open rewards'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open rewards'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Open rewards'), findsOneWidget);
    },
  );

  testWidgets('Points history filters transactions by month', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: _withRewardsController(const PointsHistoryScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('KLCC Park'), findsOneWidget);

    await tester.tap(find.byTooltip('Filter activity period'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is CheckedPopupMenuItem<int> && widget.value == 1,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bukit Bintang Green Walk'), findsOneWidget);
    expect(find.text('River of Life Transit Route'), findsOneWidget);
    expect(find.textContaining('KLCC Park'), findsNothing);
  });

  testWidgets('View all expands the remaining leaderboard rankings', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(504, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RewardsHubScreen(
            repository: const RewardsRepositoryImpl(RewardsMockDataSource()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aisha Rahman'), findsNothing);
    await tester.tap(find.text('View all (4)'));
    await tester.pumpAndSettle();

    expect(find.text('Aisha Rahman'), findsOneWidget);
    expect(find.text('Show less'), findsOneWidget);
  });

  testWidgets('Podium keeps available ranks when another rank is missing', (
    WidgetTester tester,
  ) async {
    const entries = <LeaderboardEntry>[
      LeaderboardEntry(
        rank: 1,
        name: 'First Place',
        points: 300,
        achievement: 'Champion',
        initials: 'FP',
      ),
      LeaderboardEntry(
        rank: 3,
        name: 'Third Place',
        points: 100,
        achievement: 'Explorer',
        initials: 'TP',
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.green,
          body: PodiumWidget(entries: entries),
        ),
      ),
    );

    expect(find.text('First Place'), findsOneWidget);
    expect(find.text('Third Place'), findsOneWidget);
    expect(find.byType(PodiumWidget), findsOneWidget);
  });

  testWidgets('Pull-to-refresh reloads leaderboard data', (
    WidgetTester tester,
  ) async {
    final controller = _RecordingRewardsController()..load();

    await tester.pumpWidget(
      ChangeNotifierProvider<RewardsController>.value(
        value: controller,
        child: const MaterialApp(home: LeaderboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final refreshIndicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    expect(controller.loadCount, 1);

    await refreshIndicator.onRefresh();
    await tester.pumpAndSettle();

    expect(controller.loadCount, 2);
  });

  testWidgets('Pull-to-refresh reloads achievement data', (
    WidgetTester tester,
  ) async {
    final controller = _RecordingRewardsController()..load();

    await tester.pumpWidget(
      ChangeNotifierProvider<RewardsController>.value(
        value: controller,
        child: const MaterialApp(home: AchievementLockerScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final refreshIndicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    expect(controller.loadCount, 1);

    await refreshIndicator.onRefresh();
    await tester.pumpAndSettle();

    expect(controller.loadCount, 2);
  });

  testWidgets('Pull-to-refresh reloads points history data', (
    WidgetTester tester,
  ) async {
    final controller = _RecordingRewardsController()..load();

    await tester.pumpWidget(
      ChangeNotifierProvider<RewardsController>.value(
        value: controller,
        child: const MaterialApp(home: PointsHistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final refreshIndicator = tester.widget<RefreshIndicator>(
      find.byType(RefreshIndicator),
    );
    expect(controller.loadCount, 1);

    await refreshIndicator.onRefresh();
    await tester.pumpAndSettle();

    expect(controller.loadCount, 2);
  });
}
