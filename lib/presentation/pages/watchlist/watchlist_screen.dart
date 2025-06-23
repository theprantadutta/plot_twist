import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_twist/presentation/pages/home/widgets/empty_watchlist_widget.dart';

import '../../../application/home/home_providers.dart';
import '../../../application/watchlist/watchlist_providers.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../home/widgets/media_type_toggle.dart';
import 'full_watchlist_screen.dart';
import 'widgets/watchlist_item_tile.dart';
import 'widgets/watchlist_stats_component.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We now watch the GLOBAL mediaTypeNotifierProvider
    final selectedType = ref.watch(mediaTypeNotifierProvider);
    final watchlistAsync = ref.watch(watchlistDetailsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text("Watchlist"),
        // The AppBar now uses the same toggle as the Home screen
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: MediaTypeToggle(),
          ),
        ],
      ),
      body: watchlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (fullList) {
          // The filtering logic is now simpler and based on the global toggle
          final filteredList = fullList.where((item) {
            final isMovie = item.containsKey('title');
            if (selectedType == MediaType.movie) return isMovie;
            if (selectedType == MediaType.tv) return !isMovie;
            return false;
          }).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              const WatchlistStatsComponent(),
              const SizedBox(height: 32),
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
                    if (filteredList.length > 5)
                      TextButton(
                        onPressed: () {
                          // We should pass the current filter to the full screen
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
                EmptyWatchlistWidget()
              else
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
