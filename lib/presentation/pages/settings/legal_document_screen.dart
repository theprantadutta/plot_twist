import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String markdownAssetPath;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.markdownAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.darkSurface,
      ),
      // We use a FutureBuilder to load the text file from assets
      body: FutureBuilder<String>(
        future: rootBundle.loadString(markdownAssetPath),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            // Once the file is loaded, we use the Markdown widget to display it
            return Markdown(
              data: snapshot.data!,
              // Style the markdown to match our app's theme
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                    p: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    h1: const TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    h2: const TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    a: const TextStyle(color: AppColors.auroraPink),
                  ),
              // Make links tappable
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(Uri.parse(href));
                }
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
