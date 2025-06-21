// lib/presentation/pages/discover/widgets/filter_bottom_sheet.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/discover/discover_providers.dart';
import '../../../../application/home/home_providers.dart';
import '../../../core/app_colors.dart';

void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const FilterBottomSheet(),
  );
}

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaType = ref.watch(mediaTypeNotifierProvider);
    final genresAsyncValue = ref.watch(genreListProvider(mediaType));
    final selectedGenres = ref.watch(discoverFiltersNotifierProvider);
    final notifier = ref.read(discoverFiltersNotifierProvider.notifier);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Filter by Genre",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: genresAsyncValue.when(
                data: (genres) => GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final isSelected = selectedGenres.contains(genre['id']);
                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          notifier.removeGenre(genre['id']);
                        } else {
                          notifier.addGenre(genre['id']);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: isSelected
                              ? AppColors.auroraGradient
                              : null,
                          border: Border.all(
                            color: AppColors.auroraPink.withOpacity(0.5),
                          ),
                          color: isSelected ? null : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            genre['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error: $e")),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => notifier.clearFilters(),
                      child: const Text("Clear All"),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.auroraPink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Apply"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
