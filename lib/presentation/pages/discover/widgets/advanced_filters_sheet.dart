import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/discover/discover_filters.dart';
import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';

/// Advanced filters sheet with comprehensive filtering and sorting options
class AdvancedFiltersSheet extends ConsumerStatefulWidget {
  const AdvancedFiltersSheet({super.key});

  @override
  ConsumerState<AdvancedFiltersSheet> createState() =>
      _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends ConsumerState<AdvancedFiltersSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late DiscoverFilters _localFilters;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _localFilters = ref.read(discoverFiltersProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Tab Bar
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicFiltersTab(),
                _buildAdvancedFiltersTab(),
                _buildSortingTab(),
                _buildPresetsTab(),
              ],
            ),
          ),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkTextSecondary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, color: AppColors.cinematicGold, size: 24),
          const SizedBox(width: 12),
          Text(
            'Advanced Filters',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (_localFilters.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cinematicGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_localFilters.activeFilterCount}',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: AppColors.darkTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.cinematicGold,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.darkTextSecondary,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelMedium,
        tabs: const [
          Tab(text: 'Basic'),
          Tab(text: 'Advanced'),
          Tab(text: 'Sort'),
          Tab(text: 'Presets'),
        ],
      ),
    );
  }

  Widget _buildBasicFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Type
          _buildSectionTitle('Content Type'),
          _buildMediaTypeSelector(),
          const SizedBox(height: 24),

          // Genres
          _buildSectionTitle('Genres'),
          _buildGenreSelector(),
          const SizedBox(height: 24),

          // Rating Range
          _buildSectionTitle('Rating Range'),
          _buildRatingRangeSlider(),
        ],
      ),
    );
  }

  Widget _buildAdvancedFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Languages
          _buildSectionTitle('Languages'),
          _buildLanguageSelector(),
          const SizedBox(height: 24),

          // Countries
          _buildSectionTitle('Countries'),
          _buildCountrySelector(),
          const SizedBox(height: 24),

          // Adult Content
          _buildSectionTitle('Content Filters'),
          _buildAdultContentToggle(),
        ],
      ),
    );
  }

  Widget _buildSortingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Sort By'),
          _buildSortOptionSelector(),
          const SizedBox(height: 24),

          _buildSectionTitle('Sort Order'),
          _buildSortOrderSelector(),
        ],
      ),
    );
  }

  Widget _buildPresetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quick Filters'),
          const SizedBox(height: 16),
          ...FilterPreset.values.map((preset) => _buildPresetCard(preset)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMediaTypeSelector() {
    return Row(
      children: MediaType.values.map((type) {
        final isSelected = _localFilters.mediaType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () =>
                _updateLocalFilters(_localFilters.copyWith(mediaType: type)),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cinematicGold
                    : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.cinematicGold
                      : AppColors.darkTextSecondary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                type == MediaType.movie ? 'Movies' : 'TV Shows',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? Colors.black : AppColors.darkTextPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenreSelector() {
    final genresAsync = ref.watch(
      availableGenresProvider(_localFilters.mediaType),
    );

    return genresAsync.when(
      data: (genres) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: genres.map((genre) {
          final isSelected = _localFilters.selectedGenres.contains(genre.id);
          return FilterChip(
            label: Text(genre.name),
            selected: isSelected,
            onSelected: (selected) {
              final updatedGenres = List<int>.from(
                _localFilters.selectedGenres,
              );
              if (selected) {
                updatedGenres.add(genre.id);
              } else {
                updatedGenres.remove(genre.id);
              }
              _updateLocalFilters(
                _localFilters.copyWith(selectedGenres: updatedGenres),
              );
            },
            backgroundColor: AppColors.darkSurface,
            selectedColor: AppColors.cinematicGold,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.black : AppColors.darkTextPrimary,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.cinematicGold
                  : AppColors.darkTextSecondary.withValues(alpha: 0.2),
            ),
          );
        }).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading genres: $error'),
    );
  }

  Widget _buildRatingRangeSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _localFilters.ratingRange.min.toStringAsFixed(1),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            Text(
              _localFilters.ratingRange.max.toStringAsFixed(1),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(
            _localFilters.ratingRange.min,
            _localFilters.ratingRange.max,
          ),
          min: 0.0,
          max: 10.0,
          divisions: 20,
          activeColor: AppColors.cinematicGold,
          inactiveColor: AppColors.darkSurface,
          onChanged: (values) {
            _updateLocalFilters(
              _localFilters.copyWith(
                ratingRange: RatingRange(min: values.start, max: values.end),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    final languagesAsync = ref.watch(availableLanguagesProvider);

    return languagesAsync.when(
      data: (languages) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: languages.map((language) {
          final isSelected = _localFilters.selectedLanguages.contains(
            language.code,
          );
          return FilterChip(
            label: Text(language.englishName),
            selected: isSelected,
            onSelected: (selected) {
              final updatedLanguages = List<String>.from(
                _localFilters.selectedLanguages,
              );
              if (selected) {
                updatedLanguages.add(language.code);
              } else {
                updatedLanguages.remove(language.code);
              }
              _updateLocalFilters(
                _localFilters.copyWith(selectedLanguages: updatedLanguages),
              );
            },
            backgroundColor: AppColors.darkSurface,
            selectedColor: AppColors.cinematicGold,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.black : AppColors.darkTextPrimary,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.cinematicGold
                  : AppColors.darkTextSecondary.withValues(alpha: 0.2),
            ),
          );
        }).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading languages: $error'),
    );
  }

  Widget _buildCountrySelector() {
    final countriesAsync = ref.watch(availableCountriesProvider);

    return countriesAsync.when(
      data: (countries) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: countries.map((country) {
          final isSelected = _localFilters.selectedCountries.contains(
            country.code,
          );
          return FilterChip(
            label: Text(country.name),
            selected: isSelected,
            onSelected: (selected) {
              final updatedCountries = List<String>.from(
                _localFilters.selectedCountries,
              );
              if (selected) {
                updatedCountries.add(country.code);
              } else {
                updatedCountries.remove(country.code);
              }
              _updateLocalFilters(
                _localFilters.copyWith(selectedCountries: updatedCountries),
              );
            },
            backgroundColor: AppColors.darkSurface,
            selectedColor: AppColors.cinematicGold,
            labelStyle: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.black : AppColors.darkTextPrimary,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.cinematicGold
                  : AppColors.darkTextSecondary.withValues(alpha: 0.2),
            ),
          );
        }).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading countries: $error'),
    );
  }

  Widget _buildAdultContentToggle() {
    return SwitchListTile(
      title: Text(
        'Include adult content',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
      subtitle: Text(
        'Show content rated for mature audiences',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),
      value: _localFilters.includeAdult,
      onChanged: (value) =>
          _updateLocalFilters(_localFilters.copyWith(includeAdult: value)),
      activeColor: AppColors.cinematicGold,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSortOptionSelector() {
    return Column(
      children: SortOption.values.map((option) {
        // Filter out movie-only options for TV shows
        if (option == SortOption.revenue &&
            _localFilters.mediaType != MediaType.movie) {
          return const SizedBox.shrink();
        }

        return RadioListTile<SortOption>(
          title: Text(
            option.displayName,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          value: option,
          groupValue: _localFilters.sortBy,
          onChanged: (value) {
            if (value != null) {
              _updateLocalFilters(_localFilters.copyWith(sortBy: value));
            }
          },
          activeColor: AppColors.cinematicGold,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildSortOrderSelector() {
    return Column(
      children: SortOrder.values.map((order) {
        return RadioListTile<SortOrder>(
          title: Text(
            order.displayName,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          value: order,
          groupValue: _localFilters.sortOrder,
          onChanged: (value) {
            if (value != null) {
              _updateLocalFilters(_localFilters.copyWith(sortOrder: value));
            }
          },
          activeColor: AppColors.cinematicGold,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildPresetCard(FilterPreset preset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            ref.read(discoverFiltersProvider.notifier).applyPreset(preset);
            _localFilters = ref.read(discoverFiltersProvider);
            setState(() {});
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cinematicGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPresetIcon(preset),
                    color: AppColors.cinematicGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset.displayName,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.darkTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPresetDescription(preset),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.darkTextSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPresetIcon(FilterPreset preset) {
    switch (preset) {
      case FilterPreset.popular:
        return Icons.trending_up_rounded;
      case FilterPreset.recent:
        return Icons.schedule_rounded;
      case FilterPreset.topRated:
        return Icons.star_rounded;
      case FilterPreset.upcoming:
        return Icons.upcoming_rounded;
    }
  }

  String _getPresetDescription(FilterPreset preset) {
    switch (preset) {
      case FilterPreset.popular:
        return 'Most popular content with high ratings';
      case FilterPreset.recent:
        return 'Recently released content from the past year';
      case FilterPreset.topRated:
        return 'Highest rated content with many votes';
      case FilterPreset.upcoming:
        return 'Upcoming releases in the next year';
    }
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.darkTextSecondary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Reset Button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _localFilters = _localFilters.reset();
                setState(() {});
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.darkTextSecondary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Reset',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Apply Button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                ref.read(discoverFiltersProvider.notifier).state =
                    _localFilters;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinematicGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filters',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateLocalFilters(DiscoverFilters newFilters) {
    setState(() {
      _localFilters = newFilters;
    });
  }
}
