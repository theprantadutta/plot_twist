// lib/presentation/pages/home/home_screen.dart
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../../../data/tmdb/tmdb_repository.dart';
import '../../../application/discover/discover_providers.dart';
import '../../../application/home/home_providers.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../search/search_screen.dart';
import '../settings/legal_document_screen.dart';
import 'widgets/empty_watchlist_widget.dart';
import 'widgets/media_type_toggle.dart';
import 'widgets/movie_carousel_section.dart';
import 'widgets/shimmer_loaders.dart';
import 'widgets/spotlight_card.dart';
import '../../core/widgets/cinematic_hero_card.dart';
import '../../core/widgets/library_section_card.dart';
import '../../core/widgets/skeleton_loading.dart';

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

  Future<void> _checkForMaintenanceAndAppUpdate() async {
    debugPrint('Running checkForMaintenanceAndAppUpdate...');

    // A check to ensure the widget is still mounted before showing dialogs.
    if (!mounted) return;

    try {
      // --- Step 1: Check for an App Update using the in_app_update package ---
      // This talks directly to the Google Play Store.
      debugPrint("Checking for update via in_app_update package...");
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      // If an update is available...
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        debugPrint("Update available. Starting flexible update flow.");

        // Start a user-friendly flexible update.
        // This downloads the update in the background while the user can still use the app.
        await InAppUpdate.startFlexibleUpdate();

        // Once the download is complete, this line will trigger a snackbar
        // prompting the user to restart the app to complete the installation.
        await InAppUpdate.completeFlexibleUpdate();

        debugPrint("Flexible update flow completed.");
      } else {
        debugPrint("No update available.");
      }

      // Your old code for manual version comparison is no longer needed for the update check.
      // The `in_app_update` package handles this automatically.
    } catch (e) {
      debugPrint('Something went wrong during the check: $e');
      // You can optionally show a non-intrusive error message here if needed.
    }
  }

  Future<void> _checkAndShowTermsDialog() async {
    // We now use our Riverpod provider to access the persistence service
    final persistenceService = ref.read(persistenceServiceProvider);

    if (persistenceService.hasAcceptedTerms()) {
      return;
    }

    if (!mounted) return;

    bool isChecked = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Welcome to PlotTwists!'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text(
                      'Before you begin, please review and accept our policies to continue.',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            setDialogState(() => isChecked = value ?? false);
                          },
                          activeColor: AppColors.auroraPink,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.darkTextSecondary,
                                    ),
                                children: [
                                  const TextSpan(
                                    text: 'I have read and agree to the ',
                                  ),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: const TextStyle(
                                      color: AppColors.auroraPink,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () =>
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LegalDocumentScreen(
                                                    title: 'Terms & Conditions',
                                                    markdownAssetPath:
                                                        'assets/legal/terms.md',
                                                  ),
                                            ),
                                          ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: AppColors.auroraPink,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LegalDocumentScreen(
                                                title: 'Privacy Policy',
                                                markdownAssetPath:
                                                    'assets/legal/privacy.md',
                                              ),
                                        ),
                                      ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  // The button is disabled until the box is checked
                  onPressed: isChecked
                      ? () async {
                          await persistenceService.setHasAcceptedTerms(true);
                          Navigator.of(dialogContext).pop();
                        }
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor: isChecked
                        ? AppColors.auroraPink
                        : AppColors.darkSurface,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.darkSurface.withOpacity(
                      0.5,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkForMaintenanceAndAppUpdate();
      await _checkAndShowTermsDialog();
    });
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
                    itemBuilder: (context, index) => CinematicHeroCard(
                      movie: items[index],
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
