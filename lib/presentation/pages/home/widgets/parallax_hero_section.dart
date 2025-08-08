import 'dart:ui';
import 'package:flutter/material.dart';

/// Parallax hero section that creates depth through scroll-based transformations
class ParallaxHeroSection extends StatelessWidget {
  final Widget child;
  final double scrollOffset;
  final double parallaxFactor;
  final double maxOffset;

  const ParallaxHeroSection({
    super.key,
    required this.child,
    required this.scrollOffset,
    this.parallaxFactor = 0.5,
    this.maxOffset = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate parallax offset with bounds
    final parallaxOffset = (scrollOffset * parallaxFactor).clamp(
      0.0,
      maxOffset,
    );

    // Calculate scale effect (subtle zoom out as user scrolls)
    final scale = (1.0 - (scrollOffset / 1000)).clamp(0.8, 1.0);

    // Calculate opacity effect (fade out as user scrolls)
    final opacity = (1.0 - (scrollOffset / 400)).clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced parallax container with multiple layers
class LayeredParallaxSection extends StatelessWidget {
  final Widget backgroundChild;
  final Widget foregroundChild;
  final double scrollOffset;
  final double backgroundParallaxFactor;
  final double foregroundParallaxFactor;

  const LayeredParallaxSection({
    super.key,
    required this.backgroundChild,
    required this.foregroundChild,
    required this.scrollOffset,
    this.backgroundParallaxFactor = 0.3,
    this.foregroundParallaxFactor = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundOffset = scrollOffset * backgroundParallaxFactor;
    final foregroundOffset = scrollOffset * foregroundParallaxFactor;

    return Stack(
      children: [
        // Background layer (slower parallax)
        Transform.translate(
          offset: Offset(0, backgroundOffset),
          child: backgroundChild,
        ),

        // Foreground layer (faster parallax)
        Transform.translate(
          offset: Offset(0, foregroundOffset),
          child: foregroundChild,
        ),
      ],
    );
  }
}

/// Parallax effect with rotation and perspective
class PerspectiveParallaxSection extends StatelessWidget {
  final Widget child;
  final double scrollOffset;
  final double maxRotation;
  final double maxPerspective;

  const PerspectiveParallaxSection({
    super.key,
    required this.child,
    required this.scrollOffset,
    this.maxRotation = 0.1,
    this.maxPerspective = 0.002,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate rotation based on scroll
    final rotation = (scrollOffset / 1000 * maxRotation).clamp(
      -maxRotation,
      maxRotation,
    );

    // Calculate perspective transformation
    final perspective = (scrollOffset / 1000 * maxPerspective).clamp(
      0.0,
      maxPerspective,
    );

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, perspective) // Perspective
        ..rotateX(rotation), // Rotation
      child: child,
    );
  }
}

/// Smooth parallax with easing curves
class EasedParallaxSection extends StatelessWidget {
  final Widget child;
  final double scrollOffset;
  final double parallaxFactor;
  final Curve curve;

  const EasedParallaxSection({
    super.key,
    required this.child,
    required this.scrollOffset,
    this.parallaxFactor = 0.5,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    // Apply easing curve to the parallax calculation
    final normalizedOffset = (scrollOffset / 400).clamp(0.0, 1.0);
    final easedOffset = curve.transform(normalizedOffset);
    final parallaxOffset = easedOffset * 200 * parallaxFactor;

    return Transform.translate(offset: Offset(0, parallaxOffset), child: child);
  }
}

/// Parallax section with blur effect
class BlurParallaxSection extends StatelessWidget {
  final Widget child;
  final double scrollOffset;
  final double maxBlur;
  final double parallaxFactor;

  const BlurParallaxSection({
    super.key,
    required this.child,
    required this.scrollOffset,
    this.maxBlur = 5.0,
    this.parallaxFactor = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final parallaxOffset = scrollOffset * parallaxFactor;
    final blurAmount = (scrollOffset / 200 * maxBlur).clamp(0.0, maxBlur);

    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: child,
      ),
    );
  }
}
