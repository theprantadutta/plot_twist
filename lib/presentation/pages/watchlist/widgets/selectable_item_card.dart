// lib/presentation/pages/watchlist/widgets/selectable_item_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/watchlist/multi_select_provider.dart';
import '../../../../data/local/persistence_service.dart';
import '../../home/widgets/poster_card.dart';

class SelectableItemCard extends ConsumerWidget {
  final Map<String, dynamic> item;
  final bool isEditMode;

  const SelectableItemCard({
    super.key,
    required this.item,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaId = item['id'].toString();
    final selectedItems = ref.watch(multiSelectProvider);
    final notifier = ref.read(multiSelectProvider.notifier);
    final isSelected = selectedItems.contains(mediaId);

    return GestureDetector(
      onTap: () {
        if (isEditMode) {
          notifier.toggle(mediaId);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          PosterCard(
            mediaId: item['id'],
            mediaType: item.containsKey('title')
                ? MediaType.movie
                : MediaType.tv,
            posterPath: item['poster_path'],
            voteAverage: (item['vote_average'] as num?)?.toDouble() ?? 0.0,
          ),
          // Show overlay and checkmark if in edit mode and selected
          if (isEditMode)
            AnimatedContainer(
              duration: 200.ms,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.3),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 40,
                    )
                  : const SizedBox.shrink(),
            ).animate().fade(),
        ],
      ),
    );
  }
}
