import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Enhanced detail page hero section with sticky headers and video integration
class EnhancedDetailHeroSection extends StatefulWidget {
  final Map<String, dynamic> media;
  final String? trailerKey;
  final VoidCallback? onPlayTrailer;
  final VoidCallback? onAddToWatchlist;
  final VoidCallback? onMarkAsFavorite;
  final VoidCallback? onRate;
  final bool isInWatchlist;
  final bool isFavorite;
  final double? userRating;
  final ScrollController? scrollController;

  const EnhancedDetailHeroSection({
    super.key,
    required this.media,
    this.trailerKey,
    this.onPlayTrailer,
    this.onAddToWatchlist,
    this.onMarkAsFavorite,
    this.onRate,
    this.isInWatchlist = false,
    this.isFavorite = false,
    this.userRating,
    this.scrollController,
  });

  @override
  State<EnhancedDetailHeroSection> createState() =>
      _EnhancedDetailHeroSectionState();
}

class _EnhancedDetailHeroSectionState extends State<EnhancedDetailHeroSection>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _stickyHeaderController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _stickyHeaderOpacity;

  YoutubePlayerController? _youtubeController;
  bool _isTrailerPlaying = false;
  bool _showStickyHeader = false;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
    _initializeTrailer();

    // Start hero animations
    _heroAnimationController.forward();
  }

  void _setupAnimations() {
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _stickyHeaderController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _heroAnimationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _stickyHeaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stickyHeaderController, curve: Curves.easeInOut),
    );
  }

  void _setupScrollListener() {
    widget.scrollController?.addListener(() {
      final offset = widget.scrollController?.offset ?? 0.0;
      setState(() {
        _scrollOffset = offset;
        _showStickyHeader = offset > 300;
      });

      if (_showStickyHeader &&
          _stickyHeaderController.status != AnimationStatus.forward) {
        _stickyHeaderController.forward();
      } else if (!_showStickyHeader &&
          _stickyHeaderController.status != AnimationStatus.reverse) {
        _stickyHeaderController.reverse();
      }
    });
  }

  void _initializeTrailer() {
    if (widget.trailerKey != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.trailerKey!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          captionLanguage: 'en',
        ),
      );
    }
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _stickyHeaderController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [_buildHeroSection(), _buildStickyHeader()]);
  }

  Widget _buildHeroSection() {
    final backdropPath = widget.media['backdrop_path'];
    final posterPath = widget.media['poster_path'];
    final title = widget.media['title'] ?? widget.media['name'] ?? 'No Title';
    final overview = widget.media['overview'] ?? '';
    final releaseDate =
        widget.media['release_date'] ?? widget.media['first_air_date'] ?? '';
    final voteAverage =
        (widget.media['vote_average'] as num?)?.toDouble() ?? 0.0;
    final runtime =
        widget.media['runtime'] ?? widget.media['episode_run_time']?.first ?? 0;

    return SizedBox(
      height: 600,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop Image with Parallax Effect
          _buildBackdropImage(backdropPath),

          // Gradient Overlay
          _buildGradientOverlay(),

          // Trailer Video Overlay
          if (_isTrailerPlaying && _youtubeController != null)
            _buildTrailerOverlay(),

          // Content
          _buildHeroContent(
            title,
            overview,
            releaseDate,
            voteAverage,
            runtime,
            posterPath,
          ),

          // Back Button
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildBackdropImage(String? backdropPath) {
    if (backdropPath == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkSurface, AppColors.darkBackground],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _scrollOffset * 0.5), // Parallax effect
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Image.network(
              'https://image.tmdb.org/t/p/w1280$backdropPath',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.darkSurface,
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.darkSurface, AppColors.darkBackground],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.darkBackground.withValues(alpha: 0.3),
            AppColors.darkBackground.withValues(alpha: 0.7),
            AppColors.darkBackground,
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildTrailerOverlay() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.cinematicGold,
              progressColors: ProgressBarColors(
                playedColor: AppColors.cinematicGold,
                handleColor: AppColors.cinematicGold,
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isTrailerPlaying = false;
                });
                _youtubeController?.pause();
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroContent(
    String title,
    String overview,
    String releaseDate,
    double voteAverage,
    int runtime,
    String? posterPath,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),

          // Movie Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Poster
              if (posterPath != null)
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500$posterPath',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(width: 20),

              // Title and Info
              Expanded(
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _slideAnimation.value.dx * 100,
                        _slideAnimation.value.dy * 100,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              title,
                              style: AppTypography.headlineLarge.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 12),

                            // Metadata Row
                            _buildMetadataRow(
                              releaseDate,
                              runtime,
                              voteAverage,
                            ),

                            const SizedBox(height: 16),

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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    String releaseDate,
    int runtime,
    double voteAverage,
  ) {
    return Row(
      children: [
        // Release Year
        if (releaseDate.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              releaseDate.split('-').first,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        if (releaseDate.isNotEmpty) const SizedBox(width: 8),

        // Runtime
        if (runtime > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${runtime}min',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        if (runtime > 0) const SizedBox(width: 8),

        // Rating
        if (voteAverage > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.getRatingColor(
                voteAverage,
              ).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.getRatingColor(
                  voteAverage,
                ).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.getRatingColor(voteAverage),
                ),
                const SizedBox(width: 4),
                Text(
                  voteAverage.toStringAsFixed(1),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.getRatingColor(voteAverage),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Row(
            children: [
              // Play Trailer Button
              if (widget.trailerKey != null)
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (_youtubeController != null) {
                        setState(() {
                          _isTrailerPlaying = true;
                        });
                        _youtubeController!.play();
                      } else {
                        widget.onPlayTrailer?.call();
                      }
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text('Play Trailer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cinematicGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              const SizedBox(width: 12),

              // Watchlist Button
              _buildActionButton(
                icon: widget.isInWatchlist
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                isActive: widget.isInWatchlist,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onAddToWatchlist?.call();
                },
              ),

              const SizedBox(width: 8),

              // Favorite Button
              _buildActionButton(
                icon: widget.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                isActive: widget.isFavorite,
                color: AppColors.cinematicRed,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onMarkAsFavorite?.call();
                },
              ),

              const SizedBox(width: 8),

              // Rate Button
              _buildActionButton(
                icon: Icons.star_outline_rounded,
                isActive: widget.userRating != null,
                color: AppColors.cinematicGold,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onRate?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    Color? color,
  }) {
    final buttonColor = color ?? AppColors.cinematicBlue;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isActive ? buttonColor : buttonColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: buttonColor.withValues(alpha: 0.5)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isActive ? Colors.white : buttonColor,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 50,
      left: 20,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStickyHeader() {
    if (!_showStickyHeader) return const SizedBox.shrink();

    final title = widget.media['title'] ?? widget.media['name'] ?? 'No Title';
    final voteAverage =
        (widget.media['vote_average'] as num?)?.toDouble() ?? 0.0;

    return AnimatedBuilder(
      animation: _stickyHeaderOpacity,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: _stickyHeaderOpacity.value,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.darkBackground.withValues(alpha: 0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Title and Rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (voteAverage > 0)
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: AppColors.getRatingColor(
                                      voteAverage,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    voteAverage.toStringAsFixed(1),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.getRatingColor(
                                        voteAverage,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Quick Actions
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              widget.onAddToWatchlist?.call();
                            },
                            icon: Icon(
                              widget.isInWatchlist
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_rounded,
                              color: widget.isInWatchlist
                                  ? AppColors.cinematicBlue
                                  : AppColors.darkTextSecondary,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              widget.onMarkAsFavorite?.call();
                            },
                            icon: Icon(
                              widget.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              color: widget.isFavorite
                                  ? AppColors.cinematicRed
                                  : AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
