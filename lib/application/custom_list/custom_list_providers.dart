import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../discover/discover_providers.dart';

part 'custom_list_providers.g.dart';

// Provider to get the details of the list itself (name, description, etc.)
@Riverpod(keepAlive: true)
Stream<DocumentSnapshot> customListStream(
  CustomListStreamRef ref,
  String listId,
) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('custom_lists')
      .doc(listId)
      .snapshots();
}

// The main provider for this screen.
// It fetches the simple list of item IDs from Firestore, then gets the
// full, rich details for each item from the TMDB API.
@riverpod
Future<List<Map<String, dynamic>>> customListItemsDetails(
  CustomListItemsDetailsRef ref,
  String listId,
) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final repo = ref.watch(tmdbRepositoryProvider);

  // 1. Get the list of item documents from Firestore
  final itemsSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('custom_lists')
      .doc(listId)
      .collection('items')
      .orderBy('added_at', descending: true)
      .get();

  final docs = itemsSnapshot.docs;

  // 2. Create a list of futures for each TMDB API call
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
