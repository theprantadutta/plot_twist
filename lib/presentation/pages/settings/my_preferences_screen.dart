// lib/presentation/pages/settings/my_preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plot_twist/application/settings/preferences_provider.dart';
import 'package:plot_twist/presentation/core/app_colors.dart';

import 'favorite_genres_screen.dart';
import 'watch_providers_screen.dart'; // Import the new screen
import 'widgets/settings_menu_item.dart';
import 'widgets/settings_section.dart';

class MyPreferencesScreen extends ConsumerWidget {
  const MyPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that is now a StreamProvider, so we use .when
    final preferencesAsync = ref.watch(preferencesNotifierProvider);
    final notifier = ref.read(preferencesNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("My Preferences"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
        data: (preferences) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // --- CONTENT PREFERENCES SECTION ---
                SettingsSection(
                  title: "Content",
                  children: [
                    SettingsMenuItem(
                      icon: FontAwesomeIcons.solidHeart,
                      iconColor: Colors.red.shade300,
                      title: "Favorite Genres",
                      subtitle: "${preferences.favoriteGenres.length} selected",
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FavoriteGenresScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.darkBackground),
                    // NEW: My Subscriptions
                    SettingsMenuItem(
                      icon: FontAwesomeIcons.satelliteDish,
                      iconColor: Colors.green.shade300,
                      title: "My Subscriptions",
                      subtitle: "${preferences.watchProviders.length} selected",
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WatchProvidersScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                // --- Browse PREFERENCES SECTION ---
                SettingsSection(
                  title: "Browse",
                  children: [
                    SwitchListTile(
                      title: const Text("Hide Watched Items"),
                      subtitle: const Text(
                        "Remove items you've watched from discovery.",
                      ),
                      value: preferences.hideWatched,
                      onChanged: notifier.setHideWatched,
                      activeColor: AppColors.auroraPink,
                    ),
                    const Divider(height: 1, color: AppColors.darkBackground),
                    SwitchListTile(
                      title: const Text("Include Adult Content"),
                      value: preferences.includeAdultContent,
                      onChanged: notifier.setIncludeAdultContent,
                      activeColor: AppColors.auroraPink,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
