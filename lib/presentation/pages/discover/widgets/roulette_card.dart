import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';
import '../../auth/widgets/auth_button.dart';

class RouletteCard extends StatelessWidget {
  const RouletteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.auroraPink.withValues(alpha: 0.5)),
        // A cool, subtle gradient
        gradient: LinearGradient(
          colors: [
            AppColors.auroraPurple.withValues(alpha: 0.1),
            AppColors.darkSurface.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            children: [
              const FaIcon(
                FontAwesomeIcons.diceD20,
                color: AppColors.auroraPink,
                size: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                "Feeling Adventurous?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Let us find a hidden gem for you to watch tonight.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              AuthButton(text: "Find a Movie", onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
