import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock provider for custom lists
final customListsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // This would typically fetch from a repository
  return [];
});
