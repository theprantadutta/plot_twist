import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import 'swipe_discovery_card.dart';

/// Example integration of SwipeDiscoveryCard with flutter_card_swiper
/// Shows how to replace the old MovieInfoCard with the enhanced version
class EnhancedDiscoverIntegration extends StatefulWidget {
  final List<Map<String, dynamic>> movies;
  final Function(int index, CardSwiperDirection direction)? onSwipe;
  final VoidCallback? onUndo;

  const EnhancedDiscoverIntegration({
    super.key,
    required this.movies,
    this.onSwipe,
    this.onUndo,
  });

  @override
  State<EnhancedDiscoverIntegration> createState() =>
      _EnhancedDiscoverIntegrationState();
}

class _EnhancedDiscoverIntegrationState
    extends State<EnhancedDiscoverIntegration> {
  final CardSwiperController _controller = CardSwiperController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Card Swiper with Enhanced Cards
        Expanded(
          child: CardSwiper(
            controller: _controller,
            cardsCount: widget.movies.length,
            onSwipe: (previousIndex, currentIndex, direction) {
              widget.onSwipe?.call(previousIndex, direction);
              return true;
            },
            onUndo: (previousIndex, currentIndex, direction) {
              widget.onUndo?.call();
              return true;
            },
            isLoop: false,
            allowedSwipeDirection: AllowedSwipeDirection.all(),
            cardBuilder:
                (
                  context,
                  index,
                  horizontalThresholdPercentage,
                  verticalThresholdPercentage,
                ) {
                  // Calculate swipe progress for overlay effects
                  final swipeProgress = horizontalThresholdPercentage
                      .toDouble();

                  return SwipeDiscoveryCard(
                    movie: widget.movies[index],
                    swipeProgress: swipeProgress,
                    showSwipeOverlays: true,
                    onTap: () => _handleCardTap(widget.movies[index]),
                  );
                },
          ),
        ),

        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "That's all for now!",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for more recommendations",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button
          _buildActionButton(
            onPressed: () => _controller.swipe(CardSwiperDirection.left),
            icon: Icons.close_rounded,
            color: Colors.red.shade400,
            size: 70,
          ),

          // Undo Button
          _buildActionButton(
            onPressed: () => _controller.undo(),
            icon: Icons.undo_rounded,
            color: Colors.amber.shade600,
            size: 50,
          ),

          // Like Button
          _buildActionButton(
            onPressed: () => _controller.swipe(CardSwiperDirection.right),
            icon: Icons.favorite_rounded,
            color: Colors.green.shade400,
            size: 70,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1A1A24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, color: color, size: size / 2.5),
          ),
        ),
      ),
    );
  }

  void _handleCardTap(Map<String, dynamic> movie) {
    // Handle navigation to detail screen
    // This would typically navigate to MovieDetailScreen or TvShowDetailScreen
    debugPrint('Tapped on: ${movie['title'] ?? movie['name']}');
  }
}

/// Usage example for the enhanced discover integration
class EnhancedDiscoverExample extends StatefulWidget {
  const EnhancedDiscoverExample({super.key});

  @override
  State<EnhancedDiscoverExample> createState() =>
      _EnhancedDiscoverExampleState();
}

class _EnhancedDiscoverExampleState extends State<EnhancedDiscoverExample> {
  final List<Map<String, dynamic>> _movies = [
    {
      'id': 550,
      'title': 'Fight Club',
      'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'vote_average': 8.4,
      'release_date': '1999-10-15',
      'genre_ids': [18, 53],
    },
    {
      'id': 238,
      'title': 'The Godfather',
      'poster_path': '/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
      'vote_average': 9.2,
      'release_date': '1972-03-14',
      'genre_ids': [18, 80],
    },
    {
      'id': 1399,
      'name': 'Game of Thrones',
      'poster_path': '/7WUHnWGx5OO145IRxPDUkQSh4C7.jpg',
      'vote_average': 8.4,
      'first_air_date': '2011-04-17',
      'genre_ids': [10765, 18, 10759],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Enhanced Discover'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: EnhancedDiscoverIntegration(
        movies: _movies,
        onSwipe: (index, direction) {
          debugPrint('Swiped $direction on movie at index $index');
          // Handle swipe logic (add to watchlist, etc.)
        },
        onUndo: () {
          debugPrint('Undo action');
          // Handle undo logic
        },
      ),
    );
  }
}
