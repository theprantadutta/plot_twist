import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/discover/discover_providers.dart';
import '../../../application/settings/preferences_provider.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';

class FavoriteGenresScreen extends ConsumerWidget {
  const FavoriteGenresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We fetch genres for both movies and TV to show a comprehensive list
    final movieGenresAsync = ref.watch(genreListProvider(MediaType.movie));
    final tvGenresAsync = ref.watch(genreListProvider(MediaType.tv));
    final selectedGenres = ref
        .watch(preferencesNotifierProvider)
        .favoriteGenres;
    final notifier = ref.read(preferencesNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Favorite Genres"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: movieGenresAsync.when(
        data: (movieGenres) {
          // Combine and de-duplicate movie and TV genres
          final allGenres = {
            ...movieGenres,
            ...tvGenresAsync.asData?.value ?? [],
          };
          final uniqueGenres = {for (var g in allGenres) g['id']: g['name']};
          final sortedGenres = uniqueGenres.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value));

          return ListView.builder(
            itemCount: sortedGenres.length,
            itemBuilder: (context, index) {
              final genre = sortedGenres[index];
              final isSelected = selectedGenres.contains(genre.key);
              return CheckboxListTile(
                title: Text(genre.value),
                value: isSelected,
                onChanged: (bool? value) {
                  notifier.toggleFavoriteGenre(genre.key);
                },
                activeColor: AppColors.auroraPink,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
