import 'package:flutter/material.dart';
import 'cinematic_hero_card.dart';

/// Example usage of CinematicHeroCard component
/// This file demonstrates various ways to use the hero card
class CinematicHeroCardExample extends StatelessWidget {
  const CinematicHeroCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Cinematic Hero Card Examples'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Featured Movie',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Example 1: Full-featured hero card
            CinematicHeroCard(
              movie: _sampleMovie,
              height: 400,
              onPlayTrailer: () => _showSnackBar(context, 'Playing trailer...'),
              onAddToWatchlist: () =>
                  _showSnackBar(context, 'Added to watchlist!'),
              onTap: () => _showSnackBar(context, 'Navigating to details...'),
            ),

            const SizedBox(height: 32),

            const Text(
              'Compact Version',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Example 2: Compact version without actions
            CinematicHeroCard(
              movie: _sampleTvShow,
              height: 300,
              showActions: false,
              onTap: () =>
                  _showSnackBar(context, 'Navigating to TV show details...'),
            ),

            const SizedBox(height: 32),

            const Text(
              'Without Backdrop Image',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Example 3: Movie without backdrop image
            CinematicHeroCard(
              movie: _movieWithoutBackdrop,
              height: 350,
              onPlayTrailer: () => _showSnackBar(context, 'Playing trailer...'),
              onAddToWatchlist: () =>
                  _showSnackBar(context, 'Added to watchlist!'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFFD700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Sample movie data
  static const Map<String, dynamic> _sampleMovie = {
    'id': 550,
    'title': 'Fight Club',
    'overview':
        'A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy. Their concept catches on, with underground "fight clubs" forming in every town, until an eccentric gets in the way and ignites an out-of-control spiral toward oblivion.',
    'backdrop_path': '/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg',
    'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    'vote_average': 8.433,
    'release_date': '1999-10-15',
    'genre_ids': [18, 53, 35],
  };

  // Sample TV show data
  static const Map<String, dynamic> _sampleTvShow = {
    'id': 1399,
    'name': 'Game of Thrones',
    'overview':
        'Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war. All while a very ancient evil awakens in the farthest north. Amidst the war, a neglected military order of misfits, the Night\'s Watch, is all that stands between the realms of men and icy horrors beyond.',
    'backdrop_path': '/suopoADq0k8YZr4dQXcU6pToj6s.jpg',
    'poster_path': '/7WUHnWGx5OO145IRxPDUkQSh4C7.jpg',
    'vote_average': 8.453,
    'first_air_date': '2011-04-17',
    'genre_ids': [10765, 18, 10759],
  };

  // Sample movie without backdrop
  static const Map<String, dynamic> _movieWithoutBackdrop = {
    'id': 238,
    'title': 'The Godfather',
    'overview':
        'Spanning the years 1945 to 1955, a chronicle of the fictional Italian-American Corleone crime family. When organized crime family patriarch, Vito Corleone barely survives an attempt on his life, his youngest son, Michael steps in to take care of the would-be killers, launching a campaign of bloody revenge.',
    'poster_path': '/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
    'vote_average': 8.7,
    'release_date': '1972-03-14',
    'genre_ids': [18, 80],
    // Note: No backdrop_path to demonstrate fallback behavior
  };
}
