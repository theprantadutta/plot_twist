// lib/presentation/pages/detail/widgets/tv_show_detail_shimmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../home/widgets/shimmer_loaders.dart';

class TvShowDetailShimmer extends StatelessWidget {
  const TvShowDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap the whole thing in the shimmer animation
    return const CustomScrollView(
          physics: NeverScrollableScrollPhysics(),
          slivers: [
            // Placeholder for the SliverAppBar
            SliverToBoxAdapter(
              child: ShimmerLoader(width: double.infinity, height: 400),
            ),

            // Placeholder for the TabBar
            SliverToBoxAdapter(
              child: ShimmerLoader(
                width: double.infinity,
                height: 120,
              ), // Approx height of Action Bar + TabBar
            ),

            // Placeholder for the TabBarView content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    ShimmerLoader(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    ShimmerLoader(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    ShimmerLoader(width: 200, height: 16),
                    SizedBox(height: 8),
                    ShimmerLoader(width: 200, height: 16),
                  ],
                ),
              ),
            ),
          ],
        )
        .animate(onComplete: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.1));
  }
}
