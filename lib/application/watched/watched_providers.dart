import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../discover/discover_providers.dart';

part 'watched_providers.g.dart';

// This new provider fetches the full details for every item in the 'watched' collection.
// It works exactly like our watchlistDetailsProvider, but points to a different collection.
@Riverpod(keepAlive: true)
Future<List<Map<String, dynamic>>> watchedDetails(Ref ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final repo = ref.watch(tmdbRepositoryProvider);

  // 1. Get the list of document snapshots from the 'watched' collection in Firestore
  final watchedSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('watched')
      .orderBy('added_at', descending: true)
      .get();

  final docs = watchedSnapshot.docs;

  // 2. Create a list of futures, one for each TMDB API call
  final futures = docs.map((doc) {
    final data = doc.data();
    final tmdbId = data['tmdb_id'] as int;
    final type = data['type'] as String;
    return repo.fetchMediaDetails(tmdbId, type);
  }).toList();

  // 3. Wait for all calls to complete and return the results
  final results = await Future.wait(futures);
  return results
      .where((item) => item != null)
      .cast<Map<String, dynamic>>()
      .toList();
}
