import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/watched/watched_providers.dart';
import '../../../application/watchlist/multi_select_provider.dart';
import '../../../data/firestore/firestore_service.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../watchlist/widgets/selectable_item_card.dart';
import '../watchlist/widgets/selectable_watchlist_item_tile.dart';

class WatchedHistoryScreen extends ConsumerStatefulWidget {
  final String title;
  final MediaType initialFilter;

  const WatchedHistoryScreen({
    super.key,
    required this.title,
    required this.initialFilter,
  });

  @override
  ConsumerState<WatchedHistoryScreen> createState() =>
      _WatchedHistoryScreenState();
}

class _WatchedHistoryScreenState extends ConsumerState<WatchedHistoryScreen> {
  bool _isEditMode = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Clear any selections from other screens and set the initial filter
    Future.microtask(() => ref.read(multiSelectProvider.notifier).clear());
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        ref.read(multiSelectProvider.notifier).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchedAsync = ref.watch(watchedDetailsProvider);
    final selectedItems = ref.watch(multiSelectProvider);

    return WillPopScope(
      onWillPop: () async {
        if (_isEditMode) {
          _toggleEditMode();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkSurface,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: Icon(
                _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
              ),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
            TextButton(
              onPressed: _toggleEditMode,
              child: Text(
                _isEditMode ? "Done" : "Edit",
                style: const TextStyle(
                  color: AppColors.auroraPink,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            watchedAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
              data: (fullList) {
                // Filter the list based on the initial filter passed to the screen
                final filteredList = fullList.where((item) {
                  final isMovie = item.containsKey('title');
                  if (widget.initialFilter == MediaType.movie) return isMovie;
                  return !isMovie;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      "You haven't watched any ${widget.initialFilter == MediaType.movie ? "Movies" : "TV Shows"} yet.",
                    ),
                  );
                }

                return AnimatedSwitcher(
                  duration: 300.ms,
                  child: _isGridView
                      ? _buildGridView(filteredList)
                      : _buildListView(filteredList),
                );
              },
            ),
            if (_isEditMode && selectedItems.isNotEmpty)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Card(
                  color: AppColors.darkSurface,
                  elevation: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("${selectedItems.length} selected"),
                      TextButton.icon(
                        icon: const Icon(
                          Icons.delete_forever_rounded,
                          color: AppColors.darkErrorRed,
                        ),
                        label: const Text(
                          "Remove",
                          style: TextStyle(color: AppColors.darkErrorRed),
                        ),
                        onPressed: () {
                          final service = FirestoreService();
                          for (var mediaId in selectedItems) {
                            service.removeFromList('watched', mediaId);
                          }
                          ref.read(multiSelectProvider.notifier).clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> list) {
    return GridView.builder(
      key: const ValueKey('grid'),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) =>
          SelectableItemCard(item: list[index], isEditMode: _isEditMode),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> list) {
    return ListView.builder(
      key: const ValueKey('list'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) => SelectableWatchlistItemTile(
        item: list[index],
        isEditMode: _isEditMode,
        mediaType: list[index].containsKey('title')
            ? MediaType.movie
            : MediaType.tv,
      ),
    );
  }
}
