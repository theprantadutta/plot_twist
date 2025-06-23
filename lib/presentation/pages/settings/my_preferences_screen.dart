import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../application/settings/preferences_provider.dart';
import '../../../data/local/persistence_service.dart';
import '../../core/app_colors.dart';
import 'favorite_genres_screen.dart';
import 'widgets/settings_menu_item.dart';
import 'widgets/settings_section.dart';

class MyPreferencesScreen extends ConsumerWidget {
  const MyPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesNotifierProvider);
    final notifier = ref.read(preferencesNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("My Preferences"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingsSection(
              title: "Default View",
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CupertinoSlidingSegmentedControl<DefaultView>(
                    groupValue: preferences.defaultView,
                    backgroundColor: AppColors.darkBackground,
                    thumbColor: AppColors.auroraPink,
                    onValueChanged: (view) {
                      if (view != null) notifier.setDefaultView(view);
                    },
                    children: const {
                      DefaultView.movies: Text("Movies"),
                      DefaultView.tv: Text("TV Shows"),
                      DefaultView.remember: Text("Remember Last"),
                    },
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: "Content",
              children: [
                SettingsMenuItem(
                  icon: FontAwesomeIcons.solidHeart,
                  iconColor: Colors.red.shade300,
                  title: "Favorite Genres",
                  subtitle: "${preferences.favoriteGenres.length} selected",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FavoriteGenresScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.darkBackground),
                SwitchListTile(
                  title: const Text("Include Adult Content"),
                  value: preferences.includeAdultContent,
                  onChanged: notifier.setIncludeAdultContent,
                  activeColor: AppColors.auroraPink,
                ),
                const Divider(height: 1, color: AppColors.darkBackground),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.globe,
                  iconColor: Colors.green.shade300,
                  title: "Content Region",
                  trailing: Text(
                    preferences.contentRegion,
                    style: const TextStyle(color: AppColors.darkTextSecondary),
                  ),
                  onTap: () {
                    // In a real app, this would open a country picker dialog
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
