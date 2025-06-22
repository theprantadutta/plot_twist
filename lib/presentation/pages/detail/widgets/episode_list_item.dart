// lib/presentation/pages/detail/widgets/episode_list_item.dart
import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class EpisodeListItem extends StatelessWidget {
  final Map<String, dynamic> episode;
  const EpisodeListItem({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final stillPath = episode['still_path'];
    final episodeNumber = episode['episode_number'];
    final title = episode['name'] ?? 'Episode $episodeNumber';
    final overview = episode['overview'] ?? 'No overview available.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Episode still image
          Container(
            width: 140,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.darkSurface,
              image: stillPath != null
                  ? DecorationImage(
                      image: NetworkImage(
                        'https://image.tmdb.org/t/p/w300$stillPath',
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: stillPath == null
                ? const Center(child: Icon(Icons.tv_off_rounded))
                : null,
          ),
          const SizedBox(width: 16),
          // Episode details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "E$episodeNumber - $title",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
