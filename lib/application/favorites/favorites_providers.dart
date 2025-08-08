import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock provider for favorite movies
final favoritesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // This would typically fetch from a repository
  return [];
});

/// Provider for favorites details (with full movie information)
final favoritesDetailsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // This would typically fetch detailed movie information
  return [];
});

/// Filter options for favorites
enum FavoritesFilter { all, movies, tvShows }

/// Provider for favorites filter state
final favoritesFilterNotifierProvider =
    StateNotifierProvider<FavoritesFilterNotifier, FavoritesFilter>((ref) {
      return FavoritesFilterNotifier();
    });

/// Notifier for managing favorites filter state
class FavoritesFilterNotifier extends StateNotifier<FavoritesFilter> {
  FavoritesFilterNotifier() : super(FavoritesFilter.all);

  void setFilter(FavoritesFilter filter) {
    state = filter;
  }
}
