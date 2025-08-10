import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/presentation/pages/profile/widgets/profile_stats_dashboard.dart';

void main() {
  group('ProfileStatsDashboard', () {
    late Map<String, dynamic> mockUserStats;

    setUp(() {
      mockUserStats = {
        'moviesWatched': 45,
        'moviesGoal': 100,
        'showsWatched': 12,
        'showsGoal': 50,
        'hoursWatched': 250,
        'hoursGoal': 500,
        'topGenres': [
          {'name': 'Action', 'count': 25, 'color': Colors.red},
          {'name': 'Drama', 'count': 20, 'color': Colors.blue},
          {'name': 'Comedy', 'count': 15, 'color': Colors.amber},
        ],
        'recentActivity': [
          {
            'title': 'The Dark Knight',
            'type': 'movie',
            'action': 'watched',
            'date': '2024-01-15',
            'rating': 9.0,
          },
          {
            'title': 'Breaking Bad',
            'type': 'tv',
            'action': 'added_to_watchlist',
            'date': '2024-01-14',
            'rating': null,
          },
        ],
      };
    });

    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ProfileStatsDashboard(userStats: mockUserStats)),
        ),
      );
    }

    testWidgets('should display dashboard header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Your Cinematic Journey'), findsOneWidget);
      expect(
        find.text('Track your viewing progress and milestones'),
        findsOneWidget,
      );
    });

    testWidgets('should display progress rings', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Movies'), findsOneWidget);
      expect(find.text('TV Shows'), findsOneWidget);
      expect(find.text('Hours'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
    });

    testWidgets('should display genre distribution', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Favorite Genres'), findsOneWidget);
      expect(find.text('Action (25)'), findsOneWidget);
      expect(find.text('Drama (20)'), findsOneWidget);
      expect(find.text('Comedy (15)'), findsOneWidget);
    });

    testWidgets('should display recent activity', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('The Dark Knight'), findsOneWidget);
      expect(find.text('Breaking Bad'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('should show view all activity snackbar when tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(find.text('Opening full activity view...'), findsOneWidget);
    });

    testWidgets('should handle empty stats gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: ProfileStatsDashboard(userStats: {})),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should display zeros for empty stats
      expect(find.text('0'), findsAtLeastNWidgets(3));
    });

    testWidgets('should display progress percentages', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Movies: 45/100 = 45%
      expect(find.text('45% of 100'), findsOneWidget);
      // Shows: 12/50 = 24%
      expect(find.text('24% of 50'), findsOneWidget);
      // Hours: 250/500 = 50%
      expect(find.text('50% of 500'), findsOneWidget);
    });

    testWidgets('should display activity with ratings', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show rating for The Dark Knight
      expect(find.text('9.0'), findsOneWidget);
      // Should show star icon for rated content
      expect(find.byIcon(Icons.star_rounded), findsAtLeastNWidgets(1));
    });

    testWidgets('should display different action types', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Watched'), findsOneWidget);
      expect(find.text('Added to Watchlist'), findsOneWidget);
    });
  });

  group('ProgressRingPainter', () {
    test('should create painter with correct properties', () {
      final painter = ProgressRingPainter(
        progress: 0.5,
        color: Colors.red,
        strokeWidth: 8.0,
      );

      expect(painter.progress, 0.5);
      expect(painter.color, Colors.red);
      expect(painter.strokeWidth, 8.0);
    });
  });

  group('GenreChartPainter', () {
    testWidgets('should create painter with correct properties', (
      WidgetTester tester,
    ) async {
      final controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: const TestVSync(),
      );

      final genres = [
        {'name': 'Action', 'count': 25, 'color': Colors.red},
        {'name': 'Drama', 'count': 20, 'color': Colors.blue},
      ];

      final painter = GenreChartPainter(
        genres: genres,
        total: 45,
        animation: controller,
      );

      expect(painter.genres, genres);
      expect(painter.total, 45);
      expect(painter.animation, controller);

      controller.dispose();
    });
  });
}
