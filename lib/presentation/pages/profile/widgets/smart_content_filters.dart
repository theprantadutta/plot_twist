import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Smart content filtering system with advanced preferences
class SmartContentFilters extends ConsumerStatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const SmartContentFilters({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<SmartContentFilters> createState() =>
      _SmartContentFiltersState();
}

class _SmartContentFiltersState extends ConsumerState<SmartContentFilters>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _filterControllers;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic> _filters = {};
  bool _isExpanded = false;

  final List<Map<String, dynamic>> _filterCategories = [
    {
      'id': 'content_type',
      'name': 'Content Type',
      'icon': Icons.category_rounded,
      'options': [
        {'id': 'movies', 'name': 'Movies', 'icon': Icons.movie_rounded},
        {'id': 'tv_shows', 'name': 'TV Shows', 'icon': Icons.tv_rounded},
        {
          'id': 'documentaries',
          'name': 'Documentaries',
          'icon': Icons.article_rounded,
        },
        {'id': 'anime', 'name': 'Anime', 'icon': Icons.animation_rounded},
      ],
    },
    {
      'id': 'genres',
      'name': 'Genres',
      'icon': Icons.palette_rounded,
      'options': [
        {'id': 'action', 'name': 'Action', 'color': Colors.red},
        {'id': 'comedy', 'name': 'Comedy', 'color': Colors.orange},
        {'id': 'drama', 'name': 'Drama', 'color': Colors.blue},
        {'id': 'horror', 'name': 'Horror', 'color': Colors.purple},
        {'id': 'sci_fi', 'name': 'Sci-Fi', 'color': Colors.cyan},
        {'id': 'romance', 'name': 'Romance', 'color': Colors.pink},
        {'id': 'thriller', 'name': 'Thriller', 'color': Colors.indigo},
        {'id': 'fantasy', 'name': 'Fantasy', 'color': Colors.green},
      ],
    },
    {
      'id': 'ratings',
      'name': 'Ratings',
      'icon': Icons.star_rounded,
      'options': [
        {'id': 'g', 'name': 'G', 'description': 'General Audiences'},
        {'id': 'pg', 'name': 'PG', 'description': 'Parental Guidance'},
        {
          'id': 'pg13',
          'name': 'PG-13',
          'description': 'Parents Strongly Cautioned',
        },
        {'id': 'r', 'name': 'R', 'description': 'Restricted'},
        {'id': 'nc17', 'name': 'NC-17', 'description': 'Adults Only'},
      ],
    },
    {
      'id': 'release_period',
      'name': 'Release Period',
      'icon': Icons.calendar_today_rounded,
      'options': [
        {'id': '2020s', 'name': '2020s', 'range': '2020-2029'},
        {'id': '2010s', 'name': '2010s', 'range': '2010-2019'},
        {'id': '2000s', 'name': '2000s', 'range': '2000-2009'},
        {'id': '1990s', 'name': '1990s', 'range': '1990-1999'},
        {'id': 'classic', 'name': 'Classic', 'range': 'Before 1990'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    // Create controllers for each filter category
    _filterControllers = List.generate(
      _filterCategories.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 150)),
        vsync: this,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: MotionPresets.slideUp.curve,
          ),
        );
  }

  void _startAnimations() {
    _animationController.forward();

    // Start filter animations with staggered delays
    Future.delayed(const Duration(milliseconds: 200), () {
      for (int i = 0; i < _filterControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) {
            _filterControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _filterControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildQuickFilters(),
                  if (_isExpanded) ...[
                    const SizedBox(height: 24),
                    _buildAdvancedFilters(),
                  ],
                  const SizedBox(height: 20),
                  _buildFilterActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cinematicBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: AppColors.cinematicBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Filters',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Personalize your content discovery',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _toggleExpanded,
          icon: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.expand_more_rounded,
              color: AppColors.cinematicBlue,
            ),
          ),
          tooltip: _isExpanded ? 'Show Less' : 'Show More',
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    final activeFiltersCount = _getActiveFiltersCount();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Filters',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (activeFiltersCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cinematicPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$activeFiltersCount active',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.cinematicPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Content Type Quick Filters
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _filterCategories[0]['options'].map<Widget>((option) {
            final isSelected = _isOptionSelected('content_type', option['id']);

            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: GestureDetector(
                onTap: () => _toggleOption('content_type', option['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.cinematicBlue.withValues(alpha: 0.2)
                        : AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.cinematicBlue
                          : AppColors.darkTextTertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        option['icon'],
                        color: isSelected
                            ? AppColors.cinematicBlue
                            : AppColors.darkTextSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        option['name'],
                        style: AppTypography.labelLarge.copyWith(
                          color: isSelected
                              ? AppColors.cinematicBlue
                              : AppColors.darkTextSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Filters',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 20),

        // Filter Categories
        ...List.generate(_filterCategories.length, (index) {
          if (index == 0) {
            return const SizedBox.shrink(); // Skip content type (already shown)
          }

          final category = _filterCategories[index];
          return AnimatedBuilder(
            animation: _filterControllers[index],
            builder: (context, child) {
              return FadeTransition(
                opacity: _filterControllers[index],
                child: Column(
                  children: [
                    _buildFilterCategory(category),
                    if (index < _filterCategories.length - 1)
                      const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        }),

        const SizedBox(height: 24),

        // Rating Range Slider
        _buildRatingRangeSlider(),

        const SizedBox(height: 24),

        // Runtime Range Slider
        _buildRuntimeRangeSlider(),
      ],
    );
  }

  Widget _buildFilterCategory(Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category['icon'], color: AppColors.cinematicPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              category['name'],
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: category['options'].map<Widget>((option) {
            final isSelected = _isOptionSelected(category['id'], option['id']);

            return GestureDetector(
              onTap: () => _toggleOption(category['id'], option['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (option['color'] ?? AppColors.cinematicPurple)
                            .withValues(alpha: 0.2)
                      : AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? (option['color'] ?? AppColors.cinematicPurple)
                        : AppColors.darkTextTertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option['color'] != null)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: option['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (option['color'] != null) const SizedBox(width: 6),
                    Text(
                      option['name'],
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? (option['color'] ?? AppColors.cinematicPurple)
                            : AppColors.darkTextSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    if (option['description'] != null && isSelected) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.info_outline_rounded,
                        size: 12,
                        color: option['color'] ?? AppColors.cinematicPurple,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingRangeSlider() {
    final ratingRange =
        _filters['rating_range'] as RangeValues? ??
        const RangeValues(0.0, 10.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_rounded, color: AppColors.cinematicGold, size: 20),
            const SizedBox(width: 8),
            Text(
              'Rating Range',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${ratingRange.start.toStringAsFixed(1)} - ${ratingRange.end.toStringAsFixed(1)}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.cinematicGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.cinematicGold,
            inactiveTrackColor: AppColors.darkTextTertiary.withValues(
              alpha: 0.3,
            ),
            thumbColor: AppColors.cinematicGold,
            overlayColor: AppColors.cinematicGold.withValues(alpha: 0.2),
            valueIndicatorColor: AppColors.cinematicGold,
            valueIndicatorTextStyle: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: RangeSlider(
            values: ratingRange,
            min: 0.0,
            max: 10.0,
            divisions: 20,
            labels: RangeLabels(
              ratingRange.start.toStringAsFixed(1),
              ratingRange.end.toStringAsFixed(1),
            ),
            onChanged: (values) {
              setState(() {
                _filters['rating_range'] = values;
              });
              HapticFeedback.selectionClick();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRuntimeRangeSlider() {
    final runtimeRange =
        _filters['runtime_range'] as RangeValues? ??
        const RangeValues(0.0, 300.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: AppColors.cinematicBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Runtime (minutes)',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${runtimeRange.start.toInt()} - ${runtimeRange.end.toInt()} min',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.cinematicBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.cinematicBlue,
            inactiveTrackColor: AppColors.darkTextTertiary.withValues(
              alpha: 0.3,
            ),
            thumbColor: AppColors.cinematicBlue,
            overlayColor: AppColors.cinematicBlue.withValues(alpha: 0.2),
            valueIndicatorColor: AppColors.cinematicBlue,
            valueIndicatorTextStyle: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: RangeSlider(
            values: runtimeRange,
            min: 0.0,
            max: 300.0,
            divisions: 30,
            labels: RangeLabels(
              '${runtimeRange.start.toInt()}m',
              '${runtimeRange.end.toInt()}m',
            ),
            onChanged: (values) {
              setState(() {
                _filters['runtime_range'] = values;
              });
              HapticFeedback.selectionClick();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearAllFilters,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkTextSecondary,
              side: BorderSide(
                color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Clear All',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cinematicPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  bool _isOptionSelected(String categoryId, String optionId) {
    final categoryFilters = _filters[categoryId] as List<String>? ?? [];
    return categoryFilters.contains(optionId);
  }

  void _toggleOption(String categoryId, String optionId) {
    setState(() {
      final categoryFilters = _filters[categoryId] as List<String>? ?? [];
      if (categoryFilters.contains(optionId)) {
        categoryFilters.remove(optionId);
      } else {
        categoryFilters.add(optionId);
      }
      _filters[categoryId] = categoryFilters;
    });

    HapticFeedback.selectionClick();
  }

  int _getActiveFiltersCount() {
    int count = 0;
    for (final entry in _filters.entries) {
      if (entry.value is List && (entry.value as List).isNotEmpty) {
        count += (entry.value as List).length;
      } else if (entry.value is RangeValues) {
        final range = entry.value as RangeValues;
        if (entry.key == 'rating_range' &&
            (range.start != 0.0 || range.end != 10.0)) {
          count++;
        } else if (entry.key == 'runtime_range' &&
            (range.start != 0.0 || range.end != 300.0)) {
          count++;
        }
      }
    }
    return count;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    HapticFeedback.lightImpact();
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });

    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All filters cleared'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);

    HapticFeedback.lightImpact();

    final activeCount = _getActiveFiltersCount();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activeCount > 0 ? 'Applied $activeCount filters' : 'Filters applied',
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
