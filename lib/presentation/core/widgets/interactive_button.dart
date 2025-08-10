import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_typography.dart';

/// Interactive button with comprehensive feedback system
class InteractiveButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final InteractiveButtonStyle style;
  final HapticFeedbackType hapticFeedback;

  const InteractiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.isDisabled = false,
    this.style = InteractiveButtonStyle.primary,
    this.hapticFeedback = HapticFeedbackType.light,
  });

  @override
  State<InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _loadingController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _loadingAnimation;

  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(InteractiveButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
        _loadingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isDisabled || widget.isLoading) return;

    setState(() {
      _isPressed = true;
    });

    _scaleController.forward();
    _triggerHapticFeedback();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isDisabled || widget.isLoading) return;

    setState(() {
      _isPressed = false;
    });

    _scaleController.reverse();
  }

  void _handleTapCancel() {
    if (widget.isDisabled || widget.isLoading) return;

    setState(() {
      _isPressed = false;
    });

    _scaleController.reverse();
  }

  void _handleTap() {
    if (widget.isDisabled || widget.isLoading) return;

    _shimmerController.forward().then((_) {
      _shimmerController.reset();
    });

    widget.onPressed?.call();
  }

  void _handleHover(bool isHovered) {
    if (widget.isDisabled || widget.isLoading) return;

    setState(() {
      _isHovered = isHovered;
    });
  }

  void _triggerHapticFeedback() {
    switch (widget.hapticFeedback) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.none:
        break;
    }
  }

  Color get _backgroundColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.style) {
      case InteractiveButtonStyle.primary:
        return AppColors.cinematicPurple;
      case InteractiveButtonStyle.secondary:
        return AppColors.darkSurface;
      case InteractiveButtonStyle.outline:
        return Colors.transparent;
      case InteractiveButtonStyle.ghost:
        return Colors.transparent;
      case InteractiveButtonStyle.destructive:
        return Colors.red.shade600;
    }
  }

  Color get _foregroundColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;

    switch (widget.style) {
      case InteractiveButtonStyle.primary:
        return Colors.white;
      case InteractiveButtonStyle.secondary:
        return AppColors.darkTextPrimary;
      case InteractiveButtonStyle.outline:
        return AppColors.cinematicPurple;
      case InteractiveButtonStyle.ghost:
        return AppColors.darkTextSecondary;
      case InteractiveButtonStyle.destructive:
        return Colors.white;
    }
  }

  Color get _borderColor {
    if (widget.borderColor != null) return widget.borderColor!;

    switch (widget.style) {
      case InteractiveButtonStyle.primary:
        return AppColors.cinematicPurple;
      case InteractiveButtonStyle.secondary:
        return AppColors.darkTextTertiary.withValues(alpha: 0.3);
      case InteractiveButtonStyle.outline:
        return AppColors.cinematicPurple;
      case InteractiveButtonStyle.ghost:
        return Colors.transparent;
      case InteractiveButtonStyle.destructive:
        return Colors.red.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = !widget.isDisabled && !widget.isLoading;

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _shimmerAnimation,
            _loadingAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.width,
                height: widget.height ?? 48,
                padding:
                    widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _getAnimatedBackgroundColor(),
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(12),
                  border: Border.all(
                    color: _getAnimatedBorderColor(),
                    width: widget.style == InteractiveButtonStyle.outline
                        ? 2
                        : 1,
                  ),
                  boxShadow: _getBoxShadow(),
                ),
                child: Stack(
                  children: [
                    // Shimmer effect
                    if (isInteractive) _buildShimmerEffect(),

                    // Button content
                    _buildButtonContent(),

                    // Loading overlay
                    if (widget.isLoading) _buildLoadingOverlay(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getAnimatedBackgroundColor() {
    Color baseColor = _backgroundColor;

    if (widget.isDisabled) {
      return baseColor.withValues(alpha: 0.3);
    }

    if (_isPressed) {
      return Color.lerp(baseColor, Colors.black, 0.1) ?? baseColor;
    }

    if (_isHovered) {
      return Color.lerp(baseColor, Colors.white, 0.1) ?? baseColor;
    }

    return baseColor;
  }

  Color _getAnimatedBorderColor() {
    Color baseColor = _borderColor;

    if (widget.isDisabled) {
      return baseColor.withValues(alpha: 0.3);
    }

    if (_isPressed) {
      return Color.lerp(baseColor, Colors.black, 0.2) ?? baseColor;
    }

    if (_isHovered) {
      return Color.lerp(baseColor, Colors.white, 0.2) ?? baseColor;
    }

    return baseColor;
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.isDisabled) return [];

    if (_isPressed) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    if (_isHovered) {
      return [
        BoxShadow(
          color: _backgroundColor.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shimmerAnimation.value * 200, 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null && !widget.isLoading) ...[
          Icon(widget.icon, color: _getAnimatedForegroundColor(), size: 20),
          const SizedBox(width: 8),
        ],

        if (!widget.isLoading)
          Text(
            widget.text,
            style: AppTypography.labelLarge.copyWith(
              color: _getAnimatedForegroundColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor.withValues(alpha: 0.8),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAnimatedForegroundColor() {
    Color baseColor = _foregroundColor;

    if (widget.isDisabled) {
      return baseColor.withValues(alpha: 0.5);
    }

    return baseColor;
  }
}

enum InteractiveButtonStyle { primary, secondary, outline, ghost, destructive }

enum HapticFeedbackType { none, light, medium, heavy, selection }
