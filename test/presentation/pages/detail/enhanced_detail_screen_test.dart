import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/presentation/pages/detail/enhanced_detail_screen.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';

void main() {
  group('EnhancedDetailScreen', () {
    final mockMovie = {
      'id': 1,
      'title': 'The Dark Knight',
      'overview': 'Batman fights crime in Gotham City with the help of allies.',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'release_date': '2008-07-18',
      'vote_average': 9.0,
      'runtime': 152,
      'genres': [
        {'id': 28, 'name': 'Action'},
        {'id': 80, 'name': 'Crime'},
      ],
    };

    Widget createTestWidget({
      Map<String, dynamic>? media,
      String mediaType = 'movie',
    }) {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: EnhancedDetailScreen(
            media: media ?? mockMovie,
            mediaType: mediaType,
          ),
        ),
      );
    }

    testWidgets('should display enhanced detail screen with hero section', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedDetailScreen), findsOneWidget);
      expect(find.text('The Dark Knight'), findsOneWidget);
    });

    testWidgets('should display movie information correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('The Dark Knight'), findsOneWidget);
      expect(
        find.text(
          'Batman fights crime in Gotham City with the help of allies.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should handle TV show media type', (tester) async {
      final mockTvShow = {
        'id': 1,
        'name': 'Breaking Bad',
        'overview': 'A high school chemistry teacher turned meth cook.',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'first_air_date': '2008-01-20',
        'vote_average': 9.5,
        'episode_run_time': [47],
      };

      await tester.pumpWidget(
        createTestWidget(media: mockTvShow, mediaType: 'tv'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Breaking Bad'), findsOneWidget);
      expect(
        find.text('A high school chemistry teacher turned meth cook.'),
        findsOneWidget,
      );
    });

    testWidgets('should display action buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for action buttons (watchlist, favorite, etc.)
      expect(find.byIcon(Icons.bookmark_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline_rounded), findsOneWidget);
    });

    testWidgets('should handle missing backdrop image', (tester) async {
      final movieWithoutBackdrop = Map<String, dynamic>.from(mockMovie);
      movieWithoutBackdrop.remove('backdrop_path');

      await tester.pumpWidget(createTestWidget(media: movieWithoutBackdrop));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedDetailScreen), findsOneWidget);
    });

    testWidgets('should display rating information', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('9.0'), findsOneWidget);
    });

    testWidgets('should handle scroll interactions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test scrolling behavior
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedDetailScreen), findsOneWidget);
    });

    testWidgets('should display genre information', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Crime'), findsOneWidget);
    });

    testWidgets('should handle trailer playback', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Look for play button
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });

    testWidgets('should display runtime information', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('152'), findsOneWidget);
    });
  });

  group('EnhancedDetailScreen Interactions', () {
    final mockMovie = {
      'id': 1,
      'title': 'Inception',
      'overview': 'A thief enters dreams to steal secrets.',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'release_date': '2010-07-16',
      'vote_average': 8.8,
      'runtime': 148,
    };

    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: EnhancedDetailScreen(media: mockMovie, mediaType: 'movie'),
        ),
      );
    }

    testWidgets('should handle watchlist toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap watchlist button
      await tester.tap(find.byIcon(Icons.bookmark_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedDetailScreen), findsOneWidget);
    });

    testWidgets('should handle favorite toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap favorite button
      await tester.tap(find.byIcon(Icons.favorite_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedDetailScreen), findsOneWidget);
    });

    testWidgets('should handle back navigation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedDetailScreen), findsOneWidget);
    });
  });

  group('EnhancedDetailScreen Animations', () {
    final mockMovie = {
      'id': 1,
      'title': 'Interstellar',
      'overview': 'A team explores space to save humanity.',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'release_date': '2014-11-07',
      'vote_average': 8.6,
      'runtime': 169,
    };

    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: EnhancedDetailScreen(media: mockMovie, mediaType: 'movie'),
        ),
      );
    }

    testWidgets('should animate hero section on load', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should start with animations
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);

      await tester.pumpAndSettle();

      expect(find.text('Interstellar'), findsOneWidget);
    });

    testWidgets('should show sticky header on scroll', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll down to trigger sticky header
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.byType(EnhancedDetailScreen), findsOneWidget);
    });
  });
}
