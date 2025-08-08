import 'package:flutter/material.dart';
import 'glassmorphism_bottom_navigation.dart';

/// Example usage of GlassmorphismBottomNavigation
class GlassmorphismBottomNavigationExample extends StatefulWidget {
  const GlassmorphismBottomNavigationExample({super.key});

  @override
  State<GlassmorphismBottomNavigationExample> createState() =>
      _GlassmorphismBottomNavigationExampleState();
}

class _GlassmorphismBottomNavigationExampleState
    extends State<GlassmorphismBottomNavigationExample> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DemoScreen(title: 'Home', color: Colors.blue),
    const _DemoScreen(title: 'Discover', color: Colors.green),
    const _DemoScreen(title: 'Library', color: Colors.orange),
    const _DemoScreen(title: 'Profile', color: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Column(
        children: [
          // App Bar
          AppBar(
            title: const Text('Glassmorphism Navigation'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),

          // Main Content
          Expanded(
            child: FloatingNavigationWrapper(
              navigation: CinematicBottomNavigation(
                selectedIndex: _selectedIndex,
                onItemTapped: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoScreen extends StatelessWidget {
  final String title;
  final Color color;

  const _DemoScreen({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.1), Colors.transparent],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForTitle(title), size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This is the $title screen',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Home':
        return Icons.home_rounded;
      case 'Discover':
        return Icons.explore_rounded;
      case 'Library':
        return Icons.bookmark_rounded;
      case 'Profile':
        return Icons.person_rounded;
      default:
        return Icons.circle;
    }
  }
}

/// Different navigation variants example
class NavigationVariantsExample extends StatefulWidget {
  const NavigationVariantsExample({super.key});

  @override
  State<NavigationVariantsExample> createState() =>
      _NavigationVariantsExampleState();
}

class _NavigationVariantsExampleState extends State<NavigationVariantsExample> {
  int _selectedIndex = 0;
  int _variantIndex = 0;

  final List<String> _variants = ['Cinematic', 'Compact', 'Custom'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Navigation Variants'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            onSelected: (index) => setState(() => _variantIndex = index),
            itemBuilder: (context) => _variants.asMap().entries.map((entry) {
              return PopupMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_variants[_variantIndex]),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FloatingNavigationWrapper(
        navigation: _buildNavigationVariant(),
        child: const _DemoScreen(title: 'Content', color: Colors.indigo),
      ),
    );
  }

  Widget _buildNavigationVariant() {
    switch (_variantIndex) {
      case 0: // Cinematic
        return CinematicBottomNavigation(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) => setState(() => _selectedIndex = index),
        );
      case 1: // Compact
        return CompactBottomNavigation(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) => setState(() => _selectedIndex = index),
        );
      case 2: // Custom
        return GlassmorphismBottomNavigation(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) => setState(() => _selectedIndex = index),
          destinations: AppNavigationDestinations.extended,
          height: 90,
          borderRadius: 35,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        );
      default:
        return CinematicBottomNavigation(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) => setState(() => _selectedIndex = index),
        );
    }
  }
}
