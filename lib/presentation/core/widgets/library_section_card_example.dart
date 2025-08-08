import 'package:flutter/material.dart';
import 'library_section_card.dart';

/// Example usage of LibrarySectionCard and its specialized variants
class LibrarySectionCardExample extends StatelessWidget {
  const LibrarySectionCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Library Section Cards'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Library Sections',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Watchlist Section with Movies
            WatchlistSectionCard(
              movies: _sampleMovies,
              onViewAll: () => _showSnackBar(context, 'View All Watchlist'),
              onBrowseMovies: () => _showSnackBar(context, 'Browse Movies'),
            ),

            const SizedBox(height: 24),

            // Empty Favorites Section
            FavoritesSectionCard(
              movies: const [],
              onViewAll: () => _showSnackBar(context, 'View All Favorites'),
              onDiscoverMovies: () => _showSnackBar(context, 'Discover Movies'),
            ),

            const SizedBox(height: 24),

            // Watched Section with Movies
            WatchedSectionCard(
              movies: _sampleMovies.take(2).toList(),
              onViewAll: () => _showSnackBar(context, 'View All Watched'),
              onStartWatching: () => _showSnackBar(context, 'Start Watching'),
            ),

            const SizedBox(height: 24),

            // Custom List Section
            CustomListSectionCard(
              listName: 'My Action Movies',
              movies: _sampleMovies.take(3).toList(),
              onViewAll: () => _showSnackBar(context, 'View All Action Movies'),
              onAddMovies: () => _showSnackBar(context, 'Add Movies to List'),
            ),

            const SizedBox(height: 24),

            // Empty Custom List
            CustomListSectionCard(
              listName: 'Sci-Fi Classics',
              movies: const [],
              onViewAll: () => _showSnackBar(context, 'View All Sci-Fi'),
              onAddMovies: () => _showSnackBar(context, 'Add Sci-Fi Movies'),
            ),

            const SizedBox(height: 24),

            // Generic Library Section
            LibrarySectionCard(
              title: 'Recently Added',
              movies: _sampleMovies,
              emptyStateMessage:
                  'No recently added movies\nCheck back later for updates',
              emptyStateIcon: Icons.new_releases_outlined,
              emptyActionText: 'Refresh',
              onViewAll: () => _showSnackBar(context, 'View All Recent'),
              onEmptyAction: () => _showSnackBar(context, 'Refreshing...'),
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
  static const List<Map<String, dynamic>> _sampleMovies = [
    {
      'id': 550,
      'title': 'Fight Club',
      'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'vote_average': 8.4,
      'release_date': '1999-10-15',
    },
    {
      'id': 238,
      'title': 'The Godfather',
      'poster_path': '/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
      'vote_average': 9.2,
      'release_date': '1972-03-14',
    },
    {
      'id': 424,
      'title': 'Schindler\'s List',
      'poster_path': '/sF1U4EUQS8YHUYjNl3pMGNIQyr0.jpg',
      'vote_average': 8.6,
      'release_date': '1993-12-15',
    },
    {
      'id': 1399,
      'name': 'Game of Thrones',
      'poster_path': '/7WUHnWGx5OO145IRxPDUkQSh4C7.jpg',
      'vote_average': 8.4,
      'first_air_date': '2011-04-17',
    },
    {
      'id': 155,
      'title': 'The Dark Knight',
      'poster_path': '/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      'vote_average': 8.5,
      'release_date': '2008-07-18',
    },
  ];
}
