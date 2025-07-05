// lib/presentation/pages/home/home_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 2. Create state variables for the controller and timer
  final PageController _spotlightController = PageController();
  Timer? _spotlightTimer;

  // 3. A method to start the timer
  void _startSpotlightTimer(int pageCount) {
    // Ensure we don't create multiple timers
    if (_spotlightTimer != null && _spotlightTimer!.isActive) {
      return;
    }

    _spotlightTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_spotlightController.hasClients) return;

      if (context.mounted == false) {
        return;
      }

      int nextPage = _spotlightController.page!.round() + 1;

      // If we reach the end, loop back to the start
      if (nextPage >= pageCount) {
        nextPage = 0;
      }

      _spotlightController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  // 4. Make sure to cancel the timer and dispose the controller when the screen is removed
  @override
  void dispose() {
    _spotlightTimer?.cancel();
    _spotlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          child: Image.asset('assets/images/logo_transparent.png'),
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SpotlightShimmer();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nothing to see here.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  final items = snapshot.data!;
                  final pageCount = items.length > 10 ? 10 : items.length;

                  // 5. Start the timer once we have the data
                  _startSpotlightTimer(pageCount);
                  return PageView.builder(
                    controller: _spotlightController,
                    itemCount: pageCount,
                    itemBuilder: (context, index) => SpotlightCard(
                      movie: items[index],
                      mediaType: selectedType,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // All carousels now conditionally fetch data
            MovieCarouselSection(
              title: "Your Watchlist",
              future: tmdbRepository.getWatchlist(), // Fetches both types
              onEmptyWidget: const EmptyWatchlistWidget(),
              mediaTypeFilter: selectedType, // <-- We now pass the filter here
            ),
            const SizedBox(height: 16),
            MovieCarouselSection(
              title: "Trending This Week",
              // Use a ternary operator to call the correct new method
              future: selectedType == MediaType.movie
                  ? tmdbRepository.getTrendingMoviesWeek()
                  : tmdbRepository.getTrendingTvShowsWeek(),
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
            const SizedBox(height: 120),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms),
    );
  }
}
