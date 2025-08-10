import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock provider for custom lists
final customListsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // This would typically fetch from a repository
  return [];
});

/// Provider for streaming a specific custom list
final customListStreamProvider =
    StreamProvider.family<MockDocumentSnapshot, String>((ref, listId) {
      // This would typically stream from Firestore
      return Stream.value(
        MockDocumentSnapshot(data: {'name': 'Mock List', 'items': []}),
      );
    });

/// Provider for custom list items with details
final customListItemsDetailsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      listId,
    ) async {
      // This would typically fetch detailed item information
      return [];
    });

/// Mock DocumentSnapshot for testing
class MockDocumentSnapshot {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot({required Map<String, dynamic> data}) : _data = data;

  Map<String, dynamic>? data() => _data;
}
