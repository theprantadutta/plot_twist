import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/profile/profile_providers.dart';
import '../../../core/app_colors.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user document stream provider
    final userDocAsync = ref.watch(userDocumentStreamProvider);

    return userDocAsync.when(
      data: (doc) {
        final data = doc.data();
        final fullName = data?['fullName'] ?? 'PlotTwists User';
        final username = data?['username'] ?? 'username';

        return Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.auroraGradient),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.auroraPurple,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@$username',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) =>
          const Center(child: Text("Could not load user data")),
    );
  }
}
