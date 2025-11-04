import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../application/profile/profile_providers.dart';
import '../../../core/app_colors.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDocAsync = ref.watch(userDocumentStreamProvider);

    return userDocAsync.when(
      data: (doc) {
        final data = doc.data();
        final fullName = data?['fullName'] ?? 'PlotTwists User';
        final username = data?['username'] ?? 'username';
        final avatarUrl = data?['avatarUrl']; // Get the avatar URL

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.auroraGradient),
          child: Column(
            children: [
              // Updated Avatar Logic
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? const FaIcon(
                        FontAwesomeIcons.userAstronaut,
                        size: 50,
                        color: AppColors.auroraPurple,
                      )
                    : null,
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
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 234,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) =>
          const Center(child: Text("Could not load user data")),
    );
  }
}
