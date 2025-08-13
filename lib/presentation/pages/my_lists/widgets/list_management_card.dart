// lib/presentation/pages/my_lists/widgets/list_management_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    final listDesc = listData['description'] ?? '';
    final detailsAsync = ref.watch(customListDetailsProvider(listId));

    return Card(
      color: Colors.transparent, // The container will handle the color
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CustomListDetailScreen(listId: listId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: detailsAsync.when(
            data: (details) => _buildCardContent(
              context,
              listName,
              listDesc,
              details.itemCount,
              details.posterPaths,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
              child: Text(
                "Error",
                style: TextStyle(color: AppColors.darkErrorRed),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    String name,
    String desc,
    int count,
    List<String> posters,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dynamic poster collage background
          if (posters.isNotEmpty) _buildPosterCollage(posters),
          // Gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content and Action Menu
          Positioned(top: 8, right: 8, child: _buildActionMenu(context, name)),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.darkTextSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  "$count items",
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterCollage(List<String> posterPaths) {
    return Row(
      children: List.generate(
        posterPaths.length > 4 ? 4 : posterPaths.length,
        (index) => Expanded(
          child: Image.network(
            'https://image.tmdb.org/t/p/w500${posterPaths[index]}',
            fit: BoxFit.cover,
            height: 200,
          ),
        ),
      ),
    );
  }

  // The new, cleaner action menu
  Widget _buildActionMenu(BuildContext context, String listName) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          showEditListDialog(context, listId, listData);
        } else if (value == 'delete') {
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
        }
      },
      icon: const FaIcon(
        FontAwesomeIcons.ellipsisVertical,
        color: Colors.white,
      ),
      color: AppColors.darkSurface,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit List'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.darkErrorRed),
            title: Text(
              'Delete List',
              style: TextStyle(color: AppColors.darkErrorRed),
            ),
          ),
        ),
      ],
    );
  }
}
