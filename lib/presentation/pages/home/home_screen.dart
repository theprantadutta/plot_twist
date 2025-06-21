// lib/presentation/pages/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/tmdb/tmdb_repository.dart';
import '../../../application/discover/discover_providers.dart';
import '../../../application/home/home_providers.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../search/search_screen.dart';
import 'widgets/empty_watchlist_widget.dart';
import 'widgets/media_type_toggle.dart';
import 'widgets/movie_carousel_section.dart';
import 'widgets/shimmer_loaders.dart';
import 'widgets/spotlight_card.dart';

// Now a ConsumerWidget to use Riverpod
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our new provider. The UI will rebuild whenever this changes.
    final selectedType = ref.watch(mediaTypeNotifierProvider);

    // We can keep a single repository instance
    final tmdbRepository = TmdbRepository();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      // The new AppBar design as you requested
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/logo.png',
          ), // Using the logo as an icon
        ),
        leadingWidth: 40,
        title: const Text("Home"),
        actions: [
          // --- THIS IS THE CHANGE ---
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // Reset search query when opening the page
              ref.read(searchQueryNotifierProvider.notifier).setQuery('');
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          // ---------------------------
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: MediaTypeToggle(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Spotlight Carousel now dynamically changes content
            SizedBox(
              height: 250,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: selectedType == MediaType.movie
                    ? tmdbRepository.getTrendingMoviesDay()
                    : tmdbRepository.getTrendingTvShowsDay(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const SpotlightShimmer();
                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return const Center(
                      child: Text(
                        "Nothing to see here.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  final items = snapshot.data!;
                  return PageView.builder(
                    itemCount: items.length > 5 ? 5 : items.length,
                    itemBuilder: (context, index) =>
                        SpotlightCard(movie: items[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // All carousels now conditionally fetch data
            MovieCarouselSection(
              title: "Your Watchlist",
              future: tmdbRepository
                  .getWatchlist(), // Watchlist can contain both types
              onEmptyWidget: const EmptyWatchlistWidget(),
            ),
            const SizedBox(height: 16),
            MovieCarouselSection(
              title: "Trending This Week",
              future: tmdbRepository
                  .getTrendingAllWeek(), // 'all' includes both
            ),
            const SizedBox(height: 16),
            MovieCarouselSection(
              title: selectedType == MediaType.movie
                  ? "Top Rated Movies"
                  : "Top Rated TV Shows",
              future: selectedType == MediaType.movie
                  ? tmdbRepository.getTopRatedMovies()
                  : tmdbRepository.getTopRatedTvShows(),
            ),
            const SizedBox(height: 16),
            if (selectedType == MediaType.movie) ...[
              // Only show "Coming Soon" for movies
              MovieCarouselSection(
                title: "Coming Soon",
                future: tmdbRepository.getUpcomingMovies(),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms),
    );
  }
}
