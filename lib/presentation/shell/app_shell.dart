// // lib/presentation/shell/app_shell.dart

// import 'package:flutter/material.dart';

// import '../pages/discover/discover_screen.dart';
// import '../pages/home/home_screen.dart';
// import '../pages/profile/profile_screen.dart';
// import '../pages/watchlist/watchlist_screen.dart';
// import 'widgets/custom_bottom_nav_bar.dart';

// class AppShell extends StatefulWidget {
//   final bool isDarkMode;
//   final VoidCallback onThemeChanged;
//   final VoidCallback onLogout;

//   const AppShell({
//     super.key,
//     required this.isDarkMode,
//     required this.onThemeChanged,
//     required this.onLogout,
//   });

//   @override
//   State<AppShell> createState() => _AppShellState();
// }

// class _AppShellState extends State<AppShell> {
//   int _selectedIndex = 0;

//   late final List<Widget> _screens;

//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       const HomeScreen(), // Has its own SliverAppBar
//       const DiscoverScreen(),
//       const WatchlistScreen(),
//       ProfileScreen(onLogout: widget.onLogout), // Has its own AppBar
//     ];
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // The body is now an IndexedStack, which is better for state preservation
//       body: IndexedStack(index: _selectedIndex, children: _screens),
//       // The bottom navigation bar remains the same
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// import '../pages/discover/discover_screen.dart';
// import '../pages/home/home_screen.dart';
// import '../pages/profile/profile_screen.dart';
// import '../pages/watchlist/watchlist_screen.dart';
// import 'widgets/custom_bottom_nav_bar.dart';

// class AppShell extends StatefulWidget {
//   final bool isDarkMode;
//   final VoidCallback onThemeChanged;
//   final VoidCallback onLogout;

//   const AppShell({
//     super.key,
//     required this.isDarkMode,
//     required this.onThemeChanged,
//     required this.onLogout,
//   });

//   @override
//   State<AppShell> createState() => _AppShellState();
// }

// class _AppShellState extends State<AppShell> {
//   int _selectedIndex = 0;
//   // --- THIS IS THE NEW CONTROLLER ---
//   // We use a PageController to control the PageView programmatically
//   late final PageController _pageController;

//   late final List<Widget> _screens;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _selectedIndex);
//     _screens = [
//       const HomeScreen(),
//       const DiscoverScreen(),
//       const WatchlistScreen(),
//       ProfileScreen(onLogout: widget.onLogout),
//     ];
//   }

//   // The onTap method is now updated to smoothly animate to the new page
//   void _onItemTapped(int index) {
//     // We don't need setState here anymore because the onPageChanged callback will handle it
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     // It's crucial to dispose of the controller to prevent memory leaks
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // --- THE BODY IS NOW A PAGEVIEW.BUILDER ---
//       // This allows for swiping between the main screens
//       body: PageView.builder(
//         controller: _pageController,
//         itemCount: _screens.length,
//         itemBuilder: (context, index) {
//           return _screens[index];
//         },
//         // This callback updates the selectedIndex when the user swipes
//         onPageChanged: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//       // ---------------------------------------------
//       bottomNavigationBar: CustomBottomNavBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// import '../pages/discover/discover_screen.dart';
// import '../pages/home/home_screen.dart';
// import '../pages/profile/profile_screen.dart';
// import '../pages/watchlist/watchlist_screen.dart';
// import 'widgets/custom_bottom_nav_bar.dart';

// class AppShell extends StatefulWidget {
//   final bool isDarkMode;
//   final VoidCallback onThemeChanged;
//   final VoidCallback onLogout;

//   const AppShell({
//     super.key,
//     required this.isDarkMode,
//     required this.onThemeChanged,
//     required this.onLogout,
//   });

//   @override
//   State<AppShell> createState() => _AppShellState();
// }

// class _AppShellState extends State<AppShell> {
//   int _selectedIndex = 0;
//   late final PageController _pageController;

//   late final List<Widget> _screens;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _selectedIndex);
//     _screens = [
//       const HomeScreen(),
//       const DiscoverScreen(),
//       const WatchlistScreen(),
//       ProfileScreen(onLogout: widget.onLogout),
//     ];
//   }

//   void _onItemTapped(int index) {
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // extendBody allows the PageView to go behind our floating nav bar
//       extendBody: true,
//       // --- THE BODY IS NOW A STACK TO FLOAT THE NAV BAR ---
//       body: Stack(
//         children: [
//           // The PageView is the main content, filling the whole screen
//           PageView.builder(
//             controller: _pageController,
//             itemCount: _screens.length,
//             itemBuilder: (context, index) {
//               return _screens[index];
//             },
//             onPageChanged: (index) {
//               setState(() {
//                 _selectedIndex = index;
//               });
//             },
//           ),
//           // We use Positioned to place the Nav Bar at the bottom
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: CustomBottomNavBar(
//               selectedIndex: _selectedIndex,
//               onItemTapped: _onItemTapped,
//             ),
//           ),
//         ],
//       ),
//       // The bottomNavigationBar property is no longer used
//       // bottomNavigationBar: ...
//     );
//   }
// }

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
  // --- PageController is no longer needed ---
  // late final PageController _pageController;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // We no longer initialize a PageController here
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

  // We no longer need to dispose of a controller
  // @override
  // void dispose() { ... }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // This is key for the floating effect
      body: Stack(
        children: [
          // --- THE BODY IS NOW AN INDEXEDSTACK ---
          // This preserves the state of each screen when switching tabs
          IndexedStack(index: _selectedIndex, children: _screens),
          // ----------------------------------------

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
    );
  }
}
