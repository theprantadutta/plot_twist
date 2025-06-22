// lib/presentation/pages/watchlist/watchlist_screen.dart
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
    // We now watch our new, powerful provider that returns full media details
    final watchlistAsync = ref.watch(watchlistDetailsProvider);
    final currentFilter = ref.watch(watchlistFilterNotifierProvider);
    final notifier = ref.read(watchlistFilterNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text("Watchlist"),
        actions: [
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
                if (filter != null) notifier.setFilter(filter);
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
          Expanded(
            child: watchlistAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (fullWatchlist) {
                // Filter the already-fetched full details
                final filteredList = fullWatchlist.where((item) {
                  if (currentFilter == WatchlistFilter.all) return true;
                  final typeString = currentFilter == WatchlistFilter.movies
                      ? 'movie'
                      : 'tv';
                  // Check the media type based on whether it has a 'title' (movie) or 'name' (tv)
                  return (typeString == 'movie')
                      ? item.containsKey('title')
                      : item.containsKey('name');
                }).toList();

                if (filteredList.isEmpty) {
                  return _buildEmptyState(
                    isFilterActive: currentFilter != WatchlistFilter.all,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2 / 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];

                    // Now we are 100% sure that poster_path exists and is a String
                    return WatchlistItemCard(
                          mediaId: item['id'].toString(),
                          posterPath: item['poster_path'],
                          isEditMode: _isEditMode,
                        )
                        .animate()
                        .fadeIn(delay: (50 * index).ms)
                        .scale(begin: const Offset(0.9, 0.9));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isFilterActive = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFilterActive
                ? Icons.filter_list_off_rounded
                : Icons.bookmark_border_rounded,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            isFilterActive ? "No Results Found" : "Your Watchlist is Empty",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isFilterActive
                ? "No items in your watchlist match this filter."
                : "Add movies and shows to see them here.",
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
