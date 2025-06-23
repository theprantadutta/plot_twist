import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/app_colors.dart';

class SupportPlotTwistsScreen extends StatelessWidget {
  const SupportPlotTwistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Support PlotTwists"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FaIcon(
                FontAwesomeIcons.solidHeart,
                size: 80,
                color: AppColors.auroraPink,
              ),
              const SizedBox(height: 24),
              const Text(
                "Support Features Coming Soon!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Thank you for considering supporting the app. We're working on ways for you to contribute and help keep the servers running!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}
