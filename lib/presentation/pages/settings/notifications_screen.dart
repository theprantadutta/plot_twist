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
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Notifications & Reminders"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error loading settings: $e")),
        data: (settings) {
          final allEnabled = settings.allNotificationsEnabled;
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 20),
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
                      activeThumbColor: AppColors.auroraPink,
                    ),
                  ],
                ),

                // Use Opacity to visually disable sections if the master toggle is off
                Opacity(
                  opacity: allEnabled ? 1.0 : 0.5,
                  child: AbsorbPointer(
                    absorbing: !allEnabled, // Also prevent taps
                    child: Column(
                      children: [
                        // --- PERSONAL ALERTS SECTION ---
                        SettingsSection(
                          title: "Personal Alerts",
                          children: [
                            SwitchListTile(
                              title: const Text("Movie Premiere Reminders"),
                              subtitle: const Text(
                                "When a movie on your watchlist is released.",
                              ),
                              value: settings.moviePremiereReminders,
                              onChanged: notifier.setMoviePremiereReminders,
                              activeThumbColor: AppColors.auroraPink,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.darkBackground,
                            ),
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
                              onTap: () => _showReminderTimeDialog(
                                context,
                                notifier,
                                settings.movieReminderTime,
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.darkBackground,
                            ),
                            SwitchListTile(
                              title: const Text("New Episode Reminders"),
                              subtitle: const Text(
                                "When a new episode of a show you follow airs.",
                              ),
                              value: settings.newEpisodeReminders,
                              onChanged: notifier.setNewEpisodeReminders,
                              activeThumbColor: AppColors.auroraPink,
                            ),
                          ],
                        ),

                        // --- DISCOVERY & RECOMMENDATIONS SECTION ---
                        SettingsSection(
                          title: "Discovery & Recommendations",
                          children: [
                            SwitchListTile(
                              title: const Text("Trending This Week"),
                              subtitle: const Text(
                                "A weekly roundup of what's popular.",
                              ),
                              value: settings.trendingReminders,
                              onChanged: notifier.setTrendingReminders,
                              activeThumbColor: AppColors.auroraPink,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.darkBackground,
                            ),
                            SwitchListTile(
                              title: const Text("Hidden Gem Suggestions"),
                              subtitle: const Text(
                                "Occasional recommendations based on your taste.",
                              ),
                              value: settings.suggestionReminders,
                              onChanged: notifier.setSuggestionReminders,
                              activeThumbColor: AppColors.auroraPink,
                            ),
                          ],
                        ),

                        // --- NEW DAILY DIGESTS SECTION ---
                        SettingsSection(
                          title: "Daily Digests (Opt-In)",
                          children: [
                            SwitchListTile(
                              title: const Text("Daily Movie Marathon"),
                              subtitle: const Text(
                                "Get a daily movie suggestion from your watchlist.",
                              ),
                              value: settings.dailyMovieMarathon,
                              onChanged: notifier.setDailyMovieMarathon,
                              activeThumbColor: AppColors.auroraPink,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.darkBackground,
                            ),
                            SwitchListTile(
                              title: const Text("Daily TV Pick"),
                              subtitle: const Text(
                                "Get a suggestion for a TV show you might like.",
                              ),
                              value: settings.dailyTvPick,
                              onChanged: notifier.setDailyTvPick,
                              activeThumbColor: AppColors.auroraPink,
                            ),
                          ],
                        ),
                      ],
                    ),
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
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Set Reminder Time"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.entries.map((entry) {
              return RadioListTile<int>(
                title: Text(entry.key),
                value: entry.value,
                groupValue: currentSelection,
                activeColor: AppColors.auroraPink,
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
