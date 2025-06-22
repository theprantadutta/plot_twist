// lib/presentation/pages/home/widgets/movie_carousel_section.dart
import 'package:flutter/material.dart';

import '../../../../data/local/persistence_service.dart';
import 'poster_card.dart';
import 'section_header.dart';
import 'shimmer_loaders.dart';

class MovieCarouselSection extends StatelessWidget {
  final String title;
  final Future<List<Map<String, dynamic>>> future;
  final Widget? onEmptyWidget;

  const MovieCarouselSection({
    super.key,
    required this.title,
    required this.future,
    this.onEmptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 8),
        SizedBox(
          height: 210,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CarouselShimmer();
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Oops! Something went wrong.",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return onEmptyWidget ??
                    const Center(
                      child: Text(
                        "No items found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
              }

              final items = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item['poster_path'] == null)
                    return const SizedBox.shrink();

                  final voteAverage =
                      (item['vote_awesome'] as num?)?.toDouble() ?? 0.0;
                  final mediaId = item['id'] as int;

                  // Infer the media type. Some TMDB endpoints provide 'media_type',
                  // others don't. We can check for 'title' (movie) vs 'name' (TV) as a fallback.
                  final String typeString =
                      item['media_type'] ??
                      (item.containsKey('title') ? 'movie' : 'tv');
                  final mediaType = typeString == 'tv'
                      ? MediaType.tv
                      : MediaType.movie;

                  return PosterCard(
                    mediaId: mediaId,
                    mediaType: mediaType,
                    posterPath: item['poster_path'],
                    voteAverage: voteAverage,
                  );
                  // ---------------------------
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
