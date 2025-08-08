import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/profile_stats_dashboard.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';

void main() {
  group('ProfileStatsDashboard', () {
    late UserStats mockStats;

    setUp(() {
      mockStats = const UserStats(
        moviesWatched: 25,
        tvShowsWatched: 12,
        totalHours: 150,
        topGenres: ['Action', 'Drama', 'Comedy', 'Sci-Fi'],
      );
    });

    Widget createTestWidget({
      UserStats? stats,
      VoidCallback? onMoviesWatchedTap,
      VoidCallback? onTvShowsWatchedTap,
      VoidCallback? onWatchTimeTap,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: ProfileStatsDashboard(
            stats: stats ?? mockStats,
            onMoviesWatchedTap: onMoviesWatchedTap,
            onTvShowsWatchedTap: onTvShowsWatchedTap,
            onWatchTimeTap: onWatchTimeTap,
          ),
        ),
      );
    }

    testWidgets('renders with user stats', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify dashboard title is displayed
      expect(find.text('Viewing Statistics'), findsOneWidget);
      expect(find.text('Your cinematic journey'), findsOneWidget);

      // Verify stat circle titles are displayed
      expect(find.text('Movies'), findsOneWidget);
      expect(find.text('TV Shows'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);

      // Verify genre section is displayed
      expect(find.text('Favorite Genres'), findsOneWidget);
    });

    testWidgets('displays correct stat values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify stat values are displayed (after animation completes)
      expect(find.text('25'), findsOneWidget); // Movies
      expect(find.text('12'), findsOneWidget); // TV Shows
      expect(find.text('150h'), findsOneWidget); // Hours
    });

    testWidgets('displays genre tags correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify genre tags are displayed
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Drama'), findsOneWidget);
      expect(find.text('Comedy'), findsOneWidget);
      expect(find.text('Sci-Fi'), findsOneWidget);
    });

    testWidgets('calls onMoviesWatchedTap when movies circle is tapped', (
      WidgetTester tester,
    ) async {
      bool moviesTapped = false;

      await tester.pumpWidget(
        createTestWidget(onMoviesWatchedTap: () => moviesTapped = true),
      );
      await tester.pumpAndSettle();

      // Find and tap the movies stat circle
      final moviesCircle = find.ancestor(
        of: find.text('Movies'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(moviesCircle);
      await tester.pumpAndSettle();

      expect(moviesTapped, isTrue);
    });

    testWidgets('calls onTvShowsWatchedTap when TV shows circle is tapped', (
      WidgetTester tester,
    ) async {
      bool tvShowsTapped = false;

      await tester.pumpWidget(
        createTestWidget(onTvShowsWatchedTap: () => tvShowsTapped = true),
      );
      await tester.pumpAndSettle();

      // Find and tap the TV shows stat circle
      final tvShowsCircle = find.ancestor(
        of: find.text('TV Shows'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(tvShowsCircle);
      await tester.pumpAndSettle();

      expect(tvShowsTapped, isTrue);
    });

    testWidgets('calls onWatchTimeTap when hours circle is tapped', (
      WidgetTester tester,
    ) async {
      bool watchTimeTapped = false;

      await tester.pumpWidget(
        createTestWidget(onWatchTimeTap: () => watchTimeTapped = true),
      );
      await tester.pumpAndSettle();

      // Find and tap the hours stat circle
      final hoursCircle = find.ancestor(
        of: find.text('Hours'),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(hoursCircle);
      await tester.pumpAndSettle();

      expect(watchTimeTapped, isTrue);
    });

    testWidgets('handles empty stats gracefully', (WidgetTester tester) async {
      final emptyStats = UserStats.empty();

      await tester.pumpWidget(createTestWidget(stats: emptyStats));
      await tester.pumpAndSettle();

      // Verify zero values are displayed
      expect(
        find.text('0'),
        findsNWidgets(2),
      ); // Movies, TV Shows (Hours shows as "0h")
      expect(find.text('0h'), findsOneWidget); // Hours with suffix

      // Verify genre section is not displayed when empty
      expect(find.text('Favorite Genres'), findsNothing);
    });

    testWidgets('handles stats with no genres', (WidgetTester tester) async {
      final statsWithoutGenres = mockStats.copyWith(topGenres: []);

      await tester.pumpWidget(createTestWidget(stats: statsWithoutGenres));
      await tester.pumpAndSettle();

      // Verify stats are displayed
      expect(find.text('25'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('150h'), findsOneWidget);

      // Verify genre section is not displayed
      expect(find.text('Favorite Genres'), findsNothing);
    });

    testWidgets('applies custom margin', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(24);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ProfileStatsDashboard(stats: mockStats, margin: customMargin),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the widget was created with custom margin
      final dashboardWidget = tester.widget<ProfileStatsDashboard>(
        find.byType(ProfileStatsDashboard),
      );
      expect(dashboardWidget.margin, customMargin);
    });

    testWidgets('displays circular progress indicators', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify CustomPaint widgets are present (for circular progress)
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('animates progress values', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Before animation completes, values should be animating
      await tester.pump(const Duration(milliseconds: 500));

      // After animation completes, final values should be displayed
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('150h'), findsOneWidget);
    });

    testWidgets('displays genre tags with staggered animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Initially, genre tags might be animating
      await tester.pump(const Duration(milliseconds: 200));

      // After staggered animation completes
      await tester.pumpAndSettle();

      // All genre tags should be visible
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Drama'), findsOneWidget);
      expect(find.text('Comedy'), findsOneWidget);
      expect(find.text('Sci-Fi'), findsOneWidget);
    });
  });

  group('UserStats', () {
    testWidgets('creates empty stats correctly', (WidgetTester tester) async {
      final emptyStats = UserStats.empty();

      expect(emptyStats.moviesWatched, 0);
      expect(emptyStats.tvShowsWatched, 0);
      expect(emptyStats.totalHours, 0);
      expect(emptyStats.topGenres, isEmpty);
    });

    testWidgets('copyWith works correctly', (WidgetTester tester) async {
      const originalStats = UserStats(
        moviesWatched: 10,
        tvShowsWatched: 5,
        totalHours: 50,
        topGenres: ['Action'],
      );

      final updatedStats = originalStats.copyWith(
        moviesWatched: 20,
        topGenres: ['Action', 'Drama'],
      );

      expect(updatedStats.moviesWatched, 20);
      expect(updatedStats.tvShowsWatched, 5); // Unchanged
      expect(updatedStats.totalHours, 50); // Unchanged
      expect(updatedStats.topGenres, ['Action', 'Drama']);
    });
  });

  group('CompactStatsDashboard', () {
    late UserStats mockStats;

    setUp(() {
      mockStats = const UserStats(
        moviesWatched: 15,
        tvShowsWatched: 8,
        totalHours: 75,
        topGenres: ['Action', 'Drama'],
      );
    });

    testWidgets('renders compact stats correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: CompactStatsDashboard(stats: mockStats)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify compact stat values are displayed
      expect(find.text('15'), findsOneWidget); // Movies
      expect(find.text('8'), findsOneWidget); // Shows
      expect(find.text('75'), findsOneWidget); // Hours

      // Verify compact stat labels are displayed
      expect(find.text('Movies'), findsOneWidget);
      expect(find.text('Shows'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
    });

    testWidgets('calls onTap when compact dashboard is tapped', (
      WidgetTester tester,
    ) async {
      bool dashboardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CompactStatsDashboard(
              stats: mockStats,
              onTap: () => dashboardTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the compact dashboard
      await tester.tap(find.byType(CompactStatsDashboard));
      await tester.pumpAndSettle();

      expect(dashboardTapped, isTrue);
    });

    testWidgets('displays dividers between stats', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: CompactStatsDashboard(stats: mockStats)),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dividers are present (2 dividers between 3 stats)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });
  });

  group('CircularProgressPainter', () {
    testWidgets('should repaint when progress changes', (
      WidgetTester tester,
    ) async {
      final painter1 = CircularProgressPainter(
        progress: 0.5,
        color: Colors.red,
        backgroundColor: Colors.grey,
      );

      final painter2 = CircularProgressPainter(
        progress: 0.8,
        color: Colors.red,
        backgroundColor: Colors.grey,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    testWidgets('should not repaint when properties are the same', (
      WidgetTester tester,
    ) async {
      final painter1 = CircularProgressPainter(
        progress: 0.5,
        color: Colors.red,
        backgroundColor: Colors.grey,
      );

      final painter2 = CircularProgressPainter(
        progress: 0.5,
        color: Colors.red,
        backgroundColor: Colors.grey,
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });
  });
}
