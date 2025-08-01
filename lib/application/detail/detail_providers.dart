// lib/application/detail/detail_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/persistence_service.dart';
import '../discover/discover_providers.dart';

part 'detail_providers.g.dart';

// A record to pass both id and type, making it type-safe
typedef MediaIdentifier = ({int id, MediaType type});

// A new record to pass both tvId and season number
typedef SeasonIdentifier = ({int tvId, int seasonNumber});

// This provider fetches the full details for a specific movie or show
@Riverpod(keepAlive: true)
Future<Map<String, dynamic>> mediaDetails(Ref ref, MediaIdentifier media) {
  final repo = ref.watch(tmdbRepositoryProvider);
  return repo.getMediaDetails(id: media.id, type: media.type);
}

// --- THIS IS THE MISSING PROVIDER ---
// This provider checks if an item is in the user's watchlist in real-time
@Riverpod(keepAlive: true)
Stream<bool> isMediaInWatchlist(Ref ref, int mediaId) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    // If there's no user, they can't have anything in their watchlist.
    return Stream.value(false);
  }

  // Point to the specific document in the watchlist subcollection
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('watchlist')
      .doc(mediaId.toString());

  // Listen to changes for that document. .map((snapshot) => snapshot.exists)
  // will return true if the document exists, and false if it doesn't.
  return docRef.snapshots().map((snapshot) => snapshot.exists);
}

// It returns a double? (nullable) - null means not rated.
@Riverpod(keepAlive: true)
Stream<double?> mediaUserRating(MediaUserRatingRef ref, int mediaId) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(null);

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('watched')
      .doc(mediaId.toString());

  return docRef.snapshots().map((snapshot) {
    if (snapshot.exists && snapshot.data()!.containsKey('rating')) {
      return (snapshot.data()!['rating'] as num).toDouble();
    }
    return null;
  });
}

// This provider just checks if the movie exists in the 'watched' collection.
@Riverpod(keepAlive: true)
Stream<bool> isMediaWatched(IsMediaWatchedRef ref, int mediaId) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(false);

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('watched')
      .doc(mediaId.toString());
  return docRef.snapshots().map((snapshot) => snapshot.exists);
}

// It checks if a specific media item exists within a specific custom list.
@Riverpod(keepAlive: true)
Stream<bool> isMediaInCustomList(
  IsMediaInCustomListRef ref, {
  required String listId,
  required int mediaId,
}) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(false);

  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('custom_lists')
      .doc(listId)
      .collection('items')
      .doc(mediaId.toString());

  return docRef.snapshots().map((snapshot) => snapshot.exists);
}

@Riverpod(keepAlive: true)
Future<Map<String, dynamic>> seasonDetails(
  SeasonDetailsRef ref,
  SeasonIdentifier season,
) {
  final repo = ref.watch(tmdbRepositoryProvider);
  return repo.getSeasonDetails(
    tvId: season.tvId,
    seasonNumber: season.seasonNumber,
  );
}

@Riverpod(keepAlive: true)
Stream<bool> isMediaInFavorites(IsMediaInFavoritesRef ref, int mediaId) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(false);

  // It works exactly like the others, but points to a 'favorites' collection
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('favorites')
      .doc(mediaId.toString());

  return docRef.snapshots().map((snapshot) => snapshot.exists);
}
