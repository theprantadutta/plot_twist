import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/discover/discover_filters.dart';
import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import 'advanced_filters_sheet.dart';

/// Quick filter button that shows active filter count and opens advanced filters
class QuickFilterButton extends ConsumerWidget {
  const QuickFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(discoverFiltersProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAdvancedFilters(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: filters.hasActiveFilters
                ? AppColors.cinematicGold.withValues(alpha: 0.2)
                : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filters.hasActiveFilters
                  ? AppColors.cinematicGold
                  : AppColors.darkTextSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                color: filters.hasActiveFilters
                    ? AppColors.cinematicGold
                    : AppColors.darkTextSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: AppTypography.labelMedium.copyWith(
                  color: filters.hasActiveFilters
                      ? AppColors.cinematicGold
                      : AppColors.darkTextSecondary,
                  fontWeight: filters.hasActiveFilters
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
              if (filters.hasActiveFilters) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cinematicGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${filters.activeFilterCount}',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedFiltersSheet(),
    );
  }
}

/// Preset filter chips for quick access
class PresetFilterChips extends ConsumerWidget {
  const PresetFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: FilterPreset.values.map((preset) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(preset.displayName),
              onSelected: (selected) {
                if (selected) {
                  ref
                      .read(discoverFiltersProvider.notifier)
                      .applyPreset(preset);
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
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Sort options dropdown for quick sorting
class QuickSortDropdown extends ConsumerWidget {
  const QuickSortDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(discoverFiltersProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.darkTextSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: filters.sortBy,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.darkTextSecondary,
            size: 20,
          ),
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          dropdownColor: AppColors.darkSurface,
          items: SortOption.values
              .map((option) {
                // Filter out movie-only options for TV shows
                if (option == SortOption.revenue &&
                    filters.mediaType != MediaType.movie) {
                  return null;
                }

                return DropdownMenuItem<SortOption>(
                  value: option,
                  child: Text(
                    option.displayName,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                );
              })
              .where((item) => item != null)
              .cast<DropdownMenuItem<SortOption>>()
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(discoverFiltersProvider.notifier)
                  .updateSorting(value, filters.sortOrder);
            }
          },
        ),
      ),
    );
  }
}

/// Media type toggle for quick switching
class MediaTypeToggle extends ConsumerWidget {
  const MediaTypeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(discoverFiltersProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: MediaType.values.map((type) {
          final isSelected = filters.mediaType == type;
          return GestureDetector(
            onTap: () => ref
                .read(discoverFiltersProvider.notifier)
                .updateMediaType(type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cinematicGold
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                type == MediaType.movie ? 'Movies' : 'TV',
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.black : AppColors.darkTextPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Active filters display with clear options
class ActiveFiltersDisplay extends ConsumerWidget {
  const ActiveFiltersDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(discoverFiltersProvider);

    if (!filters.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Active Filters (${filters.activeFilterCount})',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    ref.read(discoverFiltersProvider.notifier).resetFilters(),
                child: Text(
                  'Clear All',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.cinematicGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _buildActiveFilterChips(filters, ref),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActiveFilterChips(DiscoverFilters filters, WidgetRef ref) {
    final chips = <Widget>[];

    // Genres
    if (filters.selectedGenres.isNotEmpty) {
      chips.add(
        _buildFilterChip(
          'Genres (${filters.selectedGenres.length})',
          () => ref.read(discoverFiltersProvider.notifier).updateGenres([]),
        ),
      );
    }

    // Rating
    if (filters.ratingRange != const RatingRange(min: 0.0, max: 10.0)) {
      chips.add(
        _buildFilterChip(
          'Rating ${filters.ratingRange.min.toStringAsFixed(1)}-${filters.ratingRange.max.toStringAsFixed(1)}',
          () => ref
              .read(discoverFiltersProvider.notifier)
              .updateRatingRange(const RatingRange(min: 0.0, max: 10.0)),
        ),
      );
    }

    // Release Date
    if (filters.releaseDate != null) {
      chips.add(
        _buildFilterChip(
          'Release Date',
          () => ref
              .read(discoverFiltersProvider.notifier)
              .updateReleaseDate(null),
        ),
      );
    }

    // Runtime
    if (filters.runtime != null) {
      chips.add(
        _buildFilterChip(
          'Runtime ${filters.runtime!.min}-${filters.runtime!.max}min',
          () => ref.read(discoverFiltersProvider.notifier).updateRuntime(null),
        ),
      );
    }

    // Languages
    if (filters.selectedLanguages.isNotEmpty) {
      chips.add(
        _buildFilterChip(
          'Languages (${filters.selectedLanguages.length})',
          () => ref.read(discoverFiltersProvider.notifier).updateLanguages([]),
        ),
      );
    }

    // Countries
    if (filters.selectedCountries.isNotEmpty) {
      chips.add(
        _buildFilterChip(
          'Countries (${filters.selectedCountries.length})',
          () => ref.read(discoverFiltersProvider.notifier).updateCountries([]),
        ),
      );
    }

    // Watch Providers
    if (filters.selectedWatchProviders.isNotEmpty) {
      chips.add(
        _buildFilterChip(
          'Streaming (${filters.selectedWatchProviders.length})',
          () => ref
              .read(discoverFiltersProvider.notifier)
              .updateWatchProviders([], false),
        ),
      );
    }

    // Adult Content
    if (filters.includeAdult) {
      chips.add(
        _buildFilterChip(
          'Adult Content',
          () => ref
              .read(discoverFiltersProvider.notifier)
              .updateIncludeAdult(false),
        ),
      );
    }

    // Sorting (if not default)
    if (filters.sortBy != SortOption.popularity ||
        filters.sortOrder != SortOrder.descending) {
      chips.add(
        _buildFilterChip(
          '${filters.sortBy.displayName} (${filters.sortOrder.displayName})',
          () => ref
              .read(discoverFiltersProvider.notifier)
              .updateSorting(SortOption.popularity, SortOrder.descending),
        ),
      );
    }

    return chips;
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cinematicGold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cinematicGold.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.cinematicGold,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.cinematicGold,
            ),
          ),
        ],
      ),
    );
  }
}
