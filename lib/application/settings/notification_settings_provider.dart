import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/persistence_service.dart';
import '../home/home_providers.dart'; // To get the persistenceServiceProvider

part 'notification_settings_provider.g.dart';

// A class to hold all our notification settings state
class NotificationSettingsState {
  final bool moviePremiereReminders;
  final int movieReminderTime;
  final bool tvEpisodeReminders;

  NotificationSettingsState({
    required this.moviePremiereReminders,
    required this.movieReminderTime,
    required this.tvEpisodeReminders,
  });

  NotificationSettingsState copyWith({
    bool? moviePremiereReminders,
    int? movieReminderTime,
    bool? tvEpisodeReminders,
  }) {
    return NotificationSettingsState(
      moviePremiereReminders:
          moviePremiereReminders ?? this.moviePremiereReminders,
      movieReminderTime: movieReminderTime ?? this.movieReminderTime,
      tvEpisodeReminders: tvEpisodeReminders ?? this.tvEpisodeReminders,
    );
  }
}

// The Notifier that manages the state
@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  late PersistenceService _persistenceService;

  @override
  NotificationSettingsState build() {
    _persistenceService = ref.watch(persistenceServiceProvider);
    return NotificationSettingsState(
      moviePremiereReminders: _persistenceService
          .getMoviePremiereRemindersEnabled(),
      movieReminderTime: _persistenceService.getMovieReminderTime(),
      tvEpisodeReminders: _persistenceService.getTvEpisodeRemindersEnabled(),
    );
  }

  void setMoviePremiereReminders(bool isEnabled) {
    _persistenceService.setMoviePremiereRemindersEnabled(isEnabled);
    state = state.copyWith(moviePremiereReminders: isEnabled);
  }

  void setMovieReminderTime(int daysBefore) {
    _persistenceService.setMovieReminderTime(daysBefore);
    state = state.copyWith(movieReminderTime: daysBefore);
  }

  void setTvEpisodeReminders(bool isEnabled) {
    _persistenceService.setTvEpisodeRemindersEnabled(isEnabled);
    state = state.copyWith(tvEpisodeReminders: isEnabled);
  }
}
