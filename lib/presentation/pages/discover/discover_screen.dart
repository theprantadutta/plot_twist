// import 'dart:async';

// import 'package:appinio_swiper/appinio_swiper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import '../../../application/discover/discover_providers.dart';
// import '../../core/app_colors.dart';
// import 'widgets/movie_info_card.dart';

// class DiscoverScreen extends ConsumerStatefulWidget {
//   const DiscoverScreen({super.key});

//   @override
//   ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
// }

// class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
//   final AppinioSwiperController _swiperController = AppinioSwiperController();
//   // To track the swipe progress for the UI overlays
//   final ValueNotifier<double> _swipeProgress = ValueNotifier(0.0);

//   // A timer to delay the database action, allowing for "Undo"
//   Timer? _undoTimer;
//   Map<String, dynamic>? _lastSwipedMovie;

//   void _onSwipeEnd(
//     int previousIndex,
//     int? targetIndex,
//     SwiperActivity activity,
//   ) {
//     // Reset progress so the next card doesn't show an overlay
//     _swipeProgress.value = 0.0;

//     final direction = activity.direction;
//     if (direction == AxisDirection.right || direction == AxisDirection.left) {
//       // Get the movie that was just swiped from the deck's current state
//       final movie = ref.read(discoverDeckProvider).asData!.value[previousIndex];
//       _lastSwipedMovie = movie;

//       final action = direction == AxisDirection.right
//           ? "Added to Watchlist"
//           : "Dismissed";

//       // Immediately update the UI by calling the notifier method
//       if (direction == AxisDirection.right) {
//         ref.read(discoverDeckProvider.notifier).cardSwiped(movie);
//       } else {
//         ref.read(discoverDeckProvider.notifier).cardSwiped(movie);
//       }

//       // Show SnackBar with Undo option
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${movie['title']} $action'),
//           action: SnackBarAction(
//             label: "Undo",
//             textColor: AppColors.auroraPink,
//             onPressed: () {
//               // Cancel the database action and tell the notifier to restore the card
//               _undoTimer?.cancel();
//               ref
//                   .read(discoverDeckProvider.notifier)
//                   .undoSwipe(_lastSwipedMovie!, previousIndex);
//             },
//           ),
//         ),
//       );

//       // If the user swiped right, schedule the actual database write after a delay
//       if (direction == AxisDirection.right) {
//         _undoTimer?.cancel();
//         _undoTimer = Timer(const Duration(seconds: 4), () {
//           // This call can be made to a method that specifically handles the DB write
//           // For now, it's illustrative as the logic is handled in the bottom sheet in the other version
//           print("Permanently adding ${movie['title']} to database...");
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _swiperController.dispose();
//     _swipeProgress.dispose();
//     _undoTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final deckAsync = ref.watch(discoverDeckProvider);

//     return Scaffold(
//       backgroundColor: AppColors.darkBackground,
//       appBar: AppBar(
//         backgroundColor: AppColors.darkBackground,
//         title: const Text("Discover"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: deckAsync.when(
//               data: (movies) {
//                 if (movies.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       "That's all for now!",
//                       style: TextStyle(color: Colors.white70, fontSize: 18),
//                     ),
//                   );
//                 }
//                 return AppinioSwiper(
//                   controller: _swiperController,
//                   cardCount: movies.length,
//                   onSwipeEnd: _onSwipeEnd,
//                   // This callback tracks the swipe progress in real-time
//                   // onSwiping: (activity) {
//                   //   _swipeProgress.value = activity.swipeProgress;
//                   // },
//                   cardBuilder: (context, index) {
//                     final movie = movies[index];
//                     // We rebuild the card using a ValueListenableBuilder for efficiency
//                     return ValueListenableBuilder<double>(
//                       valueListenable: _swipeProgress,
//                       builder: (context, progress, child) {
//                         // Only the top card (the one being swiped) should show the progress
//                         final currentProgress = (index == 0) ? progress : 0.0;
//                         return MovieInfoCard(
//                           movie: movie,
//                           swipeProgress: currentProgress,
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//               loading: () => const Center(
//                 child: CircularProgressIndicator(color: AppColors.auroraPink),
//               ),
//               error: (err, stack) => Center(
//                 child: Text(
//                   'Error: $err',
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildActionButton(
//                   onPressed: () => _swiperController.swipeLeft(),
//                   icon: FontAwesomeIcons.xmark,
//                   color: Colors.red.shade400,
//                 ),
//                 _buildActionButton(
//                   onPressed: () => _swiperController.unswipe(),
//                   icon: FontAwesomeIcons.rotateLeft,
//                   color: Colors.amber.shade600,
//                 ),
//                 _buildActionButton(
//                   onPressed: () => _swiperController.swipeRight(),
//                   icon: FontAwesomeIcons.solidHeart,
//                   color: Colors.green.shade400,
//                   isLarge: true,
//                 ),
//               ],
//             ),
//           ),
//           // const SizedBox(height: 80),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required VoidCallback onPressed,
//     required IconData icon,
//     required Color color,
//     bool isLarge = false,
//   }) {
//     final size = isLarge ? 80.0 : 60.0;
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: AppColors.darkSurface,
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 15,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: IconButton(
//         onPressed: onPressed,
//         icon: FaIcon(icon, color: color, size: size / 2.5),
//       ),
//     );
//   }
// }
// lib/presentation/pages/discover/discover_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../application/detail/detail_providers.dart';
import '../../../application/discover/discover_providers.dart';
import '../../../data/firestore/firestore_service.dart';
import '../../core/app_colors.dart';
import 'widgets/movie_info_card.dart';

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

  // This is our new, smarter swipe handler
  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    // FIX #2: Immediately update the state with the new card's index.
    // This makes the like button instantly reactive.
    setState(() {
      _currentIndex = currentIndex ?? 0;
    });

    // FIX #3: Proactively fetch more movies when we're getting close to the end
    final movies = ref.read(discoverDeckProvider).asData?.value ?? [];
    if (movies.length - _currentIndex < 5) {
      ref.read(discoverDeckProvider.notifier).fetchMore();
    }

    return true; // Allow the swipe
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
                        return MovieInfoCard(movie: movies[index]);
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
