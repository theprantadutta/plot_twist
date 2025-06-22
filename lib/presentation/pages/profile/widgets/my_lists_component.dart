import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/profile/profile_providers.dart';
import '../../../core/app_colors.dart';
import '../../my_lists/my_lists_screen.dart';

class MyListsComponent extends ConsumerWidget {
  const MyListsComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customListsAsync = ref.watch(customListsStreamProvider);

    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MyListsScreen()));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Lists",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "View and manage all your lists",
                  style: TextStyle(color: AppColors.darkTextSecondary),
                ),
              ],
            ),
            customListsAsync.when(
              data: (docs) => Text(
                docs.length.toString(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.auroraPink,
                ),
              ),
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, s) => const Icon(
                Icons.error_outline,
                color: AppColors.darkErrorRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
