// lib/presentation/pages/detail/widgets/movie_detail_shimmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../home/widgets/shimmer_loaders.dart'; // We can still reuse the base loader

class MovieDetailShimmer extends StatelessWidget {
  const MovieDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for the Hero Section
              ShimmerLoader(width: double.infinity, height: 450),
              SizedBox(height: 16),

              // Placeholder for the Action Button Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      ShimmerLoader(width: 24, height: 24),
                      SizedBox(height: 8),
                      ShimmerLoader(width: 60, height: 12),
                    ],
                  ),
                  Column(
                    children: [
                      ShimmerLoader(width: 24, height: 24),
                      SizedBox(height: 8),
                      ShimmerLoader(width: 60, height: 12),
                    ],
                  ),
                  Column(
                    children: [
                      ShimmerLoader(width: 24, height: 24),
                      SizedBox(height: 8),
                      ShimmerLoader(width: 60, height: 12),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Placeholder for Info Panel and Cast
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoader(width: 150, height: 24), // "Synopsis" title
                    SizedBox(height: 12),
                    ShimmerLoader(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    ShimmerLoader(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    ShimmerLoader(width: 200, height: 16),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(onComplete: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.1));
  }
}
