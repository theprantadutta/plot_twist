import 'package:flutter/material.dart';

import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';

/// Engaging empty states for discovery interface with compelling illustrations
class DiscoveryEmptyStates extends StatefulWidget {
  final MediaType mediaType;
  final VoidCallback? onRefresh;
  final VoidCallback? onExploreGenres;
  final VoidCallback? onAdjustFilters;
  final VoidCallback? onSwitchMediaType;
  final DiscoveryEmptyStateType type;

  const DiscoveryEmptyStates({
    super.key,
    required this.mediaType,
    required this.type,
    this.onRefresh,
    this.onExploreGenres,
    this.onAdjustFilters,
    this.onSwitchMediaType,
  });

  @override
  State<DiscoveryEmptyStates> createState() => _DiscoveryEmptyStatesState();
}

class _DiscoveryEmptyStatesState extends State<DiscoveryEmptyStates>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIllustration(),
              const SizedBox(height: 32),
              _buildContent(),
              const SizedBox(height: 32),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: _getIllustrationForType(),
        );
      },
    );
  }

  Widget _getIllustrationForType() {
    switch (widget.type) {
      case DiscoveryEmptyStateType.noMoreContent:
        return _buildNoMoreContentIllustration();
      case DiscoveryEmptyStateType.noResults:
        return _buildNoResultsIllustration();
      case DiscoveryEmptyStateType.networkError:
        return _buildNetworkErrorIllustration();
      case DiscoveryEmptyStateType.firstTime:
        return _buildFirstTimeIllustration();
    }
  }

  Widget _buildNoMoreContentIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.cinematicGold.withValues(alpha: 0.2),
            AppColors.cinematicGold.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.cinematicGold.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          // Inner content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 40,
                color: AppColors.cinematicGold,
              ),
              const SizedBox(height: 4),
              Text(
                'All Done!',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.cinematicGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.cinematicBlue.withValues(alpha: 0.2),
            AppColors.cinematicBlue.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Search magnifying glass
          Icon(
            Icons.search_rounded,
            size: 60,
            color: AppColors.cinematicBlue.withValues(alpha: 0.7),
          ),
          // "No results" indicator
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cinematicBlue, width: 2),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.cinematicBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkErrorIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.red.withValues(alpha: 0.2),
            Colors.red.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // WiFi icon with slash
          Icon(
            Icons.wifi_off_rounded,
            size: 60,
            color: Colors.red.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstTimeIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.cinematicPurple.withValues(alpha: 0.2),
            AppColors.cinematicPurple.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Movie reel icon
          Icon(
            Icons.movie_rounded,
            size: 60,
            color: AppColors.cinematicPurple.withValues(alpha: 0.8),
          ),
          // Sparkle effects
          Positioned(
            top: 15,
            right: 15,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: AppColors.cinematicGold,
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 12,
              color: AppColors.cinematicGold.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final content = _getContentForType();

    return Column(
      children: [
        Text(
          content.title,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          content.message,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.darkTextSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (content.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            content.subtitle!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  EmptyStateContent _getContentForType() {
    final mediaTypeName = widget.mediaType == MediaType.movie
        ? 'movies'
        : 'TV shows';

    switch (widget.type) {
      case DiscoveryEmptyStateType.noMoreContent:
        return EmptyStateContent(
          title: 'You\'ve seen it all!',
          message:
              'Congratulations! You\'ve discovered all available $mediaTypeName. Check back later for fresh content, or explore a different category.',
          subtitle: 'New content is added regularly',
        );

      case DiscoveryEmptyStateType.noResults:
        return EmptyStateContent(
          title: 'No matches found',
          message:
              'We couldn\'t find any $mediaTypeName matching your current filters. Try adjusting your preferences or exploring different genres.',
        );

      case DiscoveryEmptyStateType.networkError:
        return EmptyStateContent(
          title: 'Connection trouble',
          message:
              'We\'re having trouble loading new $mediaTypeName. Check your internet connection and try again.',
          subtitle: 'Your previous discoveries are still available',
        );

      case DiscoveryEmptyStateType.firstTime:
        return EmptyStateContent(
          title: 'Welcome to Discovery!',
          message:
              'Get ready to find your next favorite ${widget.mediaType == MediaType.movie ? 'film' : 'series'}. Swipe right to like, left to pass, and up for super likes!',
          subtitle: 'Let\'s find something amazing together',
        );
    }
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Primary action
        _buildPrimaryAction(),

        const SizedBox(height: 16),

        // Secondary actions
        _buildSecondaryActions(),
      ],
    );
  }

  Widget _buildPrimaryAction() {
    final action = _getPrimaryActionForType();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cinematicGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.cinematicGold.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 20),
            const SizedBox(width: 8),
            Text(
              action.label,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  EmptyStateAction _getPrimaryActionForType() {
    switch (widget.type) {
      case DiscoveryEmptyStateType.noMoreContent:
        return EmptyStateAction(
          label: 'Refresh Content',
          icon: Icons.refresh_rounded,
          onPressed: widget.onRefresh,
        );

      case DiscoveryEmptyStateType.noResults:
        return EmptyStateAction(
          label: 'Adjust Filters',
          icon: Icons.tune_rounded,
          onPressed: widget.onAdjustFilters,
        );

      case DiscoveryEmptyStateType.networkError:
        return EmptyStateAction(
          label: 'Try Again',
          icon: Icons.refresh_rounded,
          onPressed: widget.onRefresh,
        );

      case DiscoveryEmptyStateType.firstTime:
        return EmptyStateAction(
          label: 'Start Discovering',
          icon: Icons.play_arrow_rounded,
          onPressed: widget.onRefresh,
        );
    }
  }

  Widget _buildSecondaryActions() {
    final actions = _getSecondaryActionsForType();

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: actions.map((action) {
        return OutlinedButton(
          onPressed: action.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.darkTextSecondary,
            side: BorderSide(
              color: AppColors.darkTextSecondary.withValues(alpha: 0.3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, size: 16),
              const SizedBox(width: 6),
              Text(action.label),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<EmptyStateAction> _getSecondaryActionsForType() {
    switch (widget.type) {
      case DiscoveryEmptyStateType.noMoreContent:
        return [
          EmptyStateAction(
            label: 'Explore Genres',
            icon: Icons.category_rounded,
            onPressed: widget.onExploreGenres,
          ),
          EmptyStateAction(
            label: widget.mediaType == MediaType.movie
                ? 'Try TV Shows'
                : 'Try Movies',
            icon: widget.mediaType == MediaType.movie
                ? Icons.tv_rounded
                : Icons.movie_rounded,
            onPressed: widget.onSwitchMediaType,
          ),
        ];

      case DiscoveryEmptyStateType.noResults:
        return [
          EmptyStateAction(
            label: 'Clear Filters',
            icon: Icons.clear_rounded,
            onPressed: widget.onRefresh,
          ),
          EmptyStateAction(
            label: widget.mediaType == MediaType.movie
                ? 'Try TV Shows'
                : 'Try Movies',
            icon: widget.mediaType == MediaType.movie
                ? Icons.tv_rounded
                : Icons.movie_rounded,
            onPressed: widget.onSwitchMediaType,
          ),
        ];

      case DiscoveryEmptyStateType.networkError:
        return [
          EmptyStateAction(
            label: 'Check Connection',
            icon: Icons.wifi_rounded,
            onPressed: () {}, // Could open network settings
          ),
        ];

      case DiscoveryEmptyStateType.firstTime:
        return [
          EmptyStateAction(
            label: 'Browse Genres',
            icon: Icons.category_rounded,
            onPressed: widget.onExploreGenres,
          ),
        ];
    }
  }
}

/// Types of empty states for discovery
enum DiscoveryEmptyStateType {
  noMoreContent,
  noResults,
  networkError,
  firstTime,
}

/// Content data for empty states
class EmptyStateContent {
  final String title;
  final String message;
  final String? subtitle;

  const EmptyStateContent({
    required this.title,
    required this.message,
    this.subtitle,
  });
}

/// Action data for empty state buttons
class EmptyStateAction {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const EmptyStateAction({
    required this.label,
    required this.icon,
    this.onPressed,
  });
}

/// Animated transition wrapper for smooth empty state transitions
class EmptyStateTransition extends StatefulWidget {
  final Widget child;
  final bool show;
  final Duration duration;

  const EmptyStateTransition({
    super.key,
    required this.child,
    required this.show,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<EmptyStateTransition> createState() => _EmptyStateTransitionState();
}

class _EmptyStateTransitionState extends State<EmptyStateTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(EmptyStateTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * MediaQuery.of(context).size.width,
              _slideAnimation.value.dy * 100,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
