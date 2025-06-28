// lib/presentation/pages/profile/widgets/favorites_preview_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../application/favorites/favorites_providers.dart';
import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../favorites/favorites_screen.dart';
import '../../home/widgets/poster_card.dart';
import '../../home/widgets/shimmer_loaders.dart';

class FavoritesPreviewSection extends ConsumerWidget {
  const FavoritesPreviewSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesDetailsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Favorites", style: Theme.of(context).textTheme.titleLarge),
              // --- ADD THE "VIEW ALL" BUTTON ---
              favoritesAsync.when(
                data: (items) =>
                    items.length >
                        5 // Only show if there are more than 5
                    ? TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FavoritesScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "View All",
                          style: TextStyle(color: AppColors.auroraPink),
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: favoritesAsync.when(
            loading: () => const CarouselShimmer(),
            error: (err, stack) =>
                const Center(child: Text("Could not load favorites.")),
            data: (items) {
              if (items.isEmpty) {
                return const EmptyStateWidget(
                  icon: FontAwesomeIcons.solidHeart,
                  title: "No Favorites Yet",
                  message: "Like a movie or show to see it here.",
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: items.length > 10 ? 10 : items.length, // Show max 10
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item['poster_path'] == null || item['id'] == null) {
                    return const SizedBox.shrink();
                  }

                  return PosterCard(
                    mediaId: item['id'],
                    mediaType: item.containsKey('title')
                        ? MediaType.movie
                        : MediaType.tv,
                    posterPath: item['poster_path'],
                    voteAverage:
                        (item['vote_average'] as num?)?.toDouble() ?? 0.0,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
