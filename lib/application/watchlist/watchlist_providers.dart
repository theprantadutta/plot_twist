import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'watchlist_providers.g.dart';

// An enum to represent our filter states
enum WatchlistFilter { all, movies, tvShows }

// 1. A provider to manage the currently selected filter tab
@riverpod
class WatchlistFilterNotifier extends _$WatchlistFilterNotifier {
  @override
  WatchlistFilter build() => WatchlistFilter.all;

  void setFilter(WatchlistFilter filter) {
    state = filter;
  }
}

// 2. A provider to fetch the raw watchlist data from Firestore
@riverpod
Stream<List<QueryDocumentSnapshot>> watchlistStream(WatchlistStreamRef ref) {
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
@riverpod
List<QueryDocumentSnapshot> filteredWatchlist(FilteredWatchlistRef ref) {
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
