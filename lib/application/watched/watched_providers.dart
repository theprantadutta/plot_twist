import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock provider for watched movies
final watchedProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // This would typically fetch from a repository
  return [];
});

/// Provider for watched details (with full movie information)
final watchedDetailsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // This would typically fetch detailed movie information
  return [];
});
