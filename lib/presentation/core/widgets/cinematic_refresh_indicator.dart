import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Custom refresh indicator with cinematic styling and smooth animations
class CinematicRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double strokeWidth;

  const CinematicRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.strokeWidth = 3.0,
  });

  @override
  State<CinematicRefreshIndicator> createState() =>
      _CinematicRefreshIndicatorState();
}

class _CinematicRefreshIndicatorState extends State<CinematicRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2.0 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      displacement: widget.displacement,
      backgroundColor: widget.backgroundColor ?? AppColors.darkSurface,
      color: widget.color ?? AppColors.cinematicGold,
      strokeWidth: widget.strokeWidth,
      child: widget.child,
    );
  }

  Future<void> _handleRefresh() async {
    _scaleController.forward();
    _controller.repeat();

    try {
      await widget.onRefresh();
    } finally {
      _controller.stop();
      await _scaleController.reverse();
    }
  }
}

/// Custom refresh indicator with cinematic movie reel animation
class MovieReelRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final double displacement;

  const MovieReelRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.displacement = 60.0,
  });

  @override
  State<MovieReelRefreshIndicator> createState() =>
      _MovieReelRefreshIndicatorState();
}

class _MovieReelRefreshIndicatorState extends State<MovieReelRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pullController;
  late AnimationController _refreshController;
  late Animation<double> _pullAnimation;
  late Animation<double> _rotationAnimation;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pullController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pullAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pullController, curve: Curves.easeOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2.0 * math.pi).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pullController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          widget.child,
          if (_isRefreshing)
            Positioned(
              top: widget.displacement,
              left: 0,
              right: 0,
              child: Center(child: _buildMovieReelIndicator()),
            ),
        ],
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final metrics = notification.metrics;
      if (metrics.pixels < -100 && !_isRefreshing) {
        _startRefresh();
      }
    }
    return false;
  }

  Widget _buildMovieReelIndicator() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.cinematicGold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.color ?? AppColors.cinematicGold).withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Movie reel holes
                ...List.generate(8, (index) {
                  final angle = (index * math.pi * 2) / 8;
                  final radius = 14.0;
                  final x = 24 + radius * math.cos(angle);
                  final y = 24 + radius * math.sin(angle);

                  return Positioned(
                    left: x - 3,
                    top: y - 3,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
                // Center hole
                Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _pullController.forward();
    _refreshController.repeat();

    try {
      await widget.onRefresh();
    } finally {
      _refreshController.stop();
      await _pullController.reverse();

      setState(() {
        _isRefreshing = false;
      });
    }
  }
}

/// Cinematic pull-to-refresh with golden glow effect
class GoldenGlowRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? refreshText;

  const GoldenGlowRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText,
  });

  @override
  State<GoldenGlowRefreshIndicator> createState() =>
      _GoldenGlowRefreshIndicatorState();
}

class _GoldenGlowRefreshIndicatorState extends State<GoldenGlowRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _textController;
  late Animation<double> _glowAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: _handleRefresh,
      displacement: 80.0,
      backgroundColor: Colors.transparent,
      child: widget.child,
    );
  }

  Future<void> _handleRefresh() async {
    _glowController.repeat(reverse: true);
    _textController.forward();

    try {
      await widget.onRefresh();
    } finally {
      _glowController.stop();
      await _textController.reverse();
    }
  }
}

/// Simple cinematic refresh indicator with fade animation
class FadeRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const FadeRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: AppColors.darkSurface,
      color: color ?? AppColors.cinematicGold,
      strokeWidth: 3.0,
      displacement: 50.0,
      child: child,
    );
  }
}
