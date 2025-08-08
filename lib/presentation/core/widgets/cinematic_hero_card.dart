import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../app_animations.dart';

/// Cinematic hero card component for showcasing featured content
/// Displays backdrop image with gradient overlay and action buttons
class CinematicHeroCard extends StatefulWidget {
  final Map<String, dynamic> movie;
  final double height;
  final VoidCallback? onPlayTrailer;
  final VoidCallback? onAddToWatchlist;
  final VoidCallback? onTap;
  final bool showActions;
  final EdgeInsetsGeometry? margin;

  const CinematicHeroCard({
    super.key,
    required this.movie,
    this.height = 400,
    this.onPlayTrailer,
    this.onAddToWatchlist,
    this.onTap,
    this.showActions = true,
    this.margin,
  });

  @override
  State<CinematicHeroCard> createState() => _CinematicHeroCardState();
}

class _CinematicHeroCardState extends State<CinematicHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backdropPath = widget.movie['backdrop_path'];
    final title = widget.movie['title'] ?? widget.movie['name'] ?? 'No Title';
    final overview = widget.movie['overview'] ?? 'No overview available.';
    final voteAverage =
        (widget.movie['vote_average'] as num?)?.toDouble() ?? 0.0;
    final releaseYear =
        widget.movie['release_date']?.substring(0, 4) ??
        widget.movie['first_air_date']?.substring(0, 4) ??
        'N/A';

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              height: widget.height,
              margin: widget.margin ?? const EdgeInsets.all(16),
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedContainer(
                    duration: MotionPresets.hover.duration,
                    curve: MotionPresets.hover.curve,
                    transform: Matrix4.identity()
                      ..scale(_isHovered ? 1.02 : 1.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: _isHovered ? 0.4 : 0.3,
                          ),
                          blurRadius: _isHovered ? 25 : 20,
                          offset: Offset(0, _isHovered ? 12 : 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Backdrop Image
                          _buildBackdropImage(backdropPath),

                          // Gradient Overlay
                          _buildGradientOverlay(),

                          // Content Overlay
                          _buildContentOverlay(
                            title: title,
                            overview: overview,
                            voteAverage: voteAverage,
                            releaseYear: releaseYear,
                          ),
                        ],
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

  Widget _buildBackdropImage(String? backdropPath) {
    if (backdropPath == null) {
      return Container(
        decoration: BoxDecoration(gradient: AppColors.cardGradient),
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            size: 64,
            color: AppColors.darkTextSecondary,
          ),
        ),
      );
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w1280$backdropPath',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(gradient: AppColors.cardGradient),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.cinematicGold,
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
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
    );
  }

  Widget _buildContentOverlay({
    required String title,
    required String overview,
    required double voteAverage,
    required String releaseYear,
  }) {
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
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.darkTextPrimary,
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
                  color: AppColors.getRatingColor(voteAverage),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  voteAverage.toStringAsFixed(1),
                  style: AppTypography.rating.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.darkTextSecondary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  releaseYear,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Overview
            Text(
              overview,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            if (widget.showActions) ...[
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Play Trailer Button
        Expanded(
          flex: 2,
          child: _buildActionButton(
            onPressed: widget.onPlayTrailer,
            icon: Icons.play_arrow_rounded,
            label: 'Watch Trailer',
            isPrimary: true,
          ),
        ),

        const SizedBox(width: 12),

        // Add to Watchlist Button
        Expanded(
          child: _buildActionButton(
            onPressed: widget.onAddToWatchlist,
            icon: Icons.add_rounded,
            label: 'Watchlist',
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return AnimatedContainer(
      duration: MotionPresets.buttonPress.duration,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinematicRed,
                foregroundColor: AppColors.darkTextPrimary,
                textStyle: AppTypography.button,
                elevation: 4,
                shadowColor: AppColors.cinematicRed.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkTextPrimary,
                textStyle: AppTypography.button,
                side: BorderSide(
                  color: AppColors.darkTextPrimary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
    );
  }
}
