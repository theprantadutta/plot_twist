// lib/presentation/pages/detail/widgets/detail_screen_shimmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../home/widgets/shimmer_loaders.dart'; // Reusing our generic shimmer loader

class DetailScreenShimmer extends StatelessWidget {
  const DetailScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // The entire skeleton is animated with a single shimmer effect for performance
    return const SingleChildScrollView(
          physics:
              NeverScrollableScrollPhysics(), // Disable scrolling on the shimmer page
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for Hero Section
              ShimmerLoader(width: double.infinity, height: 400),
              SizedBox(height: 16),

              // Placeholder for Action Button Bar
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
                    // Genre Chips
                    Row(
                      children: [
                        ShimmerLoader(width: 80, height: 30),
                        SizedBox(width: 8),
                        ShimmerLoader(width: 100, height: 30),
                        SizedBox(width: 8),
                        ShimmerLoader(width: 70, height: 30),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Synopsis
                    ShimmerLoader(width: 150, height: 24), // "Synopsis" title
                    SizedBox(height: 12),
                    ShimmerLoader(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    ShimmerLoader(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    ShimmerLoader(width: 200, height: 16),
                    SizedBox(height: 24),
                    // Cast
                    ShimmerLoader(width: 100, height: 24), // "Cast" title
                    SizedBox(height: 16),
                    SizedBox(
                      height: 175,
                      child: Row(
                        children: [
                          // Simulating a few cast cards
                          Column(
                            children: [
                              ShimmerLoader(
                                width: 100,
                                height: 100,
                                shape: BoxShape.circle,
                              ),
                              SizedBox(height: 12),
                              ShimmerLoader(width: 80, height: 14),
                            ],
                          ),
                          SizedBox(width: 16),
                          Column(
                            children: [
                              ShimmerLoader(
                                width: 100,
                                height: 100,
                                shape: BoxShape.circle,
                              ),
                              SizedBox(height: 12),
                              ShimmerLoader(width: 80, height: 14),
                            ],
                          ),
                          SizedBox(width: 16),
                          Column(
                            children: [
                              ShimmerLoader(
                                width: 100,
                                height: 100,
                                shape: BoxShape.circle,
                              ),
                              SizedBox(height: 12),
                              ShimmerLoader(width: 80, height: 14),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(onComplete: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.1));
  }
}
