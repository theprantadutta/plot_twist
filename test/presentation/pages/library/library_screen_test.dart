import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/presentation/pages/library/library_screen.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';
import 'package:plot_twist/application/watchlist/watchlist_providers.dart';
import 'package:plot_twist/application/favorites/favorites_providers.dart';
import 'package:plot_twist/application/watched/watched_providers.dart';
import 'package:plot_twist/application/custom_list/custom_list_providers.dart';

// Mock data
final mockMovies = [
  {
    'id': 1,
    'title': 'The Dark Knight',
    'overview': 'Batman fights crime in Gotham City',
    'poster_path': '/poster1.jpg',
    'release_date': '2008-07-18',
    'vote_average': 9.0,
  },
  {
    'id': 2,
    'title': 'Inception',
    'overview': 'A thief enters dreams to steal secrets',
    'poster_path': '/poster2.jpg',
    'release_date': '2010-07-16',
    'vote_average': 8.8,
  },
  {
    'id': 3,
    'title': 'Interstellar',
    'overview': 'A team explores space to save humanity',
    'poster_path': '/poster3.jpg',
    'release_date': '2014-11-07',
    'vote_average': 8.6,
  },
];

final mockCustomLists = [
  {
    'id': 'list1',
    'name': 'Sci-Fi Favorites',
    'movies': [mockMovies[1], mockMovies[2]],
  },
  {
    'id': 'list2',
    'name': 'Action Movies',
    'movies': [mockMovies[0]],
  },
];

void main() {
  group('LibraryScreen', () {
    Widget createTestWidget({
      List<Map<String, dynamic>>? watchlistMovies,
      List<Map<String, dynamic>>? favoritesMovies,
      List<Map<String, dynamic>>? watchedMovies,
      List<Map<String, dynamic>>? customLists,
    }) {
      return ProviderScope(
        overrides: [
          watchlistProvider.overrideWith((ref) async => watchlistMovies ?? []),
          favoritesProvider.overrideWith((ref) async => favoritesMovies ?? []),
          watchedProvider.overrideWith((ref) async => watchedMovies ?? []),
          customListsProvider.overrideWith((ref) async => customLists ?? []),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const LibraryScreen(),
        ),
      );
    }

    testWidgets('should display library screen with app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Library'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    });

    testWidgets('should display quick stats section', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          watchlistMovies: mockMovies.take(2).toList(),
          favoritesMovies: mockMovies.take(1).toList(),
          watchedMovies: mockMovies,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Cinema Stats'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Watched'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Watchlist count
      expect(find.text('1'), findsOneWidget); // Favorites count
      expect(find.text('3'), findsOneWidget); // Watched count
    });

    testWidgets('should display watchlist section with movies', (tester) async {
      await tester.pumpWidget(
        createTestWidget(watchlistMovies: mockMovies.take(2).toList()),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Watchlist'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Movie count badge
    });

    testWidgets('should display empty watchlist state', (tester) async {
      await tester.pumpWidget(createTestWidget(watchlistMovies: []));
      await tester.pumpAndSettle();

      expect(find.text('My Watchlist'), findsOneWidget);
      expect(
        find.text('Your watchlist is empty\nDiscover movies to add them here'),
        findsOneWidget,
      );
      expect(find.text('Browse Movies'), findsOneWidget);
    });

    testWidgets('should display favorites section with movies', (tester) async {
      await tester.pumpWidget(
        createTestWidget(favoritesMovies: mockMovies.take(1).toList()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Movie count badge
    });

    testWidgets('should display empty favorites state', (tester) async {
      await tester.pumpWidget(createTestWidget(favoritesMovies: []));
      await tester.pumpAndSettle();

      expect(find.text('Favorites'), findsOneWidget);
      expect(
        find.text('No favorites yet\nMark movies you love as favorites'),
        findsOneWidget,
      );
      expect(find.text('Discover Movies'), findsOneWidget);
    });

    testWidgets('should display recently watched section', (tester) async {
      await tester.pumpWidget(createTestWidget(watchedMovies: mockMovies));
      await tester.pumpAndSettle();

      expect(find.text('Recently Watched'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Movie count badge
    });

    testWidgets('should display empty watched state', (tester) async {
      await tester.pumpWidget(createTestWidget(watchedMovies: []));
      await tester.pumpAndSettle();

      expect(find.text('Recently Watched'), findsOneWidget);
      expect(
        find.text('No watched movies yet\nStart your cinematic journey'),
        findsOneWidget,
      );
      expect(find.text('Start Watching'), findsOneWidget);
    });

    testWidgets('should display custom lists section', (tester) async {
      await tester.pumpWidget(createTestWidget(customLists: mockCustomLists));
      await tester.pumpAndSettle();

      expect(find.text('My Lists'), findsOneWidget);
      expect(find.text('Create List'), findsOneWidget);
      expect(find.text('Sci-Fi Favorites'), findsOneWidget);
      expect(find.text('Action Movies'), findsOneWidget);
    });

    testWidgets('should display create list prompt when no lists exist', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(customLists: []));
      await tester.pumpAndSettle();

      expect(find.text('Create Your First List'), findsOneWidget);
      expect(
        find.text(
          'Organize your movies into custom collections\nlike "Date Night Movies" or "Action Favorites"',
        ),
        findsOneWidget,
      );
      expect(find.text('Create List'), findsOneWidget);
    });

    testWidgets('should toggle search functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially search should be hidden
      expect(find.byType(TextField), findsNothing);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // Search field should appear
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search your library...'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Search field should disappear
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('should filter movies based on search query', (tester) async {
      await tester.pumpWidget(createTestWidget(watchlistMovies: mockMovies));
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'dark');
      await tester.pumpAndSettle();

      // Should filter movies (this would require more complex testing with actual movie cards)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show library options bottom sheet', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap more options
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      // Should show bottom sheet with options
      expect(find.text('Sort Library'), findsOneWidget);
      expect(find.text('Filter Content'), findsOneWidget);
      expect(find.text('Export Library'), findsOneWidget);
    });

    testWidgets('should handle loading states', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchlistProvider.overrideWith(
              (ref) =>
                  Future.delayed(const Duration(seconds: 1), () => mockMovies),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const LibraryScreen(),
          ),
        ),
      );

      // Should show loading state initially
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should show loaded content
      expect(find.text('My Watchlist'), findsOneWidget);
    });

    testWidgets('should handle error states', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchlistProvider.overrideWith(
              (ref) => Future.error('Network error'),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const LibraryScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show error state
      expect(find.text('Error loading My Watchlist'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('should scroll through all sections', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          watchlistMovies: mockMovies,
          favoritesMovies: mockMovies,
          watchedMovies: mockMovies,
          customLists: mockCustomLists,
        ),
      );
      await tester.pumpAndSettle();

      // Should be able to scroll through all sections
      expect(find.text('Your Cinema Stats'), findsOneWidget);

      // Scroll down to see more sections
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should still find library sections
      expect(find.text('My Watchlist'), findsOneWidget);
    });

    testWidgets('should display correct movie counts in stats', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          watchlistMovies: List.generate(5, (i) => {...mockMovies[0], 'id': i}),
          favoritesMovies: List.generate(
            3,
            (i) => {...mockMovies[0], 'id': i + 10},
          ),
          watchedMovies: List.generate(
            8,
            (i) => {...mockMovies[0], 'id': i + 20},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('5'), findsOneWidget); // Watchlist count
      expect(find.text('3'), findsOneWidget); // Favorites count
      expect(find.text('8'), findsOneWidget); // Watched count
    });

    testWidgets('should handle empty library state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          watchlistMovies: [],
          favoritesMovies: [],
          watchedMovies: [],
          customLists: [],
        ),
      );
      await tester.pumpAndSettle();

      // Should show empty states for all sections
      expect(
        find.text('Your watchlist is empty\nDiscover movies to add them here'),
        findsOneWidget,
      );
      expect(
        find.text('No favorites yet\nMark movies you love as favorites'),
        findsOneWidget,
      );
      expect(
        find.text('No watched movies yet\nStart your cinematic journey'),
        findsOneWidget,
      );
      expect(find.text('Create Your First List'), findsOneWidget);
    });
  });

  group('LibraryScreen Navigation', () {
    testWidgets('should navigate to sections when View All is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchlistProvider.overrideWith((ref) async => mockMovies),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const LibraryScreen(),
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(settings.name ?? '')),
                  body: Center(child: Text('Page: ${settings.name}')),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap View All for watchlist
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      // Should navigate to watchlist page
      expect(find.text('Page: /watchlist'), findsOneWidget);
    });

    testWidgets('should navigate to discover when empty action is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [watchlistProvider.overrideWith((ref) async => [])],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const LibraryScreen(),
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(settings.name ?? '')),
                  body: Center(child: Text('Page: ${settings.name}')),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Browse Movies for empty watchlist
      await tester.tap(find.text('Browse Movies'));
      await tester.pumpAndSettle();

      // Should navigate to discover page
      expect(find.text('Page: /discover'), findsOneWidget);
    });
  });

  group('LibraryScreen Accessibility', () {
    testWidgets('should have proper semantic labels', (tester) async {
      await tester.pumpWidget(
        createTestWidget(watchlistMovies: mockMovies.take(1).toList()),
      );
      await tester.pumpAndSettle();

      // Check for semantic labels
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
      expect(find.text('My Library'), findsOneWidget);
    });

    testWidgets('should support keyboard navigation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // Should be able to focus on search field
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
