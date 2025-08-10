// lib/presentation/pages/favorites/favorites_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/favorites/favorites_providers.dart';
import '../../../application/watchlist/watchlist_providers.dart';
import '../../../data/firestore/firestore_service.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../watchlist/widgets/selectable_item_card.dart';
import '../watchlist/widgets/selectable_watchlist_item_tile.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _isEditMode = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    // Clear any selections from other screens when this screen is first built
    Future.microtask(
      () => ref.read(multiSelectNotifierProvider.notifier).clear(),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        ref.read(multiSelectNotifierProvider.notifier).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoritesDetailsProvider);
    final currentFilter = ref.watch(favoritesFilterNotifierProvider);
    final filterNotifier = ref.read(favoritesFilterNotifierProvider.notifier);
    final selectedItems = ref.watch(multiSelectNotifierProvider);

    return PopScope(
      canPop: !_isEditMode,
      onPopInvoked: (didPop) {
        if (!didPop && _isEditMode) {
          _toggleEditMode();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkSurface,
          title: const Text("All Favorites"),
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
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: CupertinoSlidingSegmentedControl<FavoritesFilter>(
                    groupValue: currentFilter,
                    backgroundColor: AppColors.darkSurface,
                    thumbColor: AppColors.auroraPink,
                    onValueChanged: (filter) => filter != null
                        ? filterNotifier.setFilter(filter)
                        : null,
                    children: const {
                      FavoritesFilter.all: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("All"),
                      ),
                      FavoritesFilter.movies: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Movies"),
                      ),
                      FavoritesFilter.tvShows: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("TV Shows"),
                      ),
                    },
                  ),
                ),
                Expanded(
                  child: favoritesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text("Error: $err")),
                    data: (fullList) {
                      final filteredList = fullList.where((item) {
                        if (currentFilter == FavoritesFilter.all) return true;
                        final isMovie = item.containsKey('title');
                        if (currentFilter == FavoritesFilter.movies) {
                          return isMovie;
                        }
                        return !isMovie;
                      }).toList();

                      if (filteredList.isEmpty) {
                        return const Center(
                          child: Text(
                            "No favorites found for this filter.",
                            style: TextStyle(
                              color: AppColors.darkTextSecondary,
                            ),
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
                ),
              ],
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "${selectedItems.length} selected",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
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
                                      service.removeFromList(
                                        'favorites',
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
      itemBuilder: (context, index) =>
          SelectableItemCard(item: list[index], isEditMode: _isEditMode),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> list) {
    return ListView.builder(
      key: const ValueKey('list_view'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return SelectableWatchlistItemTile(
          item: list[index],
          isEditMode: _isEditMode,
          mediaType: list[index].containsKey('title')
              ? MediaType.movie
              : MediaType.tv,
        );
      },
    );
  }
}
