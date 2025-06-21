import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/profile/profile_providers.dart';
import '../../../core/app_colors.dart';

class StatCard extends ConsumerWidget {
  const StatCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers for the counts
    final watchedCount =
        ref.watch(watchedCountStreamProvider).asData?.value ?? 0;
    final watchlistCount =
        ref.watch(watchlistCountStreamProvider).asData?.value ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Watched", watchedCount.toString()),
          _buildStatItem("Watchlist", watchlistCount.toString()),
          _buildStatItem("Hours", "0"), // Placeholder for now
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.auroraPink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}
