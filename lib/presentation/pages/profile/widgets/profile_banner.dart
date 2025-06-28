// lib/presentation/pages/profile/widgets/profile_banner.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../application/favorites/favorites_providers.dart';
import '../../../../application/profile/profile_providers.dart';
import '../../../core/app_colors.dart';

class ProfileBanner extends ConsumerWidget {
  const ProfileBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch both providers: one for user data, one for favorite posters
    final userAsync = ref.watch(userDocumentStreamProvider);
    final favoritesAsync = ref.watch(favoritesDetailsProvider);

    return userAsync.when(
      data: (doc) {
        final data = doc.data();
        final fullName = data?['fullName'] ?? 'PlotTwists User';
        final username = data?['username'] ?? 'username';
        final avatarUrl = data?['avatarUrl'];

        return SizedBox(
          height: 250, // A nice, substantial height for the banner
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Dynamic Blurred Background Collage
              favoritesAsync.when(
                data: (favorites) {
                  if (favorites.isEmpty) {
                    return Container(color: AppColors.darkSurface);
                  }
                  // Take the first 4 posters for the collage
                  final collagePosters = favorites
                      .take(4)
                      .map((f) => f['poster_path'] as String?)
                      .toList();
                  return _buildPosterCollage(collagePosters);
                },
                loading: () => Container(color: AppColors.darkSurface),
                error: (_, _) => Container(color: AppColors.darkSurface),
              ),

              // Frosted Glass effect and darkening gradient
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.8),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Main Content (Avatar and Name)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.darkSurface,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? const FaIcon(
                              FontAwesomeIcons.userAstronaut,
                              size: 40,
                              color: AppColors.darkTextSecondary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@$username',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(height: 250, color: AppColors.darkSurface),
      error: (_, __) =>
          SizedBox(height: 250, child: const Center(child: Text("Error"))),
    );
  }

  Widget _buildPosterCollage(List<String?> posterPaths) {
    return Row(
      children: posterPaths
          .map(
            (path) => Expanded(
              child: path != null
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500$path',
                      fit: BoxFit.cover,
                    )
                  : Container(),
            ),
          )
          .toList(),
    );
  }
}
