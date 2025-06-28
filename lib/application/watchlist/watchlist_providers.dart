import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../discover/discover_providers.dart';

part 'watchlist_providers.g.dart';

// An enum to represent our filter states
enum WatchlistFilter { all, movies, tvShows }

// 1. A provider to manage the currently selected filter tab
@Riverpod(keepAlive: true)
class WatchlistFilterNotifier extends _$WatchlistFilterNotifier {
  @override
  WatchlistFilter build() => WatchlistFilter.all;

  void setFilter(WatchlistFilter filter) {
    state = filter;
  }
}

// 2. A provider to fetch the raw watchlist data from Firestore
@Riverpod(keepAlive: true)
Stream<List<QueryDocumentSnapshot>> watchlistStream(Ref ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]); // Return empty stream if no user
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('watchlist')
      .orderBy('added_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs);
}

// 3. The final provider that combines the stream and the filter
// It provides the final, filtered list to the UI.
@Riverpod(keepAlive: true)
List<QueryDocumentSnapshot> filteredWatchlist(Ref ref) {
  final filter = ref.watch(watchlistFilterNotifierProvider);
  final watchlist = ref.watch(watchlistStreamProvider).asData?.value ?? [];

  if (filter == WatchlistFilter.all) {
    return watchlist;
  }

  if (filter == WatchlistFilter.movies) {
    return watchlist.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['type'] == 'movie';
    }).toList();
  }
  if (filter == WatchlistFilter.tvShows) {
    return watchlist.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['type'] == 'tv';
    }).toList();
  }
  return [];
}

// It fetches the watchlist IDs and then fetches the details for each ID from TMDB.
@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> watchlistDetails(Ref ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final repo = ref.watch(tmdbRepositoryProvider);

  // 1. Get the list of document snapshots from Firestore
  final watchlistSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('watchlist')
      .orderBy('added_at', descending: true)
      .get();

  final docs = watchlistSnapshot.docs;

  // 2. Create a list of futures, one for each TMDB API call
  final List<Future<Map<String, dynamic>?>> futures = docs.map((doc) {
    final data = doc.data();
    final tmdbId = data['tmdb_id'] as int;
    final type = data['type'] as String;
    return repo.fetchMediaDetails(tmdbId, type);
  }).toList();

  // 3. Wait for all API calls to complete in parallel
  final results = await Future.wait(futures);

  // 4. Filter out any null results from failed calls and return the list
  return results
      .where((item) => item != null)
      .cast<Map<String, dynamic>>()
      .toList();
}
