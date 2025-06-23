import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';
import 'watchlist_item_action_sheet.dart';

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
    final runtime = item['runtime'] as int?;

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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
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
          // --- THE NEW "MORE" BUTTON ---
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.darkTextSecondary,
            ),
            onPressed: () {
              // On tap, open our new action sheet
              showWatchlistItemActionSheet(context, item);
            },
          ),
        ],
      ),
    );
  }
}
