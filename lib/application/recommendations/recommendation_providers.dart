import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/persistence_service.dart';
import '../../data/tmdb/tmdb_repository.dart';
import '../home/home_providers.dart';

part 'recommendation_providers.g.dart';

/// Recommendation engine that provides personalized content based on user preferences
@Riverpod(keepAlive: true)
class RecommendationEngine extends _$RecommendationEngine {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final mediaType = ref.watch(mediaTypeNotifierProvider);
    final repository = ref.watch(tmdbRepositoryProvider);

    return await _generatePersonalizedRecommendations(repository, mediaType);
  }

  /// Generate personalized recommendations based on user viewing history and preferences
  Future<List<Map<String, dynamic>>> _generatePersonalizedRecommendations(
    TmdbRepository repository,
    MediaType mediaType,
  ) async {
    try {
      // Get user's favorite genres from persistence
      final persistenceService = ref.read(persistenceServiceProvider);
      final favoriteGenres = persistenceService.getFavoriteGenres();

      // Get user's watchlist to understand preferences
      final watchlist = await repository.getWatchlist();

      // Generate recommendations based on multiple factors
      final recommendations = <Map<String, dynamic>>[];

      // 1. Genre-based recommendations (if user has favorite genres)
      if (favoriteGenres.isNotEmpty) {
        final genreRecommendations = await _getGenreBasedRecommendations(
          repository,
          mediaType,
          favoriteGenres,
        );
        recommendations.addAll(genreRecommendations);
      }

      // 2. Similar to watchlist items
      if (watchlist.isNotEmpty) {
        final similarRecommendations = await _getSimilarToWatchlist(
          repository,
          mediaType,
          watchlist,
        );
        recommendations.addAll(similarRecommendations);
      }

      // 3. Trending content as fallback
      final trendingContent = mediaType == MediaType.movie
          ? await repository.getTrendingMoviesWeek()
          : await repository.getTrendingTvShowsWeek();
      recommendations.addAll(trendingContent.take(5));

      // 4. Top rated content
      final topRatedContent = mediaType == MediaType.movie
          ? await repository.getTopRatedMovies()
          : await repository.getTopRatedTvShows();
      recommendations.addAll(topRatedContent.take(3));

      // Remove duplicates and limit results
      final uniqueRecommendations = _removeDuplicates(recommendations);

      // Score and sort recommendations
      final scoredRecommendations = _scoreRecommendations(
        uniqueRecommendations,
        favoriteGenres,
        watchlist,
      );

      return scoredRecommendations.take(20).toList();
    } catch (e) {
      // Fallback to trending content
      return mediaType == MediaType.movie
          ? await repository.getTrendingMoviesWeek()
          : await repository.getTrendingTvShowsWeek();
    }
  }

  /// Get recommendations based on user's favorite genres
  Future<List<Map<String, dynamic>>> _getGenreBasedRecommendations(
    TmdbRepository repository,
    MediaType mediaType,
    List<int> favoriteGenres,
  ) async {
    final recommendations = <Map<String, dynamic>>[];

    // Get discover content filtered by favorite genres
    for (final genreId in favoriteGenres.take(3)) {
      try {
        final genreContent = await repository.getDiscoverDeck(
          type: mediaType,
          page: 1,
          genreIds: [genreId],
        );
        recommendations.addAll(genreContent.take(5));
      } catch (e) {
        // Continue with other genres if one fails
        continue;
      }
    }

    return recommendations;
  }

  /// Get recommendations similar to items in user's watchlist
  Future<List<Map<String, dynamic>>> _getSimilarToWatchlist(
    TmdbRepository repository,
    MediaType mediaType,
    List<Map<String, dynamic>> watchlist,
  ) async {
    final recommendations = <Map<String, dynamic>>[];

    // Get similar content for top watchlist items
    final topWatchlistItems = watchlist.take(3);

    for (final item in topWatchlistItems) {
      try {
        final itemId = item['id'];
        final isMovie = item['media_type'] == 'movie' || item['title'] != null;

        // Only get similar content if media type matches
        if ((mediaType == MediaType.movie && isMovie) ||
            (mediaType == MediaType.tv && !isMovie)) {
          final similarContent = await repository.getSimilarContent(
            itemId,
            isMovie ? 'movie' : 'tv',
          );
          recommendations.addAll(similarContent.take(3));
        }
      } catch (e) {
        // Continue with other items if one fails
        continue;
      }
    }

    return recommendations;
  }

  /// Remove duplicate items from recommendations
  List<Map<String, dynamic>> _removeDuplicates(
    List<Map<String, dynamic>> recommendations,
  ) {
    final seen = <int>{};
    final unique = <Map<String, dynamic>>[];

    for (final item in recommendations) {
      final id = item['id'] as int?;
      if (id != null && !seen.contains(id)) {
        seen.add(id);
        unique.add(item);
      }
    }

    return unique;
  }

  /// Score recommendations based on user preferences
  List<Map<String, dynamic>> _scoreRecommendations(
    List<Map<String, dynamic>> recommendations,
    List<int> favoriteGenres,
    List<Map<String, dynamic>> watchlist,
  ) {
    final scoredItems = recommendations.map((item) {
      double score = 0.0;

      // Base score from vote average
      final voteAverage = (item['vote_average'] as num?)?.toDouble() ?? 0.0;
      score += voteAverage * 0.3;

      // Bonus for popularity
      final popularity = (item['popularity'] as num?)?.toDouble() ?? 0.0;
      score += (popularity / 1000) * 0.2; // Normalize popularity

      // Bonus for matching favorite genres
      final itemGenres =
          (item['genre_ids'] as List<dynamic>?)?.cast<int>() ?? [];
      final genreMatches = itemGenres.where(favoriteGenres.contains).length;
      score += genreMatches * 2.0;

      // Bonus for recent release
      final releaseDate = item['release_date'] ?? item['first_air_date'];
      if (releaseDate != null) {
        final release = DateTime.tryParse(releaseDate);
        if (release != null) {
          final daysSinceRelease = DateTime.now().difference(release).inDays;
          if (daysSinceRelease < 365) {
            score += 1.0; // Bonus for recent content
          }
        }
      }

      return {...item, 'recommendation_score': score};
    }).toList();

    // Sort by score descending
    scoredItems.sort((a, b) {
      final scoreA = a['recommendation_score'] as double;
      final scoreB = b['recommendation_score'] as double;
      return scoreB.compareTo(scoreA);
    });

    return scoredItems;
  }

  /// Refresh recommendations manually
  Future<void> refreshRecommendations() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final mediaType = ref.read(mediaTypeNotifierProvider);
      final repository = ref.read(tmdbRepositoryProvider);
      return await _generatePersonalizedRecommendations(repository, mediaType);
    });
  }

  /// Update user preferences and refresh recommendations
  Future<void> updatePreferences({
    List<int>? favoriteGenres,
    Map<String, dynamic>? likedContent,
  }) async {
    if (favoriteGenres != null) {
      final persistenceService = ref.read(persistenceServiceProvider);
      await persistenceService.setFavoriteGenres(favoriteGenres);
    }

    // Refresh recommendations with new preferences
    await refreshRecommendations();
  }
}

/// Provider for recommendation categories
@Riverpod(keepAlive: true)
Future<Map<String, List<Map<String, dynamic>>>> recommendationCategories(
  Ref ref,
) async {
  final mediaType = ref.watch(mediaTypeNotifierProvider);
  final repository = ref.watch(tmdbRepositoryProvider);
  final persistenceService = ref.read(persistenceServiceProvider);

  final categories = <String, List<Map<String, dynamic>>>{};

  try {
    // Get user's favorite genres
    final favoriteGenres = persistenceService.getFavoriteGenres();

    // Because You Watched (based on watchlist)
    final watchlist = await repository.getWatchlist();
    if (watchlist.isNotEmpty) {
      final filteredWatchlist = watchlist.where((item) {
        final isMovie = item['media_type'] == 'movie' || item['title'] != null;
        return mediaType == MediaType.movie ? isMovie : !isMovie;
      }).toList();

      if (filteredWatchlist.isNotEmpty) {
        final recentItem = filteredWatchlist.first;
        final itemId = recentItem['id'];
        final isMovie =
            recentItem['media_type'] == 'movie' || recentItem['title'] != null;

        try {
          final similar = await repository.getSimilarContent(
            itemId,
            isMovie ? 'movie' : 'tv',
          );
          categories['Because You Watched "${recentItem['title'] ?? recentItem['name']}"'] =
              similar.take(10).toList();
        } catch (e) {
          // Skip this category if it fails
        }
      }
    }

    // Genre-based categories
    if (favoriteGenres.isNotEmpty) {
      final genres = await repository.getGenres(mediaType);

      for (final genreId in favoriteGenres.take(2)) {
        final genre = genres.firstWhere(
          (g) => g['id'] == genreId,
          orElse: () => {'name': 'Unknown'},
        );

        try {
          final genreContent = await repository.getDiscoverDeck(
            type: mediaType,
            page: 1,
            genreIds: [genreId],
          );
          categories['More ${genre['name']}'] = genreContent.take(10).toList();
        } catch (e) {
          // Skip this category if it fails
        }
      }
    }

    // Trending Now
    final trending = mediaType == MediaType.movie
        ? await repository.getTrendingMoviesWeek()
        : await repository.getTrendingTvShowsWeek();
    categories['Trending Now'] = trending.take(10).toList();

    // Top Picks for You (high-rated recent content)
    final topRated = mediaType == MediaType.movie
        ? await repository.getTopRatedMovies()
        : await repository.getTopRatedTvShows();
    categories['Top Picks for You'] = topRated.take(10).toList();

    return categories;
  } catch (e) {
    // Fallback categories
    final trending = mediaType == MediaType.movie
        ? await repository.getTrendingMoviesWeek()
        : await repository.getTrendingTvShowsWeek();

    return {'Trending Now': trending.take(10).toList()};
  }
}

/// Provider for user viewing statistics
@Riverpod(keepAlive: true)
Future<Map<String, dynamic>> userViewingStats(Ref ref) async {
  final repository = ref.watch(tmdbRepositoryProvider);
  final persistenceService = ref.read(persistenceServiceProvider);

  try {
    final watchlist = await repository.getWatchlist();
    final favoriteGenres = persistenceService.getFavoriteGenres();

    // Calculate basic stats
    final movieCount = watchlist.where((item) {
      return item['media_type'] == 'movie' || item['title'] != null;
    }).length;

    final tvCount = watchlist.length - movieCount;

    // Get genre distribution
    final genreDistribution = <int, int>{};
    for (final item in watchlist) {
      final genres = (item['genre_ids'] as List<dynamic>?)?.cast<int>() ?? [];
      for (final genreId in genres) {
        genreDistribution[genreId] = (genreDistribution[genreId] ?? 0) + 1;
      }
    }

    return {
      'total_items': watchlist.length,
      'movie_count': movieCount,
      'tv_count': tvCount,
      'favorite_genres': favoriteGenres,
      'genre_distribution': genreDistribution,
      'last_updated': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    return {
      'total_items': 0,
      'movie_count': 0,
      'tv_count': 0,
      'favorite_genres': <int>[],
      'genre_distribution': <int, int>{},
      'last_updated': DateTime.now().toIso8601String(),
    };
  }
}

/// Provider for TMDB Repository
@Riverpod(keepAlive: true)
TmdbRepository tmdbRepository(Ref ref) {
  return TmdbRepository();
}
