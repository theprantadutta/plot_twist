// lib/presentation/pages/home/widgets/shimmer_loaders.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final BoxShape shape;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: shape == BoxShape.rectangle
                ? BorderRadius.circular(16)
                : null,
            color: Colors.white.withOpacity(0.1),
          ),
        )
        .animate(onComplete: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.2));
  }
}

class CarouselShimmer extends StatelessWidget {
  const CarouselShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: ShimmerLoader(width: 140, height: 210),
        );
      },
    );
  }
}

// This is the new shimmer placeholder for the main Spotlight section
class SpotlightShimmer extends StatelessWidget {
  const SpotlightShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ShimmerLoader(
        width: double.infinity, // Takes up the full width
        height: 250, // Matches the height of the spotlight section
      ),
    );
  }
}
