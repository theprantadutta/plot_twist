// lib/presentation/pages/detail/movie_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../application/detail/detail_providers.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import 'widgets/action_button_bar.dart';
import 'widgets/cast_and_crew_section.dart';
import 'widgets/detail_hero_section.dart';
import 'widgets/info_panel.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int mediaId;
  final MediaType mediaType;

  const MovieDetailScreen({
    super.key,
    required this.mediaId,
    required this.mediaType,
  });

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
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.auroraPink),
        ),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (media) {
          final trailerKey = _getTrailerKey(media);

          return CustomScrollView(
            slivers: [
              // The main hero section at the top
              SliverToBoxAdapter(
                child: DetailHeroSection(
                  media: media,
                  onPlayTrailer: trailerKey != null
                      ? () => _playTrailer(context, trailerKey)
                      : null,
                ),
              ),

              // The floating action bar for Watchlist, Watched, Rate
              SliverToBoxAdapter(child: ActionButtonBar(media: media)),

              // The main content body with all other details
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Panel with Genres, Stats, and Synopsis
                    InfoPanel(media: media),

                    const SizedBox(height: 24),

                    // Horizontal scrolling carousel for Cast
                    CastAndCrewSection(credits: media['credits']),

                    const SizedBox(height: 100), // Bottom padding
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- Video Player Screen (Can be in its own file) ---
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
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        forceHD: true,
        loop: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.auroraPink,
          progressColors: const ProgressBarColors(
            playedColor: AppColors.auroraPink,
            handleColor: AppColors.auroraPurple,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
