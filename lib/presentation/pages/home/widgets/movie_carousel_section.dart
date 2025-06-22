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
  final MediaType? mediaTypeFilter; // <-- ADD THIS OPTIONAL FILTER

  const MovieCarouselSection({
    super.key,
    required this.title,
    required this.future,
    this.onEmptyWidget,
    this.mediaTypeFilter, // <-- ADD TO CONSTRUCTOR
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

              List<Map<String, dynamic>> items = snapshot.data!;

              // --- THIS IS THE NEW FILTERING LOGIC ---
              if (mediaTypeFilter != null) {
                items = items.where((item) {
                  final typeString =
                      item['media_type'] ??
                      (item.containsKey('title') ? 'movie' : 'tv');
                  return typeString == mediaTypeFilter!.name;
                }).toList();
              }
              // ----------------------------------------

              // If the list is empty *after* filtering
              if (items.isEmpty) {
                return onEmptyWidget ??
                    const Center(
                      child: Text(
                        "No items found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item['poster_path'] == null || item['id'] == null) {
                    return const SizedBox.shrink();
                  }

                  final voteAverage =
                      (item['vote_average'] as num?)?.toDouble() ?? 0.0;
                  final mediaId = item['id'] as int;
                  final typeString =
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
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
