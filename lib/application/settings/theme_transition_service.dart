import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'theme_transition_service.g.dart';

/// Service for managing smooth theme transitions with animations
class ThemeTransitionService {
  static const Duration _transitionDuration = Duration(milliseconds: 400);
  static const Curve _transitionCurve = Curves.easeInOutCubic;

  /// Animate theme transition with a smooth fade effect
  static Future<void> animateThemeTransition({
    required BuildContext context,
    required VoidCallback onTransition,
    Duration? duration,
    Curve? curve,
  }) async {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Create a snapshot of the current screen
    overlayEntry = OverlayEntry(
      builder: (context) => _ThemeTransitionOverlay(
        duration: duration ?? _transitionDuration,
        curve: curve ?? _transitionCurve,
        onComplete: () {
          overlayEntry.remove();
        },
      ),
    );

    // Insert the overlay
    overlay.insert(overlayEntry);

    // Wait a brief moment for the overlay to be inserted
    await Future.delayed(const Duration(milliseconds: 50));

    // Perform the theme transition
    onTransition();

    // The overlay will automatically remove itself after the animation
  }

  /// Get system theme mode
  static ThemeMode getSystemThemeMode(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Check if system theme has changed
  static bool hasSystemThemeChanged(
    BuildContext context,
    ThemeMode currentMode,
  ) {
    if (currentMode != ThemeMode.system) return false;

    final systemMode = getSystemThemeMode(context);
    final currentBrightness = Theme.of(context).brightness;

    return (systemMode == ThemeMode.dark &&
            currentBrightness == Brightness.light) ||
        (systemMode == ThemeMode.light && currentBrightness == Brightness.dark);
  }

  /// Apply haptic feedback for theme switching
  static void applyHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Create a theme-aware color that smoothly transitions
  static Color createTransitionColor({
    required Color lightColor,
    required Color darkColor,
    required Brightness brightness,
    double? opacity,
  }) {
    final color = brightness == Brightness.dark ? darkColor : lightColor;
    return opacity != null ? color.withValues(alpha: opacity) : color;
  }

  /// Create animated color tween for smooth transitions
  static ColorTween createColorTween({
    required Color lightColor,
    required Color darkColor,
    required bool isDarkMode,
  }) {
    return ColorTween(
      begin: isDarkMode ? lightColor : darkColor,
      end: isDarkMode ? darkColor : lightColor,
    );
  }
}

/// Overlay widget that provides smooth theme transition animation
class _ThemeTransitionOverlay extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  final VoidCallback onComplete;

  const _ThemeTransitionOverlay({
    required this.duration,
    required this.curve,
    required this.onComplete,
  });

  @override
  State<_ThemeTransitionOverlay> createState() =>
      _ThemeTransitionOverlayState();
}

class _ThemeTransitionOverlayState extends State<_ThemeTransitionOverlay>
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
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Start the animation
    _controller.forward().then((_) {
      // Reverse the animation to fade out
      _controller.reverse().then((_) {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: _fadeAnimation.value * 0.3),
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: Colors.black87,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }
}

@riverpod
ThemeTransitionService themeTransitionService(Ref ref) {
  return ThemeTransitionService();
}
