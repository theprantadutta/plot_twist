import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final listDoc = docs[index];
              final listData = listDoc.data() as Map<String, dynamic>;
              // Use our new, beautiful card
              return ListManagementCard(listId: listDoc.id, listData: listData)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: (100 * index).ms)
                  .slideY(begin: 0.2);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  // A more beautiful empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.listOl,
            size: 60,
            color: Colors.white24,
          ),
          const SizedBox(height: 24),
          const Text(
            "Curate Your Universe",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Create your first list to organize movies and shows for any mood or occasion.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => showCreateListDialog(context),
            icon: const Icon(Icons.add),
            label: const Text("Create a List"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.auroraPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
