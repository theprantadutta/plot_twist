// lib/application/favorites/favorites_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../discover/discover_providers.dart';

part 'favorites_providers.g.dart';

// // This provider fetches the full details for every item in the 'favorites' collection.
// @riverpod
// Future<List<Map<String, dynamic>>> favoritesDetails(
//   FavoritesDetailsRef ref,
// ) async {
//   final userId = FirebaseAuth.instance.currentUser?.uid;
//   if (userId == null) return [];

//   final repo = ref.watch(tmdbRepositoryProvider);

//   // 1. Get the list of document snapshots from the 'favorites' collection in Firestore
//   final favoritesSnapshot = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(userId)
//       .collection('favorites')
//       .orderBy('added_at', descending: true)
//       .get();

//   final docs = favoritesSnapshot.docs;

//   // 2. Create a list of futures for each TMDB API call
//   final futures = docs.map((doc) {
//     final data = doc.data();
//     final tmdbId = data['tmdb_id'] as int;
//     final type = data['type'] as String;
//     return repo.fetchMediaDetails(tmdbId, type);
//   }).toList();

//   // 3. Wait for all calls to complete and return the results
//   final results = await Future.wait(futures);
//   return results
//       .where((item) => item != null)
//       .cast<Map<String, dynamic>>()
//       .toList();
// }

// An enum to represent our filter states
enum FavoritesFilter { all, movies, tvShows }

// A provider to manage the currently selected filter tab
@Riverpod(keepAlive: true)
class FavoritesFilterNotifier extends _$FavoritesFilterNotifier {
  @override
  FavoritesFilter build() => FavoritesFilter.all;

  void setFilter(FavoritesFilter filter) {
    state = filter;
  }
}

// This existing provider fetches the details for every item in the 'favorites' collection.
@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> favoritesDetails(Ref ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final repo = ref.watch(tmdbRepositoryProvider);

  final favoritesSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('favorites')
      .orderBy('added_at', descending: true)
      .get();

  final docs = favoritesSnapshot.docs;

  final futures = docs.map((doc) {
    final data = doc.data();
    final tmdbId = data['tmdb_id'] as int;
    final type = data['type'] as String;
    return repo.fetchMediaDetails(tmdbId, type);
  }).toList();

  final results = await Future.wait(futures);
  return results
      .where((item) => item != null)
      .cast<Map<String, dynamic>>()
      .toList();
}
