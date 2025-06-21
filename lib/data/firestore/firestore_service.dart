import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get the current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Generic method to add a media item to a specific list (e.g., 'watchlist', 'watched')
  Future<void> addToList(String listName, Map<String, dynamic> media) async {
    final userId = _userId;
    if (userId == null) return; // Exit if no user is logged in

    final mediaId = media['id'].toString();
    final mediaType = media['title'] != null ? 'movie' : 'tv';

    // Use a subcollection for the specified list
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(listName) // 'watchlist' or 'watched'
        .doc(mediaId)
        .set({
          'tmdb_id': media['id'],
          'type': mediaType,
          'title': media['title'] ?? media['name'],
          'poster_path': media['poster_path'],
          'added_at': FieldValue.serverTimestamp(),
        });
  }

  Future<void> removeFromList(String listName, String mediaId) async {
    final userId = _userId;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection(listName)
        .doc(mediaId)
        .delete();
  }
}
