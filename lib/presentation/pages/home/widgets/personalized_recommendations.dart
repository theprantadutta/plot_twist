import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/persistence_service.dart';
import '../../../../data/tmdb/tmdb_repository.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/widgets/movie_poster_card.dart';

/// Personalized content recommendations with visual emphasis
class PersonalizedRecommendations extends ConsumerWidget {
  final MediaType mediaType;

  const PersonalizedRecommendations({super.key, required this.mediaType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRecommendations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final recommendations = snapshot.data!.take(10).toList();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(),
              const SizedBox(height: 16),
              _buildRecommendationsList(recommendations),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getRecommendations() async {
    // For now, use popular content as recommendations
    // In a real app, this would be based on user viewing history and preferences
    final tmdbRepository = TmdbRepository();

    if (mediaType == MediaType.movie) {
      return await tmdbRepository.getTrendingMoviesWeek();
    } else {
      return await tmdbRepository.getTrendingTvShowsWeek();
    }
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cinematicGold.withValues(alpha: 0.1),
            AppColors.cinematicRed.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cinematicGold.withValues(alpha: 0.2),
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
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.cinematicGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended for You',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your viewing preferences',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.cinematicGold,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(List<Map<String, dynamic>> recommendations) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final movie = recommendations[index];
          final isHighlighted = index < 3; // Highlight first 3 recommendations

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie Poster with Highlight Effect
                Stack(
                  children: [
                    MoviePosterCard(movie: movie),
                    if (isHighlighted)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cinematicGold,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cinematicGold.withValues(
                                  alpha: 0.3,
                                ),
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
                  ],
                ),
                const SizedBox(height: 8),
                // Title with Highlight for Top Recommendations
                Text(
                  movie['title'] ?? movie['name'] ?? 'Unknown',
                  style: AppTypography.bodySmall.copyWith(
                    color: isHighlighted
                        ? AppColors.cinematicGold
                        : AppColors.darkTextPrimary,
                    fontWeight: isHighlighted
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Skeleton
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          // List Skeleton
          SizedBox(
            height: 220,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            'Start watching ${mediaType == MediaType.movie ? 'movies' : 'shows'} to get personalized recommendations',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
