// lib/application/watchlist/multi_select_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'multi_select_provider.g.dart';

@riverpod
class MultiSelectNotifier extends _$MultiSelectNotifier {
  // The state will be a list of the media IDs that are selected.
  @override
  List<String> build() => [];

  void toggle(String mediaId) {
    if (state.contains(mediaId)) {
      state = state.where((id) => id != mediaId).toList();
    } else {
      state = [...state, mediaId];
    }
  }

  void clear() {
    state = [];
  }
}
