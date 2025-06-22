import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/watchlist/watchlist_providers.dart';
import '../../core/app_colors.dart';
import 'full_watchlist_screen.dart';
import 'widgets/watchlist_item_tile.dart';
import 'widgets/watchlist_stats_component.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistDetailsProvider);
    final currentFilter = ref.watch(watchlistFilterNotifierProvider);
    final notifier = ref.read(watchlistFilterNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text("Watchlist"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CupertinoSlidingSegmentedControl<WatchlistFilter>(
              groupValue: currentFilter,
              backgroundColor: AppColors.darkSurface,
              thumbColor: AppColors.auroraPink,
              onValueChanged: (filter) =>
                  filter != null ? notifier.setFilter(filter) : null,
              children: const {
                WatchlistFilter.all: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("All"),
                ),
                WatchlistFilter.movies: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Movies"),
                ),
                WatchlistFilter.tvShows: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("TV Shows"),
                ),
              },
            ),
          ),
        ],
      ),
      body: watchlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (fullList) {
          // Apply the same filtering logic for the preview list
          final filteredList = fullList.where((item) {
            if (currentFilter == WatchlistFilter.all) return true;
            final isMovie = item.containsKey('title');
            if (currentFilter == WatchlistFilter.movies) return isMovie;
            if (currentFilter == WatchlistFilter.tvShows) return !isMovie;
            return false;
          }).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // 1. Statistics Section
              const WatchlistStatsComponent(),

              const SizedBox(height: 32),

              // 2. Watch Next Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Watch Next",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Only show "View All" if there are more items than the preview shows
                    if (filteredList.length > 5)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FullWatchlistScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            color: AppColors.auroraPink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              if (filteredList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      "Add items to your watchlist!",
                      style: TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                // Build the list of tiles, showing a max of 5 items for the preview
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length > 5 ? 5 : filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return WatchlistItemTile(item: item);
                  },
                ),
            ],
          ).animate().fadeIn();
        },
      ),
    );
  }
}
