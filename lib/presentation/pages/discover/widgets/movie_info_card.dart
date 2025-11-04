// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import '../../../core/app_colors.dart';

// class MovieInfoCard extends StatelessWidget {
//   final Map<String, dynamic> movie;
//   final double swipeProgress; // The new property to receive swipe progress

//   const MovieInfoCard({
//     super.key,
//     required this.movie,
//     this.swipeProgress = 0.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final backdropPath = movie['backdrop_path'];
//     final posterPath = movie['poster_path'];
//     final title = movie['title'] ?? movie['name'] ?? 'No Title';
//     final overview = movie['overview'] ?? 'No overview available.';
//     final voteAverage = (movie['vote_average'] as num?)?.toDouble() ?? 0.0;
//     final releaseYear =
//         movie['release_date']?.substring(0, 4) ??
//         movie['first_air_date']?.substring(0, 4) ??
//         'N/A';

//     // Calculate opacities for the overlays based on swipe direction
//     final likeOpacity = swipeProgress.clamp(0.0, 1.0);
//     final nopeOpacity = (-swipeProgress).clamp(0.0, 1.0);

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         color: AppColors.darkSurface,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.5),
//             blurRadius: 25,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(24),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             if (backdropPath != null)
//               Image.network(
//                 'https://image.tmdb.org/t/p/w1280$backdropPath',
//                 fit: BoxFit.cover,
//               ),
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.transparent,
//                     AppColors.darkBackground.withValues(alpha: 0.9),
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   stops: const [0.5, 1],
//                 ),
//               ),
//             ),
//             // --- ACTION OVERLAYS ---
//             _buildActionOverlay(
//               angle: -pi / 15,
//               opacity: likeOpacity,
//               color: Colors.green,
//               icon: FontAwesomeIcons.thumbsUp,
//               text: "LIKE",
//             ),
//             _buildActionOverlay(
//               angle: pi / 15,
//               opacity: nopeOpacity,
//               color: Colors.red,
//               icon: FontAwesomeIcons.thumbsDown,
//               text: "NOPE",
//             ),
//             // --- END ACTION OVERLAYS ---
//             Positioned(
//               bottom: 24,
//               left: 24,
//               right: 24,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       if (posterPath != null)
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.network(
//                             'https://image.tmdb.org/t/p/w500$posterPath',
//                             height: 150,
//                             width: 100,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Text(
//                               title,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "Action, Comedy, Drama",
//                               style: TextStyle(
//                                 color: Colors.white.withValues(alpha: 0.7),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       const FaIcon(
//                         FontAwesomeIcons.solidStar,
//                         color: Colors.amber,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         voteAverage.toStringAsFixed(1),
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(width: 16),
//                       const FaIcon(
//                         FontAwesomeIcons.solidCalendar,
//                         color: Colors.white70,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(releaseYear),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     overview,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionOverlay({
//     required double angle,
//     required double opacity,
//     required Color color,
//     required IconData icon,
//     required String text,
//   }) {
//     return Opacity(
//       opacity: opacity,
//       child: Center(
//         child: Transform.rotate(
//           angle: angle,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             decoration: BoxDecoration(
//               border: Border.all(color: color, width: 4),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/presentation/pages/discover/widgets/movie_info_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../detail/movie_detail_screen.dart';
import '../../detail/tv_show_detail_screen.dart';

class MovieInfoCard extends StatelessWidget {
  final Map<String, dynamic> movie;

  // The swipeProgress parameter is no longer needed
  const MovieInfoCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final backdropPath = movie['backdrop_path'];
    final posterPath = movie['poster_path'];
    final title = movie['title'] ?? movie['name'] ?? 'No Title';
    final overview = movie['overview'] ?? 'No overview available.';
    final voteAverage = (movie['vote_average'] as num?)?.toDouble() ?? 0.0;
    final releaseYear =
        movie['release_date']?.substring(0, 4) ??
        movie['first_air_date']?.substring(0, 4) ??
        'N/A';

    return GestureDetector(
      onTap: () {
        // Now it correctly uses the passed-in properties to navigate.
        Widget screen;
        final mediaId = movie['id'] as int;
        print('Navigating to details for media ID: $mediaId');
        final String typeString =
            movie['media_type'] ??
            (movie.containsKey('title') ? 'movie' : 'tv');
        final mediaType = typeString == 'tv' ? MediaType.tv : MediaType.movie;
        if (mediaType == MediaType.movie) {
          screen = MovieDetailScreen(mediaId: mediaId);
        } else {
          screen = TvShowDetailScreen(mediaId: mediaId);
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.darkSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (backdropPath != null)
                Image.network(
                  'https://image.tmdb.org/t/p/w1280$backdropPath',
                  fit: BoxFit.cover,
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.darkBackground.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1],
                  ),
                ),
              ),
              // The overlay logic is removed, simplifying the widget
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (posterPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w500$posterPath',
                              height: 150,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Action, Comedy, Drama",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.solidStar,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          voteAverage.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        const FaIcon(
                          FontAwesomeIcons.solidCalendar,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(releaseYear),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
