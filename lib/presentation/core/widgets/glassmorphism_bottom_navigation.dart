import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../app_animations.dart';

/// Enhanced glassmorphism bottom navigation with cinematic styling
/// Features floating design, blur effects, and smooth animations
class GlassmorphismBottomNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<AppNavigationDestination> destinations;
  final EdgeInsetsGeometry? margin;
  final double height;
  final double borderRadius;

  const GlassmorphismBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.destinations,
    this.margin,
    this.height = 80,
    this.borderRadius = 28,
  });

  @override
  State<GlassmorphismBottomNavigation> createState() =>
      _GlassmorphismBottomNavigationState();
}

class _GlassmorphismBottomNavigationState
    extends State<GlassmorphismBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _glowController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _slideController.forward();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: MotionPresets.slideUp.duration,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: MotionPresets.slideUp.curve,
          ),
        );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start subtle glow animation
    _glowController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: widget.margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.navigationGlass,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: AppColors.glassmorphismBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: AppColors.cinematicGold.withValues(
                          alpha: 0.1 + (0.05 * _glowAnimation.value),
                        ),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: _buildNavigationContent(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.destinations.asMap().entries.map((entry) {
          final index = entry.key;
          final destination = entry.value;
          return _buildNavigationItem(
            destination.icon,
            destination.selectedIcon ?? destination.icon,
            destination.label,
            index,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationItem(
    Widget icon,
    Widget selectedIcon,
    String label,
    int index,
  ) {
    final bool isSelected = widget.selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleItemTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Selection Indicator Background
              _buildSelectionIndicator(isSelected),

              // Navigation Item Content
              _buildItemContent(icon, selectedIcon, label, isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: isSelected ? 64 : 0,
      height: isSelected ? 64 : 0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected
            ? RadialGradient(
                colors: [
                  AppColors.cinematicGold.withValues(alpha: 0.3),
                  AppColors.cinematicGold.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              )
            : null,
      ),
    );
  }

  Widget _buildItemContent(
    Widget icon,
    Widget selectedIcon,
    String label,
    bool isSelected,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated Icon
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: AnimatedScale(
            key: ValueKey(isSelected),
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: IconTheme(
              data: IconThemeData(
                color: isSelected
                    ? AppColors.cinematicGold
                    : AppColors.darkTextSecondary,
                size: 20,
              ),
              child: isSelected ? selectedIcon : icon,
            ),
          ),
        ),

        const SizedBox(height: 2),

        // Animated Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          style: AppTypography.navigation.copyWith(
            color: isSelected
                ? AppColors.cinematicGold
                : AppColors.darkTextSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 10,
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  void _handleItemTap(int index) {
    if (index != widget.selectedIndex) {
      // Trigger haptic feedback
      HapticFeedback.lightImpact();

      // Call the callback
      widget.onItemTapped(index);
    }
  }
}

/// Navigation destination data class
class AppNavigationDestination {
  final Widget icon;
  final Widget? selectedIcon;
  final String label;

  const AppNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Predefined navigation destinations for common app sections
class AppNavigationDestinations {
  static const List<AppNavigationDestination> main = [
    AppNavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    AppNavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore_rounded),
      label: 'Discover',
    ),
    AppNavigationDestination(
      icon: Icon(Icons.bookmark_outline_rounded),
      selectedIcon: Icon(Icons.bookmark_rounded),
      label: 'Library',
    ),
    AppNavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  static const List<AppNavigationDestination> extended = [
    AppNavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    AppNavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore_rounded),
      label: 'Discover',
    ),
    AppNavigationDestination(
      icon: Icon(Icons.video_library_outlined),
      selectedIcon: Icon(Icons.video_library_rounded),
      label: 'Library',
    ),
    AppNavigationDestination(
      icon: Icon(Icons.favorite_outline_rounded),
      selectedIcon: Icon(Icons.favorite_rounded),
      label: 'Favorites',
    ),
    AppNavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];
}

/// Specialized navigation variants for different contexts
class CinematicBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CinematicBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphismBottomNavigation(
      selectedIndex: selectedIndex,
      onItemTapped: onItemTapped,
      destinations: AppNavigationDestinations.main,
      height: 85,
      borderRadius: 32,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    );
  }
}

class CompactBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CompactBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphismBottomNavigation(
      selectedIndex: selectedIndex,
      onItemTapped: onItemTapped,
      destinations: AppNavigationDestinations.main,
      height: 70,
      borderRadius: 24,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }
}

/// Navigation wrapper that handles safe area and positioning
class FloatingNavigationWrapper extends StatelessWidget {
  final Widget child;
  final Widget navigation;

  const FloatingNavigationWrapper({
    super.key,
    required this.child,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Positioned.fill(child: child),

            // Floating navigation
            Positioned(bottom: 0, left: 0, right: 0, child: navigation),
          ],
        ),
      ),
    );
  }
}
