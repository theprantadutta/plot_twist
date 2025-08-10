import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Comprehensive skeleton loading system with shimmer effects
class SkeletonLoading {
  /// Creates a shimmer effect wrapper
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _ShimmerWrapper(
      baseColor: baseColor ?? AppColors.darkBackground,
      highlightColor:
          highlightColor ?? AppColors.darkTextTertiary.withValues(alpha: 0.3),
      duration: duration,
      child: child,
    );
  }

  /// Basic skeleton box
  static Widget box({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.darkBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }

  /// Skeleton text line
  static Widget text({
    double width = 100,
    double height = 16,
    BorderRadius? borderRadius,
  }) {
    return box(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
    );
  }

  /// Skeleton circular avatar
  static Widget avatar({double size = 40}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        shape: BoxShape.circle,
      ),
    );
  }

  /// Skeleton movie poster
  static Widget moviePoster({
    double width = 120,
    double height = 180,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.movie_rounded,
          color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
          size: width * 0.3,
        ),
      ),
    );
  }

  /// Skeleton hero card
  static Widget heroCard({
    double? width,
    double height = 200,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBackground,
                  AppColors.darkSurface.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
            ),
          ),
          // Content placeholders
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(width: 200, height: 20),
                const SizedBox(height: 8),
                text(width: 150, height: 14),
                const SizedBox(height: 12),
                Row(
                  children: [
                    text(width: 60, height: 12),
                    const SizedBox(width: 16),
                    text(width: 80, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton list item
  static Widget listItem({
    double? width,
    double height = 80,
    bool showAvatar = true,
    bool showTrailing = true,
  }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (showAvatar) ...[avatar(size: 48), const SizedBox(width: 16)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                text(width: 200, height: 14),
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 16),
            box(width: 24, height: 24, borderRadius: BorderRadius.circular(4)),
          ],
        ],
      ),
    );
  }

  /// Skeleton grid item
  static Widget gridItem({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(borderRadius?.topLeft.x ?? 12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                text(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton button
  static Widget button({
    double width = 120,
    double height = 40,
    BorderRadius? borderRadius,
  }) {
    return box(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
    );
  }

  /// Skeleton profile header
  static Widget profileHeader({double? width, double height = 120}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          avatar(size: 80),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text(width: 150, height: 20),
                const SizedBox(height: 8),
                text(width: 100, height: 14),
                const SizedBox(height: 12),
                Row(
                  children: [
                    text(width: 60, height: 12),
                    const SizedBox(width: 16),
                    text(width: 80, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton stats card
  static Widget statsCard({
    double? width,
    double height = 100,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          text(width: 80, height: 14),
          const SizedBox(height: 8),
          text(width: 60, height: 24),
          const Spacer(),
          text(width: 100, height: 12),
        ],
      ),
    );
  }

  /// Skeleton search bar
  static Widget searchBar({double? width, double height = 48}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: text(width: double.infinity, height: 16)),
        ],
      ),
    );
  }

  /// Skeleton tab bar
  static Widget tabBar({int tabCount = 3, double? width, double height = 48}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(tabCount, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < tabCount - 1 ? 16 : 0),
              child: text(width: double.infinity, height: 16),
            ),
          );
        }),
      ),
    );
  }

  /// Skeleton rating stars
  static Widget ratingStars({int starCount = 5, double starSize = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        return Container(
          margin: EdgeInsets.only(right: index < starCount - 1 ? 4 : 0),
          child: Icon(
            Icons.star_rounded,
            color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
            size: starSize,
          ),
        );
      }),
    );
  }
}

/// Shimmer wrapper widget for skeleton loading
class _ShimmerWrapper extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const _ShimmerWrapper({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    required this.duration,
  });

  @override
  State<_ShimmerWrapper> createState() => _ShimmerWrapperState();
}

class _ShimmerWrapperState extends State<_ShimmerWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton loading builder for responsive layouts
class SkeletonBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  builder;
  final bool enabled;

  const SkeletonBuilder({
    super.key,
    required this.builder,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SkeletonLoading.shimmer(child: builder(context, constraints));
      },
    );
  }
}

/// Skeleton loading list for repeated items
class SkeletonList extends StatelessWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Axis scrollDirection;

  const SkeletonList({
    super.key,
    required this.itemBuilder,
    this.itemCount = 5,
    this.padding,
    this.itemExtent,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading.shimmer(
      child: ListView.builder(
        padding: padding,
        itemCount: itemCount,
        itemExtent: itemExtent,
        scrollDirection: scrollDirection,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: itemBuilder,
      ),
    );
  }
}

/// Skeleton loading grid for grid layouts
class SkeletonGrid extends StatelessWidget {
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final double childAspectRatio;

  const SkeletonGrid({
    super.key,
    required this.itemBuilder,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.padding,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading.shimmer(
      child: GridView.builder(
        padding: padding,
        itemCount: itemCount,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
