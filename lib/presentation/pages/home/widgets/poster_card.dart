// lib/presentation/pages/home/widgets/poster_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/app_colors.dart';

class PosterCard extends StatelessWidget {
  final String posterPath;
  final double voteAverage; // <-- ADD THIS: We now require the rating

  const PosterCard({
    super.key,
    required this.posterPath,
    required this.voteAverage, // <-- ADD TO CONSTRUCTOR
  });

  // Helper function to determine the rating circle's color
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
    // We use a Stack to overlay the rating on top of the poster
    return Stack(
      children: [
        // This is our existing poster card
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

        // --- THIS IS THE NEW RATING CIRCLE WIDGET ---
        Positioned(top: 15, left: 15, child: _buildRatingCircle()),
      ],
    );
  }

  Widget _buildRatingCircle() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The circular progress indicator for the rating
          CircularProgressIndicator(
            value:
                voteAverage /
                10.0, // Convert rating (e.g., 7.8) to a percentage (0.78)
            backgroundColor: Colors.grey.withOpacity(0.5),
            color: _getRatingColor(voteAverage),
            strokeWidth: 3.0,
          ),
          // The text displaying the rating number
          Center(
            child: Text(
              voteAverage.toStringAsFixed(1), // Format to one decimal place
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
