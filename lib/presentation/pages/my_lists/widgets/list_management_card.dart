import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/profile/profile_providers.dart';
import '../../../../data/firestore/firestore_service.dart';
import '../../../core/app_colors.dart';
import '../../custom_list/custom_list_detail_screen.dart';
import 'edit_list_dialog.dart';

class ListManagementCard extends ConsumerWidget {
  final String listId;
  final Map<String, dynamic> listData;

  const ListManagementCard({
    super.key,
    required this.listId,
    required this.listData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listName = listData['name'] ?? 'Untitled';
    final detailsAsync = ref.watch(customListDetailsProvider(listId));

    return Card(
      color: AppColors.darkSurface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CustomListDetailScreen(listId: listId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      listName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Edit Button
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.darkTextSecondary,
                    ),
                    onPressed: () =>
                        showEditListDialog(context, listId, listData),
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.darkErrorRed,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete List"),
                          content: Text(
                            "Are you sure you want to delete the '$listName' list? This cannot be undone.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                FirestoreService().deleteCustomList(listId);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: AppColors.darkErrorRed),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              detailsAsync.when(
                data: (details) => Text(
                  "${details.itemCount} items",
                  style: const TextStyle(color: AppColors.darkTextSecondary),
                ),
                loading: () => const Text(
                  "Loading...",
                  style: TextStyle(color: AppColors.darkTextSecondary),
                ),
                error: (e, s) => const Text(
                  "Error",
                  style: TextStyle(color: AppColors.darkErrorRed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
