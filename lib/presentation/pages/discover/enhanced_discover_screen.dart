import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/home/home_providers.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../core/widgets/cinematic_app_bar.dart';
import 'widgets/card_swipe_interface.dart';
import 'widgets/discover_stats_overlay.dart';

/// Enhanced discover screen with card-based swipe interface
class EnhancedDiscoverScreen extends ConsumerStatefulWidget {
  const EnhancedDiscoverScreen({super.key});

  @override
  ConsumerState<EnhancedDiscoverScreen> createState() =>
      _EnhancedDiscoverScreenState();
}

class _EnhancedDiscoverScreenState extends ConsumerState<EnhancedDiscoverScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _totalSwipes = 0;
  int _likes = 0;
  int _dislikes = 0;
  int _superLikes = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fadeController.forward();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(mediaTypeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: _buildAppBar(selectedType),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Main Swipe Interface
            CardSwipeInterface(
              mediaType: selectedType,
              onSwipe: _handleSwipe,
              onEmpty: _handleEmpty,
            ),

            // Stats Overlay
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: DiscoverStatsOverlay(
                totalSwipes: _totalSwipes,
                likes: _likes,
                dislikes: _dislikes,
                superLikes: _superLikes,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(MediaType selectedType) {
    return GlassmorphismAppBar(
      title:
          'Discover ${selectedType == MediaType.movie ? 'Movies' : 'TV Shows'}',
      actions: [
        // Filter Button
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: _showFiltersSheet,
          tooltip: 'Filters',
        ),

        // Media Type Toggle
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              selectedType == MediaType.movie
                  ? Icons.tv_rounded
                  : Icons.movie_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: _toggleMediaType,
          tooltip:
              'Switch to ${selectedType == MediaType.movie ? 'TV Shows' : 'Movies'}',
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  void _handleSwipe(Map<String, dynamic> movie, String direction) {
    setState(() {
      _totalSwipes++;

      switch (direction) {
        case 'left':
          _dislikes++;
          break;
        case 'right':
          _likes++;
          break;
        case 'up':
          _superLikes++;
          break;
        case 'down':
          // Handle down swipe if needed
          break;
      }
    });

    // Handle the swipe action (add to watchlist, etc.)
    _processSwipeAction(movie, direction);
  }

  void _handleEmpty() {
    // Show empty state or load more content
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No more content to discover!'),
        backgroundColor: AppColors.cinematicGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _processSwipeAction(Map<String, dynamic> movie, String direction) {
    switch (direction) {
      case 'right':
      case 'up':
        // Add to watchlist for likes and super likes
        _addToWatchlist(movie);
        break;
      case 'left':
        // Could add to "not interested" list
        _markAsNotInterested(movie);
        break;
      case 'down':
        // Handle down swipe if needed
        break;
    }
  }

  void _addToWatchlist(Map<String, dynamic> movie) {
    // TODO: Implement add to watchlist functionality
    final title = movie['title'] ?? movie['name'] ?? 'Unknown';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$title" to watchlist'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markAsNotInterested(Map<String, dynamic> movie) {
    // TODO: Implement not interested functionality
    // This could be used to improve recommendations
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DiscoverFiltersSheet(),
    );
  }

  void _toggleMediaType() {
    final currentType = ref.read(mediaTypeNotifierProvider);
    final newType = currentType == MediaType.movie
        ? MediaType.tv
        : MediaType.movie;

    ref.read(mediaTypeNotifierProvider.notifier).setMediaType(newType);

    // Reset stats when switching media type
    setState(() {
      _totalSwipes = 0;
      _likes = 0;
      _dislikes = 0;
      _superLikes = 0;
    });
  }
}

/// Discover filters bottom sheet
class DiscoverFiltersSheet extends ConsumerWidget {
  const DiscoverFiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkTextSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discover Filters',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Done',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.cinematicGold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.darkTextSecondary),

          // Filter Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Genres',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Genre filters would go here
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Genre filters coming soon...',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
