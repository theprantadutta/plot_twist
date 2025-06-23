// lib/presentation/pages/home/widgets/spotlight_card.dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../detail/movie_detail_screen.dart';
import '../../detail/tv_show_detail_screen.dart';

class SpotlightCard extends StatelessWidget {
  final Map<String, dynamic> movie;
  final MediaType mediaType;
  const SpotlightCard({
    super.key,
    required this.movie,
    required this.mediaType,
  });

  @override
  Widget build(BuildContext context) {
    final backdropPath = movie['backdrop_path'];
    final title = movie['title'] ?? movie['name'] ?? 'No Title';
    final mediaId = movie['id'] as int;
    return GestureDetector(
      onTap: () {
        // Now it correctly uses the passed-in properties to navigate.
        Widget screen;
        if (mediaType == MediaType.movie) {
          screen = MovieDetailScreen(mediaId: mediaId);
        } else {
          screen = TvShowDetailScreen(mediaId: mediaId);
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://image.tmdb.org/t/p/w1280$backdropPath',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: AppColors.darkSurface),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black, Colors.black.withOpacity(0.0)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              "View",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
