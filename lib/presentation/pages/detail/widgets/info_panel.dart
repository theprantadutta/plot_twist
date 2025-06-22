// lib/presentation/pages/detail/widgets/info_panel.dart
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class InfoPanel extends StatelessWidget {
  final Map<String, dynamic> media;
  const InfoPanel({super.key, required this.media});

  String _formatRuntime(int totalMinutes) {
    final duration = Duration(minutes: totalMinutes);
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  @override
  Widget build(BuildContext context) {
    final genres = (media['genres'] as List)
        .map((g) => g['name'] as String)
        .toList();
    final releaseYear =
        media['release_date']?.substring(0, 4) ??
        media['first_air_date']?.substring(0, 4) ??
        'N/A';
    final runtime = media['runtime'];
    final voteAverage = (media['vote_average'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal scrolling genre chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              itemBuilder: (context, index) => _buildGenreChip(genres[index]),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
            ),
          ),
          const SizedBox(height: 24),
          // Stats Row
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(releaseYear, "Year"),
                const VerticalDivider(
                  color: Colors.white24,
                  indent: 8,
                  endIndent: 8,
                ),
                if (runtime != null) ...[
                  _buildStatItem(_formatRuntime(runtime), "Duration"),
                  const VerticalDivider(
                    color: Colors.white24,
                    indent: 8,
                    endIndent: 8,
                  ),
                ],
                _buildStatItem(voteAverage.toStringAsFixed(1), "TMDB Score"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Overview
          const Text(
            "Synopsis",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            media['overview'] ?? 'No synopsis available.',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.darkTextSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.darkSurface,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }
}
