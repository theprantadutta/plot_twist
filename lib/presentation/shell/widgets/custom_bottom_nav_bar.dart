import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      height: 75,
      // The main container for the glass effect
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            // The row containing the navigation items
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_filled, 'Home', 0),
                _buildNavItem(Icons.explore_rounded, 'Discover', 1),
                _buildNavItem(Icons.bookmark_rounded, 'Watchlist', 2),
                _buildNavItem(Icons.person_rounded, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A completely redesigned Nav Item widget
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          onItemTapped(index);
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The glowing "Aura" effect that fades in
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.auroraPink.withValues(alpha: 0.4),
                      AppColors.auroraPurple.withValues(alpha: 0.0),
                    ],
                    // Concentrate the gradient in the center
                    stops: const [0.25, 1.0],
                  ),
                ),
              ),
            ),

            // The Icon and Text Column
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated scale for the icon
                AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.fastOutSlowIn,
                  child: Icon(
                    icon,
                    // The icon is always white, but its container gives it color
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 4),
                // Animated text style for the label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.fastOutSlowIn,
                  style: TextStyle(
                    fontSize: 11,
                    // Use bright white for selected, and a dimmer white for unselected
                    color: Colors.white.withValues(
                      alpha: isSelected ? 1.0 : 0.7,
                    ),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
