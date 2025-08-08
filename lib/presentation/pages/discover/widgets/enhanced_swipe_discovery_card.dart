import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Enhanced swipe discovery card with cinematic styling and smooth animations
class EnhancedSwipeDiscoveryCard extends StatefulWidget {
  final Map<String, dynamic> movie;
  final MediaType mediaType;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onSuperLike;
  final VoidCallback? onTap;
  final bool showActions;
  final double cardHeight;

  const EnhancedSwipeDiscoveryCard({
    super.key,
    required this.movie,
    required this.mediaType,
    this.onLike,
    this.onDislike,
    this.onSuperLike,
    this.onTap,
    this.showActions = true,
    this.cardHeight = 600,
  });

  @override
  State<EnhancedSwipeDiscoveryCard> createState() =>
      _EnhancedSwipeDiscoveryCardState();
}

class _EnhancedSwipeDiscoveryCardState extends State<EnhancedSwipeDiscoveryCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _likeController;
  late AnimationController _dislikeController;
  late AnimationController _superLikeController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _likeAnimation;
  late Animation<double> _dislikeAnimation;
  late Animation<double> _superLikeAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fadeController.forward();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _likeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _dislikeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _superLikeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _likeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );

    _dislikeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dislikeController, curve: Curves.elasticOut),
    );

    _superLikeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _superLikeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _likeController.dispose();
    _dislikeController.dispose();
    _superLikeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) => _handleTapDown(),
          onTapUp: (_) => _handleTapUp(),
          onTapCancel: () => _handleTapUp(),
          onTap: widget.onTap,
          child: Container(
            height: widget.cardHeight,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.cinematicGold.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Poster Image
                  _buildPosterImage(),

                  // Gradient Overlay
                  _buildGradientOverlay(),

                  // Content Overlay
                  _buildContentOverlay(),

                  // Action Overlays
                  if (widget.showActions) ...[
                    _buildLikeOverlay(),
                    _buildDislikeOverlay(),
                    _buildSuperLikeOverlay(),
                  ],

                  // Action Buttons
                  if (widget.showActions) _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosterImage() {
    final posterPath = widget.movie['poster_path'] as String?;
    final backdropPath = widget.movie['backdrop_path'] as String?;

    // Use backdrop for better card display, fallback to poster
    final imagePath = backdropPath ?? posterPath;

    if (imagePath == null) {
      return Container(
        color: AppColors.darkSurface,
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            size: 64,
            color: AppColors.darkTextSecondary,
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Image.network(
        'https://image.tmdb.org/t/p/w500$imagePath',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.darkSurface,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 64,
                color: AppColors.darkTextSecondary,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.darkSurface,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.cinematicGold,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContentOverlay() {
    final title = widget.movie['title'] ?? widget.movie['name'] ?? 'Unknown';
    final overview = widget.movie['overview'] ?? '';
    final voteAverage =
        (widget.movie['vote_average'] as num?)?.toDouble() ?? 0.0;
    final releaseDate =
        widget.movie['release_date'] ?? widget.movie['first_air_date'] ?? '';
    final genreIds =
        (widget.movie['genre_ids'] as List<dynamic>?)?.cast<int>() ?? [];

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Rating and Year
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppColors.cinematicGold,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  voteAverage.toStringAsFixed(1),
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.cinematicGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                if (releaseDate.isNotEmpty) ...[
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    releaseDate.split('-').first,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Overview
            if (overview.isNotEmpty) ...[
              Text(
                overview,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Genre Tags
            if (genreIds.isNotEmpty) _buildGenreTags(genreIds),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreTags(List<int> genreIds) {
    // Simple genre mapping - in a real app, this would come from TMDB API
    final genreMap = {
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

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: genreIds.take(3).map((genreId) {
        final genreName = genreMap[genreId] ?? 'Unknown';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.cinematicGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.cinematicGold.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Text(
            genreName,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.cinematicGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLikeOverlay() {
    return AnimatedBuilder(
      animation: _likeAnimation,
      builder: (context, child) {
        if (_likeAnimation.value == 0) return const SizedBox.shrink();

        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.3 * _likeAnimation.value),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Transform.scale(
                scale: _likeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDislikeOverlay() {
    return AnimatedBuilder(
      animation: _dislikeAnimation,
      builder: (context, child) {
        if (_dislikeAnimation.value == 0) return const SizedBox.shrink();

        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(
                alpha: 0.3 * _dislikeAnimation.value,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Transform.scale(
                scale: _dislikeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuperLikeOverlay() {
    return AnimatedBuilder(
      animation: _superLikeAnimation,
      builder: (context, child) {
        if (_superLikeAnimation.value == 0) return const SizedBox.shrink();

        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cinematicGold.withValues(
                alpha: 0.3 * _superLikeAnimation.value,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Transform.scale(
                scale: _superLikeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cinematicGold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cinematicGold.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.black,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Super Like Button
          _buildActionButton(
            icon: Icons.star_rounded,
            color: AppColors.cinematicGold,
            onPressed: () => _handleSuperLike(),
          ),
          const SizedBox(height: 12),

          // Like Button
          _buildActionButton(
            icon: Icons.favorite_rounded,
            color: Colors.green,
            onPressed: () => _handleLike(),
          ),
          const SizedBox(height: 12),

          // Dislike Button
          _buildActionButton(
            icon: Icons.close_rounded,
            color: Colors.red,
            onPressed: () => _handleDislike(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  void _handleTapDown() {
    setState(() {
      _isPressed = true;
    });
    _scaleController.forward();
  }

  void _handleTapUp() {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }

  void _handleLike() {
    HapticFeedback.lightImpact();
    _likeController.forward().then((_) {
      _likeController.reset();
    });
    widget.onLike?.call();
  }

  void _handleDislike() {
    HapticFeedback.lightImpact();
    _dislikeController.forward().then((_) {
      _dislikeController.reset();
    });
    widget.onDislike?.call();
  }

  void _handleSuperLike() {
    HapticFeedback.mediumImpact();
    _superLikeController.forward().then((_) {
      _superLikeController.reset();
    });
    widget.onSuperLike?.call();
  }
}
