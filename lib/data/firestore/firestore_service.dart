import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Helper method to get the current user ID
  String? get _userId => _auth.currentUser?.uid;

  Future<void> addToList(String listName, Map<String, dynamic> media) async {
    final userId = _userId;
    if (userId == null) return;

    final mediaId = media['id'].toString();
    final mediaType = media['title'] != null ? 'movie' : 'tv';

    // --- THIS IS THE CHANGE ---
    // The "smart" logic that automatically removed items from the other list
    // has now been removed, as you requested.
    /*
    if (listName == 'watched') {
      await removeFromList('watchlist', mediaId);
    }
    if (listName == 'watchlist') {
      await removeFromList('watched', mediaId);
    }
    */
    // -------------------------

    // Now, this function ONLY adds the item to the specified list.
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(listName)
        .doc(mediaId)
        .set({
          'tmdb_id': media['id'],
          'type': mediaType,
          'title': media['title'] ?? media['name'],
          'poster_path': media['poster_path'],
          'added_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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

  Future<void> rateMedia(Map<String, dynamic> media, double rating) async {
    final userId = _userId;
    if (userId == null) return;

    // Rating a movie automatically marks it as watched.
    await addToList('watched', media);

    final mediaId = media['id'].toString();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('watched')
        .doc(mediaId)
        .update({'rating': rating});
  }

  Future<void> createCustomList(String listName, String description) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('custom_lists')
        .add({
          'name': listName,
          'description': description,
          'created_at': FieldValue.serverTimestamp(),
        });
  }

  Future<void> addMediaToCustomList(
    String listId,
    Map<String, dynamic> media,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    final mediaId = media['id'].toString();
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('custom_lists')
        .doc(listId)
        .collection('items')
        .doc(mediaId)
        .set({
          'tmdb_id': media['id'],
          'type': media['title'] != null ? 'movie' : 'tv',
          'poster_path': media['poster_path'],
          'added_at': FieldValue.serverTimestamp(),
        });
  }

  Future<void> removeMediaFromCustomList(String listId, String mediaId) async {
    final userId = _userId;
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('custom_lists')
        .doc(listId)
        .collection('items')
        .doc(mediaId)
        .delete();
  }

  // Deletes an entire custom list and all the items within it.
  Future<void> deleteCustomList(String listId) async {
    final userId = _userId;
    if (userId == null) return;
    final listRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('custom_lists')
        .doc(listId);

    // IMPORTANT: You must delete all items in the subcollection first.
    final itemsSnapshot = await listRef.collection('items').get();
    for (var doc in itemsSnapshot.docs) {
      await doc.reference.delete();
    }

    // After the subcollection is empty, delete the main list document.
    await listRef.delete();
  }

  Future<void> updateCustomList(
    String listId,
    String newName,
    String newDescription,
  ) async {
    final userId = _userId;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('custom_lists')
        .doc(listId)
        .update({'name': newName, 'description': newDescription});
  }

  Future<String?> uploadAvatar(File imageFile) async {
    final userId = _userId;
    if (userId == null) return null;

    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      final ref = _storage.ref().child('avatars/$userId.jpg');

      // Upload the file
      final uploadTask = await ref.putFile(imageFile);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Failed to upload avatar: $e");
      return null;
    }
  }

  // We now accept an optional avatarUrl
  Future<void> updateUserProfile({
    required String fullName,
    required String username,
    String? avatarUrl,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    final Map<String, dynamic> dataToUpdate = {
      'fullName': fullName,
      'username': username,
    };

    // Only add the avatarUrl to the update map if it's not null
    if (avatarUrl != null) {
      dataToUpdate['avatarUrl'] = avatarUrl;
    }

    await _firestore.collection('users').doc(userId).update(dataToUpdate);
  }

  Future<void> saveFcmToken(String? token) async {
    final userId = _userId;
    if (userId == null || token == null) return;

    // We use SetOptions(merge: true) to avoid overwriting other user data
    await _firestore.collection('users').doc(userId).set({
      'fcm_token': token,
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
