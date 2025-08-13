import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../application/detail/detail_providers.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/error_display_widget.dart';
import 'widgets/action_button_bar.dart';
import 'widgets/cast_and_crew_section.dart';
import 'widgets/detail_header.dart';
import 'widgets/info_panel.dart';
import 'widgets/movie_detail_shimmer.dart';
import 'widgets/enhanced_detail_hero_section.dart';
import 'widgets/enhanced_cast_and_crew_section.dart';
import 'widgets/interactive_elements_section.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int mediaId;

  const MovieDetailScreen({super.key, required this.mediaId});

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
    final mediaIdentifier = (id: mediaId, type: MediaType.movie);
    final detailsAsync = ref.watch(mediaDetailsProvider(mediaIdentifier));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: detailsAsync.when(
        loading: () => const MovieDetailShimmer(),
        error: (err, stack) => ErrorDisplayWidget(
          message: err.toString(),
          // ref.invalidate tells Riverpod to discard the old state and re-run the provider
          onRetry: () => ref.invalidate(mediaDetailsProvider(mediaIdentifier)),
        ),
        data: (media) {
          final trailerKey = _getTrailerKey(media);
          final title = media['title'] ?? 'Details';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400.0,
                backgroundColor: AppColors.darkBackground,
                pinned: true,
                // The title property is what shows when the AppBar is collapsed.
                // The FlexibleSpaceBar handles the animation.
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  // Use a LayoutBuilder to get the current collapse progress
                  background: LayoutBuilder(
                    builder: (context, constraints) {
                      final settings = context
                          .dependOnInheritedWidgetOfExactType<
                            FlexibleSpaceBarSettings
                          >()!;
                      // Calculate progress from 0.0 (expanded) to 1.0 (collapsed)
                      final progress =
                          (settings.currentExtent - settings.minExtent) /
                          (settings.maxExtent - settings.minExtent);
                      return DetailHeader(
                        media: media,
                        collapseProgress:
                            1 - progress, // Invert progress for our widget
                        onPlayTrailer: trailerKey != null
                            ? () => _playTrailer(context, trailerKey)
                            : null,
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(child: ActionButtonBar(media: media)),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    InfoPanel(media: media),
                    const SizedBox(height: 24),
                    CastAndCrewSection(credits: media['credits']),
                    const SizedBox(height: 100),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Video Player Screen
class VideoPlayerScreen extends StatefulWidget {
  final String videoKey;
  const VideoPlayerScreen({super.key, required this.videoKey});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoKey,
      flags: const YoutubePlayerFlags(autoPlay: true, forceHD: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Center(child: YoutubePlayer(controller: _controller)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
