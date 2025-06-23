import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../application/settings/app_info_provider.dart';
import '../../core/app_colors.dart';
import 'widgets/settings_menu_item.dart';
import 'widgets/settings_section.dart';

class AppAndSupportScreen extends ConsumerWidget {
  const AppAndSupportScreen({super.key});

  // Helper function to launch email
  void _launchEmail(String subject) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'prantadutta1997@gmail.com',
      queryParameters: {'subject': subject},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      // Handle error, e.g., show a snackbar
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfoAsync = ref.watch(packageInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("App & Support"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingsSection(
              title: "Help & Feedback",
              children: [
                SettingsMenuItem(
                  icon: FontAwesomeIcons.bug,
                  iconColor: Colors.orange.shade300,
                  title: "Report a Bug",
                  onTap: () => _launchEmail("Bug Report - PlotTwists App"),
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.headset,
                  iconColor: Colors.blue.shade300,
                  title: "Contact Support",
                  onTap: () => _launchEmail("Support Request - PlotTwists App"),
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.solidStar,
                  iconColor: AppColors.darkStarlightGold,
                  title: "Rate PlotTwists",
                  subtitle: "Enjoying the app? Leave a review!",
                  onTap: () {
                    // This will open the app store listing. Replace with your actual app store links.
                    // final url = Uri.parse("your_app_store_link_here");
                    // launchUrl(url);
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Display the app version at the bottom
            packageInfoAsync.when(
              data: (info) => Text(
                'Version ${info.version} (Build ${info.buildNumber})',
                style: const TextStyle(color: AppColors.darkTextSecondary),
              ),
              loading: () => const SizedBox(),
              error: (e, s) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
