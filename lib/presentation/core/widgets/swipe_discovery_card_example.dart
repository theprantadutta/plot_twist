import 'package:flutter/material.dart';
import 'swipe_discovery_card.dart';

/// Example usage of SwipeDiscoveryCard component
/// Demonstrates various configurations and swipe states
class SwipeDiscoveryCardExample extends StatefulWidget {
  const SwipeDiscoveryCardExample({super.key});

  @override
  State<SwipeDiscoveryCardExample> createState() =>
      _SwipeDiscoveryCardExampleState();
}

class _SwipeDiscoveryCardExampleState extends State<SwipeDiscoveryCardExample> {
  double _swipeProgress = 0.0;
  bool _showOverlays = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Swipe Discovery Card Examples'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls
            _buildControls(),

            const SizedBox(height: 24),

            const Text(
              'Interactive Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Interactive card with swipe simulation
            Center(
              child: SizedBox(
                width: 280,
                child: SwipeDiscoveryCard(
                  movie: _sampleMovie,
                  swipeProgress: _swipeProgress,
                  showSwipeOverlays: _showOverlays,
                  onTap: () =>
                      _showSnackBar('Tapped on ${_sampleMovie['title']}'),
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Different Content Types',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Row of different cards
            SizedBox(
              height: 400,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // High-rated movie
                  SizedBox(
                    width: 250,
                    child: SwipeDiscoveryCard(
                      movie: _highRatedMovie,
                      showSwipeOverlays: false,
                      onTap: () => _showSnackBar('High-rated movie tapped'),
                    ),
                  ),

                  // TV Show
                  SizedBox(
                    width: 250,
                    child: SwipeDiscoveryCard(
                      movie: _tvShow,
                      showSwipeOverlays: false,
                      onTap: () => _showSnackBar('TV show tapped'),
                    ),
                  ),

                  // Movie without poster
                  SizedBox(
                    width: 250,
                    child: SwipeDiscoveryCard(
                      movie: _movieWithoutPoster,
                      showSwipeOverlays: false,
                      onTap: () => _showSnackBar('Movie without poster tapped'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Swipe States Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Row showing different swipe states
            Row(
              children: [
                // Like state
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Like State',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      SwipeDiscoveryCard(
                        movie: _sampleMovie,
                        swipeProgress: 0.8,
                        onTap: () => _showSnackBar('Like state demo'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Pass state
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Pass State',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      SwipeDiscoveryCard(
                        movie: _sampleMovie,
                        swipeProgress: -0.8,
                        onTap: () => _showSnackBar('Pass state demo'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Controls',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Swipe progress slider
          Row(
            children: [
              const Text(
                'Swipe Progress:',
                style: TextStyle(color: Colors.white70),
              ),
              Expanded(
                child: Slider(
                  value: _swipeProgress,
                  min: -1.0,
                  max: 1.0,
                  divisions: 20,
                  label: _swipeProgress.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _swipeProgress = value;
                    });
                  },
                ),
              ),
            ],
          ),

          // Show overlays toggle
          Row(
            children: [
              const Text(
                'Show Swipe Overlays:',
                style: TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              Switch(
                value: _showOverlays,
                onChanged: (value) {
                  setState(() {
                    _showOverlays = value;
                  });
                },
              ),
            ],
          ),

          // Quick action buttons
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _swipeProgress = -0.8),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                ),
                child: const Text('Pass'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _swipeProgress = 0.0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                ),
                child: const Text('Reset'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _swipeProgress = 0.8),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
                child: const Text('Like'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Sample data
  static const Map<String, dynamic> _sampleMovie = {
    'id': 550,
    'title': 'Fight Club',
    'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    'vote_average': 8.4,
    'release_date': '1999-10-15',
    'genre_ids': [18, 53], // Drama, Thriller
  };

  static const Map<String, dynamic> _highRatedMovie = {
    'id': 238,
    'title': 'The Godfather',
    'poster_path': '/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
    'vote_average': 9.2,
    'release_date': '1972-03-14',
    'genre_ids': [18, 80], // Drama, Crime
  };

  static const Map<String, dynamic> _tvShow = {
    'id': 1399,
    'name': 'Game of Thrones',
    'poster_path': '/7WUHnWGx5OO145IRxPDUkQSh4C7.jpg',
    'vote_average': 8.4,
    'first_air_date': '2011-04-17',
    'genre_ids': [
      10765,
      18,
      10759,
    ], // Sci-Fi & Fantasy, Drama, Action & Adventure
  };

  static const Map<String, dynamic> _movieWithoutPoster = {
    'id': 424,
    'title': 'Schindler\'s List',
    'vote_average': 8.6,
    'release_date': '1993-12-15',
    'genre_ids': [18, 36, 10752], // Drama, History, War
    // Note: No poster_path to demonstrate fallback
  };
}
