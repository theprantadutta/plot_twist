import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/recommendations/recommendation_providers.dart';
import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';
import '../../../core/widgets/movie_poster_card.dart';

/// Enhanced personalized recommendations with visual emphasis and smooth transitions
class EnhancedPersonalizedRecommendations extends ConsumerStatefulWidget {
  final MediaType mediaType;
  final VoidCallback? onRefresh;

  const EnhancedPersonalizedRecommendations({
    super.key,
    required this.mediaType,
    this.onRefresh,
  });

  @override
  ConsumerState<EnhancedPersonalizedRecommendations> createState() =>
      _EnhancedPersonalizedRecommendationsState();
}

class _EnhancedPersonalizedRecommendationsState
    extends ConsumerState<EnhancedPersonalizedRecommendations>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: MotionPresets.slideUp.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: MotionPresets.slideUp.curve,
          ),
        );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(recommendationEngineProvider);
    final categoriesAsync = ref.watch(recommendationCategoriesProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainRecommendationsSection(recommendationsAsync),
              const SizedBox(height: 32),
              _buildCategorizedRecommendations(categoriesAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainRecommendationsSection(
    AsyncValue<List<Map<String, dynamic>>> recommendationsAsync,
  ) {
    return recommendationsAsync.when(
      data: (recommendations) => _buildMainRecommendations(recommendations),
      loading: () => _buildMainRecommendationsLoading(),
      error: (error, stack) => _buildMainRecommendationsError(),
    );
  }

  Widget _buildMainRecommendations(List<Map<String, dynamic>> recommendations) {
    if (recommendations.isEmpty) {
      return _buildEmptyRecommendations();
    }

    final topRecommendations = recommendations.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Recommended for You',
          subtitle: 'Based on your viewing preferences',
          icon: Icons.auto_awesome_rounded,
          onRefresh: () => _refreshRecommendations(),
        ),
        const SizedBox(height: 16),
        _buildRecommendationsList(topRecommendations),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onRefresh,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cinematicGold.withValues(alpha: 0.15),
            AppColors.cinematicRed.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cinematicGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cinematicGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.cinematicGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onRefresh != null)
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cinematicGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.cinematicGold,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(List<Map<String, dynamic>> recommendations) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final movie = recommendations[index];
          final score = movie['recommendation_score'] as double? ?? 0.0;
          final isHighlyRecommended = score > 7.0;

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: _buildRecommendationCard(movie, index, isHighlyRecommended),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(
    Map<String, dynamic> movie,
    int index,
    bool isHighlyRecommended,
  ) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Poster with Recommendation Badge
          Stack(
            children: [
              MoviePosterCard(
                movie: movie,
                animationDelay: Duration(milliseconds: index * 100),
              ),

              // Recommendation Score Badge
              if (isHighlyRecommended)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cinematicGold,
                          AppColors.cinematicGold.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cinematicGold.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.black,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'TOP',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Match Percentage (if available)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(movie['recommendation_score'] as double? ?? 0.0).toInt()}% match',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.cinematicGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Title with Visual Emphasis for Top Recommendations
          Text(
            movie['title'] ?? movie['name'] ?? 'Unknown',
            style: AppTypography.bodySmall.copyWith(
              color: isHighlyRecommended
                  ? AppColors.cinematicGold
                  : AppColors.darkTextPrimary,
              fontWeight: isHighlyRecommended
                  ? FontWeight.w600
                  : FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorizedRecommendations(
    AsyncValue<Map<String, List<Map<String, dynamic>>>> categoriesAsync,
  ) {
    return categoriesAsync.when(
      data: (categories) => _buildCategoryList(categories),
      loading: () => _buildCategoriesLoading(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoryList(
    Map<String, List<Map<String, dynamic>>> categories,
  ) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: categories.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: _buildCategorySection(entry.key, entry.value),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySection(String title, List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: MoviePosterCard(
                  movie: items[index],
                  animationDelay: Duration(milliseconds: index * 80),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainRecommendationsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 16),
        // List skeleton
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesLoading() {
    return Column(
      children: List.generate(2, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMainRecommendationsError() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkTextSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.darkTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to Load Recommendations',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your connection and try again',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshRecommendations(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cinematicGold,
              foregroundColor: Colors.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecommendations() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkTextSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 48,
            color: AppColors.darkTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Recommendations Yet',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start watching ${widget.mediaType == MediaType.movie ? 'movies' : 'shows'} to get personalized recommendations',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshRecommendations() async {
    // Trigger haptic feedback
    // HapticFeedback.lightImpact();

    // Animate refresh
    await _fadeController.reverse();

    // Refresh data
    ref.invalidate(recommendationEngineProvider);
    ref.invalidate(recommendationCategoriesProvider);

    // Animate back in
    await _fadeController.forward();

    // Call external refresh callback
    widget.onRefresh?.call();
  }
}
