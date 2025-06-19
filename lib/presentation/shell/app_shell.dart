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
  final VoidCallback onLogout; // <-- ADD THIS LINE

  const AppShell({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLogout, // <-- AND ADD THIS LINE
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // We can't use a const list anymore since we need to pass a widget property.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize the screens list here to access widget.onLogout
    _screens = [
      const HomeScreen(),
      const DiscoverScreen(),
      const WatchlistScreen(),
      ProfileScreen(onLogout: widget.onLogout), // <-- PASS THE CALLBACK HERE
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('PlotTwists'),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round,
            ),
            onPressed: widget.onThemeChanged,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        // prevent page view from rebuilding by using the list from state
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
