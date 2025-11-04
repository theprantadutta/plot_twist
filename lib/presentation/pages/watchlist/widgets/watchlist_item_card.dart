import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../data/firestore/firestore_service.dart';

class WatchlistItemCard extends StatelessWidget {
  final String mediaId;
  final String posterPath;
  final bool isEditMode;

  const WatchlistItemCard({
    super.key,
    required this.mediaId,
    required this.posterPath,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main poster card
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://image.tmdb.org/t/p/w500$posterPath',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // The "Remove" button overlay, shown only in edit mode
        if (isEditMode)
          Positioned.fill(
            child: AnimatedContainer(
              duration: 300.ms,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withValues(alpha: isEditMode ? 0.6 : 0),
              ),
              child: Center(
                child: IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.trashCan,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Call firestore service to delete the item
                    FirestoreService().removeFromList('watchlist', mediaId);
                  },
                ),
              ),
            ).animate().fadeIn(),
          ),
      ],
    );
  }
}
