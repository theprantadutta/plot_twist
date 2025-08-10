import 'package:flutter/material.dart';

/// Screen transition animations for smooth navigation
class ScreenTransitions {
  /// Slide transition from right to left
  static PageRouteBuilder slideFromRight<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Slide transition from left to right
  static PageRouteBuilder slideFromLeft<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Slide transition from bottom to top
  static PageRouteBuilder slideFromBottom<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Fade transition
  static PageRouteBuilder fade<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Scale transition
  static PageRouteBuilder scale<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    double beginScale = 0.8,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(
          begin: beginScale,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  /// Hero transition with shared element
  static PageRouteBuilder hero<T>({
    required Widget page,
    required String heroTag,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Custom cinematic transition with multiple effects
  static PageRouteBuilder cinematic<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide animation
        const slideBegin = Offset(0.3, 0.0);
        const slideEnd = Offset.zero;
        var slideTween = Tween(
          begin: slideBegin,
          end: slideEnd,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        // Scale animation
        var scaleTween = Tween(
          begin: 0.9,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        // Fade animation
        var fadeTween = Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Modal bottom sheet transition
  static PageRouteBuilder modalBottomSheet<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = const Duration(milliseconds: 300),
    bool isScrollControlled = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

/// Hero transition wrapper widget
class HeroTransition extends StatelessWidget {
  final String tag;
  final Widget child;
  final VoidCallback? onTap;

  const HeroTransition({
    super.key,
    required this.tag,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }
}

/// Shared axis transition for tab-like navigation
class SharedAxisTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final SharedAxisTransitionType transitionType;

  const SharedAxisTransition({
    super.key,
    required this.child,
    required this.animation,
    this.transitionType = SharedAxisTransitionType.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0.3, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case SharedAxisTransitionType.vertical:
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case SharedAxisTransitionType.scaled:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
    }
  }
}

enum SharedAxisTransitionType { horizontal, vertical, scaled }

/// Animated page switcher with smooth transitions
class AnimatedPageSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AnimatedPageSwitcherType transitionType;

  const AnimatedPageSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.transitionType = AnimatedPageSwitcherType.fade,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (child, animation) {
        switch (transitionType) {
          case AnimatedPageSwitcherType.fade:
            return FadeTransition(opacity: animation, child: child);
          case AnimatedPageSwitcherType.scale:
            return ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          case AnimatedPageSwitcherType.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          case AnimatedPageSwitcherType.rotation:
            return RotationTransition(
              turns: Tween<double>(begin: 0.1, end: 0.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
        }
      },
      child: child,
    );
  }
}

enum AnimatedPageSwitcherType { fade, scale, slide, rotation }

/// Staggered animation builder for list items
class StaggeredAnimationBuilder extends StatelessWidget {
  final int itemCount;
  final Duration duration;
  final Duration delay;
  final Widget Function(
    BuildContext context,
    int index,
    Animation<double> animation,
  )
  builder;

  const StaggeredAnimationBuilder({
    super.key,
    required this.itemCount,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return TweenAnimationBuilder<double>(
          duration: duration + (delay * index),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return builder(context, index, AlwaysStoppedAnimation(value));
          },
        );
      }),
    );
  }
}

/// Momentum scroll physics with bounce effect
class CinematicScrollPhysics extends ScrollPhysics {
  const CinematicScrollPhysics({super.parent});

  @override
  CinematicScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CinematicScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 80, stiffness: 100, damping: 1);

  @override
  double get minFlingVelocity => 50.0;

  @override
  double get maxFlingVelocity => 8000.0;
}
