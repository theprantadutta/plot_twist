import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Comprehensive achievement and badge system with unlock animations
class AchievementBadgeSystem extends ConsumerStatefulWidget {
  final Map<String, dynamic> userStats;
  final Function(Map<String, dynamic>)? onAchievementUnlocked;

  const AchievementBadgeSystem({
    super.key,
    required this.userStats,
    this.onAchievementUnlocked,
  });

  @override
  ConsumerState<AchievementBadgeSystem> createState() =>
      _AchievementBadgeSystemState();
}

class _AchievementBadgeSystemState extends ConsumerState<AchievementBadgeSystem>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _unlockController;
  late List<AnimationController> _badgeControllers;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _unlockScaleAnimation;
  late Animation<double> _unlockRotationAnimation;

  final List<String> _recentlyUnlocked = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkForNewAchievements();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _unlockController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final achievements = _getAllAchievements();
    _badgeControllers = List.generate(
      achievements.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 50)),
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

    _unlockScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(parent: _unlockController, curve: Curves.elasticOut),
    );

    _unlockRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _unlockController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _animationController.forward();

    // Start badge animations with staggered delays
    Future.delayed(const Duration(milliseconds: 400), () {
      for (int i = 0; i < _badgeControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 80), () {
          if (mounted) {
            _badgeControllers[i].forward();
          }
        });
      }
    });
  }

  void _checkForNewAchievements() {
    final achievements = _getAllAchievements();
    for (final achievement in achievements) {
      if (achievement['unlocked'] == true && achievement['isNew'] == true) {
        _recentlyUnlocked.add(achievement['id']);
      }
    }

    // Show unlock animations for new achievements
    if (_recentlyUnlocked.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _showUnlockAnimation();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _unlockController.dispose();
    for (final controller in _badgeControllers) {
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
                  _buildAchievementGrid(),
                  const SizedBox(height: 24),
                  _buildProgressSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final achievements = _getAllAchievements();
    final unlockedCount = achievements
        .where((a) => a['unlocked'] == true)
        .length;
    final totalCount = achievements.length;
    final completionPercentage = ((unlockedCount / totalCount) * 100).toInt();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cinematicGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.emoji_events_rounded,
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
                'Achievement Badges',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$unlockedCount of $totalCount unlocked ($completionPercentage%)',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
        if (_recentlyUnlocked.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cinematicRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_recentlyUnlocked.length} New!',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['All', 'Viewing', 'Social', 'Milestones'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == 'All'; // Default to 'All' for now

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _selectCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.cinematicGold
                      : AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.cinematicGold
                        : AppColors.darkTextTertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  category,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected
                        ? Colors.black
                        : AppColors.darkTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementGrid() {
    final achievements = _getAllAchievements();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementBadge(
          achievement,
          _badgeControllers[index],
          index,
        );
      },
    );
  }

  Widget _buildAchievementBadge(
    Map<String, dynamic> achievement,
    AnimationController controller,
    int index,
  ) {
    final isUnlocked = achievement['unlocked'] as bool;
    final isNew = achievement['isNew'] as bool? ?? false;
    final isRecentlyUnlocked = _recentlyUnlocked.contains(achievement['id']);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0.0, end: controller.value),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.7 + (0.3 * value),
              child: GestureDetector(
                onTap: () => _showAchievementDetails(achievement),
                child: Container(
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.darkBackground
                        : AppColors.darkBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUnlocked
                          ? (achievement['color'] as Color).withValues(
                              alpha: 0.6,
                            )
                          : AppColors.darkTextTertiary.withValues(alpha: 0.3),
                      width: isRecentlyUnlocked ? 3 : 2,
                    ),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: (achievement['color'] as Color).withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: isRecentlyUnlocked ? 20 : 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Shimmer effect for recently unlocked
                      if (isRecentlyUnlocked)
                        Positioned.fill(
                          child: _buildShimmerEffect(
                            achievement['color'] as Color,
                          ),
                        ),

                      // Main Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Badge Icon
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? (achievement['color'] as Color)
                                          .withValues(alpha: 0.2)
                                    : AppColors.darkTextTertiary.withValues(
                                        alpha: 0.1,
                                      ),
                                shape: BoxShape.circle,
                                boxShadow: isUnlocked
                                    ? [
                                        BoxShadow(
                                          color: (achievement['color'] as Color)
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                achievement['icon'] as IconData,
                                color: isUnlocked
                                    ? achievement['color'] as Color
                                    : AppColors.darkTextTertiary,
                                size: 32,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Title
                            Text(
                              achievement['title'] as String,
                              style: AppTypography.titleSmall.copyWith(
                                color: isUnlocked
                                    ? AppColors.darkTextPrimary
                                    : AppColors.darkTextTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            // Rarity
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRarityColor(
                                  achievement['rarity'],
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                achievement['rarity'] as String,
                                style: AppTypography.labelSmall.copyWith(
                                  color: _getRarityColor(achievement['rarity']),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // New Badge
                      if (isNew && isUnlocked)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.cinematicRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cinematicRed.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Lock Overlay
                      if (!isUnlocked)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.lock_rounded,
                                color: AppColors.darkTextTertiary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerEffect(Color color) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: -1.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                color.withValues(alpha: 0.1),
                Colors.transparent,
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    final inProgressAchievements = _getAllAchievements()
        .where(
          (a) =>
              a['unlocked'] == false &&
              a['progress'] != null &&
              a['progress'] > 0,
        )
        .take(3)
        .toList();

    if (inProgressAchievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Almost There!',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        ...inProgressAchievements.map((achievement) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildProgressItem(achievement),
          );
        }),
      ],
    );
  }

  Widget _buildProgressItem(Map<String, dynamic> achievement) {
    final progress = achievement['progress'] as double;
    final target = achievement['target'] as int;
    final current = (progress * target).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (achievement['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (achievement['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  achievement['icon'] as IconData,
                  color: achievement['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['title'] as String,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement['description'] as String,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$current/$target',
                    style: AppTypography.titleSmall.copyWith(
                      color: achievement['color'] as Color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Animated Progress Bar
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: progress),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: (achievement['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: achievement['color'] as Color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: (achievement['color'] as Color).withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String? rarity) {
    switch (rarity?.toLowerCase()) {
      case 'common':
        return AppColors.darkTextSecondary;
      case 'rare':
        return AppColors.cinematicBlue;
      case 'epic':
        return AppColors.cinematicPurple;
      case 'legendary':
        return AppColors.cinematicGold;
      default:
        return AppColors.darkTextSecondary;
    }
  }

  List<Map<String, dynamic>> _getAllAchievements() {
    final moviesWatched = widget.userStats['moviesWatched'] ?? 0;
    final showsWatched = widget.userStats['showsWatched'] ?? 0;
    final hoursWatched = widget.userStats['hoursWatched'] ?? 0;
    final listsCreated = widget.userStats['listsCreated'] ?? 0;
    final ratingsGiven = widget.userStats['ratingsGiven'] ?? 0;
    final genresExplored = widget.userStats['genresExplored'] ?? 0;
    final listsShared = widget.userStats['listsShared'] ?? 0;
    final friendsAdded = widget.userStats['friendsAdded'] ?? 0;

    return [
      // Viewing Achievements
      {
        'id': 'first_movie',
        'title': 'First Steps',
        'description': 'Watch your first movie',
        'icon': Icons.play_circle_rounded,
        'color': AppColors.cinematicRed,
        'category': 'viewing',
        'rarity': 'common',
        'unlocked': moviesWatched >= 1,
        'target': 1,
        'progress': moviesWatched >= 1 ? 1.0 : moviesWatched / 1,
        'isNew': moviesWatched == 1,
      },
      {
        'id': 'movie_buff',
        'title': 'Movie Buff',
        'description': 'Watch 50 movies',
        'icon': Icons.movie_rounded,
        'color': AppColors.cinematicRed,
        'category': 'viewing',
        'rarity': 'rare',
        'unlocked': moviesWatched >= 50,
        'target': 50,
        'progress': (moviesWatched / 50).clamp(0.0, 1.0),
        'isNew': moviesWatched >= 50 && moviesWatched < 55,
      },
      {
        'id': 'cinephile',
        'title': 'Cinephile',
        'description': 'Watch 100 movies',
        'icon': Icons.local_movies_rounded,
        'color': AppColors.cinematicGold,
        'category': 'viewing',
        'rarity': 'epic',
        'unlocked': moviesWatched >= 100,
        'target': 100,
        'progress': (moviesWatched / 100).clamp(0.0, 1.0),
        'isNew': moviesWatched >= 100 && moviesWatched < 105,
      },
      {
        'id': 'tv_enthusiast',
        'title': 'TV Enthusiast',
        'description': 'Watch 25 TV shows',
        'icon': Icons.tv_rounded,
        'color': AppColors.cinematicBlue,
        'category': 'viewing',
        'rarity': 'rare',
        'unlocked': showsWatched >= 25,
        'target': 25,
        'progress': (showsWatched / 25).clamp(0.0, 1.0),
        'isNew': showsWatched >= 25 && showsWatched < 30,
      },
      {
        'id': 'binge_master',
        'title': 'Binge Master',
        'description': 'Watch 500 hours of content',
        'icon': Icons.schedule_rounded,
        'color': AppColors.cinematicPurple,
        'category': 'viewing',
        'rarity': 'legendary',
        'unlocked': hoursWatched >= 500,
        'target': 500,
        'progress': (hoursWatched / 500).clamp(0.0, 1.0),
        'isNew': hoursWatched >= 500 && hoursWatched < 520,
      },

      // Social Achievements
      {
        'id': 'curator',
        'title': 'Curator',
        'description': 'Create 5 custom lists',
        'icon': Icons.list_rounded,
        'color': AppColors.darkSuccessGreen,
        'category': 'social',
        'rarity': 'rare',
        'unlocked': listsCreated >= 5,
        'target': 5,
        'progress': (listsCreated / 5).clamp(0.0, 1.0),
        'isNew': listsCreated >= 5 && listsCreated < 8,
      },
      {
        'id': 'social_butterfly',
        'title': 'Social Butterfly',
        'description': 'Share 10 lists with friends',
        'icon': Icons.share_rounded,
        'color': AppColors.cinematicBlue,
        'category': 'social',
        'rarity': 'epic',
        'unlocked': listsShared >= 10,
        'target': 10,
        'progress': (listsShared / 10).clamp(0.0, 1.0),
        'isNew': listsShared >= 10 && listsShared < 12,
      },
      {
        'id': 'networker',
        'title': 'Networker',
        'description': 'Add 20 friends',
        'icon': Icons.people_rounded,
        'color': AppColors.cinematicGold,
        'category': 'social',
        'rarity': 'rare',
        'unlocked': friendsAdded >= 20,
        'target': 20,
        'progress': (friendsAdded / 20).clamp(0.0, 1.0),
        'isNew': friendsAdded >= 20 && friendsAdded < 23,
      },

      // Milestone Achievements
      {
        'id': 'critic',
        'title': 'Critic',
        'description': 'Rate 100 movies/shows',
        'icon': Icons.star_rounded,
        'color': AppColors.cinematicGold,
        'category': 'milestones',
        'rarity': 'epic',
        'unlocked': ratingsGiven >= 100,
        'target': 100,
        'progress': (ratingsGiven / 100).clamp(0.0, 1.0),
        'isNew': ratingsGiven >= 100 && ratingsGiven < 105,
      },
      {
        'id': 'genre_explorer',
        'title': 'Genre Explorer',
        'description': 'Watch content from 15 different genres',
        'icon': Icons.explore_rounded,
        'color': AppColors.cinematicRed,
        'category': 'milestones',
        'rarity': 'legendary',
        'unlocked': genresExplored >= 15,
        'target': 15,
        'progress': (genresExplored / 15).clamp(0.0, 1.0),
        'isNew': genresExplored >= 15 && genresExplored < 17,
      },
      {
        'id': 'completionist',
        'title': 'Completionist',
        'description': 'Complete all other achievements',
        'icon': Icons.emoji_events_rounded,
        'color': AppColors.cinematicGold,
        'category': 'milestones',
        'rarity': 'legendary',
        'unlocked': false, // Special logic needed
        'target': 10,
        'progress': 0.8, // Mock progress
        'isNew': false,
      },
    ];
  }

  void _selectCategory(String category) {
    HapticFeedback.selectionClick();
    // TODO: Implement category filtering
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtering by $category category...'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAchievementDetails(Map<String, dynamic> achievement) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => _buildAchievementDialog(achievement),
    );
  }

  Widget _buildAchievementDialog(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] as bool;

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Achievement Badge
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? (achievement['color'] as Color).withValues(alpha: 0.2)
                    : AppColors.darkTextTertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: (achievement['color'] as Color).withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                achievement['icon'] as IconData,
                color: isUnlocked
                    ? achievement['color'] as Color
                    : AppColors.darkTextTertiary,
                size: 64,
              ),
            ),

            const SizedBox(height: 20),

            // Title and Rarity
            Text(
              achievement['title'] as String,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRarityColor(
                  achievement['rarity'],
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${achievement['rarity']} Achievement',
                style: AppTypography.labelMedium.copyWith(
                  color: _getRarityColor(achievement['rarity']),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              achievement['description'] as String,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Progress or Status
            if (!isUnlocked && achievement['progress'] != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${((achievement['progress'] as double) * 100).toInt()}%',
                          style: AppTypography.titleSmall.copyWith(
                            color: achievement['color'] as Color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: achievement['progress'] as double,
                      backgroundColor: (achievement['color'] as Color)
                          .withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievement['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isUnlocked) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkSuccessGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.darkSuccessGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked!',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.darkSuccessGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Close Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.cinematicGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnlockAnimation() {
    if (_recentlyUnlocked.isEmpty) return;

    HapticFeedback.heavyImpact();
    _unlockController.forward().then((_) {
      _unlockController.reverse();
    });

    // Show unlock notification
    final achievement = _getAllAchievements().firstWhere(
      (a) => a['id'] == _recentlyUnlocked.first,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: AppColors.cinematicGold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Achievement Unlocked!',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    achievement['title'],
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.cinematicGold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
