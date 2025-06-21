import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/persistence_service.dart';
import '../../data/tmdb/tmdb_repository.dart';
import '../home/home_providers.dart';

part 'discover_providers.g.dart';

@riverpod
class DiscoverDeck extends _$DiscoverDeck {
  int _page = 1;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    _page = 1;
    final repo = ref.read(tmdbRepositoryProvider);
    return repo.getDiscoverDeck(page: _page);
  }

  // This method simply removes the card from the current UI state.
  // It's called after a swipe in any direction.
  void cardSwiped(Map<String, dynamic> media) {
    state = AsyncData(state.value!..removeWhere((m) => m['id'] == media['id']));
    _fetchMoreIfneeded();
  }

  void undoSwipe(Map<String, dynamic> movie, int index) {
    final currentList = [...?state.value];
    currentList.insert(index, movie);
    state = AsyncData(currentList);
  }

  // Helper to fetch more cards when the deck runs low
  Future<void> _fetchMoreIfneeded() async {
    if (state.value != null && state.value!.length < 5) {
      _page++;
      final repo = ref.read(tmdbRepositoryProvider);
      final newItems = await repo.getDiscoverDeck(page: _page);
      // Add the new items to the existing list
      state = AsyncData(state.value!..addAll(newItems));
    }
  }
}

@riverpod
TmdbRepository tmdbRepository(Ref ref) {
  return TmdbRepository();
}

// --- PROVIDER FOR THE MAIN DISCOVER SCREEN FEED ---
// This one automatically reacts to the movie/tv toggle
@riverpod
Future<List<Map<String, dynamic>>> discoverGenres(Ref ref) {
  final mediaType = ref.watch(mediaTypeNotifierProvider);
  final repository = ref.watch(tmdbRepositoryProvider);
  return repository.getGenres(mediaType);
}

// --- PROVIDER FOR THE FILTER BOTTOM SHEET ---
// We keep this one exactly as it was. The filter sheet will pass it the
// mediaType it needs when it calls it. This is correct.
@riverpod
Future<List<Map<String, dynamic>>> genreList(Ref ref, MediaType mediaType) {
  final repository = ref.watch(tmdbRepositoryProvider);
  return repository.getGenres(mediaType);
}
// ---------------------------------------------

@riverpod
Future<List<Map<String, dynamic>>> popularPeople(Ref ref) {
  final repository = ref.watch(tmdbRepositoryProvider);
  return repository.getPopularPeople();
}

// --- Keep the existing providers below ---
@riverpod
class SearchQueryNotifier extends _$SearchQueryNotifier {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

@riverpod
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
