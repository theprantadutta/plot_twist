// lib/data/local/persistence_service.dart
import 'package:shared_preferences/shared_preferences.dart';

// Using an enum is much safer than using raw strings
enum MediaType { movie, tv }

class PersistenceService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Load the last selected media type, defaulting to 'movie'
  MediaType getMediaType() {
    final typeString = _prefs.getString('selectedMediaType') ?? 'movie';
    return MediaType.values.firstWhere((e) => e.name == typeString);
  }

  // Save the user's choice
  Future<void> setMediaType(MediaType type) async {
    await _prefs.setString('selectedMediaType', type.name);
  }
}
