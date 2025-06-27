// // lib/presentation/pages/profile/widgets/stat_grid.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import '../../../../application/profile/profile_providers.dart';
// import '../../../core/app_colors.dart';

// class StatGrid extends ConsumerWidget {
//   const StatGrid({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final moviesWatched =
//         ref.watch(watchedMoviesCountProvider).asData?.value ?? 0;
//     final showsWatched =
//         ref.watch(watchedTvShowsCountProvider).asData?.value ?? 0;
//     final moviesWatchlist =
//         ref.watch(watchlistMoviesCountProvider).asData?.value ?? 0;
//     final showsWatchlist =
//         ref.watch(watchlistTvShowsCountProvider).asData?.value ?? 0;

//     return GridView.count(
//       crossAxisCount: 2,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       childAspectRatio: 1.8, // Make cards wider than they are tall
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       children: [
//         _StatCard(
//           value: moviesWatched.toString(),
//           label: "Movies Watched",
//           icon: FontAwesomeIcons.film,
//         ),
//         _StatCard(
//           value: showsWatched.toString(),
//           label: "TV Shows Watched",
//           icon: FontAwesomeIcons.tv,
//         ),
//         _StatCard(
//           value: moviesWatchlist.toString(),
//           label: "Movie Watchlist",
//           icon: FontAwesomeIcons.video,
//         ),
//         _StatCard(
//           value: showsWatchlist.toString(),
//           label: "TV Show Watchlist",
//           icon: FontAwesomeIcons.video,
//         ),
//       ],
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String value;
//   final String label;
//   final IconData icon;

//   const _StatCard({
//     required this.value,
//     required this.label,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.darkSurface,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             spacing: 10,
//             children: [
//               FaIcon(icon, color: AppColors.auroraPink, size: 24),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           Text(
//             label,
//             style: const TextStyle(color: AppColors.darkTextSecondary),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../application/profile/profile_providers.dart';
import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../watched/watched_history_screen.dart';

class StatGrid extends ConsumerWidget {
  const StatGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesWatched =
        ref.watch(watchedMoviesCountProvider).asData?.value ?? 0;
    final showsWatched =
        ref.watch(watchedTvShowsCountProvider).asData?.value ?? 0;
    final moviesWatchlist =
        ref.watch(watchlistMoviesCountProvider).asData?.value ?? 0;
    final showsWatchlist =
        ref.watch(watchlistTvShowsCountProvider).asData?.value ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // --- THIS IS THE CHANGE: WRAP STAT CARDS IN INKWELL ---
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const WatchedHistoryScreen(
                  title: "Movies Watched",
                  initialFilter: MediaType.movie,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: _StatCard(
            value: moviesWatched.toString(),
            label: "Movies Watched",
            icon: FontAwesomeIcons.film,
            color: AppColors.auroraPink,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const WatchedHistoryScreen(
                  title: "Shows Watched",
                  initialFilter: MediaType.tv,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: _StatCard(
            value: showsWatched.toString(),
            label: "Shows Watched",
            icon: FontAwesomeIcons.tv,
            color: AppColors.darkStarlightGold,
          ),
        ),
        // We can make the watchlist cards tappable later to go to the FullWatchlistScreen
        _StatCard(
          value: moviesWatchlist.toString(),
          label: "Movie Watchlist",
          icon: FontAwesomeIcons.video,
          color: AppColors.darkInfoCyan,
        ),
        _StatCard(
          value: showsWatchlist.toString(),
          label: "Shows Watchlist",
          icon: FontAwesomeIcons.video,
          color: AppColors.darkInfoCyan,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          FaIcon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
