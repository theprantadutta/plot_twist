import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/watchlist/watchlist_providers.dart';
import '../../core/app_colors.dart';
import 'widgets/watchlist_item_card.dart';

class FullWatchlistScreen extends ConsumerStatefulWidget {
  const FullWatchlistScreen({super.key});

  @override
  ConsumerState<FullWatchlistScreen> createState() =>
      _FullWatchlistScreenState();
}

class _FullWatchlistScreenState extends ConsumerState<FullWatchlistScreen> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final watchlistAsync = ref.watch(watchlistDetailsProvider);
    final currentFilter = ref.watch(watchlistFilterNotifierProvider);
    final notifier = ref.read(watchlistFilterNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text("Full Watchlist"),
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
            padding: const EdgeInsets.all(16.0),
            child: CupertinoSlidingSegmentedControl<WatchlistFilter>(
              groupValue: currentFilter,
              backgroundColor: AppColors.darkSurface,
              thumbColor: AppColors.auroraPink,
              onValueChanged: (filter) =>
                  filter != null ? notifier.setFilter(filter) : null,
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
              data: (fullList) {
                // --- THIS IS THE FIXED FILTER LOGIC ---
                final filteredList = fullList.where((item) {
                  if (currentFilter == WatchlistFilter.all) return true;
                  final isMovie = item.containsKey('title');
                  if (currentFilter == WatchlistFilter.movies) return isMovie;
                  if (currentFilter == WatchlistFilter.tvShows) return !isMovie;
                  return false;
                }).toList();
                // ------------------------------------

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text("No items found for this filter."),
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
                    return WatchlistItemCard(
                      mediaId: item['id'].toString(),
                      posterPath: item['poster_path'],
                      isEditMode: _isEditMode,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
