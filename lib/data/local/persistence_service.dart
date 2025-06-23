// lib/data/local/persistence_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Using an enum is much safer than using raw strings
enum MediaType { movie, tv }

// New enum for the default view preference
enum DefaultView { movies, tv, remember }

class PersistenceService {
  late SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Load the last selected media type, defaulting to 'movie'
  MediaType getMediaType() {
    final typeString = _preferences.getString('selectedMediaType') ?? 'movie';
    return MediaType.values.firstWhere((e) => e.name == typeString);
  }

  // Save the user's choice
  Future<void> setMediaType(MediaType type) async {
    await _preferences.setString('selectedMediaType', type.name);
  }

  // --- NEW NOTIFICATION PREFERENCE METHODS ---

  // For Movie Premiere Reminders
  bool getMoviePremiereRemindersEnabled() =>
      _preferences.getBool('moviePremiereReminders') ?? false;
  Future<void> setMoviePremiereRemindersEnabled(bool isEnabled) async =>
      await _preferences.setBool('moviePremiereReminders', isEnabled);

  // For Movie Reminder Time (storing days before)
  int getMovieReminderTime() =>
      _preferences.getInt('movieReminderTime') ?? 1; // Default to 1 day before
  Future<void> setMovieReminderTime(int daysBefore) async =>
      await _preferences.setInt('movieReminderTime', daysBefore);

  // For TV Episode Reminders
  bool getTvEpisodeRemindersEnabled() =>
      _preferences.getBool('tvEpisodeReminders') ?? false;
  Future<void> setTvEpisodeRemindersEnabled(bool isEnabled) async =>
      await _preferences.setBool('tvEpisodeReminders', isEnabled);

  // Theme Mode (Light, Dark, or System)
  ThemeMode getThemeMode() {
    final themeString =
        _preferences.getString('themeMode') ?? 'dark'; // Default to dark
    return ThemeMode.values.firstWhere((e) => e.name == themeString);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _preferences.setString('themeMode', mode.name);
  }

  // Accent Color (storing the color's integer value)
  int getAccentColorValue() =>
      _preferences.getInt('accentColor') ?? 0xFFFF00A8; // Default to our blue
  Future<void> setAccentColorValue(int colorValue) async {
    await _preferences.setInt('accentColor', colorValue);
  }

  // True Black (OLED) Mode
  bool getTrueBlackEnabled() => _preferences.getBool('trueBlack') ?? false;
  Future<void> setTrueBlackEnabled(bool isEnabled) async {
    await _preferences.setBool('trueBlack', isEnabled);
  }

  // Default View Preference
  DefaultView getDefaultView() {
    final viewString = _preferences.getString('defaultView') ?? 'remember';
    return DefaultView.values.firstWhere((e) => e.name == viewString);
  }

  Future<void> setDefaultView(DefaultView view) async {
    await _preferences.setString('defaultView', view.name);
  }

  // Favorite Genres (stored as a list of strings)
  List<int> getFavoriteGenres() {
    final genreStrings = _preferences.getStringList('favoriteGenres') ?? [];
    return genreStrings.map((id) => int.parse(id)).toList();
  }

  Future<void> setFavoriteGenres(List<int> genreIds) async {
    final genreStrings = genreIds.map((id) => id.toString()).toList();
    await _preferences.setStringList('favoriteGenres', genreStrings);
  }

  // Include Adult Content
  bool getIncludeAdultContent() =>
      _preferences.getBool('includeAdult') ?? false;
  Future<void> setIncludeAdultContent(bool isEnabled) async {
    await _preferences.setBool('includeAdult', isEnabled);
  }

  // Content Region
  String getContentRegion() =>
      _preferences.getString('contentRegion') ?? 'US'; // Default to US
  Future<void> setContentRegion(String region) async {
    await _preferences.setString('contentRegion', region);
  }
}
