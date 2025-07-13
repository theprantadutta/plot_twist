import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plot_twist/presentation/pages/settings/appearance_screen.dart';
import 'package:plot_twist/presentation/pages/settings/security_screen.dart';
import 'package:plot_twist/presentation/pages/settings/support_plottwists_screen.dart';

import '../../core/app_colors.dart';
import '../profile/edit_profile_screen.dart';
import 'app_and_support_screen.dart';
import 'legal_document_screen.dart';
import 'my_preferences_screen.dart';
import 'notifications_screen.dart';
import 'widgets/delete_account_dialog.dart';
import 'widgets/settings_menu_item.dart';
import 'widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Settings & Privacy"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // --- ACCOUNT SECTION ---
            SettingsSection(
              title: "Account",
              children: [
                SettingsMenuItem(
                  icon: FontAwesomeIcons.userPen,
                  iconColor: Colors.blue.shade300,
                  title: "Edit Profile",
                  subtitle: "Change your name, username, and avatar",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.shieldHalved,
                  iconColor: Colors.green.shade300,
                  title: "Security",
                  subtitle: "Change your password",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SecurityScreen()),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.darkBackground),
                // --- THIS IS THE NEW MENU ITEM ---
                SettingsMenuItem(
                  icon: FontAwesomeIcons.userSlash,
                  iconColor: AppColors.darkErrorRed,
                  title: "Delete Account",
                  subtitle: "Request permanent account deletion",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const DeleteAccountDialog(),
                    );
                  },
                ),
              ],
            ),

            // --- APP SETTINGS SECTION ---
            SettingsSection(
              title: "App Settings",
              children: [
                SettingsMenuItem(
                  icon: FontAwesomeIcons.solidBell,
                  iconColor: Colors.orange.shade300,
                  title: "Notifications & Reminders",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.solidMoon,
                  iconColor: Colors.purple.shade300,
                  title: "Appearance",
                  subtitle: "Dark Mode, Light Mode",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AppearanceScreen(),
                      ),
                    );
                  },
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.sliders,
                  iconColor: Colors.cyan.shade300,
                  title: "My Preferences",
                  subtitle: "Manage your content preferences",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MyPreferencesScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // --- SUPPORT & ABOUT SECTION ---
            SettingsSection(
              title: "Support & About",
              children: [
                SettingsMenuItem(
                  icon: FontAwesomeIcons.solidHeart,
                  iconColor: Colors.red.shade300,
                  title: "Support PlotTwists",
                  subtitle: "Help keep the servers running",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SupportPlotTwistsScreen(),
                      ),
                    );
                  },
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.circleInfo,
                  iconColor: Colors.blueGrey.shade300,
                  title: "App & Support",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AppAndSupportScreen(),
                      ),
                    );
                  },
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.fileContract,
                  iconColor: Colors.grey.shade400,
                  title: "Terms & Conditions",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LegalDocumentScreen(
                          title: "Terms & Conditions",
                          markdownAssetPath: "assets/legal/terms.md",
                        ),
                      ),
                    );
                  },
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.userSecret,
                  iconColor: Colors.grey.shade400,
                  title: "Privacy Policy",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LegalDocumentScreen(
                          title: "Privacy Policy",
                          markdownAssetPath: "assets/legal/privacy.md",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}
