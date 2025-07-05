// lib/presentation/pages/settings/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plot_twist/application/settings/notification_settings_provider.dart';
import 'package:plot_twist/presentation/core/app_colors.dart';
import 'package:plot_twist/presentation/pages/settings/widgets/settings_menu_item.dart';

import 'widgets/settings_section.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsNotifierProvider);
    final notifier = ref.read(notificationSettingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Notifications & Reminders"),
        backgroundColor: AppColors.darkSurface,
      ),
      // Use the .when to handle loading/error for the initial settings fetch
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error loading settings: $e")),
        data: (settings) {
          // Once loaded, we build the UI. All subsequent updates will be seamless.
          final allEnabled = settings.allNotificationsEnabled;
          return SingleChildScrollView(
            child: Column(
              children: [
                // --- MASTER TOGGLE ---
                SettingsSection(
                  title: "Master Control",
                  children: [
                    SwitchListTile(
                      title: const Text("All Notifications"),
                      subtitle: const Text(
                        "Enable or disable all alerts from the app.",
                      ),
                      value: allEnabled,
                      onChanged: notifier.setAllNotifications,
                      activeColor: AppColors.auroraPink,
                    ),
                  ],
                ),

                // --- MOVIE REMINDERS SECTION ---
                // We use Opacity to visually disable the section if the master toggle is off
                Opacity(
                  opacity: allEnabled ? 1.0 : 0.5,
                  child: SettingsSection(
                    title: "Movie Reminders",
                    children: [
                      SwitchListTile(
                        title: const Text("Movie Premiere Reminders"),
                        subtitle: const Text(
                          "When a movie on your watchlist is released.",
                        ),
                        value: settings.moviePremiereReminders,
                        onChanged: allEnabled
                            ? notifier.setMoviePremiereReminders
                            : null,
                        activeColor: AppColors.auroraPink,
                      ),
                      const Divider(height: 1, color: AppColors.darkBackground),
                      SettingsMenuItem(
                        icon: FontAwesomeIcons.clock,
                        iconColor: Colors.blue.shade300,
                        title: "Remind Me",
                        trailing: Text(
                          _getReminderText(settings.movieReminderTime),
                          style: const TextStyle(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        onTap: allEnabled
                            ? () => _showReminderTimeDialog(
                                context,
                                notifier,
                                settings.movieReminderTime,
                              )
                            : () {},
                      ),
                    ],
                  ),
                ),

                // --- TV SHOW REMINDERS SECTION ---
                Opacity(
                  opacity: allEnabled ? 1.0 : 0.5,
                  child: SettingsSection(
                    title: "TV Show Reminders",
                    children: [
                      SwitchListTile(
                        title: const Text("New Episode Reminders"),
                        subtitle: const Text(
                          "When a new episode of a show on your watchlist airs.",
                        ),
                        value: settings.newEpisodeReminders,
                        onChanged: allEnabled
                            ? notifier.setNewEpisodeReminders
                            : null,
                        activeColor: AppColors.auroraPink,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getReminderText(int daysBefore) {
    if (daysBefore == 0) return "On release day";
    if (daysBefore == 1) return "1 day before";
    return "$daysBefore days before";
  }

  void _showReminderTimeDialog(
    BuildContext context,
    NotificationSettingsNotifier notifier,
    int currentSelection,
  ) {
    final options = {
      "On release day": 0,
      "1 day before": 1,
      "3 days before": 3,
      "1 week before": 7,
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Reminder Time"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.entries.map((entry) {
              return RadioListTile<int>(
                title: Text(entry.key),
                value: entry.value,
                groupValue: currentSelection,
                onChanged: (value) {
                  if (value != null) {
                    notifier.setMovieReminderTime(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
