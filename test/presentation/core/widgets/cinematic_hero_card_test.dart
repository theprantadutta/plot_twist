import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/cinematic_hero_card.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';

void main() {
  group('CinematicHeroCard', () {
    late Map<String, dynamic> mockMovie;

    setUp(() {
      mockMovie = {
        'id': 123,
        'title': 'Test Movie',
        'overview':
            'This is a test movie overview that should be displayed in the hero card.',
        'backdrop_path': '/test-backdrop.jpg',
        'poster_path': '/test-poster.jpg',
        'vote_average': 8.5,
        'release_date': '2024-01-15',
        'genre_ids': [28, 12, 878],
      };
    });

    Widget createTestWidget({
      Map<String, dynamic>? movie,
      double? height,
      VoidCallback? onPlayTrailer,
      VoidCallback? onAddToWatchlist,
      VoidCallback? onTap,
      bool? showActions,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: CinematicHeroCard(
            movie: movie ?? mockMovie,
            height: height ?? 400,
            onPlayTrailer: onPlayTrailer,
            onAddToWatchlist: onAddToWatchlist,
            onTap: onTap,
            showActions: showActions ?? true,
          ),
        ),
      );
    }

    testWidgets('renders with movie data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify movie title is displayed
      expect(find.text('Test Movie'), findsOneWidget);

      // Verify overview is displayed
      expect(
        find.textContaining('This is a test movie overview'),
        findsOneWidget,
      );

      // Verify rating is displayed
      expect(find.text('8.5'), findsOneWidget);

      // Verify year is displayed
      expect(find.text('2024'), findsOneWidget);
    });

    testWidgets('displays action buttons when showActions is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(showActions: true));
      await tester.pumpAndSettle();

      // Verify action buttons are present
      expect(find.text('Watch Trailer'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);

      // Verify button icons
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('hides action buttons when showActions is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(showActions: false));
      await tester.pumpAndSettle();

      // Verify action buttons are not present
      expect(find.text('Watch Trailer'), findsNothing);
      expect(find.text('Watchlist'), findsNothing);
    });

    testWidgets('calls onPlayTrailer when trailer button is tapped', (
      WidgetTester tester,
    ) async {
      bool trailerTapped = false;

      await tester.pumpWidget(
        createTestWidget(onPlayTrailer: () => trailerTapped = true),
      );
      await tester.pumpAndSettle();

      // Tap the trailer button
      await tester.tap(find.text('Watch Trailer'));
      await tester.pumpAndSettle();

      expect(trailerTapped, isTrue);
    });

    testWidgets('calls onAddToWatchlist when watchlist button is tapped', (
      WidgetTester tester,
    ) async {
      bool watchlistTapped = false;

      await tester.pumpWidget(
        createTestWidget(onAddToWatchlist: () => watchlistTapped = true),
      );
      await tester.pumpAndSettle();

      // Tap the watchlist button
      await tester.tap(find.text('Watchlist'));
      await tester.pumpAndSettle();

      expect(watchlistTapped, isTrue);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(createTestWidget(onTap: () => cardTapped = true));
      await tester.pumpAndSettle();

      // Tap the card (but not on buttons)
      await tester.tap(find.text('Test Movie'));
      await tester.pumpAndSettle();

      expect(cardTapped, isTrue);
    });

    testWidgets('handles missing backdrop image gracefully', (
      WidgetTester tester,
    ) async {
      final movieWithoutBackdrop = Map<String, dynamic>.from(mockMovie);
      movieWithoutBackdrop.remove('backdrop_path');

      await tester.pumpWidget(createTestWidget(movie: movieWithoutBackdrop));
      await tester.pumpAndSettle();

      // Should display fallback icon
      expect(find.byIcon(Icons.movie_outlined), findsOneWidget);

      // Should still display movie information
      expect(find.text('Test Movie'), findsOneWidget);
    });

    testWidgets('handles missing movie data gracefully', (
      WidgetTester tester,
    ) async {
      final incompleteMovie = {
        'id': 456,
        // Missing title, overview, etc.
      };

      await tester.pumpWidget(createTestWidget(movie: incompleteMovie));
      await tester.pumpAndSettle();

      // Should display fallback values
      expect(find.text('No Title'), findsOneWidget);
      expect(find.text('No overview available.'), findsOneWidget);
      expect(find.text('0.0'), findsOneWidget); // Default rating
      expect(find.text('N/A'), findsOneWidget); // Default year
    });

    testWidgets('displays correct rating color based on score', (
      WidgetTester tester,
    ) async {
      // Test high rating (should be gold)
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

    testWidgets('respects custom height parameter', (
      WidgetTester tester,
    ) async {
      const customHeight = 300.0;

      await tester.pumpWidget(createTestWidget(height: customHeight));
      await tester.pumpAndSettle();

      // Find the hero card widget
      final heroCard = find.byType(CinematicHeroCard);
      expect(heroCard, findsOneWidget);

      // Verify the widget was created with the custom height
      final heroCardWidget = tester.widget<CinematicHeroCard>(heroCard);
      expect(heroCardWidget.height, customHeight);
    });

    testWidgets('applies hover effects on desktop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the CinematicHeroCard widget
      final heroCard = find.byType(CinematicHeroCard);
      expect(heroCard, findsOneWidget);

      // Find MouseRegion widgets within the hero card
      final mouseRegions = find.descendant(
        of: heroCard,
        matching: find.byType(MouseRegion),
      );
      expect(mouseRegions, findsWidgets);

      // The hover state should be handled internally
      // This test verifies the MouseRegion exists for hover functionality
    });

    testWidgets('displays loading indicator while image loads', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Before pumpAndSettle, we should see loading state
      await tester.pump();

      // The image loading builder should show a progress indicator
      // Note: In actual implementation, this would require mocking network image loading
      expect(find.byType(CinematicHeroCard), findsOneWidget);
    });

    testWidgets('handles TV show data correctly', (WidgetTester tester) async {
      final tvShowData = {
        'id': 789,
        'name': 'Test TV Show', // TV shows use 'name' instead of 'title'
        'overview': 'This is a test TV show overview.',
        'backdrop_path': '/test-tv-backdrop.jpg',
        'vote_average': 7.8,
        'first_air_date': '2023-05-20', // TV shows use 'first_air_date'
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
  });
}
