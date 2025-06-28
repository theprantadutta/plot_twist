import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../application/profile/profile_providers.dart';
import '../../../../data/local/persistence_service.dart';
import '../../../core/app_colors.dart';
import '../../watched/watched_history_screen.dart';

class WatchlistStatsComponent extends ConsumerWidget {
  const WatchlistStatsComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can reuse the same providers from the Profile screen
    final moviesWatched =
        ref.watch(watchedMoviesCountProvider).asData?.value ?? 0;
    final showsWatched =
        ref.watch(watchedTvShowsCountProvider).asData?.value ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistics",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
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
                  value: moviesWatched.toString(),
                  label: "Movies Watched",
                  icon: FontAwesomeIcons.film,
                  color: AppColors.auroraPink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
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
                  value: showsWatched.toString(),
                  label: "Shows Watched",
                  icon: FontAwesomeIcons.tv,
                  color: AppColors.darkStarlightGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
