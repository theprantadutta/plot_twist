// lib/data/tmdb/tmdb_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/api_constants.dart';
import '../local/persistence_service.dart';

class TmdbRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Private helper to add the API key to every request
  Map<String, dynamic> get _apiKeyParam => {'api_key': ApiConstants.tmdbApiKey};

  // Fetches a list of movies/tv shows from a given endpoint path
  Future<List<Map<String, dynamic>>> _fetchMediaList(String path) async {
    try {
      final response = await _dio.get(path, queryParameters: _apiKeyParam);
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      print("Error fetching media list from $path: ${e.message}");
      return [];
    }
  }

  // --- Methods for Home Screen Sections ---

  Future<List<Map<String, dynamic>>> getTrendingMoviesDay() =>
      _fetchMediaList('/trending/movie/day');
  Future<List<Map<String, dynamic>>> getTrendingAllWeek() =>
      _fetchMediaList('/trending/all/week');
  Future<List<Map<String, dynamic>>> getTopRatedTvShows() =>
      _fetchMediaList('/tv/top_rated');
  Future<List<Map<String, dynamic>>> getUpcomingMovies() =>
      _fetchMediaList('/movie/upcoming');
  Future<List<Map<String, dynamic>>> getTrendingTvShowsDay() =>
      _fetchMediaList('/trending/tv/day');
  Future<List<Map<String, dynamic>>> getTopRatedMovies() =>
      _fetchMediaList('/movie/top_rated');
  Future<List<Map<String, dynamic>>> getTrendingMoviesWeek() =>
      _fetchMediaList('/trending/movie/week');
  Future<List<Map<String, dynamic>>> getTrendingTvShowsWeek() =>
      _fetchMediaList('/trending/tv/week');

  // --- Methods for Personalized Data ---

  Future<String> getUsername() async {
    final user = _auth.currentUser;
    if (user == null) return "Guest";
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data()?['username'] ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  // A more complex method to fetch the user's watchlist from Firestore
  // and then get the details for each item from TMDB.
  Future<List<Map<String, dynamic>>> getWatchlist() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Assuming you store watchlist items in a subcollection like: /users/{uid}/watchlist/{docId}
      // where each document has a 'tmdb_id' and 'type' ('movie' or 'tv') field.
      final watchlistSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('watchlist')
          .get();

      final List<Future<Map<String, dynamic>?>> futures = watchlistSnapshot.docs
          .map((doc) async {
            final tmdbId = doc.data()['tmdb_id'];
            final type = doc.data()['type'];
            if (tmdbId != null && type != null) {
              return await _fetchMediaDetails(tmdbId, type);
            }
            return null;
          })
          .toList();

      final results = await Future.wait(futures);
      // Filter out any null results from failed fetches
      return results
          .where((item) => item != null)
          .cast<Map<String, dynamic>>()
          .toList();
    } catch (e) {
      print("Error fetching watchlist: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> _fetchMediaDetails(int id, String type) async {
    try {
      final response = await _dio.get(
        '/$type/$id',
        queryParameters: _apiKeyParam,
      );
      return response.data;
    } catch (e) {
      print("Error fetching details for $type/$id: $e");
      return null;
    }
  }

  // The main method for the Discover screen
  Future<List<Map<String, dynamic>>> discoverMedia({
    required MediaType type,
    int page = 1,
    String? sortBy,
    List<int>? withGenres,
  }) async {
    try {
      final queryParameters = {
        ..._apiKeyParam,
        'page': page,
        if (sortBy != null) 'sort_by': sortBy,
        if (withGenres != null && withGenres.isNotEmpty)
          'with_genres': withGenres.join(','),
      };
      final response = await _dio.get(
        '/discover/${type.name}',
        queryParameters: queryParameters,
      );
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      print("Error discovering media: ${e.message}");
      return [];
    }
  }

  // Method for the real-time search bar
  Future<List<Map<String, dynamic>>> searchMedia({
    required MediaType type,
    required String query,
    int page = 1,
  }) async {
    try {
      final queryParameters = {..._apiKeyParam, 'page': page, 'query': query};
      final response = await _dio.get(
        '/search/${type.name}',
        queryParameters: queryParameters,
      );
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      print("Error searching media: ${e.message}");
      return [];
    }
  }

  // Method to get the official list of all genres
  Future<List<Map<String, dynamic>>> getGenres(MediaType type) async {
    try {
      final response = await _dio.get(
        '/genre/${type.name}/list',
        queryParameters: _apiKeyParam,
      );
      return List<Map<String, dynamic>>.from(response.data['genres']);
    } on DioException catch (e) {
      print("Error fetching genres: ${e.message}");
      return [];
    }
  }

  // Method to get a list of currently popular actors/directors
  Future<List<Map<String, dynamic>>> getPopularPeople() async {
    try {
      final response = await _dio.get(
        '/person/popular',
        queryParameters: _apiKeyParam,
      );
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      print("Error fetching popular people: ${e.message}");
      return [];
    }
  }

  // A versatile method to get a "deck" of movies for swiping
  // Future<List<Map<String, dynamic>>> getDiscoverDeck({int page = 1}) async {
  //   try {
  //     final queryParameters = {
  //       ..._apiKeyParam,
  //       'page': page,
  //       'sort_by': 'popularity.desc', // A good default
  //       'vote_count.gte': 100, // Filter out movies with very few votes
  //       'watch_region': 'US', // Can be customized
  //     };
  //     final response = await _dio.get(
  //       '/discover/movie',
  //       queryParameters: queryParameters,
  //     );
  //     return List<Map<String, dynamic>>.from(response.data['results']);
  //   } on DioException catch (e) {
  //     print("Error fetching discover deck: ${e.message}");
  //     return [];
  //   }
  // }

  Future<List<Map<String, dynamic>>> getDiscoverDeck({
    required MediaType type, // It now requires a type
    int page = 1,
  }) async {
    try {
      final queryParameters = {
        'api_key': ApiConstants.tmdbApiKey,
        'page': page,
        'sort_by': 'popularity.desc',
        'vote_count.gte': 100,
        'watch_region': 'US',
      };
      // The path now dynamically uses the type's name ('movie' or 'tv')
      final response = await _dio.get(
        '/discover/${type.name}',
        queryParameters: queryParameters,
      );
      return List<Map<String, dynamic>>.from(response.data['results']);
    } on DioException catch (e) {
      print("Error fetching discover deck: ${e.message}");
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchMediaDetails(int id, String type) async {
    // Ensure type is either 'movie' or 'tv' to prevent invalid URLs
    if (type != 'movie' && type != 'tv') return null;

    try {
      final response = await _dio.get(
        '/$type/$id',
        queryParameters: _apiKeyParam,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print("Error fetching details for $type/$id: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> getMediaDetails({
    required int id,
    required MediaType type,
  }) async {
    // We request extra data all in one call for efficiency
    const String appendToResponse =
        'videos,credits,reviews,similar,external_ids';

    try {
      final response = await _dio.get(
        '/${type.name}/$id',
        queryParameters: {
          ..._apiKeyParam,
          'append_to_response': appendToResponse,
        },
      );
      return response.data;
    } on DioException catch (e) {
      print("Error fetching media details: ${e.message}");
      // Re-throw the exception so the UI layer can handle it
      throw Exception('Failed to load media details');
    }
  }

  Future<Map<String, dynamic>> getSeasonDetails({
    required int tvId,
    required int seasonNumber,
  }) async {
    try {
      final response = await _dio.get(
        '/tv/$tvId/season/$seasonNumber',
        queryParameters: _apiKeyParam,
      );
      return response.data;
    } on DioException catch (e) {
      print("Error fetching season details: ${e.message}");
      throw Exception('Failed to load season details');
    }
  }
}
