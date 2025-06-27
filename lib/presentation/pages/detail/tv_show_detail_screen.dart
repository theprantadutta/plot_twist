import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_twist/presentation/pages/detail/widgets/tv_show_detail_shimmer.dart';

import '../../../application/detail/detail_providers.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/error_display_widget.dart';
import '../home/widgets/poster_card.dart';
import 'movie_detail_screen.dart';
import 'widgets/action_button_bar.dart';
import 'widgets/cast_and_crew_section.dart';
import 'widgets/detail_header.dart';
import 'widgets/detail_tab_bar.dart';
import 'widgets/info_panel.dart';
import 'widgets/season_card.dart';

class TvShowDetailScreen extends ConsumerWidget {
  final int mediaId;
  final MediaType mediaType = MediaType.tv;

  const TvShowDetailScreen({super.key, required this.mediaId});

  String? _getTrailerKey(Map<String, dynamic> media) {
    final videos = media['videos']['results'] as List;
    if (videos.isEmpty) return null;
    final trailer = videos.firstWhere(
      (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
      orElse: () =>
          videos.firstWhere((v) => v['site'] == 'YouTube', orElse: () => null),
    );
    return trailer?['key'];
  }

  void _playTrailer(BuildContext context, String videoKey) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPlayerScreen(videoKey: videoKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaIdentifier = (id: mediaId, type: mediaType);
    final detailsAsync = ref.watch(mediaDetailsProvider(mediaIdentifier));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: detailsAsync.when(
        loading: () => const TvShowDetailShimmer(),
        error: (err, stack) => ErrorDisplayWidget(
          message: err.toString(),
          // ref.invalidate tells Riverpod to discard the old state and re-run the provider
          onRetry: () => ref.invalidate(mediaDetailsProvider(mediaIdentifier)),
        ),
        data: (media) {
          final seasons = (media['seasons'] as List)
              .where((s) => s['season_number'] != 0)
              .toList();
          final trailerKey = _getTrailerKey(media);
          final title = media['name'] ?? 'Details';

          return DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 400.0,
                    backgroundColor: AppColors.darkBackground,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: LayoutBuilder(
                        builder: (context, constraints) {
                          final settings = context
                              .dependOnInheritedWidgetOfExactType<
                                FlexibleSpaceBarSettings
                              >()!;
                          final progress =
                              (settings.currentExtent - settings.minExtent) /
                              (settings.maxExtent - settings.minExtent);
                          return DetailHeader(
                            media: media,
                            collapseProgress: 1 - progress,
                            onPlayTrailer: trailerKey != null
                                ? () => _playTrailer(context, trailerKey)
                                : null,
                          );
                        },
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: DetailTabBarDelegate(
                      TabBar(
                        isScrollable: true,
                        indicatorColor: AppColors.auroraPink,
                        tabs: const [
                          Tab(text: "DETAILS"),
                          Tab(text: "SEASONS"),
                          Tab(text: "CAST"),
                          Tab(text: "SIMILAR"),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(bottom: 100, top: 24),
                    children: [
                      ActionButtonBar(media: media),
                      const SizedBox(height: 24),
                      InfoPanel(media: media),
                    ],
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: seasons.length,
                    itemBuilder: (context, index) =>
                        SeasonCard(tvId: mediaId, season: seasons[index]),
                  ),
                  ListView(
                    padding: const EdgeInsets.only(top: 16, bottom: 100),
                    children: [CastAndCrewSection(credits: media['credits'])],
                  ),
                  _buildSimilarTab(media['similar']['results']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimilarTab(List<dynamic> similar) {
    if (similar.isEmpty) {
      return const Center(
        child: Text(
          "No similar shows found.",
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: similar.length,
      itemBuilder: (context, index) {
        final item = similar[index];
        if (item['poster_path'] == null) return const SizedBox.shrink();
        return PosterCard(
          mediaId: item['id'],
          mediaType: MediaType.tv,
          posterPath: item['poster_path'],
          voteAverage: (item['vote_average'] as num?)?.toDouble() ?? 0.0,
        );
      },
    );
  }
}
