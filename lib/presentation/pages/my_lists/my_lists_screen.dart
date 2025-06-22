import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/profile/profile_providers.dart';
import '../../core/app_colors.dart';
import '../profile/widgets/create_list_dialog.dart';
import 'widgets/list_management_card.dart';

class MyListsScreen extends ConsumerWidget {
  const MyListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customListsAsync = ref.watch(customListsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("My Lists"),
        backgroundColor: AppColors.darkSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => showCreateListDialog(context),
            tooltip: "Create New List",
          ),
        ],
      ),
      body: customListsAsync.when(
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "You haven't created any lists yet.",
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 16,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final listDoc = docs[index];
              final listData = listDoc.data() as Map<String, dynamic>;
              return ListManagementCard(listId: listDoc.id, listData: listData);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
