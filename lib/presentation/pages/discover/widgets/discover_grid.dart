import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../application/discover/discover_providers.dart';
import '../../../../application/home/home_providers.dart';
import '../../../../data/local/persistence_service.dart';
import '../../home/widgets/poster_card.dart';
import '../../home/widgets/shimmer_loaders.dart';

class DiscoverGrid extends ConsumerStatefulWidget {
  const DiscoverGrid({super.key});

  @override
  ConsumerState<DiscoverGrid> createState() => _DiscoverGridState();
}

class _DiscoverGridState extends ConsumerState<DiscoverGrid> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _items = [];
  int _page = 1;
  bool _isLoading = false;
  // A flag to prevent multiple fetches for the same state
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  // WE NO LONGER NEED didChangeDependencies

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isLoading) {
      _fetchData(isLoadMore: true);
    }
  }

  void _resetAndFetch() {
    // Prevent fetching if a fetch is already in progress
    if (_isFetching) return;

    // Reset state and fetch new data
    setState(() {
      _items = [];
      _page = 1;
    });
    // Use addPostFrameCallback to ensure the state update has completed before fetching
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData({bool isLoadMore = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _isFetching = true; // Mark as fetching
    });

    final repo = ref.read(tmdbRepositoryProvider);
    final mediaType = ref.read(mediaTypeNotifierProvider);
    final query = ref.read(searchQueryNotifierProvider);
    final genres = ref.read(discoverFiltersNotifierProvider);

    List<Map<String, dynamic>> newItems;
    if (query.isNotEmpty) {
      newItems = await repo.searchMedia(
        type: mediaType,
        query: query,
        page: _page,
      );
    } else {
      newItems = await repo.discoverMedia(
        type: mediaType,
        withGenres: genres,
        page: _page,
      );
    }

    if (!mounted) return;

    setState(() {
      if (isLoadMore) {
        _items.addAll(newItems);
        if (newItems.isNotEmpty) _page++;
      } else {
        _items = newItems;
        _page = 2; // Set page to 2 for the next load-more request
      }
      _isLoading = false;
      _isFetching = false; // Mark fetching as complete
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- THIS IS THE FIX ---
    // We listen here, inside the build method. This is the correct place.
    ref.listen(discoverFiltersNotifierProvider, (_, __) => _resetAndFetch());
    ref.listen(searchQueryNotifierProvider, (_, __) => _resetAndFetch());
    // ----------------------

    if (_items.isEmpty && _isLoading) {
      // Shimmer loading state for the initial load
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2 / 3,
        ),
        itemCount: 8,
        itemBuilder: (context, index) =>
            const ShimmerLoader(width: 140, height: 210),
      );
    }

    if (_items.isEmpty && !_isLoading) {
      return const Center(
        child: Text(
          "No results found. Try different filters or a new search!",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return MasonryGridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: _items.length + (_isLoading ? 1 : 0), // Add space for loader
      itemBuilder: (context, index) {
        if (index == _items.length) {
          // Show a loading indicator at the bottom when loading more
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final item = _items[index];
        if (item['poster_path'] == null) {
          return const SizedBox.shrink(); // Don't show items without posters
        }
        final voteAverage = (item['vote_awesome'] as num?)?.toDouble() ?? 0.0;
        final mediaId = item['id'] as int;

        // Infer the media type. Some TMDB endpoints provide 'media_type',
        // others don't. We can check for 'title' (movie) vs 'name' (TV) as a fallback.
        final String typeString =
            item['media_type'] ?? (item.containsKey('title') ? 'movie' : 'tv');
        final mediaType = typeString == 'tv' ? MediaType.tv : MediaType.movie;

        return PosterCard(
          mediaId: mediaId,
          mediaType: mediaType,
          posterPath: item['poster_path'],
          voteAverage: voteAverage,
        );
      },
    );
  }
}
