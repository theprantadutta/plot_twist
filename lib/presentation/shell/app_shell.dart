import 'package:flutter/material.dart';

import '../pages/discover/discover_screen.dart';
import '../pages/home/home_screen.dart';
import '../pages/profile/profile_screen.dart';
import '../pages/watchlist/watchlist_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import '../core/widgets/glassmorphism_bottom_navigation.dart';

class AppShell extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;
  final VoidCallback onLogout;

  const AppShell({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const DiscoverScreen(),
      const WatchlistScreen(),
      ProfileScreen(onLogout: widget.onLogout),
    ];
  }

  // The onTap method is now simpler, just updating the state
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // This is key for the floating effect
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(index: _selectedIndex, children: _screens),
            // The Positioned Nav Bar remains the same, creating the floating effect
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassmorphismBottomNavigation(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
                destinations: const [
                  AppNavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  AppNavigationDestination(
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore),
                    label: 'Discover',
                  ),
                  AppNavigationDestination(
                    icon: Icon(Icons.video_library_outlined),
                    selectedIcon: Icon(Icons.video_library),
                    label: 'Library',
                  ),
                  AppNavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
