// lib/presentation/pages/detail/widgets/detail_hero_section.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';

class DetailHeroSection extends StatelessWidget {
  final Map<String, dynamic> media;
  final VoidCallback? onPlayTrailer;

  const DetailHeroSection({super.key, required this.media, this.onPlayTrailer});

  @override
  Widget build(BuildContext context) {
    final backdropPath = media['backdrop_path'];
    final title = media['title'] ?? media['name'] ?? 'No Title';

    return SizedBox(
      height: 450, // Increased height for a more epic feel
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred Background Image
          if (backdropPath != null)
            Image.network(
              'https://image.tmdb.org/t/p/w1280$backdropPath',
              fit: BoxFit.cover,
            ).animate().fadeIn(duration: 600.ms),

          // Frosted Glass effect & Darkening Gradient
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.darkBackground.withOpacity(0.5),
                      AppColors.darkBackground,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Centered Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                // Poster Image with shadow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${media['poster_path']}',
                      height: 220,
                    ),
                  ),
                ).animate().scale(
                  delay: 200.ms,
                  duration: 500.ms,
                  curve: Curves.easeOut,
                ),
                const Spacer(),
                // Title
                Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 24),
                // Play Trailer Button
                if (onPlayTrailer != null)
                  ElevatedButton.icon(
                    onPressed: onPlayTrailer,
                    icon: const FaIcon(FontAwesomeIcons.play, size: 16),
                    label: const Text("Play Trailer"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: AppColors.auroraPink,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5),
              ],
            ),
          ),
          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
