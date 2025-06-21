import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

// Provider to get the current user's document from Firestore
@riverpod
Stream<DocumentSnapshot<Map<String, dynamic>>> userDocumentStream(
  UserDocumentStreamRef ref,
) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.empty();
  return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
}

// Provider to get the count of items in the 'watched' list
@riverpod
Stream<int> watchedCountStream(WatchedCountStreamRef ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(0);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('watched')
      .snapshots()
      .map((snapshot) => snapshot.size);
}

// Provider to get the count of items in the 'watchlist'
@riverpod
Stream<int> watchlistCountStream(WatchlistCountStreamRef ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(0);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('watchlist')
      .snapshots()
      .map((snapshot) => snapshot.size);
}
