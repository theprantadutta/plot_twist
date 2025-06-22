// lib/presentation/pages/detail/widgets/detail_header.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';

class DetailHeader extends StatelessWidget {
  final Map<String, dynamic> media;
  final double collapseProgress;
  final VoidCallback? onPlayTrailer; // <-- We will now use this

  const DetailHeader({
    super.key,
    required this.media,
    required this.collapseProgress,
    this.onPlayTrailer,
  });

  @override
  Widget build(BuildContext context) {
    final backdropPath = media['backdrop_path'];
    final posterPath = media['poster_path'];
    final title = media['title'] ?? media['name'] ?? 'No Title';

    // Lerp (linear interpolation) helps animate values smoothly from 0.0 to 1.0
    final posterY = lerpDouble(120, 0, collapseProgress)!;
    final posterX = lerpDouble(32, 16, collapseProgress)!;
    final posterHeight = lerpDouble(200, 50, collapseProgress)!;

    return SizedBox(
      height: 400, // Matching the SliverAppBar's expandedHeight
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          if (backdropPath != null)
            Image.network(
              'https://image.tmdb.org/t/p/w1280$backdropPath',
              fit: BoxFit.cover,
            ),

          // Blur and Gradient Overlay
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5 * collapseProgress,
                sigmaY: 5 * collapseProgress,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.darkBackground.withOpacity(
                        0.5 + (0.5 * collapseProgress),
                      ),
                      AppColors.darkBackground,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // --- THE NEW PLAY BUTTON ---
          // It will only build if the onPlayTrailer callback exists
          if (onPlayTrailer != null)
            Align(
              alignment: Alignment.bottomRight,
              // The button fades out as the user scrolls (as progress increases)
              child: Opacity(
                opacity: 1.0 - collapseProgress,
                child: IgnorePointer(
                  ignoring:
                      collapseProgress > 0.5, // Disable taps when mostly faded
                  child: ElevatedButton.icon(
                    onPressed: onPlayTrailer,
                    icon: const FaIcon(FontAwesomeIcons.play, size: 16),
                    label: const Text("Play Trailer"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: AppColors.auroraPink,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // --------------------------

          // The animating poster and title from our previous version
          // (This part is unchanged)
          Positioned(
            bottom: posterY,
            left: posterX,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (posterPath != null)
                  SizedBox(
                    height: posterHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500$posterPath',
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Opacity(
                    opacity:
                        1.0 -
                        (collapseProgress * 2).clamp(
                          0.0,
                          1.0,
                        ), // Fade out faster
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
