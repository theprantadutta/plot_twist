import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/app_colors.dart';

/// Cinematic skeleton loading screens that match the final content layout
class CinematicSkeletonLoaders extends StatelessWidget {
  const CinematicSkeletonLoaders({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 100), // Account for app bar
          // Hero Section Skeleton
          _buildHeroSkeleton(),

          const SizedBox(height: 32),

          // Recommendations Section Skeleton
          _buildRecommendationsSkeleton(),

          const SizedBox(height: 24),

          // Library Sections Skeleton
          _buildLibrarySectionSkeleton('Your Watchlist'),
          const SizedBox(height: 24),
          _buildLibrarySectionSkeleton('Trending This Week'),
          const SizedBox(height: 24),
          _buildLibrarySectionSkeleton('Top Rated Movies'),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildHeroSkeleton() {
    return Container(
          height: 400,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Background shimmer
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkSurface,
                        AppColors.darkSurface.withValues(alpha: 0.5),
                        AppColors.darkSurface,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Content overlay skeleton
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    Container(
                      width: 250,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description skeleton
                    Column(
                      children: List.generate(3, (index) {
                        return Container(
                          width: index == 2 ? 180 : double.infinity,
                          height: 16,
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Buttons skeleton
                    Row(
                      children: [
                        Container(
                          width: 140,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 120,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.1));
  }

  Widget _buildRecommendationsSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 1500.ms,
                color: Colors.white.withValues(alpha: 0.1),
              ),

          const SizedBox(height: 16),

          // Horizontal list skeleton
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
                          )
                          .animate(
                            delay: (index * 100).ms,
                            onPlay: (controller) => controller.repeat(),
                          )
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),

                      const SizedBox(height: 8),

                      Container(
                            width: 100,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                          .animate(
                            delay: (index * 100 + 50).ms,
                            onPlay: (controller) => controller.repeat(),
                          )
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withValues(alpha: 0.1),
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

  Widget _buildLibrarySectionSkeleton(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header skeleton
          Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 180,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 70,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 1500.ms,
                color: Colors.white.withValues(alpha: 0.1),
              ),

          const SizedBox(height: 16),

          // Horizontal movie list skeleton
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                            width: 120,
                            height: 160,
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )
                          .animate(
                            delay: (index * 80).ms,
                            onPlay: (controller) => controller.repeat(),
                          )
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),

                      const SizedBox(height: 8),

                      Container(
                            width: 90,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                          .animate(
                            delay: (index * 80 + 40).ms,
                            onPlay: (controller) => controller.repeat(),
                          )
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),

                      const SizedBox(height: 4),

                      Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                          .animate(
                            delay: (index * 80 + 80).ms,
                            onPlay: (controller) => controller.repeat(),
                          )
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withValues(alpha: 0.1),
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
}

/// Specialized skeleton for the hero spotlight section
class SpotlightSkeleton extends StatelessWidget {
  const SpotlightSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [AppColors.darkSurface, AppColors.darkBackground],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Content skeleton
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

              // Page indicators skeleton
              Positioned(
                bottom: 20,
                right: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.1));
  }
}
