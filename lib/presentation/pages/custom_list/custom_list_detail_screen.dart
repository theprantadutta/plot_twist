// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import '../../../application/custom_list/custom_list_providers.dart';
// import '../../../data/firestore/firestore_service.dart';
// import '../../../data/local/persistence_service.dart';
// import '../../core/app_colors.dart';
// import '../home/widgets/poster_card.dart';

// class CustomListDetailScreen extends ConsumerStatefulWidget {
//   final String listId;
//   const CustomListDetailScreen({super.key, required this.listId});

//   @override
//   ConsumerState<CustomListDetailScreen> createState() =>
//       _CustomListDetailScreenState();
// }

// class _CustomListDetailScreenState
//     extends ConsumerState<CustomListDetailScreen> {
//   bool _isEditMode = false;

//   @override
//   Widget build(BuildContext context) {
//     // Watch the providers for this specific list
//     final listDetailsAsync = ref.watch(customListStreamProvider(widget.listId));
//     final listItemsAsync = ref.watch(
//       customListItemsDetailsProvider(widget.listId),
//     );
//     final listName =
//         (listDetailsAsync.asData?.value.data()
//             as Map<String, dynamic>?)?['name'] ??
//         'List';

//     return Scaffold(
//       backgroundColor: AppColors.darkBackground,
//       appBar: AppBar(
//         backgroundColor: AppColors.darkBackground,
//         title: Text(listName),
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
//       body: listItemsAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text("Error: $err")),
//         data: (items) {
//           if (items.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.movie_filter_outlined,
//                     size: 80,
//                     color: Colors.white24,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     "This list is empty",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Add movies and shows to see them here.",
//                     style: TextStyle(color: Colors.white70),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             );
//           }
//           return GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               childAspectRatio: 2 / 3,
//               mainAxisSpacing: 16,
//               crossAxisSpacing: 16,
//             ),
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               final item = items[index];
//               final mediaId = item['id'].toString();
//               final posterPath = item['poster_path'];

//               if (posterPath == null) return const SizedBox.shrink();

//               return Stack(
//                 children: [
//                   PosterCard(
//                     // We need to pass all required fields to PosterCard
//                     mediaId: item['id'],
//                     mediaType: item.containsKey('title')
//                         ? MediaType.movie
//                         : MediaType.tv,
//                     posterPath: posterPath,
//                     voteAverage:
//                         (item['vote_average'] as num?)?.toDouble() ?? 0.0,
//                   ),
//                   if (_isEditMode)
//                     Positioned.fill(
//                       child: AnimatedContainer(
//                         duration: 300.ms,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: Colors.black.withOpacity(0.6),
//                         ),
//                         child: Center(
//                           child: IconButton(
//                             icon: const FaIcon(
//                               FontAwesomeIcons.trashCan,
//                               color: Colors.white,
//                             ),
//                             onPressed: () {
//                               FirestoreService().removeMediaFromCustomList(
//                                 widget.listId,
//                                 mediaId,
//                               );
//                             },
//                           ),
//                         ),
//                       ).animate().fadeIn(),
//                     ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/custom_list/custom_list_providers.dart';
import '../../../application/watchlist/multi_select_provider.dart';
import '../../../data/firestore/firestore_service.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../watchlist/widgets/selectable_item_card.dart';
import '../watchlist/widgets/selectable_watchlist_item_tile.dart';

class CustomListDetailScreen extends ConsumerStatefulWidget {
  final String listId;
  const CustomListDetailScreen({super.key, required this.listId});

  @override
  ConsumerState<CustomListDetailScreen> createState() =>
      _CustomListDetailScreenState();
}

class _CustomListDetailScreenState
    extends ConsumerState<CustomListDetailScreen> {
  bool _isEditMode = false;
  bool _isGridView = true;

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        ref.read(multiSelectNotifierProvider.notifier).clear();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Clear any selections from other screens when this screen is first built
    Future.microtask(
      () => ref.read(multiSelectNotifierProvider.notifier).clear(),
    );
  }

  @override
  void dispose() {
    // Also clear selections when leaving the screen
    Future.microtask(
      () => ref.read(multiSelectNotifierProvider.notifier).clear(),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listDetailsAsync = ref.watch(customListStreamProvider(widget.listId));
    final listItemsAsync = ref.watch(
      customListItemsDetailsProvider(widget.listId),
    );
    final listName =
        (listDetailsAsync.asData?.value.data()
            as Map<String, dynamic>?)?['name'] ??
        'List';
    final selectedItems = ref.watch(multiSelectNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Text(listName),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: "Toggle View",
          ),
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
      body: Stack(
        children: [
          listItemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    "This list is empty. Add some items!",
                    style: TextStyle(color: AppColors.darkTextSecondary),
                  ),
                );
              }
              return AnimatedSwitcher(
                duration: 300.ms,
                child: _isGridView
                    ? _buildGridView(items)
                    : _buildListView(items),
              );
            },
          ),
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
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.delete_forever_rounded,
                                  color: AppColors.darkErrorRed,
                                ),
                                label: const Text(
                                  "Remove",
                                  style: TextStyle(
                                    color: AppColors.darkErrorRed,
                                  ),
                                ),
                                onPressed: () {
                                  final service = FirestoreService();
                                  for (var mediaId in selectedItems) {
                                    service.removeMediaFromCustomList(
                                      widget.listId,
                                      mediaId,
                                    );
                                  }
                                  ref
                                      .read(
                                        multiSelectNotifierProvider.notifier,
                                      )
                                      .clear();
                                },
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
      key: const ValueKey('grid_view'),
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
        // We can reuse the same selectable card here
        return SelectableItemCard(item: item, isEditMode: _isEditMode);
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> list) {
    return ListView.builder(
      key: const ValueKey('list_view'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        // We reuse the selectable tile from the main watchlist screen
        return SelectableWatchlistItemTile(
          item: item,
          isEditMode: _isEditMode,
          mediaType: item.containsKey('title') ? MediaType.movie : MediaType.tv,
        );
      },
    );
  }
}
