import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/persistence_service.dart';
import '../home/home_providers.dart';

part 'preferences_provider.g.dart';

// A class to hold our preferences state
class PreferencesState {
  final DefaultView defaultView;
  final List<int> favoriteGenres;
  final bool includeAdultContent;
  final String contentRegion;

  PreferencesState({
    required this.defaultView,
    required this.favoriteGenres,
    required this.includeAdultContent,
    required this.contentRegion,
  });

  PreferencesState copyWith({
    DefaultView? defaultView,
    List<int>? favoriteGenres,
    bool? includeAdultContent,
    String? contentRegion,
  }) {
    return PreferencesState(
      defaultView: defaultView ?? this.defaultView,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      includeAdultContent: includeAdultContent ?? this.includeAdultContent,
      contentRegion: contentRegion ?? this.contentRegion,
    );
  }
}

// The Notifier that manages the state
@riverpod
class PreferencesNotifier extends _$PreferencesNotifier {
  late PersistenceService _persistenceService;

  @override
  PreferencesState build() {
    _persistenceService = ref.watch(persistenceServiceProvider);
    return PreferencesState(
      defaultView: _persistenceService.getDefaultView(),
      favoriteGenres: _persistenceService.getFavoriteGenres(),
      includeAdultContent: _persistenceService.getIncludeAdultContent(),
      contentRegion: _persistenceService.getContentRegion(),
    );
  }

  void setDefaultView(DefaultView view) {
    _persistenceService.setDefaultView(view);
    state = state.copyWith(defaultView: view);
  }

  void toggleFavoriteGenre(int genreId) {
    final currentGenres = List<int>.from(state.favoriteGenres);
    if (currentGenres.contains(genreId)) {
      currentGenres.remove(genreId);
    } else {
      currentGenres.add(genreId);
    }
    _persistenceService.setFavoriteGenres(currentGenres);
    state = state.copyWith(favoriteGenres: currentGenres);
  }

  void setIncludeAdultContent(bool isEnabled) {
    _persistenceService.setIncludeAdultContent(isEnabled);
    state = state.copyWith(includeAdultContent: isEnabled);
  }

  void setContentRegion(String region) {
    _persistenceService.setContentRegion(region);
    state = state.copyWith(contentRegion: region);
  }
}
