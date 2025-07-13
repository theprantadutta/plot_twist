// lib/presentation/pages/settings/widgets/delete_account_dialog.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_colors.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  // The link you provided
  final String deletionFormUrl = "https://forms.gle/zhvrbVdZ7YGxESF36";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.darkErrorRed,
        size: 32,
      ),
      title: const Text("Delete Your Account?"),
      content: const Text(
        "To proceed with deleting your account and all associated data, you must fill out our account deletion request form. This action is permanent and cannot be undone.",
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.darkTextSecondary),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        // Close Button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
        ),
        // Open Form Button
        ElevatedButton(
          onPressed: () async {
            final Uri url = Uri.parse(deletionFormUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Could not open form. Please try again later."),
                ),
              );
            }
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkErrorRed,
            foregroundColor: Colors.white,
          ),
          child: const Text("Open Deletion Form"),
        ),
      ],
    );
  }
}
