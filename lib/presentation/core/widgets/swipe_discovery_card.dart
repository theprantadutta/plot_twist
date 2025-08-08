import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../app_animations.dart';

/// Enhanced swipe discovery card for content discovery interface
/// Features poster image, gradient overlay, rating display, and genre tags
class SwipeDiscoveryCard extends StatefulWidget {
  final Map<String, dynamic> movie;
  final VoidCallback? onTap;
  final double swipeProgress;
  final bool showSwipeOverlays;
  final EdgeInsetsGeometry? margin;

  const SwipeDiscoveryCard({
    super.key,
    required this.movie,
    this.onTap,
    this.swipeProgress = 0.0,
    this.showSwipeOverlays = true,
    this.margin,
  });

  @override
  State<SwipeDiscoveryCard> createState() => _SwipeDiscoveryCardState();
}

class _SwipeDiscoveryCardState extends State<SwipeDiscoveryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
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

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: MotionPresets.scaleIn.curve,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posterPath = widget.movie['poster_path'];
    final title = widget.movie['title'] ?? widget.movie['name'] ?? 'No Title';
    final voteAverage =
        (widget.movie['vote_average'] as num?)?.toDouble() ?? 0.0;
    final releaseYear =
        widget.movie['release_date']?.substring(0, 4) ??
        widget.movie['first_air_date']?.substring(0, 4) ??
        'N/A';
    final genres = _extractGenres(widget.movie);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin:
                    widget.margin ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    _triggerHapticFeedback();
                    widget.onTap?.call();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: AppColors.cinematicGold.withValues(alpha: 0.1),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Poster Image
                            _buildPosterImage(posterPath),

                            // Gradient Overlay
                            _buildGradientOverlay(),

                            // Swipe Action Overlays
                            if (widget.showSwipeOverlays) ...[
                              _buildSwipeOverlay(
                                isLike: true,
                                opacity: widget.swipeProgress.clamp(0.0, 1.0),
                              ),
                              _buildSwipeOverlay(
                                isLike: false,
                                opacity: (-widget.swipeProgress).clamp(
                                  0.0,
                                  1.0,
                                ),
                              ),
                            ],

                            // Content Overlay
                            _buildContentOverlay(
                              title: title,
                              voteAverage: voteAverage,
                              releaseYear: releaseYear,
                              genres: genres,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPosterImage(String? posterPath) {
    if (posterPath == null) {
      return Container(
        decoration: BoxDecoration(gradient: AppColors.cardGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.movie_outlined,
                size: 64,
                color: AppColors.darkTextSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'No Image',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w500$posterPath',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(gradient: AppColors.cardGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.cinematicGold,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading...',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: BoxDecoration(gradient: AppColors.cardGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: AppColors.darkTextSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Image not available',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Color(0x66000000),
            Color(0xCC000000),
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildSwipeOverlay({required bool isLike, required double opacity}) {
    if (opacity <= 0.0) return const SizedBox.shrink();

    final color = isLike ? AppColors.darkSuccessGreen : AppColors.darkErrorRed;
    final icon = isLike ? Icons.favorite_rounded : Icons.close_rounded;
    final text = isLike ? 'LIKE' : 'PASS';
    final angle = isLike ? -0.2 : 0.2;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: opacity * 0.2),
        ),
        child: Center(
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 4),
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: AppTypography.labelLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentOverlay({
    required String title,
    required double voteAverage,
    required String releaseYear,
    required List<String> genres,
  }) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Rating and Year Row
            Row(
              children: [
                // Rating with Star
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.getRatingColor(voteAverage),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        voteAverage.toStringAsFixed(1),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.darkTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Year
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    releaseYear,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // Genre Tags
            if (genres.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: genres.take(3).map((genre) {
                  final genreColor =
                      AppColors.genreColors[genre] ?? AppColors.cinematicPurple;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: genreColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: genreColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      genre,
                      style: AppTypography.genreTag.copyWith(
                        color: genreColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _extractGenres(Map<String, dynamic> movie) {
    // This is a simplified genre extraction
    // In a real app, you'd map genre_ids to actual genre names
    final genreIds = movie['genre_ids'] as List<dynamic>? ?? [];

    // Map common genre IDs to names (simplified)
    const genreMap = {
      28: 'Action',
      12: 'Adventure',
      16: 'Animation',
      35: 'Comedy',
      80: 'Crime',
      99: 'Documentary',
      18: 'Drama',
      10751: 'Family',
      14: 'Fantasy',
      36: 'History',
      27: 'Horror',
      10402: 'Music',
      9648: 'Mystery',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'TV Movie',
      53: 'Thriller',
      10752: 'War',
      37: 'Western',
    };

    return genreIds
        .cast<int>()
        .map((id) => genreMap[id])
        .where((genre) => genre != null)
        .cast<String>()
        .toList();
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }
}
