import 'package:flutter/material.dart';

import 'lib/presentation/theme/app_colors.dart';

void main() {
  runApp(const PlotTwistsApp());
}

class PlotTwistsApp extends StatefulWidget {
  const PlotTwistsApp({super.key});

  @override
  State<PlotTwistsApp> createState() => _PlotTwistsAppState();
}

class _PlotTwistsAppState extends State<PlotTwistsApp> {
  // State to toggle between light and dark theme
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the dark theme
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.auroraPink,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.auroraPink,
        secondary: AppColors.auroraPurple,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkTextPrimary,
        onSecondary: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.darkErrorRed,
        onError: AppColors.darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.auroraPink,
        unselectedItemColor: AppColors.darkTextSecondary,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      ),
    );

    // Define the light theme
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.auroraPink,
      colorScheme: const ColorScheme.light(
        primary: AppColors.auroraPink,
        secondary: AppColors.auroraPurple,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.lightErrorRed,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.auroraPink,
        unselectedItemColor: AppColors.lightTextSecondary,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      ),
    );

    return MaterialApp(
      title: 'PlotTwists',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: HomePage(isDarkMode: _isDarkMode, onThemeChanged: _toggleTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // A dummy screen to showcase the colors based on the selected tab
    final List<Widget> widgetOptions = <Widget>[
      ColorShowcase(isDarkMode: widget.isDarkMode),
      const Center(child: Text('Discover Page')),
      const Center(child: Text('Watchlist Page')),
      const Center(child: Text('Profile Page')),
    ];

    return Scaffold(
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
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// A widget to demonstrate the color palette in action
class ColorShowcase extends StatelessWidget {
  final bool isDarkMode;
  const ColorShowcase({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final successColor = isDarkMode
        ? AppColors.darkSuccessGreen
        : AppColors.lightSuccessGreen;
    final infoColor = isDarkMode
        ? AppColors.darkInfoCyan
        : AppColors.lightInfoCyan;
    final starColor = isDarkMode
        ? AppColors.darkStarlightGold
        : AppColors.lightStarlightGold;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color Showcase', style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'This screen demonstrates the custom color palette for the ${isDarkMode ? "Dark" : "Light"} Theme.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Movie Card Example',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This card uses the "Surface" color. The text below shows primary and secondary text colors.',
                    style: textTheme.bodyMedium,
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: starColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '8.5',
                            style: textTheme.bodyLarge?.copyWith(
                              color: starColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: infoColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Action',
                          style: textTheme.bodyLarge?.copyWith(
                            color: infoColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Gradient Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.auroraGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.auroraPink.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Primary Action (Gradient)',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Success Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(
                Icons.check_circle_outline_rounded,
                color: successColor,
              ),
              label: Text(
                'Mark as Watched',
                style: TextStyle(color: successColor),
              ),
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: successColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
