import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../application/custom_list/custom_list_providers.dart';
import '../../../data/firestore/firestore_service.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../home/widgets/poster_card.dart';

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

  @override
  Widget build(BuildContext context) {
    // Watch the providers for this specific list
    final listDetailsAsync = ref.watch(customListStreamProvider(widget.listId));
    final listItemsAsync = ref.watch(
      customListItemsDetailsProvider(widget.listId),
    );
    final listName =
        (listDetailsAsync.asData?.value.data()
            as Map<String, dynamic>?)?['name'] ??
        'List';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: Text(listName),
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
      body: listItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_filter_outlined,
                    size: 80,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "This list is empty",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Add movies and shows to see them here.",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final mediaId = item['id'].toString();
              final posterPath = item['poster_path'];

              if (posterPath == null) return const SizedBox.shrink();

              return Stack(
                children: [
                  PosterCard(
                    // We need to pass all required fields to PosterCard
                    mediaId: item['id'],
                    mediaType: item.containsKey('title')
                        ? MediaType.movie
                        : MediaType.tv,
                    posterPath: posterPath,
                    voteAverage:
                        (item['vote_average'] as num?)?.toDouble() ?? 0.0,
                  ),
                  if (_isEditMode)
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: 300.ms,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withOpacity(0.6),
                        ),
                        child: Center(
                          child: IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.trashCan,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              FirestoreService().removeMediaFromCustomList(
                                widget.listId,
                                mediaId,
                              );
                            },
                          ),
                        ),
                      ).animate().fadeIn(),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
