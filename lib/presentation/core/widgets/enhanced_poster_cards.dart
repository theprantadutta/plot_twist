import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../app_animations.dart';
import 'movie_poster_card.dart';
import 'progress_indicators.dart';

/// Enhanced watchlist poster card with progress indicators and priority cues
class EnhancedWatchlistCard extends StatefulWidget {
  final Map<String, dynamic> movie;
  final WatchPriority priority;
  final double? watchProgress;
  final Duration? estimatedRuntime;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onPriorityChange;
  final Duration animationDelay;

  const EnhancedWatchlistCard({
    super.key,
    required this.movie,
    this.priority = WatchPriority.medium,
    this.watchProgress,
    this.estimatedRuntime,
    this.onTap,
    this.onRemove,
    this.onPriorityChange,
    this.animationDelay = Duration.zero,
  });

  @override
  State<EnhancedWatchlistCard> createState() => _EnhancedWatchlistCardState();
}

class _EnhancedWatchlistCardState extends State<EnhancedWatchlistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.slideUp.duration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: MotionPresets.slideUp.curve,
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: GestureDetector(
              onLongPress: () {
                HapticFeedback.mediumImpact();
                setState(() => _showActions = !_showActions);
              },
              child: Stack(
                children: [
                  // Base Movie Card
                  MoviePosterCard(
                    movie: widget.movie,
                    onTap: widget.onTap,
                    showRating: true,
                  ),

                  // Priority Indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PriorityIndicator(
                      priority: widget.priority,
                      size: 20,
                    ),
                  ),

                  // Watch Progress (if available)
                  if (widget.watchProgress != null && widget.watchProgress! > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: WatchProgressIndicator(
                        progress: widget.watchProgress!,
                        size: 36,
                        showTime: false,
                        onTap: widget.onTap,
                      ),
                    ),

                  // Runtime Badge
                  if (widget.estimatedRuntime != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkBackground.withValues(
                            alpha: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.darkTextTertiary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Text(
                          _formatDuration(widget.estimatedRuntime!),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Quick Actions (shown on long press)
                  if (_showActions)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkBackground.withValues(
                            alpha: 0.9,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                QuickActionButton(
                                  icon: Icons.play_arrow_rounded,
                                  label: 'Watch',
                                  color: AppColors.darkSuccessGreen,
                                  onPressed: () {
                                    setState(() => _showActions = false);
                                    widget.onTap?.call();
                                  },
                                ),
                                QuickActionButton(
                                  icon: Icons.priority_high_rounded,
                                  label: 'Priority',
                                  color: widget.priority.color,
                                  isActive:
                                      widget.priority == WatchPriority.high,
                                  onPressed: () {
                                    setState(() => _showActions = false);
                                    widget.onPriorityChange?.call();
                                  },
                                ),
                                QuickActionButton(
                                  icon: Icons.remove_circle_outline_rounded,
                                  label: 'Remove',
                                  color: AppColors.cinematicRed,
                                  onPressed: () {
                                    setState(() => _showActions = false);
                                    widget.onRemove?.call();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap outside to close',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
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
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

/// Enhanced watched poster card with completion status and rating overlays
class EnhancedWatchedCard extends StatefulWidget {
  final Map<String, dynamic> movie;
  final CompletionStatus status;
  final double? userRating;
  final DateTime? watchedDate;
  final int? rewatchCount;
  final VoidCallback? onTap;
  final VoidCallback? onRate;
  final Duration animationDelay;

  const EnhancedWatchedCard({
    super.key,
    required this.movie,
    this.status = CompletionStatus.completed,
    this.userRating,
    this.watchedDate,
    this.rewatchCount,
    this.onTap,
    this.onRate,
    this.animationDelay = Duration.zero,
  });

  @override
  State<EnhancedWatchedCard> createState() => _EnhancedWatchedCardState();
}

class _EnhancedWatchedCardState extends State<EnhancedWatchedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              setState(() => _showDetails = !_showDetails);
            },
            child: Stack(
              children: [
                // Base Movie Card
                MoviePosterCard(
                  movie: widget.movie,
                  onTap: widget.onTap,
                  showRating: true,
                ),

                // Completion Status Overlay
                Positioned(
                  top: 8,
                  left: 8,
                  child: CompletionStatusOverlay(
                    status: widget.status,
                    rating: widget.userRating,
                    watchedDate: widget.watchedDate,
                    showDetails: _showDetails,
                    onTap: () => setState(() => _showDetails = !_showDetails),
                  ),
                ),

                // User Rating (if available)
                if (widget.userRating != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: RatingOverlay(
                      rating: widget.userRating!,
                      size: 36,
                      onTap: widget.onRate,
                    ),
                  ),

                // Rewatch Count Badge
                if (widget.rewatchCount != null && widget.rewatchCount! > 1)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cinematicPurple.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.cinematicPurple.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.replay_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.rewatchCount}',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Watch Date Badge (bottom left)
                if (widget.watchedDate != null && _showDetails)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.darkTextTertiary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        _formatWatchDate(widget.watchedDate!),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.darkTextPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatWatchDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

/// Enhanced favorites card with rating and favorite date
class EnhancedFavoritesCard extends StatefulWidget {
  final Map<String, dynamic> movie;
  final double? userRating;
  final DateTime? favoriteDate;
  final String? personalNote;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onEditNote;
  final Duration animationDelay;

  const EnhancedFavoritesCard({
    super.key,
    required this.movie,
    this.userRating,
    this.favoriteDate,
    this.personalNote,
    this.onTap,
    this.onRemove,
    this.onEditNote,
    this.animationDelay = Duration.zero,
  });

  @override
  State<EnhancedFavoritesCard> createState() => _EnhancedFavoritesCardState();
}

class _EnhancedFavoritesCardState extends State<EnhancedFavoritesCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heartAnimation;
  bool _showNote = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    Future.delayed(widget.animationDelay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (widget.personalNote != null) {
          HapticFeedback.mediumImpact();
          setState(() => _showNote = !_showNote);
        }
      },
      child: Stack(
        children: [
          // Base Movie Card
          MoviePosterCard(
            movie: widget.movie,
            onTap: widget.onTap,
            showRating: true,
          ),

          // Favorite Heart Icon
          Positioned(
            top: 8,
            left: 8,
            child: AnimatedBuilder(
              animation: _heartAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _heartAnimation.value,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.cinematicRed.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cinematicRed.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          ),

          // User Rating
          if (widget.userRating != null)
            Positioned(
              top: 8,
              right: 8,
              child: RatingOverlay(rating: widget.userRating!, size: 36),
            ),

          // Personal Note Indicator
          if (widget.personalNote != null)
            Positioned(
              bottom: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => setState(() => _showNote = !_showNote),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cinematicGold.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cinematicGold.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.note_rounded,
                    color: Colors.black,
                    size: 14,
                  ),
                ),
              ),
            ),

          // Favorite Date
          if (widget.favoriteDate != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.cinematicRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _formatFavoriteDate(widget.favoriteDate!),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.cinematicRed,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          // Personal Note Overlay
          if (_showNote && widget.personalNote != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: AppColors.cinematicGold,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.personalNote!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        QuickActionButton(
                          icon: Icons.edit_rounded,
                          label: 'Edit',
                          color: AppColors.cinematicGold,
                          size: 32,
                          onPressed: () {
                            setState(() => _showNote = false);
                            widget.onEditNote?.call();
                          },
                        ),
                        QuickActionButton(
                          icon: Icons.close_rounded,
                          label: 'Close',
                          color: AppColors.darkTextSecondary,
                          size: 32,
                          onPressed: () => setState(() => _showNote = false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatFavoriteDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return 'Recent';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      return '${date.year}';
    }
  }
}
