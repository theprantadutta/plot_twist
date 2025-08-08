import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/movie_poster_card.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';

void main() {
  group('MoviePosterCard', () {
    late Map<String, dynamic> mockMovie;

    setUp(() {
      mockMovie = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test-poster.jpg',
        'vote_average': 8.5,
      };
    });

    Widget createTestWidget({
      Map<String, dynamic>? movie,
      VoidCallback? onTap,
      bool? showRating,
      bool? showTitle,
      double? width,
      double? aspectRatio,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: MoviePosterCard(
            movie: movie ?? mockMovie,
            onTap: onTap,
            showRating: showRating ?? true,
            showTitle: showTitle ?? false,
            width: width,
            aspectRatio: aspectRatio,
          ),
        ),
      );
    }

    testWidgets('renders with movie data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify the card is displayed
      expect(find.byType(MoviePosterCard), findsOneWidget);

      // Verify AspectRatio widget is present
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('displays rating overlay when showRating is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(showRating: true));
      await tester.pumpAndSettle();

      // Verify rating text is displayed
      expect(find.text('8.5'), findsOneWidget);

      // Verify CircularProgressIndicator for rating is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hides rating overlay when showRating is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(showRating: false));
      await tester.pumpAndSettle();

      // Verify rating text is not displayed
      expect(find.text('8.5'), findsNothing);
    });

    testWidgets('displays title when showTitle is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(showTitle: true));
      await tester.pumpAndSettle();

      // Verify movie title is displayed
      expect(find.text('Test Movie'), findsOneWidget);
    });

    testWidgets('hides title when showTitle is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(showTitle: false));
      await tester.pumpAndSettle();

      // Verify movie title is not displayed
      expect(find.text('Test Movie'), findsNothing);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(createTestWidget(onTap: () => cardTapped = true));
      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.byType(MoviePosterCard));
      await tester.pumpAndSettle();

      expect(cardTapped, isTrue);
    });

    testWidgets('handles missing poster image gracefully', (
      WidgetTester tester,
    ) async {
      final movieWithoutPoster = Map<String, dynamic>.from(mockMovie);
      movieWithoutPoster.remove('poster_path');

      await tester.pumpWidget(createTestWidget(movie: movieWithoutPoster));
      await tester.pumpAndSettle();

      // Verify fallback icon and text are displayed
      expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
      expect(find.text('No Image'), findsOneWidget);
    });

    testWidgets('handles missing rating gracefully', (
      WidgetTester tester,
    ) async {
      final movieWithoutRating = Map<String, dynamic>.from(mockMovie);
      movieWithoutRating.remove('vote_average');

      await tester.pumpWidget(createTestWidget(movie: movieWithoutRating));
      await tester.pumpAndSettle();

      // Should not display rating overlay for 0.0 rating
      expect(find.text('0.0'), findsNothing);
    });

    testWidgets('handles TV show data correctly', (WidgetTester tester) async {
      final tvShowData = {
        'id': 789,
        'name': 'Test TV Show', // TV shows use 'name' instead of 'title'
        'poster_path': '/test-tv-poster.jpg',
        'vote_average': 7.8,
      };

      await tester.pumpWidget(
        createTestWidget(movie: tvShowData, showTitle: true),
      );
      await tester.pumpAndSettle();

      // Verify TV show name is displayed when showTitle is true
      expect(find.text('Test TV Show'), findsOneWidget);

      // Verify rating is displayed
      expect(find.text('7.8'), findsOneWidget);
    });

    testWidgets('applies custom width', (WidgetTester tester) async {
      const customWidth = 200.0;

      await tester.pumpWidget(createTestWidget(width: customWidth));
      await tester.pumpAndSettle();

      // Verify the widget was created with custom width
      final cardWidget = tester.widget<MoviePosterCard>(
        find.byType(MoviePosterCard),
      );
      expect(cardWidget.width, customWidth);
    });

    testWidgets('applies custom aspect ratio', (WidgetTester tester) async {
      const customAspectRatio = 1.0; // Square aspect ratio

      await tester.pumpWidget(createTestWidget(aspectRatio: customAspectRatio));
      await tester.pumpAndSettle();

      // Verify the AspectRatio widget has the custom ratio
      final aspectRatioWidget = tester.widget<AspectRatio>(
        find.byType(AspectRatio),
      );
      expect(aspectRatioWidget.aspectRatio, customAspectRatio);
    });

    testWidgets('applies hover effects on desktop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the MouseRegion widget
      final mouseRegion = find.byType(MouseRegion);
      expect(mouseRegion, findsOneWidget);
    });

    testWidgets('handles missing title gracefully', (
      WidgetTester tester,
    ) async {
      final movieWithoutTitle = {
        'id': 456,
        'poster_path': '/test.jpg',
        'vote_average': 6.0,
        // Missing both 'title' and 'name'
      };

      await tester.pumpWidget(
        createTestWidget(movie: movieWithoutTitle, showTitle: true),
      );
      await tester.pumpAndSettle();

      // Should display fallback title
      expect(find.text('No Title'), findsOneWidget);
    });

    testWidgets('displays loading state while image loads', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Before pumpAndSettle, we should see the card structure
      await tester.pump();

      // The image loading builder should be handled internally
      expect(find.byType(MoviePosterCard), findsOneWidget);
    });
  });

  group('WatchlistPosterCard', () {
    late Map<String, dynamic> mockMovie;

    setUp(() {
      mockMovie = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test-poster.jpg',
        'vote_average': 8.5,
      };
    });

    testWidgets('renders with remove button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: WatchlistPosterCard(movie: mockMovie, onRemove: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify remove button is displayed
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('calls onRemove when remove button is tapped', (
      WidgetTester tester,
    ) async {
      bool removeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: WatchlistPosterCard(
              movie: mockMovie,
              onRemove: () => removeCalled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the remove button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(removeCalled, isTrue);
    });

    testWidgets('hides remove button when onRemove is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: WatchlistPosterCard(
              movie: mockMovie,
              // onRemove is null
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify remove button is not displayed
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });

  group('WatchedPosterCard', () {
    late Map<String, dynamic> mockMovie;

    setUp(() {
      mockMovie = {
        'id': 123,
        'title': 'Test Movie',
        'poster_path': '/test-poster.jpg',
        'vote_average': 8.5,
      };
    });

    testWidgets('renders with completion indicator when completed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: WatchedPosterCard(movie: mockMovie, isCompleted: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify completion check icon is displayed
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('hides completion indicator when not completed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: WatchedPosterCard(movie: mockMovie, isCompleted: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify completion check icon is not displayed
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: WatchedPosterCard(
              movie: mockMovie,
              onTap: () => cardTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the card (not the completion indicator)
      await tester.tap(find.byType(MoviePosterCard));
      await tester.pumpAndSettle();

      expect(cardTapped, isTrue);
    });
  });
}
