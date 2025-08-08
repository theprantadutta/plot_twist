import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appinio_swiper/appinio_swiper.dart';

import '../../../../application/discover/discover_providers.dart';
import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import 'enhanced_swipe_discovery_card.dart';

/// Card-based swipe interface with smooth animations and haptic feedback
class CardSwipeInterface extends ConsumerStatefulWidget {
  final MediaType mediaType;
  final VoidCallback? onEmpty;
  final Function(Map<String, dynamic>, String)? onSwipe;

  const CardSwipeInterface({
    super.key,
    required this.mediaType,
    this.onEmpty,
    this.onSwipe,
  });

  @override
  ConsumerState<CardSwipeInterface> createState() => _CardSwipeInterfaceState();
}

class _CardSwipeInterfaceState extends ConsumerState<CardSwipeInterface>
    with TickerProviderStateMixin {
  late AppinioSwiperController _swiperController;
  late AnimationController _stackController;
  late AnimationController _actionController;

  late Animation<double> _stackAnimation;
  late Animation<double> _actionAnimation;

  List<Map<String, dynamic>> _currentDeck = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _swiperController = AppinioSwiperController();
    _setupAnimations();
    _loadInitialDeck();
  }

  void _setupAnimations() {
    _stackController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _actionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _stackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stackController, curve: Curves.easeOutCubic),
    );

    _actionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _actionController, curve: Curves.easeOutBack),
    );
  }

  Future<void> _loadInitialDeck() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final deck = await ref.read(discoverDeckProvider.future);

      if (mounted) {
        setState(() {
          _currentDeck = deck;
          _isLoading = false;
        });

        _stackController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _stackController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_currentDeck.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Swipe Stack
        Expanded(child: _buildSwipeStack()),

        // Action Controls
        _buildActionControls(),
      ],
    );
  }

  Widget _buildSwipeStack() {
    return FadeTransition(
      opacity: _stackAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: AppinioSwiper(
          controller: _swiperController,
          cardBuilder: (context, index) {
            return EnhancedSwipeDiscoveryCard(
              movie: _currentDeck[index],
              mediaType: widget.mediaType,
              showActions: false, // Actions handled by bottom controls
              onTap: () => _handleCardTap(_currentDeck[index]),
            );
          },
          cardCount: _currentDeck.length,
          onSwipeEnd: _handleSwipeEnd,
          onEnd: _handleDeckEnd,
          // Swipe configuration
          maxAngle: 30,
          threshold: 80,
          duration: const Duration(milliseconds: 300),
          // Visual configuration
          backgroundCardCount: 2,
          backgroundCardOffset: const Offset(0, -8),
          backgroundCardScale: 0.9,
          // Swipe directions
          allowUnlimitedUnSwipe: false,
          swipeOptions: const SwipeOptions.all(),
        ),
      ),
    );
  }

  Widget _buildActionControls() {
    return AnimatedBuilder(
      animation: _actionAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _actionAnimation.value)),
          child: Opacity(
            opacity: _actionAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Dislike Button
                  _buildControlButton(
                    icon: Icons.close_rounded,
                    color: Colors.red,
                    size: 64,
                    onPressed: () => _swipeLeft(),
                  ),

                  // Super Like Button
                  _buildControlButton(
                    icon: Icons.star_rounded,
                    color: AppColors.cinematicGold,
                    size: 56,
                    onPressed: () => _swipeUp(),
                  ),

                  // Like Button
                  _buildControlButton(
                    icon: Icons.favorite_rounded,
                    color: Colors.green,
                    size: 64,
                    onPressed: () => _swipeRight(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.4),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.cinematicGold,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading amazing content...',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t load new content. Check your connection and try again.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialDeck,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinematicGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.darkTextSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: AppColors.darkTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No more content to discover',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve seen all available ${widget.mediaType == MediaType.movie ? 'movies' : 'shows'}. Check back later for more!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadInitialDeck,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cinematicGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSwipeEnd(
    int previousIndex,
    int? currentIndex,
    SwiperActivity activity,
  ) {
    if (currentIndex == null) return;

    final swipedMovie = _currentDeck[previousIndex];
    String? direction;

    switch (activity) {
      case Swipe():
        // Map the swipe direction to string
        switch (activity.direction.toString()) {
          case 'AppinioSwiperDirection.left':
            direction = 'left';
            break;
          case 'AppinioSwiperDirection.right':
            direction = 'right';
            break;
          case 'AppinioSwiperDirection.top':
            direction = 'up';
            break;
          case 'AppinioSwiperDirection.bottom':
            direction = 'down';
            break;
        }
        break;
      case Unswipe():
        // Handle unswipe if needed
        return;
      case CancelSwipe():
        return;
      case DrivenActivity():
        return;
    }

    if (direction != null) {
      _handleSwipeAction(swipedMovie, direction);
    }

    // Load more content when running low
    if (_currentDeck.length - currentIndex <= 3) {
      _loadMoreContent();
    }
  }

  void _handleSwipeAction(Map<String, dynamic> movie, String direction) {
    // Trigger haptic feedback based on swipe direction
    switch (direction) {
      case 'left':
        HapticFeedback.lightImpact();
        _showSwipeConfirmation('Passed', Colors.red, Icons.close_rounded);
        break;
      case 'right':
        HapticFeedback.lightImpact();
        _showSwipeConfirmation('Liked', Colors.green, Icons.favorite_rounded);
        break;
      case 'up':
        HapticFeedback.mediumImpact();
        _showSwipeConfirmation(
          'Super Liked',
          AppColors.cinematicGold,
          Icons.star_rounded,
        );
        break;
      case 'down':
        // Handle down swipe if needed
        break;
    }

    // Notify parent about the swipe
    widget.onSwipe?.call(movie, direction);

    // Update discover providers
    ref.read(discoverDeckProvider.notifier).cardSwiped(movie);
  }

  void _handleDeckEnd() {
    widget.onEmpty?.call();
  }

  void _handleCardTap(Map<String, dynamic> movie) {
    // Navigate to detail screen or show more info
    HapticFeedback.selectionClick();
    // TODO: Navigate to movie detail screen
  }

  void _swipeLeft() {
    _swiperController.swipeLeft();
  }

  void _swipeRight() {
    _swiperController.swipeRight();
  }

  void _swipeUp() {
    _swiperController.swipeUp();
  }

  Future<void> _loadMoreContent() async {
    try {
      await ref.read(discoverDeckProvider.notifier).fetchMore();
      final updatedDeck = await ref.read(discoverDeckProvider.future);

      if (mounted) {
        setState(() {
          _currentDeck = updatedDeck;
        });
      }
    } catch (e) {
      // Handle error silently or show a subtle notification
      debugPrint('Failed to load more content: $e');
    }
  }

  void _showSwipeConfirmation(String action, Color color, IconData icon) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(action),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.only(
          bottom: 120, // Above action controls
          left: 16,
          right: 16,
        ),
      ),
    );
  }
}
