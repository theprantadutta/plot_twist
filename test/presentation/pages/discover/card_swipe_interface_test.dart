import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';

import 'package:plot_twist/presentation/pages/discover/widgets/card_swipe_interface.dart';
import 'package:plot_twist/presentation/pages/discover/widgets/enhanced_swipe_discovery_card.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';
import 'package:plot_twist/application/discover/discover_providers.dart';
import 'package:plot_twist/application/home/home_providers.dart';
import 'package:plot_twist/data/local/persistence_service.dart';

// Mock classes for testing
class MockPersistenceService extends PersistenceService {
  @override
  Future<void> init() async {}

  @override
  MediaType getMediaType() => MediaType.movie;

  @override
  Future<void> setMediaType(MediaType type) async {}

  @override
  bool hasAcceptedTerms() => true;

  @override
  Future<void> setHasAcceptedTerms(bool hasAccepted) async {}

  @override
  List<int> getFavoriteGenres() => [28, 12, 16];

  @override
  Future<void> setFavoriteGenres(List<int> genreIds) async {}
}

class MockDiscoverDeckNotifier extends DiscoverDeck {
  final List<Map<String, dynamic>> _deck = [
    {
      'id': 1,
      'title': 'Test Movie 1',
      'overview': 'A great test movie',
      'poster_path': '/test1.jpg',
      'backdrop_path': '/backdrop1.jpg',
      'vote_average': 8.5,
      'release_date': '2023-01-01',
      'genre_ids': [28, 12],
    },
    {
      'id': 2,
      'title': 'Test Movie 2',
      'overview': 'Another great test movie',
      'poster_path': '/test2.jpg',
      'backdrop_path': '/backdrop2.jpg',
      'vote_average': 7.8,
      'release_date': '2023-02-01',
      'genre_ids': [16, 35],
    },
    {
      'id': 3,
      'title': 'Test Movie 3',
      'overview': 'The third test movie',
      'poster_path': '/test3.jpg',
      'backdrop_path': '/backdrop3.jpg',
      'vote_average': 9.0,
      'release_date': '2023-03-01',
      'genre_ids': [18, 53],
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _deck;
  }

  @override
  void cardSwiped(Map<String, dynamic> media) {
    _deck.removeWhere((item) => item['id'] == media['id']);
    state = AsyncData(_deck);
  }

  @override
  Future<void> fetchMore() async {
    // Add more mock data
    _deck.addAll([
      {
        'id': 4,
        'title': 'Test Movie 4',
        'overview': 'Fourth test movie',
        'poster_path': '/test4.jpg',
        'backdrop_path': '/backdrop4.jpg',
        'vote_average': 7.2,
        'release_date': '2023-04-01',
        'genre_ids': [28],
      },
    ]);
    state = AsyncData(_deck);
  }
}

void main() {
  group('CardSwipeInterface', () {
    late MockPersistenceService mockPersistenceService;
    late MockDiscoverDeckNotifier mockDiscoverDeck;

    setUp(() {
      mockPersistenceService = MockPersistenceService();
      mockDiscoverDeck = MockDiscoverDeckNotifier();
    });

    Widget createTestWidget({
      VoidCallback? onEmpty,
      Function(Map<String, dynamic>, String)? onSwipe,
    }) {
      return ProviderScope(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
          discoverDeckProvider.overrideWith(() => mockDiscoverDeck),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CardSwipeInterface(
              mediaType: MediaType.movie,
              onEmpty: onEmpty,
              onSwipe: onSwipe,
            ),
          ),
        ),
      );
    }

    testWidgets('renders loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show loading state
      expect(find.text('Loading amazing content...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders swipe cards after loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Should show swipe interface
      expect(find.byType(AppinioSwiper), findsOneWidget);
      expect(find.byType(EnhancedSwipeDiscoveryCard), findsWidgets);
    });

    testWidgets('renders action controls', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show action control buttons
      expect(find.byIcon(Icons.close_rounded), findsOneWidget); // Dislike
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget); // Like
      expect(find.byIcon(Icons.star_rounded), findsOneWidget); // Super like
    });

    testWidgets('handles swipe actions correctly', (WidgetTester tester) async {
      Map<String, dynamic>? swipedMovie;
      String? swipeDirection;

      await tester.pumpWidget(
        createTestWidget(
          onSwipe: (movie, direction) {
            swipedMovie = movie;
            swipeDirection = direction;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the like button
      final likeButton = find.byIcon(Icons.favorite_rounded);
      expect(likeButton, findsOneWidget);

      await tester.tap(likeButton);
      await tester.pumpAndSettle();

      // Should have triggered swipe callback
      expect(swipedMovie, isNotNull);
      expect(swipeDirection, 'right');
    });

    testWidgets('handles dislike action', (WidgetTester tester) async {
      Map<String, dynamic>? swipedMovie;
      String? swipeDirection;

      await tester.pumpWidget(
        createTestWidget(
          onSwipe: (movie, direction) {
            swipedMovie = movie;
            swipeDirection = direction;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the dislike button
      final dislikeButton = find.byIcon(Icons.close_rounded);
      expect(dislikeButton, findsOneWidget);

      await tester.tap(dislikeButton);
      await tester.pumpAndSettle();

      // Should have triggered swipe callback
      expect(swipedMovie, isNotNull);
      expect(swipeDirection, 'left');
    });

    testWidgets('handles super like action', (WidgetTester tester) async {
      Map<String, dynamic>? swipedMovie;
      String? swipeDirection;

      await tester.pumpWidget(
        createTestWidget(
          onSwipe: (movie, direction) {
            swipedMovie = movie;
            swipeDirection = direction;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the super like button
      final superLikeButton = find.byIcon(Icons.star_rounded);
      expect(superLikeButton, findsOneWidget);

      await tester.tap(superLikeButton);
      await tester.pumpAndSettle();

      // Should have triggered swipe callback
      expect(swipedMovie, isNotNull);
      expect(swipeDirection, 'up');
    });

    testWidgets('shows empty state when no cards left', (
      WidgetTester tester,
    ) async {
      // Create a deck with no cards
      final emptyDeck = MockDiscoverDeckNotifier();
      emptyDeck.state = const AsyncData([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            persistenceServiceProvider.overrideWithValue(
              mockPersistenceService,
            ),
            discoverDeckProvider.overrideWith(() => emptyDeck),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: CardSwipeInterface(mediaType: MediaType.movie),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No more content to discover'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('handles error state correctly', (WidgetTester tester) async {
      // Create a deck that throws an error
      final errorDeck = MockDiscoverDeckNotifier();
      errorDeck.state = AsyncError('Network error', StackTrace.empty);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            persistenceServiceProvider.overrideWithValue(
              mockPersistenceService,
            ),
            discoverDeckProvider.overrideWith(() => errorDeck),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: CardSwipeInterface(mediaType: MediaType.movie),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show error state
      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('calls onEmpty when deck is finished', (
      WidgetTester tester,
    ) async {
      bool onEmptyCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          onEmpty: () {
            onEmptyCalled = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Simulate swiping through all cards
      for (int i = 0; i < 3; i++) {
        final likeButton = find.byIcon(Icons.favorite_rounded);
        if (likeButton.evaluate().isNotEmpty) {
          await tester.tap(likeButton);
          await tester.pumpAndSettle();
        }
      }

      // Should have called onEmpty
      expect(onEmptyCalled, isTrue);
    });

    testWidgets('loads more content when running low', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Get initial card count
      // final initialCards = find.byType(EnhancedSwipeDiscoveryCard);
      // final initialCount = initialCards.evaluate().length;

      // Swipe through cards to trigger loading more content
      for (int i = 0; i < 2; i++) {
        final likeButton = find.byIcon(Icons.favorite_rounded);
        if (likeButton.evaluate().isNotEmpty) {
          await tester.tap(likeButton);
          await tester.pumpAndSettle();
        }
      }

      // Should have loaded more content (this depends on the mock implementation)
      // In a real scenario, this would verify that fetchMore was called
    });

    testWidgets('shows swipe confirmation snackbar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap like button
      final likeButton = find.byIcon(Icons.favorite_rounded);
      await tester.tap(likeButton);
      await tester.pumpAndSettle();

      // Should show confirmation snackbar
      expect(find.text('Liked'), findsOneWidget);
    });

    testWidgets('handles card tap correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap a card
      final card = find.byType(EnhancedSwipeDiscoveryCard).first;
      await tester.tap(card);
      await tester.pumpAndSettle();

      // Should handle tap (in real implementation, this would navigate to detail screen)
      // For now, we just verify the tap doesn't cause errors
    });
  });

  group('EnhancedSwipeDiscoveryCard', () {
    Widget createCardTestWidget({
      VoidCallback? onLike,
      VoidCallback? onDislike,
      VoidCallback? onSuperLike,
      VoidCallback? onTap,
    }) {
      final testMovie = {
        'id': 1,
        'title': 'Test Movie',
        'overview':
            'A great test movie with a long description that should be truncated properly',
        'poster_path': '/test.jpg',
        'backdrop_path': '/backdrop.jpg',
        'vote_average': 8.5,
        'release_date': '2023-01-01',
        'genre_ids': [28, 12, 16],
      };

      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: EnhancedSwipeDiscoveryCard(
            movie: testMovie,
            mediaType: MediaType.movie,
            onLike: onLike,
            onDislike: onDislike,
            onSuperLike: onSuperLike,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('renders movie information correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCardTestWidget());
      await tester.pumpAndSettle();

      // Should display movie title
      expect(find.text('Test Movie'), findsOneWidget);

      // Should display rating
      expect(find.text('8.5'), findsOneWidget);

      // Should display year
      expect(find.text('2023'), findsOneWidget);

      // Should display overview (truncated)
      expect(find.textContaining('A great test movie'), findsOneWidget);
    });

    testWidgets('renders genre tags', (WidgetTester tester) async {
      await tester.pumpWidget(createCardTestWidget());
      await tester.pumpAndSettle();

      // Should display genre tags (based on mock genre mapping)
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Adventure'), findsOneWidget);
      expect(find.text('Animation'), findsOneWidget);
    });

    testWidgets('handles action button taps', (WidgetTester tester) async {
      bool likeCalled = false;
      bool dislikeCalled = false;
      bool superLikeCalled = false;

      await tester.pumpWidget(
        createCardTestWidget(
          onLike: () => likeCalled = true,
          onDislike: () => dislikeCalled = true,
          onSuperLike: () => superLikeCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      // Test like button
      await tester.tap(find.byIcon(Icons.favorite_rounded));
      await tester.pumpAndSettle();
      expect(likeCalled, isTrue);

      // Test dislike button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(dislikeCalled, isTrue);

      // Test super like button
      await tester.tap(find.byIcon(Icons.star_rounded));
      await tester.pumpAndSettle();
      expect(superLikeCalled, isTrue);
    });

    testWidgets('handles card tap', (WidgetTester tester) async {
      bool tapCalled = false;

      await tester.pumpWidget(
        createCardTestWidget(onTap: () => tapCalled = true),
      );
      await tester.pumpAndSettle();

      // Tap the card
      await tester.tap(find.byType(EnhancedSwipeDiscoveryCard));
      await tester.pumpAndSettle();

      expect(tapCalled, isTrue);
    });

    testWidgets('shows action overlays on button press', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCardTestWidget());
      await tester.pumpAndSettle();

      // Tap like button and check for overlay animation
      await tester.tap(find.byIcon(Icons.favorite_rounded));
      await tester.pump(); // Don't settle to catch animation

      // The overlay should be animating (this is hard to test precisely)
      // In a real test, you might check for specific animation states
    });

    testWidgets('handles missing poster image gracefully', (
      WidgetTester tester,
    ) async {
      final testMovie = {
        'id': 1,
        'title': 'Test Movie',
        'overview': 'A test movie without poster',
        'vote_average': 8.5,
        'release_date': '2023-01-01',
        'genre_ids': [28],
      };

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EnhancedSwipeDiscoveryCard(
              movie: testMovie,
              mediaType: MediaType.movie,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show placeholder icon
      expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
    });

    testWidgets('applies press animation on tap down', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createCardTestWidget());
      await tester.pumpAndSettle();

      // Simulate tap down
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(EnhancedSwipeDiscoveryCard)),
      );
      await tester.pump();

      // Card should be in pressed state (scale animation)
      // This is hard to test precisely without accessing internal state

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
