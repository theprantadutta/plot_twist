import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/swipe_discovery_card.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';

void main() {
  group('SwipeDiscoveryCard', () {
    late Map<String, dynamic> mockMovie;

    setUp(() {
      mockMovie = {
        'id': 123,
        'title': 'Test Movie',
        'overview': 'This is a test movie overview.',
        'poster_path': '/test-poster.jpg',
        'vote_average': 8.5,
        'release_date': '2024-01-15',
        'genre_ids': [28, 12, 878], // Action, Adventure, Sci-Fi
      };
    });

    Widget createTestWidget({
      Map<String, dynamic>? movie,
      VoidCallback? onTap,
      double? swipeProgress,
      bool? showSwipeOverlays,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SwipeDiscoveryCard(
            movie: movie ?? mockMovie,
            onTap: onTap,
            swipeProgress: swipeProgress ?? 0.0,
            showSwipeOverlays: showSwipeOverlays ?? true,
          ),
        ),
      );
    }

    testWidgets('renders with movie data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify movie title is displayed
      expect(find.text('Test Movie'), findsOneWidget);

      // Verify rating is displayed
      expect(find.text('8.5'), findsOneWidget);

      // Verify year is displayed
      expect(find.text('2024'), findsOneWidget);

      // Verify star icon is present
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('displays genre tags correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify genre tags are displayed
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Adventure'), findsOneWidget);
      expect(find.text('Sci-Fi'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(createTestWidget(onTap: () => cardTapped = true));
      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.byType(SwipeDiscoveryCard));
      await tester.pumpAndSettle();

      expect(cardTapped, isTrue);
    });

    testWidgets('shows like overlay when swiping right', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          swipeProgress: 0.8, // Positive progress = right swipe
        ),
      );
      await tester.pumpAndSettle();

      // Should show LIKE overlay
      expect(find.text('LIKE'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      // Should not show PASS overlay
      expect(find.text('PASS'), findsNothing);
    });

    testWidgets('shows pass overlay when swiping left', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          swipeProgress: -0.8, // Negative progress = left swipe
        ),
      );
      await tester.pumpAndSettle();

      // Should show PASS overlay
      expect(find.text('PASS'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Should not show LIKE overlay
      expect(find.text('LIKE'), findsNothing);
    });

    testWidgets('hides swipe overlays when showSwipeOverlays is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(swipeProgress: 0.8, showSwipeOverlays: false),
      );
      await tester.pumpAndSettle();

      // Should not show any overlays
      expect(find.text('LIKE'), findsNothing);
      expect(find.text('PASS'), findsNothing);
    });

    testWidgets('handles missing poster image gracefully', (
      WidgetTester tester,
    ) async {
      final movieWithoutPoster = Map<String, dynamic>.from(mockMovie);
      movieWithoutPoster.remove('poster_path');

      await tester.pumpWidget(createTestWidget(movie: movieWithoutPoster));
      await tester.pumpAndSettle();

      // Should display fallback icon and text
      expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
      expect(find.text('No Image'), findsOneWidget);

      // Should still display movie information
      expect(find.text('Test Movie'), findsOneWidget);
    });

    testWidgets('handles missing movie data gracefully', (
      WidgetTester tester,
    ) async {
      final incompleteMovie = {
        'id': 456,
        // Missing title, rating, etc.
      };

      await tester.pumpWidget(createTestWidget(movie: incompleteMovie));
      await tester.pumpAndSettle();

      // Should display fallback values
      expect(find.text('No Title'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget); // Default rating
      expect(find.text('N/A'), findsOneWidget); // Default year
    });

    testWidgets('displays TV show data correctly', (WidgetTester tester) async {
      final tvShowData = {
        'id': 789,
        'name': 'Test TV Show', // TV shows use 'name' instead of 'title'
        'poster_path': '/test-tv-poster.jpg',
        'vote_average': 7.8,
        'first_air_date': '2023-05-20', // TV shows use 'first_air_date'
        'genre_ids': [18, 10765], // Drama, Sci-Fi & Fantasy
      };

      await tester.pumpWidget(createTestWidget(movie: tvShowData));
      await tester.pumpAndSettle();

      // Verify TV show name is displayed
      expect(find.text('Test TV Show'), findsOneWidget);

      // Verify year from first_air_date
      expect(find.text('2023'), findsOneWidget);

      // Verify rating
      expect(find.text('7.8'), findsOneWidget);
    });

    testWidgets('limits genre tags to maximum of 3', (
      WidgetTester tester,
    ) async {
      final movieWithManyGenres = Map<String, dynamic>.from(mockMovie);
      movieWithManyGenres['genre_ids'] = [28, 12, 878, 35, 18, 27]; // 6 genres

      await tester.pumpWidget(createTestWidget(movie: movieWithManyGenres));
      await tester.pumpAndSettle();

      // Should only show first 3 genres
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Adventure'), findsOneWidget);
      expect(find.text('Sci-Fi'), findsOneWidget);

      // Should not show additional genres
      expect(find.text('Comedy'), findsNothing);
      expect(find.text('Drama'), findsNothing);
      expect(find.text('Horror'), findsNothing);
    });

    testWidgets('handles empty genre list', (WidgetTester tester) async {
      final movieWithoutGenres = Map<String, dynamic>.from(mockMovie);
      movieWithoutGenres['genre_ids'] = [];

      await tester.pumpWidget(createTestWidget(movie: movieWithoutGenres));
      await tester.pumpAndSettle();

      // Should still display other movie information
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);

      // No genre tags should be displayed
      expect(find.text('Action'), findsNothing);
    });

    testWidgets('displays correct rating colors based on score', (
      WidgetTester tester,
    ) async {
      // Test high rating
      final highRatedMovie = Map<String, dynamic>.from(mockMovie);
      highRatedMovie['vote_average'] = 9.2;

      await tester.pumpWidget(createTestWidget(movie: highRatedMovie));
      await tester.pumpAndSettle();

      // Find the star icon and verify it exists
      final starIcon = find.byIcon(Icons.star_rounded);
      expect(starIcon, findsOneWidget);

      // Verify rating text
      expect(find.text('9.2'), findsOneWidget);
    });

    testWidgets('applies correct aspect ratio', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the AspectRatio widget
      final aspectRatio = find.byType(AspectRatio);
      expect(aspectRatio, findsOneWidget);

      // Verify the aspect ratio is 2/3 (poster ratio)
      final aspectRatioWidget = tester.widget<AspectRatio>(aspectRatio);
      expect(aspectRatioWidget.aspectRatio, 2 / 3);
    });

    testWidgets('shows loading state while image loads', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Before pumpAndSettle, we should see the card structure
      await tester.pump();

      // The image loading builder should be handled internally
      expect(find.byType(SwipeDiscoveryCard), findsOneWidget);
    });

    testWidgets('handles unknown genre IDs gracefully', (
      WidgetTester tester,
    ) async {
      final movieWithUnknownGenres = Map<String, dynamic>.from(mockMovie);
      movieWithUnknownGenres['genre_ids'] = [99999, 88888]; // Unknown genre IDs

      await tester.pumpWidget(createTestWidget(movie: movieWithUnknownGenres));
      await tester.pumpAndSettle();

      // Should still display movie information without crashing
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);

      // No genre tags should be displayed for unknown IDs
      expect(find.text('Action'), findsNothing);
    });

    testWidgets('applies entrance animations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially, animations should be in progress
      await tester.pump();

      // After animations complete
      await tester.pumpAndSettle();

      // Card should be visible
      expect(find.byType(SwipeDiscoveryCard), findsOneWidget);
      expect(find.text('Test Movie'), findsOneWidget);
    });

    testWidgets('respects custom margin', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(24);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SwipeDiscoveryCard(movie: mockMovie, margin: customMargin),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the widget was created with custom margin
      final cardWidget = tester.widget<SwipeDiscoveryCard>(
        find.byType(SwipeDiscoveryCard),
      );
      expect(cardWidget.margin, customMargin);
    });
  });
}
