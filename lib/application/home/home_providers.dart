// lib/application/home/home_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/persistence_service.dart';

// This is required for the generator to work
part 'home_providers.g.dart';

// A simple provider to make our PersistenceService available
@Riverpod(keepAlive: true)
PersistenceService persistenceService(Ref ref) {
  throw UnimplementedError(
    'persistenceServiceProvider must be overridden in ProviderScope',
  );
}

@Riverpod(keepAlive: true)
class MediaTypeNotifier extends _$MediaTypeNotifier {
  late PersistenceService _persistenceService;

  @override
  MediaType build() {
    // This will now get the initialized instance we provide in main.dart
    _persistenceService = ref.watch(persistenceServiceProvider);
    return _persistenceService.getMediaType();
  }

  Future<void> setMediaType(MediaType newType) async {
    if (state != newType) {
      state = newType;
      await _persistenceService.setMediaType(newType);
    }
  }
}
