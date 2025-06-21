import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/watchlist/watchlist_providers.dart';
import '../../core/app_colors.dart';
import 'widgets/watchlist_item_card.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    // Watch our final, filtered list provider
    final watchlist = ref.watch(filteredWatchlistProvider);
    final currentFilter = ref.watch(watchlistFilterNotifierProvider);
    final notifier = ref.read(watchlistFilterNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text("Watchlist"),
        actions: [
          // The Edit/Done button
          TextButton(
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
            child: Text(
              _isEditMode ? "Done" : "Edit",
              style: const TextStyle(color: AppColors.auroraPink, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // The filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: CupertinoSlidingSegmentedControl<WatchlistFilter>(
              groupValue: currentFilter,
              backgroundColor: AppColors.darkSurface,
              thumbColor: AppColors.auroraPink,
              onValueChanged: (filter) {
                if (filter != null) {
                  notifier.setFilter(filter);
                }
              },
              children: const {
                WatchlistFilter.all: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("All"),
                ),
                WatchlistFilter.movies: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("Movies"),
                ),
                WatchlistFilter.tvShows: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("TV Shows"),
                ),
              },
            ),
          ),
          // The grid of movies/shows
          Expanded(
            child: watchlist.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2 / 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                    itemCount: watchlist.length,
                    itemBuilder: (context, index) {
                      final doc = watchlist[index];
                      // --- THIS IS THE FIX ---
                      // Safely cast the data to a Map.
                      final data = doc.data() as Map<String, dynamic>?;

                      // Check if data is null or if the poster_path is missing or not a String.
                      if (data == null || data['poster_path'] is! String) {
                        // If it's invalid, return an empty container to prevent crashing.
                        return const SizedBox.shrink();
                      }

                      // Now we know poster_path exists and is a String.
                      return WatchlistItemCard(
                            mediaId: doc.id,
                            posterPath: data['poster_path'],
                            isEditMode: _isEditMode,
                          )
                          .animate()
                          .fadeIn(delay: (50 * index).ms)
                          .scale(begin: const Offset(0.9, 0.9));
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            "Your Watchlist is Empty",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add movies and shows to see them here.",
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
