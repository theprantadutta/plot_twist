import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';

/// Interactive icon button with comprehensive feedback system
class InteractiveIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final bool isSelected;
  final String? tooltip;
  final InteractiveIconButtonStyle style;
  final HapticFeedbackType hapticFeedback;

  const InteractiveIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.size = 48,
    this.iconSize = 24,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.isDisabled = false,
    this.isSelected = false,
    this.tooltip,
    this.style = InteractiveIconButtonStyle.primary,
    this.hapticFeedback = HapticFeedbackType.light,
  });

  @override
  State<InteractiveIconButton> createState() => _InteractiveIconButtonState();
}

class _InteractiveIconButtonState extends State<InteractiveIconButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late AnimationController _loadingController;
  late AnimationController _selectionController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _selectionAnimation;

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

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    _selectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeInOut),
    );

    if (widget.isLoading) {
      _loadingController.repeat();
    }

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(InteractiveIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
        _loadingController.reset();
      }
    }

    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    _loadingController.dispose();
    _selectionController.dispose();
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

    _rippleController.forward().then((_) {
      _rippleController.reset();
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
      case InteractiveIconButtonStyle.primary:
        return AppColors.cinematicPurple;
      case InteractiveIconButtonStyle.secondary:
        return AppColors.darkSurface;
      case InteractiveIconButtonStyle.ghost:
        return Colors.transparent;
      case InteractiveIconButtonStyle.outline:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;

    switch (widget.style) {
      case InteractiveIconButtonStyle.primary:
        return Colors.white;
      case InteractiveIconButtonStyle.secondary:
        return AppColors.darkTextPrimary;
      case InteractiveIconButtonStyle.ghost:
        return AppColors.darkTextSecondary;
      case InteractiveIconButtonStyle.outline:
        return AppColors.cinematicPurple;
    }
  }

  Color get _borderColor {
    if (widget.borderColor != null) return widget.borderColor!;

    switch (widget.style) {
      case InteractiveIconButtonStyle.primary:
        return AppColors.cinematicPurple;
      case InteractiveIconButtonStyle.secondary:
        return AppColors.darkTextTertiary.withValues(alpha: 0.3);
      case InteractiveIconButtonStyle.ghost:
        return Colors.transparent;
      case InteractiveIconButtonStyle.outline:
        return AppColors.cinematicPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
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
            _rippleAnimation,
            _loadingAnimation,
            _selectionAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: _getAnimatedBackgroundColor(),
                  borderRadius:
                      widget.borderRadius ??
                      BorderRadius.circular(widget.size / 2),
                  border: Border.all(
                    color: _getAnimatedBorderColor(),
                    width: widget.style == InteractiveIconButtonStyle.outline
                        ? 2
                        : 1,
                  ),
                  boxShadow: _getBoxShadow(),
                ),
                child: Stack(
                  children: [
                    // Ripple effect
                    if (!widget.isDisabled && !widget.isLoading)
                      _buildRippleEffect(),

                    // Selection indicator
                    if (widget.isSelected) _buildSelectionIndicator(),

                    // Icon content
                    Center(
                      child: widget.isLoading
                          ? _buildLoadingIndicator()
                          : Icon(
                              widget.icon,
                              color: _getAnimatedForegroundColor(),
                              size: widget.iconSize,
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }

  Color _getAnimatedBackgroundColor() {
    Color baseColor = _backgroundColor;

    if (widget.isDisabled) {
      return baseColor.withValues(alpha: 0.3);
    }

    if (widget.isSelected) {
      baseColor =
          Color.lerp(baseColor, AppColors.cinematicPurple, 0.3) ?? baseColor;
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

    if (widget.isSelected) {
      return AppColors.cinematicPurple;
    }

    if (_isPressed) {
      return Color.lerp(baseColor, Colors.black, 0.2) ?? baseColor;
    }

    if (_isHovered) {
      return Color.lerp(baseColor, Colors.white, 0.2) ?? baseColor;
    }

    return baseColor;
  }

  Color _getAnimatedForegroundColor() {
    Color baseColor = _foregroundColor;

    if (widget.isDisabled) {
      return baseColor.withValues(alpha: 0.5);
    }

    if (widget.isSelected) {
      return AppColors.cinematicPurple;
    }

    return baseColor;
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.isDisabled) return [];

    if (widget.isSelected) {
      return [
        BoxShadow(
          color: AppColors.cinematicPurple.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

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
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return [];
  }

  Widget _buildRippleEffect() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(widget.size / 2),
        child: AnimatedBuilder(
          animation: _rippleAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.3 * (1 - _rippleAnimation.value),
                ),
              ),
              transform: Matrix4.identity()..scale(_rippleAnimation.value * 2),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _selectionAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.cinematicPurple.withValues(
                  alpha: _selectionAnimation.value * 0.8,
                ),
                width: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: widget.iconSize * 0.8,
      height: widget.iconSize * 0.8,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getAnimatedForegroundColor(),
        ),
      ),
    );
  }
}

enum InteractiveIconButtonStyle { primary, secondary, ghost, outline }

enum HapticFeedbackType { none, light, medium, heavy, selection }
