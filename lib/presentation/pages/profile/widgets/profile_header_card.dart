import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../application/profile/profile_providers.dart';
import '../../../core/app_colors.dart';
import '../../settings/settings_screen.dart';

class ProfileHeaderCard extends ConsumerWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDocumentStreamProvider);
    final totalWatched = ref.watch(totalWatchedCountProvider);
    final totalHours = ref.watch(totalWatchTimeProvider);

    return userAsync.when(
      data: (doc) {
        final data = doc.data();
        final fullName = data?['fullName'] ?? 'PlotTwists User';
        final username = data?['username'] ?? 'username';
        final avatarUrl = data?['avatarUrl'];

        return Card(
          margin: const EdgeInsets.all(16),
          color: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Top row with Avatar, Name, and Settings button
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.darkBackground,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? const FaIcon(
                              FontAwesomeIcons.userAstronaut,
                              size: 30,
                              color: AppColors.darkTextSecondary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@$username',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.darkTextSecondary,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(height: 40, color: Colors.white12),
                // Bottom row with key stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      value: totalWatched.toString(),
                      label: "Titles Watched",
                    ),
                    _buildStatColumn(
                      value: totalHours.toString(),
                      label: "Total Hours",
                    ),
                    // You can add a "Lists" count here later
                    _buildStatColumn(value: "0", label: "Lists"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 190,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatColumn({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.auroraPink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.darkTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
