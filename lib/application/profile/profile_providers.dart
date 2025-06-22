// lib/application/profile/profile_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

// Using a Record to return multiple values from the provider
typedef CustomListDetails = ({int itemCount, List<String> posterPaths});

// --- THIS IS THE NEW PROVIDER ---
// Given a listId, it fetches the item count and first 4 posters.
@riverpod
Future<CustomListDetails> customListDetails(
  CustomListDetailsRef ref,
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

@riverpod
Stream<int> watchedMoviesCount(WatchedMoviesCountRef ref) {
  return _listCountStream('watched', 'movie');
}

@riverpod
Stream<int> watchedTvShowsCount(WatchedTvShowsCountRef ref) {
  return _listCountStream('watched', 'tv');
}

@riverpod
Stream<int> watchlistMoviesCount(WatchlistMoviesCountRef ref) {
  return _listCountStream('watchlist', 'movie');
}

@riverpod
Stream<int> watchlistTvShowsCount(WatchlistTvShowsCountRef ref) {
  return _listCountStream('watchlist', 'tv');
}

// Provider for the user's custom lists
@riverpod
Stream<List<QueryDocumentSnapshot>> customListsStream(
  CustomListsStreamRef ref,
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
@riverpod
Stream<DocumentSnapshot<Map<String, dynamic>>> userDocumentStream(
  UserDocumentStreamRef ref,
) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.empty();
  return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
}
