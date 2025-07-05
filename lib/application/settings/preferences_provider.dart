// lib/application/settings/preferences_provider.dart
import 'package:flutter/material.dart';
import 'package:plot_twist/application/discover/discover_providers.dart';
import 'package:plot_twist/data/firestore/firestore_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preferences_provider.g.dart';

// --- A NEW PROVIDER TO FETCH STREAMING SERVICES ---
@riverpod
Future<List<Map<String, dynamic>>> watchProviders(WatchProvidersRef ref) {
  final region = ref.watch(
    preferencesNotifierProvider.select((p) => p.value?.contentRegion ?? 'US'),
  );
  return ref
      .watch(tmdbRepositoryProvider)
      .getWatchProviders(watchRegion: region);
}

// --- THE UPGRADED STATE AND NOTIFIER ---

@immutable
class PreferencesState {
  final List<int> favoriteGenres;
  final bool includeAdultContent;
  final String contentRegion;
  // New properties
  final List<int> watchProviders;
  final bool hideWatched;

  const PreferencesState({
    this.favoriteGenres = const [],
    this.includeAdultContent = false,
    this.contentRegion = 'US',
    this.watchProviders = const [],
    this.hideWatched = false,
  });

  PreferencesState copyWith({
    List<int>? favoriteGenres,
    bool? includeAdultContent,
    String? contentRegion,
    List<int>? watchProviders,
    bool? hideWatched,
  }) {
    return PreferencesState(
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      includeAdultContent: includeAdultContent ?? this.includeAdultContent,
      contentRegion: contentRegion ?? this.contentRegion,
      watchProviders: watchProviders ?? this.watchProviders,
      hideWatched: hideWatched ?? this.hideWatched,
    );
  }
}

@riverpod
class PreferencesNotifier extends _$PreferencesNotifier {
  final _service = FirestoreService();

  @override
  Stream<PreferencesState> build() {
    return _service.getPreferencesStream().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        return PreferencesState(
          favoriteGenres: List<int>.from(data['favoriteGenres'] ?? []),
          includeAdultContent: data['includeAdultContent'] ?? false,
          contentRegion: data['contentRegion'] ?? 'US',
          watchProviders: List<int>.from(data['watchProviders'] ?? []),
          hideWatched: data['hideWatched'] ?? false,
        );
      }
      return const PreferencesState();
    });
  }

  Future<void> toggleFavoriteGenre(int genreId) async {
    // Get the current list from the state safely
    final currentGenres = List<int>.from(state.value?.favoriteGenres ?? []);

    if (currentGenres.contains(genreId)) {
      currentGenres.remove(genreId);
    } else {
      currentGenres.add(genreId);
    }
    await _service.updatePreferences({'favoriteGenres': currentGenres});
  }

  Future<void> setIncludeAdultContent(bool isEnabled) async {
    await _service.updatePreferences({'includeAdultContent': isEnabled});
  }

  // New methods for new preferences
  Future<void> toggleWatchProvider(int providerId) async {
    final currentProviders = List<int>.from(
      state.asData?.value.watchProviders ?? [],
    );
    if (currentProviders.contains(providerId)) {
      currentProviders.remove(providerId);
    } else {
      currentProviders.add(providerId);
    }
    await _service.updatePreferences({'watchProviders': currentProviders});
  }

  Future<void> setHideWatched(bool isEnabled) async {
    await _service.updatePreferences({'hideWatched': isEnabled});
  }
}
