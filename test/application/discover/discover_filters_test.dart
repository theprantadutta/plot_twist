import 'package:flutter_test/flutter_test.dart';
import 'package:plot_twist/application/discover/discover_filters.dart';
import 'package:plot_twist/data/local/persistence_service.dart';

void main() {
  group('DiscoverFilters', () {
    test('should create default filters correctly', () {
      const filters = DiscoverFilters();

      expect(filters.mediaType, MediaType.movie);
      expect(filters.selectedGenres, isEmpty);
      expect(filters.releaseDate, isNull);
      expect(filters.ratingRange, const RatingRange(min: 0.0, max: 10.0));
      expect(filters.runtime, isNull);
      expect(filters.selectedLanguages, isEmpty);
      expect(filters.selectedCountries, isEmpty);
      expect(filters.sortBy, SortOption.popularity);
      expect(filters.sortOrder, SortOrder.descending);
      expect(filters.includeAdult, false);
      expect(filters.onlyWatchProviders, false);
      expect(filters.selectedWatchProviders, isEmpty);
      expect(filters.certification, isNull);
      expect(filters.popularityRange, isNull);
      expect(filters.voteCountRange, isNull);
    });

    test('should detect active filters correctly', () {
      const defaultFilters = DiscoverFilters();
      expect(defaultFilters.hasActiveFilters, false);
      expect(defaultFilters.activeFilterCount, 0);

      final filtersWithGenres = defaultFilters.copyWith(
        selectedGenres: [28, 35], // Action, Comedy
      );
      expect(filtersWithGenres.hasActiveFilters, true);
      expect(filtersWithGenres.activeFilterCount, 1);

      final filtersWithMultiple = filtersWithGenres.copyWith(
        ratingRange: const RatingRange(min: 7.0, max: 10.0),
        includeAdult: true,
      );
      expect(filtersWithMultiple.hasActiveFilters, true);
      expect(filtersWithMultiple.activeFilterCount, 3);
    });

    test('should reset filters correctly', () {
      final filters = const DiscoverFilters().copyWith(
        selectedGenres: [28, 35],
        ratingRange: const RatingRange(min: 7.0, max: 10.0),
        includeAdult: true,
        sortBy: SortOption.rating,
      );

      expect(filters.hasActiveFilters, true);

      final resetFilters = filters.reset();
      expect(resetFilters.hasActiveFilters, false);
      expect(
        resetFilters.mediaType,
        filters.mediaType,
      ); // Should preserve media type
      expect(resetFilters.selectedGenres, isEmpty);
      expect(resetFilters.ratingRange, const RatingRange(min: 0.0, max: 10.0));
      expect(resetFilters.includeAdult, false);
      expect(resetFilters.sortBy, SortOption.popularity);
    });

    test('should copy with new values correctly', () {
      const originalFilters = DiscoverFilters();

      final updatedFilters = originalFilters.copyWith(
        mediaType: MediaType.tv,
        selectedGenres: [18, 35], // Drama, Comedy
        ratingRange: const RatingRange(min: 6.0, max: 9.0),
        includeAdult: true,
      );

      expect(updatedFilters.mediaType, MediaType.tv);
      expect(updatedFilters.selectedGenres, [18, 35]);
      expect(updatedFilters.ratingRange, const RatingRange(min: 6.0, max: 9.0));
      expect(updatedFilters.includeAdult, true);

      // Should preserve unchanged values
      expect(updatedFilters.selectedLanguages, isEmpty);
      expect(updatedFilters.sortBy, SortOption.popularity);
    });

    test('should handle equality correctly', () {
      const filters1 = DiscoverFilters(
        mediaType: MediaType.movie,
        selectedGenres: [28, 35],
        ratingRange: RatingRange(min: 7.0, max: 10.0),
      );

      const filters2 = DiscoverFilters(
        mediaType: MediaType.movie,
        selectedGenres: [28, 35],
        ratingRange: RatingRange(min: 7.0, max: 10.0),
      );

      const filters3 = DiscoverFilters(
        mediaType: MediaType.tv,
        selectedGenres: [28, 35],
        ratingRange: RatingRange(min: 7.0, max: 10.0),
      );

      expect(filters1, equals(filters2));
      expect(filters1, isNot(equals(filters3)));
      expect(filters1.hashCode, equals(filters2.hashCode));
      expect(filters1.hashCode, isNot(equals(filters3.hashCode)));
    });
  });

  group('DiscoverFiltersNotifier', () {
    late DiscoverFiltersNotifier notifier;

    setUp(() {
      notifier = DiscoverFiltersNotifier();
    });

    test('should initialize with default filters', () {
      expect(notifier.state, const DiscoverFilters());
    });

    test('should update media type', () {
      notifier.updateMediaType(MediaType.tv);
      expect(notifier.state.mediaType, MediaType.tv);
    });

    test('should update genres', () {
      const genres = [28, 35, 18]; // Action, Comedy, Drama
      notifier.updateGenres(genres);
      expect(notifier.state.selectedGenres, genres);
    });

    test('should update rating range', () {
      const ratingRange = RatingRange(min: 7.0, max: 9.5);
      notifier.updateRatingRange(ratingRange);
      expect(notifier.state.ratingRange, ratingRange);
    });

    test('should update release date', () {
      final dateRange = DateRange(
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 12, 31),
      );
      notifier.updateReleaseDate(dateRange);
      expect(notifier.state.releaseDate, dateRange);
    });

    test('should update runtime', () {
      const runtime = RuntimeRange(min: 90, max: 150);
      notifier.updateRuntime(runtime);
      expect(notifier.state.runtime, runtime);
    });

    test('should update languages', () {
      const languages = ['en', 'es', 'fr'];
      notifier.updateLanguages(languages);
      expect(notifier.state.selectedLanguages, languages);
    });

    test('should update countries', () {
      const countries = ['US', 'GB', 'FR'];
      notifier.updateCountries(countries);
      expect(notifier.state.selectedCountries, countries);
    });

    test('should update sorting', () {
      notifier.updateSorting(SortOption.rating, SortOrder.ascending);
      expect(notifier.state.sortBy, SortOption.rating);
      expect(notifier.state.sortOrder, SortOrder.ascending);
    });

    test('should update include adult', () {
      notifier.updateIncludeAdult(true);
      expect(notifier.state.includeAdult, true);
    });

    test('should update watch providers', () {
      const providers = ['Netflix', 'Disney Plus'];
      notifier.updateWatchProviders(providers, true);
      expect(notifier.state.selectedWatchProviders, providers);
      expect(notifier.state.onlyWatchProviders, true);
    });

    test('should reset filters', () {
      // Set some filters first
      notifier.updateGenres([28, 35]);
      notifier.updateIncludeAdult(true);
      notifier.updateSorting(SortOption.rating, SortOrder.ascending);

      expect(notifier.state.hasActiveFilters, true);

      // Reset
      notifier.resetFilters();
      expect(notifier.state.hasActiveFilters, false);
      expect(notifier.state.selectedGenres, isEmpty);
      expect(notifier.state.includeAdult, false);
      expect(notifier.state.sortBy, SortOption.popularity);
      expect(notifier.state.sortOrder, SortOrder.descending);
    });

    test('should apply popular preset correctly', () {
      notifier.applyPreset(FilterPreset.popular);

      expect(notifier.state.sortBy, SortOption.popularity);
      expect(notifier.state.sortOrder, SortOrder.descending);
      expect(
        notifier.state.ratingRange,
        const RatingRange(min: 6.0, max: 10.0),
      );
    });

    test('should apply recent preset correctly', () {
      notifier.applyPreset(FilterPreset.recent);

      expect(notifier.state.sortBy, SortOption.releaseDate);
      expect(notifier.state.sortOrder, SortOrder.descending);
      expect(notifier.state.releaseDate, isNotNull);

      final releaseDate = notifier.state.releaseDate!;
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      expect(releaseDate.startDate?.year, oneYearAgo.year);
      expect(releaseDate.endDate?.year, now.year);
    });

    test('should apply top rated preset correctly', () {
      notifier.applyPreset(FilterPreset.topRated);

      expect(notifier.state.sortBy, SortOption.rating);
      expect(notifier.state.sortOrder, SortOrder.descending);
      expect(
        notifier.state.ratingRange,
        const RatingRange(min: 7.0, max: 10.0),
      );
      expect(
        notifier.state.voteCountRange,
        const VoteCountRange(min: 1000, max: 999999),
      );
    });

    test('should apply upcoming preset correctly', () {
      notifier.applyPreset(FilterPreset.upcoming);

      expect(notifier.state.sortBy, SortOption.releaseDate);
      expect(notifier.state.sortOrder, SortOrder.ascending);
      expect(notifier.state.releaseDate, isNotNull);

      final releaseDate = notifier.state.releaseDate!;
      final now = DateTime.now();
      final oneYearFromNow = DateTime(now.year + 1, now.month, now.day);

      expect(releaseDate.startDate?.year, now.year);
      expect(releaseDate.endDate?.year, oneYearFromNow.year);
    });
  });

  group('Range Classes', () {
    test('DateRange equality', () {
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 12, 31);

      final range1 = DateRange(startDate: date1, endDate: date2);
      final range2 = DateRange(startDate: date1, endDate: date2);
      final range3 = DateRange(startDate: date1, endDate: null);

      expect(range1, equals(range2));
      expect(range1, isNot(equals(range3)));
      expect(range1.hashCode, equals(range2.hashCode));
    });

    test('RatingRange equality', () {
      const range1 = RatingRange(min: 7.0, max: 9.0);
      const range2 = RatingRange(min: 7.0, max: 9.0);
      const range3 = RatingRange(min: 6.0, max: 9.0);

      expect(range1, equals(range2));
      expect(range1, isNot(equals(range3)));
      expect(range1.hashCode, equals(range2.hashCode));
    });

    test('RuntimeRange equality', () {
      const range1 = RuntimeRange(min: 90, max: 150);
      const range2 = RuntimeRange(min: 90, max: 150);
      const range3 = RuntimeRange(min: 90, max: 180);

      expect(range1, equals(range2));
      expect(range1, isNot(equals(range3)));
      expect(range1.hashCode, equals(range2.hashCode));
    });

    test('PopularityRange equality', () {
      const range1 = PopularityRange(min: 50.0, max: 100.0);
      const range2 = PopularityRange(min: 50.0, max: 100.0);
      const range3 = PopularityRange(min: 0.0, max: 100.0);

      expect(range1, equals(range2));
      expect(range1, isNot(equals(range3)));
      expect(range1.hashCode, equals(range2.hashCode));
    });

    test('VoteCountRange equality', () {
      const range1 = VoteCountRange(min: 1000, max: 10000);
      const range2 = VoteCountRange(min: 1000, max: 10000);
      const range3 = VoteCountRange(min: 500, max: 10000);

      expect(range1, equals(range2));
      expect(range1, isNot(equals(range3)));
      expect(range1.hashCode, equals(range2.hashCode));
    });

    test('CertificationFilter equality', () {
      const filter1 = CertificationFilter(
        selectedCertifications: ['PG', 'PG-13'],
      );
      const filter2 = CertificationFilter(
        selectedCertifications: ['PG', 'PG-13'],
      );
      const filter3 = CertificationFilter(
        selectedCertifications: ['R', 'NC-17'],
      );

      expect(filter1, equals(filter2));
      expect(filter1, isNot(equals(filter3)));
      expect(filter1.hashCode, equals(filter2.hashCode));
    });
  });

  group('Static Data', () {
    test('should have movie genres', () {
      expect(_movieGenres.length, greaterThan(0));
      expect(_movieGenres.any((g) => g.name == 'Action'), true);
      expect(_movieGenres.any((g) => g.name == 'Comedy'), true);
      expect(_movieGenres.any((g) => g.name == 'Drama'), true);
    });

    test('should have TV genres', () {
      expect(_tvGenres.length, greaterThan(0));
      expect(_tvGenres.any((g) => g.name == 'Action & Adventure'), true);
      expect(_tvGenres.any((g) => g.name == 'Comedy'), true);
      expect(_tvGenres.any((g) => g.name == 'Drama'), true);
    });

    test('should have languages', () {
      expect(_languages.length, greaterThan(0));
      expect(_languages.any((l) => l.code == 'en'), true);
      expect(_languages.any((l) => l.code == 'es'), true);
      expect(_languages.any((l) => l.code == 'fr'), true);
    });

    test('should have countries', () {
      expect(_countries.length, greaterThan(0));
      expect(_countries.any((c) => c.code == 'US'), true);
      expect(_countries.any((c) => c.code == 'GB'), true);
      expect(_countries.any((c) => c.code == 'FR'), true);
    });

    test('should have watch providers', () {
      expect(_watchProviders.length, greaterThan(0));
      expect(_watchProviders.any((p) => p.name == 'Netflix'), true);
      expect(_watchProviders.any((p) => p.name == 'Disney Plus'), true);
      expect(_watchProviders.any((p) => p.name == 'Amazon Prime Video'), true);
    });
  });
}

// Reference to static data for testing
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
