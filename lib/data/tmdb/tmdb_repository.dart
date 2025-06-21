// lib/data/tmdb/tmdb_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/api_constants.dart';

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
}
