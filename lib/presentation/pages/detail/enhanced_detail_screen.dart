import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import 'widgets/enhanced_detail_hero_section.dart';
import 'widgets/interactive_elements_section.dart';

/// Enhanced detail screen with rich hero section and smooth scrolling
class EnhancedDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> media;
  final String mediaType; // 'movie' or 'tv'

  const EnhancedDetailScreen({
    super.key,
    required this.media,
    required this.mediaType,
  });

  @override
  ConsumerState<EnhancedDetailScreen> createState() =>
      _EnhancedDetailScreenState();
}

class _EnhancedDetailScreenState extends ConsumerState<EnhancedDetailScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _sectionAnimationController;

  bool _isInWatchlist = false;
  bool _isFavorite = false;
  double? _userRating;
  String? _trailerKey;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _sectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadMediaDetails();
    _sectionAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sectionAnimationController.dispose();
    super.dispose();
  }

  void _loadMediaDetails() {
    // In a real app, this would load additional details like trailer key
    // For now, we'll use mock data
    setState(() {
      _trailerKey = 'dQw4w9WgXcQ'; // Mock trailer key
      _isInWatchlist = false;
      _isFavorite = false;
      _userRating = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: EnhancedDetailHeroSection(
              media: widget.media,
              trailerKey: _trailerKey,
              isInWatchlist: _isInWatchlist,
              isFavorite: _isFavorite,
              userRating: _userRating,
              scrollController: _scrollController,
              onPlayTrailer: _handlePlayTrailer,
              onAddToWatchlist: _handleAddToWatchlist,
              onMarkAsFavorite: _handleMarkAsFavorite,
              onRate: _handleRate,
            ),
          ),

          // Content Sections
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _sectionAnimationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _sectionAnimationController,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      50 * (1 - _sectionAnimationController.value),
                    ),
                    child: Column(
                      children: [
                        // Overview Section
                        _buildOverviewSection(),

                        // Cast and Crew Section
                        _buildCastAndCrewSection(),

                        // Interactive Elements Section
                        InteractiveElementsSection(
                          media: widget.media,
                          mediaType: widget.mediaType,
                        ),

                        // Additional Info Section
                        _buildAdditionalInfoSection(),

                        // Similar Movies/Shows Section
                        _buildSimilarContentSection(),

                        // Reviews Section
                        _buildReviewsSection(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    final overview = widget.media['overview'] ?? '';
    if (overview.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
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
          Text(
            'Overview',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            overview,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.darkTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastAndCrewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Cast & Crew',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // This would use the existing CastAndCrewSection widget
          // For now, we'll create a placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Cast & Crew Section\n(To be implemented)',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    final releaseDate =
        widget.media['release_date'] ?? widget.media['first_air_date'] ?? '';
    final originalLanguage = widget.media['original_language'] ?? '';
    final budget = widget.media['budget'];
    final revenue = widget.media['revenue'];
    final status = widget.media['status'] ?? '';

    final infoItems = <MapEntry<String, String>>[];

    if (releaseDate.isNotEmpty) {
      infoItems.add(MapEntry('Release Date', releaseDate));
    }
    if (originalLanguage.isNotEmpty) {
      infoItems.add(
        MapEntry('Original Language', originalLanguage.toUpperCase()),
      );
    }
    if (budget != null && budget > 0) {
      infoItems.add(MapEntry('Budget', '\$${_formatCurrency(budget)}'));
    }
    if (revenue != null && revenue > 0) {
      infoItems.add(MapEntry('Revenue', '\$${_formatCurrency(revenue)}'));
    }
    if (status.isNotEmpty) {
      infoItems.add(MapEntry('Status', status));
    }

    if (infoItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
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
          Text(
            'Additional Information',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...infoItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      item.key,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextPrimary,
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

  Widget _buildSimilarContentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              widget.mediaType == 'movie' ? 'Similar Movies' : 'Similar Shows',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Similar Content Section\n(To be implemented)',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Reviews',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Reviews Section\n(To be implemented)',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  void _handlePlayTrailer() {
    // Handle trailer playback
    // TODO: Implement trailer playback functionality
  }

  void _handleAddToWatchlist() {
    setState(() {
      _isInWatchlist = !_isInWatchlist;
    });
    // TODO: Implement watchlist toggle functionality
  }

  void _handleMarkAsFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // TODO: Implement favorite toggle functionality
  }

  void _handleRate() {
    // Show rating dialog
    _showRatingDialog();
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          'Rate this ${widget.mediaType}',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How would you rate this ${widget.mediaType}?',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _userRating = rating.toDouble();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.star_rounded,
                    size: 32,
                    color: (_userRating ?? 0) >= rating
                        ? AppColors.cinematicGold
                        : AppColors.darkTextTertiary,
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
