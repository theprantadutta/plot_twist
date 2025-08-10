import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'responsive_layout.dart';

/// Touch-friendly interaction utilities for mobile devices
class TouchInteractions {
  /// Minimum touch target size (44x44 dp as per accessibility guidelines)
  static const double minTouchTargetSize = 44.0;

  /// Recommended touch target size for comfortable interaction
  static const double recommendedTouchTargetSize = 48.0;

  /// Large touch target size for primary actions
  static const double largeTouchTargetSize = 56.0;

  /// Get responsive touch target size
  static double getTouchTargetSize(
    BuildContext context, {
    TouchTargetSize size = TouchTargetSize.recommended,
  }) {
    final baseSize = switch (size) {
      TouchTargetSize.minimum => minTouchTargetSize,
      TouchTargetSize.recommended => recommendedTouchTargetSize,
      TouchTargetSize.large => largeTouchTargetSize,
    };

    // Scale up for larger screens
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: baseSize,
      tablet: baseSize + 4,
      desktop: baseSize + 8,
      largeDesktop: baseSize + 12,
    );
  }

  /// Get responsive button padding
  static EdgeInsetsGeometry getButtonPadding(
    BuildContext context, {
    ButtonSize size = ButtonSize.medium,
  }) {
    final basePadding = switch (size) {
      ButtonSize.small => const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      ButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      ButtonSize.large => const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
    };

    final scaleFactor = ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
      largeDesktop: 1.3,
    );

    return EdgeInsets.symmetric(
      horizontal: basePadding.horizontal * scaleFactor,
      vertical: basePadding.vertical * scaleFactor,
    );
  }

  /// Get responsive icon size
  static double getIconSize(
    BuildContext context, {
    IconSize size = IconSize.medium,
  }) {
    final baseSize = switch (size) {
      IconSize.small => 16.0,
      IconSize.medium => 24.0,
      IconSize.large => 32.0,
      IconSize.extraLarge => 48.0,
    };

    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: baseSize,
      tablet: baseSize + 2,
      desktop: baseSize + 4,
      largeDesktop: baseSize + 6,
    );
  }
}

/// Touch target size enumeration
enum TouchTargetSize { minimum, recommended, large }

/// Button size enumeration
enum ButtonSize { small, medium, large }

/// Icon size enumeration
enum IconSize { small, medium, large, extraLarge }

/// Touch-friendly button widget
class TouchFriendlyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final TouchTargetSize touchTargetSize;
  final bool enableHapticFeedback;
  final HapticFeedbackType hapticFeedbackType;

  const TouchFriendlyButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.style,
    this.touchTargetSize = TouchTargetSize.recommended,
    this.enableHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.light,
  });

  @override
  State<TouchFriendlyButton> createState() => _TouchFriendlyButtonState();
}

class _TouchFriendlyButtonState extends State<TouchFriendlyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _animationController.forward();
      if (widget.enableHapticFeedback) {
        _triggerHapticFeedback();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  void _triggerHapticFeedback() {
    switch (widget.hapticFeedbackType) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final touchTargetSize = TouchInteractions.getTouchTargetSize(
      context,
      size: widget.touchTargetSize,
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onPressed,
            onLongPress: widget.onLongPress,
            child: Container(
              constraints: BoxConstraints(
                minWidth: touchTargetSize,
                minHeight: touchTargetSize,
              ),
              child: ElevatedButton(
                onPressed: widget.onPressed,
                onLongPress: widget.onLongPress,
                style: widget.style,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Haptic feedback type enumeration
enum HapticFeedbackType { light, medium, heavy, selection }

/// Touch-friendly icon button
class TouchFriendlyIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? backgroundColor;
  final TouchTargetSize touchTargetSize;
  final IconSize iconSize;
  final String? tooltip;
  final bool enableHapticFeedback;

  const TouchFriendlyIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.backgroundColor,
    this.touchTargetSize = TouchTargetSize.recommended,
    this.iconSize = IconSize.medium,
    this.tooltip,
    this.enableHapticFeedback = true,
  });

  @override
  State<TouchFriendlyIconButton> createState() =>
      _TouchFriendlyIconButtonState();
}

class _TouchFriendlyIconButtonState extends State<TouchFriendlyIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _animationController.forward();
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final touchTargetSize = TouchInteractions.getTouchTargetSize(
      context,
      size: widget.touchTargetSize,
    );

    final iconSize = TouchInteractions.getIconSize(
      context,
      size: widget.iconSize,
    );

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onPressed,
            onLongPress: widget.onLongPress,
            child: Container(
              width: touchTargetSize,
              height: touchTargetSize,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: iconSize, color: widget.color),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

/// Touch-friendly list tile
class TouchFriendlyListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? contentPadding;
  final bool enableHapticFeedback;

  const TouchFriendlyListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
    this.enableHapticFeedback = true,
  });

  @override
  State<TouchFriendlyListTile> createState() => _TouchFriendlyListTileState();
}

class _TouchFriendlyListTileState extends State<TouchFriendlyListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
      if (widget.enableHapticFeedback) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding =
        widget.contentPadding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
          vertical: ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 12.0,
            tablet: 16.0,
            desktop: 20.0,
          ),
        );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: TouchInteractions.minTouchTargetSize,
              ),
              child: ListTile(
                leading: widget.leading,
                title: widget.title,
                subtitle: widget.subtitle,
                trailing: widget.trailing,
                contentPadding: responsivePadding,
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Touch-friendly card widget
class TouchFriendlyCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool enableHapticFeedback;

  const TouchFriendlyCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.enableHapticFeedback = true,
  });

  @override
  State<TouchFriendlyCard> createState() => _TouchFriendlyCardState();
}

class _TouchFriendlyCardState extends State<TouchFriendlyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _elevationAnimation =
        Tween<double>(
          begin: widget.elevation ?? 2.0,
          end: (widget.elevation ?? 2.0) + 4.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding =
        widget.padding ??
        EdgeInsets.all(
          ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 16.0,
            tablet: 20.0,
            desktop: 24.0,
          ),
        );

    final responsiveMargin =
        widget.margin ??
        EdgeInsets.all(
          ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 8.0,
            tablet: 12.0,
            desktop: 16.0,
          ),
        );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Card(
              color: widget.color,
              elevation: _elevationAnimation.value,
              margin: responsiveMargin,
              shape: RoundedRectangleBorder(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              ),
              child: Padding(padding: responsivePadding, child: widget.child),
            ),
          ),
        );
      },
    );
  }
}

/// Touch-friendly slider
class TouchFriendlySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;

  const TouchFriendlySlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
        ),
        trackHeight: ResponsiveBreakpoints.getResponsiveValue(
          context,
          mobile: 4.0,
          tablet: 5.0,
          desktop: 6.0,
        ),
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: ResponsiveBreakpoints.getResponsiveValue(
            context,
            mobile: 24.0,
            tablet: 28.0,
            desktop: 32.0,
          ),
        ),
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
      ),
    );
  }
}
