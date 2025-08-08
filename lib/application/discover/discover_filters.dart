import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/persistence_service.dart';

/// Advanced filtering and sorting options for content discovery
class DiscoverFilters {
  final MediaType mediaType;
  final List<int> selectedGenres;
  final DateRange? releaseDate;
  final RatingRange ratingRange;
  final RuntimeRange? runtime;
  final List<String> selectedLanguages;
  final List<String> selectedCountries;
  final SortOption sortBy;
  final SortOrder sortOrder;
  final bool includeAdult;
  final bool onlyWatchProviders;
  final List<String> selectedWatchProviders;
  final CertificationFilter? certification;
  final PopularityRange? popularityRange;
  final VoteCountRange? voteCountRange;

  const DiscoverFilters({
    this.mediaType = MediaType.movie,
    this.selectedGenres = const [],
    this.releaseDate,
    this.ratingRange = const RatingRange(min: 0.0, max: 10.0),
    this.runtime,
    this.selectedLanguages = const [],
    this.selectedCountries = const [],
    this.sortBy = SortOption.popularity,
    this.sortOrder = SortOrder.descending,
    this.includeAdult = false,
    this.onlyWatchProviders = false,
    this.selectedWatchProviders = const [],
    this.certification,
    this.popularityRange,
    this.voteCountRange,
  });

  DiscoverFilters copyWith({
    MediaType? mediaType,
    List<int>? selectedGenres,
    DateRange? releaseDate,
    RatingRange? ratingRange,
    RuntimeRange? runtime,
    List<String>? selectedLanguages,
    List<String>? selectedCountries,
    SortOption? sortBy,
    SortOrder? sortOrder,
    bool? includeAdult,
    bool? onlyWatchProviders,
    List<String>? selectedWatchProviders,
    CertificationFilter? certification,
    PopularityRange? popularityRange,
    VoteCountRange? voteCountRange,
  }) {
    return DiscoverFilters(
      mediaType: mediaType ?? this.mediaType,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      releaseDate: releaseDate ?? this.releaseDate,
      ratingRange: ratingRange ?? this.ratingRange,
      runtime: runtime ?? this.runtime,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      selectedCountries: selectedCountries ?? this.selectedCountries,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      includeAdult: includeAdult ?? this.includeAdult,
      onlyWatchProviders: onlyWatchProviders ?? this.onlyWatchProviders,
      selectedWatchProviders:
          selectedWatchProviders ?? this.selectedWatchProviders,
      certification: certification ?? this.certification,
      popularityRange: popularityRange ?? this.popularityRange,
      voteCountRange: voteCountRange ?? this.voteCountRange,
    );
  }

  /// Reset all filters to default values
  DiscoverFilters reset() {
    return DiscoverFilters(mediaType: mediaType);
  }

  /// Check if any filters are active (non-default)
  bool get hasActiveFilters {
    return selectedGenres.isNotEmpty ||
        releaseDate != null ||
        ratingRange != const RatingRange(min: 0.0, max: 10.0) ||
        runtime != null ||
        selectedLanguages.isNotEmpty ||
        selectedCountries.isNotEmpty ||
        sortBy != SortOption.popularity ||
        sortOrder != SortOrder.descending ||
        includeAdult ||
        onlyWatchProviders ||
        selectedWatchProviders.isNotEmpty ||
        certification != null ||
        popularityRange != null ||
        voteCountRange != null;
  }

  /// Get active filter count for UI display
  int get activeFilterCount {
    int count = 0;
    if (selectedGenres.isNotEmpty) count++;
    if (releaseDate != null) count++;
    if (ratingRange != const RatingRange(min: 0.0, max: 10.0)) count++;
    if (runtime != null) count++;
    if (selectedLanguages.isNotEmpty) count++;
    if (selectedCountries.isNotEmpty) count++;
    if (sortBy != SortOption.popularity || sortOrder != SortOrder.descending)
      count++;
    if (includeAdult) count++;
    if (onlyWatchProviders) count++;
    if (selectedWatchProviders.isNotEmpty) count++;
    if (certification != null) count++;
    if (popularityRange != null) count++;
    if (voteCountRange != null) count++;
    return count;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoverFilters &&
        other.mediaType == mediaType &&
        listEquals(other.selectedGenres, selectedGenres) &&
        other.releaseDate == releaseDate &&
        other.ratingRange == ratingRange &&
        other.runtime == runtime &&
        listEquals(other.selectedLanguages, selectedLanguages) &&
        listEquals(other.selectedCountries, selectedCountries) &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder &&
        other.includeAdult == includeAdult &&
        other.onlyWatchProviders == onlyWatchProviders &&
        listEquals(other.selectedWatchProviders, selectedWatchProviders) &&
        other.certification == certification &&
        other.popularityRange == popularityRange &&
        other.voteCountRange == voteCountRange;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      mediaType,
      selectedGenres,
      releaseDate,
      ratingRange,
      runtime,
      selectedLanguages,
      selectedCountries,
      sortBy,
      sortOrder,
      includeAdult,
      onlyWatchProviders,
      selectedWatchProviders,
      certification,
      popularityRange,
      voteCountRange,
    ]);
  }
}

/// Date range filter
class DateRange {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRange({this.startDate, this.endDate});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate);
}

/// Rating range filter (0.0 - 10.0)
class RatingRange {
  final double min;
  final double max;

  const RatingRange({required this.min, required this.max});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatingRange && other.min == min && other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);
}

/// Runtime range filter (in minutes)
class RuntimeRange {
  final int min;
  final int max;

  const RuntimeRange({required this.min, required this.max});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RuntimeRange && other.min == min && other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);
}

/// Popularity range filter
class PopularityRange {
  final double min;
  final double max;

  const PopularityRange({required this.min, required this.max});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PopularityRange && other.min == min && other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);
}

/// Vote count range filter
class VoteCountRange {
  final int min;
  final int max;

  const VoteCountRange({required this.min, required this.max});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoteCountRange && other.min == min && other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);
}

/// Certification filter (age ratings)
class CertificationFilter {
  final List<String> selectedCertifications;

  const CertificationFilter({required this.selectedCertifications});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CertificationFilter &&
        listEquals(other.selectedCertifications, selectedCertifications);
  }

  @override
  int get hashCode => selectedCertifications.hashCode;
}

/// Sort options for content discovery
enum SortOption {
  popularity('Popularity'),
  releaseDate('Release Date'),
  rating('Rating'),
  title('Title'),
  runtime('Runtime'),
  voteCount('Vote Count'),
  revenue('Revenue'); // Movies only

  const SortOption(this.displayName);
  final String displayName;
}

/// Sort order
enum SortOrder {
  ascending('Ascending'),
  descending('Descending');

  const SortOrder(this.displayName);
  final String displayName;
}

/// Discover filters notifier
class DiscoverFiltersNotifier extends StateNotifier<DiscoverFilters> {
  DiscoverFiltersNotifier() : super(const DiscoverFilters());

  void updateMediaType(MediaType mediaType) {
    state = state.copyWith(mediaType: mediaType);
  }

  void updateGenres(List<int> genres) {
    state = state.copyWith(selectedGenres: genres);
  }

  void updateReleaseDate(DateRange? dateRange) {
    state = state.copyWith(releaseDate: dateRange);
  }

  void updateRatingRange(RatingRange ratingRange) {
    state = state.copyWith(ratingRange: ratingRange);
  }

  void updateRuntime(RuntimeRange? runtime) {
    state = state.copyWith(runtime: runtime);
  }

  void updateLanguages(List<String> languages) {
    state = state.copyWith(selectedLanguages: languages);
  }

  void updateCountries(List<String> countries) {
    state = state.copyWith(selectedCountries: countries);
  }

  void updateSorting(SortOption sortBy, SortOrder sortOrder) {
    state = state.copyWith(sortBy: sortBy, sortOrder: sortOrder);
  }

  void updateIncludeAdult(bool includeAdult) {
    state = state.copyWith(includeAdult: includeAdult);
  }

  void updateWatchProviders(List<String> providers, bool onlyWatchProviders) {
    state = state.copyWith(
      selectedWatchProviders: providers,
      onlyWatchProviders: onlyWatchProviders,
    );
  }

  void updateCertification(CertificationFilter? certification) {
    state = state.copyWith(certification: certification);
  }

  void updatePopularityRange(PopularityRange? popularityRange) {
    state = state.copyWith(popularityRange: popularityRange);
  }

  void updateVoteCountRange(VoteCountRange? voteCountRange) {
    state = state.copyWith(voteCountRange: voteCountRange);
  }

  void resetFilters() {
    state = state.reset();
  }

  void applyPreset(FilterPreset preset) {
    switch (preset) {
      case FilterPreset.popular:
        state = state.copyWith(
          sortBy: SortOption.popularity,
          sortOrder: SortOrder.descending,
          ratingRange: const RatingRange(min: 6.0, max: 10.0),
        );
        break;
      case FilterPreset.recent:
        final now = DateTime.now();
        final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
        state = state.copyWith(
          releaseDate: DateRange(startDate: oneYearAgo, endDate: now),
          sortBy: SortOption.releaseDate,
          sortOrder: SortOrder.descending,
        );
        break;
      case FilterPreset.topRated:
        state = state.copyWith(
          sortBy: SortOption.rating,
          sortOrder: SortOrder.descending,
          ratingRange: const RatingRange(min: 7.0, max: 10.0),
          voteCountRange: const VoteCountRange(min: 1000, max: 999999),
        );
        break;
      case FilterPreset.upcoming:
        final now = DateTime.now();
        final oneYearFromNow = DateTime(now.year + 1, now.month, now.day);
        state = state.copyWith(
          releaseDate: DateRange(startDate: now, endDate: oneYearFromNow),
          sortBy: SortOption.releaseDate,
          sortOrder: SortOrder.ascending,
        );
        break;
    }
  }
}

/// Filter presets for quick access
enum FilterPreset {
  popular('Popular'),
  recent('Recent'),
  topRated('Top Rated'),
  upcoming('Upcoming');

  const FilterPreset(this.displayName);
  final String displayName;
}

/// Provider for discover filters
final discoverFiltersProvider =
    StateNotifierProvider<DiscoverFiltersNotifier, DiscoverFilters>(
      (ref) => DiscoverFiltersNotifier(),
    );

/// Provider for available genres
final availableGenresProvider = FutureProvider.family<List<Genre>, MediaType>((
  ref,
  mediaType,
) async {
  // This would typically fetch from TMDB API
  // For now, return static data
  if (mediaType == MediaType.movie) {
    return _movieGenres;
  } else {
    return _tvGenres;
  }
});

/// Provider for available languages
final availableLanguagesProvider = FutureProvider<List<Language>>((ref) async {
  // This would typically fetch from TMDB API
  return _languages;
});

/// Provider for available countries
final availableCountriesProvider = FutureProvider<List<Country>>((ref) async {
  // This would typically fetch from TMDB API
  return _countries;
});

/// Provider for available watch providers
final availableWatchProvidersProvider = FutureProvider<List<WatchProvider>>((
  ref,
) async {
  // This would typically fetch from TMDB API
  return _watchProviders;
});

/// Genre model
class Genre {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});
}

/// Language model
class Language {
  final String code;
  final String name;
  final String englishName;

  const Language({
    required this.code,
    required this.name,
    required this.englishName,
  });
}

/// Country model
class Country {
  final String code;
  final String name;

  const Country({required this.code, required this.name});
}

/// Watch provider model
class WatchProvider {
  final int id;
  final String name;
  final String logoPath;

  const WatchProvider({
    required this.id,
    required this.name,
    required this.logoPath,
  });
}

// Static data for genres, languages, countries, and watch providers
const List<Genre> _movieGenres = [
  Genre(id: 28, name: 'Action'),
  Genre(id: 12, name: 'Adventure'),
  Genre(id: 16, name: 'Animation'),
  Genre(id: 35, name: 'Comedy'),
  Genre(id: 80, name: 'Crime'),
  Genre(id: 99, name: 'Documentary'),
  Genre(id: 18, name: 'Drama'),
  Genre(id: 10751, name: 'Family'),
  Genre(id: 14, name: 'Fantasy'),
  Genre(id: 36, name: 'History'),
  Genre(id: 27, name: 'Horror'),
  Genre(id: 10402, name: 'Music'),
  Genre(id: 9648, name: 'Mystery'),
  Genre(id: 10749, name: 'Romance'),
  Genre(id: 878, name: 'Science Fiction'),
  Genre(id: 10770, name: 'TV Movie'),
  Genre(id: 53, name: 'Thriller'),
  Genre(id: 10752, name: 'War'),
  Genre(id: 37, name: 'Western'),
];

const List<Genre> _tvGenres = [
  Genre(id: 10759, name: 'Action & Adventure'),
  Genre(id: 16, name: 'Animation'),
  Genre(id: 35, name: 'Comedy'),
  Genre(id: 80, name: 'Crime'),
  Genre(id: 99, name: 'Documentary'),
  Genre(id: 18, name: 'Drama'),
  Genre(id: 10751, name: 'Family'),
  Genre(id: 10762, name: 'Kids'),
  Genre(id: 9648, name: 'Mystery'),
  Genre(id: 10763, name: 'News'),
  Genre(id: 10764, name: 'Reality'),
  Genre(id: 10765, name: 'Sci-Fi & Fantasy'),
  Genre(id: 10766, name: 'Soap'),
  Genre(id: 10767, name: 'Talk'),
  Genre(id: 10768, name: 'War & Politics'),
  Genre(id: 37, name: 'Western'),
];

const List<Language> _languages = [
  Language(code: 'en', name: 'English', englishName: 'English'),
  Language(code: 'es', name: 'Español', englishName: 'Spanish'),
  Language(code: 'fr', name: 'Français', englishName: 'French'),
  Language(code: 'de', name: 'Deutsch', englishName: 'German'),
  Language(code: 'it', name: 'Italiano', englishName: 'Italian'),
  Language(code: 'ja', name: '日本語', englishName: 'Japanese'),
  Language(code: 'ko', name: '한국어', englishName: 'Korean'),
  Language(code: 'zh', name: '中文', englishName: 'Chinese'),
  Language(code: 'hi', name: 'हिन्दी', englishName: 'Hindi'),
  Language(code: 'ar', name: 'العربية', englishName: 'Arabic'),
];

const List<Country> _countries = [
  Country(code: 'US', name: 'United States'),
  Country(code: 'GB', name: 'United Kingdom'),
  Country(code: 'CA', name: 'Canada'),
  Country(code: 'AU', name: 'Australia'),
  Country(code: 'FR', name: 'France'),
  Country(code: 'DE', name: 'Germany'),
  Country(code: 'IT', name: 'Italy'),
  Country(code: 'ES', name: 'Spain'),
  Country(code: 'JP', name: 'Japan'),
  Country(code: 'KR', name: 'South Korea'),
  Country(code: 'IN', name: 'India'),
  Country(code: 'CN', name: 'China'),
];

const List<WatchProvider> _watchProviders = [
  WatchProvider(id: 8, name: 'Netflix', logoPath: '/netflix.jpg'),
  WatchProvider(id: 337, name: 'Disney Plus', logoPath: '/disney.jpg'),
  WatchProvider(id: 15, name: 'Hulu', logoPath: '/hulu.jpg'),
  WatchProvider(id: 9, name: 'Amazon Prime Video', logoPath: '/amazon.jpg'),
  WatchProvider(id: 384, name: 'HBO Max', logoPath: '/hbo.jpg'),
  WatchProvider(id: 350, name: 'Apple TV Plus', logoPath: '/apple.jpg'),
  WatchProvider(id: 531, name: 'Paramount Plus', logoPath: '/paramount.jpg'),
  WatchProvider(id: 387, name: 'Peacock', logoPath: '/peacock.jpg'),
];
