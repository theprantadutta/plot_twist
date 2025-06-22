import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../data/firestore/firestore_service.dart';
import '../../../core/app_colors.dart';

class WatchlistItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const WatchlistItemTile({super.key, required this.item});

  String _formatRuntime(int totalMinutes) {
    final duration = Duration(minutes: totalMinutes);
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  @override
  Widget build(BuildContext context) {
    final posterPath = item['poster_path'];
    final title = item['title'] ?? item['name'] ?? 'Untitled';
    final voteAverage = (item['vote_average'] as num?)?.toDouble() ?? 0.0;
    final runtime =
        item['runtime']
            as int?; // This might be null for TV shows on first fetch

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://image.tmdb.org/t/p/w500$posterPath',
              width: 120,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.solidStar,
                      color: AppColors.darkStarlightGold,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      voteAverage.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (runtime != null) ...[
                      const Text(
                        "  •  ",
                        style: TextStyle(color: AppColors.darkTextSecondary),
                      ),
                      Text(
                        _formatRuntime(runtime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Action Button
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: AppColors.darkSuccessGreen,
              radius: 14,
              child: Icon(Icons.check, color: AppColors.darkSurface, size: 16),
            ),
            onPressed: () {
              // On tap, move from watchlist to watched
              FirestoreService().addToList('watched', item);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Moved '$title' to Watched")),
              );
            },
          ),
        ],
      ),
    );
  }
}
