import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../app_animations.dart';
import 'movie_poster_card.dart';

/// Enhanced library section card for organizing content collections
/// Features horizontal scrolling movie list with engaging empty states
class LibrarySectionCard extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> movies;
  final String emptyStateMessage;
  final IconData emptyStateIcon;
  final VoidCallback? onViewAll;
  final VoidCallback? onEmptyAction;
  final String? emptyActionText;
  final bool showViewAll;
  final EdgeInsetsGeometry? margin;
  final double cardHeight;

  const LibrarySectionCard({
    super.key,
    required this.title,
    required this.movies,
    this.emptyStateMessage = 'No items found',
    this.emptyStateIcon = Icons.movie_outlined,
    this.onViewAll,
    this.onEmptyAction,
    this.emptyActionText,
    this.showViewAll = true,
    this.margin,
    this.cardHeight = 220,
  });

  @override
  State<LibrarySectionCard> createState() => _LibrarySectionCardState();
}

class _LibrarySectionCardState extends State<LibrarySectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: widget.cardHeight,
                    child: widget.movies.isEmpty
                        ? _buildEmptyState()
                        : _buildMovieList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with movie count
          Row(
            children: [
              Text(
                widget.title,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
              if (widget.movies.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cinematicGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.cinematicGold.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${widget.movies.length}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.cinematicGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // View All Button
          if (widget.showViewAll && widget.movies.isNotEmpty)
            GestureDetector(
              onTap: widget.onViewAll,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.cinematicGold.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.cinematicGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.cinematicGold,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovieList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.movies.length,
      itemBuilder: (context, index) {
        final movie = widget.movies[index];
        return Container(
          width: 140,
          margin: EdgeInsets.only(
            right: index < widget.movies.length - 1 ? 12 : 0,
          ),
          child: MoviePosterCard(
            movie: movie,
            animationDelay: Duration(milliseconds: index * 100),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Empty State Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.emptyStateIcon,
                size: 24,
                color: AppColors.darkTextSecondary,
              ),
            ),

            const SizedBox(height: 12),

            // Empty State Message
            Text(
              widget.emptyStateMessage,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Action Button (if provided)
            if (widget.onEmptyAction != null &&
                widget.emptyActionText != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: widget.onEmptyAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cinematicGold,
                  foregroundColor: AppColors.darkBackground,
                  textStyle: AppTypography.labelMedium,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(widget.emptyActionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specialized library section cards for different content types
class WatchlistSectionCard extends StatelessWidget {
  final List<Map<String, dynamic>> movies;
  final VoidCallback? onViewAll;
  final VoidCallback? onBrowseMovies;

  const WatchlistSectionCard({
    super.key,
    required this.movies,
    this.onViewAll,
    this.onBrowseMovies,
  });

  @override
  Widget build(BuildContext context) {
    return LibrarySectionCard(
      title: 'My Watchlist',
      movies: movies,
      emptyStateMessage:
          'Your watchlist is empty\nDiscover movies to add them here',
      emptyStateIcon: Icons.bookmark_outline_rounded,
      emptyActionText: 'Browse Movies',
      onViewAll: onViewAll,
      onEmptyAction: onBrowseMovies,
    );
  }
}

class FavoritesSectionCard extends StatelessWidget {
  final List<Map<String, dynamic>> movies;
  final VoidCallback? onViewAll;
  final VoidCallback? onDiscoverMovies;

  const FavoritesSectionCard({
    super.key,
    required this.movies,
    this.onViewAll,
    this.onDiscoverMovies,
  });

  @override
  Widget build(BuildContext context) {
    return LibrarySectionCard(
      title: 'Favorites',
      movies: movies,
      emptyStateMessage: 'No favorites yet\nMark movies you love as favorites',
      emptyStateIcon: Icons.favorite_outline_rounded,
      emptyActionText: 'Discover Movies',
      onViewAll: onViewAll,
      onEmptyAction: onDiscoverMovies,
    );
  }
}

class WatchedSectionCard extends StatelessWidget {
  final List<Map<String, dynamic>> movies;
  final VoidCallback? onViewAll;
  final VoidCallback? onStartWatching;

  const WatchedSectionCard({
    super.key,
    required this.movies,
    this.onViewAll,
    this.onStartWatching,
  });

  @override
  Widget build(BuildContext context) {
    return LibrarySectionCard(
      title: 'Recently Watched',
      movies: movies,
      emptyStateMessage: 'No watched movies yet\nStart your cinematic journey',
      emptyStateIcon: Icons.history_rounded,
      emptyActionText: 'Start Watching',
      onViewAll: onViewAll,
      onEmptyAction: onStartWatching,
    );
  }
}

class CustomListSectionCard extends StatelessWidget {
  final String listName;
  final List<Map<String, dynamic>> movies;
  final VoidCallback? onViewAll;
  final VoidCallback? onAddMovies;

  const CustomListSectionCard({
    super.key,
    required this.listName,
    required this.movies,
    this.onViewAll,
    this.onAddMovies,
  });

  @override
  Widget build(BuildContext context) {
    return LibrarySectionCard(
      title: listName,
      movies: movies,
      emptyStateMessage:
          'This list is empty\nAdd movies to build your collection',
      emptyStateIcon: Icons.playlist_add_rounded,
      emptyActionText: 'Add Movies',
      onViewAll: onViewAll,
      onEmptyAction: onAddMovies,
    );
  }
}
