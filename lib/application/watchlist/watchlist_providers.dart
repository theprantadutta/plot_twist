import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock provider for watchlist movies
final watchlistProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // This would typically fetch from a repository
  return [];
});

/// Provider for watchlist details (with full movie information)
final watchlistDetailsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // This would typically fetch detailed movie information
  return [];
});

/// Filter options for watchlist
enum WatchlistFilter { all, movies, tvShows }

/// Provider for watchlist filter state
final watchlistFilterNotifierProvider = NotifierProvider<WatchlistFilterNotifier, WatchlistFilter>(
  WatchlistFilterNotifier.new,
);

/// Notifier for managing watchlist filter state
class WatchlistFilterNotifier extends Notifier<WatchlistFilter> {
  @override
  WatchlistFilter build() => WatchlistFilter.all;

  void setFilter(WatchlistFilter filter) {
    state = filter;
  }
}

/// Provider for multi-select state in watchlist
final multiSelectNotifierProvider = NotifierProvider<MultiSelectNotifier, Set<String>>(
  MultiSelectNotifier.new,
);

/// Notifier for managing multi-select state
class MultiSelectNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggleSelection(String id) {
    if (state.contains(id)) {
      state = Set.from(state)..remove(id);
    } else {
      state = Set.from(state)..add(id);
    }
  }

  void clearSelection() {
    state = {};
  }

  void clear() {
    state = {};
  }

  void toggle(String id) {
    toggleSelection(id);
  }

  void selectAll(List<String> ids) {
    state = Set.from(ids);
  }
}
