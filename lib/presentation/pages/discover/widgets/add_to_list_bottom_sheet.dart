import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../data/firestore/firestore_service.dart';
import '../../../core/app_colors.dart';

// A function to show our custom bottom sheet
void showAddToListBottomSheet(
  BuildContext context,
  Map<String, dynamic> movie,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddToListBottomSheet(movie: movie),
  );
}

class AddToListBottomSheet extends ConsumerWidget {
  final Map<String, dynamic> movie;
  const AddToListBottomSheet({super.key, required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = movie['title'] ?? movie['name'] ?? 'No Title';
    final posterPath = movie['poster_path'];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top movie info row
            Row(
              children: [
                if (posterPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500$posterPath',
                      height: 90,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32, color: Colors.white12),
            // List options
            _buildListOption(
              context: context,
              title: "Watchlist",
              subtitle: "Plan to watch",
              icon: FontAwesomeIcons.solidBookmark,
              onTap: () async {
                await FirestoreService().addToList('watchlist', movie);
                Navigator.pop(context); // Close the sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added to Watchlist")),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildListOption(
              context: context,
              title: "Watched",
              subtitle: "Mark as seen",
              icon: FontAwesomeIcons.solidEye,
              onTap: () async {
                await FirestoreService().addToList('watched', movie);
                Navigator.pop(context); // Close the sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Marked as Watched")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: FaIcon(icon, color: AppColors.auroraPink),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
      trailing: IconButton(
        icon: const Icon(
          Icons.add_circle_outline_rounded,
          color: Colors.white70,
        ),
        onPressed: onTap,
      ),
      onTap: onTap,
    );
  }
}
