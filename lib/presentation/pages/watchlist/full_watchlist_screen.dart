// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../application/watchlist/watchlist_providers.dart';
// import '../../core/app_colors.dart';
// import 'widgets/watchlist_item_card.dart';

// class FullWatchlistScreen extends ConsumerStatefulWidget {
//   const FullWatchlistScreen({super.key});

//   @override
//   ConsumerState<FullWatchlistScreen> createState() =>
//       _FullWatchlistScreenState();
// }

// class _FullWatchlistScreenState extends ConsumerState<FullWatchlistScreen> {
//   bool _isEditMode = false;

//   @override
//   Widget build(BuildContext context) {
//     final watchlistAsync = ref.watch(watchlistDetailsProvider);
//     final currentFilter = ref.watch(watchlistFilterNotifierProvider);
//     final notifier = ref.read(watchlistFilterNotifierProvider.notifier);

//     return Scaffold(
//       backgroundColor: AppColors.darkBackground,
//       appBar: AppBar(
//         backgroundColor: AppColors.darkBackground,
//         title: const Text("Full Watchlist"),
//         actions: [
//           TextButton(
//             onPressed: () => setState(() => _isEditMode = !_isEditMode),
//             child: Text(
//               _isEditMode ? "Done" : "Edit",
//               style: const TextStyle(color: AppColors.auroraPink, fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: CupertinoSlidingSegmentedControl<WatchlistFilter>(
//               groupValue: currentFilter,
//               backgroundColor: AppColors.darkSurface,
//               thumbColor: AppColors.auroraPink,
//               onValueChanged: (filter) =>
//                   filter != null ? notifier.setFilter(filter) : null,
//               children: const {
//                 WatchlistFilter.all: Padding(
//                   padding: EdgeInsets.all(8),
//                   child: Text("All"),
//                 ),
//                 WatchlistFilter.movies: Padding(
//                   padding: EdgeInsets.all(8),
//                   child: Text("Movies"),
//                 ),
//                 WatchlistFilter.tvShows: Padding(
//                   padding: EdgeInsets.all(8),
//                   child: Text("TV Shows"),
//                 ),
//               },
//             ),
//           ),
//           Expanded(
//             child: watchlistAsync.when(
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (err, stack) => Center(child: Text("Error: $err")),
//               data: (fullList) {
//                 // --- THIS IS THE FIXED FILTER LOGIC ---
//                 final filteredList = fullList.where((item) {
//                   if (currentFilter == WatchlistFilter.all) return true;
//                   final isMovie = item.containsKey('title');
//                   if (currentFilter == WatchlistFilter.movies) return isMovie;
//                   if (currentFilter == WatchlistFilter.tvShows) return !isMovie;
//                   return false;
//                 }).toList();
//                 // ------------------------------------

//                 if (filteredList.isEmpty) {
//                   return const Center(
//                     child: Text("No items found for this filter."),
//                   );
//                 }

//                 return GridView.builder(
//                   padding: const EdgeInsets.all(16),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     childAspectRatio: 2 / 3,
//                     mainAxisSpacing: 16,
//                     crossAxisSpacing: 16,
//                   ),
//                   itemCount: filteredList.length,
//                   itemBuilder: (context, index) {
//                     final item = filteredList[index];
//                     return WatchlistItemCard(
//                       mediaId: item['id'].toString(),
//                       posterPath: item['poster_path'],
//                       isEditMode: _isEditMode,
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/presentation/pages/watchlist/full_watchlist_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/watchlist/multi_select_provider.dart';
import '../../../application/watchlist/watchlist_providers.dart';
import '../../../data/firestore/firestore_service.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import 'widgets/selectable_item_card.dart';
import 'widgets/selectable_watchlist_item_tile.dart';

class FullWatchlistScreen extends ConsumerStatefulWidget {
  const FullWatchlistScreen({super.key});

  @override
  ConsumerState<FullWatchlistScreen> createState() =>
      _FullWatchlistScreenState();
}

class _FullWatchlistScreenState extends ConsumerState<FullWatchlistScreen> {
  bool _isEditMode = false;
  bool _isGridView = true; // To toggle between Grid and List view

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      // When leaving edit mode, clear any selections
      if (!_isEditMode) {
        ref.read(multiSelectNotifierProvider.notifier).clear();
      }
    });
  }

  // @override
  // void dispose() {
  //   // Ensure we clear selections if the user navigates back while in edit mode
  //   Future.microtask(
  //     () => ref.read(multiSelectNotifierProvider.notifier).clear(),
  //   );
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final watchlistAsync = ref.watch(watchlistDetailsProvider);
    final currentFilter = ref.watch(watchlistFilterNotifierProvider);
    final filterNotifier = ref.read(watchlistFilterNotifierProvider.notifier);
    final selectedItems = ref.watch(multiSelectNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Text("Full Watchlist"),
        actions: [
          // Layout Toggle Button
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: "Toggle View",
          ),
          // Edit/Done Button
          TextButton(
            onPressed: _toggleEditMode,
            child: Text(
              _isEditMode ? "Done" : "Edit",
              style: const TextStyle(
                color: AppColors.auroraPink,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      // Use a Stack to overlay the bulk action bar at the bottom
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: CupertinoSlidingSegmentedControl<WatchlistFilter>(
                  groupValue: currentFilter,
                  backgroundColor: AppColors.darkSurface,
                  thumbColor: AppColors.auroraPink,
                  onValueChanged: (filter) =>
                      filter != null ? filterNotifier.setFilter(filter) : null,
                  children: const {
                    WatchlistFilter.all: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("All", style: TextStyle(color: Colors.white)),
                    ),
                    WatchlistFilter.movies: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Movies",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    WatchlistFilter.tvShows: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "TV Shows",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  },
                ),
              ),
              Expanded(
                child: watchlistAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("Error: $err")),
                  data: (fullList) {
                    final filteredList = fullList.where((item) {
                      if (currentFilter == WatchlistFilter.all) return true;
                      final isMovie = item.containsKey('title');
                      if (currentFilter == WatchlistFilter.movies)
                        return isMovie;
                      return !isMovie;
                    }).toList();

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Text(
                          "No items found for this filter.",
                          style: TextStyle(color: AppColors.darkTextSecondary),
                        ),
                      );
                    }

                    // Use an AnimatedSwitcher for a smooth transition between Grid and List
                    return AnimatedSwitcher(
                      duration: 400.ms,
                      child: _isGridView
                          ? _buildGridView(filteredList)
                          : _buildListView(filteredList),
                    );
                  },
                ),
              ),
            ],
          ),

          // The floating action bar for bulk actions
          if (_isEditMode && selectedItems.isNotEmpty)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child:
                  Card(
                        color: AppColors.darkSurface,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "${selectedItems.length} selected",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    child: const Text("Add to..."),
                                    onPressed: () {
                                      /* Add to custom list logic here */
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever_rounded,
                                      color: AppColors.darkErrorRed,
                                    ),
                                    onPressed: () {
                                      final service = FirestoreService();
                                      for (var mediaId in selectedItems) {
                                        service.removeFromList(
                                          'watchlist',
                                          mediaId,
                                        );
                                      }
                                      // Clear the selection after the action is done
                                      ref
                                          .read(
                                            multiSelectNotifierProvider
                                                .notifier,
                                          )
                                          .clear();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .slideY(
                        begin: 2.0,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(),
            ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> list) {
    return GridView.builder(
      key: const ValueKey('grid_view'), // Key for AnimatedSwitcher
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return SelectableItemCard(item: item, isEditMode: _isEditMode);
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> list) {
    return ListView.builder(
      key: const ValueKey('list_view'), // Key for AnimatedSwitcher
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return SelectableWatchlistItemTile(
          item: item,
          isEditMode: _isEditMode,
          mediaType: item.containsKey('title') ? MediaType.movie : MediaType.tv,
        );
      },
    );
  }
}
