import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../performance/performance_integration.dart';

/// Comprehensive UI polish system for final refinements
class UIPolishSystem {
  static UIPolishSystem? _instance;
  static UIPolishSystem get instance => _instance ??= UIPolishSystem._();

  UIPolishSystem._();

  // --- VISUAL CONSISTENCY CONSTANTS ---

  /// Standard spacing scale for consistent layout
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// Standard border radius scale
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  /// Standard elevation scale
  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 12.0;
  static const double elevationXXL = 16.0;

  /// Standard opacity scale
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.87;
  static const double opacityFull = 1.0;

  // --- REFINED ANIMATION CURVES ---

  /// Polished easing curves for premium feel
  static const Curve cinematicEase = Cubic(0.25, 0.1, 0.25, 1.0);
  static const Curve smoothEntry = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve smoothExit = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve bounceEntry = Cubic(0.175, 0.885, 0.32, 1.275);
  static const Curve sharpEntry = Cubic(0.4, 0.0, 0.6, 1.0);

  // --- REFINED ANIMATION DURATIONS ---

  /// Polished timing for different interaction types
  static Duration get microDuration =>
      _getOptimizedDuration(const Duration(milliseconds: 100));
  static Duration get quickDuration =>
      _getOptimizedDuration(const Duration(milliseconds: 200));
  static Duration get standardDuration =>
      _getOptimizedDuration(const Duration(milliseconds: 300));
  static Duration get moderateDuration =>
      _getOptimizedDuration(const Duration(milliseconds: 400));
  static Duration get slowDuration =>
      _getOptimizedDuration(const Duration(milliseconds: 600));

  static Duration _getOptimizedDuration(Duration baseDuration) {
    return PerformanceIntegration.instance.getRecommendedAnimationDuration(
      defaultDuration: baseDuration,
    );
  }

  // --- POLISHED COMPONENT BUILDERS ---

  /// Create a polished button with consistent styling and micro-interactions
  static Widget polishedButton({
    required String text,
    required VoidCallback? onPressed,
    ButtonStyle? style,
    IconData? icon,
    bool isLoading = false,
    bool isPrimary = true,
  }) {
    return _PolishedButton(
      text: text,
      onPressed: onPressed,
      style: style,
      icon: icon,
      isLoading: isLoading,
      isPrimary: isPrimary,
    );
  }

  /// Create a polished card with consistent elevation and styling
  static Widget polishedCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
    Color? color,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
    bool enableHover = true,
  }) {
    return _PolishedCard(
      padding: padding,
      margin: margin,
      elevation: elevation,
      color: color,
      borderRadius: borderRadius,
      onTap: onTap,
      enableHover: enableHover,
      child: child,
    );
  }

  /// Create a polished input field with consistent styling
  static Widget polishedTextField({
    required String label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    bool enabled = true,
  }) {
    return _PolishedTextField(
      label: label,
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      obscureText: obscureText,
      keyboardType: keyboardType,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      enabled: enabled,
    );
  }

  /// Create a polished loading indicator
  static Widget polishedLoadingIndicator({
    double size = 24.0,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return _PolishedLoadingIndicator(
      size: size,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  /// Create a polished page transition
  static PageRouteBuilder<T> polishedPageTransition<T>({
    required Widget page,
    TransitionType transitionType = TransitionType.slideFromRight,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? standardDuration,
      reverseTransitionDuration: duration ?? standardDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildPageTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          transitionType: transitionType,
        );
      },
    );
  }

  static Widget _buildPageTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required TransitionType transitionType,
  }) {
    switch (transitionType) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: cinematicEase),
          child: child,
        );
      case TransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: smoothEntry)),
          child: child,
        );
      case TransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: smoothEntry)),
          child: child,
        );
      case TransitionType.scale:
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: bounceEntry),
          child: child,
        );
    }
  }

  // --- ACCESSIBILITY HELPERS ---

  /// Ensure minimum touch target size
  static Widget ensureMinimumTouchTarget({
    required Widget child,
    double minSize = 48.0,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      child: child,
    );
  }

  /// Add semantic labels for screen readers
  static Widget addSemanticLabel({
    required Widget child,
    required String label,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  // --- HAPTIC FEEDBACK ---

  /// Provide consistent haptic feedback
  static void provideFeedback(FeedbackType type) {
    switch (type) {
      case FeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case FeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case FeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case FeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }
}

// --- ENUMS ---

enum TransitionType { fade, slideFromRight, slideFromBottom, scale }

enum FeedbackType { light, medium, heavy, selection }

// --- POLISHED COMPONENTS ---

class _PolishedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;

  const _PolishedButton({
    required this.text,
    required this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
  });

  @override
  State<_PolishedButton> createState() => _PolishedButtonState();
}

class _PolishedButtonState extends State<_PolishedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: UIPolishSystem.microDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: UIPolishSystem.cinematicEase,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UIPolishSystem.ensureMinimumTouchTarget(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.isPrimary
                ? ElevatedButton.icon(
                    onPressed: widget.isLoading ? null : _handlePress,
                    icon: widget.isLoading
                        ? UIPolishSystem.polishedLoadingIndicator(size: 16)
                        : (widget.icon != null
                              ? Icon(widget.icon)
                              : const SizedBox.shrink()),
                    label: Text(widget.text),
                    style: widget.style,
                  )
                : OutlinedButton.icon(
                    onPressed: widget.isLoading ? null : _handlePress,
                    icon: widget.isLoading
                        ? UIPolishSystem.polishedLoadingIndicator(size: 16)
                        : (widget.icon != null
                              ? Icon(widget.icon)
                              : const SizedBox.shrink()),
                    label: Text(widget.text),
                    style: widget.style,
                  ),
          );
        },
      ),
    );
  }

  void _handlePress() {
    UIPolishSystem.provideFeedback(FeedbackType.light);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onPressed?.call();
  }
}

class _PolishedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enableHover;

  const _PolishedCard({
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.borderRadius,
    this.onTap,
    this.enableHover = true,
  });

  @override
  State<_PolishedCard> createState() => _PolishedCardState();
}

class _PolishedCardState extends State<_PolishedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: UIPolishSystem.quickDuration,
      vsync: this,
    );
    _elevationAnimation =
        Tween<double>(
          begin: widget.elevation ?? UIPolishSystem.elevationM,
          end: (widget.elevation ?? UIPolishSystem.elevationM) + 4,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: UIPolishSystem.cinematicEase,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elevationAnimation,
      builder: (context, child) {
        return MouseRegion(
          onEnter: widget.enableHover ? (_) => _handleHover(true) : null,
          onExit: widget.enableHover ? (_) => _handleHover(false) : null,
          child: GestureDetector(
            onTap: widget.onTap != null ? _handleTap : null,
            child: Card(
              elevation: _elevationAnimation.value,
              color: widget.color,
              margin:
                  widget.margin ??
                  const EdgeInsets.all(UIPolishSystem.spacingS),
              shape: RoundedRectangleBorder(
                borderRadius:
                    widget.borderRadius ??
                    BorderRadius.circular(UIPolishSystem.radiusL),
              ),
              child: Padding(
                padding:
                    widget.padding ??
                    const EdgeInsets.all(UIPolishSystem.spacingM),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (_isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTap() {
    UIPolishSystem.provideFeedback(FeedbackType.light);
    widget.onTap?.call();
  }
}

class _PolishedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final bool enabled;

  const _PolishedTextField({
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<_PolishedTextField> createState() => _PolishedTextFieldState();
}

class _PolishedTextFieldState extends State<_PolishedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: UIPolishSystem.quickDuration,
      vsync: this,
    );
    _focusAnimation = CurvedAnimation(
      parent: _animationController,
      curve: UIPolishSystem.cinematicEase,
    );

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            errorText: widget.errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(UIPolishSystem.radiusM),
              borderSide: BorderSide(
                color: AppColors.cinematicGold.withValues(
                  alpha: 0.3 + (_focusAnimation.value * 0.7),
                ),
                width: 1 + (_focusAnimation.value * 1),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PolishedLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const _PolishedLoadingIndicator({
    this.size = 24.0,
    this.color,
    this.strokeWidth = 2.0,
  });

  @override
  State<_PolishedLoadingIndicator> createState() =>
      _PolishedLoadingIndicatorState();
}

class _PolishedLoadingIndicatorState extends State<_PolishedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: widget.strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? AppColors.cinematicGold,
        ),
      ),
    );
  }
}
