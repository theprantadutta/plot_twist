import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/application/recommendations/recommendation_providers.dart';
import 'package:plot_twist/application/home/home_providers.dart';
import 'package:plot_twist/data/local/persistence_service.dart';
import 'package:plot_twist/data/tmdb/tmdb_repository.dart';

// Mock classes for testing
class MockPersistenceService extends PersistenceService {
  List<int> _favoriteGenres = [28, 12, 16]; // Action, Adventure, Animation

  @override
  Future<void> init() async {}

  @override
  MediaType getMediaType() => MediaType.movie;

  @override
  Future<void> setMediaType(MediaType type) async {}

  @override
  List<int> getFavoriteGenres() => _favoriteGenres;

  @override
  Future<void> setFavoriteGenres(List<int> genreIds) async {
    _favoriteGenres = genreIds;
  }

  @override
  bool hasAcceptedTerms() => true;

  @override
  Future<void> setHasAcceptedTerms(bool hasAccepted) async {}
}

class MockTmdbRepository extends TmdbRepository {
  List<Map<String, dynamic>> _watchlist = [
    {
      'id': 1,
      'title': 'Test Movie 1',
      'media_type': 'movie',
      'genre_ids': [28, 12],
      'vote_average': 8.5,
      'popularity': 1000.0,
      'release_date': '2023-01-01',
    },
    {
      'id': 2,
      'name': 'Test TV Show 1',
      'media_type': 'tv',
      'genre_ids': [16, 35],
      'vote_average': 7.8,
      'popularity': 800.0,
      'first_air_date': '2023-02-01',
    },
  ];

  void setWatchlist(List<Map<String, dynamic>> watchlist) {
    _watchlist = watchlist;
  }

  @override
  Future<List<Map<String, dynamic>>> getWatchlist() async {
    return _watchlist;
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingMoviesWeek() async {
    return [
      {
        'id': 3,
        'title': 'Trending Movie 1',
        'genre_ids': [28],
        'vote_average': 7.5,
        'popularity': 1200.0,
        'release_date': '2023-03-01',
      },
      {
        'id': 4,
        'title': 'Trending Movie 2',
        'genre_ids': [12],
        'vote_average': 8.0,
        'popularity': 1100.0,
        'release_date': '2023-03-15',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingTvShowsWeek() async {
    return [
      {
        'id': 5,
        'name': 'Trending TV Show 1',
        'genre_ids': [16],
        'vote_average': 8.2,
        'popularity': 900.0,
        'first_air_date': '2023-04-01',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopRatedMovies() async {
    return [
      {
        'id': 6,
        'title': 'Top Rated Movie 1',
        'genre_ids': [28, 12],
        'vote_average': 9.0,
        'popularity': 500.0,
        'release_date': '2022-01-01',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getTopRatedTvShows() async {
    return [
      {
        'id': 7,
        'name': 'Top Rated TV Show 1',
        'genre_ids': [16],
        'vote_average': 9.2,
        'popularity': 600.0,
        'first_air_date': '2022-02-01',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getSimilarContent(
    int id,
    String mediaType,
  ) async {
    return [
      {
        'id': 8,
        'title': 'Similar Movie 1',
        'name': 'Similar TV Show 1',
        'genre_ids': [28],
        'vote_average': 7.0,
        'popularity': 700.0,
        'release_date': '2023-05-01',
        'first_air_date': '2023-05-01',
      },
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getDiscoverDeck({
    required MediaType type,
    int page = 1,
    List<int>? genreIds,
  }) async {
    if (genreIds != null && genreIds.isNotEmpty) {
      return [
        {
          'id': 9,
          'title': 'Genre Movie 1',
          'name': 'Genre TV Show 1',
          'genre_ids': genreIds,
          'vote_average': 7.8,
          'popularity': 850.0,
          'release_date': '2023-06-01',
          'first_air_date': '2023-06-01',
        },
      ];
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getGenres(MediaType mediaType) async {
    return [
      {'id': 28, 'name': 'Action'},
      {'id': 12, 'name': 'Adventure'},
      {'id': 16, 'name': 'Animation'},
      {'id': 35, 'name': 'Comedy'},
    ];
  }
}

class FailingMockTmdbRepository extends MockTmdbRepository {
  @override
  Future<List<Map<String, dynamic>>> getTrendingMoviesWeek() async {
    throw Exception('Network error');
  }

  @override
  Future<List<Map<String, dynamic>>> getWatchlist() async {
    throw Exception('Network error');
  }
}

void main() {
  group('RecommendationEngine', () {
    late ProviderContainer container;
    late MockPersistenceService mockPersistenceService;
    late MockTmdbRepository mockTmdbRepository;

    setUp(() {
      mockPersistenceService = MockPersistenceService();
      mockTmdbRepository = MockTmdbRepository();

      container = ProviderContainer(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
          tmdbRepositoryProvider.overrideWithValue(mockTmdbRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('generates personalized recommendations for movies', () async {
      final recommendations = await container.read(
        recommendationEngineProvider.future,
      );

      expect(recommendations, isNotEmpty);
      expect(recommendations.length, lessThanOrEqualTo(20));

      // Should contain recommendations with scores
      final firstRecommendation = recommendations.first;
      expect(
        firstRecommendation,
        containsPair('recommendation_score', isA<double>()),
      );
    });

    test('includes genre-based recommendations', () async {
      final recommendations = await container.read(
        recommendationEngineProvider.future,
      );

      // Should include content from favorite genres (28, 12, 16)
      final hasGenreMatch = recommendations.any((item) {
        final genres = (item['genre_ids'] as List<dynamic>?)?.cast<int>() ?? [];
        return genres.any((genre) => [28, 12, 16].contains(genre));
      });

      expect(hasGenreMatch, isTrue);
    });

    test('includes similar content based on watchlist', () async {
      final recommendations = await container.read(
        recommendationEngineProvider.future,
      );

      // Should include similar content (id: 8)
      final hasSimilarContent = recommendations.any((item) => item['id'] == 8);
      expect(hasSimilarContent, isTrue);
    });

    test('scores recommendations correctly', () async {
      final recommendations = await container.read(
        recommendationEngineProvider.future,
      );

      // Recommendations should be sorted by score (descending)
      for (int i = 0; i < recommendations.length - 1; i++) {
        final currentScore =
            recommendations[i]['recommendation_score'] as double;
        final nextScore =
            recommendations[i + 1]['recommendation_score'] as double;
        expect(currentScore, greaterThanOrEqualTo(nextScore));
      }
    });

    test('removes duplicate recommendations', () async {
      final recommendations = await container.read(
        recommendationEngineProvider.future,
      );

      final ids = recommendations.map((item) => item['id']).toList();
      final uniqueIds = ids.toSet();

      expect(ids.length, equals(uniqueIds.length));
    });

    test('handles empty watchlist gracefully', () async {
      // Override with empty watchlist
      final emptyTmdbRepository = MockTmdbRepository();
      emptyTmdbRepository.setWatchlist([]);

      final emptyContainer = ProviderContainer(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
          tmdbRepositoryProvider.overrideWithValue(emptyTmdbRepository),
        ],
      );

      final recommendations = await emptyContainer.read(
        recommendationEngineProvider.future,
      );

      expect(recommendations, isNotEmpty);
      emptyContainer.dispose();
    });

    test('refreshes recommendations correctly', () async {
      final engine = container.read(recommendationEngineProvider.notifier);

      // Get initial recommendations
      final initialRecommendations = await container.read(
        recommendationEngineProvider.future,
      );
      expect(initialRecommendations, isNotEmpty);

      // Refresh recommendations
      await engine.refreshRecommendations();

      // Should still have recommendations after refresh
      final refreshedRecommendations = await container.read(
        recommendationEngineProvider.future,
      );
      expect(refreshedRecommendations, isNotEmpty);
    });

    test('updates preferences and refreshes', () async {
      final engine = container.read(recommendationEngineProvider.notifier);

      // Update preferences with new favorite genres
      await engine.updatePreferences(favoriteGenres: [35, 18]); // Comedy, Drama

      // Should have updated the persistence service
      expect(mockPersistenceService.getFavoriteGenres(), equals([35, 18]));
    });
  });

  group('RecommendationCategories', () {
    late ProviderContainer container;
    late MockPersistenceService mockPersistenceService;
    late MockTmdbRepository mockTmdbRepository;

    setUp(() {
      mockPersistenceService = MockPersistenceService();
      mockTmdbRepository = MockTmdbRepository();

      container = ProviderContainer(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
          tmdbRepositoryProvider.overrideWithValue(mockTmdbRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('generates recommendation categories', () async {
      final categories = await container.read(
        recommendationCategoriesProvider.future,
      );

      expect(categories, isNotEmpty);
      expect(categories.containsKey('Trending Now'), isTrue);
      expect(categories.containsKey('Top Picks for You'), isTrue);
    });

    test(
      'includes "Because You Watched" category when watchlist exists',
      () async {
        final categories = await container.read(
          recommendationCategoriesProvider.future,
        );

        final becauseYouWatchedKey = categories.keys.firstWhere(
          (key) => key.startsWith('Because You Watched'),
          orElse: () => '',
        );

        expect(becauseYouWatchedKey, isNotEmpty);
      },
    );

    test('includes genre-based categories', () async {
      final categories = await container.read(
        recommendationCategoriesProvider.future,
      );

      final genreCategories = categories.keys.where(
        (key) => key.startsWith('More '),
      );

      expect(genreCategories, isNotEmpty);
    });

    test('handles errors gracefully', () async {
      // Override with failing repository
      final failingRepository = FailingMockTmdbRepository();

      final failingContainer = ProviderContainer(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
          tmdbRepositoryProvider.overrideWithValue(failingRepository),
        ],
      );

      final categories = await failingContainer.read(
        recommendationCategoriesProvider.future,
      );

      // Should still return some categories (fallback)
      expect(categories, isNotEmpty);
      failingContainer.dispose();
    });
  });

  group('UserViewingStats', () {
    late ProviderContainer container;
    late MockPersistenceService mockPersistenceService;
    late MockTmdbRepository mockTmdbRepository;

    setUp(() {
      mockPersistenceService = MockPersistenceService();
      mockTmdbRepository = MockTmdbRepository();

      container = ProviderContainer(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
          tmdbRepositoryProvider.overrideWithValue(mockTmdbRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('calculates viewing statistics correctly', () async {
      final stats = await container.read(userViewingStatsProvider.future);

      expect(stats['total_items'], equals(2));
      expect(stats['movie_count'], equals(1));
      expect(stats['tv_count'], equals(1));
      expect(stats['favorite_genres'], equals([28, 12, 16]));
      expect(stats['genre_distribution'], isA<Map<int, int>>());
      expect(stats['last_updated'], isA<String>());
    });

    test('calculates genre distribution correctly', () async {
      final stats = await container.read(userViewingStatsProvider.future);
      final genreDistribution = stats['genre_distribution'] as Map<int, int>;

      // Action (28) should appear in 1 movie
      expect(genreDistribution[28], equals(1));
      // Adventure (12) should appear in 1 movie
      expect(genreDistribution[12], equals(1));
      // Animation (16) should appear in 1 TV show
      expect(genreDistribution[16], equals(1));
      // Comedy (35) should appear in 1 TV show
      expect(genreDistribution[35], equals(1));
    });

    test('handles empty watchlist', () async {
      final emptyTmdbRepository = MockTmdbRepository();
      emptyTmdbRepository.setWatchlist([]);

      final emptyContainer = ProviderContainer(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
          tmdbRepositoryProvider.overrideWithValue(emptyTmdbRepository),
        ],
      );

      final stats = await emptyContainer.read(userViewingStatsProvider.future);

      expect(stats['total_items'], equals(0));
      expect(stats['movie_count'], equals(0));
      expect(stats['tv_count'], equals(0));

      emptyContainer.dispose();
    });

    test('handles errors gracefully', () async {
      final failingRepository = FailingMockTmdbRepository();

      final failingContainer = ProviderContainer(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
          tmdbRepositoryProvider.overrideWithValue(failingRepository),
        ],
      );

      final stats = await failingContainer.read(
        userViewingStatsProvider.future,
      );

      expect(stats['total_items'], equals(0));
      expect(stats['movie_count'], equals(0));
      expect(stats['tv_count'], equals(0));

      failingContainer.dispose();
    });
  });
}
