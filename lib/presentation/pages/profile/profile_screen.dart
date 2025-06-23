// lib/presentation/pages/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../application/profile/profile_providers.dart';
import '../../core/app_colors.dart';
import '../settings/settings_screen.dart';
import 'widgets/create_list_dialog.dart';
import 'widgets/my_lists_component.dart';
import 'widgets/stat_grid.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDocumentStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      // We use a CustomScrollView for a more advanced layout that can have a pinned AppBar.
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.darkBackground,
            pinned: true,
            title: userAsync.when(
              data: (doc) => Text(doc.data()?['username'] ?? 'Profile'),
              loading: () => const Text("Profile"),
              error: (_, __) => const Text("Profile"),
            ),
            actions: [
              // Settings Button
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),

          // Using SliverList to hold our main column of content
          SliverList(
            delegate: SliverChildListDelegate([
              // User Info Header
              userAsync.when(
                data: (doc) {
                  final data = doc.data();
                  // Get the avatar URL from the document data
                  final avatarUrl = data?['avatarUrl'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // --- THIS IS THE UPDATED WIDGET ---
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.darkSurface,
                          // Use the NetworkImage if the URL exists
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          // The child (icon) is only shown if there is no background image
                          child: avatarUrl == null
                              ? const FaIcon(
                                  FontAwesomeIcons.userAstronaut,
                                  size: 40,
                                  color: AppColors.darkTextSecondary,
                                )
                              : null,
                        ),
                        // ------------------------------------
                        const SizedBox(height: 16),
                        Text(
                          data?['fullName'] ?? 'PlotTwists User',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data?['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Grid of User Statistics
              const StatGrid(),

              const SizedBox(height: 24),

              // "My Lists" Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Lists",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () => showCreateListDialog(context),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      tooltip: "Create a new list",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              const MyListsComponent(),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.darkErrorRed,
                  ),
                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      color: AppColors.darkErrorRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40), // Bottom padding
            ]),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}
