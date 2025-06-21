// lib/presentation/shell/app_shell.dart

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
      const HomeScreen(), // Has its own SliverAppBar
      const DiscoverScreen(),
      const WatchlistScreen(),
      ProfileScreen(onLogout: widget.onLogout), // Has its own AppBar
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is now an IndexedStack, which is better for state preservation
      body: IndexedStack(index: _selectedIndex, children: _screens),
      // The bottom navigation bar remains the same
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
