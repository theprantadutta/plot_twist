import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

// This StreamProvider creates and exposes the Firebase auth state stream.
// Riverpod will handle subscribing, caching, and cleaning it up for us.
@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}
