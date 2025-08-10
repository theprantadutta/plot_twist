import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Achievement-style indicators for viewing milestones
class AchievementIndicators extends ConsumerStatefulWidget {
  final Map<String, dynamic> userStats;

  const AchievementIndicators({super.key, required this.userStats});

  @override
  ConsumerState<AchievementIndicators> createState() =>
      _AchievementIndicatorsState();
}

class _AchievementIndicatorsState extends ConsumerState<AchievementIndicators>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _achievementControllers;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    // Create controllers for each achievement
    _achievementControllers = List.generate(
      _getAchievements().length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 800 + (index * 100)),
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

    // Start achievement animations with staggered delays
    Future.delayed(const Duration(milliseconds: 300), () {
      for (int i = 0; i < _achievementControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) {
            _achievementControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _achievementControllers) {
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
    final unlockedCount = _getAchievements()
        .where((a) => a['unlocked'] == true)
        .length;
    final totalCount = _getAchievements().length;

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
                'Achievements',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$unlockedCount of $totalCount unlocked',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.cinematicGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${((unlockedCount / totalCount) * 100).toInt()}%',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.cinematicGold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementGrid() {
    final achievements = _getAchievements();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementBadge(
          achievement,
          _achievementControllers[index],
        );
      },
    );
  }

  Widget _buildAchievementBadge(
    Map<String, dynamic> achievement,
    AnimationController controller,
  ) {
    final isUnlocked = achievement['unlocked'] as bool;
    final isNew = achievement['isNew'] as bool? ?? false;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: controller.value),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: GestureDetector(
                onTap: () => _showAchievementDetails(achievement),
                child: Container(
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.darkBackground
                        : AppColors.darkBackground.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked
                          ? (achievement['color'] as Color).withValues(
                              alpha: 0.5,
                            )
                          : AppColors.darkTextTertiary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: (achievement['color'] as Color).withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Main Content
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? (achievement['color'] as Color)
                                          .withValues(alpha: 0.2)
                                    : AppColors.darkTextTertiary.withValues(
                                        alpha: 0.1,
                                      ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                achievement['icon'] as IconData,
                                color: isUnlocked
                                    ? achievement['color'] as Color
                                    : AppColors.darkTextTertiary,
                                size: 24,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Title
                            Text(
                              achievement['title'] as String,
                              style: AppTypography.labelMedium.copyWith(
                                color: isUnlocked
                                    ? AppColors.darkTextPrimary
                                    : AppColors.darkTextTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // New Badge
                      if (isNew && isUnlocked)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.cinematicRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                      // Lock Overlay
                      if (!isUnlocked)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.lock_rounded,
                                color: AppColors.darkTextTertiary,
                                size: 20,
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

  Widget _buildProgressSection() {
    final inProgressAchievements = _getAchievements()
        .where((a) => a['unlocked'] == false && a['progress'] != null)
        .take(3)
        .toList();

    if (inProgressAchievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'In Progress',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        ...inProgressAchievements.map((achievement) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (achievement['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                achievement['icon'] as IconData,
                color: achievement['color'] as Color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  achievement['title'] as String,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$current/$target',
                style: AppTypography.labelMedium.copyWith(
                  color: achievement['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: (achievement['color'] as Color).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: achievement['color'] as Color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            achievement['description'] as String,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAchievements() {
    final moviesWatched = widget.userStats['moviesWatched'] ?? 0;
    final showsWatched = widget.userStats['showsWatched'] ?? 0;
    final hoursWatched = widget.userStats['hoursWatched'] ?? 0;
    final listsCreated = widget.userStats['listsCreated'] ?? 0;
    final ratingsGiven = widget.userStats['ratingsGiven'] ?? 0;

    return [
      {
        'id': 'first_movie',
        'title': 'First Steps',
        'description': 'Watch your first movie',
        'icon': Icons.play_circle_rounded,
        'color': AppColors.cinematicRed,
        'unlocked': moviesWatched >= 1,
        'target': 1,
        'progress': moviesWatched >= 1 ? 1.0 : moviesWatched / 1,
        'isNew': false,
      },
      {
        'id': 'movie_buff',
        'title': 'Movie Buff',
        'description': 'Watch 50 movies',
        'icon': Icons.movie_rounded,
        'color': AppColors.cinematicRed,
        'unlocked': moviesWatched >= 50,
        'target': 50,
        'progress': (moviesWatched / 50).clamp(0.0, 1.0),
        'isNew': moviesWatched >= 50,
      },
      {
        'id': 'cinephile',
        'title': 'Cinephile',
        'description': 'Watch 100 movies',
        'icon': Icons.local_movies_rounded,
        'color': AppColors.cinematicGold,
        'unlocked': moviesWatched >= 100,
        'target': 100,
        'progress': (moviesWatched / 100).clamp(0.0, 1.0),
        'isNew': false,
      },
      {
        'id': 'tv_enthusiast',
        'title': 'TV Enthusiast',
        'description': 'Watch 25 TV shows',
        'icon': Icons.tv_rounded,
        'color': AppColors.cinematicBlue,
        'unlocked': showsWatched >= 25,
        'target': 25,
        'progress': (showsWatched / 25).clamp(0.0, 1.0),
        'isNew': false,
      },
      {
        'id': 'binge_watcher',
        'title': 'Binge Watcher',
        'description': 'Watch 500 hours of content',
        'icon': Icons.schedule_rounded,
        'color': AppColors.cinematicPurple,
        'unlocked': hoursWatched >= 500,
        'target': 500,
        'progress': (hoursWatched / 500).clamp(0.0, 1.0),
        'isNew': false,
      },
      {
        'id': 'curator',
        'title': 'Curator',
        'description': 'Create 5 custom lists',
        'icon': Icons.list_rounded,
        'color': AppColors.darkSuccessGreen,
        'unlocked': listsCreated >= 5,
        'target': 5,
        'progress': (listsCreated / 5).clamp(0.0, 1.0),
        'isNew': false,
      },
      {
        'id': 'critic',
        'title': 'Critic',
        'description': 'Rate 100 movies/shows',
        'icon': Icons.star_rounded,
        'color': AppColors.cinematicGold,
        'unlocked': ratingsGiven >= 100,
        'target': 100,
        'progress': (ratingsGiven / 100).clamp(0.0, 1.0),
        'isNew': false,
      },
      {
        'id': 'genre_explorer',
        'title': 'Genre Explorer',
        'description': 'Watch content from 10 different genres',
        'icon': Icons.explore_rounded,
        'color': AppColors.cinematicRed,
        'unlocked': (widget.userStats['genresExplored'] ?? 0) >= 10,
        'target': 10,
        'progress': ((widget.userStats['genresExplored'] ?? 0) / 10).clamp(
          0.0,
          1.0,
        ),
        'isNew': false,
      },
      {
        'id': 'social_butterfly',
        'title': 'Social Butterfly',
        'description': 'Share 10 lists with friends',
        'icon': Icons.share_rounded,
        'color': AppColors.cinematicBlue,
        'unlocked': (widget.userStats['listsShared'] ?? 0) >= 10,
        'target': 10,
        'progress': ((widget.userStats['listsShared'] ?? 0) / 10).clamp(
          0.0,
          1.0,
        ),
        'isNew': false,
      },
    ];
  }

  void _showAchievementDetails(Map<String, dynamic> achievement) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Achievement Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (achievement['color'] as Color).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement['icon'] as IconData,
                  color: achievement['color'] as Color,
                  size: 48,
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                achievement['title'] as String,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                achievement['description'] as String,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: achievement['unlocked'] as bool
                      ? AppColors.darkSuccessGreen.withValues(alpha: 0.2)
                      : AppColors.cinematicGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  achievement['unlocked'] as bool ? 'Unlocked!' : 'In Progress',
                  style: AppTypography.labelLarge.copyWith(
                    color: achievement['unlocked'] as bool
                        ? AppColors.darkSuccessGreen
                        : AppColors.cinematicGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

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
      ),
    );
  }
}
