// lib/presentation/pages/detail/widgets/info_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';

class InfoHeader extends StatelessWidget {
  final Map<String, dynamic> media;
  final VoidCallback? onPlayTrailer;

  const InfoHeader({super.key, required this.media, this.onPlayTrailer});

  String formatRuntime(int totalMinutes) {
    final duration = Duration(minutes: totalMinutes);
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }

  @override
  Widget build(BuildContext context) {
    final posterPath = media['poster_path'];
    final title = media['title'] ?? media['name'] ?? 'No Title';
    final releaseYear =
        media['release_date']?.substring(0, 4) ??
        media['first_air_date']?.substring(0, 4) ??
        'N/A';
    final runtime = media['runtime'];
    final voteAverage = (media['vote_average'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, kToolbarHeight + 40, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              if (posterPath != null)
                Hero(
                  tag: 'poster_${media['id']}', // For smooth transitions
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500$posterPath',
                      height: 180,
                    ),
                  ),
                ),
              const SizedBox(width: 16),
              // Info Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip(releaseYear),
                        if (runtime != null)
                          _buildInfoChip(formatRuntime(runtime)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.solidStar,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          '/10',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
          const SizedBox(height: 24),
          // Play Trailer Button
          if (onPlayTrailer != null)
            ElevatedButton.icon(
              onPressed: onPlayTrailer,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: const Text("Play Trailer"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: AppColors.auroraPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
