import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/firestore/firestore_service.dart';

part 'notification_settings_provider.g.dart';

// The data class now holds all our new settings
@immutable
class NotificationSettingsState {
  final bool allNotificationsEnabled;
  // Personal Alerts
  final bool moviePremiereReminders;
  final int movieReminderTime;
  final bool newEpisodeReminders;
  // Discovery & Recommendation Alerts
  final bool trendingReminders;
  final bool suggestionReminders;
  // New Daily Alerts
  final bool dailyMovieMarathon;
  final bool dailyTvPick;

  // Default values for a new user
  const NotificationSettingsState({
    this.allNotificationsEnabled = true,
    this.moviePremiereReminders = true,
    this.movieReminderTime = 1,
    this.newEpisodeReminders = true,
    this.trendingReminders = true,
    this.suggestionReminders = true,
    // The new daily notifications are OFF by default
    this.dailyMovieMarathon = false,
    this.dailyTvPick = false,
  });

  // Helper to create a copy of the state with new values
  NotificationSettingsState copyWith({
    bool? allNotificationsEnabled,
    bool? moviePremiereReminders,
    int? movieReminderTime,
    bool? newEpisodeReminders,
    bool? trendingReminders,
    bool? suggestionReminders,
    bool? dailyMovieMarathon,
    bool? dailyTvPick,
  }) {
    return NotificationSettingsState(
      allNotificationsEnabled:
          allNotificationsEnabled ?? this.allNotificationsEnabled,
      moviePremiereReminders:
          moviePremiereReminders ?? this.moviePremiereReminders,
      movieReminderTime: movieReminderTime ?? this.movieReminderTime,
      newEpisodeReminders: newEpisodeReminders ?? this.newEpisodeReminders,
      trendingReminders: trendingReminders ?? this.trendingReminders,
      suggestionReminders: suggestionReminders ?? this.suggestionReminders,
      dailyMovieMarathon: dailyMovieMarathon ?? this.dailyMovieMarathon,
      dailyTvPick: dailyTvPick ?? this.dailyTvPick,
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
          trendingReminders: data['trendingReminders'] ?? true,
          suggestionReminders: data['suggestionReminders'] ?? true,
          dailyMovieMarathon:
              data['dailyMovieMarathon'] ?? false, // Default to false
          dailyTvPick: data['dailyTvPick'] ?? false, // Default to false
        );
      } else {
        // Return the default state if the document doesn't exist yet
        return const NotificationSettingsState();
      }
    });
  }

  // --- Methods to update specific settings in Firestore ---

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

  Future<void> setTrendingReminders(bool isEnabled) async {
    await _service.updateNotificationSettings({'trendingReminders': isEnabled});
  }

  Future<void> setSuggestionReminders(bool isEnabled) async {
    await _service.updateNotificationSettings({
      'suggestionReminders': isEnabled,
    });
  }

  // New methods for the new daily settings
  Future<void> setDailyMovieMarathon(bool isEnabled) async {
    await _service.updateNotificationSettings({
      'dailyMovieMarathon': isEnabled,
    });
  }

  Future<void> setDailyTvPick(bool isEnabled) async {
    await _service.updateNotificationSettings({'dailyTvPick': isEnabled});
  }
}
