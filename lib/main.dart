import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_twist/presentation/core/auth_guard.dart';

import 'application/home/home_providers.dart';
import 'application/settings/appearance_provider.dart';
import 'data/local/persistence_service.dart';
import 'firebase_options.dart';
import 'presentation/core/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 1. Create an instance of our persistence service
  final persistenceService = PersistenceService();
  // 2. Initialize it (and wait for it to complete)
  await persistenceService.init();
  dotenv.load();
  runApp(
    ProviderScope(
      overrides: [
        persistenceServiceProvider.overrideWithValue(persistenceService),
      ],
      child: PlotTwistsApp(),
    ),
  );
}

class PlotTwistsApp extends ConsumerWidget {
  const PlotTwistsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theme definitions remain here as they are an app-level concern.
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: appearanceState.useTrueBlack
          ? Colors.black
          : AppColors.darkBackground,
      primaryColor: appearanceState.accentColor, // Dynamic Accent Color
      colorScheme: ColorScheme.dark(
        primary: appearanceState.accentColor, // Dynamic Accent Color
        secondary: AppColors.auroraPurple,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkTextPrimary,
        onSecondary: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.darkErrorRed,
        onError: AppColors.darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      ),
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: appearanceState.accentColor, // Dynamic Accent Color
      colorScheme: ColorScheme.light(
        primary: appearanceState.accentColor, // Dynamic Accent Color
        secondary: AppColors.auroraPurple,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.lightErrorRed,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      ),
    );

    return MaterialApp(
      title: 'Plot Twists',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appearanceState.themeMode,
      debugShowCheckedModeBanner: false,
      // home: AppShell(isDarkMode: _isDarkMode, onThemeChanged: _toggleTheme),
      home: AuthGuard(),
    );
  }
}
