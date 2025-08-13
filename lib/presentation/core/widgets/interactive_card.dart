import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';

/// Interactive card with comprehensive feedback system
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool isSelected;
  final bool isDisabled;
  final HapticFeedbackType hapticFeedback;
  final InteractiveCardStyle style;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isSelected = false,
    this.isDisabled = false,
    this.hapticFeedback = HapticFeedbackType.light,
    this.style = InteractiveCardStyle.elevated,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _elevationController;
  late AnimationController _selectionController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
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

    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _elevationController, curve: Curves.easeOut),
    );

    _selectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.easeInOut),
    );

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(InteractiveCard oldWidget) {
    super.didUpdateWidget(oldWidget);

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
    _elevationController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isDisabled) return;

    setState(() {
      _isPressed = true;
    });

    _scaleController.forward();
    _triggerHapticFeedback();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isDisabled) return;

    setState(() {
      _isPressed = false;
    });

    _scaleController.reverse();
  }

  void _handleTapCancel() {
    if (widget.isDisabled) return;

    setState(() {
      _isPressed = false;
    });

    _scaleController.reverse();
  }

  void _handleTap() {
    if (widget.isDisabled) return;
    widget.onTap?.call();
  }

  // void _handleLongPress() {
  //   if (widget.isDisabled) return;
  //   HapticFeedback.mediumImpact();
  //   widget.onLongPress?.call();
  // }

  void _handleHover(bool isHovered) {
    if (widget.isDisabled) return;

    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _elevationController.forward();
    } else {
      _elevationController.reverse();
    }
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
      case InteractiveCardStyle.elevated:
        return AppColors.darkSurface;
      case InteractiveCardStyle.outlined:
        return Colors.transparent;
      case InteractiveCardStyle.filled:
        return AppColors.darkBackground;
    }
  }

  Color get _borderColor {
    if (widget.borderColor != null) return widget.borderColor!;

    switch (widget.style) {
      case InteractiveCardStyle.elevated:
        return Colors.transparent;
      case InteractiveCardStyle.outlined:
        return AppColors.darkTextTertiary.withValues(alpha: 0.3);
      case InteractiveCardStyle.filled:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null || widget.onLongPress != null;

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: isInteractive ? _handleTapDown : null,
        onTapUp: isInteractive ? _handleTapUp : null,
        onTapCancel: isInteractive ? _handleTapCancel : null,
        onTap: isInteractive ? _handleTap : null,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _elevationAnimation,
            _selectionAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                padding: widget.padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getAnimatedBackgroundColor(),
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(16),
                  border: Border.all(
                    color: _getAnimatedBorderColor(),
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: _getBoxShadow(),
                ),
                child: Stack(
                  children: [
                    // Selection indicator
                    if (widget.isSelected) _buildSelectionIndicator(),

                    // Card content
                    widget.child,
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
      return baseColor.withValues(alpha: 0.5);
    }

    if (widget.isSelected) {
      baseColor =
          Color.lerp(baseColor, AppColors.cinematicPurple, 0.1) ?? baseColor;
    }

    if (_isPressed) {
      return Color.lerp(baseColor, Colors.black, 0.05) ?? baseColor;
    }

    if (_isHovered) {
      return Color.lerp(baseColor, Colors.white, 0.05) ?? baseColor;
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

    if (_isHovered) {
      return Color.lerp(baseColor, AppColors.cinematicPurple, 0.3) ?? baseColor;
    }

    return baseColor;
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.isDisabled) return [];

    List<BoxShadow> baseShadow = [];

    if (widget.style == InteractiveCardStyle.elevated) {
      baseShadow = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    if (widget.isSelected) {
      return [
        ...baseShadow,
        BoxShadow(
          color: AppColors.cinematicPurple.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }

    if (_isHovered && widget.style == InteractiveCardStyle.elevated) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
    }

    return baseShadow;
  }

  Widget _buildSelectionIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: AnimatedBuilder(
        animation: _selectionAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _selectionAnimation.value,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.cinematicPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cinematicPurple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          );
        },
      ),
    );
  }
}

enum InteractiveCardStyle { elevated, outlined, filled }

enum HapticFeedbackType { none, light, medium, heavy, selection }
