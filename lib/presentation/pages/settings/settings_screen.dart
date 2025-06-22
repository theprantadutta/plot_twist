// lib/presentation/pages/settings/settings_screen.dart
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: const Center(child: Text("App Settings Coming Soon!")),
    );
  }
}
