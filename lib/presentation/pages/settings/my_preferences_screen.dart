// // lib/presentation/pages/settings/my_preferences_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:plot_twist/application/settings/preferences_provider.dart';
// import 'package:plot_twist/presentation/core/app_colors.dart';

// import 'favorite_genres_screen.dart';
// import 'watch_providers_screen.dart'; // Import the new screen
// import 'widgets/settings_menu_item.dart';
// import 'widgets/settings_section.dart';

// class MyPreferencesScreen extends ConsumerWidget {
//   const MyPreferencesScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch the provider that is now a StreamProvider, so we use .when
//     final preferencesAsync = ref.watch(preferencesNotifierProvider);
//     final notifier = ref.read(preferencesNotifierProvider.notifier);

//     return Scaffold(
//       backgroundColor: AppColors.darkBackground,
//       appBar: AppBar(
//         title: const Text("My Preferences"),
//         backgroundColor: AppColors.darkSurface,
//       ),
//       body: preferencesAsync.when(
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, s) => Center(child: Text("Error: $e")),
//         data: (preferences) {
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(height: 10),
//                 // --- Add A Coming soon Flat ---
//                 const Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Text("Coming soon..."),
//                 ),
//                 SizedBox(height: 10),
//                 Opacity(
//                   opacity: 0.5,
//                   child: Column(
//                     children: [
//                       // --- CONTENT PREFERENCES SECTION ---
//                       SettingsSection(
//                         title: "Content",
//                         children: [
//                           SettingsMenuItem(
//                             icon: FontAwesomeIcons.solidHeart,
//                             iconColor: Colors.red.shade300,
//                             title: "Favorite Genres",
//                             subtitle:
//                                 "${preferences.favoriteGenres.length} selected",
//                             onTap: () => Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (_) => const FavoriteGenresScreen(),
//                               ),
//                             ),
//                           ),
//                           const Divider(
//                             height: 1,
//                             color: AppColors.darkBackground,
//                           ),
//                           // NEW: My Subscriptions
//                           SettingsMenuItem(
//                             icon: FontAwesomeIcons.satelliteDish,
//                             iconColor: Colors.green.shade300,
//                             title: "My Subscriptions",
//                             subtitle:
//                                 "${preferences.watchProviders.length} selected",
//                             onTap: () => Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (_) => const WatchProvidersScreen(),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       // --- Browse PREFERENCES SECTION ---
//                       SettingsSection(
//                         title: "Browse",
//                         children: [
//                           SwitchListTile(
//                             title: const Text("Hide Watched Items"),
//                             subtitle: const Text(
//                               "Remove items you've watched from discovery.",
//                             ),
//                             value: preferences.hideWatched,
//                             onChanged: notifier.setHideWatched,
//                             activeColor: AppColors.auroraPink,
//                           ),
//                           const Divider(
//                             height: 1,
//                             color: AppColors.darkBackground,
//                           ),
//                           SwitchListTile(
//                             title: const Text("Include Adult Content"),
//                             value: preferences.includeAdultContent,
//                             onChanged: notifier.setIncludeAdultContent,
//                             activeColor: AppColors.auroraPink,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../application/settings/preferences_provider.dart';
import '../../core/app_colors.dart';

class MyPreferencesScreen extends ConsumerWidget {
  const MyPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We still watch the provider to ensure the screen can be updated later
    // without changing the core structure.
    final preferencesAsync = ref.watch(preferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("My Preferences"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: preferencesAsync.when(
        // We can show the same placeholder for all states for now
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
        data: (preferences) {
          // --- THIS IS THE NEW "COMING SOON" UI ---
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.gears,
                    size: 60,
                    color: AppColors.auroraPink,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "More Personalization Coming Soon!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "We're working on powerful new ways for you to tailor your PlotTwists experience. Here's what's planned:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // List of upcoming features
                  _buildFeatureChip("✓ Favorite Genres"),
                  _buildFeatureChip("✓ My Streaming Services"),
                  _buildFeatureChip("✓ Hide Watched Items from Discovery"),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms);
        },
      ),
    );
  }

  // A helper widget to create styled chips for the feature list
  Widget _buildFeatureChip(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
