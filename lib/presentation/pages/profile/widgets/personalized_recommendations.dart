import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Personalized recommendations engine with smart content suggestions
class PersonalizedRecommendations extends ConsumerStatefulWidget {
  final Map<String, dynamic> userProfile;
  final List<Map<String, dynamic>> viewingHistory;

  const PersonalizedRecommendations({
    super.key,
    required this.userProfile,
    required this.viewingHistory,
  });

  @override
  ConsumerState<PersonalizedRecommendations> createState() =>
      _PersonalizedRecommendationsState();
}

class _PersonalizedRecommendationsState
    extends ConsumerState<PersonalizedRecommendations>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _sectionControllers;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedCategory = 'for_you';
  bool _isRefreshing = false;

  final List<Map<String, String>> _categories = [
    {
      'id': 'for_you',
      'name': 'For You',
      'description': 'Personalized picks based on your taste',
      'icon': 'person',
    },
    {
      'id': 'trending',
      'name': 'Trending',
      'description': 'What everyone is watching now',
      'icon': 'trending_up',
    },
    {
      'id': 'similar',
      'name': 'More Like This',
      'description': 'Based on your recent watches',
      'icon': 'recommend',
    },
    {
      'id': 'genres',
      'name': 'Your Genres',
      'description': 'From your favorite genres',
      'icon': 'category',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    // Create controllers for each recommendation section
    _sectionControllers = List.generate(
      4, // Number of recommendation sections
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 200)),
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
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: MotionPresets.slideUp.curve,
          ),
        );
  }

  void _startAnimations() {
    _animationController.forward();

    // Start section animations with staggered delays
    Future.delayed(const Duration(milliseconds: 300), () {
      for (int i = 0; i < _sectionControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          if (mounted) {
            _sectionControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _sectionControllers) {
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
                  _buildCategoryTabs(),
                  const SizedBox(height: 24),
                  _buildRecommendationSections(),
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
            color: AppColors.cinematicPurple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.cinematicPurple,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discover Your Next Favorite',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Curated recommendations just for you',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _refreshRecommendations,
          icon: AnimatedRotation(
            turns: _isRefreshing ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Icon(
              Icons.refresh_rounded,
              color: AppColors.cinematicPurple,
            ),
          ),
          tooltip: 'Refresh Recommendations',
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (index) {
          final category = _categories[index];
          final isSelected = category['id'] == _selectedCategory;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: EdgeInsets.only(
                right: index < _categories.length - 1 ? 12 : 0,
              ),
              child: GestureDetector(
                onTap: () => _selectCategory(category['id']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.cinematicPurple.withValues(alpha: 0.2)
                        : AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.cinematicPurple
                          : AppColors.darkTextTertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForCategory(category['icon']!),
                        color: isSelected
                            ? AppColors.cinematicPurple
                            : AppColors.darkTextSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category['name']!,
                        style: AppTypography.labelLarge.copyWith(
                          color: isSelected
                              ? AppColors.cinematicPurple
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
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecommendationSections() {
    switch (_selectedCategory) {
      case 'for_you':
        return _buildForYouSection();
      case 'trending':
        return _buildTrendingSection();
      case 'similar':
        return _buildSimilarSection();
      case 'genres':
        return _buildGenresSection();
      default:
        return _buildForYouSection();
    }
  }

  Widget _buildForYouSection() {
    return Column(
      children: [
        _buildRecommendationRow(
          title: 'Because You Loved "The Dark Knight"',
          subtitle: 'More superhero epics you\'ll enjoy',
          recommendations: _getSuperheroRecommendations(),
          controller: _sectionControllers[0],
        ),
        const SizedBox(height: 32),
        _buildRecommendationRow(
          title: 'Your Sci-Fi Journey Continues',
          subtitle: 'Mind-bending stories await',
          recommendations: _getSciFiRecommendations(),
          controller: _sectionControllers[1],
        ),
        const SizedBox(height: 32),
        _buildRecommendationRow(
          title: 'Hidden Gems for You',
          subtitle: 'Underrated movies you might have missed',
          recommendations: _getHiddenGemRecommendations(),
          controller: _sectionControllers[2],
        ),
      ],
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      children: [
        _buildRecommendationRow(
          title: 'Trending Now',
          subtitle: 'What everyone is watching this week',
          recommendations: _getTrendingRecommendations(),
          controller: _sectionControllers[0],
        ),
        const SizedBox(height: 32),
        _buildRecommendationRow(
          title: 'Rising Stars',
          subtitle: 'Movies gaining momentum',
          recommendations: _getRisingRecommendations(),
          controller: _sectionControllers[1],
        ),
      ],
    );
  }

  Widget _buildSimilarSection() {
    return Column(
      children: [
        _buildRecommendationRow(
          title: 'More Like "Inception"',
          subtitle: 'Complex narratives and mind-bending plots',
          recommendations: _getSimilarToInception(),
          controller: _sectionControllers[0],
        ),
        const SizedBox(height: 32),
        _buildRecommendationRow(
          title: 'If You Liked "Breaking Bad"',
          subtitle: 'Intense character-driven dramas',
          recommendations: _getSimilarToBreakingBad(),
          controller: _sectionControllers[1],
        ),
      ],
    );
  }

  Widget _buildGenresSection() {
    final topGenres =
        widget.userProfile['topGenres'] as List<Map<String, dynamic>>? ?? [];

    return Column(
      children: List.generate(topGenres.take(3).length, (index) {
        final genre = topGenres[index];
        return Column(
          children: [
            _buildRecommendationRow(
              title: 'More ${genre['name']} for You',
              subtitle: 'Based on your ${genre['name']} viewing history',
              recommendations: _getGenreRecommendations(genre['name']),
              controller: _sectionControllers[index],
            ),
            if (index < topGenres.take(3).length - 1)
              const SizedBox(height: 32),
          ],
        );
      }),
    );
  }

  Widget _buildRecommendationRow({
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> recommendations,
    required AnimationController controller,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  TextButton(
                    onPressed: () => _viewAllRecommendations(title),
                    child: Text(
                      'See All',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.cinematicPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Recommendations List
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final recommendation = recommendations[index];
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween(begin: 0.0, end: controller.value),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: EdgeInsets.only(
                          right: index < recommendations.length - 1 ? 16 : 0,
                        ),
                        child: _buildRecommendationCard(recommendation),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return GestureDetector(
      onTap: () => _viewRecommendationDetails(recommendation),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.darkBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Poster Placeholder
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.cinematicPurple.withValues(alpha: 0.3),
                          AppColors.cinematicBlue.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Icon(
                      recommendation['type'] == 'movie'
                          ? Icons.movie_rounded
                          : Icons.tv_rounded,
                      color: AppColors.darkTextSecondary,
                      size: 48,
                    ),
                  ),

                  // Rating Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.cinematicGold,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${recommendation['rating']?.toStringAsFixed(1) ?? '0.0'}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.darkTextPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Match Percentage
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cinematicPurple.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${recommendation['match']}% match',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            recommendation['title'] ?? 'Unknown Title',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Year and Genre
          Text(
            '${recommendation['year'] ?? 'Unknown'} • ${recommendation['genre'] ?? 'Unknown'}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.darkTextSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'recommend':
        return Icons.recommend_rounded;
      case 'category':
        return Icons.category_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  void _selectCategory(String categoryId) {
    if (categoryId != _selectedCategory) {
      setState(() {
        _selectedCategory = categoryId;
      });
      HapticFeedback.selectionClick();

      // Restart animations for new category
      for (final controller in _sectionControllers) {
        controller.reset();
        controller.forward();
      }
    }
  }

  void _refreshRecommendations() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    // Simulate refresh delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });

      // Restart animations
      for (final controller in _sectionControllers) {
        controller.reset();
        controller.forward();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recommendations refreshed!'),
          backgroundColor: AppColors.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _viewAllRecommendations(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening all recommendations for: $category'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _viewRecommendationDetails(Map<String, dynamic> recommendation) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${recommendation['title']}'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Mock recommendation data generators
  List<Map<String, dynamic>> _getSuperheroRecommendations() {
    return [
      {
        'id': 1,
        'title': 'The Dark Knight Rises',
        'year': 2012,
        'genre': 'Action',
        'type': 'movie',
        'rating': 8.4,
        'match': 95,
      },
      {
        'id': 2,
        'title': 'Batman Begins',
        'year': 2005,
        'genre': 'Action',
        'type': 'movie',
        'rating': 8.2,
        'match': 92,
      },
      {
        'id': 3,
        'title': 'Watchmen',
        'year': 2009,
        'genre': 'Action',
        'type': 'movie',
        'rating': 7.6,
        'match': 88,
      },
      {
        'id': 4,
        'title': 'V for Vendetta',
        'year': 2005,
        'genre': 'Action',
        'type': 'movie',
        'rating': 8.1,
        'match': 85,
      },
    ];
  }

  List<Map<String, dynamic>> _getSciFiRecommendations() {
    return [
      {
        'id': 5,
        'title': 'Blade Runner 2049',
        'year': 2017,
        'genre': 'Sci-Fi',
        'type': 'movie',
        'rating': 8.0,
        'match': 93,
      },
      {
        'id': 6,
        'title': 'Arrival',
        'year': 2016,
        'genre': 'Sci-Fi',
        'type': 'movie',
        'rating': 7.9,
        'match': 90,
      },
      {
        'id': 7,
        'title': 'Ex Machina',
        'year': 2014,
        'genre': 'Sci-Fi',
        'type': 'movie',
        'rating': 7.7,
        'match': 87,
      },
      {
        'id': 8,
        'title': 'Interstellar',
        'year': 2014,
        'genre': 'Sci-Fi',
        'type': 'movie',
        'rating': 8.6,
        'match': 91,
      },
    ];
  }

  List<Map<String, dynamic>> _getHiddenGemRecommendations() {
    return [
      {
        'id': 9,
        'title': 'The Man from Earth',
        'year': 2007,
        'genre': 'Drama',
        'type': 'movie',
        'rating': 7.8,
        'match': 89,
      },
      {
        'id': 10,
        'title': 'Coherence',
        'year': 2013,
        'genre': 'Sci-Fi',
        'type': 'movie',
        'rating': 7.2,
        'match': 86,
      },
      {
        'id': 11,
        'title': 'The Invitation',
        'year': 2015,
        'genre': 'Thriller',
        'type': 'movie',
        'rating': 6.6,
        'match': 83,
      },
      {
        'id': 12,
        'title': 'Sound of Metal',
        'year': 2019,
        'genre': 'Drama',
        'type': 'movie',
        'rating': 7.7,
        'match': 88,
      },
    ];
  }

  List<Map<String, dynamic>> _getTrendingRecommendations() {
    return [
      {
        'id': 13,
        'title': 'Dune: Part Two',
        'year': 2024,
        'genre': 'Sci-Fi',
        'type': 'movie',
        'rating': 8.5,
        'match': 94,
      },
      {
        'id': 14,
        'title': 'The Bear',
        'year': 2022,
        'genre': 'Comedy',
        'type': 'tv',
        'rating': 8.7,
        'match': 91,
      },
      {
        'id': 15,
        'title': 'House of the Dragon',
        'year': 2022,
        'genre': 'Fantasy',
        'type': 'tv',
        'rating': 8.4,
        'match': 89,
      },
      {
        'id': 16,
        'title': 'Everything Everywhere All at Once',
        'year': 2022,
        'genre': 'Sci-Fi',
        'type': 'movie',
        'rating': 7.8,
        'match': 92,
      },
    ];
  }

  List<Map<String, dynamic>> _getRisingRecommendations() {
    return [
      {
        'id': 17,
        'title': 'The Last of Us',
        'year': 2023,
        'genre': 'Drama',
        'type': 'tv',
        'rating': 8.7,
        'match': 93,
      },
      {
        'id': 18,
        'title': 'Wednesday',
        'year': 2022,
        'genre': 'Comedy',
        'type': 'tv',
        'rating': 8.1,
        'match': 87,
      },
      {
        'id': 19,
        'title': 'Top Gun: Maverick',
        'year': 2022,
        'genre': 'Action',
        'type': 'movie',
        'rating': 8.3,
        'match': 90,
      },
      {
        'id': 20,
        'title': 'Stranger Things 4',
        'year': 2022,
        'genre': 'Sci-Fi',
        'type': 'tv',
        'rating': 8.7,
        'match': 88,
      },
    ];
  }

  List<Map<String, dynamic>> _getSimilarToInception() {
    return [
      {
        'id': 21,
        'title': 'Memento',
        'year': 2000,
        'genre': 'Thriller',
        'type': 'movie',
        'rating': 8.4,
        'match': 96,
      },
      {
        'id': 22,
        'title': 'The Prestige',
        'year': 2006,
        'genre': 'Mystery',
        'type': 'movie',
        'rating': 8.5,
        'match': 94,
      },
      {
        'id': 23,
        'title': 'Shutter Island',
        'year': 2010,
        'genre': 'Thriller',
        'type': 'movie',
        'rating': 8.2,
        'match': 91,
      },
      {
        'id': 24,
        'title': 'Primer',
        'year': 2004,
        'genre': 'Sci-Fi',
        'type': 'movie',
        'rating': 6.9,
        'match': 89,
      },
    ];
  }

  List<Map<String, dynamic>> _getSimilarToBreakingBad() {
    return [
      {
        'id': 25,
        'title': 'Better Call Saul',
        'year': 2015,
        'genre': 'Drama',
        'type': 'tv',
        'rating': 8.8,
        'match': 97,
      },
      {
        'id': 26,
        'title': 'Ozark',
        'year': 2017,
        'genre': 'Crime',
        'type': 'tv',
        'rating': 8.4,
        'match': 93,
      },
      {
        'id': 27,
        'title': 'The Sopranos',
        'year': 1999,
        'genre': 'Crime',
        'type': 'tv',
        'rating': 9.2,
        'match': 91,
      },
      {
        'id': 28,
        'title': 'Narcos',
        'year': 2015,
        'genre': 'Crime',
        'type': 'tv',
        'rating': 8.8,
        'match': 89,
      },
    ];
  }

  List<Map<String, dynamic>> _getGenreRecommendations(String genre) {
    // Return different recommendations based on genre
    switch (genre.toLowerCase()) {
      case 'action':
        return [
          {
            'id': 29,
            'title': 'Mad Max: Fury Road',
            'year': 2015,
            'genre': 'Action',
            'type': 'movie',
            'rating': 8.1,
            'match': 92,
          },
          {
            'id': 30,
            'title': 'John Wick',
            'year': 2014,
            'genre': 'Action',
            'type': 'movie',
            'rating': 7.4,
            'match': 89,
          },
        ];
      case 'drama':
        return [
          {
            'id': 31,
            'title': 'The Shawshank Redemption',
            'year': 1994,
            'genre': 'Drama',
            'type': 'movie',
            'rating': 9.3,
            'match': 95,
          },
          {
            'id': 32,
            'title': 'Forrest Gump',
            'year': 1994,
            'genre': 'Drama',
            'type': 'movie',
            'rating': 8.8,
            'match': 91,
          },
        ];
      case 'comedy':
        return [
          {
            'id': 33,
            'title': 'The Grand Budapest Hotel',
            'year': 2014,
            'genre': 'Comedy',
            'type': 'movie',
            'rating': 8.1,
            'match': 88,
          },
          {
            'id': 34,
            'title': 'Brooklyn Nine-Nine',
            'year': 2013,
            'genre': 'Comedy',
            'type': 'tv',
            'rating': 8.4,
            'match': 85,
          },
        ];
      default:
        return _getSuperheroRecommendations();
    }
  }
}
