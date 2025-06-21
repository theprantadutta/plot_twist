import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class GenreCard extends StatelessWidget {
  final String genreName;
  final String imageUrl; // A representative image for the genre

  const GenreCard({super.key, required this.genreName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.darkSurface),
            ),
            // Dark overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  begin: Alignment.center,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            // Centered Text with a subtle glow
            Center(
              child: Text(
                genreName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 20, color: AppColors.auroraPink),
                    Shadow(blurRadius: 30, color: AppColors.auroraPurple),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
