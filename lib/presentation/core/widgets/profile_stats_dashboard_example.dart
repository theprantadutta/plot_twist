import 'package:flutter/material.dart';
import 'profile_stats_dashboard.dart';

/// Example usage of ProfileStatsDashboard and CompactStatsDashboard
class ProfileStatsDashboardExample extends StatefulWidget {
  const ProfileStatsDashboardExample({super.key});

  @override
  State<ProfileStatsDashboardExample> createState() =>
      _ProfileStatsDashboardExampleState();
}

class _ProfileStatsDashboardExampleState
    extends State<ProfileStatsDashboardExample> {
  UserStats _currentStats = const UserStats(
    moviesWatched: 42,
    tvShowsWatched: 18,
    totalHours: 287,
    topGenres: ['Action', 'Drama', 'Comedy', 'Sci-Fi', 'Thriller'],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Profile Stats Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Full Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Full Profile Stats Dashboard
            ProfileStatsDashboard(
              stats: _currentStats,
              onMoviesWatchedTap: () => _showSnackBar('Movies Watched Tapped'),
              onTvShowsWatchedTap: () =>
                  _showSnackBar('TV Shows Watched Tapped'),
              onWatchTimeTap: () => _showSnackBar('Watch Time Tapped'),
            ),

            const SizedBox(height: 32),

            const Text(
              'Compact Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Compact Stats Dashboard
            CompactStatsDashboard(
              stats: _currentStats,
              onTap: () => _showSnackBar('Compact Dashboard Tapped'),
            ),

            const SizedBox(height: 32),

            const Text(
              'Empty State',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Empty Stats Dashboard
            ProfileStatsDashboard(
              stats: UserStats.empty(),
              onMoviesWatchedTap: () => _showSnackBar('Start watching movies!'),
              onTvShowsWatchedTap: () =>
                  _showSnackBar('Start watching TV shows!'),
              onWatchTimeTap: () =>
                  _showSnackBar('Begin your cinematic journey!'),
            ),

            const SizedBox(height: 32),

            const Text(
              'Different Stats Examples',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Row of different stat examples
            Row(
              children: [
                // Beginner Stats
                Expanded(
                  child: CompactStatsDashboard(
                    stats: const UserStats(
                      moviesWatched: 3,
                      tvShowsWatched: 1,
                      totalHours: 12,
                      topGenres: ['Action'],
                    ),
                    onTap: () => _showSnackBar('Beginner Stats'),
                  ),
                ),

                const SizedBox(width: 16),

                // Power User Stats
                Expanded(
                  child: CompactStatsDashboard(
                    stats: const UserStats(
                      moviesWatched: 156,
                      tvShowsWatched: 89,
                      totalHours: 1247,
                      topGenres: [
                        'Drama',
                        'Thriller',
                        'Action',
                        'Comedy',
                        'Sci-Fi',
                      ],
                    ),
                    onTap: () => _showSnackBar('Power User Stats'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Controls
            _buildControls(),
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

          // Movies Watched Slider
          Row(
            children: [
              const Text('Movies:', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Slider(
                  value: _currentStats.moviesWatched.toDouble(),
                  min: 0,
                  max: 200,
                  divisions: 40,
                  label: _currentStats.moviesWatched.toString(),
                  onChanged: (value) {
                    setState(() {
                      _currentStats = _currentStats.copyWith(
                        moviesWatched: value.round(),
                      );
                    });
                  },
                ),
              ),
            ],
          ),

          // TV Shows Watched Slider
          Row(
            children: [
              const Text('TV Shows:', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Slider(
                  value: _currentStats.tvShowsWatched.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: _currentStats.tvShowsWatched.toString(),
                  onChanged: (value) {
                    setState(() {
                      _currentStats = _currentStats.copyWith(
                        tvShowsWatched: value.round(),
                      );
                    });
                  },
                ),
              ),
            ],
          ),

          // Total Hours Slider
          Row(
            children: [
              const Text('Hours:', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Slider(
                  value: _currentStats.totalHours.toDouble(),
                  min: 0,
                  max: 1000,
                  divisions: 50,
                  label: _currentStats.totalHours.toString(),
                  onChanged: (value) {
                    setState(() {
                      _currentStats = _currentStats.copyWith(
                        totalHours: value.round(),
                      );
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Preset Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () =>
                    setState(() => _currentStats = UserStats.empty()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade600,
                ),
                child: const Text('Empty'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _currentStats = const UserStats(
                    moviesWatched: 15,
                    tvShowsWatched: 8,
                    totalHours: 95,
                    topGenres: ['Action', 'Comedy'],
                  );
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
                child: const Text('Casual'),
              ),
              ElevatedButton(
                onPressed: () => setState(() {
                  _currentStats = const UserStats(
                    moviesWatched: 127,
                    tvShowsWatched: 64,
                    totalHours: 856,
                    topGenres: [
                      'Drama',
                      'Thriller',
                      'Action',
                      'Sci-Fi',
                      'Comedy',
                    ],
                  );
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                ),
                child: const Text('Enthusiast'),
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
}
