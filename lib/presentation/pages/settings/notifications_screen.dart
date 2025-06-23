import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../application/settings/notification_settings_provider.dart';
import '../../core/app_colors.dart';
import 'widgets/settings_menu_item.dart';
import 'widgets/settings_section.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsNotifierProvider);
    final notifier = ref.read(notificationSettingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Notifications & Reminders"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- MOVIE REMINDERS SECTION ---
            SettingsSection(
              title: "Movie Reminders",
              children: [
                SwitchListTile(
                  title: const Text("Movie Premiere Reminders"),
                  subtitle: const Text(
                    "Get notified when a movie on your watchlist is released.",
                  ),
                  value: settings.moviePremiereReminders,
                  onChanged: notifier.setMoviePremiereReminders,
                  activeColor: AppColors.auroraPink,
                ),
                const Divider(height: 1, color: AppColors.darkBackground),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.clock,
                  iconColor: Colors.blue.shade300,
                  title: "Remind Me",
                  // Show the currently selected time
                  trailing: Text(
                    _getReminderText(settings.movieReminderTime),
                    style: const TextStyle(color: AppColors.darkTextSecondary),
                  ),
                  onTap: () {
                    // Tapping will open a dialog to change the time
                  },
                ),
              ],
            ),

            // --- TV SHOW REMINDERS SECTION ---
            SettingsSection(
              title: "TV Show Reminders",
              children: [
                SwitchListTile(
                  title: const Text("New Episode Reminders"),
                  subtitle: const Text("Get notified when a new episode airs."),
                  value: settings.tvEpisodeReminders,
                  onChanged: notifier.setTvEpisodeReminders,
                  activeColor: AppColors.auroraPink,
                ),
                const Divider(height: 1, color: AppColors.darkBackground),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.bell,
                  iconColor: Colors.orange.shade300,
                  title: "Notification Style",
                  trailing: const Text(
                    "On Air Day", // Placeholder
                    style: TextStyle(color: AppColors.darkTextSecondary),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getReminderText(int daysBefore) {
    if (daysBefore == 0) return "On release day";
    if (daysBefore == 1) return "1 day before";
    return "$daysBefore days before";
  }
}
