import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Interactive elements section with add-to-list, rating, and feedback functionality
class InteractiveElementsSection extends ConsumerStatefulWidget {
  final Map<String, dynamic> media;
  final String mediaType;

  const InteractiveElementsSection({
    super.key,
    required this.media,
    required this.mediaType,
  });

  @override
  ConsumerState<InteractiveElementsSection> createState() =>
      _InteractiveElementsSectionState();
}

class _InteractiveElementsSectionState
    extends ConsumerState<InteractiveElementsSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _ratingAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isInWatchlist = false;
  bool _isInFavorites = false;
  double _userRating = 0.0;
  bool _showRatingSuccess = false;
  bool _showAddToListSuccess = false;

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

    _ratingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
        parent: _ratingAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ratingAnimationController.dispose();
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
              margin: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildRatingSection(),
                  const SizedBox(height: 24),
                  _buildSimilarContentSection(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Take Action',
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildAddToWatchlistButton()),
          const SizedBox(width: 12),
          Expanded(child: _buildAddToFavoritesButton()),
          const SizedBox(width: 12),
          _buildMoreActionsButton(),
        ],
      ),
    );
  }

  Widget _buildAddToWatchlistButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: ElevatedButton.icon(
        onPressed: _toggleWatchlist,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _isInWatchlist ? Icons.check_rounded : Icons.add_rounded,
            key: ValueKey(_isInWatchlist),
            color: _isInWatchlist ? Colors.black : Colors.white,
          ),
        ),
        label: Text(
          _isInWatchlist ? 'In Watchlist' : 'Add to Watchlist',
          style: AppTypography.labelLarge.copyWith(
            color: _isInWatchlist ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isInWatchlist
              ? AppColors.cinematicGold
              : AppColors.darkSurface,
          foregroundColor: _isInWatchlist ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isInWatchlist
                  ? AppColors.cinematicGold
                  : AppColors.darkTextTertiary.withValues(alpha: 0.3),
            ),
          ),
          elevation: _isInWatchlist ? 4 : 0,
        ),
      ),
    );
  }

  Widget _buildAddToFavoritesButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: ElevatedButton.icon(
        onPressed: _toggleFavorites,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _isInFavorites
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            key: ValueKey(_isInFavorites),
            color: _isInFavorites ? Colors.white : AppColors.cinematicRed,
          ),
        ),
        label: Text(
          _isInFavorites ? 'Favorited' : 'Add to Favorites',
          style: AppTypography.labelLarge.copyWith(
            color: _isInFavorites ? Colors.white : AppColors.cinematicRed,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isInFavorites
              ? AppColors.cinematicRed
              : AppColors.darkSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.cinematicRed),
          ),
          elevation: _isInFavorites ? 4 : 0,
        ),
      ),
    );
  }

  Widget _buildMoreActionsButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
        ),
      ),
      child: IconButton(
        onPressed: _showMoreActions,
        icon: Icon(Icons.more_horiz_rounded, color: AppColors.darkTextPrimary),
        tooltip: 'More Actions',
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rate This ${widget.mediaType == 'movie' ? 'Movie' : 'Show'}',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_showRatingSuccess)
                AnimatedBuilder(
                  animation: _ratingAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkSuccessGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Rated!',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStarRating(),
          if (_userRating > 0) ...[
            const SizedBox(height: 12),
            Text(
              _getRatingText(_userRating),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.cinematicGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = _userRating >= starValue;
        final isHalfFilled =
            _userRating >= starValue - 0.5 && _userRating < starValue;

        return GestureDetector(
          onTap: () => _setRating(starValue.toDouble()),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Icon(
                isFilled || isHalfFilled
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: isFilled || isHalfFilled
                    ? AppColors.cinematicGold
                    : AppColors.darkTextTertiary,
                size: 32,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSimilarContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'More Like This',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: _viewAllSimilar,
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
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _getSimilarContent().length,
            itemBuilder: (context, index) {
              final item = _getSimilarContent()[index];
              return _buildSimilarContentCard(
                item,
                Duration(milliseconds: index * 100),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarContentCard(Map<String, dynamic> item, Duration delay) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: TweenAnimationBuilder<double>(
        duration: MotionPresets.slideUp.duration + delay,
        tween: Tween(begin: 0.0, end: 1.0),
        curve: MotionPresets.slideUp.curve,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: GestureDetector(
          onTap: () => _navigateToDetail(item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.darkSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Placeholder for poster image
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.cinematicBlue.withValues(alpha: 0.3),
                              AppColors.cinematicPurple.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.movie_rounded,
                          color: AppColors.darkTextSecondary,
                          size: 48,
                        ),
                      ),

                      // Rating badge
                      Positioned(
                        top: 8,
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
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: AppColors.cinematicGold,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${item['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.darkTextPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
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

              const SizedBox(height: 12),

              // Title
              Text(
                item['title'] ?? 'Unknown Title',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Year and Genre
              Text(
                '${item['year'] ?? 'Unknown'} • ${item['genre'] ?? 'Unknown'}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mock data for similar content
  List<Map<String, dynamic>> _getSimilarContent() {
    return [
      {
        'id': 1,
        'title': 'The Dark Knight Rises',
        'year': 2012,
        'genre': 'Action',
        'rating': 8.4,
        'poster_path': '/poster1.jpg',
      },
      {
        'id': 2,
        'title': 'Batman Begins',
        'year': 2005,
        'genre': 'Action',
        'rating': 8.2,
        'poster_path': '/poster2.jpg',
      },
      {
        'id': 3,
        'title': 'Joker',
        'year': 2019,
        'genre': 'Drama',
        'rating': 8.4,
        'poster_path': '/poster3.jpg',
      },
      {
        'id': 4,
        'title': 'Inception',
        'year': 2010,
        'genre': 'Sci-Fi',
        'rating': 8.8,
        'poster_path': '/poster4.jpg',
      },
      {
        'id': 5,
        'title': 'Interstellar',
        'year': 2014,
        'genre': 'Sci-Fi',
        'rating': 8.6,
        'poster_path': '/poster5.jpg',
      },
    ];
  }

  void _toggleWatchlist() {
    HapticFeedback.lightImpact();
    setState(() {
      _isInWatchlist = !_isInWatchlist;
      _showAddToListSuccess = _isInWatchlist;
    });

    if (_isInWatchlist) {
      _showSuccessSnackBar('Added to Watchlist');
    } else {
      _showSuccessSnackBar('Removed from Watchlist');
    }

    // Hide success indicator after delay
    if (_showAddToListSuccess) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showAddToListSuccess = false;
          });
        }
      });
    }
  }

  void _toggleFavorites() {
    HapticFeedback.lightImpact();
    setState(() {
      _isInFavorites = !_isInFavorites;
    });

    if (_isInFavorites) {
      _showSuccessSnackBar('Added to Favorites');
    } else {
      _showSuccessSnackBar('Removed from Favorites');
    }
  }

  void _setRating(double rating) {
    HapticFeedback.selectionClick();
    setState(() {
      _userRating = rating;
      _showRatingSuccess = true;
    });

    _ratingAnimationController.forward();
    _showSuccessSnackBar('Rating saved: ${rating.toInt()}/5 stars');

    // Hide success indicator after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showRatingSuccess = false;
        });
        _ratingAnimationController.reset();
      }
    });
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Poor';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  void _showMoreActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildMoreActionsSheet(),
    );
  }

  Widget _buildMoreActionsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkTextTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'More Actions',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildActionItem(
                  icon: Icons.playlist_add_rounded,
                  title: 'Add to Custom List',
                  onTap: _addToCustomList,
                ),
                _buildActionItem(
                  icon: Icons.share_rounded,
                  title: 'Share',
                  onTap: _shareContent,
                ),
                _buildActionItem(
                  icon: Icons.download_rounded,
                  title: 'Download for Offline',
                  onTap: _downloadContent,
                ),
                _buildActionItem(
                  icon: Icons.report_rounded,
                  title: 'Report Issue',
                  onTap: _reportIssue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.darkTextPrimary, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.darkSuccessGreen),
            const SizedBox(width: 12),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    // Navigate to detail page for similar content
    // TODO: Implement navigation to detail page
    _showSuccessSnackBar('Opening ${item['title']}...');
  }

  void _viewAllSimilar() {
    // Navigate to similar content list
    // TODO: Implement navigation to similar content list
    _showSuccessSnackBar('Loading similar content...');
  }

  void _addToCustomList() {
    _showSuccessSnackBar('Added to custom list');
  }

  void _shareContent() {
    _showSuccessSnackBar('Content shared');
  }

  void _downloadContent() {
    _showSuccessSnackBar('Download started');
  }

  void _reportIssue() {
    _showSuccessSnackBar('Issue reported');
  }
}
