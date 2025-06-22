import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/detail/detail_providers.dart';
import '../../../core/app_colors.dart';
import 'episode_list_item.dart';

class SeasonCard extends ConsumerStatefulWidget {
  final int tvId;
  final Map<String, dynamic> season;
  const SeasonCard({super.key, required this.tvId, required this.season});

  @override
  ConsumerState<SeasonCard> createState() => _SeasonCardState();
}

class _SeasonCardState extends ConsumerState<SeasonCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final posterPath = widget.season['poster_path'];

    // --- THIS IS THE FIX ---
    // We explicitly cast the season_number from dynamic to a specific int.
    final seasonNumber = widget.season['season_number'] as int;
    // ----------------------

    final name = widget.season['name'];
    final airDate = widget.season['air_date']?.substring(0, 4) ?? 'N/A';
    final episodeCount = widget.season['episode_count'];

    final seasonIdentifier = (tvId: widget.tvId, seasonNumber: seasonNumber);

    return Card(
      color: AppColors.darkSurface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        onExpansionChanged: (isExpanding) =>
            setState(() => _isExpanded = isExpanding),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$airDate • $episodeCount Episodes"),
        leading: posterPath != null
            ? Image.network(
                'https://image.tmdb.org/t/p/w200$posterPath',
                width: 50,
              )
            : const SizedBox(width: 50, child: Icon(Icons.tv)),
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: AppColors.auroraPink,
        ),
        children: [
          Consumer(
            builder: (context, ref, child) {
              final episodesAsync = ref.watch(
                seasonDetailsProvider(seasonIdentifier),
              );
              return episodesAsync.when(
                data: (seasonDetails) {
                  final episodes = seasonDetails['episodes'] as List;
                  return Column(
                    children: episodes
                        .map((ep) => EpisodeListItem(episode: ep))
                        .toList(),
                  ).animate().fadeIn();
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
                error: (e, s) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Error loading episodes: $e"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
