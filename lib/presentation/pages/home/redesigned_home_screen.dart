import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/discover/discover_providers.dart';
import '../../../application/home/home_providers.dart';
import '../../../data/local/persistence_service.dart';
import '../../../data/tmdb/tmdb_repository.dart';
import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../core/app_animations.dart';
import '../../core/widgets/cinematic_hero_card.dart';
import '../../core/widgets/library_section_card.dart';
import '../../core/widgets/cinematic_app_bar.dart';
import '../search/search_screen.dart';
import 'widgets/enhanced_personalized_recommendations.dart';
import '../../core/widgets/cinematic_refresh_indicator.dart';
import 'widgets/cinematic_skeleton_loaders.dart';
import 'widgets/parallax_hero_section.dart';

/// Redesigned home screen with cinematic UI and enhanced user experience
class RedesignedHomeScreen extends ConsumerStatefulWidget {
  const RedesignedHomeScreen({super.key});

  @override
  ConsumerState<RedesignedHomeScreen> createState() =>
      _RedesignedHomeScreenState();
}

class _RedesignedHomeScreenState extends ConsumerState<RedesignedHomeScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _heroController = PageController();
  Timer? _heroTimer;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double _scrollOffset = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
    _initializeContent();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: MotionPresets.slideUp.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: MotionPresets.slideUp.curve,
          ),
        );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  Future<void> _initializeContent() async {
    // Simulate loading time for smooth animation
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      _fadeController.forward();
      _slideController.forward();
    }
  }

  void _startHeroTimer(int pageCount) {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!_heroController.hasClients || !mounted) return;

      final currentPage = _heroController.page?.round() ?? 0;
      final nextPage = (currentPage + 1) % pageCount;

      _heroController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _scrollController.dispose();
    _heroController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(mediaTypeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      extendBodyBehindAppBar: true,
      appBar: _buildDynamicAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildContent(selectedType),
    );
  }

  PreferredSizeWidget _buildDynamicAppBar() {
    // Dynamic app bar that changes based on scroll position
    final isScrolled = _scrollOffset > 100;

    return isScrolled
        ? GlassmorphismAppBar(
            title: 'PlotTwists',
            actions: _buildAppBarActions(),
          )
        : TransparentOverlayAppBar(
            titleWidget: _buildLogoTitle(),
            actions: _buildAppBarActions(),
          );
  }

  Widget _buildLogoTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [AppColors.cinematicGold, AppColors.cinematicRed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.movie_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'PlotTwists',
          style: AppTypography.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () {
          ref.read(searchQueryNotifierProvider.notifier).setQuery('');
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
        },
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildLoadingState() {
    return const CinematicSkeletonLoaders();
  }

  Widget _buildContent(MediaType selectedType) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CinematicRefreshIndicator(
          onRefresh: () => _refreshContent(selectedType),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Section with Parallax
              _buildHeroSection(selectedType),

              // Content Sections
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Enhanced Personalized Recommendations
                    EnhancedPersonalizedRecommendations(
                      mediaType: selectedType,
                      onRefresh: () => _refreshRecommendations(),
                    ),

                    const SizedBox(height: 24),

                    // Your Watchlist
                    _buildWatchlistSection(selectedType),

                    const SizedBox(height: 24),

                    // Trending Content
                    _buildTrendingSection(selectedType),

                    const SizedBox(height: 24),

                    // Top Rated Content
                    _buildTopRatedSection(selectedType),

                    const SizedBox(height: 24),

                    // Conditional Sections
                    if (selectedType == MediaType.movie) ...[
                      _buildUpcomingSection(),
                      const SizedBox(height: 24),
                    ],

                    // Continue Watching (if applicable)
                    _buildContinueWatchingSection(),

                    const SizedBox(
                      height: 120,
                    ), // Bottom padding for navigation
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(MediaType selectedType) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 400,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: selectedType == MediaType.movie
              ? TmdbRepository().getTrendingMoviesDay()
              : TmdbRepository().getTrendingTvShowsDay(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildHeroSkeleton();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildHeroError();
            }

            final items = snapshot.data!.take(5).toList();
            _startHeroTimer(items.length);

            return ParallaxHeroSection(
              scrollOffset: _scrollOffset,
              child: PageView.builder(
                controller: _heroController,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return CinematicHeroCard(
                    movie: items[index],
                    onPlayTrailer: () => _playTrailer(items[index]),
                    onAddToWatchlist: () => _addToWatchlist(items[index]),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.cinematicGold),
      ),
    );
  }

  Widget _buildHeroError() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: AppColors.darkTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load featured content',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistSection(MediaType selectedType) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: TmdbRepository().getWatchlist(),
      builder: (context, snapshot) {
        final movies = snapshot.data ?? [];
        final filteredMovies = movies.where((movie) {
          final isMovie =
              movie['media_type'] == 'movie' || movie['title'] != null;
          return selectedType == MediaType.movie ? isMovie : !isMovie;
        }).toList();

        return LibrarySectionCard(
          title: 'Your Watchlist',
          movies: filteredMovies,
          emptyStateMessage:
              'Add ${selectedType == MediaType.movie ? 'movies' : 'shows'} you want to watch later',
          emptyStateIcon: Icons.bookmark_outline_rounded,
          onViewAll: () => _navigateToLibrary(),
        );
      },
    );
  }

  Widget _buildTrendingSection(MediaType selectedType) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: selectedType == MediaType.movie
          ? TmdbRepository().getTrendingMoviesWeek()
          : TmdbRepository().getTrendingTvShowsWeek(),
      builder: (context, snapshot) {
        return LibrarySectionCard(
          title: 'Trending This Week',
          movies: snapshot.data ?? [],
          emptyStateMessage:
              'Check back later for trending ${selectedType == MediaType.movie ? 'movies' : 'shows'}',
          emptyStateIcon: Icons.trending_up_rounded,
          onViewAll: () => _navigateToDiscover(),
        );
      },
    );
  }

  Widget _buildTopRatedSection(MediaType selectedType) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: selectedType == MediaType.movie
          ? TmdbRepository().getTopRatedMovies()
          : TmdbRepository().getTopRatedTvShows(),
      builder: (context, snapshot) {
        return LibrarySectionCard(
          title: selectedType == MediaType.movie
              ? 'Top Rated Movies'
              : 'Top Rated TV Shows',
          movies: snapshot.data ?? [],
          emptyStateMessage:
              'Check back later for top rated ${selectedType == MediaType.movie ? 'movies' : 'shows'}',
          emptyStateIcon: Icons.star_rounded,
          onViewAll: () => _navigateToDiscover(),
        );
      },
    );
  }

  Widget _buildUpcomingSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: TmdbRepository().getUpcomingMovies(),
      builder: (context, snapshot) {
        return LibrarySectionCard(
          title: 'Coming Soon',
          movies: snapshot.data ?? [],
          emptyStateMessage: 'Check back later for upcoming releases',
          emptyStateIcon: Icons.schedule_rounded,
          onViewAll: () => _navigateToDiscover(),
        );
      },
    );
  }

  Widget _buildContinueWatchingSection() {
    // This would integrate with a continue watching provider
    // For now, return empty container
    return const SizedBox.shrink();
  }

  void _playTrailer(Map<String, dynamic> movie) {
    // Implement trailer playback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing trailer for ${movie['title'] ?? movie['name']}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _addToWatchlist(Map<String, dynamic> movie) {
    // Implement add to watchlist
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${movie['title'] ?? movie['name']} to watchlist'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.cinematicGold,
      ),
    );
  }

  void _navigateToLibrary() {
    // Navigate to library screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Library'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToDiscover() {
    // Navigate to discover screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to Discover'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshContent(MediaType selectedType) async {
    // Refresh all content sections
    await Future.wait([
      _refreshRecommendations(),
      _refreshHeroContent(),
      _refreshLibraryContent(),
    ]);
  }

  Future<void> _refreshRecommendations() async {
    // This would refresh the recommendations provider
    // For now, just show a message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recommendations refreshed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.cinematicGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _refreshHeroContent() async {
    // Refresh hero section content
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _refreshLibraryContent() async {
    // Refresh library sections
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
