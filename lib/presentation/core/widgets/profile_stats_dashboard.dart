import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../app_animations.dart';

/// Enhanced profile stats dashboard with circular progress indicators
/// Features animated stat circles, genre tags, and viewing statistics
class ProfileStatsDashboard extends StatefulWidget {
  final UserStats stats;
  final VoidCallback? onMoviesWatchedTap;
  final VoidCallback? onTvShowsWatchedTap;
  final VoidCallback? onWatchTimeTap;
  final EdgeInsetsGeometry? margin;

  const ProfileStatsDashboard({
    super.key,
    required this.stats,
    this.onMoviesWatchedTap,
    this.onTvShowsWatchedTap,
    this.onWatchTimeTap,
    this.margin,
  });

  @override
  State<ProfileStatsDashboard> createState() => _ProfileStatsDashboardState();
}

class _ProfileStatsDashboardState extends State<ProfileStatsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.cinematicGold.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.cinematicGold.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard Title
                _buildDashboardHeader(),

                const SizedBox(height: 24),

                // Circular Progress Indicators
                _buildStatCircles(),

                const SizedBox(height: 32),

                // Genre Distribution
                _buildGenreSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.cinematicGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.analytics_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Viewing Statistics',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Your cinematic journey',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCircles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCircle(
          title: 'Movies',
          value: widget.stats.moviesWatched,
          maxValue: 100, // Adjust based on your needs
          color: AppColors.cinematicRed,
          onTap: widget.onMoviesWatchedTap,
        ),
        _buildStatCircle(
          title: 'TV Shows',
          value: widget.stats.tvShowsWatched,
          maxValue: 50, // Adjust based on your needs
          color: AppColors.cinematicBlue,
          onTap: widget.onTvShowsWatchedTap,
        ),
        _buildStatCircle(
          title: 'Hours',
          value: widget.stats.totalHours,
          maxValue: 500, // Adjust based on your needs
          color: AppColors.cinematicGold,
          suffix: 'h',
          onTap: widget.onWatchTimeTap,
        ),
      ],
    );
  }

  Widget _buildStatCircle({
    required String title,
    required int value,
    required int maxValue,
    required Color color,
    String suffix = '',
    VoidCallback? onTap,
  }) {
    final progress = (value / maxValue).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Column(
          children: [
            // Circular Progress
            SizedBox(
              width: 70,
              height: 70,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CircularProgressPainter(
                      progress: progress * _progressAnimation.value,
                      color: color,
                      backgroundColor: AppColors.darkSurfaceVariant,
                      strokeWidth: 6,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(value * _progressAnimation.value).round()}$suffix',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.darkTextPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Title
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.darkTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreSection() {
    if (widget.stats.topGenres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Genres',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.stats.topGenres.asMap().entries.map((entry) {
            final index = entry.key;
            final genre = entry.value;
            final genreColor =
                AppColors.genreColors[genre] ?? AppColors.cinematicPurple;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: genreColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: genreColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: genreColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          genre,
                          style: AppTypography.genreTag.copyWith(
                            color: genreColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Custom painter for circular progress indicators
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Data model for user statistics
class UserStats {
  final int moviesWatched;
  final int tvShowsWatched;
  final int totalHours;
  final List<String> topGenres;

  const UserStats({
    required this.moviesWatched,
    required this.tvShowsWatched,
    required this.totalHours,
    required this.topGenres,
  });

  factory UserStats.empty() {
    return const UserStats(
      moviesWatched: 0,
      tvShowsWatched: 0,
      totalHours: 0,
      topGenres: [],
    );
  }

  UserStats copyWith({
    int? moviesWatched,
    int? tvShowsWatched,
    int? totalHours,
    List<String>? topGenres,
  }) {
    return UserStats(
      moviesWatched: moviesWatched ?? this.moviesWatched,
      tvShowsWatched: tvShowsWatched ?? this.tvShowsWatched,
      totalHours: totalHours ?? this.totalHours,
      topGenres: topGenres ?? this.topGenres,
    );
  }
}

/// Specialized dashboard variants for different contexts
class CompactStatsDashboard extends StatelessWidget {
  final UserStats stats;
  final VoidCallback? onTap;

  const CompactStatsDashboard({super.key, required this.stats, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cinematicGold.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCompactStat(
              'Movies',
              stats.moviesWatched,
              AppColors.cinematicRed,
            ),
            _buildDivider(),
            _buildCompactStat(
              'Shows',
              stats.tvShowsWatched,
              AppColors.cinematicBlue,
            ),
            _buildDivider(),
            _buildCompactStat(
              'Hours',
              stats.totalHours,
              AppColors.cinematicGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat(String label, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: AppTypography.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
    );
  }
}
