// lib/presentation/pages/home/widgets/poster_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../detail/movie_detail_screen.dart';
import '../../detail/tv_show_detail_screen.dart';

class PosterCard extends StatelessWidget {
  // --- NEW PROPERTIES ---
  final int mediaId;
  final MediaType mediaType;
  // --------------------

  final String posterPath;
  final double voteAverage;

  const PosterCard({
    super.key,
    required this.mediaId, // <-- ADD TO CONSTRUCTOR
    required this.mediaType, // <-- ADD TO CONSTRUCTOR
    required this.posterPath,
    required this.voteAverage,
  });

  Color _getRatingColor(double rating) {
    if (rating >= 7.0) {
      return Colors.green.shade400;
    } else if (rating >= 5.0) {
      return Colors.yellow.shade600;
    } else {
      return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // --- THIS IS THE FIX ---
        // Now it correctly uses the passed-in properties to navigate.
        Widget screen;
        if (mediaType == MediaType.movie) {
          screen = MovieDetailScreen(mediaId: mediaId);
        } else {
          screen = TvShowDetailScreen(mediaId: mediaId);
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
      child: Stack(
        children: [
          Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500$posterPath',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.movie_creation_outlined,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.2, curve: Curves.easeOut),
          Positioned(top: 16, left: 16, child: _buildRatingCircle()),
        ],
      ),
    );
  }

  Widget _buildRatingCircle() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: voteAverage / 10.0,
            backgroundColor: Colors.grey.withOpacity(0.5),
            color: _getRatingColor(voteAverage),
            strokeWidth: 3.0,
          ),
          Center(
            child: Text(
              voteAverage.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
