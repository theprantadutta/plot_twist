// lib/presentation/pages/settings/favorite_genres_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_twist/application/discover/discover_providers.dart';
import 'package:plot_twist/application/settings/preferences_provider.dart';
import 'package:plot_twist/data/local/persistence_service.dart';
import 'package:plot_twist/presentation/core/app_colors.dart';

class FavoriteGenresScreen extends ConsumerWidget {
  const FavoriteGenresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers for both movie and TV genres
    final movieGenresAsync = ref.watch(genreListProvider(MediaType.movie));
    final tvGenresAsync = ref.watch(genreListProvider(MediaType.tv));

    // Watch the preferences provider to get the list of selected genre IDs
    // We use .value to safely access the data from the stream provider
    final selectedGenres =
        ref.watch(preferencesProvider).value?.favoriteGenres ?? [];
    final notifier = ref.read(preferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Favorite Genres"),
        backgroundColor: AppColors.darkSurface,
      ),
      // We use a body that handles the loading state of both genre lists
      body: _buildBody(
        context,
        movieGenresAsync,
        tvGenresAsync,
        selectedGenres,
        notifier,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> movieGenresAsync,
    AsyncValue<List<Map<String, dynamic>>> tvGenresAsync,
    List<int> selectedGenres,
    PreferencesNotifier notifier,
  ) {
    // Show a loading indicator if either list is still loading
    if (movieGenresAsync is AsyncLoading || tvGenresAsync is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show an error message if either list failed to load
    if (movieGenresAsync is AsyncError || tvGenresAsync is AsyncError) {
      return const Center(child: Text("Error: Could not load genres."));
    }

    // --- THIS IS THE FIXED DE-DUPLICATION LOGIC ---
    // Once both are loaded, combine them safely
    final movieGenres = movieGenresAsync.asData?.value ?? [];
    final tvGenres = tvGenresAsync.asData?.value ?? [];

    // Use a Map to automatically handle duplicates based on the genre ID
    final uniqueGenresMap = <int, String>{};
    for (var g in movieGenres) {
      uniqueGenresMap[g['id']] = g['name'];
    }
    for (var g in tvGenres) {
      uniqueGenresMap[g['id']] = g['name'];
    }

    // Convert the map to a sorted list
    final sortedGenres = uniqueGenresMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    // ---------------------------------------------

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
          checkColor: Colors.white,
        );
      },
    );
  }
}
