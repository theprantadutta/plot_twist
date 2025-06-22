import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/profile/profile_providers.dart';
import '../../../../data/firestore/firestore_service.dart';
import '../../../core/app_colors.dart';
import '../../custom_list/custom_list_detail_screen.dart';

class CustomListCard extends ConsumerWidget {
  final String listId;
  final String listName;

  const CustomListCard({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(customListDetailsProvider(listId));

    return GestureDetector(
      // --- THIS IS THE CHANGE ---
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CustomListDetailScreen(listId: listId),
          ),
        );
      },
      // --------------------------
      onLongPress: () {
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
      child: detailsAsync.when(
        data: (details) =>
            _buildCardContent(context, details.itemCount, details.posterPaths),
        loading: () => _buildLoadingCard(),
        error: (e, s) => _buildErrorCard(),
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    int itemCount,
    List<String> posterPaths,
  ) {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (posterPaths.isNotEmpty) _buildPosterCollage(posterPaths),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    listName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$itemCount items",
                    style: const TextStyle(color: AppColors.darkTextSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            height: 180,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() => Container(
    height: 180,
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _buildErrorCard() => Container(
    height: 180,
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppColors.darkErrorRed.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Center(child: Text("Could not load details")),
  );
}
