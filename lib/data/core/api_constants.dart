// lib/data/core/api_constants.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get tmdbApiKey {
    final key = dotenv.env['TMDB_API_KEY'];
    if (key == null) {
      throw Exception('TMDB_API_KEY not found in .env file. Please set it up.');
    }
    return key;
  }

  static const String baseUrl = "https://api.themoviedb.org/3";
  static const String requestTokenUrl = "$baseUrl/authentication/token/new";
  static const String validateTokenUrl =
      "$baseUrl/authentication/token/validate_with_login";
  static const String createSessionUrl = "$baseUrl/authentication/session/new";

  // This is the URL the user will be redirected to for authentication
  static String tmdbAuthUrl(String requestToken) =>
      'https://www.themoviedb.org/authenticate/$requestToken';
}
