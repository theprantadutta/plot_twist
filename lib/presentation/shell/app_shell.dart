import 'package:flutter/material.dart';

import '../pages/discover/discover_screen.dart';
import '../pages/home/home_screen.dart';
import '../pages/profile/profile_screen.dart';
import '../pages/watchlist/watchlist_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';

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
              child: CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
