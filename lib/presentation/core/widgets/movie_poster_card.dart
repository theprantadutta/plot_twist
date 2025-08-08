import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../app_animations.dart';

/// Enhanced movie poster card for library sections
/// Features poster image, rating overlay, and smooth animations
class MoviePosterCard extends StatefulWidget {
  final Map<String, dynamic> movie;
  final VoidCallback? onTap;
  final Duration animationDelay;
  final bool showRating;
  final bool showTitle;
  final double? width;
  final double? aspectRatio;

  const MoviePosterCard({
    super.key,
    required this.movie,
    this.onTap,
    this.animationDelay = Duration.zero,
    this.showRating = true,
    this.showTitle = false,
    this.width,
    this.aspectRatio = 2 / 3,
  });

  @override
  State<MoviePosterCard> createState() => _MoviePosterCardState();
}

class _MoviePosterCardState extends State<MoviePosterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Delay animation start based on index
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: () {
                    _triggerHapticFeedback();
                    widget.onTap?.call();
                  },
                  child: AnimatedContainer(
                    duration: MotionPresets.hover.duration,
                    curve: MotionPresets.hover.curve,
                    transform: Matrix4.identity()
                      ..scale(_isHovered ? 1.05 : 1.0),
                    child: Container(
                      width: widget.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: _isHovered ? 0.4 : 0.3,
                            ),
                            blurRadius: _isHovered ? 15 : 10,
                            offset: Offset(0, _isHovered ? 8 : 5),
                          ),
                          if (_isHovered)
                            BoxShadow(
                              color: AppColors.cinematicGold.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Poster Image
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: widget.aspectRatio ?? 2 / 3,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildPosterImage(posterPath),

                                    // Rating Overlay
                                    if (widget.showRating && voteAverage > 0)
                                      _buildRatingOverlay(voteAverage),
                                  ],
                                ),
                              ),
                            ),

                            // Title (if enabled)
                            if (widget.showTitle) _buildTitleSection(title),
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
                size: 48,
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
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.cinematicGold,
                strokeWidth: 2,
              ),
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
                  size: 32,
                  color: AppColors.darkTextSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  'Image Error',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingOverlay(double voteAverage) {
    final ratingColor = AppColors.getRatingColor(voteAverage);

    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.darkBackground.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: ratingColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Progress Ring
            CircularProgressIndicator(
              value: voteAverage / 10.0,
              backgroundColor: AppColors.darkTextTertiary.withValues(
                alpha: 0.3,
              ),
              color: ratingColor,
              strokeWidth: 2.5,
            ),

            // Rating Text
            Center(
              child: Text(
                voteAverage.toStringAsFixed(1),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Text(
        title,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }
}

/// Specialized poster cards for different use cases
class WatchlistPosterCard extends StatelessWidget {
  final Map<String, dynamic> movie;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final Duration animationDelay;

  const WatchlistPosterCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onRemove,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MoviePosterCard(
          movie: movie,
          onTap: onTap,
          animationDelay: animationDelay,
          showRating: true,
        ),

        // Remove Button
        if (onRemove != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.darkErrorRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class WatchedPosterCard extends StatelessWidget {
  final Map<String, dynamic> movie;
  final VoidCallback? onTap;
  final Duration animationDelay;
  final bool isCompleted;

  const WatchedPosterCard({
    super.key,
    required this.movie,
    this.onTap,
    this.animationDelay = Duration.zero,
    this.isCompleted = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MoviePosterCard(
          movie: movie,
          onTap: onTap,
          animationDelay: animationDelay,
          showRating: true,
        ),

        // Completion Overlay
        if (isCompleted)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.darkSuccessGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
