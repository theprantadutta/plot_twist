// lib/presentation/pages/detail/widgets/action_button_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../application/detail/detail_providers.dart';
import '../../../../data/firestore/firestore_service.dart';
import '../../../core/app_colors.dart';
import '../../discover/widgets/add_to_list_bottom_sheet.dart';

class ActionButtonBar extends ConsumerWidget {
  final Map<String, dynamic> media;
  const ActionButtonBar({super.key, required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaId = media['id'] as int;

    // Watch all our new providers
    final isInWatchlist =
        ref.watch(isMediaInWatchlistProvider(mediaId)).asData?.value ?? false;
    final isWatched =
        ref.watch(isMediaWatchedProvider(mediaId)).asData?.value ?? false;
    // final userRating = ref
    //     .watch(mediaUserRatingProvider(mediaId))
    //     .asData
    //     ?.value;
    final isFavorite =
        ref.watch(isMediaInFavoritesProvider(mediaId)).asData?.value ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Add to Watchlist Button
          _buildActionButton(
            context: context,
            icon: isInWatchlist
                ? FontAwesomeIcons.solidBookmark
                : FontAwesomeIcons.bookmark,
            label: "Watchlist",
            color: isInWatchlist
                ? AppColors.auroraPink
                : AppColors.darkTextSecondary,
            onTap: () {
              final service = FirestoreService();
              if (isInWatchlist) {
                service.removeFromList('watchlist', mediaId.toString());
              } else {
                service.addToList('watchlist', media);
              }
            },
          ),

          // Mark as Watched Button
          _buildActionButton(
            context: context,
            icon: FontAwesomeIcons.solidEye,
            label: "Watched",
            color: isWatched
                ? AppColors.auroraPink
                : AppColors.darkTextSecondary,
            onTap: () {
              final service = FirestoreService();
              if (isWatched) {
                // If it's already watched, maybe show a confirmation to un-watch it
                service.removeFromList('watched', mediaId.toString());
              } else {
                service.addToList('watched', media);
              }
            },
          ),

          // --- NEW "ADD TO LIST" BUTTON ---
          _buildActionButton(
            context: context,
            icon: Icons.playlist_add_rounded,
            label: "Add to List",
            onTap: () {
              // This shows our new, powerful bottom sheet
              showAddToListBottomSheet(context, media);
            },
          ),

          // Rate Button
          // _buildActionButton(
          //   context: context,
          //   icon: userRating != null
          //       ? FontAwesomeIcons.solidStar
          //       : FontAwesomeIcons.star,
          //   label: userRating != null ? "Rated ${userRating.toInt()}" : "Rate",
          //   color: userRating != null
          //       ? AppColors.darkStarlightGold
          //       : AppColors.darkTextSecondary,
          //   onTap: () {
          //     showRatingDialog(context, media, userRating ?? 5.0);
          //   },
          // ),

          // --- NEW FAVORITE BUTTON (Replaces the Rate button) ---
          _buildActionButton(
            context: context,
            icon: isFavorite
                ? FontAwesomeIcons.solidHeart
                : FontAwesomeIcons.heart,
            label: "Like",
            color: isFavorite
                ? Colors.red.shade400
                : AppColors.darkTextSecondary,
            onTap: () {
              final service = FirestoreService();
              if (isFavorite) {
                service.removeFromList('favorites', mediaId.toString());
              } else {
                service.addToList('favorites', media);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  icon,
                  color: color ?? AppColors.darkTextSecondary,
                  size: 22,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color ?? AppColors.darkTextSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
