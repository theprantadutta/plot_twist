// lib/presentation/pages/detail/widgets/add_to_list_bottom_sheet.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../application/detail/detail_providers.dart';
import '../../../../application/profile/profile_providers.dart';
import '../../../../data/firestore/firestore_service.dart';
import '../../../core/app_colors.dart';
import '../../profile/widgets/create_list_dialog.dart';

void showAddToListBottomSheet(
  BuildContext context,
  Map<String, dynamic> media,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddToListBottomSheet(media: media),
  );
}

class AddToListBottomSheet extends ConsumerWidget {
  final Map<String, dynamic> media;
  const AddToListBottomSheet({super.key, required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that gives us all the user's custom lists
    final customListsAsync = ref.watch(customListsStreamProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const Text(
              "Add to...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32, color: Colors.white12),
            // The section for custom lists
            Expanded(
              child: customListsAsync.when(
                data: (docs) {
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final list = docs[index];
                      final listData = list.data() as Map<String, dynamic>;
                      return _CustomListItem(
                        listId: list.id,
                        listName: listData['name'],
                        media: media,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error: $e")),
              ),
            ),
            // The button to create a new list
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet first
                  showCreateListDialog(context); // Then show the create dialog
                },
                icon: const Icon(Icons.add),
                label: const Text("Create New List"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.auroraPink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A private, stateful widget for each list item, to manage its own checked state
class _CustomListItem extends ConsumerWidget {
  final String listId;
  final String listName;
  final Map<String, dynamic> media;

  const _CustomListItem({
    required this.listId,
    required this.listName,
    required this.media,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch our new provider to see if this movie is already in this specific list
    final isInListProvider = isMediaInCustomListProvider(
      listId: listId,
      mediaId: media['id'],
    );
    final isInList = ref.watch(isInListProvider).asData?.value ?? false;

    return ListTile(
      title: Text(listName),
      trailing: IconButton(
        icon: FaIcon(
          isInList
              ? FontAwesomeIcons.solidCircleCheck
              : FontAwesomeIcons.circlePlus,
          color: isInList
              ? AppColors.darkSuccessGreen
              : AppColors.darkTextSecondary,
        ),
        onPressed: () {
          final service = FirestoreService();
          if (isInList) {
            service.removeMediaFromCustomList(listId, media['id'].toString());
          } else {
            service.addMediaToCustomList(listId, media);
          }
        },
      ),
    );
  }
}
