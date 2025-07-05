import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:plot_twist/application/settings/app_info_provider.dart';
import 'package:plot_twist/presentation/core/app_colors.dart';

import 'widgets/feedback_dialog.dart';
import 'widgets/settings_menu_item.dart';
import 'widgets/settings_section.dart';

class AppAndSupportScreen extends ConsumerWidget {
  const AppAndSupportScreen({super.key});

  // Helper function to request the native in-app review dialog
  void _requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      // Fallback to opening the store page if native review is not available
      // final url = Uri.parse("your_app_store_link_here");
      // launchUrl(url);
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const FeedbackDialog(
                        title: "Report a Bug",
                        emailSubject: "Bug Report - PlotTwists App",
                      ),
                    );
                  },
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.headset,
                  iconColor: Colors.blue.shade300,
                  title: "Contact Support",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const FeedbackDialog(
                        title: "Contact Support",
                        emailSubject: "Support Request - PlotTwists App",
                      ),
                    );
                  },
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.solidStar,
                  iconColor: AppColors.darkStarlightGold,
                  title: "Rate PlotTwists",
                  subtitle: "Enjoying the app? Leave a review!",
                  onTap: _requestReview,
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
