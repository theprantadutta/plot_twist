import 'package:flutter/material.dart';

import 'performance/performance_integration.dart';
import 'performance/optimized_animations.dart' hide PageTransitionType;

/// Animation configuration class for consistent motion design
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final double? scale;
  final Offset? offset;
  final double? opacity;
  final double? rotation;

  const AnimationConfig({
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.scale,
    this.offset,
    this.opacity,
    this.rotation,
  });

  /// Create a copy with modified properties
  AnimationConfig copyWith({
    Duration? duration,
    Curve? curve,
    double? scale,
    Offset? offset,
    double? opacity,
    double? rotation,
  }) {
    return AnimationConfig(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      opacity: opacity ?? this.opacity,
      rotation: rotation ?? this.rotation,
    );
  }
}

/// Predefined motion presets for consistent animations throughout the app
class MotionPresets {
  // --- BASIC ANIMATIONS ---

  /// Fade in animation
  static const AnimationConfig fadeIn = AnimationConfig(
    duration: Duration(milliseconds: 400),
    curve: Curves.easeOut,
    opacity: 0.0,
  );

  /// Fade out animation
  static const AnimationConfig fadeOut = AnimationConfig(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeIn,
    opacity: 1.0,
  );

  /// Slide up animation
  static const AnimationConfig slideUp = AnimationConfig(
    duration: Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
    offset: Offset(0, 50),
  );

  /// Slide down animation
  static const AnimationConfig slideDown = AnimationConfig(
    duration: Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
    offset: Offset(0, -50),
  );

  /// Slide left animation
  static const AnimationConfig slideLeft = AnimationConfig(
    duration: Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
    offset: Offset(50, 0),
  );

  /// Slide right animation
  static const AnimationConfig slideRight = AnimationConfig(
    duration: Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
    offset: Offset(-50, 0),
  );

  /// Scale in animation
  static const AnimationConfig scaleIn = AnimationConfig(
    duration: Duration(milliseconds: 250),
    curve: Curves.easeOutBack,
    scale: 0.8,
  );

  /// Scale out animation
  static const AnimationConfig scaleOut = AnimationConfig(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInBack,
    scale: 1.2,
  );

  // --- MICRO-INTERACTIONS ---

  /// Button press feedback
  static const AnimationConfig buttonPress = AnimationConfig(
    duration: Duration(milliseconds: 150),
    curve: Curves.easeInOut,
    scale: 0.95,
  );

  /// Button release feedback
  static const AnimationConfig buttonRelease = AnimationConfig(
    duration: Duration(milliseconds: 100),
    curve: Curves.easeOut,
    scale: 1.0,
  );

  /// Hover effect for desktop/web
  static const AnimationConfig hover = AnimationConfig(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
    scale: 1.05,
  );

  /// Card elevation animation
  static const AnimationConfig cardElevation = AnimationConfig(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOut,
  );

  // --- SCREEN TRANSITIONS ---

  /// Page transition slide
  static const AnimationConfig pageTransition = AnimationConfig(
    duration: Duration(milliseconds: 400),
    curve: Curves.easeOutCubic,
    offset: Offset(1.0, 0),
  );

  /// Modal slide up
  static const AnimationConfig modalSlideUp = AnimationConfig(
    duration: Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
    offset: Offset(0, 1.0),
  );

  /// Bottom sheet slide
  static const AnimationConfig bottomSheet = AnimationConfig(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
    offset: Offset(0, 1.0),
  );

  /// Hero animation
  static const AnimationConfig hero = AnimationConfig(
    duration: Duration(milliseconds: 400),
    curve: Curves.easeInOutCubic,
  );

  // --- LOADING STATES ---

  /// Skeleton shimmer animation
  static const AnimationConfig shimmer = AnimationConfig(
    duration: Duration(milliseconds: 1500),
    curve: Curves.linear,
  );

  /// Loading spinner
  static const AnimationConfig spinner = AnimationConfig(
    duration: Duration(milliseconds: 1000),
    curve: Curves.linear,
    rotation: 6.28, // 2π radians (full rotation)
  );

  /// Pulse animation for loading states
  static const AnimationConfig pulse = AnimationConfig(
    duration: Duration(milliseconds: 800),
    curve: Curves.easeInOut,
    scale: 1.1,
    opacity: 0.7,
  );

  // --- SWIPE ANIMATIONS ---

  /// Card swipe right (like)
  static const AnimationConfig swipeRight = AnimationConfig(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
    offset: Offset(1.5, 0),
    rotation: 0.3,
  );

  /// Card swipe left (dislike)
  static const AnimationConfig swipeLeft = AnimationConfig(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
    offset: Offset(-1.5, 0),
    rotation: -0.3,
  );

  /// Card return to center
  static const AnimationConfig cardReturn = AnimationConfig(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOutBack,
    offset: Offset.zero,
    rotation: 0.0,
  );

  // --- NOTIFICATION ANIMATIONS ---

  /// Notification slide in
  static const AnimationConfig notificationIn = AnimationConfig(
    duration: Duration(milliseconds: 400),
    curve: Curves.easeOutBack,
    offset: Offset(0, -100),
  );

  /// Notification slide out
  static const AnimationConfig notificationOut = AnimationConfig(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInBack,
    offset: Offset(0, -100),
  );

  // --- LIST ANIMATIONS ---

  /// Staggered list item animation
  static AnimationConfig staggeredListItem(int index) {
    return AnimationConfig(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      offset: const Offset(0, 30),
      opacity: 0.0,
    );
  }

  /// List item removal
  static const AnimationConfig listItemRemoval = AnimationConfig(
    duration: Duration(milliseconds: 250),
    curve: Curves.easeInCubic,
    offset: Offset(-1.0, 0),
    opacity: 0.0,
  );

  /// List item addition
  static const AnimationConfig listItemAddition = AnimationConfig(
    duration: Duration(milliseconds: 350),
    curve: Curves.easeOutBack,
    scale: 0.8,
    opacity: 0.0,
  );
}

/// Animation timing constants for consistent motion design
class AnimationTiming {
  // --- DURATION CATEGORIES ---

  /// Micro-interactions (button presses, hover effects)
  static const Duration micro = Duration(milliseconds: 150);

  /// Quick transitions (tooltips, small UI changes)
  static const Duration quick = Duration(milliseconds: 250);

  /// Standard transitions (most UI animations)
  static const Duration standard = Duration(milliseconds: 300);

  /// Moderate transitions (screen changes, modal appearances)
  static const Duration moderate = Duration(milliseconds: 400);

  /// Slow transitions (complex animations, loading states)
  static const Duration slow = Duration(milliseconds: 600);

  /// Very slow (special effects, onboarding)
  static const Duration verySlow = Duration(milliseconds: 800);

  // --- EASING CURVES ---

  /// Standard easing for most animations
  static const Curve standardCurve = Curves.easeOutCubic;

  /// Bouncy easing for playful interactions
  static const Curve bouncy = Curves.easeOutBack;

  /// Sharp easing for quick, decisive actions
  static const Curve sharp = Curves.easeInOut;

  /// Gentle easing for subtle transitions
  static const Curve gentle = Curves.easeOut;

  /// Linear for continuous animations (loading, shimmer)
  static const Curve linear = Curves.linear;
}

/// Utility class for creating custom animations with performance optimizations
class AnimationUtils {
  /// Create an optimized slide transition
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return OptimizedSlideTransition(
      position: Tween<Offset>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: animation,
          curve: AnimationTiming.standardCurve,
        ),
      ),
      child: child,
    );
  }

  /// Create an optimized fade transition
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return OptimizedFadeTransition(
      opacity: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(parent: animation, curve: AnimationTiming.gentle),
      ),
      child: child,
    );
  }

  /// Create an optimized scale transition
  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return OptimizedScaleTransition(
      scale: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(parent: animation, curve: AnimationTiming.bouncy),
      ),
      child: child,
    );
  }

  /// Create an optimized combined slide and fade transition
  static Widget slideFadeTransition({
    required Widget child,
    required Animation<double> animation,
    Offset slideBegin = const Offset(0.0, 0.3),
    double fadeBegin = 0.0,
  }) {
    return OptimizedSlideTransition(
      position: Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(
        CurvedAnimation(
          parent: animation,
          curve: AnimationTiming.standardCurve,
        ),
      ),
      child: OptimizedFadeTransition(
        opacity: Tween<double>(begin: fadeBegin, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: AnimationTiming.gentle),
        ),
        child: child,
      ),
    );
  }

  /// Create an optimized rotation transition
  static Widget rotationTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return RotationTransition(
      turns: Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: animation,
          curve: AnimationTiming.standardCurve,
        ),
      ),
      child: child,
    );
  }

  /// Create an optimized size transition
  static Widget sizeTransition({
    required Widget child,
    required Animation<double> animation,
    Axis axis = Axis.vertical,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      axis: axis,
      child: child,
    );
  }

  /// Get performance-optimized animation duration based on device capabilities
  static Duration getOptimizedDuration(Duration defaultDuration) {
    return PerformanceIntegration.instance.getRecommendedAnimationDuration(
      defaultDuration: defaultDuration,
    );
  }

  /// Create a performance-optimized page transition
  static PageRouteBuilder<T> createOptimizedPageRoute<T>({
    required Widget page,
    PageTransitionType transitionType = PageTransitionType.slide,
    Duration? duration,
    Curve curve = Curves.easeInOut,
  }) {
    return PerformanceIntegration.instance.createOptimizedPageTransition<T>(
      page: page,
      transitionType: transitionType,
      duration: duration ?? getOptimizedDuration(AnimationTiming.moderate),
      curve: curve,
    );
  }
}
