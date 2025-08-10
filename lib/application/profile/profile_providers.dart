// lib/application/profile/profile_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../watched/watched_providers.dart';

part 'profile_providers.g.dart';

// Using a Record to return multiple values from the provider
typedef CustomListDetails = ({int itemCount, List<String> posterPaths});

// --- THIS IS THE NEW PROVIDER ---
// Given a listId, it fetches the item count and first 4 posters.
@Riverpod(keepAlive: true)
Future<CustomListDetails> customListDetails(
  Ref ref,
  String listId,
) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    throw Exception("User not logged in");
  }

  final collectionRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('custom_lists')
      .doc(listId)
      .collection('items');

  // Fetch the total count
  final countSnapshot = await collectionRef.count().get();
  final itemCount = countSnapshot.count ?? 0;

  // Fetch the first 4 posters for the collage
  final postersSnapshot = await collectionRef.limit(4).get();
  final posterPaths = postersSnapshot.docs
      .map((doc) => doc.data()['poster_path'] as String?)
      .where((path) => path != null)
      .cast<String>()
      .toList();

  return (itemCount: itemCount, posterPaths: posterPaths);
}

// Helper function to create a stream for a specific list and type
Stream<int> _listCountStream(String listName, String? mediaType) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(0);

  Query query = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection(listName);

  if (mediaType != null) {
    query = query.where('type', isEqualTo: mediaType);
  }

  return query.snapshots().map((snapshot) => snapshot.size);
}

// --- NEW, MORE DETAILED STAT PROVIDERS ---

@Riverpod(keepAlive: true)
Stream<int> watchedMoviesCount(Ref ref) {
  return _listCountStream('watched', 'movie');
}

@Riverpod(keepAlive: true)
Stream<int> watchedTvShowsCount(Ref ref) {
  return _listCountStream('watched', 'tv');
}

@Riverpod(keepAlive: true)
Stream<int> watchlistMoviesCount(Ref ref) {
  return _listCountStream('watchlist', 'movie');
}

@Riverpod(keepAlive: true)
Stream<int> watchlistTvShowsCount(Ref ref) {
  return _listCountStream('watchlist', 'tv');
}

// Provider for the user's custom lists
@Riverpod(keepAlive: true)
Stream<List<QueryDocumentSnapshot>> customListsStream(
  Ref ref,
) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('custom_lists') // Assuming this is your collection name
      .snapshots()
      .map((snapshot) => snapshot.docs);
}

// --- Keep the existing provider for user details ---
@Riverpod(keepAlive: true)
Stream<DocumentSnapshot<Map<String, dynamic>>> userDocumentStream(
  Ref ref,
) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.empty();
  return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
}

// This provider calculates the total watch time for all watched MOVIES
@Riverpod(keepAlive: true)
int movieWatchTime(Ref ref) {
  // 1. Watch the provider that already fetches all our watched items
  final watchedDetails = ref.watch(watchedDetailsProvider);
  int totalMinutes = 0;

  // 2. When the data is available, calculate the sum
  watchedDetails.whenData((items) {
    for (final item in items) {
      // Check if it's a movie and has a runtime
      if (item.containsKey('title') && item['runtime'] != null) {
        totalMinutes += (item['runtime'] as num).toInt();
      }
    }
  });
  // Convert total minutes to hours and round to the nearest whole number
  return (totalMinutes / 60).round();
}

// This provider calculates the total watch time for all watched TV SHOWS
@Riverpod(keepAlive: true)
int tvShowWatchTime(Ref ref) {
  final watchedDetails = ref.watch(watchedDetailsProvider);
  int totalMinutes = 0;

  watchedDetails.whenData((items) {
    for (final item in items) {
      // Check if it's a TV show
      if (item.containsKey('name')) {
        final episodeRuntime =
            (item['episode_run_time'] as List?)?.firstOrNull as int? ??
            45; // Default to 45m if not available
        final episodeCount = (item['number_of_episodes'] as num?)?.toInt() ?? 0;
        totalMinutes += episodeRuntime * episodeCount;
      }
    }
  });
  // Convert total minutes to hours and round to the nearest whole number
  return (totalMinutes / 60).round();
}

// This provider calculates the TOTAL number of watched items by combining movies and shows.
@Riverpod(keepAlive: true)
int totalWatchedCount(Ref ref) {
  final movies = ref.watch(watchedMoviesCountProvider).asData?.value ?? 0;
  final shows = ref.watch(watchedTvShowsCountProvider).asData?.value ?? 0;
  return movies + shows;
}

// This provider calculates the TOTAL watch time in hours.
@Riverpod(keepAlive: true)
int totalWatchTime(Ref ref) {
  final movieMinutes = ref.watch(
    movieWatchTimeProvider,
  ); // Already returns hours
  final tvMinutes = ref.watch(tvShowWatchTimeProvider); // Already returns hours
  return movieMinutes + tvMinutes;
}
