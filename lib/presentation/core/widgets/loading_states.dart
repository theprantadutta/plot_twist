import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_typography.dart';

/// Comprehensive loading state widgets with various styles
class LoadingStates {
  /// Circular loading indicator with cinematic styling
  static Widget circular({
    double size = 24,
    Color? color,
    double strokeWidth = 3,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.cinematicPurple,
        ),
      ),
    );
  }

  /// Linear loading indicator with cinematic styling
  static Widget linear({
    Color? backgroundColor,
    Color? valueColor,
    double? value,
  }) {
    return LinearProgressIndicator(
      backgroundColor:
          backgroundColor ?? AppColors.darkTextTertiary.withValues(alpha: 0.2),
      valueColor: AlwaysStoppedAnimation<Color>(
        valueColor ?? AppColors.cinematicPurple,
      ),
      value: value,
    );
  }

  /// Pulsing dot loading indicator
  static Widget pulsingDots({Color? color, double size = 8, int dotCount = 3}) {
    return _PulsingDots(
      color: color ?? AppColors.cinematicPurple,
      size: size,
      dotCount: dotCount,
    );
  }

  /// Shimmer loading effect
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return _ShimmerEffect(
      baseColor: baseColor ?? AppColors.darkBackground,
      highlightColor:
          highlightColor ?? AppColors.darkTextTertiary.withValues(alpha: 0.3),
      child: child,
    );
  }

  /// Skeleton loading for text
  static Widget skeletonText({
    double width = 100,
    double height = 16,
    BorderRadius? borderRadius,
  }) {
    return shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Skeleton loading for circular avatar
  static Widget skeletonAvatar({double size = 40}) {
    return shimmer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Skeleton loading for rectangular content
  static Widget skeletonBox({
    double width = 100,
    double height = 100,
    BorderRadius? borderRadius,
  }) {
    return shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Full screen loading overlay
  static Widget overlay({
    String? message,
    Color? backgroundColor,
    bool dismissible = false,
  }) {
    return _LoadingOverlay(
      message: message,
      backgroundColor: backgroundColor,
      dismissible: dismissible,
    );
  }

  /// Inline loading state with message
  static Widget inline({
    String? message,
    double size = 20,
    Color? color,
    MainAxisAlignment alignment = MainAxisAlignment.center,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        circular(size: size, color: color),
        if (message != null) ...[
          const SizedBox(width: 12),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// Button loading state
  static Widget button({double size = 16, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.white),
      ),
    );
  }
}

/// Pulsing dots animation widget
class _PulsingDots extends StatefulWidget {
  final Color color;
  final double size;
  final int dotCount;

  const _PulsingDots({
    required this.color,
    required this.size,
    required this.dotCount,
  });

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(
      widget.dotCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.4,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
              child: Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Shimmer effect widget
class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerEffect({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
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
              stops: [0.0, 0.5, 1.0],
              transform: GradientRotation(_animation.value * 3.14159),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Loading overlay widget
class _LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final bool dismissible;

  const _LoadingOverlay({
    this.message,
    this.backgroundColor,
    required this.dismissible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingStates.circular(size: 32),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
