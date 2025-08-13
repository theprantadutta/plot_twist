// lib/presentation/pages/discover/discover_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../application/detail/detail_providers.dart';
import '../../../application/discover/discover_providers.dart';
import '../../../data/firestore/firestore_service.dart';
import '../../core/app_colors.dart';
import '../home/widgets/media_type_toggle.dart';
import 'widgets/movie_info_card.dart';
import '../../core/widgets/swipe_discovery_card.dart';
import '../../core/widgets/cinematic_app_bar.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  // We keep track of the current index locally to solve the button lag
  int _currentIndex = 0;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    setState(() => _currentIndex = currentIndex ?? 0);
    final movies = ref.read(discoverDeckProvider).asData?.value ?? [];
    if (movies.length - (currentIndex ?? 0) < 5) {
      ref.read(discoverDeckProvider.notifier).fetchMore();
    }
    return true;
  }

  void _handleLike() {
    final movies = ref.read(discoverDeckProvider).asData?.value;
    if (movies == null || movies.isEmpty) return;

    final movie = movies[_currentIndex];
    final service = FirestoreService();
    final isLiked =
        ref
            .read(isMediaInWatchlistProvider(movie['id'] as int))
            .asData
            ?.value ??
        false;

    if (isLiked) {
      service.removeFromList('watchlist', movie['id'].toString());
    } else {
      service.addToList('watchlist', movie);
    }
    _swiperController.swipe(CardSwiperDirection.right);
  }

  @override
  Widget build(BuildContext context) {
    final deckAsync = ref.watch(discoverDeckProvider);
    final movies = deckAsync.asData?.value ?? [];

    final currentMovieId = (movies.isNotEmpty)
        ? movies[_currentIndex]['id'] as int
        : null;
    final isLikedAsync = ref.watch(
      isMediaInWatchlistProvider(currentMovieId ?? 0),
    );
    final isLiked = isLikedAsync.asData?.value ?? false;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text("Discover"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: MediaTypeToggle(), // Add the toggle here
          ),
        ],
      ),
      body: deckAsync.when(
        data: (movies) {
          if (movies.isEmpty) {
            return const Center(
              child: Text(
                "That's all for now!",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          // Important: We reset the controller when the data changes to avoid errors
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   if (mounted) {
          //     _swiperController.moveTo(0);
          //     setState(() => _currentIndex = 0);
          //   }
          // });
          return Column(
            children: [
              Flexible(
                child: CardSwiper(
                  controller: _swiperController,
                  cardsCount: movies.length,
                  onSwipe: _onSwipe,
                  onUndo: (p, c, d) {
                    setState(() => _currentIndex = c);
                    return true;
                  },
                  isLoop: false,
                  // FIX #1: Allow swipes up and down again
                  allowedSwipeDirection: AllowedSwipeDirection.all(),
                  cardBuilder:
                      (
                        context,
                        index,
                        horizontalThresholdPercentage,
                        verticalThresholdPercentage,
                      ) {
                        return SwipeDiscoveryCard(movie: movies[index]);
                      },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 32.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      onPressed: () =>
                          _swiperController.swipe(CardSwiperDirection.left),
                      icon: FontAwesomeIcons.xmark,
                    ),
                    _buildActionButton(
                      onPressed: () => _swiperController.undo(),
                      icon: FontAwesomeIcons.rotateLeft,
                      isSmall: true,
                      color: Colors.amber.shade600,
                    ),
                    _buildActionButton(
                      onPressed: _handleLike,
                      icon: isLiked
                          ? FontAwesomeIcons.solidHeart
                          : FontAwesomeIcons.heart,
                      color: isLiked ? Colors.red.shade400 : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    Color? color,
    bool isSmall = false,
  }) {
    final size = isSmall ? 50.0 : 70.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkSurface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: FaIcon(icon, color: color ?? Colors.white70, size: size / 2.5),
      ),
    );
  }
}
