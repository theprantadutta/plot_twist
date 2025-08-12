import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_animations.dart';
import 'animation_performance_monitor.dart';

/// Optimized animation controller with performance monitoring
class OptimizedAnimationController extends AnimationController {
  final String animationName;
  final AnimationPerformanceMonitor _monitor = AnimationPerformanceMonitor();
  int _frameCount = 0;
  DateTime? _startTime;

  OptimizedAnimationController({
    required this.animationName,
    required Duration super.duration,
    required super.vsync,
    super.value,
    String? debugLabel,
  }) : super(debugLabel: debugLabel ?? animationName);

  @override
  TickerFuture forward({double? from}) {
    _startPerformanceTracking();
    return super.forward(from: from);
  }

  @override
  TickerFuture reverse({double? from}) {
    _startPerformanceTracking();
    return super.reverse(from: from);
  }

  @override
  TickerFuture animateTo(
    double target, {
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    _startPerformanceTracking();
    return super.animateTo(target, duration: duration, curve: curve);
  }

  @override
  TickerFuture animateBack(
    double target, {
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    _startPerformanceTracking();
    return super.animateBack(target, duration: duration, curve: curve);
  }

  void _startPerformanceTracking() {
    if (!kDebugMode) return;

    _startTime = DateTime.now();
    _frameCount = 0;

    addListener(_trackFrame);
    addStatusListener(_onAnimationComplete);
  }

  void _trackFrame() {
    _frameCount++;
  }

  void _onAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _endPerformanceTracking();
      removeListener(_trackFrame);
      removeStatusListener(_onAnimationComplete);
    }
  }

  void _endPerformanceTracking() {
    if (!kDebugMode || _startTime == null) return;

    final duration = DateTime.now().difference(_startTime!);
    _monitor.recordAnimation(animationName, duration, _frameCount);
  }

  @override
  void dispose() {
    removeListener(_trackFrame);
    removeStatusListener(_onAnimationComplete);
    super.dispose();
  }
}

/// High-performance fade transition
class OptimizedFadeTransition extends StatelessWidget {
  final Animation<double> opacity;
  final Widget child;
  final bool alwaysIncludeSemantics;

  const OptimizedFadeTransition({
    super.key,
    required this.opacity,
    required this.child,
    this.alwaysIncludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: opacity,
      builder: (context, child) {
        // Optimize by avoiding rebuilds when opacity is 0 or 1
        final opacityValue = opacity.value;

        if (opacityValue == 0.0) {
          return const SizedBox.shrink();
        }

        if (opacityValue == 1.0) {
          return this.child;
        }

        return Opacity(
          opacity: opacityValue,
          alwaysIncludeSemantics: alwaysIncludeSemantics,
          child: this.child,
        );
      },
    );
  }
}

/// High-performance slide transition
class OptimizedSlideTransition extends StatelessWidget {
  final Animation<Offset> position;
  final Widget child;
  final TextDirection? textDirection;
  final bool transformHitTests;

  const OptimizedSlideTransition({
    super.key,
    required this.position,
    required this.child,
    this.textDirection,
    this.transformHitTests = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: position,
      builder: (context, child) {
        final offset = position.value;

        // Optimize by avoiding transform when offset is zero
        if (offset == Offset.zero) {
          return this.child;
        }

        return FractionalTranslation(
          translation: offset,
          transformHitTests: transformHitTests,
          child: this.child,
        );
      },
    );
  }
}

/// High-performance scale transition
class OptimizedScaleTransition extends StatelessWidget {
  final Animation<double> scale;
  final Widget child;
  final Alignment alignment;

  const OptimizedScaleTransition({
    super.key,
    required this.scale,
    required this.child,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scale,
      builder: (context, child) {
        final scaleValue = scale.value;

        // Optimize by avoiding transform when scale is 1.0
        if (scaleValue == 1.0) {
          return this.child;
        }

        // Hide widget when scale is 0
        if (scaleValue == 0.0) {
          return const SizedBox.shrink();
        }

        return Transform.scale(
          scale: scaleValue,
          alignment: alignment,
          child: this.child,
        );
      },
    );
  }
}

/// Optimized staggered animation builder
class OptimizedStaggeredAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final AnimationConfig animationConfig;

  const OptimizedStaggeredAnimation({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutCubic,
    this.animationConfig = MotionPresets.slideUp,
  });

  @override
  State<OptimizedStaggeredAnimation> createState() =>
      _OptimizedStaggeredAnimationState();
}

class _OptimizedStaggeredAnimationState
    extends State<OptimizedStaggeredAnimation>
    with TickerProviderStateMixin {
  late List<OptimizedAnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startStaggeredAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => OptimizedAnimationController(
        animationName: 'staggered_item_$index',
        duration: widget.duration,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: widget.curve);
    }).toList();
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) {
          _controllers[i].forward();
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
    return Column(
      children: List.generate(widget.children.length, (index) {
        return _buildAnimatedChild(index);
      }),
    );
  }

  Widget _buildAnimatedChild(int index) {
    final animation = _animations[index];
    final child = widget.children[index];

    switch (widget.animationConfig.runtimeType) {
      case const (MotionPresets):
        if (widget.animationConfig.offset != null) {
          return OptimizedSlideTransition(
            position: Tween<Offset>(
              begin: widget.animationConfig.offset!,
              end: Offset.zero,
            ).animate(animation),
            child: OptimizedFadeTransition(opacity: animation, child: child),
          );
        }
        break;
    }

    // Default fade animation
    return OptimizedFadeTransition(opacity: animation, child: child);
  }
}

/// Performance-optimized list animation
class OptimizedListAnimation extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? scrollController;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool enableLazyLoading;

  const OptimizedListAnimation({
    super.key,
    required this.children,
    this.scrollController,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.enableLazyLoading = true,
  });

  @override
  State<OptimizedListAnimation> createState() => _OptimizedListAnimationState();
}

class _OptimizedListAnimationState extends State<OptimizedListAnimation> {
  final Set<int> _visibleItems = {};
  final Set<int> _animatedItems = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return _buildAnimatedListItem(index);
      },
    );
  }

  Widget _buildAnimatedListItem(int index) {
    final child = widget.children[index];

    if (!widget.enableLazyLoading) {
      return _buildAnimatedChild(child, index);
    }

    return VisibilityDetector(
      key: Key('list_item_$index'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_visibleItems.contains(index)) {
          setState(() {
            _visibleItems.add(index);
          });
        }
      },
      child: _visibleItems.contains(index)
          ? _buildAnimatedChild(child, index)
          : SizedBox(height: 100, child: Container()), // Placeholder
    );
  }

  Widget _buildAnimatedChild(Widget child, int index) {
    if (_animatedItems.contains(index)) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      tween: Tween(begin: 0.0, end: 1.0),
      onEnd: () {
        _animatedItems.add(index);
      },
      builder: (context, value, child) {
        return OptimizedSlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(AlwaysStoppedAnimation(value)),
          child: OptimizedFadeTransition(
            opacity: AlwaysStoppedAnimation(value),
            child: child!,
          ),
        );
      },
      child: child,
    );
  }
}

/// Visibility detector for lazy loading
class VisibilityDetector extends StatefulWidget {
  @override
  final Key key;
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    // Simplified visibility detection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVisibilityChanged(VisibilityInfo(visibleFraction: 1.0));
    });

    return widget.child;
  }
}

class VisibilityInfo {
  final double visibleFraction;
  const VisibilityInfo({required this.visibleFraction});
}

/// Optimized hero animation
class OptimizedHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final CreateRectTween? createRectTween;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;
  final bool transitionOnUserGestures;

  const OptimizedHero({
    super.key,
    required this.tag,
    required this.child,
    this.createRectTween,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.transitionOnUserGestures = false,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: createRectTween ?? _createOptimizedRectTween,
      flightShuttleBuilder:
          flightShuttleBuilder ?? _optimizedFlightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
      child: child,
    );
  }

  static RectTween _createOptimizedRectTween(Rect? begin, Rect? end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  static Widget _optimizedFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero toHero = toHeroContext.widget as Hero;
    return OptimizedFadeTransition(opacity: animation, child: toHero.child);
  }
}

/// Performance-optimized page transition
class OptimizedPageTransition<T> extends PageRouteBuilder<T> {
  final Widget child;
  final PageTransitionType transitionType;
  @override
  final Duration transitionDuration;
  final Curve curve;

  OptimizedPageTransition({
    required this.child,
    this.transitionType = PageTransitionType.slideRight,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: transitionDuration,
         reverseTransitionDuration: transitionDuration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildTransition(child, animation, transitionType, curve);
         },
       );

  static Widget _buildTransition(
    Widget child,
    Animation<double> animation,
    PageTransitionType type,
    Curve curve,
  ) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case PageTransitionType.fade:
        return OptimizedFadeTransition(opacity: curvedAnimation, child: child);

      case PageTransitionType.slideRight:
        return OptimizedSlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideLeft:
        return OptimizedSlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideUp:
        return OptimizedSlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.scale:
        return OptimizedScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: OptimizedFadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
    }
  }
}

enum PageTransitionType { fade, slideRight, slideLeft, slideUp, scale }

/// Animation performance optimizer
class AnimationPerformanceOptimizer {
  static const double _targetFPS = 60.0;
  static const Duration _frameTime = Duration(microseconds: 16667); // 60 FPS

  /// Optimize animation duration based on device performance
  static Duration optimizeDuration(Duration baseDuration) {
    // In debug mode or on slower devices, extend duration slightly
    if (kDebugMode) {
      return Duration(
        milliseconds: (baseDuration.inMilliseconds * 1.2).round(),
      );
    }

    return baseDuration;
  }

  /// Get optimized curve based on animation type
  static Curve optimizeCurve(AnimationType type) {
    switch (type) {
      case AnimationType.microInteraction:
        return Curves.easeInOut;
      case AnimationType.screenTransition:
        return Curves.easeOutCubic;
      case AnimationType.listAnimation:
        return Curves.easeOut;
      case AnimationType.heroAnimation:
        return Curves.easeInOutCubic;
    }
  }

  /// Check if device can handle complex animations
  static bool canHandleComplexAnimations() {
    // Simplified check - in a real app, you might check device specs
    return !kDebugMode;
  }
}

enum AnimationType {
  microInteraction,
  screenTransition,
  listAnimation,
  heroAnimation,
}
