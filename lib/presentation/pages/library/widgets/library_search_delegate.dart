import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/widgets/movie_poster_card.dart';
import '../../../../application/watchlist/watchlist_providers.dart';
import '../../../../application/favorites/favorites_providers.dart';
import '../../../../application/watched/watched_providers.dart';

/// Search delegate for library content with real-time filtering
class LibrarySearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final WidgetRef ref;

  LibrarySearchDelegate(this.ref);

  @override
  String get searchFieldLabel => 'Search your library...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        border: InputBorder.none,
      ),
      textTheme: Theme.of(context).textTheme.copyWith(
        titleLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: Icon(Icons.clear_rounded, color: AppColors.darkTextSecondary),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkTextPrimary),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return Container(
      color: AppColors.darkBackground,
      child: Consumer(
        builder: (context, ref, child) {
          final watchlistAsync = ref.watch(watchlistProvider);
          final favoritesAsync = ref.watch(favoritesProvider);
          final watchedAsync = ref.watch(watchedProvider);

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _combineAllMovies(
              watchlistAsync,
              favoritesAsync,
              watchedAsync,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }

              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }

              final allMovies = snapshot.data ?? [];
              final filteredMovies = _filterMovies(allMovies, query);

              if (filteredMovies.isEmpty) {
                return _buildEmptyState();
              }

              return _buildMovieGrid(filteredMovies);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    // This would typically come from a recent searches provider
    final recentSearches = <String>[
      'Action movies',
      'Marvel',
      'Christopher Nolan',
      'Comedy',
    ];

    return Container(
      color: AppColors.darkBackground,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...recentSearches.map(
            (search) => ListTile(
              leading: Icon(
                Icons.history_rounded,
                color: AppColors.darkTextSecondary,
              ),
              title: Text(
                search,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
              trailing: IconButton(
                onPressed: () {
                  // Remove from recent searches
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.darkTextSecondary,
                  size: 20,
                ),
              ),
              onTap: () {
                query = search;
                showResults(context);
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Filters',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickFilterChip(
                'Watchlist',
                Icons.bookmark_outline_rounded,
              ),
              _buildQuickFilterChip(
                'Favorites',
                Icons.favorite_outline_rounded,
              ),
              _buildQuickFilterChip(
                'Watched',
                Icons.check_circle_outline_rounded,
              ),
              _buildQuickFilterChip('High Rated', Icons.star_outline_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.darkTextPrimary),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          query = label.toLowerCase();
          // Apply specific filter logic here
        }
      },
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.cinematicGold,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      side: BorderSide(
        color: AppColors.darkTextSecondary.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildMovieGrid(List<Map<String, dynamic>> movies) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () => close(context, movie),
          child: Column(
            children: [
              Expanded(
                child: MoviePosterCard(
                  movie: movie,
                  animationDelay: Duration(milliseconds: index * 50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                movie['title'] ?? 'Unknown Title',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppColors.darkBackground,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      color: AppColors.darkBackground,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.cinematicRed,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Search Error',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppColors.darkBackground,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: AppColors.darkTextSecondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords\nor check your spelling',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinematicGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _combineAllMovies(
    AsyncValue<List<Map<String, dynamic>>> watchlistAsync,
    AsyncValue<List<Map<String, dynamic>>> favoritesAsync,
    AsyncValue<List<Map<String, dynamic>>> watchedAsync,
  ) async {
    final allMovies = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    // Add watchlist movies
    watchlistAsync.whenData((movies) {
      for (final movie in movies) {
        final id = movie['id']?.toString() ?? '';
        if (id.isNotEmpty && !seenIds.contains(id)) {
          allMovies.add({...movie, 'source': 'watchlist'});
          seenIds.add(id);
        }
      }
    });

    // Add favorites movies
    favoritesAsync.whenData((movies) {
      for (final movie in movies) {
        final id = movie['id']?.toString() ?? '';
        if (id.isNotEmpty && !seenIds.contains(id)) {
          allMovies.add({...movie, 'source': 'favorites'});
          seenIds.add(id);
        } else if (seenIds.contains(id)) {
          // Update existing movie to include favorite status
          final existingIndex = allMovies.indexWhere(
            (m) => m['id']?.toString() == id,
          );
          if (existingIndex != -1) {
            allMovies[existingIndex] = {
              ...allMovies[existingIndex],
              'is_favorite': true,
            };
          }
        }
      }
    });

    // Add watched movies
    watchedAsync.whenData((movies) {
      for (final movie in movies) {
        final id = movie['id']?.toString() ?? '';
        if (id.isNotEmpty && !seenIds.contains(id)) {
          allMovies.add({...movie, 'source': 'watched'});
          seenIds.add(id);
        } else if (seenIds.contains(id)) {
          // Update existing movie to include watched status
          final existingIndex = allMovies.indexWhere(
            (m) => m['id']?.toString() == id,
          );
          if (existingIndex != -1) {
            allMovies[existingIndex] = {
              ...allMovies[existingIndex],
              'is_watched': true,
            };
          }
        }
      }
    });

    return allMovies;
  }

  List<Map<String, dynamic>> _filterMovies(
    List<Map<String, dynamic>> movies,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return movies;

    final query = searchQuery.toLowerCase();
    return movies.where((movie) {
      final title = (movie['title'] ?? '').toString().toLowerCase();
      final overview = (movie['overview'] ?? '').toString().toLowerCase();
      final genres =
          (movie['genres'] as List<dynamic>?)
              ?.map((g) => g.toString().toLowerCase())
              .join(' ') ??
          '';
      final year = (movie['release_date'] ?? '').toString();

      return title.contains(query) ||
          overview.contains(query) ||
          genres.contains(query) ||
          year.contains(query);
    }).toList();
  }
}
