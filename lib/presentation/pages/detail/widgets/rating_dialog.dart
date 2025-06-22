// lib/presentation/pages/detail/widgets/rating_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../data/firestore/firestore_service.dart';
import '../../../core/app_colors.dart';

// Function to show the dialog
void showRatingDialog(
  BuildContext context,
  Map<String, dynamic> media,
  double initialRating,
) {
  showDialog(
    context: context,
    builder: (context) =>
        RatingDialog(media: media, initialRating: initialRating),
  );
}

class RatingDialog extends StatefulWidget {
  final Map<String, dynamic> media;
  final double initialRating;

  const RatingDialog({
    super.key,
    required this.media,
    required this.initialRating,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    // Use the initial rating, defaulting to 5 if not rated yet
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Rate this",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.media['title'] ?? widget.media['name'],
              style: const TextStyle(color: AppColors.darkTextSecondary),
            ),
            const SizedBox(height: 24),
            // The interactive rating stars
            Wrap(
              spacing: 4,
              children: List.generate(10, (index) {
                final ratingValue = index + 1;
                return IconButton(
                  onPressed: () =>
                      setState(() => _currentRating = ratingValue.toDouble()),
                  icon: FaIcon(
                    ratingValue <= _currentRating
                        ? FontAwesomeIcons.solidStar
                        : FontAwesomeIcons.star,
                    color: AppColors.darkStarlightGold,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // The Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  FirestoreService().rateMedia(widget.media, _currentRating);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.auroraPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Save Rating"),
              ),
            ),
          ],
        ).animate().fadeIn(),
      ),
    );
  }
}
