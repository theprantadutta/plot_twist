import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/persistence_service.dart';
import '../../data/tmdb/tmdb_repository.dart';
import '../home/home_providers.dart';

part 'discover_providers.g.dart';

@Riverpod(keepAlive: true)
class DiscoverDeck extends _$DiscoverDeck {
  int _page = 1;

  // The build method now depends on the mediaTypeNotifierProvider.
  // When the toggle changes, Riverpod will automatically re-run this method.
  @override
  Future<List<Map<String, dynamic>>> build() async {
    _page = 1;
    final repo = ref.read(tmdbRepositoryProvider);
    // Get the currently selected media type from the toggle
    final mediaType = ref.watch(mediaTypeNotifierProvider);
    // Fetch the correct type of deck
    return repo.getDiscoverDeck(type: mediaType, page: _page);
  }

  // This method simply removes the card from the current UI state.
  // It's called after a swipe in any direction.
  // void cardSwiped(Map<String, dynamic> media) {
  //   state = AsyncData(state.value!..removeWhere((m) => m['id'] == media['id']));
  //   fetchMore();
  // }
  void cardSwiped(Map<String, dynamic> media) {
    // This logic doesn't need to change
    final currentItems = state.value ?? [];
    currentItems.removeWhere((m) => m['id'] == media['id']);
    state = AsyncData([
      ...currentItems,
    ]); // Create a new list to notify listeners
    fetchMore();
    // Note: The proactive fetch logic is now handled in the UI
  }

  void undoSwipe(Map<String, dynamic> movie, int index) {
    final currentList = [...?state.value];
    currentList.insert(index, movie);
    state = AsyncData(currentList);
  }

  // and adds the new movies to the end of our existing list.
  Future<void> fetchMore() async {
    if (state is AsyncLoading) return;

    _page++;
    final repo = ref.read(tmdbRepositoryProvider);
    // Also use the mediaType when fetching more pages
    final mediaType = ref.read(mediaTypeNotifierProvider);
    final newItems = await repo.getDiscoverDeck(type: mediaType, page: _page);

    final currentItems = state.value ?? [];
    state = AsyncData([...currentItems, ...newItems]);
  }
}

@Riverpod(keepAlive: true)
TmdbRepository tmdbRepository(Ref ref) {
  return TmdbRepository();
}

// --- PROVIDER FOR THE MAIN DISCOVER SCREEN FEED ---
// This one automatically reacts to the movie/tv toggle
@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> discoverGenres(Ref ref) {
  final mediaType = ref.watch(mediaTypeNotifierProvider);
  final repository = ref.watch(tmdbRepositoryProvider);
  return repository.getGenres(mediaType);
}

// --- PROVIDER FOR THE FILTER BOTTOM SHEET ---
// We keep this one exactly as it was. The filter sheet will pass it the
// mediaType it needs when it calls it. This is correct.
@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> genreList(Ref ref, MediaType mediaType) {
  final repository = ref.watch(tmdbRepositoryProvider);
  return repository.getGenres(mediaType);
}
// ---------------------------------------------

@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> popularPeople(Ref ref) {
  final repository = ref.watch(tmdbRepositoryProvider);
  return repository.getPopularPeople();
}

// --- Keep the existing providers below ---
@Riverpod(keepAlive: true)
class SearchQueryNotifier extends _$SearchQueryNotifier {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

@Riverpod(keepAlive: true)
class DiscoverFiltersNotifier extends _$DiscoverFiltersNotifier {
  @override
  List<int> build() => [];

  void addGenre(int genreId) {
    if (!state.contains(genreId)) {
      state = [...state, genreId];
    }
  }

  void removeGenre(int genreId) {
    state = state.where((id) => id != genreId).toList();
  }

  void clearFilters() {
    state = [];
  }
}
