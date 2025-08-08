import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/presentation/pages/library/library_screen.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';
import 'package:plot_twist/application/watchlist/watchlist_providers.dart';
import 'package:plot_twist/application/favorites/favorites_providers.dart';
import 'package:plot_twist/application/watched/watched_providers.dart';
import 'package:plot_twist/application/custom_list/custom_list_providers.dart';

void main() {
  group('LibraryScreen Basic Tests', () {
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
          watchlistMovies: [
            {'id': 1, 'title': 'Movie 1'},
            {'id': 2, 'title': 'Movie 2'},
          ],
          favoritesMovies: [
            {'id': 1, 'title': 'Movie 1'},
          ],
          watchedMovies: [
            {'id': 1, 'title': 'Movie 1'},
            {'id': 2, 'title': 'Movie 2'},
            {'id': 3, 'title': 'Movie 3'},
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Cinema Stats'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Watched'), findsOneWidget);
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

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Search field should disappear
      expect(find.byType(TextField), findsNothing);
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

    testWidgets('should display empty states', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          watchlistMovies: [],
          favoritesMovies: [],
          watchedMovies: [],
          customLists: [],
        ),
      );
      await tester.pumpAndSettle();

      // Should show empty states for sections
      expect(find.text('Create Your First List'), findsOneWidget);
    });
  });
}
