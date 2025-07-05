// lib/presentation/pages/settings/widgets/feedback_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plot_twist/application/settings/app_info_provider.dart';
import 'package:plot_twist/presentation/core/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackDialog extends ConsumerStatefulWidget {
  final String title;
  final String emailSubject;

  const FeedbackDialog({
    super.key,
    required this.title,
    required this.emailSubject,
  });

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendEmail(PackageInfo packageInfo) async {
    if (!_formKey.currentState!.validate()) return;

    final String messageBody = Uri.encodeComponent(
      "Message:\n${_controller.text}\n\n"
      "--------------------\n"
      "App Version: ${packageInfo.version}\n"
      "Build Number: ${packageInfo.buildNumber}\n"
      "Platform: ${Theme.of(context).platform}\n",
    );

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'prantadutta1997@gmail.com',
      query:
          'subject=${Uri.encodeComponent(widget.emailSubject)}&body=$messageBody',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open email app.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final packageInfo = ref.watch(packageInfoProvider);

    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Please describe the issue or your feedback in detail...",
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value!.isEmpty ? "Please enter a message." : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
        ),
        packageInfo.when(
          data: (info) => ElevatedButton(
            onPressed: () => _sendEmail(info),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.auroraPink,
            ),
            child: const Text(
              "Send Email",
              style: TextStyle(color: Colors.white),
            ),
          ),
          loading: () =>
              const ElevatedButton(onPressed: null, child: Text("Send Email")),
          error: (_, _) => const SizedBox(),
        ),
      ],
    );
  }
}
