// lib/presentation/pages/settings/watch_providers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_twist/application/settings/preferences_provider.dart';
import 'package:plot_twist/presentation/core/app_colors.dart';

class WatchProvidersScreen extends ConsumerWidget {
  const WatchProvidersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providersAsync = ref.watch(watchProvidersProvider);
    final selectedProviders =
        ref.watch(preferencesProvider).value?.watchProviders ?? [];
    final notifier = ref.read(preferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("My Subscriptions"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: providersAsync.when(
        data: (providers) {
          providers.sort(
            (a, b) => (a['display_priority'] as int).compareTo(
              b['display_priority'] as int,
            ),
          );
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              final providerId = provider['provider_id'] as int;
              final isSelected = selectedProviders.contains(providerId);
              return GestureDetector(
                onTap: () => notifier.toggleWatchProvider(providerId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.auroraPink, width: 3)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w200${provider['logo_path']}',
                    ),
                  ),
                ),
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
