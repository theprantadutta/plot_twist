import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Profile statistics dashboard with animated progress rings and viewing data
class ProfileStatsDashboard extends ConsumerStatefulWidget {
  final Map<String, dynamic> userStats;

  const ProfileStatsDashboard({super.key, required this.userStats});

  @override
  ConsumerState<ProfileStatsDashboard> createState() =>
      _ProfileStatsDashboardState();
}

class _ProfileStatsDashboardState extends ConsumerState<ProfileStatsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late List<AnimationController> _ringControllers;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _progressAnimations;

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

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create individual controllers for each progress ring
    _ringControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1500 + (index * 200)),
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

    // Create progress animations for each ring
    _progressAnimations = _ringControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          ),
        )
        .toList();
  }

  void _startAnimations() {
    _animationController.forward();

    // Start progress rings with staggered delays
    Future.delayed(const Duration(milliseconds: 500), () {
      for (int i = 0; i < _ringControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          if (mounted) {
            _ringControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    for (final controller in _ringControllers) {
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
                  _buildProgressRings(),
                  const SizedBox(height: 32),
                  _buildGenreDistribution(),
                  const SizedBox(height: 32),
                  _buildRecentActivity(),
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
            color: AppColors.cinematicGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.analytics_rounded,
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
                'Your Cinematic Journey',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Track your viewing progress and milestones',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRings() {
    final stats = [
      {
        'label': 'Movies',
        'value': widget.userStats['moviesWatched'] ?? 0,
        'total': widget.userStats['moviesGoal'] ?? 100,
        'color': AppColors.cinematicRed,
        'icon': Icons.movie_rounded,
      },
      {
        'label': 'TV Shows',
        'value': widget.userStats['showsWatched'] ?? 0,
        'total': widget.userStats['showsGoal'] ?? 50,
        'color': AppColors.cinematicBlue,
        'icon': Icons.tv_rounded,
      },
      {
        'label': 'Hours',
        'value': widget.userStats['hoursWatched'] ?? 0,
        'total': widget.userStats['hoursGoal'] ?? 500,
        'color': AppColors.cinematicGold,
        'icon': Icons.schedule_rounded,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(stats.length, (index) {
        final stat = stats[index];
        return _buildProgressRing(
          label: stat['label'] as String,
          value: stat['value'] as int,
          total: stat['total'] as int,
          color: stat['color'] as Color,
          icon: stat['icon'] as IconData,
          animation: _progressAnimations[index],
        );
      }),
    );
  }

  Widget _buildProgressRing({
    required String label,
    required int value,
    required int total,
    required Color color,
    required IconData icon,
    required Animation<double> animation,
  }) {
    final progress = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animatedProgress = progress * animation.value;

        return Column(
          children: [
            // Progress Ring
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  // Background Ring
                  CustomPaint(
                    size: const Size(100, 100),
                    painter: ProgressRingPainter(
                      progress: 1.0,
                      color: color.withValues(alpha: 0.2),
                      strokeWidth: 8,
                    ),
                  ),

                  // Progress Ring
                  CustomPaint(
                    size: const Size(100, 100),
                    painter: ProgressRingPainter(
                      progress: animatedProgress,
                      color: color,
                      strokeWidth: 8,
                    ),
                  ),

                  // Center Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: color, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          '$value',
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Label and Progress Text
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(animatedProgress * 100).toInt()}% of $total',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenreDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Genres',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Genre Chart
        _buildGenreChart(),

        const SizedBox(height: 16),

        // Genre Legend
        _buildGenreLegend(),
      ],
    );
  }

  Widget _buildGenreChart() {
    final genres =
        widget.userStats['topGenres'] as List<Map<String, dynamic>>? ??
        [
          {'name': 'Action', 'count': 25, 'color': AppColors.cinematicRed},
          {'name': 'Drama', 'count': 20, 'color': AppColors.cinematicBlue},
          {'name': 'Comedy', 'count': 15, 'color': AppColors.cinematicGold},
          {'name': 'Sci-Fi', 'count': 12, 'color': AppColors.cinematicPurple},
          {
            'name': 'Thriller',
            'count': 10,
            'color': AppColors.darkSuccessGreen,
          },
        ];

    final total = genres.fold<int>(
      0,
      (sum, genre) => sum + (genre['count'] as int),
    );

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Chart
          Expanded(
            flex: 2,
            child: Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter: GenreChartPainter(
                    genres: genres,
                    total: total,
                    animation: _progressController,
                  ),
                ),
              ),
            ),
          ),

          // Stats
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('Total', '$total', AppColors.darkTextPrimary),
                const SizedBox(height: 8),
                _buildStatItem(
                  'Top Genre',
                  genres.first['name'],
                  genres.first['color'],
                ),
                const SizedBox(height: 8),
                _buildStatItem(
                  'Diversity',
                  '${genres.length} genres',
                  AppColors.cinematicGold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.darkTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreLegend() {
    final genres =
        widget.userStats['topGenres'] as List<Map<String, dynamic>>? ??
        [
          {'name': 'Action', 'count': 25, 'color': AppColors.cinematicRed},
          {'name': 'Drama', 'count': 20, 'color': AppColors.cinematicBlue},
          {'name': 'Comedy', 'count': 15, 'color': AppColors.cinematicGold},
          {'name': 'Sci-Fi', 'count': 12, 'color': AppColors.cinematicPurple},
          {
            'name': 'Thriller',
            'count': 10,
            'color': AppColors.darkSuccessGreen,
          },
        ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: genres.map((genre) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 800 + (genres.indexOf(genre) * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (genre['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (genre['color'] as Color).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: genre['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${genre['name']} (${genre['count']})',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: _viewAllActivity,
              child: Text(
                'View All',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.cinematicGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Activity Timeline
        _buildActivityTimeline(),
      ],
    );
  }

  Widget _buildActivityTimeline() {
    final activities =
        widget.userStats['recentActivity'] as List<Map<String, dynamic>>? ??
        [
          {
            'title': 'The Dark Knight',
            'type': 'movie',
            'action': 'watched',
            'date': '2024-01-15',
            'rating': 9.0,
          },
          {
            'title': 'Breaking Bad',
            'type': 'tv',
            'action': 'added_to_watchlist',
            'date': '2024-01-14',
            'rating': null,
          },
          {
            'title': 'Inception',
            'type': 'movie',
            'action': 'rated',
            'date': '2024-01-13',
            'rating': 8.5,
          },
          {
            'title': 'Stranger Things',
            'type': 'tv',
            'action': 'watched',
            'date': '2024-01-12',
            'rating': 8.0,
          },
        ];

    return Column(
      children: List.generate(activities.length, (index) {
        final activity = activities[index];

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 600 + (index * 150)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildActivityItem(activity),
          ),
        );
      }),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final isMovie = activity['type'] == 'movie';
    final actionColor = _getActionColor(activity['action']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Poster Placeholder
          Container(
            width: 48,
            height: 60,
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isMovie ? Icons.movie_rounded : Icons.tv_rounded,
              color: actionColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Activity Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _getActionText(activity['action']),
                      style: AppTypography.bodySmall.copyWith(
                        color: actionColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (activity['rating'] != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.cinematicGold,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${activity['rating']}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.cinematicGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(activity['date']),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'watched':
        return AppColors.darkSuccessGreen;
      case 'added_to_watchlist':
        return AppColors.cinematicBlue;
      case 'rated':
        return AppColors.cinematicGold;
      case 'favorited':
        return AppColors.cinematicRed;
      default:
        return AppColors.darkTextSecondary;
    }
  }

  String _getActionText(String action) {
    switch (action) {
      case 'watched':
        return 'Watched';
      case 'added_to_watchlist':
        return 'Added to Watchlist';
      case 'rated':
        return 'Rated';
      case 'favorited':
        return 'Added to Favorites';
      default:
        return 'Unknown Action';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _viewAllActivity() {
    // TODO: Navigate to full activity screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening full activity view...'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Custom painter for progress rings
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for genre distribution chart
class GenreChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> genres;
  final int total;
  final Animation<double> animation;

  GenreChartPainter({
    required this.genres,
    required this.total,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    double startAngle = -math.pi / 2;

    for (final genre in genres) {
      final count = genre['count'] as int;
      final color = genre['color'] as Color;
      final sweepAngle = (2 * math.pi * count / total) * animation.value;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = AppColors.darkSurface
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
