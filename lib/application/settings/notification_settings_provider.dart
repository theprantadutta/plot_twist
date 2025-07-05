// lib/application/settings/notification_settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:plot_twist/data/firestore/firestore_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_settings_provider.g.dart';

// A data class to hold our settings state cleanly
@immutable
class NotificationSettingsState {
  final bool allNotificationsEnabled;
  final bool moviePremiereReminders;
  final int movieReminderTime; // e.g., 0 for on day, 1 for 1 day before
  final bool newEpisodeReminders;

  // Default values for a new user
  const NotificationSettingsState({
    this.allNotificationsEnabled = true,
    this.moviePremiereReminders = true,
    this.movieReminderTime = 1,
    this.newEpisodeReminders = true,
  });

  // Helper to create a copy of the state with new values
  NotificationSettingsState copyWith({
    bool? allNotificationsEnabled,
    bool? moviePremiereReminders,
    int? movieReminderTime,
    bool? newEpisodeReminders,
  }) {
    return NotificationSettingsState(
      allNotificationsEnabled:
          allNotificationsEnabled ?? this.allNotificationsEnabled,
      moviePremiereReminders:
          moviePremiereReminders ?? this.moviePremiereReminders,
      movieReminderTime: movieReminderTime ?? this.movieReminderTime,
      newEpisodeReminders: newEpisodeReminders ?? this.newEpisodeReminders,
    );
  }
}

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  final _service = FirestoreService();

  @override
  Stream<NotificationSettingsState> build() {
    return _service.getNotificationSettingsStream().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        // Create state from Firestore data, providing defaults if fields are missing
        return NotificationSettingsState(
          allNotificationsEnabled: data['allNotificationsEnabled'] ?? true,
          moviePremiereReminders: data['moviePremiereReminders'] ?? true,
          movieReminderTime: data['movieReminderTime'] ?? 1,
          newEpisodeReminders: data['newEpisodeReminders'] ?? true,
        );
      } else {
        // Return the default state if the document doesn't exist yet
        return const NotificationSettingsState();
      }
    });
  }

  // --- Methods to update specific settings ---

  Future<void> setAllNotifications(bool isEnabled) async {
    await _service.updateNotificationSettings({
      'allNotificationsEnabled': isEnabled,
    });
  }

  Future<void> setMoviePremiereReminders(bool isEnabled) async {
    await _service.updateNotificationSettings({
      'moviePremiereReminders': isEnabled,
    });
  }

  Future<void> setMovieReminderTime(int daysBefore) async {
    await _service.updateNotificationSettings({
      'movieReminderTime': daysBefore,
    });
  }

  Future<void> setNewEpisodeReminders(bool isEnabled) async {
    await _service.updateNotificationSettings({
      'newEpisodeReminders': isEnabled,
    });
  }
}
