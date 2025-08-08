import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/library_section_card.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';

void main() {
  group('LibrarySectionCard', () {
    late List<Map<String, dynamic>> mockMovies;

    setUp(() {
      mockMovies = [
        {
          'id': 1,
          'title': 'Test Movie 1',
          'poster_path': '/test1.jpg',
          'vote_average': 8.5,
        },
        {
          'id': 2,
          'title': 'Test Movie 2',
          'poster_path': '/test2.jpg',
          'vote_average': 7.2,
        },
        {
          'id': 3,
          'name': 'Test TV Show',
          'poster_path': '/test3.jpg',
          'vote_average': 9.1,
        },
      ];
    });

    Widget createTestWidget({
      String? title,
      List<Map<String, dynamic>>? movies,
      String? emptyStateMessage,
      VoidCallback? onViewAll,
      VoidCallback? onEmptyAction,
      String? emptyActionText,
      bool? showViewAll,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: LibrarySectionCard(
            title: title ?? 'Test Section',
            movies: movies ?? mockMovies,
            emptyStateMessage: emptyStateMessage ?? 'No items found',
            onViewAll: onViewAll,
            onEmptyAction: onEmptyAction,
            emptyActionText: emptyActionText,
            showViewAll: showViewAll ?? true,
          ),
        ),
      );
    }

    testWidgets('renders with movie data', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify section title is displayed
      expect(find.text('Test Section'), findsOneWidget);

      // Verify movie count badge is displayed
      expect(find.text('3'), findsOneWidget);

      // Verify View All button is displayed
      expect(find.text('View All'), findsOneWidget);

      // Verify movies are displayed in horizontal list
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays empty state when no movies', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          movies: [],
          emptyStateMessage: 'No movies found',
          emptyActionText: 'Add Movies',
        ),
      );
      await tester.pumpAndSettle();

      // Verify empty state message is displayed
      expect(find.text('No movies found'), findsOneWidget);

      // Verify empty state icon is displayed
      expect(find.byIcon(Icons.movie_outlined), findsOneWidget);

      // Verify View All button is not displayed
      expect(find.text('View All'), findsNothing);

      // Verify movie count badge is not displayed
      expect(find.text('0'), findsNothing);
    });

    testWidgets('displays empty action button when provided', (
      WidgetTester tester,
    ) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          movies: [],
          emptyActionText: 'Add Movies',
          onEmptyAction: () => actionCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      // Verify action button is displayed
      expect(find.text('Add Movies'), findsOneWidget);

      // Tap the action button
      await tester.tap(find.text('Add Movies'));
      await tester.pumpAndSettle();

      expect(actionCalled, isTrue);
    });

    testWidgets('calls onViewAll when View All is tapped', (
      WidgetTester tester,
    ) async {
      bool viewAllCalled = false;

      await tester.pumpWidget(
        createTestWidget(onViewAll: () => viewAllCalled = true),
      );
      await tester.pumpAndSettle();

      // Tap the View All button
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(viewAllCalled, isTrue);
    });

    testWidgets('hides View All button when showViewAll is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(showViewAll: false));
      await tester.pumpAndSettle();

      // Verify View All button is not displayed
      expect(find.text('View All'), findsNothing);
    });

    testWidgets('displays correct movie count in badge', (
      WidgetTester tester,
    ) async {
      final singleMovie = [mockMovies.first];

      await tester.pumpWidget(createTestWidget(movies: singleMovie));
      await tester.pumpAndSettle();

      // Verify single movie count
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('handles custom empty state icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: LibrarySectionCard(
              title: 'Custom Section',
              movies: const [],
              emptyStateIcon: Icons.favorite_outline_rounded,
              emptyStateMessage: 'No favorites',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify custom icon is displayed
      expect(find.byIcon(Icons.favorite_outline_rounded), findsOneWidget);
      expect(find.text('No favorites'), findsOneWidget);
    });

    testWidgets('applies custom margin', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(24);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: LibrarySectionCard(
              title: 'Test Section',
              movies: mockMovies,
              margin: customMargin,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the widget was created with custom margin
      final cardWidget = tester.widget<LibrarySectionCard>(
        find.byType(LibrarySectionCard),
      );
      expect(cardWidget.margin, customMargin);
    });

    testWidgets('applies custom card height', (WidgetTester tester) async {
      const customHeight = 300.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: LibrarySectionCard(
              title: 'Test Section',
              movies: mockMovies,
              cardHeight: customHeight,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the widget was created with custom height
      final cardWidget = tester.widget<LibrarySectionCard>(
        find.byType(LibrarySectionCard),
      );
      expect(cardWidget.cardHeight, customHeight);
    });
  });

  group('WatchlistSectionCard', () {
    testWidgets('renders with correct title and empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: WatchlistSectionCard(movies: [])),
        ),
      );
      await tester.pumpAndSettle();

      // Verify watchlist-specific content
      expect(find.text('My Watchlist'), findsOneWidget);
      expect(find.textContaining('Your watchlist is empty'), findsOneWidget);
      expect(find.text('Browse Movies'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_outline_rounded), findsOneWidget);
    });

    testWidgets('calls browse movies action', (WidgetTester tester) async {
      bool browseCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: WatchlistSectionCard(
              movies: const [],
              onBrowseMovies: () => browseCalled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Browse Movies'));
      await tester.pumpAndSettle();

      expect(browseCalled, isTrue);
    });
  });

  group('FavoritesSectionCard', () {
    testWidgets('renders with correct title and empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: FavoritesSectionCard(movies: [])),
        ),
      );
      await tester.pumpAndSettle();

      // Verify favorites-specific content
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.textContaining('No favorites yet'), findsOneWidget);
      expect(find.text('Discover Movies'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline_rounded), findsOneWidget);
    });
  });

  group('WatchedSectionCard', () {
    testWidgets('renders with correct title and empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: WatchedSectionCard(movies: [])),
        ),
      );
      await tester.pumpAndSettle();

      // Verify watched-specific content
      expect(find.text('Recently Watched'), findsOneWidget);
      expect(find.textContaining('No watched movies yet'), findsOneWidget);
      expect(find.text('Start Watching'), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });
  });

  group('CustomListSectionCard', () {
    testWidgets('renders with custom list name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: CustomListSectionCard(
              listName: 'My Action Movies',
              movies: [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify custom list-specific content
      expect(find.text('My Action Movies'), findsOneWidget);
      expect(find.textContaining('This list is empty'), findsOneWidget);
      expect(find.text('Add Movies'), findsOneWidget);
      expect(find.byIcon(Icons.playlist_add_rounded), findsOneWidget);
    });
  });
}
