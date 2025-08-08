import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../core/app_animations.dart';
import '../../core/widgets/library_section_card.dart';
import '../../../application/watchlist/watchlist_providers.dart';
import '../../../application/favorites/favorites_providers.dart';
import '../../../application/watched/watched_providers.dart';
import '../../../application/custom_list/custom_list_providers.dart';

/// Enhanced library screen with organized sections for all user content
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: MotionPresets.slideUp.curve,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  _buildSearchSection(),
                  _buildLibrarySections(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'My Library',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkBackground,
                AppColors.darkBackground.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(
            _isSearching ? Icons.close_rounded : Icons.search_rounded,
            color: AppColors.darkTextPrimary,
          ),
        ),
        IconButton(
          onPressed: _showLibraryOptions,
          icon: Icon(Icons.more_vert_rounded, color: AppColors.darkTextPrimary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: MotionPresets.slideDown.duration,
        curve: MotionPresets.slideDown.curve,
        height: _isSearching ? 80 : 0,
        child: AnimatedOpacity(
          duration: MotionPresets.fadeIn.duration,
          opacity: _isSearching ? 1.0 : 0.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.darkTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search your library...',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.darkTextSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                          color: AppColors.darkTextSecondary,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.cinematicGold,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLibrarySections() {
    return SliverList(
      delegate: SliverChildListDelegate([
        const SizedBox(height: 8),

        // Quick Stats Section
        _buildQuickStats(),

        const SizedBox(height: 24),

        // Continue Watching Section
        _buildContinueWatchingSection(),

        // Watchlist Section
        _buildWatchlistSection(),

        // Favorites Section
        _buildFavoritesSection(),

        // Recently Watched Section
        _buildRecentlyWatchedSection(),

        // Custom Lists Section
        _buildCustomListsSection(),

        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildQuickStats() {
    final watchlistAsync = ref.watch(watchlistProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final watchedAsync = ref.watch(watchedProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cinematicGold.withValues(alpha: 0.1),
            AppColors.cinematicRed.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cinematicGold.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Cinema Stats',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Watchlist',
                  watchlistAsync.when(
                    data: (movies) => '${movies.length}',
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                  Icons.bookmark_outline_rounded,
                  AppColors.cinematicBlue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Favorites',
                  favoritesAsync.when(
                    data: (movies) => '${movies.length}',
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                  Icons.favorite_outline_rounded,
                  AppColors.cinematicRed,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Watched',
                  watchedAsync.when(
                    data: (movies) => '${movies.length}',
                    loading: () => '...',
                    error: (_, __) => '0',
                  ),
                  Icons.check_circle_outline_rounded,
                  AppColors.darkSuccessGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingSection() {
    // This would typically come from a continue watching provider
    final continueWatchingMovies = <Map<String, dynamic>>[];

    if (continueWatchingMovies.isEmpty) {
      return const SizedBox.shrink();
    }

    return LibrarySectionCard(
      title: 'Continue Watching',
      movies: _filterMovies(continueWatchingMovies),
      emptyStateMessage: 'No movies in progress\nStart watching something new',
      emptyStateIcon: Icons.play_circle_outline_rounded,
      emptyActionText: 'Browse Movies',
      onViewAll: () => _navigateToSection('continue_watching'),
      onEmptyAction: () => _navigateToDiscover(),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
    );
  }

  Widget _buildWatchlistSection() {
    final watchlistAsync = ref.watch(watchlistProvider);

    return watchlistAsync.when(
      data: (movies) => WatchlistSectionCard(
        movies: _filterMovies(movies),
        onViewAll: () => _navigateToSection('watchlist'),
        onBrowseMovies: () => _navigateToDiscover(),
      ),
      loading: () => _buildLoadingSection('My Watchlist'),
      error: (error, stack) => _buildErrorSection('My Watchlist', error),
    );
  }

  Widget _buildFavoritesSection() {
    final favoritesAsync = ref.watch(favoritesProvider);

    return favoritesAsync.when(
      data: (movies) => FavoritesSectionCard(
        movies: _filterMovies(movies),
        onViewAll: () => _navigateToSection('favorites'),
        onDiscoverMovies: () => _navigateToDiscover(),
      ),
      loading: () => _buildLoadingSection('Favorites'),
      error: (error, stack) => _buildErrorSection('Favorites', error),
    );
  }

  Widget _buildRecentlyWatchedSection() {
    final watchedAsync = ref.watch(watchedProvider);

    return watchedAsync.when(
      data: (movies) => WatchedSectionCard(
        movies: _filterMovies(movies.take(10).toList()),
        onViewAll: () => _navigateToSection('watched'),
        onStartWatching: () => _navigateToDiscover(),
      ),
      loading: () => _buildLoadingSection('Recently Watched'),
      error: (error, stack) => _buildErrorSection('Recently Watched', error),
    );
  }

  Widget _buildCustomListsSection() {
    final customListsAsync = ref.watch(customListsProvider);

    return customListsAsync.when(
      data: (lists) {
        if (lists.isEmpty) {
          return _buildCreateListPrompt();
        }

        return Column(
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Lists',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _navigateToCreateList(),
                    icon: Icon(
                      Icons.add_rounded,
                      color: AppColors.cinematicGold,
                      size: 20,
                    ),
                    label: Text(
                      'Create List',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.cinematicGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Custom Lists
            ...lists
                .take(3)
                .map(
                  (list) => CustomListSectionCard(
                    listName: list['name'] ?? 'Untitled List',
                    movies: _filterMovies(list['movies'] ?? []),
                    onViewAll: () => _navigateToCustomList(list['id']),
                    onAddMovies: () => _navigateToAddMovies(list['id']),
                  ),
                ),

            if (lists.length > 3)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: TextButton(
                  onPressed: () => _navigateToSection('custom_lists'),
                  child: Text(
                    'View All Lists (${lists.length})',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.cinematicGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => _buildLoadingSection('My Lists'),
      error: (error, stack) => _buildErrorSection('My Lists', error),
    );
  }

  Widget _buildCreateListPrompt() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.cinematicGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.playlist_add_rounded,
              color: AppColors.cinematicGold,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create Your First List',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Organize your movies into custom collections\nlike "Date Night Movies" or "Action Favorites"',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateList(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cinematicGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String title, Object error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cinematicRed.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.cinematicRed,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Error loading $title',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.darkTextSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterMovies(List<Map<String, dynamic>> movies) {
    if (_searchQuery.isEmpty) return movies;

    return movies.where((movie) {
      final title = (movie['title'] ?? '').toString().toLowerCase();
      final overview = (movie['overview'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery) || overview.contains(_searchQuery);
    }).toList();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _showLibraryOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLibraryOptionsSheet(),
    );
  }

  Widget _buildLibraryOptionsSheet() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkTextTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Icon(Icons.sort_rounded, color: AppColors.darkTextPrimary),
            title: Text(
              'Sort Library',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showSortOptions();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.filter_list_rounded,
              color: AppColors.darkTextPrimary,
            ),
            title: Text(
              'Filter Content',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showFilterOptions();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.import_export_rounded,
              color: AppColors.darkTextPrimary,
            ),
            title: Text(
              'Export Library',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _exportLibrary();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToSection(String section) {
    // Navigate to specific section page
    Navigator.pushNamed(context, '/$section');
  }

  void _navigateToDiscover() {
    // Navigate to discover page
    Navigator.pushNamed(context, '/discover');
  }

  void _navigateToCreateList() {
    // Navigate to create list page
    Navigator.pushNamed(context, '/create-list');
  }

  void _navigateToCustomList(String listId) {
    // Navigate to specific custom list
    Navigator.pushNamed(context, '/list/$listId');
  }

  void _navigateToAddMovies(String listId) {
    // Navigate to add movies to list
    Navigator.pushNamed(context, '/list/$listId/add-movies');
  }

  // Action methods
  void _showSortOptions() {
    // Show sort options dialog
  }

  void _showFilterOptions() {
    // Show filter options dialog
  }

  void _exportLibrary() {
    // Export library functionality
  }
}
