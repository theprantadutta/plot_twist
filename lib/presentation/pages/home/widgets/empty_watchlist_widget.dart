// lib/presentation/pages/home/widgets/empty_watchlist_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyWatchlistWidget extends StatelessWidget {
  const EmptyWatchlistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a fixed height container to ensure it fits nicely in the carousel space
    return Container(
      height: 210,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.film, color: Colors.white70, size: 40),
          const SizedBox(height: 16),
          const Text(
            "Your Watchlist is Empty",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the bookmark icon on any movie or show to save it here for later.",
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
