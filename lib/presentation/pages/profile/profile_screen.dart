import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_colors.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/stat_card.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileHeader(),
            const StatCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ProfileMenuItem(
                    title: "Account",
                    icon: Icons.person_outline_rounded,
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    title: "Notifications",
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    title: "Appearance",
                    icon: Icons.palette_outlined,
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white12, height: 32),
                  ProfileMenuItem(
                    title: "Logout",
                    icon: Icons.logout_rounded,
                    onTap: onLogout, // Use the callback passed from AuthGuard
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}
