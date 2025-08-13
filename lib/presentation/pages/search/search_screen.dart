import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../application/discover/discover_providers.dart';
import '../../../application/home/home_providers.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../home/widgets/media_type_toggle.dart';
import '../home/widgets/poster_card.dart';
import '../home/widgets/shimmer_loaders.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  late final Debouncer<String> _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(
      const Duration(milliseconds: 500),
      initialValue: '',
      onChanged: (query) {
        if (mounted) {
          ref.read(searchQueryNotifierProvider.notifier).setQuery(query);
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (query) => _debouncer.value = query,
          decoration: InputDecoration(
            hintText: "Search Movies & TV Shows...",
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: MediaTypeToggle(),
          ),
        ],
      ),
      body: const SearchResultsGrid(),
    );
  }
}

class SearchResultsGrid extends ConsumerStatefulWidget {
  const SearchResultsGrid({super.key});

  @override
  ConsumerState<SearchResultsGrid> createState() => _SearchResultsGridState();
}

class _SearchResultsGridState extends ConsumerState<SearchResultsGrid> {
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _items = [];
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isLoading) {
      _fetchData(isLoadMore: true);
    }
  }

  void _resetAndFetch() {
    // --- THIS IS PART OF THE FIX ---
    // Schedule the state reset and fetch to happen *after* the current build is finished.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _items = [];
          _page = 1;
        });
        _fetchData();
      }
    });
  }

  Future<void> _fetchData({bool isLoadMore = false}) async {
    final query = ref.read(searchQueryNotifierProvider);
    if (query.isEmpty) {
      if (mounted) setState(() => _items = []);
      return;
    }

    if (_isLoading) return;
    if (mounted) setState(() => _isLoading = true);

    final repo = ref.read(tmdbRepositoryProvider);
    final mediaType = ref.read(mediaTypeNotifierProvider);
    final newItems = await repo.searchMedia(
      type: mediaType,
      query: query,
      page: _page,
    );

    if (!mounted) return;
    setState(() {
      if (isLoadMore) {
        _items.addAll(newItems);
      } else {
        _items = newItems;
      }
      if (newItems.isNotEmpty) {
        _page++;
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The listeners are now correctly placed inside the build method.
    ref.listen(searchQueryNotifierProvider, (_, __) => _resetAndFetch());
    ref.listen(mediaTypeNotifierProvider, (_, __) => _resetAndFetch());

    final query = ref.watch(searchQueryNotifierProvider);

    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 80, color: Colors.white24),
            SizedBox(height: 16),
            Text(
              "Find your next favorite show",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty && _isLoading) {
      return MasonryGridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        itemCount: 8,
        itemBuilder: (context, index) =>
            const ShimmerLoader(width: 140, height: 210),
      );
    }

    if (_items.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          "No results found for \"$query\"",
          style: const TextStyle(color: Colors.white70),
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
      itemCount: _items.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final item = _items[index];
        if (item['poster_path'] == null) return const SizedBox.shrink();
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
