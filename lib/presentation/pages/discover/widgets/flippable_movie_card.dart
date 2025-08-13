// lib/presentation/pages/discover/widgets/flippable_movie_card.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';

class FlippableMovieCard extends StatefulWidget {
  final Map<String, dynamic> movie;
  // We now accept the swipe progress to show the overlays
  final double swipeProgress;

  const FlippableMovieCard({
    super.key,
    required this.movie,
    this.swipeProgress = 0.0,
  });

  @override
  State<FlippableMovieCard> createState() => _FlippableMovieCardState();
}

class _FlippableMovieCardState extends State<FlippableMovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _flipCard() {
    if (_controller.isAnimating) return;
    setState(() => _isFront = !_isFront);
    if (_isFront) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: _animation.value >= 0.5
              ? Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _buildCardSide(isFront: false),
                )
              : _buildCardSide(isFront: true),
        );
      },
    );
  }

  Widget _buildCardSide({required bool isFront}) {
    final title = widget.movie['title'] ?? widget.movie['name'] ?? 'No Title';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.darkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: isFront ? _buildFront(title) : _buildBack(title),
      ),
    );
  }

  Widget _buildFront(String title) {
    final backdropPath = widget.movie['backdrop_path'];
    // Calculate opacity based on how far the user has swiped
    final likeOpacity = widget.swipeProgress.clamp(0.0, 1.0);
    final nopeOpacity = (-widget.swipeProgress).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (backdropPath != null)
          Image.network(
            'https://image.tmdb.org/t/p/w1280$backdropPath',
            fit: BoxFit.cover,
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.9),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
        // --- ACTION OVERLAYS ---
        // "LIKE" overlay, fades in when swiping right
        _buildActionOverlay(
          angle: -pi / 12,
          opacity: likeOpacity,
          color: Colors.green.shade400,
          icon: FontAwesomeIcons.solidHeart,
          text: "LIKE",
        ),
        // "NOPE" overlay, fades in when swiping left
        _buildActionOverlay(
          angle: pi / 12,
          opacity: nopeOpacity,
          color: Colors.red.shade400,
          icon: FontAwesomeIcons.xmark,
          text: "NOPE",
        ),
        // --- Card Content ---
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _flipCard,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      "Tap for details",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionOverlay({
    required double angle,
    required double opacity,
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Opacity(
      opacity: opacity,
      child: Center(
        child: Transform.rotate(
          angle: angle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBack(String title) {
    final posterPath = widget.movie['poster_path'];
    final overview = widget.movie['overview'] ?? 'No overview available.';
    final voteAverage =
        (widget.movie['vote_average'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.darkSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (posterPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500$posterPath',
                    width: 80,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          const Text(
            "Overview",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                overview,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
