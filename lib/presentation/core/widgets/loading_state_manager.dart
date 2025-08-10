import 'package:flutter/material.dart';

import 'skeleton_loading.dart';
import 'skeleton_screens.dart';
import 'responsive_skeleton.dart';
import '../app_colors.dart';
import '../app_typography.dart';

/// Loading state manager for consistent loading experience
class LoadingStateManager extends StatelessWidget {
  final LoadingState state;
  final Widget child;
  final Widget? skeleton;
  final Widget? error;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Duration transitionDuration;
  final bool useResponsiveSkeleton;

  const LoadingStateManager({
    super.key,
    required this.state,
    required this.child,
    this.skeleton,
    this.error,
    this.errorMessage,
    this.onRetry,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.useResponsiveSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: transitionDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _buildCurrentState(),
    );
  }

  Widget _buildCurrentState() {
    switch (state) {
      case LoadingState.loading:
        return _buildLoadingState();
      case LoadingState.error:
        return _buildErrorState();
      case LoadingState.loaded:
        return child;
      case LoadingState.empty:
        return _buildEmptyState();
    }
  }

  Widget _buildLoadingState() {
    if (skeleton != null) {
      return skeleton!;
    }

    // Default skeleton based on context
    return SkeletonLoading.shimmer(
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    if (error != null) {
      return error!;
    }

    return ErrorStateWidget(
      message: errorMessage ?? 'Something went wrong',
      onRetry: onRetry,
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(message: 'No content available');
  }
}

/// Loading state enum
enum LoadingState { loading, loaded, error, empty }

/// Error state widget with retry functionality
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Oops!',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryText ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cinematicPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkTextTertiary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_rounded,
                color: AppColors.darkTextTertiary,
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              message,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// Screen-specific loading state managers
class ScreenLoadingManager {
  /// Home screen loading manager
  static Widget home({
    required LoadingState state,
    required Widget child,
    VoidCallback? onRetry,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: ResponsiveSkeletonScreens.homeScreen(),
      onRetry: onRetry,
      child: child,
    );
  }

  /// Discover screen loading manager
  static Widget discover({
    required LoadingState state,
    required Widget child,
    VoidCallback? onRetry,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: ResponsiveSkeletonScreens.discoverScreen(),
      onRetry: onRetry,
      child: child,
    );
  }

  /// Profile screen loading manager
  static Widget profile({
    required LoadingState state,
    required Widget child,
    VoidCallback? onRetry,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: ResponsiveSkeletonScreens.profileScreen(),
      onRetry: onRetry,
      child: child,
    );
  }

  /// Detail screen loading manager
  static Widget detail({
    required LoadingState state,
    required Widget child,
    VoidCallback? onRetry,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: ResponsiveSkeletonScreens.detailScreen(),
      onRetry: onRetry,
      child: child,
    );
  }

  /// Library screen loading manager
  static Widget library({
    required LoadingState state,
    required Widget child,
    VoidCallback? onRetry,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: ResponsiveSkeletonScreens.libraryScreen(),
      onRetry: onRetry,
      child: child,
    );
  }

  /// Search screen loading manager
  static Widget search({
    required LoadingState state,
    required Widget child,
    VoidCallback? onRetry,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: SkeletonScreens.searchScreen(),
      onRetry: onRetry,
      child: child,
    );
  }

  /// Settings screen loading manager
  static Widget settings({
    required LoadingState state,
    required Widget child,
    VoidCallback? onRetry,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: SkeletonScreens.settingsScreen(),
      onRetry: onRetry,
      child: child,
    );
  }

  /// Custom list screen loading manager
  static Widget customList({
    required LoadingState state,
    required Widget child,
    VoidCallback? onRetry,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: SkeletonScreens.customListScreen(),
      onRetry: onRetry,
      child: child,
    );
  }
}

/// Component-specific loading managers
class ComponentLoadingManager {
  /// Movie poster loading
  static Widget moviePoster({
    required LoadingState state,
    required Widget child,
    double width = 120,
    double height = 180,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: SkeletonLoading.shimmer(
        child: SkeletonLoading.moviePoster(width: width, height: height),
      ),
      child: child,
    );
  }

  /// List item loading
  static Widget listItem({
    required LoadingState state,
    required Widget child,
    bool showAvatar = true,
    bool showTrailing = true,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: SkeletonLoading.shimmer(
        child: SkeletonLoading.listItem(
          showAvatar: showAvatar,
          showTrailing: showTrailing,
        ),
      ),
      child: child,
    );
  }

  /// Grid item loading
  static Widget gridItem({
    required LoadingState state,
    required Widget child,
    double? width,
    double? height,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: SkeletonLoading.shimmer(
        child: SkeletonLoading.gridItem(width: width, height: height),
      ),
      child: child,
    );
  }

  /// Hero card loading
  static Widget heroCard({
    required LoadingState state,
    required Widget child,
    double? width,
    double height = 200,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: SkeletonLoading.shimmer(
        child: SkeletonLoading.heroCard(width: width, height: height),
      ),
      child: child,
    );
  }

  /// Profile header loading
  static Widget profileHeader({
    required LoadingState state,
    required Widget child,
    double? width,
    double height = 120,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: SkeletonLoading.shimmer(
        child: SkeletonLoading.profileHeader(width: width, height: height),
      ),
      child: child,
    );
  }

  /// Stats card loading
  static Widget statsCard({
    required LoadingState state,
    required Widget child,
    double? width,
    double height = 100,
  }) {
    return LoadingStateManager(
      state: state,
      skeleton: SkeletonLoading.shimmer(
        child: SkeletonLoading.statsCard(width: width, height: height),
      ),
      child: child,
    );
  }
}

/// Loading state builder for custom implementations
class LoadingStateBuilder extends StatelessWidget {
  final LoadingState state;
  final Widget Function() loadingBuilder;
  final Widget Function() loadedBuilder;
  final Widget Function()? errorBuilder;
  final Widget Function()? emptyBuilder;
  final Duration transitionDuration;

  const LoadingStateBuilder({
    super.key,
    required this.state,
    required this.loadingBuilder,
    required this.loadedBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: transitionDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _buildCurrentState(),
    );
  }

  Widget _buildCurrentState() {
    switch (state) {
      case LoadingState.loading:
        return loadingBuilder();
      case LoadingState.loaded:
        return loadedBuilder();
      case LoadingState.error:
        return errorBuilder?.call() ??
            const ErrorStateWidget(message: 'Something went wrong');
      case LoadingState.empty:
        return emptyBuilder?.call() ??
            const EmptyStateWidget(message: 'No content available');
    }
  }
}

/// Smooth transition from skeleton to content
class SkeletonToContentTransition extends StatefulWidget {
  final Widget skeleton;
  final Widget content;
  final bool isLoading;
  final Duration duration;

  const SkeletonToContentTransition({
    super.key,
    required this.skeleton,
    required this.content,
    required this.isLoading,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<SkeletonToContentTransition> createState() =>
      _SkeletonToContentTransitionState();
}

class _SkeletonToContentTransitionState
    extends State<SkeletonToContentTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (!widget.isLoading) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SkeletonToContentTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.reverse();
      } else {
        _controller.forward();
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
    return Stack(
      children: [
        // Skeleton layer
        AnimatedOpacity(
          opacity: widget.isLoading ? 1.0 : 0.0,
          duration: widget.duration,
          child: widget.skeleton,
        ),

        // Content layer
        FadeTransition(opacity: _fadeAnimation, child: widget.content),
      ],
    );
  }
}
