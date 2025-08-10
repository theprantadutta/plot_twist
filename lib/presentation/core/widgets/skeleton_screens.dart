import 'package:flutter/material.dart';

import 'skeleton_loading.dart';
import '../app_colors.dart';

/// Pre-built skeleton screens for major app components
class SkeletonScreens {
  /// Home screen skeleton
  static Widget homeScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading.text(width: 200, height: 24),
                  const SizedBox(height: 8),
                  SkeletonLoading.text(width: 150, height: 16),
                ],
              ),
            ),

            // Hero section
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: SkeletonLoading.heroCard(),
            ),

            const SizedBox(height: 32),

            // Continue watching section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading.text(width: 180, height: 20),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 140,
                          margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
                          child: SkeletonLoading.moviePoster(
                            width: 140,
                            height: 200,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Trending section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading.text(width: 120, height: 20),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 140,
                          margin: EdgeInsets.only(right: index < 4 ? 16 : 0),
                          child: SkeletonLoading.moviePoster(
                            width: 140,
                            height: 200,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Discover screen skeleton
  static Widget discoverScreen() {
    return SkeletonLoading.shimmer(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: SkeletonLoading.searchBar(),
          ),

          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SkeletonLoading.tabBar(tabCount: 4),
          ),

          const SizedBox(height: 20),

          // Grid content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return SkeletonLoading.gridItem();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Profile screen skeleton
  static Widget profileScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Column(
          children: [
            // Profile header
            SkeletonLoading.profileHeader(),

            const SizedBox(height: 20),

            // Stats cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: SkeletonLoading.statsCard()),
                  const SizedBox(width: 16),
                  Expanded(child: SkeletonLoading.statsCard()),
                  const SizedBox(width: 16),
                  Expanded(child: SkeletonLoading.statsCard()),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Recent activity section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading.text(width: 150, height: 20),
                  const SizedBox(height: 16),
                  ...List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: SkeletonLoading.listItem(),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Detail screen skeleton
  static Widget detailScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Container(
              height: 300,
              color: AppColors.darkBackground,
              child: Stack(
                children: [
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.darkBackground.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 250, height: 28),
                        const SizedBox(height: 8),
                        SkeletonLoading.text(width: 200, height: 16),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SkeletonLoading.ratingStars(),
                            const SizedBox(width: 16),
                            SkeletonLoading.text(width: 60, height: 14),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: SkeletonLoading.button(
                      width: double.infinity,
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SkeletonLoading.button(width: 48, height: 48),
                  const SizedBox(width: 12),
                  SkeletonLoading.button(width: 48, height: 48),
                ],
              ),
            ),

            // Overview section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading.text(width: 100, height: 20),
                  const SizedBox(height: 12),
                  SkeletonLoading.text(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  SkeletonLoading.text(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  SkeletonLoading.text(width: 200, height: 16),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Cast section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading.text(width: 80, height: 20),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          margin: EdgeInsets.only(right: index < 4 ? 16 : 0),
                          child: Column(
                            children: [
                              SkeletonLoading.avatar(size: 60),
                              const SizedBox(height: 8),
                              SkeletonLoading.text(width: 80, height: 14),
                              const SizedBox(height: 4),
                              SkeletonLoading.text(width: 60, height: 12),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Similar content section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading.text(width: 120, height: 20),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 140,
                          margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
                          child: SkeletonLoading.moviePoster(
                            width: 140,
                            height: 200,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Search screen skeleton
  static Widget searchScreen() {
    return SkeletonLoading.shimmer(
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: SkeletonLoading.searchBar(),
          ),

          // Recent searches
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoading.text(width: 140, height: 18),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(6, (index) {
                    return SkeletonLoading.button(
                      width: 80 + (index * 10).toDouble(),
                      height: 32,
                      borderRadius: BorderRadius.circular(16),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Search results
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoading.text(width: 100, height: 18),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: SkeletonLoading.listItem(
                            showAvatar: false,
                            showTrailing: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Library screen skeleton
  static Widget libraryScreen() {
    return SkeletonLoading.shimmer(
      child: Column(
        children: [
          // Header with tabs
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoading.text(width: 120, height: 24),
                const SizedBox(height: 16),
                SkeletonLoading.tabBar(tabCount: 3),
              ],
            ),
          ),

          // Filter and sort options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SkeletonLoading.button(width: 80, height: 36),
                const SizedBox(width: 12),
                SkeletonLoading.button(width: 100, height: 36),
                const Spacer(),
                SkeletonLoading.button(width: 40, height: 36),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Content grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return SkeletonLoading.gridItem();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Settings screen skeleton
  static Widget settingsScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              SkeletonLoading.listItem(height: 80),

              const SizedBox(height: 32),

              // Settings sections
              ...List.generate(4, (sectionIndex) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoading.text(width: 120, height: 18),
                    const SizedBox(height: 16),
                    ...List.generate(3, (itemIndex) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: SkeletonLoading.listItem(
                          height: 60,
                          showAvatar: false,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom list screen skeleton
  static Widget customListScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkBackground,
                    AppColors.darkSurface.withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SkeletonLoading.text(width: 200, height: 24),
                  const SizedBox(height: 8),
                  SkeletonLoading.text(width: 150, height: 16),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SkeletonLoading.button(width: 100, height: 36),
                      const SizedBox(width: 12),
                      SkeletonLoading.button(width: 80, height: 36),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonLoading.text(width: 100, height: 18),
                      SkeletonLoading.button(width: 40, height: 32),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return SkeletonLoading.gridItem();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
