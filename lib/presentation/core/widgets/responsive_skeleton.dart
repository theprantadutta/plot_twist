import 'package:flutter/material.dart';

import 'skeleton_loading.dart';
import 'skeleton_screens.dart';

/// Responsive skeleton layouts that adapt to different screen sizes
class ResponsiveSkeleton extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const ResponsiveSkeleton({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= mobileBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive skeleton screens for different device types
class ResponsiveSkeletonScreens {
  /// Responsive home screen skeleton
  static Widget homeScreen() {
    return ResponsiveSkeleton(
      mobile: SkeletonScreens.homeScreen(),
      tablet: _tabletHomeScreen(),
      desktop: _desktopHomeScreen(),
    );
  }

  /// Responsive discover screen skeleton
  static Widget discoverScreen() {
    return ResponsiveSkeleton(
      mobile: SkeletonScreens.discoverScreen(),
      tablet: _tabletDiscoverScreen(),
      desktop: _desktopDiscoverScreen(),
    );
  }

  /// Responsive profile screen skeleton
  static Widget profileScreen() {
    return ResponsiveSkeleton(
      mobile: SkeletonScreens.profileScreen(),
      tablet: _tabletProfileScreen(),
      desktop: _desktopProfileScreen(),
    );
  }

  /// Responsive detail screen skeleton
  static Widget detailScreen() {
    return ResponsiveSkeleton(
      mobile: SkeletonScreens.detailScreen(),
      tablet: _tabletDetailScreen(),
      desktop: _desktopDetailScreen(),
    );
  }

  /// Responsive library screen skeleton
  static Widget libraryScreen() {
    return ResponsiveSkeleton(
      mobile: SkeletonScreens.libraryScreen(),
      tablet: _tabletLibraryScreen(),
      desktop: _desktopLibraryScreen(),
    );
  }

  // Tablet layouts
  static Widget _tabletHomeScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 250, height: 28),
                        const SizedBox(height: 8),
                        SkeletonLoading.text(width: 180, height: 18),
                      ],
                    ),
                  ),
                  SkeletonLoading.button(width: 120, height: 40),
                ],
              ),

              const SizedBox(height: 32),

              // Hero section - wider for tablet
              SizedBox(height: 280, child: SkeletonLoading.heroCard()),

              const SizedBox(height: 40),

              // Content sections in rows
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Continue watching
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 180, height: 22),
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
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return SkeletonLoading.moviePoster(
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Trending
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 140, height: 22),
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
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return SkeletonLoading.moviePoster(
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _tabletDiscoverScreen() {
    return SkeletonLoading.shimmer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Search and filters row
            Row(
              children: [
                Expanded(flex: 2, child: SkeletonLoading.searchBar()),
                const SizedBox(width: 20),
                Expanded(child: SkeletonLoading.tabBar(tabCount: 3)),
              ],
            ),

            const SizedBox(height: 24),

            // Grid with more columns for tablet
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.7,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return SkeletonLoading.gridItem();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tabletProfileScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile header - horizontal layout
              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    SkeletonLoading.avatar(size: 120),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonLoading.text(width: 200, height: 28),
                          const SizedBox(height: 12),
                          SkeletonLoading.text(width: 150, height: 18),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SkeletonLoading.button(width: 120, height: 40),
                              const SizedBox(width: 16),
                              SkeletonLoading.button(width: 100, height: 40),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Stats cards - more columns
              Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
                      child: SkeletonLoading.statsCard(height: 120),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              // Content in two columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent activity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 180, height: 22),
                        const SizedBox(height: 20),
                        ...List.generate(5, (index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: SkeletonLoading.listItem(),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Achievements or other content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 160, height: 22),
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.0,
                              ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return SkeletonLoading.box(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: BorderRadius.circular(12),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _tabletDetailScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section - taller for tablet
            SizedBox(
              height: 400,
              child: Row(
                children: [
                  // Poster
                  Container(
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    child: SkeletonLoading.moviePoster(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonLoading.text(width: 300, height: 32),
                          const SizedBox(height: 12),
                          SkeletonLoading.text(width: 250, height: 18),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SkeletonLoading.ratingStars(starSize: 20),
                              const SizedBox(width: 20),
                              SkeletonLoading.text(width: 80, height: 16),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: SkeletonLoading.button(
                                  width: double.infinity,
                                  height: 48,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SkeletonLoading.button(width: 48, height: 48),
                              const SizedBox(width: 12),
                              SkeletonLoading.button(width: 48, height: 48),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content sections
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview
                  SkeletonLoading.text(width: 120, height: 24),
                  const SizedBox(height: 16),
                  SkeletonLoading.text(width: double.infinity, height: 18),
                  const SizedBox(height: 8),
                  SkeletonLoading.text(width: double.infinity, height: 18),
                  const SizedBox(height: 8),
                  SkeletonLoading.text(width: 400, height: 18),

                  const SizedBox(height: 40),

                  // Cast and similar content in row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cast
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLoading.text(width: 100, height: 22),
                            const SizedBox(height: 20),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: 6,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Expanded(
                                      child: SkeletonLoading.avatar(
                                        size: double.infinity,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SkeletonLoading.text(
                                      width: double.infinity,
                                      height: 14,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 40),

                      // Similar content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLoading.text(width: 140, height: 22),
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
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return SkeletonLoading.moviePoster(
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tabletLibraryScreen() {
    return SkeletonLoading.shimmer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header with tabs and controls
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading.text(width: 150, height: 28),
                      const SizedBox(height: 16),
                      SkeletonLoading.tabBar(tabCount: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Row(
                  children: [
                    SkeletonLoading.button(width: 100, height: 40),
                    const SizedBox(width: 16),
                    SkeletonLoading.button(width: 120, height: 40),
                    const SizedBox(width: 16),
                    SkeletonLoading.button(width: 48, height: 40),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Grid with more columns
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.7,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  return SkeletonLoading.gridItem();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop layouts
  static Widget _desktopHomeScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 300, height: 32),
                        const SizedBox(height: 12),
                        SkeletonLoading.text(width: 220, height: 20),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SkeletonLoading.button(width: 140, height: 44),
                      const SizedBox(width: 16),
                      SkeletonLoading.button(width: 120, height: 44),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Hero section - full width
              SizedBox(height: 350, child: SkeletonLoading.heroCard()),

              const SizedBox(height: 48),

              // Content sections in three columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Continue watching
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 200, height: 24),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return SkeletonLoading.moviePoster(
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // Trending
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 160, height: 24),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return SkeletonLoading.moviePoster(
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // Recommendations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 180, height: 24),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return SkeletonLoading.moviePoster(
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _desktopDiscoverScreen() {
    return SkeletonLoading.shimmer(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Search and filters row
            Row(
              children: [
                Expanded(flex: 3, child: SkeletonLoading.searchBar(height: 52)),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: SkeletonLoading.tabBar(tabCount: 4)),
                const SizedBox(width: 24),
                SkeletonLoading.button(width: 120, height: 52),
              ],
            ),

            const SizedBox(height: 32),

            // Grid with many columns for desktop
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 0.7,
                ),
                itemCount: 24,
                itemBuilder: (context, index) {
                  return SkeletonLoading.gridItem();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _desktopProfileScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Profile header - full width layout
              SizedBox(
                height: 200,
                child: Row(
                  children: [
                    SkeletonLoading.avatar(size: 160),
                    const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonLoading.text(width: 250, height: 32),
                          const SizedBox(height: 16),
                          SkeletonLoading.text(width: 200, height: 20),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              SkeletonLoading.button(width: 140, height: 44),
                              const SizedBox(width: 20),
                              SkeletonLoading.button(width: 120, height: 44),
                              const SizedBox(width: 20),
                              SkeletonLoading.button(width: 100, height: 44),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Stats cards - full row
              Row(
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 5 ? 20 : 0),
                      child: SkeletonLoading.statsCard(height: 140),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 48),

              // Content in three columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent activity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 200, height: 24),
                        const SizedBox(height: 24),
                        ...List.generate(6, (index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: SkeletonLoading.listItem(height: 80),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // Achievements
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 180, height: 24),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 1.0,
                              ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            return SkeletonLoading.box(
                              width: double.infinity,
                              height: double.infinity,
                              borderRadius: BorderRadius.circular(16),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // Statistics or other content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 160, height: 24),
                        const SizedBox(height: 24),
                        ...List.generate(4, (index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: SkeletonLoading.statsCard(height: 100),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _desktopDetailScreen() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: SkeletonLoading.shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section - side by side layout
            SizedBox(
              height: 500,
              child: Row(
                children: [
                  // Poster
                  Container(
                    width: 350,
                    padding: const EdgeInsets.all(32),
                    child: SkeletonLoading.moviePoster(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonLoading.text(width: 400, height: 36),
                          const SizedBox(height: 16),
                          SkeletonLoading.text(width: 300, height: 20),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              SkeletonLoading.ratingStars(starSize: 24),
                              const SizedBox(width: 24),
                              SkeletonLoading.text(width: 100, height: 18),
                              const SizedBox(width: 40),
                              SkeletonLoading.text(width: 80, height: 18),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SkeletonLoading.button(
                                  width: double.infinity,
                                  height: 52,
                                ),
                              ),
                              const SizedBox(width: 20),
                              SkeletonLoading.button(width: 52, height: 52),
                              const SizedBox(width: 16),
                              SkeletonLoading.button(width: 52, height: 52),
                              const SizedBox(width: 16),
                              SkeletonLoading.button(width: 52, height: 52),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SkeletonLoading.text(
                            width: double.infinity,
                            height: 20,
                          ),
                          const SizedBox(height: 12),
                          SkeletonLoading.text(
                            width: double.infinity,
                            height: 20,
                          ),
                          const SizedBox(height: 12),
                          SkeletonLoading.text(width: 500, height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content sections
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cast
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 120, height: 28),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Expanded(
                                  child: SkeletonLoading.avatar(
                                    size: double.infinity,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SkeletonLoading.text(
                                  width: double.infinity,
                                  height: 16,
                                ),
                                const SizedBox(height: 4),
                                SkeletonLoading.text(width: 80, height: 14),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 48),

                  // Similar content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading.text(width: 180, height: 28),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return SkeletonLoading.moviePoster(
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _desktopLibraryScreen() {
    return SkeletonLoading.shimmer(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Header with tabs and controls
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading.text(width: 200, height: 32),
                      const SizedBox(height: 20),
                      SkeletonLoading.tabBar(tabCount: 5),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                Row(
                  children: [
                    SkeletonLoading.button(width: 120, height: 44),
                    const SizedBox(width: 20),
                    SkeletonLoading.button(width: 140, height: 44),
                    const SizedBox(width: 20),
                    SkeletonLoading.button(width: 52, height: 44),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Grid with many columns
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 0.7,
                ),
                itemCount: 32,
                itemBuilder: (context, index) {
                  return SkeletonLoading.gridItem();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
