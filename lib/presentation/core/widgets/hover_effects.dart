import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Hover effects system for desktop and web platforms
class HoverEffects {
  /// Creates a hover effect wrapper for buttons
  static Widget button({
    required Widget child,
    required VoidCallback? onTap,
    Color? hoverColor,
    double hoverScale = 1.05,
    Duration duration = const Duration(milliseconds: 200),
    BorderRadius? borderRadius,
    bool enabled = true,
  }) {
    if (!kIsWeb && !_isDesktop()) {
      return GestureDetector(onTap: enabled ? onTap : null, child: child);
    }

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: duration,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: borderRadius,
            hoverColor:
                hoverColor ?? AppColors.cinematicPurple.withValues(alpha: 0.1),
            splashColor:
                hoverColor ?? AppColors.cinematicPurple.withValues(alpha: 0.2),
            child: AnimatedScale(scale: 1.0, duration: duration, child: child),
          ),
        ),
      ),
    );
  }

  /// Creates a hover effect wrapper for cards
  static Widget card({
    required Widget child,
    required VoidCallback? onTap,
    Color? hoverColor,
    double hoverElevation = 8.0,
    double hoverScale = 1.02,
    Duration duration = const Duration(milliseconds: 200),
    BorderRadius? borderRadius,
    bool enabled = true,
  }) {
    if (!kIsWeb && !_isDesktop()) {
      return GestureDetector(onTap: enabled ? onTap : null, child: child);
    }

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: duration,
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          elevation: 0,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            hoverColor:
                hoverColor ?? AppColors.cinematicPurple.withValues(alpha: 0.05),
            splashColor:
                hoverColor ?? AppColors.cinematicPurple.withValues(alpha: 0.1),
            child: AnimatedScale(scale: 1.0, duration: duration, child: child),
          ),
        ),
      ),
    );
  }

  /// Creates a hover effect wrapper for icons
  static Widget icon({
    required Widget child,
    required VoidCallback? onTap,
    Color? hoverColor,
    double hoverScale = 1.1,
    Duration duration = const Duration(milliseconds: 150),
    bool enabled = true,
  }) {
    if (!kIsWeb && !_isDesktop()) {
      return GestureDetector(onTap: enabled ? onTap : null, child: child);
    }

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(24),
          hoverColor:
              hoverColor ?? AppColors.cinematicPurple.withValues(alpha: 0.1),
          splashColor:
              hoverColor ?? AppColors.cinematicPurple.withValues(alpha: 0.2),
          child: AnimatedScale(
            scale: 1.0,
            duration: duration,
            child: Padding(padding: const EdgeInsets.all(8.0), child: child),
          ),
        ),
      ),
    );
  }

  /// Creates a hover effect wrapper for text buttons
  static Widget textButton({
    required Widget child,
    required VoidCallback? onTap,
    Color? hoverColor,
    Duration duration = const Duration(milliseconds: 200),
    bool enabled = true,
  }) {
    if (!kIsWeb && !_isDesktop()) {
      return GestureDetector(onTap: enabled ? onTap : null, child: child);
    }

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          hoverColor:
              hoverColor ?? AppColors.cinematicPurple.withValues(alpha: 0.08),
          splashColor:
              hoverColor ?? AppColors.cinematicPurple.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Creates a custom hover effect with builder pattern
  static Widget custom({
    required Widget child,
    required VoidCallback? onTap,
    required Widget Function(bool isHovered) builder,
    Duration duration = const Duration(milliseconds: 200),
    bool enabled = true,
  }) {
    if (!kIsWeb && !_isDesktop()) {
      return GestureDetector(onTap: enabled ? onTap : null, child: child);
    }

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;

        return MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: enabled ? onTap : null,
            child: AnimatedSwitcher(
              duration: duration,
              child: builder(isHovered),
            ),
          ),
        );
      },
    );
  }

  /// Checks if the current platform is desktop
  static bool _isDesktop() {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }
}

/// A widget that provides hover effects for its child
class HoverEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? hoverColor;
  final double hoverScale;
  final Duration duration;
  final BorderRadius? borderRadius;
  final bool enabled;
  final HoverEffectType type;

  const HoverEffect({
    super.key,
    required this.child,
    this.onTap,
    this.hoverColor,
    this.hoverScale = 1.05,
    this.duration = const Duration(milliseconds: 200),
    this.borderRadius,
    this.enabled = true,
    this.type = HoverEffectType.button,
  });

  @override
  State<HoverEffect> createState() => _HoverEffectState();
}

class _HoverEffectState extends State<HoverEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  // bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    if (!widget.enabled) return;
    // setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit() {
    // setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && !_isDesktop()) {
      return GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: widget.child,
      );
    }

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              borderRadius: widget.borderRadius,
              child: InkWell(
                onTap: widget.enabled ? widget.onTap : null,
                borderRadius: widget.borderRadius,
                hoverColor:
                    widget.hoverColor ??
                    AppColors.cinematicPurple.withValues(alpha: 0.1),
                splashColor:
                    widget.hoverColor ??
                    AppColors.cinematicPurple.withValues(alpha: 0.2),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }

  static bool _isDesktop() {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }
}

/// Types of hover effects available
enum HoverEffectType { button, card, icon, text, custom }
