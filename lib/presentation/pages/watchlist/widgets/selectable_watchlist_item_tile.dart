import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/watchlist/watchlist_providers.dart';
import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../detail/movie_detail_screen.dart';
import '../../detail/tv_show_detail_screen.dart';
import 'watchlist_item_tile.dart';

class SelectableWatchlistItemTile extends ConsumerWidget {
  final Map<String, dynamic> item;
  final bool isEditMode;
  final MediaType mediaType;

  const SelectableWatchlistItemTile({
    super.key,
    required this.item,
    required this.isEditMode,
    required this.mediaType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaId = item['id'].toString();
    final selectedItems = ref.watch(multiSelectNotifierProvider);
    final notifier = ref.read(multiSelectNotifierProvider.notifier);
    final isSelected = selectedItems.contains(mediaId);

    return InkWell(
      onTap: () {
        if (isEditMode) {
          notifier.toggle(mediaId);
        } else {
          // Now it correctly uses the passed-in properties to navigate.
          Widget screen;
          if (mediaType == MediaType.movie) {
            screen = MovieDetailScreen(mediaId: int.parse(mediaId));
          } else {
            screen = TvShowDetailScreen(mediaId: int.parse(mediaId));
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.auroraPink.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IgnorePointer(
          // Ignore taps on the tile itself if in edit mode, so the InkWell handles it
          ignoring: isEditMode,
          child: WatchlistItemTile(item: item),
        ),
      ),
    );
  }
}
